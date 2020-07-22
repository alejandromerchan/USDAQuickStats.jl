


function get_nass(args...; format="json")
    key = ENV["USDA_QUICK_SURVEY_KEY"]

    header = string(usda_url, "/api/api_GET/?key=", key, "&format=$format")

    query = ""
    for i in args
        arg = string("&", i)
        query *= arg
    end

    if uppercase(format) == "JSON"
        r = request("GET", string(header, query)).body
        DataFrame(jsontable(JSON3.read(r)[:data]))
    elseif uppercase(format) == "CSV"
        r = request("GET", string(header, query)).body
        CSV.File(r) |> DataFrame
    else
        r = request("GET", string(header, query))
    end
end
