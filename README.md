# USDAQuickStats.jl


`USDAQuickStats.jl` offers the possibility to access the USDA National Agricultural Statistics Service (NASS) [Quick Stats database](https://quickstats.nass.usda.gov/api) in Julia.

## Installation

```@julia
add USDAQuickStats
```
## Index

The package contains following functions:

- `set_api_key`
- `get_counts`
- `get_param_values`
- `get_nass`

## Tutorial and Workflow
### Set up an Environment Variable for the NASS API key

To start using the API, the user first needs to get a **personal API key**.

The user can request a NASS API key at [https://quickstats.nass.usda.gov/api](https://quickstats.nass.usda.gov/api).

The API key can be saved as an environment variable called "USDA_QUICK_SURVEY_KEY" or used during each new Julia session by setting it up using:

```@julia
using USDAQuickStats
set_api_key("YOUR_KEY"::String)
```

replacing `"YOUR_KEY"` with the private API key as a string.

Saving the key into a permanent variable in your environment is dependent on the operating system.

### Query the database

The API for the Quick Stats database provides three main functions:

- get_nass
- get_counts
- get_param_values

**get_nass**

`get_nass(args...; format="json")
`
The main function is `get_nass`, which queries the main USDA Quick Stats database.

`args...` is a list of the different headers from the database that can be queried. Each argument is a string with the name of the header and the value from that header in uppercase, e.g. `"header=VALUE`. The description of the different headers (also called columns) for the database is available [here].(https://quickstats.nass.usda.gov/api)

The `format` keyword can be added to the query after a semicolon `;` and defines the format of the response. It is set to `JSON` as a default, other formats provided by the database are `CSV` and `XML`.

The function returns a DataFrame with the requested query for the `JSON` and `CSV` formats, no DataFrame has been implemented for the `XML` format yet, PR's welcome.

In the following example, the survey data for oranges in California (CA) for the year 2019 was queried for information about the headers "ACRES BEARING" and "PRICE RECEIVED".

Notice that header values that have spaces in them need to be passed with the symbol `%20` replacing the space. In general, no spaces are allowed in the query.

```@julia
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
```
output

```@julia
276×39 DataFrame. Omitted printing of 30 columns
│ Row │ prodn_practice_desc      │ state_name │ country_name  │ asd_desc │ watershed_code │ state_fips_code │ source_desc │ location_desc │ statisticcat_desc │
│     │ String                   │ String     │ String        │ String   │ String         │ String          │ String      │ String        │ String            │
├─────┼──────────────────────────┼────────────┼───────────────┼──────────┼────────────────┼─────────────────┼─────────────┼───────────────┼───────────────────┤
│ 1   │ ALL PRODUCTION PRACTICES │ CALIFORNIA │ UNITED STATES │          │ 00000000       │ 06              │ SURVEY      │ CALIFORNIA    │ AREA BEARING      │
│ 2   │ ALL PRODUCTION PRACTICES │ CALIFORNIA │ UNITED STATES │          │ 00000000       │ 06              │ SURVEY      │ CALIFORNIA    │ PRICE RECEIVED    │
⋮
│ 274 │ ALL PRODUCTION PRACTICES │ CALIFORNIA │ UNITED STATES │          │ 00000000       │ 06              │ SURVEY      │ CALIFORNIA    │ PRICE RECEIVED    │
│ 275 │ ALL PRODUCTION PRACTICES │ CALIFORNIA │ UNITED STATES │          │ 00000000       │ 06              │ SURVEY      │ CALIFORNIA    │ PRICE RECEIVED    │
│ 276 │ ALL PRODUCTION PRACTICES │ CALIFORNIA │ UNITED STATES │          │ 00000000       │ 06              │ SURVEY      │ CALIFORNIA    │ PRICE RECEIVED    │
```

**get_param_values**

`get_param_values(arg)` is a helper query that allow user to check the values of a field `arg` from the database. This is useful when constructing different query strings, as it allows the user to determine which values are available on each field.

```@julia
db_values = get_param_values("sector_desc")
```

output

```@julia
JSON3.Object{Array{UInt8,1},Array{UInt64,1}} with 1 entry:
  :sector_desc => ["ANIMALS & PRODUCTS", "CROPS", "DEMOGRAPHICS", "ECONOMICS", "ENVIRONMENTAL"]
```

If the user need to access the values, they are available as an array `db_values[:sector_desc]`.

**get_counts**

`get_counts(args...)` is a helper query that allows user to check the number of records a query using the fields in `args...` will produce before performing the query. This is important because the USDA Quick Stats API has a limit of 50,000 records per query. Any query requesting a number of records larger than this limit will fail.

As in `get_nass`, `args...` is a list of the different headers from the database that can be queried. Each argument is a string with the name of the header and the value from that header in uppercase, e.g. `"header=VALUE`. The description of the different headers (also called columns) for the database is available [here].(https://quickstats.nass.usda.gov/api)

In the following example, the number of records for survey data for oranges in California (CA) for the year 2019 with information about the headers "ACRES BEARING" and "PRICE RECEIVED" was queried. 

Notice that header values that have spaces in them need to be passed with the symbol `%20` replacing the space. In general, no spaces are allowed in the query.

```@julia
count = get_counts("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
```

output

```@julia
JSON3.Object{Array{UInt8,1},Array{UInt64,1}} with 1 entry:
  :count => 276
```

Same as before, the value can be accessed as an array `count[:count]`.

A very large query would be for example:

```@julia
get_counts("source_desc=SURVEY", "year=2019")
```

output

```@julia
JSON3.Object{Array{UInt8,1},Array{UInt64,1}} with 1 entry:
  :count => 381929
```

I would like to thank @markushhh, because I heavily used his [FredApi.jl](https://github.com/markushhh/FredApi.jl) for inspiration. And sometimes blatant plagiarism.

## Each comment, suggestion or pull request is welcome!
