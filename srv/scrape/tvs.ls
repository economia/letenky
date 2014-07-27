require! {
    $ : "node-jquery"
    fs
    async
}
destinations = <[CDG FRA]>

servers = ["vm" "l1" "l2"]
destinations = [destinations[1]]
server = servers[2]
console.log server
basedir = "#__dirname/../../data/#server"
airline = "TVS"
(err, files) <~ fs.readdir basedir
files .= filter ->
    suffix = it.substr -4
    return false if suffix isnt "html"
    airlinePart = it.substr 0 3
    return false if airlinePart isnt airline
    true

# console.log files
# return
files.sort (a, b) ->
    | a > b => 1
    | b > a => -1
    | otherwise => 0

# files.length = 1
<~ async.eachSeries destinations, (destination, cb) ->
    destinationFiles = files.filter -> destination == it.substr 4, 3
    # destinationFiles.length = 1
    flights = []
    i = 0
    len = destinationFiles.length
    (err, data) <~ fs.readFile "#__dirname/../../data/temp/#{server}-#{airline}-#{destination}.json"
    if not err && data
        flights := JSON.parse data
    (err, data) <~ fs.readFile "#__dirname/../../data/temp/#{server}-#{airline}-#{destination}-filesDone"
    if not err && data
        i := parseInt data.toString!
        destinationFiles .= slice i

    <~ async.eachSeries destinationFiles, (file, cb) ->
        console.log server, file, i++, len
        [_, _, time] = file.replace ".html" "" .split "-"
        fromDate = new Date!
            ..setTime time
        fromDateString = "#{fromDate.getFullYear!}-#{fromDate.getUTCMonth! + 1}-#{fromDate.getUTCDate!} #{fromDate.getUTCHours!}:#{fromDate.getUTCMinutes!}"
        (err, data) <~ fs.readFile "#basedir/#file"
        data .= toString!
        $file = $ data
        $links = $file.find '#bodyBlock_0 table.tabsTable td'
        $links.map ->
            $e = $ @
            date = $e.find ".date" .text!
            [_, day, month] = date.split " "
            toDateString = "2014-07-#{day}"
            priceString = $e.find '.price' .text!replace "CZK " "" .replace "," ""
            price = parseFloat priceString
            # console.log "#fromDateString,#toDateString,#price"
            flights.push "#fromDateString,#toDateString,#price"

        flights.sort (a, b) ->
            | a.month - b.month => that
            | a.day - b.day => that
            | otherwise => a.id - b.id
        temp = JSON.stringify flights
        console.log 'writing now'
        <~ fs.writeFile "#__dirname/../../data/temp/#{server}-#{airline}-#{destination}.json", temp
        <~ fs.writeFile "#__dirname/../../data/temp/#{server}-#{airline}-#{destination}-filesDone", i
        console.log 'wrote'
        cb do
            null
            flights.map (.price) .join "\t"
    lines = "checkTime,arrivalTime,price\n" + flights.join "\n"
    <~ fs.writeFile "#__dirname/../../data/processed/#{server}-#{airline}-#{destination}.csv", lines
    cb!
