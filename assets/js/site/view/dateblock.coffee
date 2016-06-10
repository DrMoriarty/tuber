{div, input, label, h4, span} = React.DOM

DateBlock = React.createClass
    getInitialState: ->
        pickupDate: ''
        arriveDate: ''

    pdm1Click: (data) ->
        pickupDate = moment(@props.pdate).subtract(1, 'd').format('DD MMMM YYYY')
        @setState
            pickupDate: pickupDate

    pdp1Click: (data) ->    
        pickupDate = moment(@props.pdate).add(1, 'd').format('DD MMMM YYYY')
        @setState
            pickupDate: pickupDate

    pdp2Click: (data) ->    
        pickupDate = moment(@props.pdate).add(2, 'd').format('DD MMMM YYYY')
        @setState
            pickupDate: pickupDate

    adm1Click: (data) ->
        arriveDate = moment(@props.adate).subtract(1, 'd').format('DD MMMM YYYY')
        @setState
            arriveDate: arriveDate

    adp1Click: (data) ->    
        arriveDate = moment(@props.adate).add(1, 'd').format('DD MMMM YYYY')
        @setState
            arriveDate: arriveDate

    adp2Click: (data) ->    
        arriveDate = moment(@props.adate).add(2, 'd').format('DD MMMM YYYY')
        @setState
            arriveDate: arriveDate

    render: ->
        div {className: 'confirmation-delivery'},
            input {id: 'day_before', type: 'radio', name: 'pdate', onClick: @pdm1Click}
            label {htmlFor: 'day_before'}, 'day earlier'
            input {id: 'pd_p1', type: 'radio', name: 'pdate', onClick: @pdp1Click}
            label {htmlFor: 'pd_p1'}, 'day later'
            input {id: 'pd_p2', type: 'radio', name: 'pdate', onClick: @pdp2Click}
            label {htmlFor: 'pd_p2'}, 'two days later'
            div {className: 'confirmation-calendar'},
                input {className:'js-datetime', name:'pickupDate', type: 'text', value: @state.pickupDate}
                div {id: 'datePicker1', className: 'confirmation-calendar-body js-datetime-body hide'},
                    h4 {}, 'Your check in Date'
            span {className: 'span_to'}, ' to '
            div {className: 'confirmation-calendar'},
                input {className:'js-datetime', name:'arriveDate', type: 'text', value: @state.arriveDate}
                div {id: 'datePicker2', className: 'confirmation-calendar-body js-datetime-body hide'},
                    h4 {}, 'Your check in Date'
            input {id: 'ad_m1', type: 'radio', name: 'adate', onClick: @adm1Click}
            label {htmlFor: 'ad_m1'}, 'day earlier'
            input {id: 'ad_p1', type: 'radio', name: 'adate', onClick: @adp1Click}
            label {htmlFor: 'ad_p1'}, 'day later'
            input {id: '2days_later2', type: 'radio', name: 'adate', onClick: @adp2Click}
            label {htmlFor: '2days_later2'}, 'two days later'

    componentDidUpdate: (oldProps, oldState) ->
        if oldProps.pdate != @props.pdate or oldProps.adate != @props.adate
            setTimeout(
                @update
                100
            )

    componentDidMount: ->
        setTimeout(
            @update
            100
        )

    update: ->
        pickupDate = moment(@props.pdate).format('DD MMMM YYYY')
        arriveDate = moment(@props.adate).format('DD MMMM YYYY')
        console.log 'Dates', @props.pdate, @props.adate, pickupDate, arriveDate
        @setState
            pickupDate: pickupDate
            arriveDate: arriveDate
