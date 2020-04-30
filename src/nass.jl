


function get_nass(args...; format="json")
    key = ENV["USDA_QUICK_SURVEY_KEY"]

    header = string(usda_url, "/api/api_GET/?key=", key, "&format=$format")

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
