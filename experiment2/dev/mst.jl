using Pidoh
using Graphs, SimpleWeightedGraphs
using Plots, DataFrames, PlotThemes, Statistics, DataFrames, LaTeXStrings
using StatsPlots


function create_experiment_TG(workspace, rep)
    algorithms :: Array{Any, 1} = []
    ins::Array{Instance, 1} = []
    for n in repeat([ 24, 36, 48,60],rep)
    # for n in repeat([ 10, 20],rep)
        mst = MST(TG(n))
        m = ne(mst.g)
        append!(algorithms, [
                RLSSDstar(stop=FixedBudget(10^9) , R=m^5, name=L"SD-RLS$^r$"),
                # RLSSDstarstar(stop=FixedBudget(10^9), R=m^4),
                ea1p1(stop=FixedBudget(10^9), mutation=UniformlyIndependentMutation(1/m), name = LaTeXString("(1+1)EA")),
                ea1p1(stop=FixedBudget(10^9), mutation=HeavyTailedMutation(1.5,m), name=L"(1+1)FEA$_{\beta}, \beta=1.5$"),
                RLS12(stop=FixedBudget(10^9), name=L"RLS$^{1,2}$"),
                ]
                )
        append!(ins, [Instance(mst, generator=RandBitStringIP(m), name=L"TG") for i in 1:4])
    end

    Experiment(workspace, Array{AbstractAlgorithm}(algorithms), ins, repeat=1)
end

function create_experiment_ER(workspace, rep)
    algorithms :: Array{Any, 1} = []
    ins::Array{Instance, 1} = []
    for n in repeat([40, 60,80,100], rep)
    # for n in repeat([10, 20, 30, 40], rep)
        mst = MST(ER(n))
        m = ne(mst.g)
        append!(algorithms, [
                RLSSDstar(stop=FixedBudget(10^9) , R=m^5, name=L"SD-RLS$^r$"),
                # RLSSDstarstar(stop=FixedBudget(10^9), R=m^4),
                ea1p1(stop=FixedBudget(10^9), mutation=UniformlyIndependentMutation(1/m), name = LaTeXString("(1+1)EA")),
                ea1p1(stop=FixedBudget(10^9), mutation=HeavyTailedMutation(1.5,m), name=L"(1+1)FEA$_{\beta}, \beta=1.5$"),
                RLS12(stop=FixedBudget(10^9), name=L"RLS$^{1,2}$"),
                ]
                )
        append!(ins, [Instance(mst, generator=RandBitStringIP(m), name=L"ER") for i in 1:4])
    end

    Experiment(workspace, Array{AbstractAlgorithm}(algorithms), ins, repeat=1)
end


exp_er = create_experiment_ER("ecj/er_ecj", 400)
exp_tg = create_experiment_TG("ecj/tg_ecj", 400)

run(exp_er)

run(exp_tg)

data_er = runtimes(exp_er)
data_tg = runtimes(exp_tg)

show(data, allcols=true)
data.ProblemParam_g

categories = :algorithm
xdata = :ProblemParam_g_weights_n
ydata = :runtime
data = data_tg

Plots.PyPlotBackend()


Plots.font("DejaVu")


begin
    sort!(data, :algorithm, rev=false)
    plt = plot()
    for cat in keys(groupby(data, categories))
        filtered_data = filter(row -> row[categories]==cat[1], data)
        aggregated_data = combine(groupby(filtered_data, xdata), ydata .=> [mean,std])
        label = L"^"*cat[1]
        plot!(plt, aggregated_data[!,1], aggregated_data[!,2], fillalpha=0.5, dpi=500,
            linewidth = 2,
            markersize=3, markershape=:circle,linealpha = 0.5, size=(320,320), yscale=:log10,
            label = label, xlabel=L"Number of vertices $(n)$", ylabel=string("Fitness function calls"), 
            legend= :bottomright,
            xticks = unique(data.ProblemParam_g_weights_n)
        )
    end
    # savefig(plt, "er_line.png")
    savefig(plt, "tg_line.png")
    plt
end

begin
    sort!(data, :runtime, rev=false)
    boxplt = plot()
    groupedboxplot!(boxplt,  data.ProblemParam_g_weights_n , data.runtime, group = L"^".*data.AlgorithmParams_name_s, bar_width = 0.8,
    yscale=:log10,xlabel=L"Number of vertices $(n)$", ylabel=string("Fitness function calls"),
    fillalpha=1, dpi=500, linewidth = 1.2,
     size=(320,320),outliers=false, legend= :bottomright)
    #  savefig(boxplt, "er_box.png")
    savefig(boxplt, "tg_box.png")
    boxplt
end



string.(data.AlgorithmParams_name_s)
