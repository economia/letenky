ig.TimeMatrix = class TimeMatrix
    (@element, @source) ->
        @width = 1900
        @height = 220

    load: (cb) ->
        (err, data) <~ d3.csv "../data/processed/#{@source}" @recordConstructor
        @data = data
        cb?!

    draw: (xProp = 'checkDate') ->
        console.log @data.0
        priceExtent = d3.extent @data.map (.price)
        checkExtent = d3.extent @data.map (.checkDate)
        arrivalExtent = d3.extent @data.map (.arrivalDate)
        timeDifferenceExtent = d3.extent @data.map (.timeDifference)
        diff = priceExtent.1 - priceExtent.0
        priceDomain = [0 to 9].map ->
            priceExtent.0 + diff / 9 * it
        color = d3.scale.linear!
            ..domain priceDomain
            ..range <[#ffffcc #ffeda0 #fed976 #feb24c #fd8d3c #fc4e2a #e31a1c #bd0026 #800026]>
        x = d3.scale.linear!
            ..domain checkExtent
            ..range [0 @width]
        y = d3.scale.linear!
            ..domain arrivalExtent
            ..range [0 @height]
        console.log @element
        # @data.length = 20
        @element.selectAll \div.pricepoint .data @data .enter!append \div
            ..attr \class \pricepoint
            ..style "left" -> "#{Math.round x it.checkDate}px"
            ..style "top" -> "#{Math.round y it.arrivalDate}px"
            ..style "background-color" -> color it.price
            ..attr \data-tooltip ~> "#{@formatDate it.checkDate} - #{@formatDate it.arrivalDate} : #{it.price}"
            # ..text (.price)
            #
    formatDate: ->
        "#{it.getDate!}. #{it.getMonth! + 1}."

    recordConstructor: (line) ->
        checkTime = new Date line.checkTime .getTime!
        checkTime -= checkTime % (21600*1e3)
        line.checkDate = new Date!
            ..setTime checkTime
        line.arrivalDate = new Date "#{line.arrivalTime} 12:00"
        line.price = parseFloat line.price
        line.timeDifference = line.arrivalDate.getTime! - line.checkDate.getTime!
        line
