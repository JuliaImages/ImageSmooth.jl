# [Using ImageSmooth](@id usage)

## Installation

You can install `ImageSmooth.jl` via [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/).

```julia
(@v1.6) pkg> add ImageSmooth
```

## Using an image smoothing algorithm

Each smoothing algorithm in `ImageSmooth.jl` is an [AbstractImageSmoothAlgorithm](@ref ImageSmooth.SmoothAPI.AbstractImageSmoothAlgorithm).

Currently, there is one image smoothing algorithm can be used:

* [`L0 Smooth`](@ref l0_smooth)

```@docs
L0Smooth
```

You can define an iamge smoothing algorithm as follow.

```@repl
using ImageSmooth
fₛ = L0Smooth()
```

## Applying the algorithm to the image

`smooth` and `smooth!`

All of the algorithm is applied to the image via `smooth` or the in-place operation `smooth!`.

```@docs
smooth!
```

```@docs
smooth
```

## Demonstration

To use the smoothing operator, you have to first define a `smooth_algorithm::AbstractImageSmoothAlgorithm`, like `L0Smooth`. Then you can apply `smooth_algorithm` by using `smooth` or `smooth!`.

```@setup mosaicviews
using Images, TestImages, MosaicViews
```

```@example mosaicviews
using ImageSmooth

img = testimage("cameraman")

# Define the smoothing algorithm needed to use
fₛ = L0Smooth() # using default arguements

# Apply the algorithm to the image
imgₛ = smooth(img, fₛ)

# View the original image and the smoothed image
mosaicview(img, imgₛ; nrow=1)
```

You can also use the in-place operator `smooth!`:

```@example mosaicviews
using ImageSmooth

img = testimage("cameraman")

fₛ = L0Smooth()


input = reshape(channelview(img), 1, size(img)...)
imgₛ = similar(float64.(input))

smooth!(imgₛ, input, fₛ)


# View the original image and the smoothed image
mosaicview(img, imgₛ[1, :, :]; nrow=1)
```
