led_pin = 4
function set_led(state)
    if state ~= nil then
        if state then
            gpio.write(led_pin, gpio.LOW)
        else
            gpio.write(led_pin, gpio.HIGH)
        end
    end
end

function startup()
    set_led(false)
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")

        -- the actual application is stored in 'application.lua'
        if file.exists("application.lua") then
            dofile("application.lua")
        end
    end
end

function start_application()
  set_led(true)
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
end

gpio.mode(led_pin, gpio.OUTPUT)

start_application()
