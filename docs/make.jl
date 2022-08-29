push!(LOAD_PATH, "../src/")
using Documenter
import BitemporalReactive, BitemporalReactive.ContractSectionView
makedocs(
    sitename="BitemporalReactive",
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "BitemporalReactive API" => [
            "BitemporalReactive" => "api/BitemporalReactive.md",
            "ContractSectionView" => "api/ContractSectionView.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/Actuarial-Sciences-for-Africa-ASA/BitemporalReactive.jl"
)
