new Tooltip!watchElements!
container = d3.select ig.containers.base
# sources = <[ l1-EZY-CDG.csv l2-EZY-CDG.csv vm-EZY-CDG.csv ]>

sources = <[ l2-TVS-CDG.csv l2-TVS-FRA.csv l1-TVS-CDG.csv ]>
# sources = <[ l1-EZY-LGW.csv ]>
sources.forEach (source) ->
    m1 = container.append \div
    server = null
    airline = null
    destination = null
    xProp = 'checkDate'
    [_, server, airline, destination] = source.match "([^-]+)-([A-Z]+)-([A-Z]+)"
    drawSelectors = (source) ->
        m1.append \select
            .on \change ->
                server := @value
                redraw!
            .selectAll \option .data <[vm l1 l2]> .enter!append \option
                ..attr \value -> it
                ..html -> it
                ..attr \selected -> if server == it then "selected" else void
        m1.append \select
            .on \change ->
                airline := @value
                redraw!
            .selectAll \option .data <[EZY CSA BA DLH TVS]> .enter!append \option
                ..attr \value -> it
                ..html -> it
                ..attr \selected -> if airline == it then "selected" else void
        destinations = switch airline
            | \EZY => <[AMS LGW CDG]>
            | \TVS => <[CDG FRA]>
            | \DLH => <[AMS LHR CDG MOW FRA]>
            | otherwise => <[AMS LHR CDG SVO FRA]>
        destinations.unshift "(vyberte)"
        m1.append \select
            .on \change ->
                destination := @value
                redraw!
            .selectAll \option .data destinations .enter!append \option
                ..attr \value -> it
                ..html -> it
                ..attr \selected -> if destination == it then "selected" else void

        m1.append \select
            .on \change ->
                xProp := @value
                redraw!
            .selectAll \option .data <[checkDate timeDifference]> .enter!append \option
                ..attr \value -> it
                ..html -> it
                ..attr \selected -> if xProp == it then "selected" else void
    redraw = ->
        tm.source = "#{server}-#{airline}-#{destination}.csv"
        console.log tm.source
        m1.html ""
        drawSelectors tm.source
        console.log tm.source
        m2.html ""
        <~ tm.load
        tm.draw xProp

    drawSelectors source
    m2 = container.append \div
        ..attr \class \graph
    tm = new ig.TimeMatrix m2, source
    <~ tm.load
    tm.draw xProp

