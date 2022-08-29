push!(LOAD_PATH,"src/")

using Pkg
Pkg.instantiate()

using BitemporalReactive; BitemporalReactive.run()