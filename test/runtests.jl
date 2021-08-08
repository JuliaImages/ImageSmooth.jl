using ImageSmooth
using Test, ReferenceTests, TestImages
using FileIO
using ImageTransformations, ImageQualityIndexes
using ImageBase

include("testutils.jl")

@testset "ImageSmooth.jl" begin
    include("algorithms/l0_smooth.jl")
end
