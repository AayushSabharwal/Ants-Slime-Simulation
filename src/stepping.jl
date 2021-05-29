using StatsBase

sample_sensor(pos, model) = sum(model.pheromones[(pos .+ off)...] for off in model.sensor)

call(f, x...) = f(x...)

function ant_step!(ant, model)
    sensors = pos_grid.(call.([left, mid, right], ant.θ, model), model)
    pher = sample_sensor.(sensors, model)
    Δθ = sample(model.rng, [-model.θ, 0, model.θ], Weights(pher)) + randn(model.rng) * model.σ
    ant.θ += Δθ
    move_agent!(ant, model, model.dt)
end

model_step!(model) = (model.pheromones .*= model.decay_rate)
