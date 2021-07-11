abstract type AbstractImageSmoothAlgorithm <: AbstractImageFilter end

smooth!(out::GenericGrayImage,
        img::GenericGrayImage,
        f::AbstractImageSmoothAlgorithm,
        args...; kwargs...) =
    f(out, img, args...; kwargs...)


function smooth(img::AbstractArray{T},
                f::AbstractImageSmoothAlgorithm,
                args...; kwargs...) where T <: Colorant
    out = similar(img)
    smooth!(out, img, f, args...; kwargs...)
    return out
end
