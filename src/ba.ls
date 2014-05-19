page = require 'webpage' .create!
require! fs
require! system
setTimeout phantom.exit, 120_s * 1e3
[_, dest] = system.args
now = Date.now!
page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36"

(status) <~ page.open "http://www.britishairways.com/travel/home/public/en_cz"

saveAndQuit = ->
    html = page.evaluate -> document.documentElement.innerHTML
    page.render "BA-#{dest}-#{now}.png"
    fs.write "BA-#{dest}-#{now}.html", html, "w"
    phantom.exit!
i = 0
check = ->
    count = page.evaluate -> document.querySelectorAll ".flightList" .length
    console.log count
    if count >= 2
        <~ setTimeout saveAndQuit, 3000
    else
        setTimeout check, 1000
page.evaluate do
    *   (dest) ->
            $('#accept_ba_cookies a') .click!
            document.querySelector ('#planTripFlightDestination') .value = dest
            document.querySelector ('#depDate') .value = "11/07/14"
            document.querySelector ('#retDate') .value = "13/07/14"
            document.querySelector ('#flightSearchButton') .click!
    *   dest


check!
