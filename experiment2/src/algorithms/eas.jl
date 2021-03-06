abstract type AbstractEA <: AbstractAlgorithm end
using LaTeXStrings

using DataFrames

struct ea1pλwith2rates <: AbstractEA
    λ::Integer
    stop::AbstractStop
    name::LaTeXString
    function ea1pλwith2rates(;
        λ::Integer = 10,
        stop::AbstractStop = FixedBudget(1000),
        name::LaTeXString = L"(1+λ)EA with 2 rates",
    )
        new(λ, stop, name)
    end
end

function optimize(x, setting::ea1pλwith2rates)
    λ = setting.λ
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    # bitrand returns a random bit string.
    r = 2

    for iter ∈ 1:niterations(setting.stop)
        α = copy(x)
        rα = r
        for i = 1:λ
            if i ≤ λ / 2
                ry = r / (2n)
                y = mutation(x, UniformlyIndependentMutation(ry))
            else
                ry = 2r / n
                y = mutation(x, UniformlyIndependentMutation(ry))
            end

            if fitness(y) ≥ fitness(α)
                α = y
                rα = ry
            end
        end

        # The second condition is for implementing "breaking ties randomly".
        if fitness(α) ≥ fitness(x)
            if fitness(α) > fitness(x)
                record(trace, α, iter, isoptimum(α))
            end
            x = α

            if isoptimum(x)
                return trace
            end
        end

        if rand() < 0.5
            r = rα
        else
            r = if (rand() < 0.5)
                r = r / 2
            else
                r = 2r
            end
        end
        r = min(max(r, 2), n / 4)
    end
    trace
end

struct ea1p1 <: AbstractEA
    mutation::Mutation
    stop::AbstractStop
    name::LaTeXString
    function ea1p1(;
        stop::AbstractStop = FixedBudget(1000),
        mutation::Mutation = UniformlyIndependentMutation(0.5),
        name::LaTeXString = L"(1+1)EA",
    )
        new(mutation, stop, name)
    end
end

function optimize(x, setting::ea1p1)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    # bitrand returns a random bit string.

    for iter ∈ 1:niterations(setting.stop)
        # println("Enters")

        y = mutation(x, setting.mutation)

        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) ≥ fitness(x)
            if fitness(y) > fitness(x)
                # println(fitness(y))
                record(trace, y, iter, isoptimum(y))
            end
            x = y

            if isoptimum(x)
                # println("Optimum found")
                return trace
            end
        end
    end
    # println("Finished")
    trace
end

struct ea1p1SD <: AbstractEA
    R::Real
    stop::AbstractStop
    thresholds::Array
    name::LaTeXString
    function ea1p1SD(;
        R::Real = 1,
        stop::AbstractStop = FixedBudget(1000),
        thresholds = [typemax(Int) for _ = 1:10],
        name::LaTeXString = name=L"SD-(1+1)EA"
    )
        new(R, stop, thresholds, name)
    end
end



SDCounter(n::Integer, r::Real, R::Real) =
    (n / r)^r * (n / (n - r))^(n - r) * log(Base.MathConstants.e * n * R)
SDCounterEstimation(n::Integer, r::Real, R::Real) =
    (Base.MathConstants.e * n / r)^r * log(Base.MathConstants.e * n * R)

function threshold_gen(generator::Function, n::Integer, R::Real)
    thresh = []
    for r = 1:ceil(Integer, n)
        val = generator(n, r, R)
        push!(thresh, val)
        if val >= typemax(Int) / n
            break
        end
    end
    thresh
end

function optimize(x, setting::ea1p1SD)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    thresholds = setting.thresholds
    r = 1
    u = 0
    for iter ∈ 1:niterations(setting.stop)
        y = mutation(x, UniformlyIndependentMutation(r // n))
        u += 1
        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) > fitness(x)
            x = y
            u = 0
            r = 1
            # println("New rate", r)
            # println(fitness(x), " in iteration= ", iter)
            record(trace, y, iter, isoptimum(y))
            if isoptimum(x)
                # println("The Optimum is found.")
                return trace
            end
        elseif fitness(y) == fitness(x) && r == 1
            x = y
        end

        if u > thresholds[r]
            r = min(r + 1, ceil(Integer, n / 2))
            # println("New rate", r)
            u = 0
        end
    end
    trace
end

struct ea1pλSASD <: AbstractEA
    R::Real
    λ::Integer
    stop::AbstractStop
    thresholds::Array
    function ea1pλSASD(;
        R::Real = 1,
        λ::Integer = 10,
        stop::AbstractStop = FixedBudget(1000),
        thresholds = [typemax(Int) for _ = 1:10],
    )
        new(R, λ, stop, thresholds)
    end
end

function optimize(x, setting::ea1pλSASD)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    thresholds = setting.thresholds
    λ = setting.λ
    r_init = 2
    r = r_init
    u = 0
    g = false

    for iter ∈ 1:niterations(setting.stop)
        u += 1
        if g == false
            y = copy(x)
            ry = r
            for i = 1:λ
                if i ≤ λ / 2
                    rα = r / (2n)
                    α = mutation(x, UniformlyIndependentMutation(rα))
                else
                    rα = 2r / n
                    α = mutation(x, UniformlyIndependentMutation(rα))
                end

                if fitness(α) ≥ fitness(y)
                    y = α
                    ry = rα
                end
            end
            if fitness(y) ≥ fitness(x)

                if fitness(y) > fitness(x)
                    # println("New rate $r in $g")
                    record(trace, y, iter, isoptimum(y))
                end
                x = y

                if isoptimum(x)
                    return trace
                end
            end

            if rand() < 0.5
                r = ry
            else
                r = if (rand() < 0.5)
                    r = r / 2
                else
                    r = 2r
                end
            end
            r = floor(Integer, min(max(r, 2), n / 4))

            if u > thresholds[1] / λ
                r = 2
                # println("New rate $r in $g")
                # println("STAG detection.")
                g = true
                u = 0
            end

        else
            y = copy(x)
            for i = 1:λ
                α = mutation(x, UniformlyIndependentMutation(r / n))
                if fitness(α) ≥ fitness(y)
                    y = α
                end
            end
            # The second condition is for implementing "breaking ties randomly".
            if fitness(y) > fitness(x)
                x = y
                r = r_init
                # println("New rate $r in $g")
                g = false
                u = 0
                record(trace, y, iter, isoptimum(y))
                if isoptimum(x)
                    # println("The Optimum is found.")
                    return trace
                end
            end

            if u > thresholds[r] / λ
                r = min(r + 1, ceil(Integer, n / 2))
                # println("New rate $r in $g")
                u = 0
            end
        end
    end
    trace
end



struct RLSSDstar <: AbstractEA
    R::Real
    stop::AbstractStop
    name::LaTeXString
    function RLSSDstar(;
        R::Real = 1,
        stop::AbstractStop = FixedBudget(1000),
        name::LaTeXString = L"SD-RLS^r",
    )
        new(R, stop, name)
    end
end



RLSSDCounter(n::Integer, r::Real, R::Real) = binomial(n, r) * log(R)

function optimize(x, setting::RLSSDstar)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    thresholds = threshold_gen(RLSSDCounter, n, setting.R)
    r = 1
    s = 1
    u = 0
    for iter ∈ 1:niterations(setting.stop)
        y = mutation(x, KBitFlip(s))
        u += 1
        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) > fitness(x)
            x = y
            u = 0
            r = 1
            s = 1
            record(trace, y, iter, isoptimum(y))
            if isoptimum(x)
                return trace
            end
        elseif fitness(y) == fitness(x) && s == 1
            x = y
        end

        if u > thresholds[s]
            if s == 1
                if r < n / 2
                    r = r + 1
                else
                    r = n
                end
                s = r
            else
                s = s - 1
            end
            u = 0
            # println("RLSSDstar ", r, " ", s, " ", fitness(x), isoptimum(x))
        end
    end
    trace
end


struct RLS12 <: AbstractEA
    stop::AbstractStop
    name::LaTeXString
    function RLS12(;
        stop::AbstractStop = FixedBudget(1000),
        name::LaTeXString = L"RLS^{1,2}",
    )
        new(stop, name)
    end
end

function optimize(x, setting::RLS12)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    # bitrand returns a random bit string.

    for iter ∈ 1:niterations(setting.stop)
        if rand() < 0.5
            y = mutation(x, KBitFlip(1))
        else
            y = mutation(x, KBitFlip(2))
        end

        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) ≥ fitness(x)
            if fitness(y) > fitness(x)
                record(trace, y, iter, isoptimum(y))
            end
            x = y

            if isoptimum(x)
                return trace
            end
        end
    end
    trace
end

struct RLSSDstarstar <: AbstractEA
    R::Real
    stop::AbstractStop
    name::LaTeXString
    function RLSSDstarstar(;
        R::Real = 1,
        stop::AbstractStop = FixedBudget(1000),
        name::LaTeXString = L"SD-RLS^m",
    )
        new(R, stop, name)
    end
end

function optimize(x, setting::RLSSDstarstar)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    thresholds = threshold_gen(RLSSDCounter, n, setting.R)
    r = 1
    s = 1
    u = 0
    B = typemax(Int)
    for iter ∈ 1:niterations(setting.stop)
        y = mutation(x, KBitFlip(s))
        u += 1
        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) > fitness(x)
            x = y
            r = s
            s = 1
            if r > 1
                B = u / (r - 1) * 1 / log(n)
            else
                B = typemax(Int)
            end
            u = 0
            record(trace, y, iter, isoptimum(y))
            if isoptimum(x)
                return trace
            end
        elseif fitness(y) == fitness(x) && s == 1
            x = y
        end

        if u > min(B, thresholds[s])
            if s == r
                if r < n / 2 - 1
                    r = r + 1
                else
                    r = n
                end
                s = 1
            else
                s = s + 1
                if s == r
                    B = typemax(Int)
                end
            end
            u = 0
            # println("RLSSDstarstar ", r, " ", s, " ", fitness(x))
        end
    end
    trace
end













struct fastSD <: AbstractEA
    β::Real
    γ::Real
    R::Real
    stop::AbstractStop
    name::LaTeXString
    function fastSD(;
        β::Real = 1.5,
        γ::Real = 2/3,
        R::Real = 1,
        stop::AbstractStop = FixedBudget(1000),
        name::LaTeXString = L"fast-SD",
    )
        new(β, γ, R, stop, name)
    end
end

function threshold_gen(generator::Function, n::Integer, γ::Real, R::Real)
    thresh = []
    for r = 1:ceil(Integer, n)
        val = generator(n, r, γ, R)
        push!(thresh, val)
        if val >= typemax(Int) / n
            break
        end
    end
    thresh
end

fastSDCounter(n::Integer, s::Real, γ::Real, R::Real) = binomial(n, s) * log(R) / (1-γ)

function optimize(x, setting::fastSD)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    γ = setting.γ
    β = setting.β
    thresholds = threshold_gen(fastSDCounter, n, γ, setting.R)
    r = 1
    u = 0
    for iter ∈ 1:niterations(setting.stop)
        s = r
        if rand() < γ
            if rand() ≤ 0.5
                α = discretepowerlaw(β, n-r)
                s = r + rand(α)
            else
                α = discretepowerlaw(β, max(1,r-1))
                s = r - rand(α)
            end
        end
        y = mutation(x, KBitFlip(s))
        u += 1
        if fitness(y) > fitness(x)
            x = y
            u = 0
            r = 1
            record(trace, y, iter, isoptimum(y))
            if isoptimum(x)
                return trace
            end
        elseif fitness(y) == fitness(x) && r == 1
            x = y 
        end

        if u > thresholds[r]
            r = min(r+1, floor(Integer, n/2))
            u = 0
        end
    end
    trace
end
