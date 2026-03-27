module USDAQuickStats

using HTTP

export
    set_api_key,
    get_api_key,
    get_counts,
    get_param_values,
    get_nass
    get_nass_df

const usda_url = "https://quickstats.nass.usda.gov"
const USDA_KEY_NAME = "USDA_QUICK_SURVEY_KEY"

include("utils.jl")
include("set_api_key.jl")
include("nass.jl")
include("counts.jl")
include("param_values.jl")

end # module