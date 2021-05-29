using GLMakie
using HDF5
function run(model, file; nsteps = 100)
    f = h5open(file, "w")
    f["log"] = zeros((nsteps, size(model.pheromones)...))
    fdata = HDF5.readmmap(f["log"])
    for i in 1:nsteps
        Agents.step!(model, ant_step!, model_step!)
        fdata[i,:,:] = model.pheromones.mat
    end
    close(f)
end

function plot(file)
    fig = Figure(resolution = (1000, 1000))
    f = h5open(file, "r")
    maxt = size(f["log"], 1)
    time = Slider(fig[1,1], range = 1:maxt, startvalue = 1; tellwidth = false)
    chm = @lift(f["log"][$(time.value), :, :])
    ax = fig[2,1] = Axis(fig)
    heatmap!(ax, chm)

    fig, f
end