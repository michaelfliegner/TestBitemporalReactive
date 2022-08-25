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

Genie.isrunning(:webserver) || up()