using Documenter, USDAQuickStats

makedocs(;
    modules=[USDAQuickStats],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/alejandromerchan/USDAQuickStats.jl/blob/{commit}{path}#L{line}",
    sitename="USDAQuickStats.jl",
    authors="H. Alejandro Merchan, California Department of Pesticide Regulation",
    assets=String[],
)

deploydocs(;
    repo="github.com/alejandromerchan/USDAQuickStats.jl",
)
