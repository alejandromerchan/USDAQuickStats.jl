"""
    get_param_values(field::String) -> Vector{String}

Return all valid values for a given database field. Useful for exploring
what values are available before constructing a query.

# Arguments
- `field::String`: The name of the database field to query (e.g. `"sector_desc"`).

# Examples
```julia
get_param_values("sector_desc")
get_param_values("commodity_desc")
```
"""
function get_param_values(field::String)
    key = get_api_key()
    url = string(usda_url[], "/api/get_param_values/?key=", key, "&param=", HTTP.escapeuri(field))
    response = _make_request(url)
    body = String(response.body)
    matches = eachmatch(r"\"([^\"]+)\"", body)
    values = [String(m.match[2:end-1]) for m in matches]
    isempty(values) && throw(ErrorException("Unexpected response from param_values endpoint: $body"))
    return values[2:end]  # skip the first match which is the field name key
end
