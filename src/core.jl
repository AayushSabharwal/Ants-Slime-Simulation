using Agents
using Random

const ATOL = 1e-4

@agent Ant ContinuousAgent{2} begin
    θ::Float64
end

@inline δ_grid(δ, ssize, gsize) = floor(Int, δ / ssize * gsize)
@inline δ_grid(δ, model) = δ_grid(δ, model.ssize, model.gsize)
@inline pos_grid(pos, model) = δ_grid.(pos, model)
@inline rect(θ) = (cos(θ), sin(θ))
@inline left(θ, model) = model.d_pher .* (cos(θ + model.θ), sin(θ + model.θ))
@inline mid(θ, model) = model.d_pher .* (cos(θ), sin(θ))
@inline right(θ, model) = model.d_pher .* (cos(θ - model.θ), sin(θ - model.θ))
update_vel!(ant, model) = (ant.vel = model.speed .* (cos(ant.θ), sin(ant.θ)))

function initialize_model(
    size::Float64,
    grid_size::Int,
    n_ants::Int,
    pos_ants::NTuple{2,Float64};
    r_vis::Float64 = 3.0,    # vision radius
    θ_pher::Float64 = 60.0,  # angle between pheromone sensors
    r_pher::Float64 = 1.0,   # radius of pheromone sensors
    d_pher::Float64 = 2.0,  # distance to pheromone sensors
    speed::Float64 = 3.0,   # movement speed
    σ::Float64 = 3.0,     # stdev of random angle variation
    decay_rate::Float64 = 0.93, # of pheromones
    dt::Float64 = 0.3,  # time granularity of simulation
    seed::Int = 42,
)
    @assert d_pher >= 2r_pher
    
    dims = (size, size)
    grid_dims = (grid_size, grid_size)

    space = ContinuousSpace(dims, min(dims...) / r_vis)
    rng = MersenneTwister(seed)

    gr_pher = δ_grid(r_pher, size, grid_size)
    gd_pher = δ_grid(d_pher, size, grid_size)

    circ = [
        (i, j) for i in -gr_pher:gr_pher, j in -gr_pher:gr_pher if
        (i * i + j * j) <= gr_pher * gr_pher
    ]

    properties = (
        ssize = size,
        gsize = grid_size,
        pheromones = PeriodicMatrix(fill(0.0, grid_dims...)),
        speed = speed,
        sensor = circ,
        d_pher = d_pher,
        gd_pher = gd_pher,
        θ = deg2rad(θ_pher),
        σ = σ,
        decay_rate = decay_rate * dt,
        dt = dt,
    )

    model = ABM(Ant, space; rng, properties)

    for _ = 1:n_ants
        add_agent!(pos_ants, model, (0., 0.), rand(rng) * 2π)
    end

    return model
end
