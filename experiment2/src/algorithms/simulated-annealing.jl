abstract type AbstractSimulatedAnnealing <: AbstractAlgorithm end
abstract type AbstractCooling end

"""
    struct FixedCooling <: AbstractCooling
        temperature::Float64
    end

Using this cooling scheduler, the algorithm accepts a worser solution with probability ``\\alpha^{-\\Delta}``, where 
``\\alpha`` is the parameter temperature and ``\\Delta`` is the absolute difference of the fitness functions between the parent and child.

Through `FixedCooling`, you are basicaully using `Metropolis` algorithm.
"""


struct FixedCooling <: AbstractCooling
    temperature::Real
    function FixedCooling(temperature::Real = 0.0)
        new(temperature)
    end
end

function temperature(cooling::FixedCooling, iter::Int)
    return cooling.temperature
end

struct FixedCoolingTag <: AbstractCooling
    temperature::Real
    order::LaTeXString
    function FixedCoolingTag(temperature::Real = 0.0, order::LaTeXString = L"nothing")
        new(temperature, order)
    end
end

function temperature(cooling::FixedCoolingTag, temp::Real)
    return cooling.temperature
end

"""
    struct SimulatedAnnealing <: AbstractSimulatedAnnealing
        cooling::AbstractCooling
        stop::AbstractStop
        name::LaTeXString
        temperature::Float64
    end
"""
struct SimulatedAnnealing <: AbstractSimulatedAnnealing
    cooling::AbstractCooling
    stop::AbstractStop
    name::LaTeXString
    temperature::Real
    mutation::Mutation

    function SimulatedAnnealing(
        cooling::AbstractCooling;
        stop::AbstractStop = FixedBudget(10^11),
        name::LaTeXString = L"Simulated-Annealing",
        temperature::Real = -1.0,
        mutation::Mutation = KBitFlip(1)
    )
        new(cooling, stop, name, temperature, mutation)
    end
end

function optimize(x, setting::SimulatedAnnealing)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)

    for iter ∈ 1:niterations(setting.stop)
        α = float(temperature(setting.cooling, iter))
        y = mutation(x, setting.mutation)
        Δ = fitness(y) - fitness(x)

        if Δ ≥ 0
            if Δ > 0
                if isoptimum(y)
                    record(trace, y, iter, isoptimum(y))
                end
            end
            x = y
            if isoptimum(x)
                return trace
            end
        elseif rand() ≤ α^(Δ)
            # record(trace, y, iter, isoptimum(y))
            x = y
        end
    end
    trace
end
