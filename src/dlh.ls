page = require 'webpage' .create!
require! fs
require! system
setTimeout phantom.exit, 120_s * 1e3
[_, dest] = system.args
now = Date.now!
page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36"

(status) <~ page.open "http://www.lufthansa.com/online/portal/lh/cz/homepage"

saveAndQuit = ->
    html = page.evaluate -> document.documentElement.innerHTML
    page.render "DLH-#{dest}-#{now}.png"
    fs.write "DLH-#{dest}-#{now}.html", html, "w"
    phantom.exit!

check = ->
    count = page.evaluate -> document.querySelectorAll ".wdk-results" .length
    if count >= 2
        <~ setTimeout saveAndQuit, 3000
    else
        setTimeout check, 1000
html = page.evaluate -> document.documentElement.innerHTML

page.evaluate do
    *   (dest) ->
            document.querySelector "input[value='From']"      .value = "PRG"
            document.querySelector "input[value='To']"        .value = dest
            document.querySelector "input[value='Departing']" .value = "Fr, 11.07.2014"
            document.querySelector "input[value='Returning']" .value = "Su, 13.07.2014"
            document.querySelector "input[name='date1']"      .value = "2014-07-11"
            document.querySelector "input[name='date2']"      .value = "2014-07-13"
            document.querySelector ".btnWrapper button.pi_touch" .click!
    *   dest


check!
