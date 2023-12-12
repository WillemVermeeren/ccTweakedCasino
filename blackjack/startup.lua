function main()
    local decks = 6
    local bettignLimit = 100000
    local cardsLeftShuffle = 75  --Not dealing to the bottom of all the cards makes it more difficult for professional card counters to operate effectively
    local naturalMultiplier = 1 -- normally this should be 1.5 but because this is only 1 v house the house only loses more so that's why i have it on 1
    local blackjackMultiplier = 1
    --gets peripherals
    local monitor = peripheral.find("monitor")
    local speaker = peripheral.find("speaker")
    local casinoNetwerk = peripheral.find("modem")
    local drive = peripheral.find("drive")

    ---------------------- checks if everything is ok ------------------------
    assert(speaker~=nil, "no speaker connected =[")
    assert(monitor~=nil, "no monitor connected =[")
    assert(casinoNetwerk~=nil, "no modem connected =[")

    local monitorX, monitorY = monitor.getSize()
    assert((monitorX==29 and monitorY==26) or (monitorX==57 and monitorY==52), "Monitor should be 3 wide and 4 tall! I believe in you. You're almost there! =D")

    casinoNetwerk.open(os.getComputerID())

    ---------------- makes monitor ready -----------------------------
    term.redirect(monitor)
    term.clear()
    monitor.setTextScale(0.5)
    term.setCursorPos(10, 13)
    term.write("loading...")

    ----------- images -----------------
    -- idleScreen
    local blackjackIdle = paintutils.loadImage("graphics/blackjackIdle.nfp")
    local cardIdle = paintutils.loadImage("graphics/cardIdle.nfp")

    -- betting screen
    local dollarSigns = paintutils.loadImage("graphics/dollarSigns.nfp")
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

    local changeBettingAmount = {
        ["+1"] = paintutils.loadImage("graphics/changeBettingAmount/+1.nfp"),
        ["+10"] = paintutils.loadImage("graphics/changeBettingAmount/+10.nfp"),
        ["+100"] = paintutils.loadImage("graphics/changeBettingAmount/+100.nfp"),
        ["-1"] = paintutils.loadImage("graphics/changeBettingAmount/-1.nfp"),
        ["-10"] = paintutils.loadImage("graphics/changeBettingAmount/-10.nfp"),
        ["-100"] = paintutils.loadImage("graphics/changeBettingAmount/-100.nfp"),
    }
    local betImage = paintutils.loadImage("graphics/changeBettingAmount/BET.nfp")
    -- playing
    local actions = {
        ["doubleGrey"] = paintutils.loadImage("graphics/actions/doubleGrey.nfp"),
        ["hitGrey"] = paintutils.loadImage("graphics/actions/hitGrey.nfp"),
        ["standGrey"] = paintutils.loadImage("graphics/actions/standGrey.nfp"),

        ["doubleGreen"] = paintutils.loadImage("graphics/actions/doubleGreen.nfp"),
        ["hitGreen"] = paintutils.loadImage("graphics/actions/hitGreen.nfp"),
        ["standGreen"] = paintutils.loadImage("graphics/actions/standGreen.nfp"),
    }

    local backsideCard = paintutils.loadImage("graphics/cards/backside.nfp")

    local redCards = {
        ["diamondsAce"] = paintutils.loadImage("graphics/cards/red/diamondsAce.nfp"),
        ["heartsAce"] = paintutils.loadImage("graphics/cards/red/heartsAce.nfp"),
        ["2"] = paintutils.loadImage("graphics/cards/red/2.nfp"),
        ["3"] = paintutils.loadImage("graphics/cards/red/3.nfp"),
        ["4"] = paintutils.loadImage("graphics/cards/red/4.nfp"),
        ["5"] = paintutils.loadImage("graphics/cards/red/5.nfp"),   -- i know you could clean this up with a for loop but I like it this way
        ["6"] = paintutils.loadImage("graphics/cards/red/6.nfp"),
        ["7"] = paintutils.loadImage("graphics/cards/red/7.nfp"),
        ["8"] = paintutils.loadImage("graphics/cards/red/8.nfp"),
        ["9"] = paintutils.loadImage("graphics/cards/red/9.nfp"),
        ["10"] = paintutils.loadImage("graphics/cards/red/10.nfp"),
        ["11"] = paintutils.loadImage("graphics/cards/red/11.nfp"),
        ["12"] = paintutils.loadImage("graphics/cards/red/12.nfp"),
        ["13"] = paintutils.loadImage("graphics/cards/red/13.nfp"),

        ["h"] = paintutils.loadImage("graphics/cards/red/icons/hearts.nfp"),
        ["d"] = paintutils.loadImage("graphics/cards/red/icons/diamonds.nfp"),
    }

    local blackCards = {
        ["clubsAce"] = paintutils.loadImage("graphics/cards/black/clubsAce.nfp"),
        ["spadesAce"] = paintutils.loadImage("graphics/cards/black/spadesAce.nfp"),

        ["2"] = paintutils.loadImage("graphics/cards/black/2.nfp"),
        ["3"] = paintutils.loadImage("graphics/cards/black/3.nfp"),
        ["4"] = paintutils.loadImage("graphics/cards/black/4.nfp"),
        ["5"] = paintutils.loadImage("graphics/cards/black/5.nfp"),
        ["6"] = paintutils.loadImage("graphics/cards/black/6.nfp"),
        ["7"] = paintutils.loadImage("graphics/cards/black/7.nfp"), -- i know you could clean this up with a for loop but I still like it this way
        ["8"] = paintutils.loadImage("graphics/cards/black/8.nfp"),
        ["9"] = paintutils.loadImage("graphics/cards/black/9.nfp"),
        ["10"] = paintutils.loadImage("graphics/cards/black/10.nfp"),
        ["11"] = paintutils.loadImage("graphics/cards/black/11.nfp"),
        ["12"] = paintutils.loadImage("graphics/cards/black/12.nfp"),
        ["13"] = paintutils.loadImage("graphics/cards/black/13.nfp"),

        ["c"] = paintutils.loadImage("graphics/cards/black/icons/clubs.nfp"),
        ["s"] = paintutils.loadImage("graphics/cards/black/icons/spades.nfp"),
    }   

    local blackJackImage = paintutils.loadImage("graphics/gamePrompts/blackjack.nfp")

    local naturalImages = {
        paintutils.loadImage("graphics/gamePrompts/natural1.nfp"),
        paintutils.loadImage("graphics/gamePrompts/natural2.nfp"),
    }

    local bustImage = paintutils.loadImage("graphics/gamePrompts/bust.nfp")

    local youWinImage = paintutils.loadImage("graphics/gamePrompts/youWin.nfp")
    local youLoseImage = paintutils.loadImage("graphics/gamePrompts/youLose.nfp")
    local tieImage = paintutils.loadImage("graphics/gamePrompts/tie.nfp")

    ----------------- deck functions ----------------------------
    local shuffledDeck = {}
    function shuffleDeck()
        local cards = {}
        for i=1,decks do
            for i=1,13 do
                table.insert(cards, tostring(i).."c") -- creates clubs card
                table.insert(cards, tostring(i).."d") -- diamonds card
                table.insert(cards, tostring(i).."h") -- hearts card
                table.insert(cards, tostring(i).."s") -- spades card
            end
        end

        while #cards > 0 do
            local placePickedShuffleCard = math.random(1, #cards) -- shuffles the previous made cards deck
            
            table.insert(shuffledDeck, cards[placePickedShuffleCard])
            table.remove(cards, placePickedShuffleCard)
        end
    end

    function pullCard(whosDeck, faceUp)
        
        if #shuffledDeck < cardsLeftShuffle then
            shuffleDeck()
        end
        table.insert(whosDeck, {shuffledDeck[1], faceUp})
        table.remove(shuffledDeck, 1)
    end
    -------- a function for getting the balance of a card and a function from adding the winnings (or losings when negative) to the balance --------------------------
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
    -------------- start --------------------------
    local dealerCards = {}
    local playerCards = {}
    local bettingAmount = 0
    local balance = 0
    local userId = 0

    goTo = nil --because goto is not suported in cc: Tweaked i have to do it this way
    while true do

        --------------------idle screen-----------------------------
        if goTo == nil or goTo == "idleScreen" then
            goTo = nil

            function showIdleMenu()
                while true do
                    

                    term.setBackgroundColor(colors.green)
                    term.clear()    -- clears screen


                    paintutils.drawImage(backsideCard, 7, 35)
                    paintutils.drawImage(blackCards["spadesAce"], 37, 35)
                    paintutils.drawImage(blackjackIdle, 5, 5)


                    sleep(10) -- change for speed (I recomend not going under 0.1 as it can get glitchy)
                end
            end
            function waitForCard() 
                while true do
                    if fs.exists("disk/id") then
                        local file = fs.open("disk/id", "r")
                        userId = file.readAll()
                        file.close()
                        return
                    end
                    sleep(0.5)
                end
            end

            
            parallel.waitForAny(waitForCard, showIdleMenu)
            
            speaker.playSound("entity.villager.yes")

            

            
        end
        --------------------------- bet making----------------------------------------
        if goTo == nil or goTo == "betMaking" then
            goTo = nil
            
            balance = getBalance(userId)
            if balance > 0 then
                bettingAmount = math.ceil(balance/2)
                if bettingAmount > bettignLimit then   -- makes sure the bettingAmount is displayable. Normally your not suposed to have so many diamonds but there are these tryhards ¯\_(ツ)_/¯
                    bettingAmount = bettignLimit
                end

                local bettingAmountString = tostring(bettingAmount) -- makes the betting amount a string so it can be easyer displayed
                ------------- drawing base menu ----------------------
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setTextColor(colors.white)
                
                term.setCursorPos(20, 52)
                term.write("your balance: "..tostring(balance))
                paintutils.drawImage(dollarSigns, 14, 2)

                paintutils.drawImage(changeBettingAmount["+1"], 2, 27)
                paintutils.drawImage(changeBettingAmount["+10"], 2, 34)
                paintutils.drawImage(changeBettingAmount["+100"], 2, 41)

                paintutils.drawImage(changeBettingAmount["-1"], 41, 27)
                paintutils.drawImage(changeBettingAmount["-10"], 41, 34)
                paintutils.drawImage(changeBettingAmount["-100"], 41, 41)

                paintutils.drawImage(betImage, 20, 33)
                -- functions that will be running simultaneously
                function updateBettingAmount()
                    paintutils.drawFilledBox(1, 13, 57, 23, colors.black)
                    local numberWidth = #bettingAmountString*11-2
                    local numberStartingXPosition = math.floor(57/2 - numberWidth/2)
                    for i=1,#bettingAmountString do
                        paintutils.drawImage(numbers[string.sub(bettingAmountString, i, i)], numberStartingXPosition+(i-1)*11, 13)
                    end
                    
                    local event, side, x, y = os.pullEvent("monitor_touch")
                    
                    local buttonPressed = ""

                    if x >= 2 and x<= 16 then -- +
                        if y>=27 and y<=32 then -- 1
                            bettingAmount = bettingAmount + 1
                            speaker.playSound("ui.button.click")

                        elseif y>=34 and y<= 39 then -- 10
                            speaker.playSound("ui.button.click")
                            bettingAmount = bettingAmount + 10
                        elseif y>=41 and y<=46 then -- 100
                            speaker.playSound("ui.button.click")
                            bettingAmount = bettingAmount + 100
                        end
                    elseif x>=41 and x<=55 then --  -
                        if y>=27 and y<=32 then -- 1
                            speaker.playSound("ui.button.click")
                            bettingAmount = bettingAmount - 1

                        elseif y>=34 and y<= 39 then -- 10
                            speaker.playSound("ui.button.click")
                            bettingAmount = bettingAmount - 10

                        elseif y>=41 and y<=46 then -- 100
                            speaker.playSound("ui.button.click")
                            bettingAmount = bettingAmount - 100

                        end
                    elseif x>=20 and x<=37 and y>=33 and y<=40 then
                        speaker.playSound("ui.button.click")
                        goTo = "playersTurn"
                    end

                    if bettingAmount < 1 then
                        bettingAmount = 1
                    elseif bettingAmount > balance then
                        bettingAmount = balance
                    
                    elseif bettingAmount > bettignLimit then
                        bettingAmount = bettignLimit
                    end

                    bettingAmountString = tostring(bettingAmount)
                end

                function checkForDisk()
                    local playerPresent = true
                    while true do
                        
                        
                        if not fs.exists("disk/id") then
                            userId = nil
                            goTo = "idleScreen"
                            return
                        end
                        sleep(0.5)
                    end
                    
                    
                end

                ---------- drawing and changing betting amount ------------------
                while goTo==nil do
                    parallel.waitForAny(checkForDisk, updateBettingAmount)        
                end
            else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.yellow)
                term.clear()

                paintutils.drawImage(dollarSigns, 14, 2)

                term.setBackgroundColor(colors.black)
                term.setCursorPos(20, 20)
                term.write("not enough chips")

                while true do
                    sleep(0.5)
                    
                    if not fs.exists("disk/id") then
                        userId = nil
                        goTo = "idleScreen"
                        break
                    end
                    
                end

            end
        end
        ---------------- main game --------------------------
        function showCards(whosCards)
            
            
            if whosCards=="dealer" then
                paintutils.drawFilledBox(1, 2, 52, 15, colors.green)
                local dealerCardWidth = #dealerCards*14-1
                local dealerCardStartX = math.floor(57/2-dealerCardWidth/2)+1
                for i=1,#dealerCards do
                    if dealerCards[i][2] == true then
        
                        local cardType = string.sub(dealerCards[i][1], #dealerCards[i][1], #dealerCards[i][1])
                        local number = string.sub(dealerCards[i][1], 1, #dealerCards[i][1]-1)
                        if cardType=="d" then
                            if number=="1" then
                                paintutils.drawImage(redCards["diamondsAce"], (i-1)*14+dealerCardStartX, 2)
                            else
                                paintutils.drawImage(redCards[number], (i-1)*14+dealerCardStartX, 2)
                                paintutils.drawImage(redCards[cardType], (i-1)*14+dealerCardStartX, 2)
                            end
        
                        elseif cardType=="h" then
                            if number=="1" then
                                paintutils.drawImage(redCards["heartsAce"], (i-1)*14+dealerCardStartX, 2)
                            else
                                paintutils.drawImage(redCards[number], (i-1)*14+dealerCardStartX, 2)
                                paintutils.drawImage(redCards[cardType], (i-1)*14+dealerCardStartX, 2)
                            end
                        elseif cardType=="c" then
                            if number=="1" then
                                paintutils.drawImage(blackCards["clubsAce"], (i-1)*14+dealerCardStartX, 2)
                            else
                                paintutils.drawImage(blackCards[number], (i-1)*14+dealerCardStartX, 2)
                                paintutils.drawImage(blackCards[cardType], (i-1)*14+dealerCardStartX, 2)
                            end
                        elseif cardType=="s" then
                            if number=="1" then
                                paintutils.drawImage(blackCards["spadesAce"], (i-1)*14+dealerCardStartX, 2)
                            else
                                paintutils.drawImage(blackCards[number], (i-1)*14+dealerCardStartX, 2)
                                paintutils.drawImage(blackCards[cardType], (i-1)*14+dealerCardStartX, 2)
                            end
                        end
                        
                    else
                        paintutils.drawImage(backsideCard, (i-1)*14+dealerCardStartX, 2)
                    end
                end
            elseif whosCards=="player" then
                paintutils.drawFilledBox(1, 28, 52, 41, colors.green)
                local playerCardWidth = #playerCards*14-1
                local playerCardStartX = math.floor(57/2-playerCardWidth/2)+1
                for i=1,#playerCards do
                    term.setBackgroundColor(colors.black)
                    if playerCards[i][2] == true then
                        local cardType = string.sub(playerCards[i][1], #playerCards[i][1], #playerCards[i][1])
                        local number = string.sub(playerCards[i][1], 1, #playerCards[i][1]-1)
                        if cardType=="d" then
                            if number=="1" then
                                paintutils.drawImage(redCards["diamondsAce"], (i-1)*14+playerCardStartX, 28)
                            else
                                paintutils.drawImage(redCards[number], (i-1)*14+playerCardStartX, 28)
                                paintutils.drawImage(redCards[cardType], (i-1)*14+playerCardStartX, 28)
                            end
        
                        elseif cardType=="h" then
                            if number=="1" then
                                paintutils.drawImage(redCards["heartsAce"], (i-1)*14+playerCardStartX, 28)
                            else
                                paintutils.drawImage(redCards[number], (i-1)*14+playerCardStartX, 28)
                                paintutils.drawImage(redCards[cardType], (i-1)*14+playerCardStartX, 28)
                            end
                        elseif cardType=="c" then
                            if number=="1" then
                                paintutils.drawImage(blackCards["clubsAce"], (i-1)*14+playerCardStartX, 28)
                            else
                                paintutils.drawImage(blackCards[number], (i-1)*14+playerCardStartX, 28)
                                paintutils.drawImage(blackCards[cardType], (i-1)*14+playerCardStartX, 28)
                            end
                        elseif cardType=="s" then
                            if number=="1" then
                                paintutils.drawImage(blackCards["spadesAce"], (i-1)*14+playerCardStartX, 28)
                            else
                                paintutils.drawImage(blackCards[number], (i-1)*14+playerCardStartX, 28)
                                paintutils.drawImage(blackCards[cardType], (i-1)*14+playerCardStartX, 28)
                            end
                        end
                    else
                        paintutils.drawImage(backsideCard, (i-1)*14+playerCardStartX, 28)
                    end
                end
            end

        end

        function cardCount(whatCount, deck)

            local countedDecks = {0}
            for i=1,#deck do
                local cardNumber = tonumber(string.sub(deck[i][1], 1, #deck[i][1]-1))
                if cardNumber>10 then
                    cardNumber = 10
                end
                local AmountTypesOfDecks = #countedDecks
                for j=1,AmountTypesOfDecks do
                    if cardNumber == 1 then
                        table.insert(countedDecks, countedDecks[j]+1)
                        countedDecks[j] = countedDecks[j]+11
                    else
                        countedDecks[j] = countedDecks[j]+cardNumber
                    end
                end
            end
            if  whatCount == "closest" then
                local closestCardCount = -1
                for k = 1,#countedDecks do
                    if 21-countedDecks[k]<21-closestCardCount and countedDecks[k]<=21 then
                        closestCardCount = countedDecks[k]
                    end
                end
                return closestCardCount
            elseif whatCount == "lowest" then
                local lowest = -1
                for k = 1,#countedDecks do
                    if countedDecks[k]<lowest or k==1 then
                        lowest = countedDecks[k]
                    end
                end
                return lowest
            end
        end
        ------- manages players turn and animation
        local natural = false
        if goTo == nil or goTo == "playersTurn" then
            goTo = nil
            
            dealerCards = {}
            playerCards = {}

            term.setBackgroundColor(colors.green)
            term.clear()
            paintutils.drawFilledBox(1, 44, 57, 52, colors.black)
            paintutils.drawImage(actions["standGrey"], 4, 45)
            paintutils.drawImage(actions["hitGrey"], 29, 45)
            paintutils.drawImage(actions["doubleGrey"], 44, 45)

            -- cards dealing animation
            sleep(0.5)
            paintutils.drawImage(backsideCard, 23, 2)
            speaker.playSound("block.dispenser.launch")
            sleep(0.5)
            speaker.playSound("block.dispenser.launch")
            paintutils.drawImage(backsideCard, 23, 28)
            sleep(0.5)
            speaker.playSound("block.dispenser.launch")
            paintutils.drawFilledBox(1, 2, 57, 20, colors.green)
            paintutils.drawImage(backsideCard, 15, 2)
            paintutils.drawImage(backsideCard, 29, 2)
            sleep(0.5)
            speaker.playSound("block.dispenser.launch")
            paintutils.drawFilledBox(1, 24, 57, 42, colors.green)
            paintutils.drawImage(backsideCard, 15, 28)
            paintutils.drawImage(backsideCard, 29, 28)
            sleep(0.5)

            pullCard(dealerCards, true)
            pullCard(dealerCards, false)
            pullCard(playerCards, true)
            pullCard(playerCards, true)

            paintutils.drawImage(actions["standGreen"], 4, 45)
            paintutils.drawImage(actions["hitGreen"], 29, 45)
            showCards("dealer")
            speaker.playSound("entity.villager.yes")

            while true do
                showCards("player")
                local playerLowestCardCount = cardCount("lowest", playerCards)
                local playerClosestCardCount = cardCount("closest", playerCards)

                if playerLowestCardCount > 21 then
                    paintutils.drawImage(actions["standGrey"], 4, 45)
                    paintutils.drawImage(actions["hitGrey"], 29, 45)
                    
                end

                if playerLowestCardCount >=9 and playerLowestCardCount<=11 and  bettingAmount*2 <= balance and #playerCards == 2 then
                    paintutils.drawImage(actions["doubleGreen"], 44, 45)
                else
                    paintutils.drawImage(actions["doubleGrey"], 44, 45)

                end

                if #playerCards >= 4 then
                    paintutils.drawImage(actions["hitGrey"], 29, 45)
                end

                
                if playerLowestCardCount > 21 then
                    speaker.playSound("entity.generic.explode")
                    
                    
                    paintutils.drawImage(bustImage, 19, 18)
                    sleep(1)
                    paintutils.drawFilledBox(1, 18, 57, 23, colors.green)
                    goTo="decideWinner"
                    break
                end
                if playerClosestCardCount == 21 and #playerCards==2 then
                    sleep(0.5)
                    for i=1,10 do
                        paintutils.drawImage(naturalImages[i%2+1], 11, 18)
                        speaker.playSound("block.note_block.pling", 1, 10)
                        sleep(0.2)
                    end
                    sleep(0.5)
                    paintutils.drawFilledBox(1, 18, 57, 23, colors.green)
                    sleep(1)
                    break
                elseif playerClosestCardCount == 21 and #playerCards>2 then
                    sleep(0.5)
                    speaker.playSound("block.note_block.pling", 1, 10)
                    paintutils.drawImage(blackJackImage, 7, 18)
                    sleep(0.5)
                    paintutils.drawFilledBox(1, 18, 57, 23, colors.green)
                    sleep(0.5)
                    speaker.playSound("block.note_block.pling", 1, 10)
                    paintutils.drawImage(blackJackImage, 7, 18)
                    sleep(0.5)
                    paintutils.drawFilledBox(1, 18, 57, 23, colors.green)
                    sleep(1)
                    break
                end

                local event, side, touchX, touchY = os.pullEvent("monitor_touch")
                if playerLowestCardCount < 21 then
                    if touchY >= 45 and touchY<=51 then
                        if touchX >= 4 and touchX <= 25 then

                            speaker.playSound("entity.villager.yes")
                            sleep(1)
                            break
                        elseif touchX >= 29 and touchX<= 39 and #playerCards < 4 then
                            speaker.playSound("block.dispenser.launch")
                            pullCard(playerCards, true)
                        elseif touchX >=44 and touchX<54 and playerLowestCardCount >=9 and playerLowestCardCount<=11 and  bettingAmount*2 <= balance and #playerCards < 4 then
                            speaker.playSound("block.dispenser.launch")
                            pullCard(playerCards, true)
                            bettingAmount = bettingAmount*2
                        end
                    end
                end
            end
        end
        if goTo == nil or goTo=="dealersTurn" then
            goTo = nil
            paintutils.drawImage(actions["standGrey"], 4, 45)
            paintutils.drawImage(actions["hitGrey"], 29, 45)
            paintutils.drawImage(actions["doubleGrey"], 44, 45)
            for i=1,#dealerCards do
                dealerCards[i][2] = true
            end
            showCards("dealer")
            sleep(0.5)
            while cardCount("closest", dealerCards) < 17 and cardCount("lowest", dealerCards) < 21 and #dealerCards<4 do
                speaker.playSound("block.dispenser.launch")

                pullCard(dealerCards, true)
                showCards("dealer")
                sleep(0.5)
            end
            if cardCount("lowest", dealerCards) > 21 then
                speaker.playSound("entity.generic.explode")
                sleep(0.5)
            end
        end
        if goTo == nil or goTo=="decideWinner" then
            goTo = nil
            paintutils.drawImage(actions["standGrey"], 4, 45)
            paintutils.drawImage(actions["hitGrey"], 29, 45)
            paintutils.drawImage(actions["doubleGrey"], 44, 45)
            local playersCardCount = cardCount("closest", playerCards)
            local dealersCardCount = cardCount("closest", dealerCards)
            sleep(0.5)
            if playersCardCount > 21 then
                -- bust    loseprompt
                speaker.playSound("block.note_block.pling", 1, 1)
                paintutils.drawImage(youLoseImage, 11, 18)
                goTo = "idleScreen"
            end
            
            if dealersCardCount > 21 then
                -- dealers busts    win prompt
                speaker.playSound("block.note_block.pling", 1, 1)
                paintutils.drawImage(youWinImage, 12, 18)
            elseif dealersCardCount==playersCardCount then
                --tie       tie prompt
                paintutils.drawImage(tieImage, 23, 18)

            elseif dealersCardCount>playersCardCount then
                -- you lose
                speaker.playSound("block.note_block.pling", 1, 1)
                paintutils.drawImage(youLoseImage, 11, 18)
                changeBalance(-bettingAmount, userId)
            else
                if playersCardCount == 21 then
                    if #playerCards == 2 then
                        --natural
                        changeBalance(bettingAmount*naturalMultiplier, userId)
                        paintutils.drawImage(youWinImage, 12, 18)
                        speaker.playSound("block.note_block.pling", 1, 10)

                    else
                        --blackjack
                        changeBalance(bettingAmount*blackjackMultiplier, userId)
                        paintutils.drawImage(youWinImage, 12, 18)
                        speaker.playSound("block.note_block.pling", 1, 10)
                    end
                else
                    changeBalance(bettingAmount, userId)
                    paintutils.drawImage(youWinImage, 12, 18)
                    speaker.playSound("block.note_block.pling", 1, 10)
                    --normal win
                end

            end
            goTo = "idleScreen"
            function waitForTouch() os.pullEvent("monitor_touch") end
            function timeOut() sleep(5) end
            parallel.waitForAny(waitForTouch, timeOut)
        end
        
    end
end

main()

