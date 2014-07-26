require! {
    $ : "node-jquery"
    fs
    async
}
destinations = <[ SVO]>

server = "vm" && "l1" && "l2"
console.log server
basedir = "#__dirname/../../data/#server"

(err, files) <~ fs.readdir basedir
files .= filter ->
    suffix = it.substr -4
    return false if suffix isnt "html"
    airline = it.substr 0 3
    return false if airline isnt "CSA"
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
    <~ async.eachSeries destinationFiles, (file, cb) ->
        console.log file
        [_, _, time] = file.replace ".html" "" .split "-"
        fromDate = new Date!
            ..setTime time
        fromDateString = "#{fromDate.getFullYear!}-#{fromDate.getUTCMonth! + 1}-#{fromDate.getUTCDate!} #{fromDate.getUTCHours!}:#{fromDate.getUTCMinutes!}"
        (err, data) <~ fs.readFile "#basedir/#file"
        data .= toString!
        $file = $ data
        $links = $file.find '#calendarContainer0 a .price'
        $links.map ->
            $e = $ @
            toDateString = $e.find "input" .val() .split "|" .pop!
            price = parseFloat $e.text!replace ' ' ''
            flights.push "#fromDateString,#toDateString,#price"

        flights.sort (a, b) ->
            | a.month - b.month => that
            | a.day - b.day => that
            | otherwise => a.id - b.id

        cb do
            null
            flights.map (.price) .join "\t"
    lines = "checkTime,arrivalTime,price\n" + flights.join "\n"
    <~ fs.writeFile "#__dirname/../../data/processed/#{server}-CSA-#destination.csv", lines
    cb!
