module USDAQuickStats

import HTTP: request
export
    set_api_key,
    get_api_key,       # now exported
    get_counts,
    get_param_values,
    get_nass

const usda_url = "https://quickstats.nass.usda.gov"   # http → https
const USDA_KEY_NAME = "USDA_QUICK_SURVEY_KEY"

include("set_api_key.jl")
include("nass.jl")
include("counts.jl")
include("param_values.jl")

end # module