function forwarddiff(a::AbstractArray{T,N}; dims::Int) where {T,N}
    require_one_based_indexing(a)
    1 <= dims <= N || throw(ArgumentError("dimension $dims out of range (1:$N)"))

    d = similar(a)
    r = axes(a)
    r0 = ntuple(i -> i == dims ? UnitRange(1, last(r[i]) - 1) : UnitRange(r[i]), N)
    r1 = ntuple(i -> i == dims ? UnitRange(2, last(r[i])) : UnitRange(r[i]), N)

    d0 = ntuple(i -> i == dims ? UnitRange(last(r[i]), last(r[i])) : UnitRange(r[i]), N)
    d1 = ntuple(i -> i == dims ? UnitRange(1, 1) : UnitRange(r[i]), N)

    d[r0...] = view(a, r1...) .- view(a, r0...)
    d[d0...] = view(a, d1...) .- view(a, d0...)

    return d
end

function backdiff(a::AbstractArray{T,N}; dims::Int) where {T,N}
    require_one_based_indexing(a)
    1 <= dims <= N || throw(ArgumentError("dimension $dims out of range (1:$N)"))

    d = similar(a)
    r = axes(a)
    r0 = ntuple(i -> i == dims ? UnitRange(1, last(r[i]) - 1) : UnitRange(r[i]), N)
    r1 = ntuple(i -> i == dims ? UnitRange(2, last(r[i])) : UnitRange(r[i]), N)

    d0 = ntuple(i -> i == dims ? UnitRange(last(r[i]), last(r[i])) : UnitRange(r[i]), N)
    d1 = ntuple(i -> i == dims ? UnitRange(1, 1) : UnitRange(r[i]), N)

    d[r1...] = view(a, r0...) .- view(a, r1...)
    d[d1...] = view(a, d0...) .- view(a, d1...)

    return d
end

function forwarddiff!(d::AbstractArray{T,N}, a::AbstractArray{T,N}; dims::Int) where {T,N}
    require_one_based_indexing(a)
    1 <= dims <= N || throw(ArgumentError("dimension $dims out of range (1:$N)"))

    r = axes(a)
    r0 = ntuple(i -> i == dims ? UnitRange(1, last(r[i]) - 1) : UnitRange(r[i]), N)
    r1 = ntuple(i -> i == dims ? UnitRange(2, last(r[i])) : UnitRange(r[i]), N)

    d0 = ntuple(i -> i == dims ? UnitRange(last(r[i]), last(r[i])) : UnitRange(r[i]), N)
    d1 = ntuple(i -> i == dims ? UnitRange(1, 1) : UnitRange(r[i]), N)

    d[r0...] = view(a, r1...) .- view(a, r0...)
    d[d0...] = view(a, d1...) .- view(a, d0...)
end

function backdiff!(d::AbstractArray{T,N}, a::AbstractArray{T,N}; dims::Int) where {T,N}
    require_one_based_indexing(a)
    1 <= dims <= N || throw(ArgumentError("dimension $dims out of range (1:$N)"))

    r = axes(a)
    r0 = ntuple(i -> i == dims ? UnitRange(1, last(r[i]) - 1) : UnitRange(r[i]), N)
    r1 = ntuple(i -> i == dims ? UnitRange(2, last(r[i])) : UnitRange(r[i]), N)

    d0 = ntuple(i -> i == dims ? UnitRange(last(r[i]), last(r[i])) : UnitRange(r[i]), N)
    d1 = ntuple(i -> i == dims ? UnitRange(1, 1) : UnitRange(r[i]), N)

    d[r1...] = view(a, r0...) .- view(a, r1...)
    d[d1...] = view(a, d0...) .- view(a, d1...)
end

expanded_channelview(img::AbstractArray{T}) where T<:Colorant = channelview(img)
expanded_channelview(img::AbstractArray{T}) where T<:Gray = reshape(channelview(img), 1, size(img)...)