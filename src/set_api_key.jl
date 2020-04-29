function get_api_key()
    "USDA_QUICK_SURVEY_KEY" in keys(ENV) ? (println("Your API key is: " * ENV["USDA_QUICK_SURVEY_KEY"])) : (println("You don't have a key in your environment. Use set_api_key"))
end

function set_api_key(api_key::String)
    length(api_key) != 36 ? (throw("Key must be 36 characters long")) : nothing

    if "USDA_QUICK_SURVEY_KEY" ∉ keys(ENV) || length(ENV["USDA_QUICK_SURVEY_KEY"]) != 36
        ENV["USDA_QUICK_SURVEY_KEY"] = api_key
        println("local API key is set.")
    else
        throw("You already have a registered key")
    end
end
