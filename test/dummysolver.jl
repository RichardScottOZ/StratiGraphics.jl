import GeoStatsBase: solvesingle

# define a dummy solver for testing
@simsolver Dummy begin end
function solvesingle(problem::SimulationProblem, covars::NamedTuple,
                      solver::Dummy, preproc)
  reals = map(covars.names) do var
    pdomain = domain(problem)
    n = nelms(pdomain)
    V = variables(problem)[var]
    var => fill(one(V), n)
  end
  Dict(reals)
end
