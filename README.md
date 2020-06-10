# USDAQuickStats.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://alejandromerchan.github.io/USDAQuickStats.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://alejandromerchan.github.io/USDAQuickStats.jl/dev)
[![Build Status](https://travis-ci.com/alejandromerchan/USDAQuickStats.jl.svg?branch=master)](https://travis-ci.com/alejandromerchan/USDAQuickStats.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/alejandromerchan/USDAQuickStats.jl?svg=true)](https://ci.appveyor.com/project/alejandromerchan/USDAQuickStats-jl)
[![Codecov](https://codecov.io/gh/alejandromerchan/USDAQuickStats.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/alejandromerchan/USDAQuickStats.jl)
[![Coveralls](https://coveralls.io/repos/github/alejandromerchan/USDAQuickStats.jl/badge.svg?branch=master)](https://coveralls.io/github/alejandromerchan/USDAQuickStats.jl?branch=master)


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

##get_nass##

The main function is `get_nass`, which queries the main USDA Quick Stats database.

The description of the different fields for the database is available [here].(https://quickstats.nass.usda.gov/api)

In this example I queried the survey data for oranges in California (CA) for the year 2019. I'm interested in the variables "ACRES BEARING" and "PRICE RECEIVED".

```@julia
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
```
output

```@julia
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Date: Wed, 10 Jun 2020 03:53:59 GMT
Server: Apache/2.4.23 (Linux/SUSE)
X-Frame-Options: SAMEORIGIN
Content-Length: 274536
Cache-Control: max-age=86400, private
Connection: close
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

{"data":[{"county_code":"","watershed_code":"00000000","class_desc":"ALL CLASSES","group_desc":"FRUIT & TREE NUTS","commodity_desc":"ORANGES","sector_desc":"CROPS","domaincat_desc":"NOT SPECIFIED","unit_desc":"ACRES","Value":"147,000","state_name":"CALIFORNIA","state_ansi":"06","week_ending":"","asd_code":"","domain_desc":"TOTAL","year":2019,"load_time":"2019-08-28 15:09:57","county_ansi":"","state_alpha":"CA","short_desc":"ORANGES - ACRES BEARING","county_name":"","zip_5":"","begin_code":"00","freq_desc":"ANNUAL","CV (%)":"","country_code":"9000","agg_level_desc":"STATE","watershed_desc":"","asd_desc":"","region_desc":"","source_desc":"SURVEY","util_practice_desc":"ALL UTILIZATION PRACTICES","location_desc":"CALIFORNIA","state_fips_code":"06","statisticcat_desc":"AREA BEARING","end_code":"00","congr_district_code":"","prodn_practice_desc":"ALL PRODUCTION PRACTICES","country_name":"UNITED STATES","reference_period_desc":"YEAR"},{"domain_desc":"TOTAL","state_name":"CALIFORNIA","state_an
⋮
274536-byte body
"""
```

The function produces a JSON object by default which can be saved and parsed in different ways.

The `format` keyword can be added to the query after a semicolon `;` to request other formats outputs, CSV and XML are also available.

```@julia
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED"; format="CSV")
```

The purpose of the package is to query the database and the user will perform any further manipulation of the resulting object.

For example, to read the JSON object into a DataFrame, the user can use the following packages:
- [DataFrames](https://github.com/JuliaData/DataFrames.jl)
- [JSONTables] (https://github.com/JuliaData/JSONTables.jl)
- [JSON3] (https://github.com/quinnj/JSON3.jl)

And do something like this:

```@julia
using DataFrames, JSONTables, JSON3
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
DataFrames.DataFrame(JSONTables.jsontable(JSON3.read(query.body)[:data]))
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

##get_param_values##

`get_param_values` is a helper query that allow user to check the values of a parameter in the query. This is useful when constructing different query strings.

```@julia
get_param_values("sector_desc")
```

output

```@julia
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Date: Wed, 10 Jun 2020 04:24:33 GMT
Server: Apache/2.4.23 (Linux/SUSE)
X-Frame-Options: SAMEORIGIN
Content-Length: 89
Cache-Control: max-age=86400, private
Connection: close
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

{"sector_desc":["ANIMALS & PRODUCTS","CROPS","DEMOGRAPHICS","ECONOMICS","ENVIRONMENTAL"]}"""
```

##get_counts##

`get_counts` is a helper query that allows user to check the number of records a query will produce before performing the query. This is important because the USDA Quick Stats API has a limit of 50,000 records per query and any query that is larger than this will fail.

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

# Each comment, suggestion or pull request is welcome!
