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

    return d
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

    return d
end

# Docstrings

"""
    forwarddiff(a::AbstractArray{T,N}; dims::Int) where {T,N}

Finite one-dimension forward difference operator on a vector or a multidimensional array `A`. In both cases,
the dimension to operate on needs to be specified with the `dims` keyword argument.

# Output

The return `Vector` or `Array` maintains the same size as input.

# Examples

```julia
julia> A = [2 4 8; 3 9 27; 4 16 64]
3×3 Matrix{Int64}:
 2   4   8
 3   9  27
 4  16  64

julia> forwarddiff(A, dims=2)
3×3 Matrix{Int64}:
  2   4   -6
  6  18  -24
 12  48  -60
```

See also [`forwarddiff!`](@ref) for in-place forward difference.
"""
forwarddiff

"""
    forwarddiff!(d::AbstractArray{T,N}, a::AbstractArray{T,N}; dims::Int) where {T,N}}

Finite one-dimension forward difference operator on a vector or a multidimensional array `A`. In both cases,
the dimension to operate on needs to be specified with the `dims` keyword argument.

# Output

`d` will be changed in place. The return `Vector` or `Array` maintains the same size as input.

# Examples

```julia
julia> A = [2 4 8; 3 9 27; 4 16 64]
3×3 Matrix{Int64}:
 2   4   8
 3   9  27
 4  16  64

julia> D = similar(A)
3×3 Matrix{Int64}:
 140441636044112  140441636135216  140441696235920
 140441647064848  140441636135296  140441636135456
 140441636135136  140441636135376  140441636135056

julia> forwarddiff!(D, A, dims=2)
3×3 Matrix{Int64}:
  2   4   -6
  6  18  -24
 12  48  -60

julia> D
3×3 Matrix{Int64}:
  2   4   -6
  6  18  -24
 12  48  -60
```

See also: [`forwarddiff`](@ref)
"""
forwarddiff!

"""
    backdiff(a::AbstractArray{T,N}; dims::Int) where {T,N}

Finite one-dimension backward difference operator on a vector or a multidimensional array `A`. In both cases,
the dimension to operate on needs to be specified with the `dims` keyword argument.

# Output

The return `Vector` or `Array` maintains the same size as input.

# Examples

```julia
julia> A = [2 4 8; 3 9 27; 4 16 64]
3×3 Matrix{Int64}:
 2   4   8
 3   9  27
 4  16  64

julia> backdiff(A, dims=2)
3×3 Matrix{Int64}:
  6   -2   -4
 24   -6  -18
 60  -12  -48
```

See also [`backdiff!`](@ref) for in-place backward difference.
"""
backdiff

"""
    backdiff!(d::AbstractArray{T,N}, a::AbstractArray{T,N}; dims::Int) where {T,N}}

Finite one-dimension backward difference operator on a vector or a multidimensional array `A`. In both cases,
the dimension to operate on needs to be specified with the `dims` keyword argument.

# Output

`d` will be changed in place. The return `Vector` or `Array` maintains the same size as input.

# Examples

```julia
julia> A = [2 4 8; 3 9 27; 4 16 64]
3×3 Matrix{Int64}:
 2   4   8
 3   9  27
 4  16  64

julia> D = similar(A)
3×3 Matrix{Int64}:
 140103024112336  140103024112336  140103027568240
               0                0                0
 140103024361232  140103024361232  140103024361232

julia> backdiff!(D, A, dims=2)
3×3 Matrix{Int64}:
  6   -2   -4
 24   -6  -18
 60  -12  -48

julia> D
3×3 Matrix{Int64}:
  6   -2   -4
 24   -6  -18
 60  -12  -48
```

See also: [`backdiff`](@ref)
"""
backdiff!