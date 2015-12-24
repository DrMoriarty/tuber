#Rx = require 'rx'
#React = require 'react'
HelloViewFactory = React.createFactory(HelloView)
#HelloStorage = require './storage'
#dispatchActions = require './dispatcher'


initApp = (mountNode) ->
    eventStream = new Rx.Subject()
    store = new HelloStorage()
    view = ReactDOM.render HelloViewFactory({eventStream, store}), mountNode
    dispatchActions(view, eventStream, store)

$(document).ready ->
    initApp(document.getElementById('hello_container'));
