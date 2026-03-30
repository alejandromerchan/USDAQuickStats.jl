# API Reference

Documentation for all exported functions in `USDAQuickStats.jl`.

## API Key Management
```@docs
set_api_key
get_api_key
```

## Database Queries
```@docs
get_nass
get_counts
get_param_values
```

## DataFrames Extension

`get_nass_df` is available when `DataFrames`, `JSON3`, `JSONTables`, and
`CSV` are all loaded. It queries the database and returns a `DataFrame`
directly. See the [Tutorial](@ref) for usage examples.