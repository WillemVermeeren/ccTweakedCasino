function main()
    local settings = require("settings")

    local monitor = peripheral.find("monitor")
    if monitor~=nil then
        term.redirect(monitor)
    end
    term.clear()
    term.setCursorPos(1, 1)

    local casinoNetwerk = peripheral.find("modem")
    casinoNetwerk.open(1)
    
    -- loads the balances from save json
    local saveFile = fs.open("/save.json", "r")
    local balances = textutils.unserialiseJSON(saveFile.readAll())
    saveFile.close()

    local profitsFile = fs.open("/machineProfits.json", "r")
    local profits = textutils.unserialiseJSON(profitsFile.readAll())
    profitsFile.close()
    -- a function for saving the balances of the user
    function save()
        local saveFile = fs.open("/save.json", "w")
        saveFile.write(textutils.serialiseJSON(balances))
        saveFile.close()

        local profitsFile = fs.open("/machineProfits.json", "w")
        profitsFile.write(textutils.serialiseJSON(profits))
        profitsFile.close()
    end

    function generateRandomUserId()
        local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
        local randomId = ""

        while randomId == "" or balances[randomId] ~= nil do 

            randomId = ""

            for i=1,20 do
                
                randomNumber = math.floor(math.random()*#characters)+1
                randomId = randomId..string.sub(characters ,randomNumber ,randomNumber )
            end
        end

        return randomId
    end

    
    

    -- main loop
    local event, side, channel, replyChannel, message, distance, request, command, userId, attributes
    while true do
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message") -- gets the commands
        

        -- gets the important info
        request = textutils.unserialiseJSON(message)

        command = request["command"]
        userId = request["userId"]
        attributes = request["attributes"]

        -- executes commands
        if command=="changeBal" then -- changes the balance
            
            if balances[userId]==nil then -- checks if user is already in database, if not he adds the person
                balances[userId]=0
            end
            if profits[tostring(replyChannel)]==nil then
                profits[tostring(replyChannel)]=0

            end
            balances[userId] = balances[userId] + attributes
            profits[tostring(replyChannel)] = profits[tostring(replyChannel)] - attributes

            casinoNetwerk.transmit(replyChannel, 1, true) --sends first a true message so the sender of the command needs to get ready to receive
            sleep(0.2)
            casinoNetwerk.transmit(replyChannel, 1, true)
            save()
            if attributes>0 then
                term.setTextColor(colors.red)
                print(" - "..userId.." won "..tostring(attributes).." chips at computer "..tostring(replyChannel))
            else
                term.setTextColor(colors.green)
                print(" - "..userId.." lost "..tostring(-attributes).." chips at computer "..tostring(replyChannel))
            end

        elseif command=="getBal" then -- returns the balance
            if balances[userId]==nil then -- if the user doesn't exist it just returns 0 as balance
                casinoNetwerk.transmit(replyChannel, 1, true) --sends first a true message so the sender of the command needs to get ready to receive
                sleep(0.2)
                casinoNetwerk.transmit(replyChannel, 1, 0)
            else
                casinoNetwerk.transmit(replyChannel, 1, true) --sends first a true message so the sender of the command needs to get ready to receive
                sleep(0.2)
                casinoNetwerk.transmit(replyChannel, 1, balances[userId])
            end
            term.setTextColor(colors.lightGray)
            print(" - computer "..tostring(replyChannel).." requested balance of "..userId)
            
        elseif command=="getChipPrice" then -- returns the value of 1 chip
            
            casinoNetwerk.transmit(replyChannel, 1, true) --sends first a true message so the sender of the command needs to get ready to receive
            sleep(0.2)
            casinoNetwerk.transmit(replyChannel, 1, chipPrice)
            
            term.setTextColor(colors.lightGray)
            print(" - computer "..tostring(replyChannel).." asked for the value of 1 chip")
        elseif command=="getWithdrawalFee" then -- returns the value of 1 chip
            
            casinoNetwerk.transmit(replyChannel, 1, true) --sends first a true message so the sender of the command needs to get ready to receive
            sleep(0.2)
            casinoNetwerk.transmit(replyChannel, 1, withdrawalFee)
            
            term.setTextColor(colors.lightGray)
            print(" - computer "..tostring(replyChannel).." asked for the withdrawal fee")
        elseif command=="getNewToken" then -- returns the value of 1 chip
            
            casinoNetwerk.transmit(replyChannel, 1, true) --sends first a true message so the sender of the command needs to get ready to receive
            sleep(0.2)
            casinoNetwerk.transmit(replyChannel, 1, generateRandomUserId())
            
            term.setTextColor(colors.lightGray)
            print(" - computer "..tostring(replyChannel).." asked for a new token")
        end

    end
end

main()


