new Tooltip!watchElements!
container = d3.select ig.containers.base
<[ l1-EZY-LGW.csv l2-EZY-LGW.csv vm-EZY-LGW.csv ]>.forEach (source) ->
    m1 = container.append \div
        ..attr \class \graph
    tm = new ig.TimeMatrix m1, source
    <~ tm.load
    tm.draw!
