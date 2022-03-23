using Pkg
Pkg.activate(".")
Pkg.status()
Pkg.offline()
Pkg.instantiate()

using Pidoh
mergeexperiments("./results")
