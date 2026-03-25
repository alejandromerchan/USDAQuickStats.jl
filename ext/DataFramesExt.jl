module DataFramesExt

using USDAQuickStats
using USDAQuickStats: _parse_response
using DataFrames
using JSON3
using JSONTables
using CSV

"""
    _parse_response(body::Vector{UInt8}, format::String) -> Union{DataFrame, Vector{UInt8}}

Extension method for `_parse_response` that returns a `DataFrame` directly
when `DataFrames`, `JSON3`, `JSONTables`, and `CSV` are all loaded.

Supports the following formats:
- `"json"`: parses the response body using `JSON3` and `JSONTables` and
  returns a `DataFrame`.
- `"csv"`: reads the response body using `CSV.read` and returns a `DataFrame`.
- `"xml"`: DataFrame conversion is not supported for XML. Returns raw
  `Vector{UInt8}` with a warning.

This method is an internal hook called by `get_nass` and is not intended
to be called directly by users. Load `DataFrames` alongside `USDAQuickStats`
to activate this extension automatically.

# Examples
```julia
using USDAQuickStats, DataFrames

# JSON (default) — returns DataFrame directly
df = get_nass("source_desc=SURVEY", "commodity_desc=ORANGES", "state_alpha=CA", "year=2019")

# CSV — returns DataFrame directly
df = get_nass("commodity_desc=ORANGES", "state_alpha=CA"; format="csv")
```
"""
function USDAQuickStats._parse_response(body::Vector{UInt8}, format::String)
    if lowercase(format) == "json"
        return DataFrame(jsontable(JSON3.read(body).data))
    elseif lowercase(format) == "csv"
        return CSV.read(body, DataFrame)
    else
        @warn "DataFrame conversion is not supported for XML format. Returning raw bytes."
        return body
    end
end

end # module