page = require 'webpage' .create!
require! fs
require! system

[_, dest] = system.args
now = Date.now!
page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36"

(status) <~ page.open "http://www.easyjet.com/links.mvc?dep=PRG&dest=#{dest}&dd=11/7/2014&rd=13/7/2014&apax=1&pid=www.easyjet.com&cpax=0&ipax=0&lang=EN&isOneWay=off&searchFrom=SearchPod|/en"
saveAndQuit = ->
    html = page.evaluate -> document.documentElement.innerHTML
    page.render "EZY-month-#{dest}-#{now}.png"
    fs.write "EZY-month-#{dest}-#{now}.html", html, "w"
    phantom.exit!

check = ->
    count = page.evaluate -> document.querySelectorAll ".calendarViewWeek" .length
    if count >= 2
        <~ setTimeout saveAndQuit, 3000
    else
        setTimeout check, 1000
page.render "EZY-day-#{dest}-#{now}.png"
html = page.evaluate -> document.documentElement.innerHTML
fs.write "EZY-day-#{dest}-#{now}.html", html, "w"
page.evaluate -> $ '#SelectLowestFlightsTab' .click!
check!
