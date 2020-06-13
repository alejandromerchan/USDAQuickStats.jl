module USDAQuickStats

import CSV
import DataFrames: DataFrame
import HTTP: request
import JSON3
import JSONTables: jsontable


export
    set_api_key,
    get_counts,
    get_param_values,
    get_nass

const usda_url = " http://quickstats.nass.usda.gov"

include("set_api_key.jl")
include("nass.jl")
include("counts.jl")
include("param_values.jl")

end # module
