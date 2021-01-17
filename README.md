# USDAQuickStats.jl


`USDAQuickStats.jl` provides functions to access data from the USDA National Agricultural Statistics Service (NASS) [Quick Stats database](https://quickstats.nass.usda.gov/api) API in Julia.

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

The function returns a HTTP.request object and the user can parse it using different packages, some examples below.

In the following example, the survey data for oranges in California (CA) for the year 2019 was queried for information about the headers "ACRES BEARING" and "PRICE RECEIVED". The format keyword isn't specified, so the request will return a JSON file. 

Notice that header values that have spaces in them need to be passed with the symbol `%20` replacing the space. In general, no spaces are allowed in the query.

```@julia
query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED")
```
output

```@julia
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Date: Sat, 26 Dec 2020 19:36:55 GMT
Server: Apache/2.4.23 (Linux/SUSE)
X-Frame-Options: SAMEORIGIN
Content-Length: 274515
Cache-Control: max-age=86400, private
Connection: close
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

{"data":[{"begin_code":"00","prodn_practice_desc":"ALL PRODUCTION PRACTICES","watershed_desc":"","state_fips_code":"06","commodity_desc":"ORANGES","statisticcat_desc":"AREA BEARING","Value":"147,000","watershed_code":"00000000","source_desc":"SURVEY","util_practice_desc":"ALL UTILIZATION PRACTICES","domaincat_desc":"NOT SPECIFIED","domain_desc":"TOTAL","state_alpha":"CA","week_ending":"","group_desc":"FRUIT & TREE NUTS","reference_period_desc":"YEAR","CV (%)":"","year":2019,"short_desc":"ORANGES - ACRES BEARING","country_code":"9000","load_time":"2019-08-28 15:09:57","country_name":"UNITED STATES","unit_desc":"ACRES","county_code":"","end_code":"00","sector_desc":"CROPS","state_name":"CALIFORNIA","zip_5":"","class_desc":"ALL CLASSES","county_ansi":"","asd_code":"","location_desc":"CALIFORNIA","congr_district_code":"","county_name":"","state_ansi":"06","region_desc":"","asd_desc":"","freq_desc":"ANNUAL","agg_level_desc":"STATE"},{"reference_period_desc":"MARKETING YEAR","CV (%)":"","yea
⋮
274515-byte body
"""
```

This query object can be post-processed in different ways, depending on the format. JSON is the default format and the object can be displayed using the packages JSON3.jl, JSONTables.jl and DataFrames.jl.

```@julia
using JSON3
using JSONTables
using DataFrames

jobject = JSON3.read(query.body)
jtable = jsontable(jobject.data)
df = DataFrame(jtable)
```

The query can also be returned and processed as a CSV file.

```@julia
using CSV
using DataFrames

query = get_nass("source_desc=SURVEY","commodity_desc=ORANGES","state_alpha=CA", "year=2019","statisticcat_desc=AREA%20BEARING","statisticcat_desc=PRICE%20RECEIVED"; format="csv")

# Display as DataFrame
CSV.File(query.body, DataFrame)

# Or save it to disk
CSV.write("query.csv", CSV.File(query.body))
```

The query can also return an XML file.

**get_param_values**

`get_param_values(arg)` is a helper query that allow user to check the values of a field `arg` from the database. This is useful when constructing different query strings, as it allows the user to determine which values are available on each field.

```@julia
db_values = get_param_values("sector_desc")
```

output

```@julia
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Date: Sat, 26 Dec 2020 20:40:29 GMT
Server: Apache/2.4.23 (Linux/SUSE)
X-Frame-Options: SAMEORIGIN
Content-Length: 89
Cache-Control: max-age=86400, private
Connection: close
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

{"sector_desc":["ANIMALS & PRODUCTS","CROPS","DEMOGRAPHICS","ECONOMICS","ENVIRONMENTAL"]}"""
```
The query object can be post processed using the JSON3 package to obtain a more readable output if needed.
```@julia
using JSON3

JSON3.read(db_values.body)
```

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
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Date: Sat, 26 Dec 2020 20:47:55 GMT
Server: Apache/2.4.23 (Linux/SUSE)
X-Frame-Options: SAMEORIGIN
Content-Length: 13
Cache-Control: max-age=86400, private
Connection: close
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

{"count":276}"""
```

Same as before, the object can be processed with the JSON3 package to get a more readable output.

A very large query would be for example:

```@julia
get_counts("source_desc=SURVEY", "year=2019")
```

output

```@julia
HTTP.Messages.Response:
"""
HTTP/1.1 200 OK
Date: Sat, 26 Dec 2020 20:49:14 GMT
Server: Apache/2.4.23 (Linux/SUSE)
X-Frame-Options: SAMEORIGIN
Content-Length: 16
Cache-Control: max-age=86400, private
Connection: close
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

{"count":448878}"""
```
This query would fail if ran directly using the `get_nass` function, because it exceeds the limit of 50000 rows.

I would like to thank @markushhh, because I heavily used his [FredApi.jl](https://github.com/markushhh/FredApi.jl) for inspiration. And sometimes blatant plagiarism.

## Each comment, suggestion or pull request is welcome!
