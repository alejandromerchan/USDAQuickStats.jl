"""
    set_api_key(api_key::String; overwrite::Bool=false)

Set the USDA NASS Quick Stats API key as an environment variable for the 
current Julia session.

The API key must be a 36-character UUID string. You can request a key at 
https://quickstats.nass.usda.gov/api.

# Arguments
- `api_key::String`: Your USDA NASS API key (36-character UUID format).

# Keywords
- `overwrite::Bool=false`: If `true`, allows replacing an already-registered key.

# Examples
```julia
set_api_key("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

# Overwrite an existing key
set_api_key("yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"; overwrite=true)
```
"""
function set_api_key(api_key::String; overwrite::Bool=false)
    if length(api_key) != 36
        throw(ArgumentError("API key must be 36 characters long (UUID format). Got $(length(api_key)) characters."))
    end

    if haskey(ENV, USDA_KEY_NAME) && !overwrite
        throw(ArgumentError("An API key is already set. Use set_api_key(key; overwrite=true) to replace it."))
    end

    ENV[USDA_KEY_NAME] = api_key
    println("USDA NASS API key set successfully.")
end

"""
    get_api_key() -> String

Return the currently set USDA NASS API key, or throw an informative error 
if none has been set.

# Examples
```julia
get_api_key()
```
"""
function get_api_key()::String
    if !haskey(ENV, USDA_KEY_NAME)
        throw(KeyError("No USDA NASS API key found. Set one with: set_api_key(\"your-key-here\")"))
    end
    return ENV[USDA_KEY_NAME]
end
