using Pkg
Pkg.instantiate()

push!(LOAD_PATH,"src/")

using BitemporalReactive; BitemporalReactive.run()