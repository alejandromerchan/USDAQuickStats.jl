function get_param_values(arg)
    key = ENV["USDA_QUICK_SURVEY_KEY"]
    url = string(usda_url, "/api/get_param_values/?key=", key, "&param=", arg)

    r = HTTP.request("GET", url)
    r
    #return(JSON3.read(r.body))
end

function return_param_values(json_object, arg::Symbol)
    json_object[arg]
end
