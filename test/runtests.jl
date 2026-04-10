using Test
using USDAQuickStats
using HTTP
using DataFrames
using JSON3
using JSONTables
using CSV

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

function with_key(f, key = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
    old = get(ENV, "USDA_QUICK_SURVEY_KEY", nothing)
    ENV["USDA_QUICK_SURVEY_KEY"] = key
    try
        f()
    finally
        if isnothing(old)
            delete!(ENV, "USDA_QUICK_SURVEY_KEY")
        else
            ENV["USDA_QUICK_SURVEY_KEY"] = old
        end
    end
end

function without_key(f)
    old = get(ENV, "USDA_QUICK_SURVEY_KEY", nothing)
    delete!(ENV, "USDA_QUICK_SURVEY_KEY")
    try
        f()
    finally
        if isnothing(old)
            delete!(ENV, "USDA_QUICK_SURVEY_KEY")  # clean up even if f() set the key
        else
            ENV["USDA_QUICK_SURVEY_KEY"] = old
        end
    end
end

# ---------------------------------------------------------------------------
# Mock server
# ---------------------------------------------------------------------------

const MOCK_JSON_BODY = """{"data": [{"commodity_desc": "ORANGES", "year": "2019", "Value": "100"}]}"""
const MOCK_CSV_BODY = "commodity_desc,year,Value\nORANGES,2019,100\n"
const MOCK_COUNTS_BODY = """{"count_requested": 276}"""
const MOCK_PARAM_VALUES_BODY = """{"sector_desc": ["ANIMALS & PRODUCTS", "CROPS", "DEMOGRAPHICS"]}"""

function mock_handler(req)
    target = req.target
    # Check special/error patterns first — before normal endpoint patterns
    occursin("bad_counts", target)       && return HTTP.Response(200, "no numbers here")
    occursin("bad_param_values", target) && return HTTP.Response(200, "no quoted strings here")
    occursin("status_401", target)       && return HTTP.Response(401, "Unauthorized")
    occursin("status_400", target)       && return HTTP.Response(400, "Bad Request")
    # Normal endpoint patterns
    occursin("get_counts", target)       && return HTTP.Response(200, MOCK_COUNTS_BODY)
    occursin("get_param_values", target) && return HTTP.Response(200, MOCK_PARAM_VALUES_BODY)
    if occursin("api_GET", target)
        occursin("format=csv", target)   && return HTTP.Response(200, MOCK_CSV_BODY)
        return HTTP.Response(200, MOCK_JSON_BODY)
    end
    return HTTP.Response(404, "Not Found")
end

const MOCK_PORT = 18080
const server = HTTP.serve!(mock_handler, "127.0.0.1", MOCK_PORT)
const original_url = USDAQuickStats.usda_url[]
USDAQuickStats.usda_url[] = "http://127.0.0.1:$MOCK_PORT"

# ---------------------------------------------------------------------------
# Helper to temporarily redirect mock to a special path
# ---------------------------------------------------------------------------

function with_mock_path(f, path)
    USDAQuickStats.usda_url[] = "http://127.0.0.1:$MOCK_PORT/$path"
    try
        f()
    finally
        USDAQuickStats.usda_url[] = "http://127.0.0.1:$MOCK_PORT"
    end
end

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

@testset "USDAQuickStats.jl" begin

    @testset "set_api_key" begin
        without_key() do
            @test begin
                set_api_key("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
                ENV["USDA_QUICK_SURVEY_KEY"] == "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
            end
            @test_throws ArgumentError set_api_key("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")
            @test begin
                set_api_key("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"; overwrite = true)
                ENV["USDA_QUICK_SURVEY_KEY"] == "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
            end
        end

        without_key() do
            @test_throws ArgumentError set_api_key("tooshort")
            @test_throws ArgumentError set_api_key("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa-extra")
        end
    end

    @testset "get_api_key" begin
        without_key() do
            @test_throws KeyError get_api_key()
        end
        with_key() do
            @test get_api_key() == "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
        end
    end

    @testset "_encode_param" begin
        @test USDAQuickStats._encode_param("state_alpha=CA") == "state_alpha=CA"
        @test USDAQuickStats._encode_param("statisticcat_desc=AREA BEARING") ==
              "statisticcat_desc=AREA%20BEARING"
        @test USDAQuickStats._encode_param("commodity_desc=FRUITS & NUTS") ==
              "commodity_desc=FRUITS%20%26%20NUTS"
        @test_throws ArgumentError USDAQuickStats._encode_param("no_equals_sign")
    end

    @testset "_build_query" begin
        @test USDAQuickStats._build_query(()) == ""
        @test USDAQuickStats._build_query(("state_alpha=CA",)) == "&state_alpha=CA"
        @test USDAQuickStats._build_query(("state_alpha=CA", "year=2019")) ==
              "&state_alpha=CA&year=2019"
        @test USDAQuickStats._build_query(("statisticcat_desc=AREA BEARING",)) ==
              "&statisticcat_desc=AREA%20BEARING"
    end

    @testset "get_nass" begin
        with_key() do
            # Format validation — throws before hitting the network
            @test_throws ArgumentError get_nass("commodity_desc=ORANGES"; format = "xlsx")
            @test_throws ArgumentError get_nass("commodity_desc=ORANGES"; format = "")

            # JSON response returns raw bytes matching mock
            result = get_nass("commodity_desc=ORANGES"; format = "json")
            @test result isa Vector{UInt8}
            @test String(result) == MOCK_JSON_BODY

            # CSV response returns raw bytes matching mock
            result = get_nass("commodity_desc=ORANGES"; format = "csv")
            @test result isa Vector{UInt8}
            @test String(result) == MOCK_CSV_BODY
        end
    end

    @testset "get_counts" begin
        with_key() do
            @test get_counts("commodity_desc=ORANGES") == 276

            # Malformed response body throws ErrorException
            with_mock_path("bad_counts") do
                @test_throws ErrorException get_counts("commodity_desc=ORANGES")
            end
        end
    end

    @testset "get_param_values" begin
        with_key() do
            result = get_param_values("sector_desc")
            @test result isa Vector{String}
            @test result == ["ANIMALS & PRODUCTS", "CROPS", "DEMOGRAPHICS"]

            # Malformed response body throws ErrorException
            with_mock_path("bad_param_values") do
                @test_throws ErrorException get_param_values("sector_desc")
            end
        end
    end

    @testset "_make_request error handling" begin
        with_key() do
            with_mock_path("status_401") do
                @test_throws ErrorException get_nass("commodity_desc=ORANGES")
            end
            with_mock_path("status_400") do
                @test_throws ErrorException get_nass("commodity_desc=ORANGES")
            end
        end
    end

    @testset "DataFramesExt" begin
        with_key() do
            # JSON format returns a DataFrame
            df = get_nass_df("commodity_desc=ORANGES"; format = "json")
            @test df isa DataFrame
            @test nrow(df) == 1
            @test "commodity_desc" in names(df)

            # CSV format returns a DataFrame
            df = get_nass_df("commodity_desc=ORANGES"; format = "csv")
            @test df isa DataFrame
            @test nrow(df) == 1
            @test "commodity_desc" in names(df)

            # XML format throws ArgumentError
            @test_throws ArgumentError get_nass_df("commodity_desc=ORANGES"; format = "xml")

            # Invalid format throws ArgumentError
            @test_throws ArgumentError get_nass_df("commodity_desc=ORANGES"; format = "xlsx")
        end
    end

    @testset "Integration (requires USDA API key)" begin
        if haskey(ENV, "USDA_QUICK_SURVEY_KEY")
            USDAQuickStats.usda_url[] = original_url
            try
                @test get_counts("commodity_desc=ORANGES", "state_alpha=CA", "year=2019") isa Int
                @test get_param_values("sector_desc") isa Vector{String}
                @test get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019") isa
                      Vector{UInt8}
            finally
                USDAQuickStats.usda_url[] = "http://127.0.0.1:$MOCK_PORT"
            end
        else
            @test_skip "USDA_QUICK_SURVEY_KEY not set — skipping integration tests"
        end
    end

end

# ---------------------------------------------------------------------------
# Teardown
# ---------------------------------------------------------------------------

close(server)
USDAQuickStats.usda_url[] = original_url
