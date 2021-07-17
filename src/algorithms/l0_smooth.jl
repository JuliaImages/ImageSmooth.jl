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

function (f::L0Smooth)(out::GenericGrayImage,
                       img::GenericGrayImage)
    S = of_eltype(floattype(eltype(img)), img)
    λ = f.λ
    κ = f.κ
    βmax = 1e5
    fx = [1 -1]
    fy = [1, -1]
    N, M = size(S)
    sizeI2D = (N, M)
    sizeI2D_t = (M, N)
    otfFx = freqkernel(centered(fx), sizeI2D)
    otfFy = transpose(freqkernel(centered(transpose(fy)), sizeI2D_t))
    Normin1 = fft(S, (1, 2))
    Denormin2 = abs.(otfFx).^2 + abs.(otfFy).^2
    β = 2*λ
    while β < βmax
        Denormin = 1 .+ β * Denormin2

        h = forwarddiff(S, dims = 2)
        v = forwarddiff(S, dims = 1)

        t = (h.^2 + v.^2) .< λ / β

        h[t] .= 0
        v[t] .= 0

        Normin2 = backdiff(h, dims = 2)
        Normin2 = Normin2 + backdiff(v, dims = 1)
        FS = (Normin1 + β*fft(Normin2, (1, 2))) ./ Denormin
        S = real(ifft(FS, (1, 2)))
        β = β * κ
    end
    out .= colorview(Gray, S)
    return out
end
