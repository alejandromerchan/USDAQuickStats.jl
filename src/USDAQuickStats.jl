module USDAQuickStats

using HTTP

export
    set_api_key,
    get_api_key,
    get_counts,
    get_param_values,
    get_nass,
    get_nass_df

const usda_url = Ref("https://quickstats.nass.usda.gov")
const USDA_KEY_NAME = "USDA_QUICK_SURVEY_KEY"

include("utils.jl")
include("set_api_key.jl")
include("nass.jl")
include("counts.jl")
include("param_values.jl")


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
function get_nass_df end

end # module
