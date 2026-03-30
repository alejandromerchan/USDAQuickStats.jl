const VALID_FORMATS = ("json", "csv", "xml")

"""
    get_nass(args...; format="json") -> Vector{UInt8}

Query the USDA NASS Quick Stats database and return the raw response body
as bytes. The caller is responsible for parsing the result using their
preferred packages.

Each argument is a `"field=VALUE"` string. Spaces in values are handled
automatically — no need for `%20`.

Note: the API has a limit of 50,000 records per query. Use `get_counts`
first to verify your query is within the limit.

# Arguments
- `args...`: Query parameters as `"field=VALUE"` strings.

# Keywords
- `format::String="json"`: Response format, one of `"json"`, `"csv"`, `"xml"`.

# Examples
```julia
# JSON (default) — parse with JSON3
using JSON3, JSONTables, DataFrames
data = get_nass("source_desc=SURVEY", "commodity_desc=ORANGES", "state_alpha=CA", "year=2019")
df = DataFrame(jsontable(JSON3.read(data).data))

# CSV — parse with CSV.jl
using CSV, DataFrames
data = get_nass("commodity_desc=ORANGES", "state_alpha=CA"; format="csv")
df = CSV.read(data, DataFrame)

# Save raw response to disk
write("output.json", get_nass("commodity_desc=ORANGES"))
```
"""
function get_nass(args...; format::String="json")
    if lowercase(format) ∉ VALID_FORMATS
        throw(ArgumentError("Invalid format \"$format\". Must be one of: $(join(VALID_FORMATS, ", "))"))
    end
    key = get_api_key()
    url = string(usda_url, "/api/api_GET/?key=", key, "&format=", lowercase(format), _build_query(args))
    response = _make_request(url)
    return response.body
end
