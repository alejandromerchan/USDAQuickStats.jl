# USDAQuickStats.jl

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://alejandromerchan.github.io/USDAQuickStats.jl/stable)
[![Development Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://alejandromerchan.github.io/USDAQuickStats.jl/dev)
[![Test workflow status](https://github.com/alejandromerchan/USDAQuickStats.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/alejandromerchan/USDAQuickStats.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/alejandromerchan/USDAQuickStats.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/alejandromerchan/USDAQuickStats.jl)
[![Docs workflow status](https://github.com/alejandromerchan/USDAQuickStats.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/alejandromerchan/USDAQuickStats.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![Julia](https://img.shields.io/badge/Julia-1.10+-blue.svg)](https://julialang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)

`USDAQuickStats.jl` provides functions to access data from the USDA National Agricultural
Statistics Service (NASS) [Quick Stats database](https://quickstats.nass.usda.gov/api) API
in Julia.

## Features

- Simple, lightweight interface to the USDA NASS Quick Stats API
- Automatic URL encoding — write `"AREA BEARING"` instead of `"AREA%20BEARING"`
- Informative error messages for common failure modes
- Returns raw bytes by default, keeping the package dependency-free
- Optional automatic `DataFrame` conversion when `DataFrames.jl` is loaded (via package extension)

## Installation

From the Julia REPL:

```julia
] add USDAQuickStats
```

## API Key

To use the Quick Stats API you need a personal API key. Request one at
[https://quickstats.nass.usda.gov/api](https://quickstats.nass.usda.gov/api).

Set your key at the start of each Julia session:

```julia
using USDAQuickStats
set_api_key("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
```

To update an existing key:

```julia
set_api_key("yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"; overwrite=true)
```

To check which key is currently set:

```julia
get_api_key()
```

For a permanent setup, save the key as an environment variable called
`USDA_QUICK_SURVEY_KEY` in your operating system. Julia will pick it up
automatically on startup.

## Functions

The package provides six exported functions:

- `set_api_key` — set your USDA NASS API key for the current session
- `get_api_key` — return the currently set API key
- `get_nass` — query the main USDA NASS Quick Stats database
- `get_nass_df` - query the main USDA NASS Quick Stats database and return a DataFrame directly (requires DataFrames extension).
- `get_counts` — check the number of records a query would return
- `get_param_values` — list all valid values for a given database field

## Usage

### Check available field values

Before building a query it is useful to explore what values are available
for each field using `get_param_values`:

```julia
using USDAQuickStats

get_param_values("sector_desc")
# ["ANIMALS & PRODUCTS", "CROPS", "DEMOGRAPHICS", "ECONOMICS", "ENVIRONMENTAL"]

get_param_values("commodity_desc")
# Returns all available commodity names
```

### Check record count before querying

The API has a hard limit of **50,000 records per query**. Use `get_counts`
before `get_nass` to verify your query is within the limit:

```julia
count = get_counts(
    "source_desc=SURVEY",
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019"
)
# 957
```

A query that is too broad will return a count exceeding the limit:

```julia
get_counts("source_desc=SURVEY", "year=2019")
# 448858 — this query would fail with get_nass
```

### Query the database

`get_nass` returns the raw response body as `Vector{UInt8}`. Pass
`"field=VALUE"` strings as arguments. Spaces in values are handled
automatically — no need for `%20`.

```julia
data = get_nass(
    "source_desc=SURVEY",
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019",
    "statisticcat_desc=AREA BEARING",
    "statisticcat_desc=PRICE RECEIVED"
)
```

The `format` keyword controls the response format (`"json"` by default):

```julia
# JSON (default)
data = get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019")

# CSV
data = get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019"; format="csv")

# XML
data = get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019"; format="xml")
```

### Parsing the response

The package returns raw bytes and lets you choose how to parse them:

**JSON with DataFrames:**

```julia
using JSON3, JSONTables, DataFrames

data = get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019")
df = DataFrame(jsontable(JSON3.read(data).data))
```

**CSV with DataFrames:**

```julia
using CSV, DataFrames

data = get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019"; format="csv")
df = CSV.read(data, DataFrame)
```

**Save directly to disk:**

```julia
write("output.json", get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019"))
write("output.csv",  get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019"; format="csv"))
```

### Automatic DataFrame conversion (extension)

If you have `DataFrames`, `JSON3`, `JSONTables`, and `CSV` loaded,
a dedicated `get_nass_df` function becomes available that returns a
`DataFrame` directly:

```julia
using DataFrames, JSON3, JSONTables, CSV, USDAQuickStats

df = get_nass_df(
    "source_desc=SURVEY",
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019"
)
# Returns a DataFrame directly
```

Users who do not have these packages installed can still use `get_nass`
as normal, which returns raw `Vector{UInt8}` bytes.

## Database Fields

The Quick Stats database has many queryable fields. Some commonly used ones:

| Field | Description | Example value |
|---|---|---|
| `source_desc` | Data source | `SURVEY`, `CENSUS` |
| `sector_desc` | Sector | `CROPS`, `ANIMALS & PRODUCTS` |
| `commodity_desc` | Commodity | `ORANGES`, `CORN`, `CATTLE` |
| `statisticcat_desc` | Statistic category | `AREA BEARING`, `PRICE RECEIVED` |
| `state_alpha` | State abbreviation | `CA`, `TX`, `FL` |
| `year` | Survey year | `2019`, `2020` |
| `freq_desc` | Frequency | `ANNUAL`, `MONTHLY` |
| `agg_level_desc` | Aggregation level | `STATE`, `COUNTY`, `NATIONAL` |

For a full list of fields and their valid values use `get_param_values` or
visit the [API documentation](https://quickstats.nass.usda.gov/api).

## Contributing

Contributions, bug reports, and pull requests are welcome! Please open an
issue first to discuss any significant changes.

## Acknowledgements

Inspired by [FredApi.jl](https://github.com/markushhh/FredApi.jl) by
@markushhh.

## License

MIT License. See [LICENSE](LICENSE) for details.
