@doc raw"""
    L0Smooth <: AbstractImageSmoothAlgorithm
    L0Smooth(; λ=2e-2, κ=2.0, βmax=1e5)

    smooth(img, f::L0Smooth)
    smooth!(out, img, f::L0Smooth)

Smoothing `img` via L0 gradient minimization to approximate prominent structure
in a sparsity-control manner.

# Output

Return the smoothed image as an `Array{Float64}` of `size(input)`.

For Gray img, `input = reshape(channelview(img), 1, size(img)...)`.
For RGB image, `input = channelview(img)`.

# Details

Using the strategy of minimizing the L0 norm of image's gradient.

This algorithm works particularly effective for sharpening major edges by 
increasing the steepness of amplitude transition while eliminating 
low-amplitude structures to some extent. See [1] for more details. 

# Options

The function argument is described in detail below.

## `λ::Float64`

The argument `𝜆` is a weight directly controlling the significance of 
the L0 gradient norm term, which must be greater than zero.

A larger `𝜆` makes the smoothed image have very few edges.

Default: 2e-2

## `βmax::Float64`

The argument `βmax` is the upper bound of `𝛽` in [1], which must be greater than 1e4.

In this algorithm, two auxiliary variables `ℎ` and `𝑣` are used to approximate 
the solution. A large enough `𝛽` ensures that the alternating optimization strategy 
based on introducing auxiliary variables is available.

Default: 1e5

## `κ::Float64`

The argument `𝜅` is the iteraiton rate, which must be larger than 1.0.

This algorithm using an alternating optimization strategy to get the solution.
In each iteration, the argument `𝛽` controls the similarity between gradient pair 
(𝛥₁𝑆ₚ, 𝛥₂𝑆ₚ) (denoted by `` (\partial_x S_p, \partial_y S_p) `` in [1]) and auxiliary pair (ℎₚ, 𝑣ₚ).
The argument `𝜅` is used to update `𝛽` as `𝛽 ⟵ 𝜅𝛽`.

Default: 2.0

# Examples

You can use the default arguments for `L0Smooth`, and then use `smooth` to apply 
the `AbstractImageSmoothAlgorithm`.

```julia
using TestImages
using ImageSmooth

img = testimage("cameraman")

fₛ = L0Smooth() # using default arguements
imgₛ = smooth(img, fₛ)
```

Manually setting the arguements is also available:

```julia
fₛ = L0Smooth(λ=0.0015, κ=1.05, βmax=2e5) # manually set the arguments
imgₛ = smooth(img, fₛ)
```

See also [`smooth!`](@ref) for in-place operation.

# References

[1] Xu, L., Lu, C., Xu, Y., & Jia, J. (2011, December). Image smoothing via L 0 gradient minimization. In Proceedings of the 2011 SIGGRAPH Asia conference (pp. 1-12). [DOI:10.1145/2024156.2024208](https://doi.org/10.1145/2024156.2024208)

"""
struct L0Smooth <: AbstractImageSmoothAlgorithm
    """smoothing weight"""
    λ::Float64
    """iteration rate"""
    κ::Float64
    """the upper bound of automatically adapting parameter β which controls the iteraiton times"""
    βmax::Float64

    function L0Smooth(λ, κ, βmax)
        λ > zero(λ) || throw(ArgumentError("smoothing weight λ should be positive"))
        κ > one(κ) || throw(ArgumentError("iteration rate κ should be > 1.0"))
        βmax > 1e4 || throw(ArgumentError("the iteration upper bound βmax should be > 1e4"))
        new(λ, κ, βmax)
    end
end

L0Smooth(; λ::Float64=2e-2, κ::Float64=2.0, βmax::Float64=1e5) = L0Smooth(λ, κ, βmax)


function (f::L0Smooth)(out::AbstractArray{<: Number},
                       img::AbstractArray{<: Number})
    𝑆 = float64.(img)
    𝜆 = f.λ # smoothing weight
    𝜅 = f.κ # iteration rate
    𝛽max = f.βmax # upper bound of 𝛽
    𝛽 = 2 * 𝜆 # define 𝛽₀
    ∂₁ = [1 -1]
    ∂₂ = [1, -1]
    D, N, M = size(𝑆)
    sizeI2D = (N, M)
    sizeI2D_t = (M, N)
    # Return the frequency-space representation of `ℱ∂₁` and `ℱ∂₂`.
    ℱ∂₁ = freqkernel(centered(∂₁), sizeI2D)
    ℱ∂₂ = transpose(freqkernel(centered(transpose(∂₂)), sizeI2D_t))
    ℱ𝐼 = fft(𝑆, (2, 3))
    Denormin = @. abs(ℱ∂₁)^2 + abs(ℱ∂₂)^2
    Denormin = reshape(Denormin, 1, size(Denormin)...)
    if D > 1
        Denormin = repeat(Denormin, inner=(1, 1, 1), outer=(D, 1, 1))
    end

    𝛥₁𝑆 = similar(𝑆)
    𝛥₂𝑆 = similar(𝑆)
    s³ = similar(𝑆)
    s¹ = zeros(1, N, M)
    𝛻₁ℎ = similar(𝑆)
    𝛻₂𝑣 = similar(𝑆)

    Normin = similar(ℱ𝐼) 
    t¹ = trues(1, N, M)
    t³ = trues(D, N, M)
    ℱ𝑆 = similar(ℱ𝐼)

    while 𝛽 < 𝛽max
        # Computing (ℎ, 𝑣) via solving equation (9) in [1]
        # We get the solution (12) in [1] through following process
        # Use (𝛥₁𝑆, 𝛥₂𝑆) to demonstrate (ℎ, 𝑣) for convenience
        fdiff!(𝛥₁𝑆, 𝑆, dims = 3, boundary=:periodic)
        fdiff!(𝛥₂𝑆, 𝑆, dims = 2, boundary=:periodic)

        # For each pixel 𝑝 in 𝑆
        # (ℎₚ, 𝑣ₚ) = (0, 0), while (𝛥₁𝑆ₚ^2 + 𝛥₂𝑆ₚ^2) < λ / 𝛽
        # (ℎₚ, 𝑣ₚ) = (𝛥₁𝑆ₚ, 𝛥₂𝑆ₚ), otherwise
        if D > 1
            @. s³ = 𝛥₁𝑆^2 + 𝛥₂𝑆^2
            s¹ .= sum(s³, dims=1)
            @. t¹ = s¹ < 𝜆 / 𝛽
            t³ .= repeat(t¹, inner=(1, 1, 1), outer=(D, 1, 1))

            𝛥₁𝑆[t³] .= 0
            𝛥₂𝑆[t³] .= 0
        else
            @. t¹ = (𝛥₁𝑆^2 + 𝛥₂𝑆^2) < 𝜆 / 𝛽

            𝛥₁𝑆[t¹] .= 0
            𝛥₂𝑆[t¹] .= 0
        end

        # For equation (8), ℎ = 𝛥₁𝑆, 𝑣 = 𝛥₂𝑆
        # According to Convolution Theorem, ℱ(𝑓₁ * 𝑓₂) = ℱ(𝑓₁) ⋅ ℱ(𝑓₂)
        # ℱ is the FFT operator, * is a convolution operator, ⋅ is a matrix dot times operator
        # We can compute ℱ(∂₁)* ⋅ ℱ(ℎ) and ℱ(∂₂)* ⋅ ℱ(𝑣) by computing ℱ(𝛻₁ℎ) and ℱ(𝛻₂𝑣)
        # ∂₁ and ∂₂ are the difference operators along horizontal axis and vertical axis, respectivly
        # 𝛻₁() and 𝛻₂() indicate the backward difference along horizontal axis and vertical axis
        fdiff!(𝛻₁ℎ, 𝛥₁𝑆, dims = 3, rev=true, boundary=:periodic)
        fdiff!(𝛻₂𝑣, 𝛥₂𝑆, dims = 2, rev=true, boundary=:periodic)
        @. 𝛻₁ℎ = -𝛻₁ℎ
        @. 𝛻₂𝑣 = -𝛻₂𝑣

        # Computing S via equation (8)
        @. Normin = complex(𝛻₁ℎ + 𝛻₂𝑣)
        fft!(Normin, (2, 3))
        @. ℱ𝑆 = (ℱ𝐼 + 𝛽 * Normin) / (1 + 𝛽 * Denormin)
        ifft!(ℱ𝑆, (2, 3))
        @. 𝑆 = real(ℱ𝑆)

        𝛽 = 𝛽 * 𝜅
    end
    out .= clamp01!(𝑆)
    return out
end