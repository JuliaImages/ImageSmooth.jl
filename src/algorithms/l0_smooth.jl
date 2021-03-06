@doc raw"""
    L0Smooth <: AbstractImageSmoothAlgorithm
    L0Smooth(; Î»=2e-2, Îº=2.0, Î²max=1e5)

    smooth(img, f::L0Smooth)
    smooth!(out, img, f::L0Smooth)

Smoothing `img` via L0 gradient minimization to approximate prominent structure
in a sparsity-control manner.

# Output

Return `Array{Gray{N0f8}}` for `Gray` input or `Array{RGB{N0f8}}` for `RGB` input.

# Details

Using the strategy of minimizing the L0 norm of image's gradient.

This algorithm works particularly effective for sharpening major edges by 
increasing the steepness of amplitude transition while eliminating 
low-amplitude structures to some extent. See [1] for more details. 

# Options

The function argument is described in detail below.

## `Î»::Float64`

The argument `ð` is a weight directly controlling the significance of 
the L0 gradient norm term, which must be greater than zero.

A larger `ð` makes the smoothed image have very few edges.

Default: 2e-2

## `Î²max::Float64`

The argument `Î²max` is the upper bound of `ð½` in [1], which must be greater than 1e4.

In this algorithm, two auxiliary variables `â` and `ð£` are used to approximate 
the solution. A large enough `ð½` ensures that the alternating optimization strategy 
based on introducing auxiliary variables is available.

Default: 1e5

## `Îº::Float64`

The argument `ð` is the iteraiton rate, which must be larger than 1.0.

This algorithm using an alternating optimization strategy to get the solution.
In each iteration, the argument `ð½` controls the similarity between gradient pair 
(ð¥âðâ, ð¥âðâ) (denoted by `` (\partial_x S_p, \partial_y S_p) `` in [1]) and auxiliary pair (ââ, ð£â).
The argument `ð` is used to update `ð½` as `ð½ âµ ðð½`.

Default: 2.0

# Examples

You can use the default arguments for `L0Smooth`, and then use `smooth` to apply 
the `AbstractImageSmoothAlgorithm`.

```julia
using TestImages
using ImageSmooth

img = testimage("cameraman")

fâ = L0Smooth() # using default arguements
imgâ = smooth(img, fâ)
```

Manually setting the arguements is also available:

```julia
fâ = L0Smooth(Î»=0.0015, Îº=1.05, Î²max=2e5) # manually set the arguments
imgâ = smooth(img, fâ)
```

See also [`smooth!`](@ref) for in-place operation.

# References

[1] Xu, L., Lu, C., Xu, Y., & Jia, J. (2011, December). Image smoothing via L 0 gradient minimization. In Proceedings of the 2011 SIGGRAPH Asia conference (pp. 1-12). [DOI:10.1145/2024156.2024208](https://doi.org/10.1145/2024156.2024208)

"""
struct L0Smooth <: AbstractImageSmoothAlgorithm
    """smoothing weight"""
    Î»::Float64
    """iteration rate"""
    Îº::Float64
    """the upper bound of automatically adapting parameter Î² which controls the iteraiton times"""
    Î²max::Float64

    function L0Smooth(Î», Îº, Î²max)
        Î» > zero(Î») || throw(ArgumentError("smoothing weight Î» should be positive"))
        Îº > one(Îº) || throw(ArgumentError("iteration rate Îº should be > 1.0"))
        Î²max > 1e4 || throw(ArgumentError("the iteration upper bound Î²max should be > 1e4"))
        new(Î», Îº, Î²max)
    end
end

L0Smooth(; Î»::Float64=2e-2, Îº::Float64=2.0, Î²max::Float64=1e5) = L0Smooth(Î», Îº, Î²max)

function (f::L0Smooth)(out::GenericGrayImage,
                       img::GenericGrayImage)
    ð = float64.(channelview(img))
    ð = f.Î» # smoothing weight
    ð = f.Îº # iteration rate
    ð½max = f.Î²max # upper bound of ð½
    ð½ = 2 * ð # define ð½â
    ââ = [1 -1]
    ââ = [1, -1]
    N, M = size(ð)
    sizeI2D = (N, M)
    sizeI2D_t = (M, N)
    # Return the frequency-space representation of `â±ââ` and `â±ââ`.
    â±ââ = freqkernel(centered(ââ), sizeI2D)
    â±ââ = transpose(freqkernel(centered(transpose(ââ)), sizeI2D_t))
    â±ð¼ = fft(ð, (1, 2))
    Denormin = @. abs(â±ââ)^2 + abs(â±ââ)^2

    ð¥âð = similar(ð)
    ð¥âð = similar(ð)
    ð¥âáµâ = similar(ð)
    ð¥âáµð£ = similar(ð)

    Normin = similar(â±ð¼) 
    tÂ¹ = trues(N, M)
    â±ð = similar(â±ð¼)

    while ð½ < ð½max
        # Computing (â, ð£) via solving equation (9) in [1]
        # We get the solution (12) in [1] through following process
        # Use (ð¥âð, ð¥âð) to demonstrate (â, ð£) for convenience
        fdiff!(ð¥âð, ð, dims = 2, boundary=:periodic)
        fdiff!(ð¥âð, ð, dims = 1, boundary=:periodic)

        # For each pixel ð in ð
        # (ââ, ð£â) = (0, 0), while (ð¥âðâ^2 + ð¥âðâ^2) < Î» / ð½
        # (ââ, ð£â) = (ð¥âðâ, ð¥âðâ), otherwise
        @. tÂ¹ = (ð¥âð^2 + ð¥âð^2) < ð / ð½

        ð¥âð[tÂ¹] .= 0
        ð¥âð[tÂ¹] .= 0

        # For equation (8), â = ð¥âð, ð£ = ð¥âð
        # According to Convolution Theorem, â±(ðâ * ðâ) = â±(ðâ) â â±(ðâ)
        # â± is the FFT operator, * is a convolution operator, â is a matrix dot times operator
        # We can compute â±(ââ)* â â±(â) and â±(ââ)* â â±(ð£) by computing â±(ð¥âáµâ) and â±(ð¥âáµð£)
        # ââ and ââ are the difference operators along horizontal axis and vertical axis, respectivly
        # â±()* denotes the complex conjugate
        # ð¥âáµ() and ð¥âáµ() indicate the transposition of forward difference along horizontal axis and vertical axis
        fdiff!(ð¥âáµâ, ð¥âð, dims = 2, rev=true, boundary=:periodic)
        fdiff!(ð¥âáµð£, ð¥âð, dims = 1, rev=true, boundary=:periodic)
        @. ð¥âáµâ = -ð¥âáµâ
        @. ð¥âáµð£ = -ð¥âáµð£

        # Computing S via equation (8) in [1]
        @. Normin = complex(ð¥âáµâ + ð¥âáµð£)
        fft!(Normin, (1, 2))
        @. â±ð = (â±ð¼ + ð½ * Normin) / (1 + ð½ * Denormin)
        ifft!(â±ð, (1, 2))
        @. ð = real(â±ð)

        ð½ = ð½ * ð
    end
    clamp01!(ð)
    out .= colorview(Gray, ð)
    return out
end

function (f::L0Smooth)(out::GenericImage{<:AbstractRGB},
                       img::GenericImage{<:AbstractRGB})
    ð = float64.(channelview(img))
    ð = f.Î» # smoothing weight
    ð = f.Îº # iteration rate
    ð½max = f.Î²max # upper bound of ð½
    ð½ = 2 * ð # define ð½â
    ââ = [1 -1]
    ââ = [1, -1]
    D, N, M = size(ð)
    sizeI2D = (N, M)
    sizeI2D_t = (M, N)
    # Return the frequency-space representation of `â±ââ` and `â±ââ`.
    â±ââ = freqkernel(centered(ââ), sizeI2D)
    â±ââ = transpose(freqkernel(centered(transpose(ââ)), sizeI2D_t))
    â±ð¼ = fft(ð, (2, 3))
    Denormin = @. abs(â±ââ)^2 + abs(â±ââ)^2
    Denormin = reshape(Denormin, 1, size(Denormin)...)
    Denormin = repeat(Denormin, inner=(1, 1, 1), outer=(D, 1, 1))

    ð¥âð = similar(ð)
    ð¥âð = similar(ð)
    sÂ³ = similar(ð)
    sÂ¹ = zeros(1, N, M)
    ð¥âáµâ = similar(ð)
    ð¥âáµð£ = similar(ð)

    Normin = similar(â±ð¼) 
    tÂ¹ = trues(1, N, M)
    tÂ³ = trues(D, N, M)
    â±ð = similar(â±ð¼)

    while ð½ < ð½max
        # Computing (â, ð£) via solving equation (9) in [1]
        # We get the solution (12) in [1] through following process
        # Use (ð¥âð, ð¥âð) to demonstrate (â, ð£) for convenience
        fdiff!(ð¥âð, ð, dims = 3, boundary=:periodic)
        fdiff!(ð¥âð, ð, dims = 2, boundary=:periodic)

        # For each pixel ð in ð, ð´â denotes the sum of three different channels
        # (ââ, ð£â) = (0, 0), while ð´â(ð¥âðââ¿^2 + ð¥âðââ¿^2) < Î» / ð½
        # (ââ, ð£â) = (ð¥âðâ, ð¥âðâ), otherwise
        @. sÂ³ = ð¥âð^2 + ð¥âð^2
        sÂ¹ .= sum(sÂ³, dims=1)
        @. tÂ¹ = sÂ¹ < ð / ð½
        tÂ³ .= repeat(tÂ¹, inner=(1, 1, 1), outer=(D, 1, 1))

        ð¥âð[tÂ³] .= 0
        ð¥âð[tÂ³] .= 0

        # For equation (8), â = ð¥âð, ð£ = ð¥âð
        # According to Convolution Theorem, â±(ðâ * ðâ) = â±(ðâ) â â±(ðâ)
        # â± is the FFT operator, * is a convolution operator, â is a matrix dot times operator
        # We can compute â±(ââ)* â â±(â) and â±(ââ)* â â±(ð£) by computing â±(ð¥âáµâ) and â±(ð¥âáµð£)
        # ââ and ââ are the difference operators along horizontal axis and vertical axis, respectivly
        # â±()* denotes the complex conjugate
        # ð¥âáµ() and ð¥âáµ() indicate the transposition of forward difference along horizontal axis and vertical axis
        fdiff!(ð¥âáµâ, ð¥âð, dims = 3, rev=true, boundary=:periodic)
        fdiff!(ð¥âáµð£, ð¥âð, dims = 2, rev=true, boundary=:periodic)
        @. ð¥âáµâ = -ð¥âáµâ
        @. ð¥âáµð£ = -ð¥âáµð£

        # Computing S via equation (8) in [1]
        @. Normin = complex(ð¥âáµâ + ð¥âáµð£)
        fft!(Normin, (2, 3))
        @. â±ð = (â±ð¼ + ð½ * Normin) / (1 + ð½ * Denormin)
        ifft!(â±ð, (2, 3))
        @. ð = real(â±ð)

        ð½ = ð½ * ð
    end
    clamp01!(ð)
    out .= colorview(RGB, ð)
    return out
end

function (f::L0Smooth)(out::OffsetArray, img::OffsetArray)
    axes(out) == axes(img) || throw(ArgumentError("out and img should have the same axes."))
    OffsetArray(f(out.parent, img.parent), out.offsets)
end