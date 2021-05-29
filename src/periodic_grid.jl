struct PeriodicMatrix{T, M<:AbstractMatrix{T}} <: AbstractMatrix{T}
    mat::M
end

PeriodicMatrix(mat::M) where {T, M<:AbstractMatrix{T}} = PeriodicMatrix{T, M}(mat)

Base.size(a::PeriodicMatrix) = size(a.mat)
Base.getindex(a::PeriodicMatrix, i...) = getindex(a.mat, ((i .+ size(a.mat) .- 1) .% size(a.mat) .+ 1)...)
Base.setindex!(a::PeriodicMatrix, v, i...) = setindex!(a.mat, v, ((i .+ size(a.mat) .- 1) .% size(a.mat) .+ 1)...)
