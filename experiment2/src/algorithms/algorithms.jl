include("stop.jl")
include("eas.jl")
include("simulated-annealing.jl")
export name
export optimize, ea1pλwith2rates, ea1p1, ea1p1SD, ea1pλSASD, RLSSDstar, RLS12, RLSSDstarstar
export fastSD
export SDCounter, SDCounterEstimation, RLSSDCounter, threshold_gen
export FixedBudget, niterations
export FixedCooling, temperature, SimulatedAnnealing, AbstractCooling, FixedCoolingTag


name(algo::AbstractAlgorithm) = algo.name

function Base.show(io::IO, algo::AbstractAlgorithm)
    print(io, algo.name)
    first = true
    for p in deepparameters(algo)
        if first
            print(io, " with ")
            first = false
        else
            print(io, " and ")
        end

        print(io, string(p[1]))
        print(io, ":")
        show(io, p[2])
    end
end
