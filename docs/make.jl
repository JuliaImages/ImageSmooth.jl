push!(LOAD_PATH,"../src/")
using ImageSmooth, TestImages, MosaicViews
using Documenter

DocMeta.setdocmeta!(ImageSmooth, :DocTestSetup, :(using ImageSmooth); recursive=true)

makedocs(;
    modules=[ImageSmooth],
    repo="https://github.com/JuliaImages/ImageSmooth.jl/blob/{commit}{path}#{line}",
    sitename="ImageSmooth.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaImages.org/ImageSmooth.jl",
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
    repo="github.com/JuliaImages/ImageSmooth.jl",
)
