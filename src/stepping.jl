using StatsBase

sample_sensor(pos, model) = sum(model.pheromones[(pos .+ off)...] for off in model.sensor)

call(f, x...) = f(x...)

function ant_step!(ant, model)
    pher = [sample_sensor(pos_grid(f(ant.θ, model), model), model) for f in [left, mid, right]]
    Δθ = sample(model.rng, [-model.θ, 0, model.θ], Weights(pher)) + randn(model.rng) * model.σ
    ant.θ += Δθ
    move_agent!(ant, model, model.dt)
    model.pheromones[pos_grid(ant.pos, model)...] += 1
end

model_step!(model) = (model.pheromones .*= model.decay_rate)
