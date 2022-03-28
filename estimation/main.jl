using Plots
using Random
using Distributions
using LaTeXStrings

global e = Base.MathConstants.e

function estimation(counter, n, m, R)
    est = zero(BigInt)
    for i in 1:m
        est += counter(n, i, R)
    end
    est
end

function sd1(n, m, R)
    est = zero(BigInt)
    for r in 1:m-1
        est += 2*(e*n/r)^r*log(R)
    end
    est += (e*n/m)^m
    return est
end



function sd2(n, m, R)
    return big((n/m))^m * big((n/(n-m)))^(n-m) * log(e*n*R)
end


function sd3(n, m, R)
    est = zero(BigInt)
    for r in 1:m-1
        est += binomial(BigInt(n), floor(Int,r))*log(R)
    end
    est += binomial(BigInt(n), floor(Int,m))
    return est
end

function sd4(n, m, R)
    est = zero(BigInt)
    for r in 1:m-1
        for s in 1:r
            est += binomial(BigInt(n), floor(Int,s))*log(R)
        end
    end
    for s in 1:m-1
        est += binomial(BigInt(n), floor(Int,s))*log(R)
    end
    est += binomial(BigInt(n), floor(Int,m))
end

Plots.font("DejaVu")
Plots.PyPlotBackend()
function fullestimation(n, maxn)
    R = n^(5)

    yticks = ([n, binomial(BigInt(n), BigInt(sqrt(n))), binomial(BigInt(n), BigInt(n/2)) ],
    [L"n", L"\binom{\!\!n\!\!}{\!\!\sqrt{n}\!\!}" , L"\binom{\!\!n\!\!}{\!\!n/2\!\!}"])
    sd1data = [estimation(sd1, n, m, R) for m in 1:maxn]
    sd3data = [estimation(sd3, n, m, R) for m in 1:maxn]
    sd4data = [sd4(n, m, R) for m in 1:maxn]
    plt = plot(sd1data, yaxis=:log10, label=L"$T_1$  (SD-(1+1)EA)", size=(320,320), linestyle=:solid, dpi=500,
    legend=:bottomright, yticks=yticks, ylims=(1, Inf), 
    xticks=([log(n), sqrt(n), n/4,n/2], [L"\ln n",L"\sqrt{n}", L"n/4" ,L"n/2"]),
    # xticks=([log(n), 1.5sqrt(n), n/4,n/2], [L"\ln n",L"\sqrt{n}", L"n/4" ,L"n/2"]),
    xlabel=L"m", ylabel=L"T_i(m)")
    plt = plot!(sd3data,  label=L"$T_2$  (SD-RLS$^p$)", linestyle=:dashdot)
    plt = plot!(sd4data, label=L"$T_3$  (SD-RLS$^r$)", linestyle=:dash)
    plt
end



plt = fullestimation(500, 250)
savefig(plt, "./estimation-large.png")

plt = fullestimation(500, 25)
savefig(plt, "./estimation-small.png")
