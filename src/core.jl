using Agents
using Random
using ImageFiltering

@agent Ant GridAgent{2} begin
    θ::Float32
end

@inline inbounds(pos, size) = all(1 .<= pos .<= size)

function initialize_model(
    size::Int;
    dep_pher::Real = 5,
    θ_pher::Float32 = 45f0,  # angle between pheromone sensors
    r_pher::Int = 1,   # radius of pheromone sensors
    d_pher::Int = 9,  # distance to pheromone sensors
    speed::Float32 = 1f0,   # movement speed
    decay_rate::Float32 = 0.99, # of pheromones
    seed::Int = 42,
)
    @assert d_pher >= 2r_pher

    dims = (size, size)

    space = GridSpace(dims; periodic = false)
    rng = MersenneTwister(seed)

    circ = [
        (i, j) for
        i in -r_pher:r_pher, j in -r_pher:r_pher if (i * i + j * j) <= r_pher * r_pher
    ]

    kernel = centered(fill(Float32(1 / 9), 3, 3) .* decay_rate)

    properties = (
        size = size,
        pheromones = fill(0f0, dims...),
        speed = speed*√2,
        sensor = circ,
        dep_pher = dep_pher,
        d_pher = d_pher,
        θ = deg2rad(θ_pher),
        kernel = kernel,
        border = Fill(0, kernel),
        rands = Int[],
    )

    ABM(Ant, space; rng, properties, scheduler = Schedulers.randomly)
end

function spawn_agents_position!(model, n_ants::Int, pos_ants::NTuple{2,Float32})
    for _ in 1:n_ants
        add_agent!(pos_ants, model, (0.0, 0.0), rand(rng) * 2π)
    end
    resize!(model.rands, nagents(model))
    nothing
end

function spawn_agents_circle!(model, radius::Int)
    center = floor.(Int, (model.size, model.size) ./ 2)
    for i in -radius:radius, j in -radius:radius
        r = √(i^2 + j^2)
        if inbounds(center .+ (i, j), model.size) && r > 0
            θ = acos(abs(i)/r)
            if i < 0 && j > 0
                θ = π - θ
            elseif i < 0 && j < 0
                θ = π + θ
            elseif i > 0 && j < 0
                θ = 2π - θ
            end
            add_agent!(center .+ (i, j), model, θ)
        end
    end
    resize!(model.rands, nagents(model))
    nothing
end

function spawn_agents_random!(model, chance::Float32)
    for i in 1:model.size, j in 1:model.size
        rand(model.rng) < chance && add_agent!((i, j), model, rand(model.rng) * 2π)
    end
    resize!(model.rands, nagents(model))
    nothing
end
