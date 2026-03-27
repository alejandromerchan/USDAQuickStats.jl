# Getting Started

## Installation

From the Julia REPL:
```julia
] add USDAQuickStats
```

## Getting an API Key

To use the Quick Stats API you need a free personal API key.
Request one at [https://quickstats.nass.usda.gov/api](https://quickstats.nass.usda.gov/api).
You will receive the key by email within a few minutes.

## Setting your API Key

Set your key at the start of each Julia session:
```julia
using USDAQuickStats
set_api_key("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
```

To update an existing key without restarting Julia:
```julia
set_api_key("yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"; overwrite=true)
```

To check which key is currently active:
```julia
get_api_key()
```

### Permanent setup

To avoid calling `set_api_key` every session, save your key as a
permanent environment variable called `USDA_QUICK_SURVEY_KEY`.
Julia will pick it up automatically on startup.

**Linux / macOS** — add to your `~/.bashrc` or `~/.zshrc`:
```bash
export USDA_QUICK_SURVEY_KEY="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

**Windows** — from PowerShell:
```powershell
[System.Environment]::SetEnvironmentVariable("USDA_QUICK_SURVEY_KEY","xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx","User")
```

## Optional: DataFrame support

If you have `DataFrames.jl`, `JSON3.jl`, `JSONTables.jl`, and
`CSV.jl` installed, loading them alongside `USDAQuickStats.jl`
will automatically activate a package extension that returns query
results as a `DataFrame` instead of raw bytes — no extra steps
required.
```julia
using DataFrames, JSON3, JSONTables, CSV
using USDAQuickStats

df = get_nass("commodity_desc=ORANGES", "state_alpha=CA", "year=2019")
# Returns a DataFrame directly
```

Users who do not have these packages installed are unaffected —
the package behaves identically to the base version.