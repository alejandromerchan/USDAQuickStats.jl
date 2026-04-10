"""
    get_counts(args...) -> Int

Return the number of records that a query with the given parameters would
return, without actually fetching the data. Useful for checking whether a
query would exceed the 50,000 record limit imposed by the USDA NASS API.

Each argument is a `"field=VALUE"` string. Spaces in values are handled
automatically — no need for `%20`.

# Arguments
- `args...`: Query parameters as `"field=VALUE"` strings.

# Examples
```julia
get_counts("source_desc=SURVEY", "commodity_desc=ORANGES", "state_alpha=CA", "year=2019")
```
"""
function get_counts(args...)
    key = get_api_key()
    url = string(usda_url[], "/api/get_counts/?key=", key, _build_query(args))
    response = _make_request(url)
    body = String(response.body)
    m = match(r"\d+", body)
    m === nothing && throw(ErrorException("Unexpected response from counts endpoint: $body"))
    return parse(Int, m.match)
end
