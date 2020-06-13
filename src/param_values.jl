function get_param_values(arg)
    key = ENV["USDA_QUICK_SURVEY_KEY"]
    url = string(usda_url, "/api/get_param_values/?key=", key, "&param=", arg)

    JSON3.read(request("GET", url).body)
end
