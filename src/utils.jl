function get_counts(args...)
    key = ENV["USDA_QUICK_SURVEY_KEY"]
    header = string(usda_url, "/api/get_counts/?key=", key) 

    query = ""
    
    for i in args
        arg = string("&", i)
        query *= arg
    end

    url = string(header, query)

    r = HTTP.request("GET", url)
    return(JSON3.read(r.body))
end

function get_param_values(arg)
    key = ENV["USDA_QUICK_SURVEY_KEY"]
    url = string(usda_url, "/api/get_param_values/?key=", key, "&param=", arg) 

    r = HTTP.request("GET", url)
    return(JSON3.read(r.body))
end

function get_nass(args...)
    key = ENV["USDA_QUICK_SURVEY_KEY"]
    header = string(usda_url, "/api/api_GET/?key=", key) 

    query = ""
    
    for i in args
        arg = string("&", i)
        query *= arg
    end

    url = string(header, query)

    r = HTTP.request("GET", url)
end

function return_table(json_object)
    DataFrames.DataFrame(JSONTables.jsontable(JSON3.read(json_object.body)[:data]))
end


function return_param_values(json_object, arg::Symbol)
    json_object[arg]
end
