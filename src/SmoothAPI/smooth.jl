"""
    AbstractImageSmoothAlgorithm <: AbstractImageFilter

The root type for 'ImageSmooth' package.

Any image smoothing algorithm shall subtype it to support
['smooth'](@ref) and ['smooth!'](@ref) APIs.

# Examples

All algorithm in ImageSmooth are called in the following pattern:

```julia
# first generate an algorithm instance
fₛ = L0Smooth()

# then pass the algorithm to 'smooth'
imgₛ = smooth(img, fₛ)

# or use in-place version 'smooth!'
imgₛ = similar(img)
smooth!(imgₛ, img, fₛ)
```

Some algorithms also receive parameters to control the smoothing process and 
to get an expected smooth degree.

'''julia
# you could explicit specify it
f = L0Smooth(λ=0.04, κ=1.5)

# or infer the default value
f = L0Smooth()
'''

"""

abstract type AbstractImageSmoothAlgorithm <: AbstractImageFilter end

smooth!(out::AbstractArray{<: Number},
        img::AbstractArray{<: Number},
        f::AbstractImageSmoothAlgorithm,
        args...; kwargs...) =
    f(out, img, args...; kwargs...)

function smooth(img::GenericGrayImage,
                f::AbstractImageSmoothAlgorithm,
                args...; kwargs...)
    input = reshape(channelview(img), 1, size(img)...)
    out = similar(float64.(channelview(input)))
    smooth!(out, input, f, args...; kwargs...)
    return colorview(Gray, out[1, :, :])
end

function smooth(img::GenericImage{<:Color3},
                f::AbstractImageSmoothAlgorithm,
                args...; kwargs...)
    input = channelview(img)
    out = similar(float64.(input))
    smooth!(out, input, f, args...; kwargs...)
    return colorview(RGB, out)
end