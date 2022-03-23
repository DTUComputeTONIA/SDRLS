using Logging

logger = SimpleLogger(stdout, Logging.Info)
global_logger(logger)

println("HELLO from ", ENV["SERVER_ID"])

server_id = parse(Int64, ENV["SERVER_ID"])

using Pkg
Pkg.activate(".")
Pkg.offline()

using Pidoh
# using SparseArrays


experiment = loadexperiment("./data.jld2")
run(experiment, server_id)
