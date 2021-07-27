"""
    L0Smooth <: AbstractImageSmoothAlgorithm

    smooth(img, f::L0Smooth)
    smooth!(out, img, f::L0Smooth)

Smoothen 'img' via L0 gradient minimization to approximate prominent structure
in a sparsity-control manner.

"""

struct L0Smooth <: AbstractImageSmoothAlgorithm
    """smoothing weight"""
    λ::Float64
    """iteration rate"""
    κ::Float64

    function L0Smooth(λ, κ)
        λ > zero(λ) || throw(ArgumentError("smoothing weight λ should be positive"))
        κ > one(κ) || throw(ArgumentError("iteration rate κ should be > 1.0"))
        new(λ, κ)
    end
end

L0Smooth(; λ::Float64=2e-2, κ::Float64=2.0) = L0Smooth(λ, κ)

# function (f::L0Smooth)(out::AbstractArray{<: Number},
#                        img::GenericGrayImage)
#     𝑆 = float64.(channelview(img))
#     𝜆 = f.λ # smoothing weight
#     𝜅 = f.κ # iteration rate
#     𝛽 = 2 * 𝜆 # define 𝛽₀
#     𝛽max = 1e5
#     ∂₁ = [1 -1]
#     ∂₂ = [1, -1]
#     N, M = size(𝑆)
#     sizeI2D = (N, M)
#     sizeI2D_t = (M, N)
#     ℱ∂₁ = freqkernel(centered(∂₁), sizeI2D)
#     ℱ∂₂ = transpose(freqkernel(centered(transpose(∂₂)), sizeI2D_t))
#     ℱ𝐼 = fft(𝑆)
#     Denormin = similar(ℱ𝐼)
#     @. Denormin = abs(ℱ∂₁)^2 + abs(ℱ∂₂)^2

#     𝛥₁𝑆 = similar(𝑆)
#     𝛥₂𝑆 = similar(𝑆)
#     𝛻₁ℎ = similar(𝑆)
#     𝛻₂𝑣 = similar(𝑆)

#     Normin = similar(ℱ𝐼) 
#     t = trues(N, M)
#     ℱ𝑆 = similar(ℱ𝐼)

#     while 𝛽 < 𝛽max
#         # Computing (ℎ, 𝑣) via solving equation (9)
#         # Actually, we get the solution in (12) through following process
#         # Use 𝛥₁𝑆, 𝛥₂𝑆 to demonstrate ℎ, 𝑣 for convenience
#         forwarddiff!(𝛥₁𝑆, 𝑆, dims = 2)
#         forwarddiff!(𝛥₂𝑆, 𝑆, dims = 1)

#         # For each pixel 𝑝 in 𝑆
#         # (ℎₚ, 𝑣ₚ) = (0, 0), while (𝛥₁𝑆ₚ^2 + 𝛥₂𝑆ₚ^2) < λ / 𝛽
#         # (ℎₚ, 𝑣ₚ) = (𝛥₁𝑆ₚ, 𝛥₂𝑆ₚ), otherwise
#         @. t = (𝛥₁𝑆^2 + 𝛥₂𝑆^2) < 𝜆 / 𝛽

#         𝛥₁𝑆[t] .= 0
#         𝛥₂𝑆[t] .= 0

#         # For equation (8), ℎ = 𝛥₁𝑆, 𝑣 = 𝛥₂𝑆
#         # According to Convolution Theorem, ℱ(𝑓₁ * 𝑓₂) = ℱ(𝑓₁) × ℱ(𝑓₂)
#         # ℱ is the FFT operator, * is a convolution operator, × is a matrix times operator
#         # We can compute ℱ(∂₁)* × ℱ(ℎ) and ℱ(∂₂)* × ℱ(𝑣) by computing ℱ(𝛻₁ℎ) and ℱ(𝛻₂𝑣)
#         # ∂₁ and ∂₂ are the difference operators along horizontal axis and vertical axis, respectivly
#         # 𝛻₁() and 𝛻₂() indicate the backward difference along horizontal axis and vertical axis
#         backdiff!(𝛻₁ℎ, 𝛥₁𝑆, dims = 2)
#         backdiff!(𝛻₂𝑣, 𝛥₂𝑆, dims = 1)

#         # Computing S via equation (8)
#         @. Normin = complex(𝛻₁ℎ + 𝛻₂𝑣)
#         fft!(Normin)
#         @. ℱ𝑆 = (ℱ𝐼 + 𝛽 * Normin) / (1 + 𝛽 * Denormin)
#         ifft!(ℱ𝑆)
#         @. 𝑆 = real(ℱ𝑆)

#         𝛽 = 𝛽 * 𝜅
#     end
#     # out .= colorview(Gray, 𝑆)
#     out .= clamp01!(𝑆)
#     return out
# end

function (f::L0Smooth)(out::AbstractArray{<: Number},
                       img::AbstractArray{<: Number})
    𝑆 = float64.(img)
    𝜆 = f.λ # smoothing weight
    𝜅 = f.κ # iteration rate
    𝛽 = 2 * 𝜆 # define 𝛽₀
    𝛽max = 1e5
    ∂₁ = [1 -1]
    ∂₂ = [1, -1]
    D, N, M = size(𝑆)
    sizeI2D = (N, M)
    sizeI2D_t = (M, N)
    ℱ∂₁ = freqkernel(centered(∂₁), sizeI2D)
    ℱ∂₂ = transpose(freqkernel(centered(transpose(∂₂)), sizeI2D_t))
    ℱ𝐼 = fft(𝑆, (2, 3))
    Denormin = @. abs(ℱ∂₁)^2 + abs(ℱ∂₂)^2
    Denormin = repeat(reshape(Denormin, 1, size(Denormin)...), inner=(1, 1, 1), outer=(D, 1, 1))

    𝛥₁𝑆 = similar(𝑆)
    𝛥₂𝑆 = similar(𝑆)
    𝛻₁ℎ = similar(𝑆)
    𝛻₂𝑣 = similar(𝑆)

    Normin = similar(ℱ𝐼) 
    t¹ = trues(1, N, M)
    t³ = trues(D, N, M)
    ℱ𝑆 = similar(ℱ𝐼)

    while 𝛽 < 𝛽max
        # Computing (ℎ, 𝑣) via solving equation (9)
        # Actually, we get the solution in (12) through following process
        # Use 𝛥₁𝑆, 𝛥₂𝑆 to demonstrate ℎ, 𝑣 for convenience
        forwarddiff!(𝛥₁𝑆, 𝑆, dims = 3)
        forwarddiff!(𝛥₂𝑆, 𝑆, dims = 2)

        # For each pixel 𝑝 in 𝑆
        # (ℎₚ, 𝑣ₚ) = (0, 0), while (𝛥₁𝑆ₚ^2 + 𝛥₂𝑆ₚ^2) < λ / 𝛽
        # (ℎₚ, 𝑣ₚ) = (𝛥₁𝑆ₚ, 𝛥₂𝑆ₚ), otherwise
        t¹ .= sum((𝛥₁𝑆.^2 .+ 𝛥₂𝑆.^2), dims=1) .< 𝜆 / 𝛽
        t³ .= repeat(t¹, inner=(1, 1, 1), outer=(D, 1, 1))

        𝛥₁𝑆[t³] .= 0
        𝛥₂𝑆[t³] .= 0

        # For equation (8), ℎ = 𝛥₁𝑆, 𝑣 = 𝛥₂𝑆
        # According to Convolution Theorem, ℱ(𝑓₁ * 𝑓₂) = ℱ(𝑓₁) × ℱ(𝑓₂)
        # ℱ is the FFT operator, * is a convolution operator, × is a matrix times operator
        # We can compute ℱ(∂₁)* × ℱ(ℎ) and ℱ(∂₂)* × ℱ(𝑣) by computing ℱ(𝛻₁ℎ) and ℱ(𝛻₂𝑣)
        # ∂₁ and ∂₂ are the difference operators along horizontal axis and vertical axis, respectivly
        # 𝛻₁() and 𝛻₂() indicate the backward difference along horizontal axis and vertical axis
        backdiff!(𝛻₁ℎ, 𝛥₁𝑆, dims = 3)
        backdiff!(𝛻₂𝑣, 𝛥₂𝑆, dims = 2)

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