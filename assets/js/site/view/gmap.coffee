{div, input, label, h4, span} = React.DOM

GMap = React.createClass
    render: ->
        div {},
            div {className:'wr-map'},
                div {id: 'map1', ref: 'map1'}
                div {className: 'maps-sign'}, @props.labelFrom, '  ', @props.title1
            div {className:'wr-map'},
                div {id: 'map2', ref: 'map2'}
                div {className: 'maps-sign'}, @props.labelTo, '  ', @props.title2

    componentDidMount: ->
        p1 = new google.maps.LatLng(@props.lat1, @props.lon1)
        mapOptions1 = {
            center: p1,
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDefaultUI: true
        }
        map1 = new google.maps.Map(@refs.map1, mapOptions1);
        window.marker1 = new google.maps.Marker
            position: p1
            map: map1
        p2 = new google.maps.LatLng(@props.lat2, @props.lon2)
        mapOptions2 = {
            center: p2,
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDefaultUI: true
        }
        map2 = new google.maps.Map(@refs.map2, mapOptions2);
        window.marker2 = new google.maps.Marker
            position: p2
            map: map2

GPath = React.createClass
    render: ->
        div {className: 'wr-map'},
            div {id: 'map3', ref: 'map3'}
            div {className: 'maps-sign'}, @props.labelRoute

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

        radius = parseInt(@props.radius3) * 1000
        """
        mapCircle = new google.maps.Circle {
            strokeColor: '#FF0000'
            strokeOpacity: 0.8
            strokeWeight: 2
            fillColor: '#FF0000'
            fillOpacity: 0.35
            map: map3
            center: {lat: @props.lat3, lng: @props.lon3},
            radius: radius
        }
        """
