using HDF5
using GLMakie
using ProgressMeter

function simulate!(model, file; nsteps = 100)
    f = h5open(file, "w")
    f["log"] = zeros((nsteps, size(model.pheromones)...))
    fdata = HDF5.readmmap(f["log"])
    p = Progress(nsteps; barglyphs = BarGlyphs("[=> ]"))
    for i in 1:nsteps
        fdata[i, :, :] = model.pheromones
        Agents.step!(model, ant_step!, model_step!)
        next!(p)
    end
    close(f)
end

function pheromone_map(file)
    f = h5open(file, "r")
    fig = Figure(; resolution = (600, 600))
    ax = fig[1, 1] = Axis(fig; aspect = AxisAspect(1))
    slider = Slider(fig[2, 1], range = 1:size(f["log"], 1), startvalue = 1)
    current = @lift(f["log"][$(slider.value), :, :])
    heatmap!(ax, current; colormap = :viridis)
    return fig, f
end
