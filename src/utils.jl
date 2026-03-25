"""
    _build_query(args) -> String

Internal helper. Builds a URL query string from a collection of
`"field=VALUE"` arguments, handling URL encoding automatically.
Spaces in values can be written naturally — no need for `%20`.
"""
function _build_query(args)
    isempty(args) && return ""
    return join(["&" * _encode_param(a) for a in args])
end

"""
    _encode_param(param::String) -> String

Internal helper. URL-encodes the value side of a `"field=VALUE"` string,
leaving the field name untouched.
"""
function _encode_param(param::String)
    parts = split(param, "=", limit=2)
    length(parts) != 2 && throw(ArgumentError("Invalid query parameter: \"$param\". Expected format: \"field=VALUE\""))
    field, value = parts
    return string(field, "=", HTTP.escapeuri(value))
end

"""
    _make_request(url::String) -> HTTP.Response

Internal helper. Makes a GET request and provides informative error messages
for common failure modes.
"""
function _make_request(url::String)
    try
        response = HTTP.get(url)
        if response.status == 200
            return response
        elseif response.status == 401
            throw(ErrorException("Authentication failed. Check your API key with get_api_key()."))
        elseif response.status == 400
            throw(ErrorException("Bad request. Check your query parameters."))
        else
            throw(ErrorException("API request failed with status $(response.status)."))
        end
    catch e
        e isa ErrorException && rethrow()
        throw(ErrorException("Network error: $(sprint(showerror, e)). Check your internet connection."))
    end
end