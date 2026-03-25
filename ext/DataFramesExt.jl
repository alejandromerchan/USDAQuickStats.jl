module DataFramesExt

using USDAQuickStats
using USDAQuickStats: usda_url, USDA_KEY_NAME, _build_query, _make_request, VALID_FORMATS
using HTTP
using DataFrames
using JSON3
using JSONTables
using CSV

"""
    get_nass(args...; format="json") -> DataFrame

Extension method for `get_nass` that returns a `DataFrame` directly when
`DataFrames` is loaded. Requires `JSON3` and `JSONTables` for JSON format,
or `CSV` for CSV format.

See `USDAQuickStats.get_nass` for full documentation.

# Examples
```julia
using USDAQuickStats, DataFrames

data = get_nass("source_desc=SURVEY", "commodity_desc=ORANGES", "state_alpha=CA", "year=2019")
# returns a DataFrame directly
```
"""
function USDAQuickStats.get_nass(args...; format::String="json")
    if lowercase(format) ∉ VALID_FORMATS
        throw(ArgumentError("Invalid format \"$format\". Must be one of: $(join(VALID_FORMATS, ", "))"))
    end

    key = USDAQuickStats.get_api_key()
    url = string(usda_url, "/api/api_GET/?key=", key, "&format=", lowercase(format), _build_query(args))
    response = _make_request(url)

    if lowercase(format) == "json"
        return DataFrame(jsontable(JSON3.read(response.body).data))
    elseif lowercase(format) == "csv"
        return CSV.read(response.body, DataFrame)
    else
        # XML has no DataFrame conversion, fall back to raw bytes
        @warn "DataFrame conversion is not supported for XML format. Returning raw bytes."
        return response.body
    end
end

end # module