require! {
    $ : "node-jquery"
    fs
    async
}
(err, dirlist) <~ fs.readdir "#__dirname/../data/ezymonth/"
dirlist.sort (a, b) ->
    | a > b => 1
    | b > a => -1
    | otherwise => 0

# dirlist.length = 1

(err, days) <~ async.map dirlist, (file, cb) ->
    console.log file
    (err, data) <~ fs.readFile "#__dirname/../data/ezymonth/#file"
    data .= toString!
    $file = $ data
    $links = $file.find "a[charge-debit]"
    flights = []
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
        flights.push {day, month, price, id}
        id++

    flights.sort (a, b) ->
        | a.month - b.month => that
        | a.day - b.day => that
        | otherwise => a.id - b.id

    cb do
        null
        flights.map (.price) .join "\t"

data = days.join "\n"
<~ fs.writeFile "#__dirname/test.tsv", data
