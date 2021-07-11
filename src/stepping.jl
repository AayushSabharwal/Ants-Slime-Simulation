function ant_step!(ant, model)
    npos = floor.(Int, ant.pos .+ model.speed .* (cos(ant.θ), sin(ant.θ)))
    if inbounds(npos, model.size) && isempty(npos, model)
        move_agent!(ant, npos, model)
        model.pheromones[npos...] += model.dep_pher
    else
        ant.θ = rand(model.rng) * 2π
    end
end


function ant_turn!(ant, model)
    sample_sensor(pos) = sum(
        model.pheromones[(pos .+ p)...] for
        p in model.sensor if inbounds(pos .+ p, model.size)
    )
    mid = floor.(Int, ant.pos .+ model.d_pher .* (cos(ant.θ), sin(ant.θ)))
    lft = floor.(Int, ant.pos .+ model.d_pher .* (cos(ant.θ + model.θ), sin(ant.θ + model.θ)))
    rht = floor.(Int, ant.pos .+ model.d_pher .* (cos(ant.θ - model.θ), sin(ant.θ - model.θ)))
    smid = inbounds(mid, model.size) ? sample_sensor(mid) : 0
    slft = inbounds(lft, model.size) ? sample_sensor(lft) : 0
    srht = inbounds(rht, model.size) ? sample_sensor(rht) : 0
    if smid > slft && smid > srht
        return
    elseif smid < slft && smid < srht
        ant.θ += [model.θ, -model.θ][model.rands[ant.id]]
    elseif slft < srht
        ant.θ -= model.θ
    elseif srht < slft
        ant.θ += model.θ
    end
end

function model_step!(model)
    for ant in Agents.schedule(model)
        ant_step!(model[ant], model)
    end
    model.rands .= rand(model.rng, [1, 2], nagents(model))
    Threads.@threads for i in 1:nagents(model)
        ant_turn!(model[i], model)
    end

    model.pheromones .= imfilter(model.pheromones, model.kernel, model.border)
end
