using GeoStatsBase
using GeoStatsDevTools
using StratiGraphics
using Plots; gr()
using VisualRegressionTests
using Test, Pkg, Random

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__,"data")
visualtests = !istravis || (istravis && islinux)
if !istravis
  Pkg.add("Gtk")
  using Gtk
end

include("dummysolver.jl")

@testset "StratiGraphics.jl" begin
  if visualtests
    Random.seed!(2019)
    env = Environment([Dummy(),Dummy()], [0.5 0.5; 0.5 0.5], ExponentialDuration(1.0))
    record = simulate(env, LandState(zeros(50,50)), 10)
    strata = Strata(record)

    @plottest plot(strata) joinpath(datadir,"strata.png") !istravis

    Random.seed!(2019)
    problem = SimulationProblem(RegularGrid{Float64}(50,50,20), :strata => Float64, 3)
    solver₁ = StratSim(:strata => (environment=env,))
    solver₂ = StratSim(:strata => (environment=env,fillbase=0))
    solver₃ = StratSim(:strata => (environment=env,fillbase=0,filltop=0))
    solvers = [solver₁, solver₂, solver₃]

    solutions = [solve(problem, solver) for solver in solvers]
    snames = ["voxel1","voxel2","voxel3"]

    for (solution, sname) in zip(solutions, snames)
      reals = digest(solution)[:strata]
      @plottest begin
        plts = [heatmap(rotr90(real[1,:,:])) for real in reals]
        plot(plts..., layout=(3,1))
      end joinpath(datadir,sname*".png") !istravis
    end
  end
end
