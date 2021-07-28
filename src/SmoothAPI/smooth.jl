"""
    AbstractImageSmoothAlgorithm <: AbstractImageFilter

The root type for `ImageSmooth` package.

Any image smoothing algorithm shall subtype it to support
[`smooth`](@ref) and [`smooth!`](@ref) APIs.

# Examples

All algorithm in ImageSmooth are called in the following pattern:

```julia
# first generate an algorithm instance
fₛ = L0Smooth()

# then pass the algorithm to `smooth`
imgₛ = smooth(img, fₛ)

# or use in-place version `smooth!`

## for Gray images
input = reshape(channelview(img), 1, size(img)...)
imgₛ = similar(float64.(input))

smooth!(imgₛ, input, fₛ)

## for RGB images
input = channelview(img)
imgₛ = similar(float64.(input))

smooth!(imgₛ, img, fₛ)
```

Some algorithms also receive parameters to control the smoothing process and 
to get an expected smooth degree.

```julia
# you could explicit specify it
f = L0Smooth(λ=0.04, κ=1.5, βmax=1e6)

# or infer the default value
f = L0Smooth()
```

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
    out = similar(float64.(input))
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

### Docstrings

"""
    smooth!(out, img, f::AbstractImageSmoothAlgorithm, args...; kwargs...)

Smooth `img` using algorithm `fₛ`

# Output

`out` will be changed in place.

# Examples

Just simply pass an algorithm to `smooth!`:

```julia
# First generate an algorithm instance
fₛ = L0Smooth()

## For Gray images
input = reshape(channelview(img), 1, size(img)...)
imgₛ = similar(float64.(input))

smooth!(imgₛ, input, fₛ)

## For RGB images
input = channelview(img)
imgₛ = similar(float64.(input))

smooth!(imgₛ, img, fₛ)
```

See also: [`smooth`](@ref)
"""
smooth!

"""
    smooth(img, f, args...; kwargs...)

Smooth `img` using algorithm `fₛ`

# Output

The return image `imgₛ` is an `Array{Gray{Float64}}} for a Gray input, and `Array{RGB{Float64}}}` for a RGB input.

# Examples

Just simply pass the input image and algorithm to `smooth`

```julia
fₛ = L0Smooth()

imgₛ = smooth(img, fₛ)
```

This reads as "`smooth` image `img` using binarization algorithm `fₛ`".`

See also [`smooth!`](@ref) for in-place smoothing.
"""
smooth