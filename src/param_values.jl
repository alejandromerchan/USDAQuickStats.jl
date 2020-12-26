function get_param_values(arg)
    key = ENV["USDA_QUICK_SURVEY_KEY"]

    request("GET", string(usda_url, "/api/get_param_values/?key=", key, "&param=", arg))
end
