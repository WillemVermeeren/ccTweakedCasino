local programs = {
    
 
    {["name"]="cashier", ["paths"]={
        
        "startup.lua",

    }, ["githubUrl"]="https://raw.githubusercontent.com/WillemVermeeren/ccTweakedCasino/main/cashier/"},
 
    {["name"]="central computer", ["paths"]={
        "machineProfits.json",
        "save.json",
        "settings.lua",
        "startup.lua",
 
    }, ["githubUrl"]="https://raw.githubusercontent.com/WillemVermeeren/ccTweakedCasino/main/centralComputer/"},
 
    {["name"]="blackjack", ["paths"]={
        "/startup.lua",
        "/graphics/dollarSigns.nfp",
        "/graphics/cardIdle.nfp",
        "/graphics/blackjackIdle.nfp",
    
        "/graphics/numbers/0.nfp",
        "/graphics/numbers/1.nfp",
        "/graphics/numbers/2.nfp",
        "/graphics/numbers/3.nfp",
        "/graphics/numbers/4.nfp",
        "/graphics/numbers/5.nfp",
        "/graphics/numbers/6.nfp",
        "/graphics/numbers/7.nfp",
        "/graphics/numbers/8.nfp",
        "/graphics/numbers/9.nfp",
    
        "/graphics/gamePrompts/blackjack.nfp",
        "/graphics/gamePrompts/bust.nfp",
        "/graphics/gamePrompts/natural1.nfp",
        "/graphics/gamePrompts/natural2.nfp",
        "/graphics/gamePrompts/tie.nfp",
        "/graphics/gamePrompts/youLose.nfp",
        "/graphics/gamePrompts/youWin.nfp",
    
        "/graphics/changeBettingAmount/+1.nfp",
        "/graphics/changeBettingAmount/+10.nfp",
        "/graphics/changeBettingAmount/+100.nfp",
        "/graphics/changeBettingAmount/-1.nfp",
        "/graphics/changeBettingAmount/-10.nfp",
        "/graphics/changeBettingAmount/-100.nfp",
        "/graphics/changeBettingAmount/BET.nfp",
    
        "/graphics/cards/backside.nfp",
    
        "/graphics/cards/black/clubsAce.nfp",
        "/graphics/cards/black/spadesAce.nfp",
        "/graphics/cards/black/2.nfp",
        "/graphics/cards/black/3.nfp",
        "/graphics/cards/black/4.nfp",
        "/graphics/cards/black/5.nfp",
        "/graphics/cards/black/6.nfp",
        "/graphics/cards/black/7.nfp",
        "/graphics/cards/black/8.nfp",
        "/graphics/cards/black/9.nfp",
        "/graphics/cards/black/10.nfp",
        "/graphics/cards/black/11.nfp",
        "/graphics/cards/black/12.nfp",
        "/graphics/cards/black/13.nfp",
        "/graphics/cards/black/icons/clubs.nfp",
        "/graphics/cards/black/icons/spades.nfp",
    
        "/graphics/cards/red/diamondsAce.nfp",
        "/graphics/cards/red/heartsAce.nfp",
        "/graphics/cards/red/2.nfp",
        "/graphics/cards/red/3.nfp",
        "/graphics/cards/red/4.nfp",
        "/graphics/cards/red/5.nfp",
        "/graphics/cards/red/6.nfp",
        "/graphics/cards/red/7.nfp",
        "/graphics/cards/red/8.nfp",
        "/graphics/cards/red/9.nfp",
        "/graphics/cards/red/10.nfp",
        "/graphics/cards/red/11.nfp",
        "/graphics/cards/red/12.nfp",
        "/graphics/cards/red/13.nfp",
        "/graphics/cards/red/icons/diamonds.nfp",
        "/graphics/cards/red/icons/hearts.nfp",
    
        "/graphics/actions/doubleGreen.nfp",
        "/graphics/actions/doubleGrey.nfp",
        "/graphics/actions/hitGreen.nfp",
        "/graphics/actions/hitGrey.nfp",
        "/graphics/actions/standGreen.nfp",
        "/graphics/actions/standGrey.nfp",
    }, ["githubUrl"]="https://raw.githubusercontent.com/WillemVermeeren/ccTweakedCasino/main/blackjack/"},
    {["name"]="roulette", ["paths"]={
 
        "startup.lua",
        "graphics/numbers/0.nfp",
        "graphics/numbers/1.nfp",
        "graphics/numbers/2.nfp",
        "graphics/numbers/3.nfp",
        "graphics/numbers/4.nfp",
        "graphics/numbers/5.nfp",
        "graphics/numbers/6.nfp",
        "graphics/numbers/7.nfp",
        "graphics/numbers/8.nfp",
        "graphics/numbers/9.nfp",
    }, ["githubUrl"]="https://raw.githubusercontent.com/WillemVermeeren/ccTweakedCasino/main/roulette/"}
}
 
 
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
selected = 1
for i, element in pairs(programs) do
    term.setCursorPos(3, i)
    term.write(element["name"])
end
while true do
    paintutils.drawFilledBox(1, 1, 2, #programs, colors.black)
    term.setCursorPos(1, selected)
    term.write(">")
 
    local event, key, isHeld = os.pullEvent("key")
    if keys.getName(key)=="up" then
        selected = selected - 1
    elseif keys.getName(key)=="down" then
        selected = selected + 1
    elseif keys.getName(key)=="enter" then
        for _, path in pairs(programs[selected]["paths"]) do
            shell.run("wget", programs[selected]["githubUrl"]..path, path)
            
        end
        os.reboot()
    end
 
    if selected <= 0 then
        selected = #programs
    elseif selected >= #programs+1 then
        selected = 1
    end
end
