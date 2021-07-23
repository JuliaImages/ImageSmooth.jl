module ImageSmooth

using ImageFiltering, FFTW, MappedArrays
using ImageCore
using ImageCore: GenericGrayImage

#TODO: port SmoothAPI to ImagesAPI
include("SmoothAPI/SmoothAPI.jl")
import .SmoothAPI: AbstractImageSmoothAlgorithm,
                   smooth, smooth!

include("utils.jl")

# Smooth algorithms

include("algorithms/l0_smooth.jl") # L0Smooth

export
    # generic API
    smooth, smooth!,

    # Algorithms
    L0Smooth

end # module ImageSmooth