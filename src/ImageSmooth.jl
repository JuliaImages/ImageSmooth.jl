module ImageSmooth

using ImageFiltering, FFTW
using ImageCore
using ImageCore: GenericGrayImage, GenericImage
using ImageBase

#TODO: port SmoothAPI to ImagesAPI
include("SmoothAPI/SmoothAPI.jl")
import .SmoothAPI: AbstractImageSmoothAlgorithm,
                   smooth, smooth!

include("utils.jl")
include("compat.jl")

# Smooth algorithms

include("algorithms/l0_smooth.jl") # L0Smooth

export
    # generic API
    smooth, smooth!,

    # Algorithms
    L0Smooth

end # module ImageSmooth