struct PeriodicMatrix{T, M<:AbstractMatrix{T}} <: AbstractMatrix{T}
    mat::M
end

PeriodicMatrix(mat::M) where {T, M<:AbstractMatrix{T}} = PeriodicMatrix{T, M}(mat)

Base.size(a::PeriodicMatrix) = size(a.mat)
Base.getindex(a::PeriodicMatrix, i...) = a.mat[mod1.(i, size(a.mat))...]
Base.getindex(a::PeriodicMatrix, i::CartesianIndex) = a.mat[mod1.(Tuple(i), size(a.mat))...]
Base.setindex!(a::PeriodicMatrix, v, i...) = (a.mat[mod1.(i, size(a.mat))...] = v)
Base.setindex!(a::PeriodicMatrix, v, i::CartesianIndex) = (a.mat[mod1.(Tuple(i), size(a.mat))...] = v)

