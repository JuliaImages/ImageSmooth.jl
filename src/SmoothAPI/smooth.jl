"""
    AbstractImageSmoothAlgorithm <: AbstractImageFilter

The root type for `ImageSmooth` package.

Any image smoothing algorithm shall subtype it to support
[`smooth`](@ref) and [`smooth!`](@ref) APIs.

# Examples

All algorithm in `ImageSmooth` are called in the following pattern, 
take `L0Smooth <: AbstractImageSmoothAlgorithm` as an example:

```julia
# First generate an algorithm instance
fₛ = L0Smooth()

# Then pass the algorithm to `smooth`
imgₛ = smooth(img, fₛ)

# Or use in-place version `smooth!`

## Ror Gray images
input = reshape(channelview(img), 1, size(img)...)
imgₛ = similar(float64.(input))

smooth!(imgₛ, input, fₛ)

## For RGB images
input = channelview(img)
imgₛ = similar(float64.(input))

smooth!(imgₛ, img, fₛ)
```

Some algorithms also receive parameters to control the smoothing process and 
to get an expected smooth degree.

```julia
# You could explicit specify it
f = L0Smooth(λ=0.04, κ=1.5, βmax=1e6)

# Or infer the default value
f = L0Smooth()
```

For more examples, please check [`smooth`](@ref) and [`smooth!`](@ref) and concret
algorithms.
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
    out = similar(input, Float64)
    smooth!(out, input, f, args...; kwargs...)
    return colorview(Gray, out[1, :, :])
end

function smooth(img::GenericImage{<:Color3},
                f::AbstractImageSmoothAlgorithm,
                args...; kwargs...)
    input = channelview(img)
    out = similar(input, Float64)
    smooth!(out, input, f, args...; kwargs...)
    return colorview(RGB, out)
end

### Docstrings

"""
    smooth!(out::AbstractArray{<: Number}, img::AbstractArray{<: Number}, fₛ::AbstractImageSmoothAlgorithm, args...; kwargs...)

Smooth `img::AbstractArray{<: Number}` using algorithm `fₛ`

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
    smooth(img, fₛ::AbstractImageSmoothAlgorithm, args...; kwargs...)

Smooth `img` using algorithm `fₛ`

# Output

The return image `imgₛ` is an `Array{Gray{Float64}} for `Gray` image, and `Array{RGB{Float64}}` for `RGB` image.

# Examples

Just simply pass the input image and algorithm to `smooth`

```julia
fₛ = L0Smooth()

imgₛ = smooth(img, fₛ)
```

This reads as "`smooth` image `img` using smoothing algorithm `fₛ`".

See also [`smooth!`](@ref) for in-place smoothing.
"""
smooth