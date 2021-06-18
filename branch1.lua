------------------------------------------------------------------------------------------------------------------------
-----------------------------------------API'S--------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
os.loadAPI("betterButton")
------------------------------------------------------------------------------------------------------------------------
---------------------------------------Variables------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local w, h = term.getSize() -- Width, and Height of terminal
local atStart = true -- The turtle is in its starting position
local y = 0
local t = turtle -- Abbreviation for turtle ;)
local side = "Left" -- Which side to strip towards
local strips = 1 -- # of strips to mine
local isUp
local length = 1 -- Length of strips
local full = false -- Whether the turtle's inventory is full or not
local offset = 0 -- How many strips to start offset by
local between = false -- Whether the turtle is between strips or not
local DistanceFromStripStart = 0 -- How far (t is) from the beginning of a strip
local DistanceFromShaftStart = 0 -- How far from the start of the mineshaft
local DistanceFromCurrentStrip = 0 -- How far from the strip (left off)
local DistanceFromCurrentStripSpot = 0 -- How far from the spot inside strip (left off)
local count = 0 -- Non-specific variable for counting
local incNum = 1 -- Increment value for setting values in GUI
local fromVeinOrder = {...} -- Table for the order of moves the turtle takes from the vein back into the strip of ore
local toVeinOrder = {...} -- Table for the order of moves the turtle takes from the strip into the vein of ore
local BI = betterButton.new() -- BI = Branch Info, instance for buttons
local menu = betterButton.new() -- Start menu instance for buttons
local orientation = 0 -- = starting orientation

local pages = {
    -- Table for menu pages
    "page1", "page2", "page3", "page4", "page5", "page6", "page7", "page8"
}
local filteredOres = {}

local lengths = {strips, length, offset}

local distances = {
    -- Table for 4 common distances to use
    DistanceFromStripStart, DistanceFromShaftStart,
    DistanceFromCurrentStripSpot, DistanceFromCurrentStrip
}

local ores = {
    -- Table for ore names to filter by
    "minecraft:gold_ore", "minecraft:iron_ore", "minecraft:redstone_ore",
    "minecraft:emerald_ore", "minecraft:coal_ore", "minecraft:diamond_ore",
    "minecraft:lapis_ore", "thaumcraft:ore_amber", "thaumcraft:ore_cinnabar",
    "thaumcraft:ore_quartz", "appiedenergistics2:quartz_ore",
    "appiedenergistics2:charged_quartz_ore",
    {"biomesoplenty:gem_ore", 0, 1, 2, 3, 4, 5, 6, 7},
    {"forestry:resources", 0, 1, 2},
    {"immersiveengineering:ore", 0, 1, 2, 3, 4, 5},
    {"ic2:resource", 1, 2, 3, 4}, {"mekanism:oreblock", 0, 1, 2},
    {"railcraft:ore_metal", 0, 1, 2, 3, 4, 5},
    {"thermalfoundation:ore", 0, 1, 2, 3, 4, 5, 6, 7, 8}
}

local oresPlain = {
    -- Table with readable ore names for menu buttons
    "Gold", "Iron", "Redstone", "Emerald", "Coal", "Diamond", "Lapis",
    "TCAmber", "Cinnabar", "Quartz", -- 10
    "Certus Quartz", "Charged Quartz", {
        "Biomesoplenty Ores", "Amethyst", "Ruby", "Peridot", "Topaz",
        "Tanzanite", "Malachite", "Sapphire", "Amber"
    }, {"Forestry Ores", "Apatite", "F-Copper", "F-Tin"}, {
        "Immersive Ores", "Imm-Copper", "Bauxite", "Imm-Lead", "Imm-Silver",
        "Imm-Nickel", "Imm-Uranium"
    }, {"IC2 Ores", "IC2-Copper", "IC2-Lead", "IC2-Tin", "IC2-Uranium"},
    {"Mekanism Ores", "Osmium", "Mek-Copper", "Mek-Tin"}, {
        "Railcraft Ores", "Rail-Copper", "Rail-Tin", "Rail-Lead", "Rail-Silver",
        "Rail-Nickel", "Zinc"
    }, -- 18
    {
        "Thermal Foundation Ores", "Therm-Copper", "Therm-Tin", "Therm-Silver",
        "Therm-Lead", "Aluminum", "Therm-Nickel", "Platinum", "Irididum",
        "Mana Infused"
    }
}
------------------------------------------------------------------------------------------------------------------------
---------------------------------------------Functions------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------------------------------------------Main Menu------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function mainMenu() -- Function to create starting menu
    menu:add("Start", function() mainMenuFunction("Start") end,
             math.ceil(w / 2) - 10, math.ceil(h / 2) - 2, math.ceil(w / 2) + 10,
             math.ceil(h / 2) - 2, colors.yellow, colors.green, colors.black,
             colors.black)
    menu:add("How to Use", function() mainMenuFunction("How to Use") end,
             math.ceil(w / 2) - 10, math.ceil(h / 2), math.ceil(w / 2) + 10,
             math.ceil(h / 2), colors.yellow, colors.green, colors.black,
             colors.black)
    menu:add("Quit", function() mainMenuFunction("Quit") end,
             math.ceil(w / 2) - 10, math.ceil(h / 2) + 2, math.ceil(w / 2) + 10,
             math.ceil(h / 2) + 2, colors.yellow, colors.green, colors.black,
             colors.black)
    menu:draw()
    setColors(colors.black, colors.orange)
    term.setCursorPos(math.ceil(w / 2) - 8, 1)
    print("RJ's Branch Miner")
    menu:run()
end
function mainMenuFunction(name)
    if (name == "Start") then
        menu:flash(name)
        sleep(0.15)
        main()
    elseif (name == "How to Use") then
        menu:flash(name)
        sleep(0.15)
        howTo()
    elseif (name == "Quit") then
        quit(menu)
    end
end
function howTo()
    local tutorialStrings = {
        "1. Place a chest behind and underneath your turtle. Place fuel in the chest underneath the turtle.",
        "2. Press 'Start' on the main menu to begin.",
        "3. Select any ores you want the turtle to mine with left-click or right-click. Use right click to filter a mod's ores specifically.",
        "4. After you have filtered your ores, press next; Select strip length, #strips, strip offset, and direction.",
        "5. Press 'Mine!'"
    }
    while true do
        for i = 1, 5 do
            setColors(colors.red, colors.orange)
            clear()
            term.setCursorPos(1, h)
            print("*HOLD CTRL + T to quit out.*")
            term.setCursorPos(1, 1)
            setColors(colors.black, colors.orange)
            print(tutorialStrings[i])
            sleep(5)
        end
    end
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------Pages-------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function initializePages()
    for i = 1, #pages do
        pages[i] = betterButton.new()
        createPage(pages[i], i)
    end
end
function createPage(page, pageIndex)
    pageIndex = pageIndex or nil
    local x = 1
    local y = 1
    local text
    page:add("Next", nil, w - 5, h, w, h, colors.yellow, colors.green,
             colors.black, colors.white)
    page:add("Back", nil, 1, h, 6, h, colors.yellow, colors.green, colors.black,
             colors.white)
    page:add("Quit", nil, math.ceil(w / 2) - 3, h, math.ceil(w / 2) + 2, h,
             colors.yellow, colors.green, colors.black, colors.white)
    if (page == pages[1]) then
        page:add("All", nil, math.ceil(w / 2) - 6, h - 2, math.ceil(w / 2) - 2,
                 h - 2, colors.yellow, colors.green, colors.black, colors.white)
        page:add("None", nil, math.ceil(w / 2), h - 2, math.ceil(w / 2) + 5,
                 h - 2, colors.yellow, colors.green, colors.black, colors.white)
        toggle(page, "None")
        for i = 1, #oresPlain do
            if (type(oresPlain[i]) ~= "table") then
                text = oresPlain[i]
                if (x + string.len(text) + 2 > w) then
                    y = y + 1
                    x = 1
                end
                page:add(text, nil, x, y, string.len(text) + x + 1, y,
                         colors.yellow, colors.green, colors.black, colors.white)
                        
            else
                text = oresPlain[i][1]
                if (x + string.len(text) + 2 > w) then
                    y = y + 1
                    x = 1
                end
                page:add(text, nil, x, y, string.len(text) + x + 1, y,
                         colors.yellow, colors.green, colors.black, colors.white)
                        
            end
            toggle(page, text)
            x = x + string.len(text) + 3
        end
    else
        for j = 2, #oresPlain[pageIndex + 11] do
            text = oresPlain[pageIndex + 11][j]
            if (x + string.len(text) + 4 > w) then
                y = y + 2
                x = 1
            end
            page:add(text, nil, x, y, string.len(text) + x + 1, y,
                     colors.yellow, colors.green, colors.black, colors.white)
            x = x + string.len(text) + 3
        end
    end
end
function branchInfoCheck()
    BI = betterButton.new()
    local leftArrow = "<"
    local rightArrow = ">"
    local ar1 = {leftArrow, label = "ar1"}
    local ar2 = {leftArrow, label = "ar2"}
    local ar3 = {leftArrow, label = "ar3"}
    local ar4 = {rightArrow, label = "ar4"}
    local ar5 = {rightArrow, label = "ar5"}
    local ar6 = {rightArrow, label = "ar6"}
    BI:add(ar1, function() arrowFunc("dec", 1, 1) end, w - 8, 1, w - 8, 1,
           colors.orange, colors.green, colors.black, colors.white)
    BI:add(ar2, function() arrowFunc("dec", 2, 2) end, w - 8, 2, w - 8, 2,
           colors.orange, colors.green, colors.black, colors.white)
    BI:add(ar3, function() arrowFunc("dec", 3, 3) end, w - 8, 3, w - 8, 3,
           colors.orange, colors.green, colors.black, colors.white)
    BI:add(ar4, function() arrowFunc("inc", 1, 1) end, w, 1, w, 1,
           colors.orange, colors.green, colors.black, colors.white)
    BI:add(ar5, function() arrowFunc("inc", 2, 2) end, w, 2, w, 2,
           colors.orange, colors.green, colors.black, colors.white)
    BI:add(ar6, function() arrowFunc("inc", 3, 3) end, w, 3, w, 3,
           colors.orange, colors.green, colors.black, colors.white)
    BI:add("Mine", function() mineButton() end, w - 5, h, w, h, colors.yellow,
           colors.green, colors.black, colors.yellow)
    BI:add("Quit", function() quit(BI) end, math.ceil(w - (w / 2) - 3), h,
           math.ceil(w - (w / 2) + 2), h, colors.yellow, colors.green,
           colors.black, colors.yellow)
    BI:add("Back", function() backButton(BI) end, 1, h, 6, h, colors.yellow,
           colors.green, colors.black, colors.white)
    BI:add("1", function() setIncrement(1) end, w - 8, 4, w - 5, 4,
           colors.yellow, colors.green, colors.black, colors.white)
    BI:add("Left", function() pickSide("Left") end, 6, 7, 11, 7, colors.yellow,
           colors.green, colors.black, colors.white)
    BI:add("Right", function() pickSide("Right") end, 13, 7, 19, 7,
           colors.yellow, colors.green, colors.black, colors.white)
    BI:toggleButton("1")
    BI:toggleButton("Left")
    BI:add("10", function() setIncrement(10) end, w - 3, 4, w, 4, colors.yellow,
           colors.green, colors.black, colors.white)
    BI:draw()
    drawBranchStaticInfo()
    BI:run()
end
function drawBranchStaticInfo()
    term.setCursorPos(1, 1)
    setColors(colors.black, colors.orange, false)
    print("Strip Length:")
    term.setCursorPos(1, 2)
    print("Number of Strips:")
    term.setCursorPos(1, 3)
    print("Offset (unit: strips):")
    term.setCursorPos(1, 5)
    print("Which way to strip towards?")
    for i = 1, 3 do
        term.setCursorPos(w - 6, i)
        formatCheck(i)
    end
end
------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Buttons------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function pullClick(page)
    while true do
        local event, name, button = page:handleEvents(
                                        os.pullEvent("mouse_click"))
        buttonDecision(page, event, name, button)
    end
end
function drawPage(page)
    page:draw()
    pullClick(page)
end
function toggle(page, name, color)
    if (color ~= nil) then page.buttonList[name].activeColor = color end
    return page:toggleButton(name)
end
function buttonDecision(page, event, name, button)
    if (event == "button_click") then
        if (name == "Back") then
            backButton(page)
        elseif (name == "Next") then
            branchInfoCheck()
        elseif (name == "Quit") then
            quit(page)
        elseif (name == "None" or name == "All") then
            selectAllorNone(page, name)
        else
            if (button == 1) then
                toggle(page, name, colors.green)
                editFilteredOres(page, name)
            elseif (button == 2) then
                for i = 1, #oresPlain do
                    if (type(oresPlain[i]) == "table" and name ==
                        oresPlain[i][1]) then
                        if (page.buttonList[name].active == false) then
                            toggle(page, name, colors.brown)
                            drawPage(pages[i - 11])
                        elseif (page.buttonList[name].activeColor == 8192 and
                            page.buttonList[name].active == true) then
                            toggle(page, name)
                            editFilteredOres(page, name)
                            toggle(page, name, colors.brown)
                            drawPage(pages[i - 11])
                        end
                    else
                        toggle(page, name, colors.green)
                        editFilteredOres(page, name)
                    end
                end
            end
        end
    end
end
function backButton(page)
    page:flash("Back")
    sleep(0.15)
    for i = 1, #filteredOres do
        if (type(filteredOres[i]) ~= "table") then
            print(filteredOres[i])
        else
            for j = 1, #filteredOres[i] do print(filteredOres[i][j]) end
        end
    end
    if (page == pages[1]) then
        menu:draw()
        setColors(colors.black, colors.orange)
        term.setCursorPos(math.ceil(w / 2) - 8, 1)
        print("RJ's Branch Miner")
        menu:run()
    else
        drawPage(pages[1])
    end
    pullClick(pages[1])
end
function quit(page)
    page:flash("Quit")
    sleep(0.15)
    clear()
    error("Quitting!!!")
end
function arrowFunc(increment, var, height)
    if (increment == "inc" and lengths[var] + incNum <= 999) then
        lengths[var] = lengths[var] + incNum
    elseif (increment == "dec" and lengths[var] - incNum >= 0) then
        lengths[var] = lengths[var] - incNum
    end
    term.setCursorPos(w - 6, height)
    formatCheck(var)
end
function selectAllorNone(page, name)
    local state
    if (name == "All") then
        state = false
    else
        state = true
    end
    if (page.buttonList[name].active ~= true) then
        toggle(page, "None", colors.green)
        toggle(page, "All", colors.green)
    end
    for i = 1, #oresPlain do
        if (type(oresPlain[i]) ~= "table") then
            if (page.buttonList[oresPlain[i]].active == state) then
                toggle(page, oresPlain[i], colors.green)
                editFilteredOres(page, oresPlain[i])
            end
        elseif (type(oresPlain[i]) == "table") then
            if (page.buttonList[oresPlain[i][1]].active == state) then
                toggle(page, oresPlain[i][1], colors.green)
                editFilteredOres(page, oresPlain[i][1])
            end
        end
    end
end
function pickSide(lefRigh) -- function to ask which side to strip towards -----MESSED UPPPPPPP
    if (BI.buttonList[lefRigh].active == false) then
        side = lefRigh
        BI:toggleButton("Right")
        BI:toggleButton("Left")
        drawBranchStaticInfo()
    end
end
function setIncrement(value)
    if (BI.buttonList[tostring(value)].active == false) then
        incNum = value
        BI:toggleButton("1")
        BI:toggleButton("10")
        drawBranchStaticInfo()
    end
    drawBranchStaticInfo()
end
function mineButton() branchMine() end
------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------ORE CHECKING-------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function inspect()
    local success, block = t.inspectUp()
    for i = 1, #filteredOres do
        if (type(filteredOres[i] ~= "table") and block.name == filteredOres[i]) then
            digUp()
            up()
            table.insert(toVeinOrder, "up")
            table.insert(fromVeinOrder, 1, "down")
            inspect()
        elseif (type(filteredOres[i]) == "table" and block.name ==
            filteredOres[i][1]) then
            for j = 1, #filteredOres[i] do
                if (block.metadata == filteredOres[i][j]) then
                    digUp()
                    up()
                    table.insert(toVeinOrder, "up")
                    table.insert(fromVeinOrder, 1, "down")
                    inspect()
                end
            end
        end
    end
    local success, block = t.inspectDown()
    for i = 1, #filteredOres do
        if (type(filteredOres[i] ~= "table") and block.name == filteredOres[i]) then
            digDown()
            down()
            table.insert(fromVeinOrder, 1, "up")
            table.insert(toVeinOrder, "down")
            inspect()
        elseif (type(filteredOres[i]) == "table" and block.name ==
            filteredOres[i][1]) then
            for j = 1, #filteredOres[i] do
                if (block.metadata == filteredOres[i][j]) then
                    digDown()
                    down()
                    table.insert(toVeinOrder, "down")
                    table.insert(fromVeinOrder, 1, "up")
                    inspect()
                end
            end
        end
    end
    for j = 1, 4 do
        local success, block = t.inspect()
        for i = 1, #filteredOres do
            if (type(filteredOres[i] ~= "table") and block.name ==
                filteredOres[i]) then
				dig()
				forward(nil, nil, false)
                table.insert(toVeinOrder, "forward")
                table.insert(fromVeinOrder, 1, "back")
                inspect()
            elseif (type(filteredOres[i]) == "table" and block.name ==
                filteredOres[i][1]) then
                for j = 1, #filteredOres[i] do
                    if (block.metadata == filteredOres[i][j]) then
                        dig()
						forward(nil, nil, false)
                        table.insert(toVeinOrder, "forward")
                        table.insert(fromVeinOrder, 1, "back")
                        inspect()
                    end
                end
            end
        end
        t.turnRight()
        table.insert(fromVeinOrder, 1, "left")
        table.insert(toVeinOrder, "right")
    end
    fromVeinToStrip(true)
end
function findIndex(tableName, name)
    for index = 1, #tableName do
        if (type(tableName[index]) ~= "table") then
            if (tableName[index] == name) then return index, nil end
        elseif (type(tableName[index]) == "table") then
            for index2 = 1, #tableName[index] do
                if (tableName[index][index2] == name) then
                    return index, index2
                end
            end
        end
    end
end
function branchMine()
    clear()
    fuelCheck()
    shaft()
    for i = 1, lengths[2] do strip() end
    backToStart()
    dropInventory()
    done(true)
end
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------Strips----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function offsetShaft()
    for i = 1, ((lengths[2] - 1) * 3 - offset) do back(2, false) end
    turn(3)
end
function shaft()
    up()
    if (lengths[2] > 1) then
        turn(1)
        for i = 1, ((lengths[2] - 1) + lengths[3]) * 3 do
            dig()
            forward(0, 2, true)
            digDown()
        end
        turn(3)
    end
end
function strip()
    for i = 1, lengths[1] do
        dig()
        forward(0, 1, true)
        digDown()
    end
    down()
    inspect()
    returnToStripStart()
    if (distances[2] ~= ((lengths[1] + lengths[3]) * 3) - 3) then
        turn(1)
        for i = 1, 3 do back(2, true) end
        turn(3)
        up()
    end
end
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------Returning Places------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function fromVeinToStrip(check)
    for i = 1, #fromVeinOrder do
        if (check == true) then
            repeat
                local move = fromVeinOrder[i]
                if (move == "back") then
                   back(nil, false)
                elseif (move == "up") then
                    up()
                elseif (move == "down") then
                    down()
                end
                table.remove(fromVeinOrder, 1)
            until (move ~= "left")
            if (fromVeinOrder[1] == nil) then
                deleteTableContents(toVeinOrder)
                deleteTableContents(fromVeinOrder)
            end
            return
        elseif (check == false) then
            local move = fromVeinOrder[i]
			if (move == "back") then
				back(nil, false)
            elseif (move == "up") then
                up()
            elseif (move == "down") then
                down()
            elseif (move == "left") then
                t.turnLeft()
            end
        end
    end
    return
end
function toVeinfromStrip()
    for i = 1, #toVeinOrder do
        local move = toVeinOrder[i]
		if (move == "forward") then
			forward(nil, nil, false)
        elseif (move == "up") then
            up()
        elseif (move == "down") then
            down()
		elseif (move == "right") then
            t.turnRight()
        end
    end
    return
end
function returnToStripStart()
    while (distances[1] ~= 0) do back(1, true) end
end
function backToStripSpot()
    if (isUp == true) then 
        up() 
    end ---changed t.up() to up()
    turn(1)
    while (distances[4] > 0) do 
        forward(4, 2, false) 
    end
    if (distances[3] == 0) then
    else
        turn(3)
        while (distances[3] > 0) do 
            forward(3, 1, false) 
        end
    end
	distances[3] = 0
	distances[4] = 0
    toVeinfromStrip()
end
function backToStart()
    if (atStart == false) then
        fromVeinToStrip(false)
        if (orientation%4 ~= 0) then turn(4 - orientation%4) end
        distances[3] = distances[1]
        distances[4] = distances[2]
        while (distances[1] ~= 0) do back(1, false) end
        if (distances[1] == 0) then
            if (between == false) then turn(1) end
        end
        while (distances[2] ~= 0) do back(2, false) end
        turn(3)
        isUp = false
		local success, block = t.inspectDown()
		while (block.name ~= "minecraft:chest") do
            isUp = true
			down()
			success, block = t.inspectDown()
		end
		atStart = true
        distances[2] = 0
        distances[1] = 0
    end
    return
end
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------Dig--------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function dig()
    while (t.detect() == true) do
		t.dig()
			inventoryCheck()
        sleep(0.8)
    end
end

function digDown()
    while (t.detectDown() == true) do
        t.digDown()
        inventoryCheck()
        sleep(0.8)
    end
end

function digUp()
    while (t.detectUp() == true) do
        t.digUp()
        inventoryCheck()
        sleep(0.8)
    end
end
------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------Movement------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function up()
	while not (t.up()) do
		t.attackUp()
        digUp()
        sleep(0.8)
	end
	y = y + 1
	print(y)
    atStart = false
end
function down()
	while not (t.down()) do
		t.attackDown()
        digDown()
        sleep(0.8)
	end
	y = y - 1
	print(y)
end
function back(m, inspec)
	if (distances[m] == nil or distances[m] > 0) then
	    while not (t.back()) do
	        	turn(2)
	        if (t.detect()) then
	            dig()
	        else
	            for i = 1, 8 do t.attack() end
	        end
	        turn(2)
	    end
	    if (m ~= nil) then distances[m] = distances[m] - 1 end
	    if (atStart == true) then atStart = false end
		if (inspec == true) then inspect() end
	end
	print("Back")
	print(distances[m])
	print("--------")
end
function forward(m, p, inspec)
	if (distances[m] == nil or distances[m] > 0) then
    	while not (t.forward()) do
			if (t.detect()) then
       			dig()
       		else
        		t.attack()
        	end
	    end
	    if (distances[m] ~= nil and distances[m] > 0) then distances[m] = distances[m] - 1 end
	 	if (p ~= nil) then distances[p] = distances[p] + 1 end
	    if (atStart == true) then atStart = false end
	    if (inspec == true) then inspect() end
		fuelCheck()
	end
	print("Forward")
	print(distances[m])
	print(distances[p])
	print("--------")
end
function turn(x)
    if (side == "Left") then
        for i = 1, x do t.turnLeft() end
    else
        for i = 1, x do t.turnRight() end
    end
    orientation = orientation + x
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------MISC--------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function editFilteredOres(page, name)
    local index, index2 = findIndex(oresPlain, name)
    if (page.buttonList[name].active == true) then
        if (index2 == nil) then
            table.insert(filteredOres, 1, ores[index])
        else
            if (index2 ~= 1) then
                table.insert(filteredOres, 1,
                             {ores[index][1], ores[index][index2]})
            else
                table.insert(filteredOres, 1, ores[index][1])
            end
        end
    elseif (page.buttonList[name].active == false) then
        if (index2 == nil) then
            table.remove(filteredOres, findIndex(filteredOres, ores[index]))
        else
            table.remove(filteredOres,
                         findIndex(filteredOres, ores[index][index2])) -- not working with metadata values
        end
    end
end
function formatCheck(var)
    if (lengths[var] < 10) then
        print(" 00" .. lengths[var] .. " ")
    elseif (lengths[var] < 100) then
        print(" 0" .. lengths[var] .. " ")
    else
        print(" " .. lengths[var] .. " ")
    end
end
function dropInventory()
    if (atStart == false) then backToStart() end
    turn(2)
    for i = 1, 16 do
        t.select(i)
		if (t.getItemCount(i) > 0) then
			local data = t.getItemDetail()
			if (data.name == "minecraft:coal") then
				if (t.dropDown() == false) then
					done(false)
				end
			else
				if (t.drop() == false) then
					t.drop()
				end
			end
        end
    end
    turn(2)
end
function fuelCheck() -- Checks if there's fuel
    if ((distances[2] + distances[1]) >= (t.getFuelLevel() - 10)) then
        refuel()
    end
    return
end
function refuel() -- function to refuel
    if (atStart == true) then -- If the turtle is in starting position
        for i = 1, 16 do -- for all slots
            t.select(i)
            t.suckDown() -- suck coal from chest below
            t.refuel() -- refuel with that coal
        end
        return
    else -- if turtle isn't at starting position
        for i = 1, 16 do -- for all slots
            if (t.getItemCount(i) > 0) then
                    t.select(i)
                    t.refuel()
                    break -- has fuel so it can move forward
            end
        end
        backToStart() -- if not, go back to start to get some fuel
        refuel()
    end
    if (distances[3] + distances[4] < t.getFuelLevel() - 10) then
        backToStripSpot()
    else
        print("No fuel")
        done(false)
    end
    return
end
function inventoryCheck()
    for i = 1, 16 do
        if (t.getItemCount(i) == 0) then
            full = false
            return
        else
            full = true
        end
    end
    if (full == true) then
        dropInventory()
        backToStripSpot()
    end
end
function done(isDone)
    t.select(1)
    if (isDone == false) then
        print("This is how much fuel I have left: " .. t.getFuelLevel())
        error("I could not finish everything.")
    else
        print("I mined " .. lengths[2] .. ", " .. lengths[1] .. " block strips.")
        print("This is how much fuel I have left: " .. t.getFuelLevel())
        error("Done Mining")
    end
end
function clear()
    term.clear()
    term.setCursorPos(1, 1)
end
function deleteTableContents(table)
    count = #table
    for i = 0, count do table[i] = nil end
    count = 0
    return
end
function setColors(text, background, clear)
    clear = clear or false
    if (term.isColor() == true) then
        term.setTextColor(text)
        term.setBackgroundColor(background)
        if (clear == true) then term.clear() end
    end
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------MAIN--------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function main()
    initializePages()
    drawPage(pages[1])
end
mainMenu()