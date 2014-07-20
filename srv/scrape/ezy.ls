require! {
    $ : "node-jquery"
    fs
    async
}
destinations = <[ LGW]>

server = "vm"# && "l1" #&& "l2"
console.log server
basedir = "#__dirname/../../data/#server"

(err, files) <~ fs.readdir basedir
files .= filter ->
    suffix = it.substr -4
    return false if suffix isnt "html"
    airline = it.substr 0 9
    return false if airline isnt "EZY-month"
    true

# console.log files
# return
files.sort (a, b) ->
    | a > b => 1
    | b > a => -1
    | otherwise => 0

# files.length = 1
<~ async.eachSeries destinations, (destination, cb) ->
    destinationFiles = files.filter -> destination == it.substr 10, 3
    # destinationFiles.length = 1
    flights = []
    <~ async.eachSeries destinationFiles, (file, cb) ->
        console.log file
        [_, _, _, time] = file.replace ".html" "" .split "-"
        fromDate = new Date!
            ..setTime time
        fromDateString = "#{fromDate.getFullYear!}-#{fromDate.getUTCMonth! + 1}-#{fromDate.getUTCDate!} #{fromDate.getUTCHours!}:#{fromDate.getUTCMinutes!}"
        (err, data) <~ fs.readFile "#basedir/#file"
        data .= toString!
        $file = $ data
        $links = $file.find "a[charge-debit]"
        id = 0
        $links.map ->
            $e = $ @
            date = $e.find "span.date" .html!
            price = parseFloat $e.attr \charge-debit-full
            [day, month] = date.split " "
            day = parseInt day, 10
            month = switch month
                | "Jun" => 6
                | "Jul" => 7
            toDateString = "2014-#month-#day"
            flights.push "#fromDateString,#toDateString,#price"
            id++

        flights.sort (a, b) ->
            | a.month - b.month => that
            | a.day - b.day => that
            | otherwise => a.id - b.id

        cb do
            null
            flights.map (.price) .join "\t"
    lines = "checkTime,arrivalTime,price\n" + flights.join "\n"
    <~ fs.writeFile "#__dirname/../../data/processed/#{server}-EZY-#destination.csv", lines
    cb!
