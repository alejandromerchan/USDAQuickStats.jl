module DataFramesExt

using USDAQuickStats
using USDAQuickStats: usda_url, _build_query, _make_request, VALID_FORMATS
using DataFrames
using JSON3
using JSONTables
using CSV

"""
    get_nass_df(args...; format="json") -> DataFrame

Query the USDA NASS Quick Stats database and return the results as a
`DataFrame` directly. Available when `DataFrames`, `JSON3`, `JSONTables`,
and `CSV` are loaded.

Supports `"json"` and `"csv"` formats. XML is not supported and will
throw an `ArgumentError`.

See `get_nass` for full documentation of query parameters.

# Examples
```julia
using USDAQuickStats, DataFrames

df = get_nass_df("commodity_desc=ORANGES", "state_alpha=CA", "year=2019")
```
"""
function USDAQuickStats.get_nass_df(args...; format::String="json")
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
        throw(ArgumentError("DataFrame conversion is not supported for XML format. Use get_nass with format=\"xml\" to retrieve raw bytes."))
    end
end

end # module