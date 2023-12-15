-- peripheral and logic stuff
local monitor = peripheral.find("monitor")
local vault = peripheral.wrap("storagedrawers:standard_drawers_1_0")
local counter = peripheral.wrap("minecraft:barrel_2")
local drive = peripheral.find("drive")


local casinoNetwerk = peripheral.find("modem")
casinoNetwerk.open(os.getComputerID())

local monitorWidth, monitorHeight = monitor.getSize()
-- important vars
local state = "idleScreen"
local userId, balance, chipValue

-- loading stuff



term.redirect(monitor)
term.clear()
monitor.setTextScale(1)


local numbers = {
    ["0"] = paintutils.loadImage("graphics/numbers/0.nfp"),
    ["1"] = paintutils.loadImage("graphics/numbers/1.nfp"), -- i know you could clean this up with a for loop but I like it this way
    ["2"] = paintutils.loadImage("graphics/numbers/2.nfp"),
    ["3"] = paintutils.loadImage("graphics/numbers/3.nfp"),
    ["4"] = paintutils.loadImage("graphics/numbers/4.nfp"),
    ["5"] = paintutils.loadImage("graphics/numbers/5.nfp"),
    ["6"] = paintutils.loadImage("graphics/numbers/6.nfp"),
    ["7"] = paintutils.loadImage("graphics/numbers/7.nfp"),
    ["8"] = paintutils.loadImage("graphics/numbers/8.nfp"),
    ["9"] = paintutils.loadImage("graphics/numbers/9.nfp")
}



-- interface stuff --
function changeBalance(amount, userId)
    function sendCommandLoop()
        while true do
            casinoNetwerk.transmit(1, os.getComputerID(), textutils.serialiseJSON({["command"]="changeBal", ["userId"]=userId, ["attributes"]=amount}))
            sleep(0.5)
        end
    end

    function receiveConfirmation()
        os.pullEvent("modem_message")
    end

    parallel.waitForAny(sendCommandLoop, receiveConfirmation)
    
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    disk.setLabel(peripheral.getName(drive), tostring(getBalance(userId)).." chips")
    return message
end

function getBalance(userId)
    function sendCommandLoop()
        while true do
            casinoNetwerk.transmit(1, os.getComputerID(), textutils.serialiseJSON({["command"]="getBal", ["userId"]=userId, ["attributes"]=nil}))
            sleep(0.5)
        end
    end

    function receiveConfirmation()
        os.pullEvent("modem_message")
    end

    parallel.waitForAny(sendCommandLoop, receiveConfirmation)
    
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    return tonumber(message)
end

function getChipPrice()
    function sendCommandLoop()
        while true do
            casinoNetwerk.transmit(1, os.getComputerID(), textutils.serialiseJSON({["command"]="getChipPrice", ["userId"]=nil, ["attributes"]=nil}))
            sleep(0.5)
        end
    end

    function receiveConfirmation()
        os.pullEvent("modem_message")
    end

    parallel.waitForAny(sendCommandLoop, receiveConfirmation)
    
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    return tonumber(message)

end

function getWithdrawalFee()
    function sendCommandLoop()
        while true do
            casinoNetwerk.transmit(1, os.getComputerID(), textutils.serialiseJSON({["command"]="getWithdrawalFee", ["userId"]=nil, ["attributes"]=nil}))
            sleep(0.5)
        end
    end

    function receiveConfirmation()
        os.pullEvent("modem_message")
    end

    parallel.waitForAny(sendCommandLoop, receiveConfirmation)
    
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    return tonumber(message)

end

function getNewToken()
    function sendCommandLoop()
        while true do
            casinoNetwerk.transmit(1, os.getComputerID(), textutils.serialiseJSON({["command"]="getNewToken"}))
            sleep(0.5)
        end
    end

    function receiveConfirmation()
        os.pullEvent("modem_message")
    end

    parallel.waitForAny(sendCommandLoop, receiveConfirmation)
    
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    return message

end


-- main --

function waitForDisk() 
    while true do
        if fs.exists("disk/id") then
            local file = fs.open("disk/id", "r")
            userId = file.readAll()
            file.close()
            return userId
        elseif fs.exists("disk/") then
            local userId = getNewToken()
            local file = fs.open("disk/id", "w")
            file.write(userId)
            file.close()
        end
        sleep(0.5)
    end
end

function cardChecker()
    local playerPresent = 0
    while true do
        
        
        if not fs.exists("disk") then
            state = "idleScreen"
            return
        end

        sleep(0.1)
    end
end



function pay(adress, value, comment)
    
    return succes
end



while true do
    if state=="idleScreen" then
        userId = nil
        balance = 0

        term.setBackgroundColor(colors.black)
        term.clear()

        term.setCursorPos(3, 3)
        term.write("welcome to casino fortuna")

        term.setCursorPos(6, 10)
        term.write("Please insert disk")
        term.setCursorPos(10, 11)
        term.write("to proceed.")

        userId = waitForDisk()
        state = "menuScreen"
    end
    if state=="menuScreen" then
        balance = getBalance(userId)

        term.setBackgroundColor(colors.black)
        term.clear()



        term.setCursorPos(6, 1)
        term.write("Your current have")

        term.setBackgroundColor(colors.gray)
        paintutils.drawLine(1, 2, monitorWidth, 2, colors.gray)
        term.setCursorPos((monitorWidth-#tostring(balance))/2, 2)
        term.write(tostring(balance))

        term.setCursorPos(12, 3)
        term.setBackgroundColor(colors.black)
        term.write("chips")

        paintutils.drawFilledBox(4, 5, monitorWidth-3, 7, colors.green)
        term.setCursorPos(11, 6)
        term.write("buy chips")

        paintutils.drawFilledBox(4, 9, monitorWidth-3, 11, colors.red)
        term.setCursorPos(9, 10)
        term.write("deposit chips")
        
        function menu()
            while true do
                local event, side, x, y = os.pullEvent("monitor_touch")
                if x>=4 and x<=monitorWidth-3 then
                    if y>=5 and y<=7 then
                        state="deposit"
                        return
                    elseif y>=9 and y<=11 then
                        state="withdraw"
                        return
                    end

                end

            end
        end

        

        parallel.waitForAny(cardChecker, menu)

    end
    if state=="deposit" then
        chipValue = getChipPrice()

        term.setBackgroundColor(colors.black)
        term.clear()

        

        paintutils.drawLine(1, 3, monitorWidth, 3, colors.gray)
        term.setCursorPos(2, 3)
        term.setTextColor(colors.white)
        term.write(tostring(chipValue)..' diamond   -->   1 chip')

        term.setBackgroundColor(colors.black)
        term.setCursorPos(5, 5)
        term.write("insert in barrel -->")

        paintutils.drawFilledBox(4, 9, monitorWidth-3, 11, colors.red)
        term.setCursorPos(12, 10)
        term.write("return")
        
        function checkReturnButton()
            while true do

                local event, side, x, y = os.pullEvent("monitor_touch")
                if x>=4 and x<=monitorWidth-3 and y>=9 and y<=11 then
                    state="menuScreen"
                    return

                end
                sleep(0.2)
            end

        end

        function depositDiamonds()
            while true do 
                for i=1,27 do
                    local subtracted = counter.pushItems(peripheral.getName(vault), i)
                    if subtracted>0 then
                        changeBalance(subtracted/chipValue, userId)
                    end
                end
                sleep(0.5)
            end	
        end

        parallel.waitForAny(cardChecker, checkReturnButton, depositDiamonds)
    end
    if state=="withdraw" then
        local depositConfirmation = false
        local diamondValue = 0


        local chipValue = getChipPrice()
        local withdrawalFee = getWithdrawalFee()

        local maxDeposit = getBalance(userId)*chipValue
        local depositValue = diamondValue/chipValue

        term.setBackgroundColor(colors.black)
        term.clear()

        term.setBackgroundColor(colors.green)
        term.setTextColor(colors.white)

        term.setCursorPos(2, 2)
        term.write("+1  ")

        term.setCursorPos(2, 4)
        term.write("+10 ")

        term.setCursorPos(2, 6)
        term.write("+100")

        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)

        term.setCursorPos(monitorWidth-4, 2)
        term.write("-1  ")

        term.setCursorPos(monitorWidth-4, 4)
        term.write("-10 ")

        term.setCursorPos(monitorWidth-4, 6)
        term.write("-100")
        
        paintutils.drawFilledBox(2, 9, monitorWidth/2-1, 11, colors.green)
        term.setCursorPos(4, 10)
        term.write("deposit")

        paintutils.drawFilledBox(monitorWidth/2+2, 9, monitorWidth-1, 11, colors.red)
        term.setCursorPos(monitorWidth/2+5, 10)
        term.write("return")
        

        paintutils.drawFilledBox(6, 1, monitorWidth-5, 8, colors.black)
        term.setCursorPos(monitorWidth/2-(#tostring(depositValue)+#" chips")/2, 3)
        term.write(tostring(depositValue).." chips")

        term.setCursorPos(monitorWidth/2, 4)
        term.write("V")

        term.setCursorPos(monitorWidth/2-(#tostring(diamondValue)+#" krist")/2, 5)
        term.write(tostring(diamondValue).." diamonds")
        function menu()
            while true do

                local event, side, x, y = os.pullEvent("monitor_touch")
                if x>=monitorWidth/2+2 and x<=monitorWidth-1 and y>=9 and y<=11 then
                    state="menuScreen"
                    return
                elseif x>=2 and x<=monitorWidth/2-1 and y>=9 and y<=11 then
                    if diamondValue>0 then
                        depositConfirmation = true
                        depositValue = diamondValue/chipValue
                    end
                    state="menuScreen"
                    return
                elseif x>=2 and x<=5 then
                    if y==2 then
                        diamondValue=diamondValue+1
                    elseif y==4 then
                        diamondValue=diamondValue+10
                    elseif y==6 then
                        diamondValue=diamondValue+100
                    end
                elseif x>=monitorWidth-4 and x<=monitorWidth-1 then
                    if y==2 then
                        diamondValue=diamondValue-1
                    elseif y==4 then
                        diamondValue=diamondValue-10
                    elseif y==6 then
                        diamondValue=diamondValue-100
                    end
                end

                if diamondValue>maxDeposit then
                    diamondValue=maxDeposit

                elseif diamondValue<0 then
                    diamondValue=0
                end

                depositValue = diamondValue/chipValue

                paintutils.drawFilledBox(6, 1, monitorWidth-5, 8, colors.black)
                term.setCursorPos(monitorWidth/2-(#tostring(depositValue)+#" chips")/2, 3)
                term.write(tostring(depositValue).." chips")

                term.setCursorPos(monitorWidth/2, 4)
                term.write("V")

                term.setCursorPos(monitorWidth/2-(#tostring(diamondValue)+#" krist")/2, 5)
                term.write(tostring(diamondValue).." diamonds")

            end

        end

        parallel.waitForAny(cardChecker, menu)

        
        if depositConfirmation then
            local withdrawalPayement = math.ceil(diamondValue*withdrawalFee)
            changeBalance(-withdrawalPayement, userId)

            diamondValue = diamondValue-withdrawalPayement
            
            while diamondValue>0 do
                
                local subtracted = vault.pushItems(peripheral.getName(counter), 2, diamondValue)
                changeBalance(-subtracted/chipValue, userId)
                diamondValue = diamondValue - subtracted

                if subtracted ==0 then
                    break
                end
            end
            
        end
    end
    sleep(0.1)
end


    





