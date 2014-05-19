page = require 'webpage' .create!
require! fs
require! system
[_, dest] = system.args
now = Date.now!
page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36"
(status) <~ page.open "http://www.csa.cz/cs/external_shared/ext_link_booking.htm?next=1&cabinPreference=&password=1&PRICER_PREF=FRP&AIRLINES=ok&ID_LOCATION=CZ&JOURNEY_TYPE=RT&DEP_0=PRG&ARR_0=#{dest}&DEP_1=&ARR_1=&DAY_0=11&MONTH_SEL_0=7%2F2014&DAY_1=13&MONTH_SEL_1=7%2F2014&ADTCOUNT=1&CHDCOUNT=0&INFCOUNT=0"
saveAndQuit = ->
    html = page.evaluate -> document.documentElement.innerHTML
    page.render "CSA-#{dest}-#{now}.png"
    fs.write "CSA-#{dest}-#{now}.html", html, "w"
    phantom.exit!

increases = 0
lastCount = 0
check = ->
    count = page.evaluate -> document.querySelectorAll ".flight" .length
    if count > lastCount
        ++increases
        lastCount := count

    if increases > 1
        <~ setTimeout saveAndQuit, 3000
    else
        setTimeout check, 1000
check!
