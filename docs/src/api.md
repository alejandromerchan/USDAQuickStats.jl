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

The following function is only available when `DataFrames`, `JSON3`,
`JSONTables`, and `CSV` are loaded:
```@docs
get_nass_df
```