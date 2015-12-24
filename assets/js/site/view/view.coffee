{div, button, h1, p} = React.DOM

HelloView = React.createClass
    getInitialState: ->
        @props.store.getViewState()

    incrementClickCount: ->
        @props.eventStream.onNext
            action: "increment_click_count"

    decrementClickCount: ->
        @props.eventStream.onNext
            action: "decrement_click_count"

    render: ->
        div null,
            div null, "Hello"

            if @state.showSavedMessage
                p {style: {color: "red"}}, "Count saved"

            div null, "You clicked #{@state.clicksCount} times"
            button
                onClick: @incrementClickCount
                "Click +1"

            button
                onClick: @decrementClickCount
                "Click -1"

