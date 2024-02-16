
# workaround is to load ImageMagick.jl first, front and center
# see https://github.com/JuliaIO/ImageMagick.jl/issues/142
# and https://github.com/JuliaIO/ImageMagick.jl/issues/130
# using ImageMagick

using Pkg

using Arena
using Test
using Aqua

@testset "Arena.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Arena; ambiguities=false)
        Aqua.test_ambiguities([Arena])
    end
    
    # include("testBasicAnimations.jl")

end
