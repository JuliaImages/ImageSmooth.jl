using ImageSmooth
using Test, ReferenceTests, TestImages, ImageTransformations, ImageQualityIndexes
using ImageCore

include("testutils.jl")

@testset "ImageSmooth.jl" begin
    include("algorithms/l0_smooth.jl")
end