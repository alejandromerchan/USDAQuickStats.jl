module USDAQuickStats

import HTTP
import JSON3
import JSONTables
import DataFrames

export
    set_api_key

const usda_url = " http://quickstats.nass.usda.gov"

include("set_api_key.jl")
include("utils.jl")

end # module
