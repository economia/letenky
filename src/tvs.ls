page = require 'webpage' .create!
require! fs
require! system
setTimeout phantom.exit, 120_s * 1e3
[_, dest] = system.args
now = Date.now!
page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36"
(status) <~ page.open "https://p1.yourairlinebooking.com/SmartWings/AirLowFareSearchExternal.do?guestTypes%5B0%5D.amount=1&guestTypes%5B0%5D.type=ADT&guestTypes%5B1%5D.amount=0&guestTypes%5B1%5D.type=CNN&guestTypes%5B2%5D.amount=0&guestTypes%5B2%5D.type=INF&inboundOption.departureDay=13&inboundOption.departureMonth=7&inboundOption.departureYear=2014&lang=en&outboundOption.departureDay=11&outboundOption.departureMonth=7&outboundOption.departureYear=2014&outboundOption.destinationLocationCode=#{dest}&outboundOption.originLocationCode=PRG&tripType=RT"
saveAndQuit = ->
    html = page.evaluate -> document.documentElement.innerHTML
    page.render "TVS-#{dest}-#{now}.png"
    fs.write "TVS-#{dest}-#{now}.html", html, "w"
    phantom.exit!

check = ->
    count = page.evaluate -> document.querySelectorAll ".resultsArea" .length

    if count == 2
        <~ setTimeout saveAndQuit, 3000
    else
        setTimeout check, 1000
check!
