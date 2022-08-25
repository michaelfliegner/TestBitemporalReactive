using Genie.Renderer.Html, Stipple, StippleUI

Genie.config.log_requests = false

@reactive mutable struct Name <: ReactiveModel
    name::R{String} = "World!"
end

function ui(model)
    page(model, class="container",
        [
            h1([
            "Hello "
            span("", @text(:name))
        ]) p([
            "What is your name? "
            input("", placeholder="Type your name", @bind(:name))
        ])
        ]
    )
end

route("/") do
    model = Stipple.init(Name, transport=Genie.WebChannels)
    html(ui(model), context=@__MODULE__)
end

Genie.config.websockets_port = 8001
Genie.config.websockets_exposed_port = 443
Genie.config.websockets_exposed_host = "8001-$(replace(ENV["GITPOD_WORKSPACE_URL"],"https://"=> ""))"


Genie.isrunning(:webserver) || up()