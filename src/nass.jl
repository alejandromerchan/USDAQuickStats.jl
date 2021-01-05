


function get_nass(args...; format="json")
    key = ENV["USDA_QUICK_SURVEY_KEY"]

    header = string(usda_url, "/api/api_GET/?key=", key, "&format=$format")

    query = ""
    for i in args
        arg = string("&", i)
        query *= arg
    end

    request("GET", string(header, query))
end
