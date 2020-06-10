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

To start using the API, you first need to get a *personal API key*.

You can request a NASS API key at [https://quickstats.nass.usda.gov/api](https://quickstats.nass.usda.gov/api).

Once you receive your key, you can either set it up as an environment variable called USDA_QUICK_SURVEY_KEY" or set it up during a new julia session with

```@julia
set_api_key("YOUR_KEY"::String)
```

where you manually replace `YOUR_KEY` with your private API key.

If you are using the database constantly, you might want to make your key into a permanent variable in your environment.

### Query the database

The API for the Quick Stats database provides three main functions:

The main function is `get_nass`, which queries the main database. 

# Each comment, suggestion or pull request is welcome!
