```@meta
CurrentModule = USDAQuickStats
```

# USDAQuickStats.jl

`USDAQuickStats.jl` provides a simple Julia interface to the
[USDA National Agricultural Statistics Service (NASS) Quick Stats API](https://quickstats.nass.usda.gov/api).

## What is Quick Stats?

The USDA NASS Quick Stats database is the primary source of official
US agricultural statistics. It covers crops, livestock, economics,
and demographics across all US states and counties, going back
several decades. The database contains hundreds of millions of
records across thousands of commodities.

## What does this package do?

`USDAQuickStats.jl` handles the communication with the Quick Stats
API for you — authentication, URL encoding, request building, and
error handling — so you can focus on the data rather than the
plumbing.

The package is intentionally lightweight, with a single dependency
(`HTTP.jl`). It returns raw response bytes by default, letting you
choose your own tools for parsing and analysis. If you have
`DataFrames.jl` loaded, results are returned as a `DataFrame`
automatically via a package extension.

## Package index

- [Getting Started](@ref) — installation, API key setup
- [Tutorial](@ref) — worked examples with real queries
- [API Reference](@ref) — full function documentation