# Tutorial

This tutorial walks through a typical workflow using
`USDAQuickStats.jl` to query the USDA NASS Quick Stats database.

## Setup
```julia
using USDAQuickStats
set_api_key("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
```

## Step 1 — Explore available field values

Before building a query it is useful to check what values are
available for each field using `get_param_values`. This avoids
guessing field values and getting empty results.
```julia
# What sectors are available?
get_param_values("sector_desc")
# ["ANIMALS & PRODUCTS", "CROPS", "DEMOGRAPHICS", "ECONOMICS", "ENVIRONMENTAL"]

# What source types are available?
get_param_values("source_desc")
# ["CENSUS", "SURVEY"]

# Find commodity names (returns a long list)
get_param_values("commodity_desc")
```

## Step 2 — Check record count before querying

The API enforces a hard limit of **50,000 records per query**.
Requests exceeding this limit will fail. Always use `get_counts`
first to verify your query is within the limit.
```julia
# Check how many records our intended query would return
count = get_counts(
    "source_desc=SURVEY",
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019"
)
# 276 — well within the limit, safe to proceed
```

If a query is too broad:
```julia
get_counts("source_desc=SURVEY", "year=2019")
# 448878 — exceeds the limit, needs to be narrowed down
```

Narrow it down by adding more filters until the count is
below 50,000.

## Step 3 — Query the database

Use `get_nass` to fetch the data. Arguments are `"field=VALUE"`
strings. Spaces in values are handled automatically.
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

`get_nass` returns a `Vector{UInt8}` — raw bytes that you can
parse with any package you prefer.

## Step 4 — Parse the results

### JSON (default format)
```julia
using JSON3, JSONTables, DataFrames

df = DataFrame(jsontable(JSON3.read(data).data))
```

### CSV format
```julia
using CSV, DataFrames

data = get_nass(
    "source_desc=SURVEY",
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019";
    format="csv"
)
df = CSV.read(data, DataFrame)
```

### Save to disk
```julia
# Save as JSON
write("oranges_ca_2019.json", get_nass(
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019"
))

# Save as CSV
write("oranges_ca_2019.csv", get_nass(
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019";
    format="csv"
))
```

## Using the DataFrames extension

If you have `DataFrames`, `JSON3`, `JSONTables`, and `CSV` loaded,
`get_nass` returns a `DataFrame` directly:
```julia
using DataFrames, JSON3, JSONTables, CSV, USDAQuickStats

df = get_nass(
    "source_desc=SURVEY",
    "commodity_desc=ORANGES",
    "state_alpha=CA",
    "year=2019",
    "statisticcat_desc=AREA BEARING",
    "statisticcat_desc=PRICE RECEIVED"
)
# Returns a DataFrame directly — no manual parsing needed
```

## Common database fields

| Field | Description | Example values |
|---|---|---|
| `source_desc` | Data source | `SURVEY`, `CENSUS` |
| `sector_desc` | Sector | `CROPS`, `ANIMALS & PRODUCTS` |
| `commodity_desc` | Commodity | `ORANGES`, `CORN`, `CATTLE` |
| `statisticcat_desc` | Statistic category | `AREA BEARING`, `PRICE RECEIVED` |
| `state_alpha` | State abbreviation | `CA`, `TX`, `FL` |
| `year` | Survey year | `2019`, `2020` |
| `freq_desc` | Frequency | `ANNUAL`, `MONTHLY` |
| `agg_level_desc` | Aggregation level | `STATE`, `COUNTY`, `NATIONAL` |

For a full list of fields and valid values, use `get_param_values`
or visit the [API documentation](https://quickstats.nass.usda.gov/api).