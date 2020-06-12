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
### Set up an Envionment Variable for the NASS API key

To start using the API, you first need to get a **personal API key**.

You can request a NASS API key at [https://quickstats.nass.usda.gov/api](https://quickstats.nass.usda.gov/api).

Once you receive your key, you can either set it up as an environment variable called USDA_QUICK_SURVEY_KEY" or set it up during a new julia session with

```@julia
using USDAQuickStats
set_api_key("YOUR_KEY"::String)
```

where you manually replace `YOUR_KEY` with your private API key.

If you are constantly  using the database, you might want to make your key into a permanent variable in your environment.

### Query the database

The API for the Quick Stats database provides three main functions:

- get_nass
- get_counts
- get_param_values

**get_nass**

The main function is `get_nass`, which queries the main USDA Quick Stats database.

The description of the different fields for the database is available [here].(https://quickstats.nass.usda.gov/api)

In this example I queried the survey data for oranges in California (CA) for the year 2019. I'm interested in the variables "ACRES BEARING" and "PRICE RECEIVED".

```@julia
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
```
output

```@julia
JSON3.Object{Array{UInt8,1},Array{UInt64,1}} with 1 entry:
  :data => JSON3.Object[{…
```

The function produces a JSON object by default which can be saved and parsed in different ways.

The `format` keyword can be added to the query after a semicolon `;` to request other formats outputs, CSV and XML are also available.

```@julia
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED"; format="CSV")
```

The purpose of the package is to query the database and the user will perform any further manipulation of the resulting object.

For example, to read the JSON object into a DataFrame, the user can use the following packages:
- [DataFrames](https://github.com/JuliaData/DataFrames.jl)
- [JSONTables](https://github.com/JuliaData/JSONTables.jl)
- [JSON3](https://github.com/quinnj/JSON3.jl)

And do something like this:

```@julia
using DataFrames, JSONTables, JSON3
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
DataFrames.DataFrame(JSONTables.jsontable(query)[:data]))
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

`get_param_values` is a helper query that allow user to check the values of a parameter in the query. This is useful when constructing different query strings.

```@julia
get_param_values("sector_desc")
```

output

```@julia
JSON3.Object{Array{UInt8,1},Array{UInt64,1}} with 1 entry:
  :sector_desc => ["ANIMALS & PRODUCTS", "CROPS", "DEMOGRAPHICS", "ECONOMICS", "ENVIRONMENTAL"]
```

**get_counts**

`get_counts` is a helper query that allows user to check the number of records a query will produce before performing the query. This is important because the USDA Quick Stats API has a limit of 50,000 records per query. Any query requesting a number of records larger than this limit will fail.

```@julia
get_counts("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
```

output

```@julia
JSON3.Object{Array{UInt8,1},Array{UInt64,1}} with 1 entry:
  :count => 276
```

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
