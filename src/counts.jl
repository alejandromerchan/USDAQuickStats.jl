function get_counts(args...)
    key = ENV["USDA_QUICK_SURVEY_KEY"]
    header = string(usda_url, "/api/get_counts/?key=", key)

    query = ""

    for i in args
        arg = string("&", i)
        query *= arg
    end

    request("GET", string(header, query))
end
