using Documenter, Arena

makedocs(
    modules = [Arena],
    format = :html,
    sitename = "Arena.jl",
    pages = Any[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Functions" => "func_ref.md"
    ]
    # html_prettyurls = !("local" in ARGS),
    )


deploydocs(
    repo   = "github.com/dehann/Arena.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing,
    julia  = "0.6",
    osname = "linux"
)
