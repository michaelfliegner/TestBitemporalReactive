I[![CI](https://github.com/actuarial-sciences-for-africa-asa/BitemporalReactive.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/actuarial-sciences-for-africa-asa/BitemporalReactive.jl/actions/workflows/CI.yml)

[![Documentation](https://github.com/actuarial-sciences-for-africa-asa/BitemporalReactive.jl/actions/workflows/GenDocs.yml/badge.svg)](https://github.com/actuarial-sciences-for-africa-asa/BitemporalReactive.jl/actions/workflows/GenDocs.yml)

This is a prototype reactive web app for bitemporal data management based on [a Julia bitemporal data management API](https://github.com/actuarial-sciences-for-africa-asa/BitemporalPostgres.jl) and a UI based on [Stipple](https://github.com/GenieFramework/StippleUI.jl) and [QUASAR (where Stipple did not yet provide a solution, or I didn't find one)](https://quasar.dev/). 

Architecture is [MVVM](https://012.vuejs.org/guide/)

* BitemporalReactive connects the business model to the view model and provides event handling. 
* ContractSectionView defines the view model, the UI elements, and their data bindings.
* LifeInsuranceDataModel - an imported package - provides the business model and logic

[LifeInsuranceDataModel - the Data Model of this prototype -](https://github.com/actuarial-sciences-for-africa-asa/LifeInsuranceDataModel.jl/blob/main/src/LifeInsuranceDataModel.jl) is - as of now - all about versioning of entities and relationships for a Life Insurance app - domain specific attributes will be added when calculations will come into play.
Features are: 
- populating the database 
- displaying contract versions and history

![work in progress](docs/src/assets/wip.png) To populate the database use [this notebook](populateAndTest.ipynb)


# DEMO ON GITPOD OPERATIONAL AGAIN due to Genie version 5 which allows for proxy configuration of websockets.
The following snippets do the trick - 
in the app's startup code
```
     Genie.config.websockets_port = 8001
     if (haskey(ENV, "GITPOD_REPO_ROOT"))
        Genie.config.websockets_exposed_port = 443
        Genie.config.websockets_exposed_host = "8001-$(replace(ENV["GITPOD_WORKSPACE_URL"],"https://"=> ""))"
    else
        Genie.config.websockets_exposed_port = 8001
    end
    model = handlers(Stipple.init(ContractSectionView.Model))
```
in GITPOD configuration file .gitpod.yml
```
ports:
  - name: postgres
    description: data base server
    port: 5432
    visibility: private
    onOpen: ignore

  - name: Web App
    description: The main application web server
    port: 8000
    visibility: public
    onOpen: open-browser

  - name: Web Socket
    description: Web Socket server UI synching
    port: 8001
    visibility: public
    onOpen: ignore
```

Demo: Opening this project in GITPOD using the gitpod Button on the repo page ![gitpod Button on the repo page](docs/src/assets/GitpodButton.PNG)

You get an environment with a running database populated with sample data, the Webapp running and link to open a browser window.
![Port8000Open](docs/src/assets/Port8000open.PNG)

The Browser shows the ContractSection page with Contracts Tab open and a list of one contract number.
![ContractsTab](docs/src/assets/ContractsTab.PNG)

Clicking this gives You the initial Contract Version Tab
![ContractSectionInitial](docs/src/assets/ContractSectionInitial.PNG)

Clicking the various show buttons give an expanded view of the current contract version
![ContractSectionExpanded](docs/src/assets/ContractSectionExpanded.PNG)

Clicking Contract History opens a tree view of the contract's mutation history, where mutations that were retrospectively altered by a mutation appear as subnodes of that mutation's node. Clicking a node show the respective version of the contract.
![MutationHistory](docs/src/assets/MutationHistory.PNG)


