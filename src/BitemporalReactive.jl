module BitemporalReactive
using BitemporalPostgres, JSON, SearchLight, Stipple, StippleUI, TimeZones, ToStruct
using LifeInsuranceDataModel, LifeInsuranceProduct
include("ContractSectionView.jl")
using .ContractSectionView

"""
load_roles(model)

    loads role tables, that provide texts for integer role keys
"""
function load_roles(model)
    map(find(LifeInsuranceDataModel.ContractPartnerRole)) do entry
        model.rolesContractPartner[entry.id.value] = entry.value
    end
    println(model.rolesContractPartner)


    map(find(LifeInsuranceDataModel.TariffItemRole)) do entry
        model.rolesTariffItem[entry.id.value] = entry.value
    end

    map(find(LifeInsuranceDataModel.TariffItemPartnerRole)) do entry
        model.rolesTariffItemPartner[entry.id.value] = entry.value
    end

end

"""
convert(node::BitemporalPostgres.Node)::Dict{String,Any}

provides the view model for the history forest from tree data the model delivers
"""
function convert(node::BitemporalPostgres.Node)::Dict{String,Any}
    i = Dict(string(fn) => getfield(getfield(node, :interval), fn) for fn ∈ fieldnames(ValidityInterval))
    shdw = length(node.shadowed) == 0 ? [] : map(node.shadowed) do child
        convert(child)
    end
    Dict("label" => string(i["ref_version"]), "interval" => i, "children" => shdw,
        "time_committed" => string(i["tsdb_validfrom"]), "time_valid_asof" => string(i["tsworld_validfrom"]))
end

"""
fn
retrieves a history node from its label 
"""

function fn(ns::Vector{Dict{String,Any}}, lbl::String)
    for n in ns
        if (n["label"] == lbl)
            return (n)
        else
            if (length(n["children"]) > 0)
                m = fn(n["children"], lbl)
                if (typeof(m) != Nothing)
                    return m
                end
            end
        end
    end
end

"""
handlers(model)

Event handling and synching of the view model between UI and model server
"""

function handlers(model)
    on(model.selected_version) do _
        println("selected version")
        println(model.selected_version[])
        if (model.selected_version[] != "")
            node = fn(model.histo[], model.selected_version[])
            model.txn_time[] = node["interval"]["tsdb_validfrom"]
            model.ref_time[] = node["interval"]["tsworld_validfrom"]
            model.current_version[] = parse(Int, model.selected_version[])
            println(model.txn_time[])
            println(model.ref_time[])
            println(model.current_version[])
            model.ref_time[]
            model.cs = JSON.parse(JSON.json(LifeInsuranceDataModel.csection(model.current_contract.id.value, model.txn_time[], model.ref_time[])))
            model.cs["loaded"] = "true"
            model.tab = "csection"
            # ti = LifeInsuranceProduct.calculate!(model.cs["product_items"][1].tariff_items[1])
            ti = model.cs["product_items"][1]
            print("ti=")
            println(ti)
            push!(model)
        end
    end

    on(model.selected_contract_idx) do _
        println(model.selected_contract_idx[])
        println(model.contracts[model.selected_contract_idx[]+1])
        model.current_contract[] = model.contracts[model.selected_contract_idx[]+1]
        model.histo = map(convert, LifeInsuranceDataModel.history_forest(model.current_contract[].ref_history.value).shadowed)
        model.cs = JSON.parse(JSON.json(LifeInsuranceDataModel.csection(model.current_contract[].id.value, now(tz"Europe/Warsaw"), now(tz"Europe/Warsaw"))))
        model.cs["loaded"] = "true"
        model.tab[] = "csection"
        ti = model.cs["product_items"][1]["tariff_items"][1]

        print("ti=")
        println(ti)
        print("tistruct")
        println(ToStruct.tostruct(LifeInsuranceDataModel.TariffItemSection, ti))
        tistruct = ToStruct.tostruct(LifeInsuranceDataModel.TariffItemSection, ti)
        LifeInsuranceProduct.calculate!(tistruct)
        model.cs["product_items"][1]["tariff_items"][1] = JSON.parse(JSON.json(tistruct))
        push!(model)

    end

    on(model.selected_product) do _
        println("model selected ")
        println(model.selected_product[])
        if (model.selected_product[] > 0)
            model.tab[] = "product"
            model.prs = JSON.parse(JSON.json(LifeInsuranceDataModel.prsection(model.selected_product[], now(tz"UTC"), now(tz"UTC"))))
            model.selected_product[] = 0
            model.prs["loaded"] = "true"
        end
        push!(model)
    end

    on(model.tab) do _
        println(model.tab[])
        if (model.tab[] == "history")
            println("current contract")
            println(model.current_contract[])
            model.histo = map(convert, LifeInsuranceDataModel.history_forest(model.current_contract[].ref_history.value).shadowed)
            push!(model)
            println("MODEL pushed")
        end
    end

    on(model.isready) do _
        model.contracts = LifeInsuranceDataModel.get_contracts()
        model.tab[] = "contracts"
        model.cs["loaded"] = "false"
        load_roles(model)
        push!(model)
        println("model pushed")
    end
    model
end

"""
run

creating the route
"""
function run()
    if (haskey(ENV, "GITPOD_REPO_ROOT"))
        Genie.config.websockets_exposed_port = 443
        Genie.config.websockets_exposed_host = "8001-$(replace(ENV["GITPOD_WORKSPACE_URL"],"https://"=> ""))"
    else
        Genie.config.websockets_exposed_port = 8001
        Genie.config.websockets_port = 8001
        Genie.config.websockets_host = "127.0.0.1"
    end
    model = handlers(Stipple.init(ContractSectionView.Model))
    route("/ContractSection") do
        html(ContractSectionView.ui(model), context=@__MODULE__)
    end
    route("/") do
        redirect("/ContractSection")
    end
    println("huhu")
    Genie.up()
end

end
