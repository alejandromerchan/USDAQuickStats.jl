using Test
using USDAQuickStats

# Helper to temporarily set/unset the API key between tests
function with_key(f, key="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
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
        isnothing(old) || (ENV["USDA_QUICK_SURVEY_KEY"] = old)
    end
end

@testset "USDAQuickStats.jl" begin

    @testset "set_api_key" begin
        without_key() do
            # Valid key sets successfully
            @test begin
                set_api_key("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
                ENV["USDA_QUICK_SURVEY_KEY"] == "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
            end

            # Cannot set key again without overwrite
            @test_throws ArgumentError set_api_key("yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy")

            # Can overwrite with overwrite=true
            @test begin
                set_api_key("yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"; overwrite=true)
                ENV["USDA_QUICK_SURVEY_KEY"] == "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
            end
        end

        without_key() do
            # Too short
            @test_throws ArgumentError set_api_key("tooshort")

            # Too long
            @test_throws ArgumentError set_api_key("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-extra")
        end
    end

    @testset "get_api_key" begin
        without_key() do
            # Throws when no key is set
            @test_throws KeyError get_api_key()
        end

        with_key() do
            # Returns the key when set
            @test get_api_key() == "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        end
    end

    @testset "_encode_param" begin
        # Basic encoding
        @test USDAQuickStats._encode_param("state_alpha=CA") == "state_alpha=CA"

        # Spaces in value are encoded
        @test USDAQuickStats._encode_param("statisticcat_desc=AREA BEARING") ==
              "statisticcat_desc=AREA%20BEARING"

        # Ampersands in value are encoded
        @test USDAQuickStats._encode_param("commodity_desc=FRUITS & NUTS") ==
              "commodity_desc=FRUITS%20%26%20NUTS"

        # Missing = sign throws
        @test_throws ArgumentError USDAQuickStats._encode_param("no_equals_sign")
    end

    @testset "_build_query" begin
        # Empty args returns empty string
        @test USDAQuickStats._build_query(()) == ""

        # Single param
        @test USDAQuickStats._build_query(("state_alpha=CA",)) == "&state_alpha=CA"

        # Multiple params
        @test USDAQuickStats._build_query(("state_alpha=CA", "year=2019")) ==
              "&state_alpha=CA&year=2019"

        # Spaces are encoded
        @test USDAQuickStats._build_query(("statisticcat_desc=AREA BEARING",)) ==
              "&statisticcat_desc=AREA%20BEARING"
    end

    @testset "get_nass format validation" begin
        with_key() do
            # Invalid format throws before hitting the network
            @test_throws ArgumentError get_nass("commodity_desc=ORANGES"; format="xlsx")
            @test_throws ArgumentError get_nass("commodity_desc=ORANGES"; format="")

            # Valid formats do not throw on validation
            # (they will fail on network, but that's a different error)
            @test_throws Exception get_nass("commodity_desc=ORANGES"; format="json")
            @test_throws Exception get_nass("commodity_desc=ORANGES"; format="csv")
            @test_throws Exception get_nass("commodity_desc=ORANGES"; format="xml")
        end
    end

end