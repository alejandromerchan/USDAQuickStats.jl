using Documenter
using USDAQuickStats

makedocs(
    sitename = "USDAQuickStats.jl",
    authors = "H. Alejandro Merchan",
    repo = "https://github.com/alejandromerchan/USDAQuickStats.jl/blob/{commit}{path}#{line}",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://alejandromerchan.github.io/USDAQuickStats.jl",
    ),
    modules = [USDAQuickStats],
    pages = [
        "Home" => "index.md",
        "Getting Started" => "gettingstarted.md",
        "Tutorial" => "tutorial.md",
        "API Reference" => "api.md",
    ],
    checkdocs = :none,
)

deploydocs(
    repo = "github.com/alejandromerchan/USDAQuickStats.jl",
    devbranch = "main",
    push_preview = false,
)