using StratiGraphics
using GeoStatsBase
using Plots, VisualRegressionTests
using Test, Pkg, Random

using ImageMagick

# workaround for GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
if !isCI
  Pkg.add("Gtk")
  using Gtk
end
datadir = joinpath(@__DIR__,"data")

include("dummysolver.jl")

@testset "StratiGraphics.jl" begin
  if visualtests
    Random.seed!(2019)
    proc   = GeoStatsProcess(Dummy())
    env    = Environment([proc, proc], [0.5 0.5; 0.5 0.5], ExponentialDuration(1.0))
    record = simulate(env, LandState(zeros(50,50)), 10)
    strata = Strata(record)

    @plottest plot(strata) joinpath(datadir,"strata.png") !isCI 0.1

    Random.seed!(2019)
    problem = SimulationProblem(RegularGrid(50,50,20), :strata => Float64, 3)
    solver₁ = StratSim(:strata => (environment=env,))
    solver₂ = StratSim(:strata => (environment=env,fillbase=0))
    solver₃ = StratSim(:strata => (environment=env,fillbase=0,filltop=0))
    solvers = [solver₁, solver₂, solver₃]

    solutions = [solve(problem, solver) for solver in solvers]
    snames = ["voxel1","voxel2","voxel3"]

    for (solution, sname) in zip(solutions, snames)
      reals = solution[:strata]
      @plottest begin
        plts = map(reals) do real
          R = reshape(real, 50, 50, 20)
          heatmap(rotr90(R[1,:,:]))
        end
        plot(plts..., layout=(3,1))
      end joinpath(datadir,sname*".png") !isCI
    end
  end
end
