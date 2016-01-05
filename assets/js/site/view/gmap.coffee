{div, input, label, h4, span} = React.DOM

GMap = React.createClass
    render: ->
        div {},
            div {className:'wr-map'},
                div {id: 'map1', ref: 'map1'}
                div {className: 'maps-sign'}, 'FROM: ', @props.title1
            div {className:'wr-map'},
                div {id: 'map2', ref: 'map2'}
                div {className: 'maps-sign'}, 'TO: ', @props.title2

    componentDidMount: ->
        mapOptions1 = {
            center: new google.maps.LatLng(@props.lat1, @props.lon1),
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDefaultUI: true
        }
        map1 = new google.maps.Map(@refs.map1, mapOptions1);
        mapOptions2 = {
            center: new google.maps.LatLng(@props.lat2, @props.lon2),
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDefaultUI: true
        }
        map2 = new google.maps.Map(@refs.map2, mapOptions2);

GPath = React.createClass
    render: ->
        div {className: 'wr-map'},
            div {id: 'map3', ref: 'map3'}
            div {className: 'maps-sign'}, 'PACKAGE ROUTE'

    componentDidMount: ->
        mapCanvas3 = @refs.map3
        mapOptions3 = {
            center: new google.maps.LatLng(@props.lat1,@props.lon1),
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        }
        map3 = new google.maps.Map(mapCanvas3, mapOptions3)
        
        rendererOptions = {map: map3};
        directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions)
        request = {
            origin: new google.maps.LatLng(@props.lat1, @props.lon1),
            destination: new google.maps.LatLng(@props.lat2, @props.lon2),
            travelMode:google.maps.DirectionsTravelMode.DRIVING
        };
        directionsService = new google.maps.DirectionsService()
        directionsService.route(request, (response, status) ->
            if (status == google.maps.DirectionsStatus.OK)
                directionsDisplay.setDirections(response)
        );
        
