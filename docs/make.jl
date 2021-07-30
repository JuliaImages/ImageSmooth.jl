push!(LOAD_PATH,"../src/")
using ImageSmooth, TestImages, MosaicViews
using Documenter

DocMeta.setdocmeta!(ImageSmooth, :DocTestSetup, :(using ImageSmooth); recursive=true)

makedocs(;
    modules=[ImageSmooth],
    authors="Johnny Chen <johnnychen94@hotmail.com>, JKay Chen <jkaychen0327@hotmail.com>",
    repo="https://github.com/johnnychen94/ImageSmooth.jl/blob/{commit}{path}#{line}",
    sitename="ImageSmooth.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://johnnychen94.github.io/ImageSmooth.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Using ImageSmooth" => "usage.md",
        "Algorithms" => "algorithms.md",
        "Package References" => "reference.md",
    ],
)

deploydocs(;
    repo="github.com/johnnychen94/ImageSmooth.jl",
)
