-- betting math
local limits = {
    ["singles"] = 500,
    ["twelves"] = 1000,
    ["eighteens"] = 2000
}

local mulitpliers = {
    ["singles"] = 36,
    ["twelves"] = 3,
    ["eighteens"] = 2
}



local driveName = "drive_1"


--speaker
local speaker = peripheral.find("speaker")
assert(speaker~=nil, "no speaker connected =[")
-- monitor stuff
local wheelMonitor = peripheral.wrap('top')
local bettingMonitor = peripheral.wrap("back")
assert(wheelMonitor~=nil and bettingMonitor~=nil, "mopnitor setup not correct connected =[")
bettingMonitor.setTextScale(0.5)
wheelMonitor.setTextScale(0.5)

local bettingMonitorWidth, bettingMonitorHeight = bettingMonitor.getSize()
local wheelMonitorWidth, wheelMonitorHeight = wheelMonitor.getSize()
local framerate = 10
-- payementblock settings


-- wheel settings
local numberOrder = {"0", "2", "14", "35", "23", "4", "16", "33", "21", "6", "18", "31", "19", "8", "12", "29", "25", "10", "27", "00", "1", "13", "36", "24", "3", "15", "34", "22", "5", "17", "32", "20", "7", "11", "30", "26", "9", "28"}
local wheelRadius = 23

local window = "idle"

-- wheel math
local wheelCenter = {math.ceil(wheelMonitorWidth/2), math.ceil(wheelMonitorHeight/2)}
local segmentCount = #numberOrder

-- paymentVars

local userId = nil
local bets = {}
local balance = 0
local winningNumber = nil
-- network stuff
local casinoNetwerk = peripheral.wrap("front")
assert(casinoNetwerk~=nil, "no modem connected =[")
casinoNetwerk.open(os.getComputerID())

-- images
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
-- functions 
function drawWheel(wheelRadius, segmentCount, angle, center)
    -- drwas the wheel with the given radius segments agle and center
    term.redirect(wheelMonitor)

    for x=center[1]-wheelRadius*(7/5)-3,center[1]+wheelRadius*(7/5)+3 do        --draws wheel with the 5/7 pixel size in mind
        for y=center[2]-wheelRadius-3,center[2]+wheelRadius+3 do

            local centerDistanceSquared = (x*(5/7)-center[1]*(5/7))^2+(y-center[2])^2 --gets the distance thanks to pythagoras

            if centerDistanceSquared<(wheelRadius/3)^2 then -- the very center should be painted brown
                paintutils.drawPixel(x, y, colors.brown)
            
            elseif centerDistanceSquared<wheelRadius^2 then -- the wheel should be painted red and black alternating and the zeros should be green
                pixelAngle = (math.atan2(center[2]-y, x*(5/7)-center[1]*(5/7))-angle)
                if pixelAngle%math.pi <math.pi/segmentCount*2 and pixelAngle%math.pi >= 0 then
                    paintutils.drawPixel(x, y, colors.green)

                elseif pixelAngle%(2*math.pi/segmentCount*2)>math.pi/segmentCount*2 then
                    paintutils.drawPixel(x, y, colors.black)
                else
                    paintutils.drawPixel(x, y, colors.red)
                end

            elseif centerDistanceSquared < (wheelRadius+3)^2 then -- the very outer layer should be painted gray
                paintutils.drawPixel(x, y, colors.gray)
            end
        end
    end
    
    for i=1,segmentCount do -- draws numbers on the wheel
        local numberAngle = (i-1)*2*math.pi/segmentCount    + math.pi/segmentCount

        local x = math.floor((wheelRadius*7/8*math.cos(numberAngle+angle))*(7/5) + center[1]    +0.5) -- gets the coordinates again with the 5/7 pixel size in mind
        local y = math.floor(-wheelRadius*7/8*math.sin(numberAngle+angle) + center[2]   +0.5)
        
        if i==1 or i==20 then -- zeros are green
            term.setBackgroundColor(colors.green)
        elseif i%2==0 then -- bleck and red alternating
            term.setBackgroundColor(colors.black)
        else
            term.setBackgroundColor(colors.red)
        end
        term.setCursorPos(x, y)
        term.write(numberOrder[i])
    end
end

function drawBall(ballRadius, angle, center)
    term.redirect(wheelMonitor) -- draws the ball

    local x = math.floor((ballRadius*math.cos(angle))*(7/5) + center[1]) -- gets coordinates with 5/7 pixel size in mind
    local y = math.floor(-ballRadius*math.sin(angle) + center[2])

    paintutils.drawPixel(x, y, colors.white)
end

function drawBettingTable() -- a lot of paintutils commands for drawing the betting table
    term.redirect(bettingMonitor)

    bettingMonitor.setTextScale(0.5)

    term.setBackgroundColor(colors.green)
    term.clear()
    
    topLeftx = bettingMonitorWidth/2-36 -- the top left cornor where the red and black numbers start
    topLefty = 1
    


    paintutils.drawBox(topLeftx-8, topLefty, topLeftx-1, topLefty+7, colors.white) -- draws the withe rectangles for the zeros
    paintutils.drawBox(topLeftx-8, topLefty+7, topLeftx-1, topLefty+14, colors.white)

    paintutils.drawBox(topLeftx, topLefty+15, topLeftx+71, topLefty+23) -- draws the bottom white rectangle

    paintutils.drawLine(topLeftx+ 24, topLefty+15, topLeftx+ 24, topLefty+23, colors.white) -- draws the white lines in the tob half of the bottom white rectangle
    paintutils.drawLine(topLeftx+ 47, topLefty+15, topLeftx+47, topLefty+23, colors.white)

    paintutils.drawLine(topLeftx, topLefty+19, topLeftx+71, topLefty+19, colors.white)  -- draws the line going through the center of the white rectangle

    paintutils.drawLine(topLeftx+ 12, topLefty+19, topLeftx+ 12, topLefty+23, colors.white) -- does the white lines in the bottom half of the white rectangle
    paintutils.drawLine(topLeftx+ 36, topLefty+19, topLeftx+36, topLefty+23, colors.white)
    paintutils.drawLine(topLeftx+ 59, topLefty+19, topLeftx+59, topLefty+23, colors.white)

    term.setBackgroundColor(colors.green)   --draws the 00
    term.setCursorPos(topLeftx-5, topLefty+4)
    term.write("00")

    term.setCursorPos(topLeftx-5, topLefty+10)  --draws the 0
    term.write("0")

    term.setCursorPos(topLeftx+9, topLefty+17) -- draws the first 12
    term.write("first 12")

    term.setCursorPos(topLeftx+32, topLefty+17) -- draws the second 12
    term.write("second 12")

    term.setCursorPos(topLeftx+55, topLefty+17) -- draaws the third 12
    term.write("third 12")

    term.setCursorPos(topLeftx+2, topLefty+21) -- draws the 1 to 18
    term.write("1 to 18")

    term.setCursorPos(topLeftx+61, topLefty+21) -- draws the 19 to 36
    term.write("19 to 36")

    term.setCursorPos(topLeftx+14, topLefty+21) -- draws even
    term.write("even")
    
    term.setCursorPos(topLeftx+49, topLefty+21) -- draws odd
    term.write("odd")

    paintutils.drawFilledBox(topLeftx+25, topLefty+20, topLeftx+35, topLefty+22, colors.red) -- draws the red with red background
    term.setCursorPos(topLeftx+26, topLefty+21)
    term.write("red")

    paintutils.drawFilledBox(topLeftx+37, topLefty+20, topLeftx+46, topLefty+22, colors.black) -- draws the black with black background
    term.setCursorPos(topLeftx+38, topLefty+21)
    term.write("black")

    for y =0,2 do
        for x=0,11 do
            value = 3*x + 3-y
            if (value <=10 and value%2==0) or (value>10 and value<=18 and value%2==1) or (value>18 and value <=28 and value%2==0) or (value>28 and value<=36 and value%2==1) then
                paintutils.drawFilledBox(topLeftx+6*x, topLefty+5*y, topLeftx+6*x+5, topLefty+5*y+4, colors.black)
                
            else
                paintutils.drawFilledBox(topLeftx+6*x, topLefty+5*y, topLeftx+6*x+5, topLefty+5*y+4, colors.red)

            end
            term.setCursorPos(topLeftx+6*x+2, topLefty+5*y+2)
            term.write(tostring(value))
        end
    end
end

function getBalance(userId) -- gets the balance
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

function changeBalance(amount, userId) -- changes the balance
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

    disk.setLabel(driveName, tostring(getBalance(userId)).." chips")

    return message
end


while true do
    if window=="idle" then
        drawBettingTable()
        balance = 0
        function drawWheelScreen()
            term.redirect(wheelMonitor)

            wheelMonitor.setTextScale(0.5)

            term.setBackgroundColor(colors.green)
            term.clear()
            local wheelAngle = 0
            local wheelSpeed = 0.5

            while true do
                wheelAngle = wheelAngle+wheelSpeed/framerate
                drawWheel(wheelRadius, segmentCount, wheelAngle, wheelCenter)
                sleep(1/framerate)
            end
        end
        
        function waitForCard() 
            while true do
                if fs.exists("disk/id") then
                    local file = fs.open("disk/id", "r")
                    userId = file.readAll()
                    file.close()
                    window="betting"
                    return
                end
                sleep(0.5)
            end
        end

        parallel.waitForAny(drawWheelScreen, waitForCard)
    end
    if window=="betting" then
        bets = {}
        local balance = getBalance(userId)
        

        drawWheel(wheelRadius, segmentCount, 0, wheelCenter)
        term.redirect(wheelMonitor)
        
        bettingMonitor.setTextScale(0.5)

        paintutils.drawFilledBox(1, wheelMonitorHeight/2-3, wheelMonitorWidth, wheelMonitorHeight/2+13, colors.gray)
        term.setCursorPos(wheelMonitorWidth/2, wheelMonitorHeight/2-2)
        term.write("You have")

        local balanceString = tostring(balance)
        local numberWidth = #balanceString*11-2
        local startingX = wheelMonitorWidth/2-numberWidth/2

        for i=1,#balanceString do
            paintutils.drawImage(numbers[string.sub(balanceString, i, i)], startingX+(i-1)*11, wheelMonitorHeight/2)
        end
        term.setBackgroundColor(colors.gray)
        term.setCursorPos(wheelMonitorWidth/2, wheelMonitorHeight/2+12)
        term.write("chips")

        paintutils.drawBox(wheelCenter[1]-26, wheelMonitorHeight-6, wheelCenter[1]-4, wheelMonitorHeight, colors.white)
        paintutils.drawFilledBox(wheelCenter[1]-25, wheelMonitorHeight-5, wheelCenter[1]-5, wheelMonitorHeight, colors.blue)
        term.setCursorPos(wheelCenter[1]-19, wheelMonitorHeight-2)
        term.write("spin wheel")

        paintutils.drawBox(wheelCenter[1]+26, wheelMonitorHeight-6, wheelCenter[1]+4, wheelMonitorHeight, colors.white)
        paintutils.drawFilledBox(wheelCenter[1]+25, wheelMonitorHeight-5, wheelCenter[1]+5, wheelMonitorHeight, colors.red)
        term.setCursorPos(wheelCenter[1]+10, wheelMonitorHeight-2)
        term.write("reset bets")
        
        drawBettingTable()

        function getBets()
            local topLeftx = bettingMonitorWidth/2-36 -- the top left cornor where the red and black numbers start
            local topLefty = 1
            while true do
                local event, side, x, y = os.pullEvent("monitor_touch")
                local bettingSum = 0
                for key, values in pairs(bets) do
                    bettingSum=bettingSum+values
                end
                if side == peripheral.getName(wheelMonitor) then
                    if x>=wheelCenter[1]-26 and x<=wheelCenter[1]-4 and y>=wheelMonitorHeight-6 and y<=wheelMonitorHeight and bettingSum>0 then
                        window="spin"
                        speaker.playSound("entity.villager.yes")
                        return
                        
                    elseif x<=wheelCenter[1]+26 and x>=wheelCenter[1]+4 and y>=wheelMonitorHeight-6 and y<=wheelMonitorHeight then
                        bets = {}
                        drawBettingTable()
                        speaker.playSound("entity.villager.yes")
                    end

                elseif side == peripheral.getName(bettingMonitor) and bettingSum+10<=balance then
                    
                    if x>=topLeftx and y>=topLefty and y<=topLefty+14 and x<=topLeftx+71 then
                        local elementX = math.floor((x-topLeftx)/6)
                        local elementY = math.floor((y-topLefty)/5)
                        local value = tostring(3*elementX + 3-elementY)
                        if bets[value]==nil then
                            bets[value]=10
                        elseif bets[value]< limits["singles"] then
                            bets[value]=bets[value]+10
                        end
                        speaker.playSound("ui.button.click")
                    elseif y>=topLefty+16 and y<=topLefty+18 then
                        if x>=topLeftx+1 and x<=topLeftx+23 then
                            if bets["firstTwelve"]==nil then
                                bets["firstTwelve"]=10
                            elseif bets["firstTwelve"]< limits["twelves"] then
                                bets["firstTwelve"]=bets["firstTwelve"]+10
                            end
                            speaker.playSound("ui.button.click")
                        elseif x>=topLeftx+25 and x<=topLeftx+46 then
                            if bets["secondTwelve"]==nil then
                                bets["secondTwelve"]=10
                            elseif bets["secondTwelve"]< limits["twelves"] then
                                bets["secondTwelve"]=bets["secondTwelve"]+10
                            end
                            speaker.playSound("ui.button.click")
                        elseif x>=topLeftx+48 and x<=topLeftx+70 then
                            if bets["thirdTwelve"]==nil then
                                bets["thirdTwelve"]=10
                            elseif bets["thirdTwelve"]< limits["twelves"] then
                                bets["thirdTwelve"]=bets["thirdTwelve"]+10
                            end
                            speaker.playSound("ui.button.click")
                        end
                        
                    elseif y>=topLefty+20 and y<=topLefty+22 then

                        if x>=topLeftx+1 and x<=topLeftx+11 then

                            if bets["1to18"]==nil then
                                bets["1to18"]=10
                            elseif bets["1to18"]< limits["eighteens"] then
                                bets["1to18"]=bets["1to18"]+10
                            end
                            speaker.playSound("ui.button.click")
                        elseif x>=topLeftx+13 and x<=topLeftx+23 then


                            if bets["even"]==nil then
                                bets["even"]=10
                            elseif bets["even"]< limits["eighteens"] then
                                bets["even"]=bets["even"]+10
                            end
                            speaker.playSound("ui.button.click")
                        elseif x>=topLeftx+25 and x<=topLeftx+35 then


                            if bets["red"]==nil then
                                bets["red"]=10
                            elseif bets["red"]< limits["eighteens"] then
                                bets["red"]=bets["red"]+10
                            end
                            speaker.playSound("ui.button.click")
                        elseif x>=topLeftx+37 and x<=topLeftx+46 then


                            if bets["black"]==nil then
                                bets["black"]=10
                            elseif bets["black"]< limits["eighteens"] then
                                bets["black"]=bets["black"]+10
                            end
                            speaker.playSound("ui.button.click")
                        elseif x>=topLeftx+48 and x<=topLeftx+58 then


                            if bets["odd"]==nil then
                                bets["odd"]=10
                            elseif bets["odd"]< limits["eighteens"] then
                                bets["odd"]=bets["odd"]+10
                            end
                            speaker.playSound("ui.button.click")
                        elseif x>=topLeftx+60 and x<=topLeftx+70 then


                            if bets["19to36"]==nil then
                                bets["19to36"]=10
                            elseif bets["19to36"]< limits["eighteens"] then
                                bets["19to36"]=bets["19to36"]+10
                            end
                            speaker.playSound("ui.button.click")
                        end

                    elseif x>=topLeftx-7 and y>=topLefty+1 and y<=topLefty+6 and x<=topLeftx-2 then
                        if bets["00"]==nil then
                            bets["00"]=10
                        elseif bets["00"]< limits["singles"] then
                            bets["00"]=bets["00"]+10
                        end

                        speaker.playSound("ui.button.click")
                    elseif x>=topLeftx-7 and y>=topLefty+8 and y<=topLefty+13 and x<=topLeftx-2 then
                        if bets["0"]==nil then
                            bets["0"]=10
                        elseif bets["0"]< limits["singles"] then
                            bets["0"]=bets["0"]+10
                        end

                        speaker.playSound("ui.button.click")
                    end
                end

                
            end
        end

        function updateTable()
            while true do
                local topLeftx = bettingMonitorWidth/2-36 -- the top left cornor where the red and black numbers start
                local topLefty = 1
                term.redirect(bettingMonitor)
                term.setBackgroundColor(colors.blue)
                for y =0,2 do
                    for x=0,11 do

                        value = tostring(3*x + 3-y)
                        if bets[value]~=nil then
                            term.setCursorPos(topLeftx+6*x+3, topLefty+5*y+4)
                            term.write(tostring(bets[value]))

                        end
                    end
                end

                if bets["firstTwelve"]~=nil then
                    term.setCursorPos(topLeftx+20, 19)
                    term.write(tostring(bets["firstTwelve"]))
                end
                if bets["secondTwelve"]~=nil then
                    term.setCursorPos(topLeftx+43, 19)
                    term.write(tostring(bets["secondTwelve"]))
                end
                if bets["thirdTwelve"]~=nil then
                    term.setCursorPos(topLeftx+67, 19)
                    term.write(tostring(bets["thirdTwelve"]))
                end

                if bets["1to18"]~=nil then
                    term.setCursorPos(topLeftx+8, 23)
                    term.write(tostring(bets["1to18"]))
                end
                if bets["even"]~=nil then
                    term.setCursorPos(topLeftx+20, 23)
                    term.write(tostring(bets["even"]))
                end
                if bets["red"]~=nil then
                    term.setCursorPos(topLeftx+32, 23)
                    term.write(tostring(bets["red"]))
                end
                if bets["black"]~=nil then
                    term.setCursorPos(topLeftx+43, 23)
                    term.write(tostring(bets["black"]))
                end
                if bets["odd"]~=nil then
                    term.setCursorPos(topLeftx+55, 23)
                    term.write(tostring(bets["odd"]))
                end
                if bets["19to36"]~=nil then
                    term.setCursorPos(topLeftx+67, 23)
                    term.write(tostring(bets["19to36"]))
                end

                if bets["00"]~=nil then
                    term.setCursorPos(topLeftx-4, topLefty+6)
                    term.write(tostring(bets["00"]))
                end
                if bets["0"]~=nil then
                    term.setCursorPos(topLeftx-4, topLefty+13)
                    term.write(tostring(bets["0"]))
                end

                sleep(0.1)

            end
        end
        function waitForCard() 
            while true do
                if not fs.exists("disk/id") then
                    userId = nil
                    window = "idle"
                    bets = {}
                    return
                end
                sleep(0.5)
            end
        end
        

        parallel.waitForAny(getBets, updateTable, waitForCard)
        
    end
    if window=="spin" then
        term.redirect(wheelMonitor)
        wheelMonitor.setTextScale(0.5)

        term.setBackgroundColor(colors.green)
        term.clear()

        

        local ballForce = -math.random()*4-3
        local wheelForce = math.random()+0.5

        local wheelAngle = 0
        local resistance = 0.05
        local ballAngle = 0

        while math.abs(ballForce)>=0.1 do
            wheelAngle=wheelAngle+(wheelForce/framerate)

            ballForce = ballForce + resistance
            ballAngle = ballAngle+ (ballForce/framerate)

            term.setBackgroundColor(colors.green)
            term.clear()
            drawWheel(wheelRadius, segmentCount, wheelAngle, wheelCenter)
            drawBall(wheelRadius+1, ballAngle, wheelCenter)

            sleep(1/framerate)
        end

        term.setBackgroundColor(colors.green)

        
        local deltaAngle = 2*math.pi-(wheelAngle-ballAngle)%(2*math.pi)
    

        local number = math.floor(deltaAngle/ (2*math.pi/segmentCount))+1
        
        

        term.clear()

        for i=1,framerate*1.5 do
            wheelAngle=wheelAngle+(wheelForce/framerate)
            ballAngle=ballAngle+(wheelForce/framerate)

            drawWheel(wheelRadius, segmentCount, wheelAngle, wheelCenter)
            drawBall(wheelRadius-2, ballAngle, wheelCenter)

            sleep(1/framerate)
        end

        speaker.playSound("entity.villager.yes")
        
        winningNumber = numberOrder[number]
        window="result"
    end
    if window=="result" then
        term.redirect(wheelMonitor)
        local winnings = 0
        local winningNumberAsNumber = tonumber(winningNumber)

        for key, value in pairs(bets) do
            winnings = winnings-value
        end


        if bets[winningNumber]~=nil then
            winnings = winnings+bets[winningNumber]*mulitpliers["singles"]

        end

        if winningNumberAsNumber%2==0 and bets["even"]~=nil then
            winnings = winnings+bets["even"]*mulitpliers["eighteens"]

        elseif winningNumberAsNumber%2==1 and bets["odd"]~=nil then
            winnings = winnings+bets["odd"]*mulitpliers["eighteens"]
        end

        if winningNumberAsNumber >= 19 and bets["19to36"]~=nil then
            winnings = winnings+bets["19to36"]*mulitpliers["eighteens"]
        elseif winningNumberAsNumber <= 18 and bets["1to18"]~=nil then
            winnings = winnings+bets["1to18"]*mulitpliers["eighteens"]
        end

        --paintutils.drawFilledBox(1, wheelMonitorHeight/2-3, wheelMonitorWidth, wheelMonitorHeight/2+13, colors.brown)
        paintutils.drawFilledBox(wheelMonitorWidth/3-1, wheelMonitorHeight/2-3 , wheelMonitorWidth*2/3+1, wheelMonitorHeight/2+13, colors.white)
        if (winningNumberAsNumber <=10 and winningNumberAsNumber%2==0) or (winningNumberAsNumber>10 and winningNumberAsNumber<=18 and winningNumberAsNumber%2==1) or (winningNumberAsNumber>18 and winningNumberAsNumber <=28 and winningNumberAsNumber%2==0) or (winningNumberAsNumber>28 and winningNumberAsNumber<=36 and winningNumberAsNumber%2==1) then
            if bets["black"]~=nil then
                winnings = winnings+bets["black"]*mulitpliers["eighteens"]
                
            end
            paintutils.drawFilledBox(wheelMonitorWidth/3, wheelMonitorHeight/2-2 , wheelMonitorWidth*2/3, wheelMonitorHeight/2+12, colors.black)
            --black
        elseif winningNumber~="0" and winningNumber~="00" then
            if bets["red"]~=nil then
                winnings = winnings+bets["red"]*mulitpliers["eighteens"]
                
            end
            paintutils.drawFilledBox(wheelMonitorWidth/3, wheelMonitorHeight/2-2 , wheelMonitorWidth*2/3, wheelMonitorHeight/2+12, colors.red)
            --red
        else
            paintutils.drawFilledBox(wheelMonitorWidth/3, wheelMonitorHeight/2-2 , wheelMonitorWidth*2/3, wheelMonitorHeight/2+12, colors.green)
        end


        if bets["firstTwelve"]~=nil and winningNumberAsNumber<=12 then
            winnings = winnings+bets["firstTwelve"]*mulitpliers["twelves"]

        elseif bets["secondTwelve"]~=nil and winningNumberAsNumber>=12 and winningNumberAsNumber<=24 then
            winnings = winnings+bets["secondTwelve"]*mulitpliers["twelves"]

        elseif bets["thirdTwelve"]~=nil and winningNumberAsNumber>=12 and winningNumberAsNumber<=24 then
            winnings = winnings+bets["thirdTwelve"]*mulitpliers["twelves"]
            
        end

        
        local numberWidth = #winningNumber*11-2
        local startingX = wheelMonitorWidth/2-numberWidth/2

        for i=1,#winningNumber do
            paintutils.drawImage(numbers[string.sub(winningNumber, i, i)], startingX+(i-1)*11, wheelMonitorHeight/2-1)
        end

        window = "idle"
        changeBalance(winnings, userId)
        sleep(3)
    end

end

-- 
