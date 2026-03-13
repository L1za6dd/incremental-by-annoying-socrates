local SAVE_FILE = "incremental_save.txt"
local ROLL_COST = 35000

local function formatNumber(n)
    if n >= 1e15 then return string.format("%.2fQa", n / 1e15)
    elseif n >= 1e12 then return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

local titles = {
    { name = "None", mult = 1, color = Color3.fromRGB(140, 140, 140) },
    { name = "Matcha Buyer", mult = 1.1, color = Color3.fromRGB(120, 255, 120) },
    { name = "Script Developer", mult = 1.5, color = Color3.fromRGB(100, 200, 255) },
    { name = "Vetted Script Developer", mult = 3, color = Color3.fromRGB(50, 130, 255) },
    { name = "LUA Lead", mult = 8, color = Color3.fromRGB(255, 200, 50) },
    { name = "Executive", mult = 30, color = Color3.fromRGB(255, 50, 50) },
    { name = "The Elite", mult = 100, color = Color3.fromRGB(255, 255, 255) },
}

local state = {
    coins = 0,
    clickPower = 1,
    clickMultiplier = 1,
    perSecond = 0,
    running = true,
    currentTab = 1,
    rolling = false,
    titleIndex = 1,
    upgrades = {
        click = { level = 0, baseCost = 10, costMult = 1.5 },
        auto  = { level = 0, baseCost = 75, costMult = 2.0 },
        multi = { level = 0, baseCost = 500, costMult = 3.0 },
    },
    rebirths = 0,
    rebirthTokens = 0,
    rebirthUpgrades = {
        startCoins = { level = 0 },
        permClick  = { level = 0 },
    },
    prestige = 0,
}

local btn = {}
local labels = {}
local allObjects = {}
local tabObjects = { {}, {}, {}, {} }
local objectData = {}
local px, py = 100, 40
local pw, ph = 380, 640
local dragging = false
local dragOffX, dragOffY = 0, 0

local function makeSquare(x, y, w, h, color, zi, tab)
    local s = Drawing.new("Square")
    s.Position = Vector2.new(x, y)
    s.Size = Vector2.new(w, h)
    s.Color = color
    s.Filled = true
    s.Visible = true
    s.ZIndex = zi or 1
    s.Transparency = 1
    table.insert(allObjects, s)
    table.insert(objectData, {obj = s, ox = x - px, oy = y - py})
    if tab then table.insert(tabObjects[tab], s) end
    return s
end

local function makeText(x, y, str, sz, color, center, zi, tab)
    local t = Drawing.new("Text")
    t.Position = Vector2.new(x, y)
    t.Text = str
    t.Size = sz or 18
    t.Color = color or Color3.fromRGB(255, 255, 255)
    t.Center = center or false
    t.Outline = true
    t.Visible = true
    t.ZIndex = zi or 5
    t.Transparency = 1
    table.insert(allObjects, t)
    table.insert(objectData, {obj = t, ox = x - px, oy = y - py})
    if tab then table.insert(tabObjects[tab], t) end
    return t
end

local function regBtn(name, x, y, w, h)
    btn[name] = {x = x, y = y, w = w, h = h, ox = x - px, oy = y - py}
end

local function hit(mx, my, b)
    return mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h
end

local function hitXY(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function switchTab(tabNum)
    state.currentTab = tabNum
    for i = 1, 4 do
        for _, obj in ipairs(tabObjects[i]) do obj.Visible = (i == tabNum) end
    end
end

local function repositionAll()
    for _, d in ipairs(objectData) do
        d.obj.Position = Vector2.new(px + d.ox, py + d.oy)
    end
    for _, b in pairs(btn) do
        b.x = px + b.ox
        b.y = py + b.oy
    end
end

makeSquare(px, py, pw, ph, Color3.fromRGB(18, 18, 30), 1)
makeSquare(px, py, pw, 42, Color3.fromRGB(35, 35, 65), 2)
makeText(px + pw / 2, py + 10, "INCREMENTAL GAME v2", 22, Color3.fromRGB(255, 215, 0), true, 6)
makeText(px + 10, py + 15, "::::", 14, Color3.fromRGB(80, 80, 120), false, 6)

regBtn("close", px + pw - 38, py + 6, 30, 30)
makeSquare(btn.close.x, btn.close.y, 30, 30, Color3.fromRGB(180, 40, 40), 3)
makeText(btn.close.x + 15, btn.close.y + 5, "X", 18, Color3.fromRGB(255, 255, 255), true, 6)

local tabY = py + 44
local tabW = math.floor(pw / 4)

regBtn("tab1", px, tabY, tabW, 32)
regBtn("tab2", px + tabW, tabY, tabW, 32)
regBtn("tab3", px + tabW * 2, tabY, tabW, 32)
regBtn("tab4", px + tabW * 3, tabY, pw - tabW * 3, 32)

labels.tab1Bg = makeSquare(btn.tab1.x, btn.tab1.y, tabW, 32, Color3.fromRGB(50, 50, 90), 3)
labels.tab2Bg = makeSquare(btn.tab2.x, btn.tab2.y, tabW, 32, Color3.fromRGB(30, 30, 50), 3)
labels.tab3Bg = makeSquare(btn.tab3.x, btn.tab3.y, tabW, 32, Color3.fromRGB(30, 30, 50), 3)
labels.tab4Bg = makeSquare(btn.tab4.x, btn.tab4.y, pw - tabW * 3, 32, Color3.fromRGB(30, 30, 50), 3)
labels.tab1Label = makeText(btn.tab1.x + tabW / 2, tabY + 8, "MAIN", 13, Color3.fromRGB(255, 255, 255), true, 6)
labels.tab2Label = makeText(btn.tab2.x + tabW / 2, tabY + 8, "REBIRTH", 11, Color3.fromRGB(140, 140, 140), true, 6)
labels.tab3Label = makeText(btn.tab3.x + tabW / 2, tabY + 8, "ROLL", 13, Color3.fromRGB(140, 140, 140), true, 6)
labels.tab4Label = makeText(btn.tab4.x + (pw - tabW * 3) / 2, tabY + 8, "CONFIG", 11, Color3.fromRGB(140, 140, 140), true, 6)

local contentY = tabY + 34

makeSquare(px, py + ph - 28, pw, 28, Color3.fromRGB(25, 25, 42), 2)
makeText(px + pw / 2, py + ph - 22, "Made by a very annoying socratee, with love", 12, Color3.fromRGB(80, 80, 100), true, 5)

do
    local cY = contentY + 5
    labels.coins = makeText(px + 20, cY, "Coins: 0", 22, Color3.fromRGB(255, 255, 80), false, 5, 1)
    cY = cY + 28
    labels.stats = makeText(px + 20, cY, "Click: 1 | /Sec: 0", 13, Color3.fromRGB(180, 180, 200), false, 5, 1)
    cY = cY + 20
    labels.mult = makeText(px + 20, cY, "Total Mult: x1", 12, Color3.fromRGB(140, 140, 200), false, 5, 1)
    cY = cY + 18
    labels.title = makeText(px + 20, cY, "Title: None", 12, Color3.fromRGB(140, 140, 140), false, 5, 1)
    cY = cY + 20
    makeSquare(px + 15, cY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 1)
    cY = cY + 8

    regBtn("click", px + 30, cY, pw - 60, 70)
    labels.clickBg = makeSquare(btn.click.x, btn.click.y, pw - 60, 70, Color3.fromRGB(40, 160, 70), 2, 1)
    makeText(btn.click.x + (pw - 60) / 2, btn.click.y + 10, ">>> CLICK <<<", 24, Color3.fromRGB(255, 255, 255), true, 6, 1)
    labels.clickSub = makeText(btn.click.x + (pw - 60) / 2, btn.click.y + 44, "+1 coins", 14, Color3.fromRGB(210, 255, 210), true, 6, 1)
    cY = cY + 80

    makeSquare(px + 15, cY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 1)
    cY = cY + 6
    makeText(px + 20, cY, "[ UPGRADES ]", 16, Color3.fromRGB(160, 160, 255), false, 5, 1)
    cY = cY + 24

    makeSquare(px + 15, cY, pw - 30, 60, Color3.fromRGB(35, 35, 60), 2, 1)
    makeText(px + 25, cY + 4, "Click Power +1", 14, Color3.fromRGB(255, 200, 80), false, 5, 1)
    labels.u1Info = makeText(px + 25, cY + 22, "Level: 0", 12, Color3.fromRGB(160, 160, 160), false, 5, 1)
    labels.u1Cost = makeText(px + 25, cY + 38, "Cost: 10", 12, Color3.fromRGB(255, 255, 100), false, 5, 1)
    regBtn("buy1", px + pw - 83, cY + 16, 58, 28)
    labels.b1Bg = makeSquare(btn.buy1.x, btn.buy1.y, 58, 28, Color3.fromRGB(40, 150, 40), 3, 1)
    makeText(btn.buy1.x + 29, btn.buy1.y + 4, "BUY", 16, Color3.fromRGB(255, 255, 255), true, 6, 1)
    cY = cY + 66

    makeSquare(px + 15, cY, pw - 30, 60, Color3.fromRGB(35, 35, 60), 2, 1)
    makeText(px + 25, cY + 4, "Auto Clicker +1 click/s", 14, Color3.fromRGB(80, 200, 255), false, 5, 1)
    labels.u2Info = makeText(px + 25, cY + 22, "Level: 0", 12, Color3.fromRGB(160, 160, 160), false, 5, 1)
    labels.u2Cost = makeText(px + 25, cY + 38, "Cost: 75", 12, Color3.fromRGB(255, 255, 100), false, 5, 1)
    regBtn("buy2", px + pw - 83, cY + 16, 58, 28)
    labels.b2Bg = makeSquare(btn.buy2.x, btn.buy2.y, 58, 28, Color3.fromRGB(40, 150, 40), 3, 1)
    makeText(btn.buy2.x + 29, btn.buy2.y + 4, "BUY", 16, Color3.fromRGB(255, 255, 255), true, 6, 1)
    cY = cY + 66

    makeSquare(px + 15, cY, pw - 30, 60, Color3.fromRGB(35, 35, 60), 2, 1)
    makeText(px + 25, cY + 4, "Click Multiplier x2", 14, Color3.fromRGB(255, 100, 200), false, 5, 1)
    labels.u3Info = makeText(px + 25, cY + 22, "Level: 0 (x1)", 12, Color3.fromRGB(160, 160, 160), false, 5, 1)
    labels.u3Cost = makeText(px + 25, cY + 38, "Cost: 500", 12, Color3.fromRGB(255, 255, 100), false, 5, 1)
    regBtn("buy3", px + pw - 83, cY + 16, 58, 28)
    labels.b3Bg = makeSquare(btn.buy3.x, btn.buy3.y, 58, 28, Color3.fromRGB(40, 150, 40), 3, 1)
    makeText(btn.buy3.x + 29, btn.buy3.y + 4, "BUY", 16, Color3.fromRGB(255, 255, 255), true, 6, 1)
end

do
    local rY = contentY + 5
    makeText(px + 20, rY, "[ REBIRTH ]", 18, Color3.fromRGB(255, 180, 50), false, 5, 2)
    rY = rY + 26
    labels.rbStats = makeText(px + 20, rY, "Rebirths: 0 | Tokens: 0", 14, Color3.fromRGB(255, 220, 120), false, 5, 2)
    rY = rY + 20
    labels.rbMult = makeText(px + 20, rY, "Rebirth Multiplier: x1.0", 13, Color3.fromRGB(200, 200, 160), false, 5, 2)
    rY = rY + 20
    labels.rbReq = makeText(px + 20, rY, "Requirement: 15,000 coins", 13, Color3.fromRGB(180, 180, 180), false, 5, 2)
    rY = rY + 24

    regBtn("rebirth", px + 30, rY, pw - 60, 42)
    labels.rbBg = makeSquare(btn.rebirth.x, btn.rebirth.y, pw - 60, 42, Color3.fromRGB(180, 120, 30), 3, 2)
    makeText(btn.rebirth.x + (pw - 60) / 2, btn.rebirth.y + 10, "REBIRTH", 20, Color3.fromRGB(255, 255, 255), true, 6, 2)
    rY = rY + 54

    makeSquare(px + 15, rY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 2)
    rY = rY + 8
    makeText(px + 20, rY, "[ REBIRTH UPGRADES ]", 15, Color3.fromRGB(255, 200, 100), false, 5, 2)
    rY = rY + 22

    makeSquare(px + 15, rY, pw - 30, 58, Color3.fromRGB(40, 35, 25), 2, 2)
    makeText(px + 25, rY + 4, "Starting Coins (+1,000)", 13, Color3.fromRGB(255, 220, 100), false, 5, 2)
    labels.ru1Info = makeText(px + 25, rY + 21, "Level: 0 (+0 coins)", 12, Color3.fromRGB(160, 160, 140), false, 5, 2)
    labels.ru1Cost = makeText(px + 25, rY + 38, "Cost: 1 Token", 12, Color3.fromRGB(255, 200, 80), false, 5, 2)
    regBtn("rbuy1", px + pw - 83, rY + 16, 58, 28)
    labels.rb1Bg = makeSquare(btn.rbuy1.x, btn.rbuy1.y, 58, 28, Color3.fromRGB(150, 100, 20), 3, 2)
    makeText(btn.rbuy1.x + 29, btn.rbuy1.y + 4, "BUY", 16, Color3.fromRGB(255, 255, 255), true, 6, 2)
    rY = rY + 64

    makeSquare(px + 15, rY, pw - 30, 58, Color3.fromRGB(40, 35, 25), 2, 2)
    makeText(px + 25, rY + 4, "Permanent Click (+15)", 13, Color3.fromRGB(255, 180, 80), false, 5, 2)
    labels.ru2Info = makeText(px + 25, rY + 21, "Level: 0 (+0 click)", 12, Color3.fromRGB(160, 160, 140), false, 5, 2)
    labels.ru2Cost = makeText(px + 25, rY + 38, "Cost: 2 Tokens", 12, Color3.fromRGB(255, 200, 80), false, 5, 2)
    regBtn("rbuy2", px + pw - 83, rY + 16, 58, 28)
    labels.rb2Bg = makeSquare(btn.rbuy2.x, btn.rbuy2.y, 58, 28, Color3.fromRGB(150, 100, 20), 3, 2)
    makeText(btn.rbuy2.x + 29, btn.rbuy2.y + 4, "BUY", 16, Color3.fromRGB(255, 255, 255), true, 6, 2)
    rY = rY + 70

    makeSquare(px + 15, rY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 2)
    rY = rY + 8
    makeText(px + 20, rY, "[ PRESTIGE ]", 18, Color3.fromRGB(200, 100, 255), false, 5, 2)
    rY = rY + 26
    labels.prStats = makeText(px + 20, rY, "Prestige: 0", 14, Color3.fromRGB(220, 160, 255), false, 5, 2)
    rY = rY + 20
    labels.prMult = makeText(px + 20, rY, "Prestige Multiplier: x1", 13, Color3.fromRGB(200, 160, 220), false, 5, 2)
    rY = rY + 20
    labels.prReq = makeText(px + 20, rY, "Requirement: 10 Rebirths", 13, Color3.fromRGB(180, 180, 180), false, 5, 2)
    rY = rY + 24

    regBtn("prestige", px + 30, rY, pw - 60, 42)
    labels.prBg = makeSquare(btn.prestige.x, btn.prestige.y, pw - 60, 42, Color3.fromRGB(130, 50, 200), 3, 2)
    makeText(btn.prestige.x + (pw - 60) / 2, btn.prestige.y + 10, "PRESTIGE", 20, Color3.fromRGB(255, 255, 255), true, 6, 2)
end

do
    local gY = contentY + 5
    makeText(px + 20, gY, "[ TITLE ROULETTE ]", 18, Color3.fromRGB(255, 220, 50), false, 5, 3)
    gY = gY + 28
    makeText(px + 20, gY, "Roll for a random title!", 13, Color3.fromRGB(180, 180, 200), false, 5, 3)
    gY = gY + 18
    makeText(px + 20, gY, "Each title gives a coin multiplier.", 13, Color3.fromRGB(180, 180, 200), false, 5, 3)
    gY = gY + 18
    makeText(px + 20, gY, "New rolls replace your current title.", 13, Color3.fromRGB(180, 180, 200), false, 5, 3)
    gY = gY + 24
    makeText(px + 20, gY, "Current Title:", 14, Color3.fromRGB(200, 200, 220), false, 5, 3)
    gY = gY + 20
    labels.rollTitle = makeText(px + 20, gY, "None", 20, Color3.fromRGB(140, 140, 140), false, 5, 3)
    gY = gY + 22
    labels.rollTitleMult = makeText(px + 20, gY, "Multiplier: x1", 13, Color3.fromRGB(180, 180, 180), false, 5, 3)
    gY = gY + 24

    makeSquare(px + 15, gY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 3)
    gY = gY + 8

    labels.rollBoxBg = makeSquare(px + 25, gY, pw - 50, 80, Color3.fromRGB(25, 25, 45), 2, 3)
    makeSquare(px + 25, gY, pw - 50, 2, Color3.fromRGB(255, 215, 0), 4, 3)
    makeSquare(px + 25, gY + 78, pw - 50, 2, Color3.fromRGB(255, 215, 0), 4, 3)
    makeSquare(px + 25, gY, 2, 80, Color3.fromRGB(255, 215, 0), 4, 3)
    makeSquare(px + pw - 27, gY, 2, 80, Color3.fromRGB(255, 215, 0), 4, 3)
    labels.rollResult = makeText(px + pw / 2, gY + 18, "???", 28, Color3.fromRGB(100, 100, 100), true, 6, 3)
    labels.rollResultMult = makeText(px + pw / 2, gY + 52, "", 14, Color3.fromRGB(180, 180, 180), true, 6, 3)
    gY = gY + 92

    regBtn("roll", px + 30, gY, pw - 60, 50)
    labels.rollBg = makeSquare(btn.roll.x, btn.roll.y, pw - 60, 50, Color3.fromRGB(200, 160, 30), 3, 3)
    makeText(btn.roll.x + (pw - 60) / 2, btn.roll.y + 6, "ROLL!", 24, Color3.fromRGB(255, 255, 255), true, 6, 3)
    makeText(btn.roll.x + (pw - 60) / 2, btn.roll.y + 32, "Cost: 35K coins", 12, Color3.fromRGB(255, 255, 200), true, 6, 3)
    gY = gY + 62

    makeSquare(px + 15, gY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 3)
    gY = gY + 8
    makeText(px + 20, gY, "[ DROP RATES ]", 14, Color3.fromRGB(180, 180, 200), false, 5, 3)
    gY = gY + 20

    local drops = {
        {"Matcha Buyer (x1.1)", "60%", 2},
        {"Script Developer (x1.5)", "30%", 3},
        {"Vetted Script Dev (x3)", "5%", 4},
        {"LUA Lead (x8)", "4.3%", 5},
        {"Executive (x30)", "0.9%", 6},
        {"The Elite (x100)", "0.1%", 7},
    }
    local bgColors = {
        Color3.fromRGB(30, 40, 30), Color3.fromRGB(25, 35, 40),
        Color3.fromRGB(20, 25, 40), Color3.fromRGB(40, 35, 20),
        Color3.fromRGB(45, 20, 20), Color3.fromRGB(50, 50, 50),
    }
    for i, d in ipairs(drops) do
        makeSquare(px + 15, gY, pw - 30, 20, bgColors[i], 2, 3)
        makeText(px + 22, gY + 3, d[1], 12, titles[d[3]].color, false, 5, 3)
        makeText(px + pw - 60, gY + 3, d[2], 12, titles[d[3]].color, false, 5, 3)
        gY = gY + 22
    end
end

do
    local sY = contentY + 5
    makeText(px + 20, sY, "[ SAVE & LOAD ]", 18, Color3.fromRGB(100, 200, 150), false, 5, 4)
    sY = sY + 30
    makeText(px + 20, sY, "Save your progress to a local file.", 13, Color3.fromRGB(160, 160, 180), false, 5, 4)
    sY = sY + 18
    makeText(px + 20, sY, "Auto-saves every 60 seconds.", 13, Color3.fromRGB(160, 160, 180), false, 5, 4)
    sY = sY + 18
    makeText(px + 20, sY, "File: " .. SAVE_FILE, 13, Color3.fromRGB(120, 180, 140), false, 5, 4)
    sY = sY + 18
    labels.saveStatus = makeText(px + 20, sY, "Status: No save found", 13, Color3.fromRGB(180, 180, 100), false, 5, 4)
    sY = sY + 30

    regBtn("save", px + 30, sY, pw - 60, 45)
    makeSquare(btn.save.x, btn.save.y, pw - 60, 45, Color3.fromRGB(30, 140, 80), 3, 4)
    makeText(btn.save.x + (pw - 60) / 2, btn.save.y + 12, "SAVE GAME", 20, Color3.fromRGB(255, 255, 255), true, 6, 4)
    sY = sY + 57

    regBtn("load", px + 30, sY, pw - 60, 45)
    makeSquare(btn.load.x, btn.load.y, pw - 60, 45, Color3.fromRGB(30, 100, 180), 3, 4)
    makeText(btn.load.x + (pw - 60) / 2, btn.load.y + 12, "LOAD GAME", 20, Color3.fromRGB(255, 255, 255), true, 6, 4)
    sY = sY + 65

    makeSquare(px + 15, sY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 4)
    sY = sY + 10
    makeText(px + 20, sY, "[ DANGER ZONE ]", 16, Color3.fromRGB(255, 80, 80), false, 5, 4)
    sY = sY + 26

    regBtn("reset", px + 30, sY, pw - 60, 40)
    makeSquare(btn.reset.x, btn.reset.y, pw - 60, 40, Color3.fromRGB(160, 30, 30), 3, 4)
    makeText(btn.reset.x + (pw - 60) / 2, btn.reset.y + 10, "RESET ALL PROGRESS", 16, Color3.fromRGB(255, 255, 255), true, 6, 4)
    sY = sY + 50
    makeText(px + 20, sY, "Warning: This cannot be undone!", 12, Color3.fromRGB(200, 80, 80), false, 5, 4)
    sY = sY + 30

    makeSquare(px + 15, sY, pw - 30, 1, Color3.fromRGB(70, 70, 110), 2, 4)
    sY = sY + 10
    makeText(px + 20, sY, "[ EXPORT / IMPORT ]", 16, Color3.fromRGB(180, 160, 255), false, 5, 4)
    sY = sY + 26

    regBtn("export", px + 30, sY, pw - 60, 40)
    makeSquare(btn.export.x, btn.export.y, pw - 60, 40, Color3.fromRGB(100, 60, 160), 3, 4)
    makeText(btn.export.x + (pw - 60) / 2, btn.export.y + 10, "COPY SAVE TO CLIPBOARD", 14, Color3.fromRGB(255, 255, 255), true, 6, 4)
end

local function serializeState()
    local p = {
        math.floor(state.coins), state.clickPower, state.clickMultiplier,
        state.perSecond, state.upgrades.click.level, state.upgrades.auto.level,
        state.upgrades.multi.level, state.rebirths, state.rebirthTokens,
        state.rebirthUpgrades.startCoins.level, state.rebirthUpgrades.permClick.level,
        state.prestige, state.titleIndex
    }
    local s = {}
    for i, v in ipairs(p) do s[i] = tostring(v) end
    return table.concat(s, ",")
end

local function deserializeState(data)
    local p = {}
    for val in string.gmatch(data, "([^,]+)") do table.insert(p, tonumber(val) or 0) end
    if #p < 12 then return false end
    state.coins = p[1]; state.clickPower = p[2]; state.clickMultiplier = p[3]
    state.perSecond = p[4]; state.upgrades.click.level = p[5]; state.upgrades.auto.level = p[6]
    state.upgrades.multi.level = p[7]; state.rebirths = p[8]; state.rebirthTokens = p[9]
    state.rebirthUpgrades.startCoins.level = p[10]; state.rebirthUpgrades.permClick.level = p[11]
    state.prestige = p[12]; state.titleIndex = p[13] or 1
    if state.titleIndex < 1 or state.titleIndex > #titles then state.titleIndex = 1 end
    return true
end

local function saveGame()
    local ok, err = pcall(function()
        writefile(SAVE_FILE, base64encode(serializeState()))
    end)
    notify(ok and "Game Saved!" or "Save Failed!", ok and ("Progress saved to " .. SAVE_FILE) or tostring(err), ok and 2 or 3)
end

local function loadGame()
    pcall(function()
        if not isfile(SAVE_FILE) then notify("No Save Found", "Starting fresh!", 2); return end
        if deserializeState(base64decode(readfile(SAVE_FILE))) then
            notify("Game Loaded!", "Welcome back!", 2)
        else
            notify("Load Failed!", "Save data corrupted", 3)
        end
    end)
end

local function getCost(upg) return math.floor(upg.baseCost * (upg.costMult ^ upg.level)) end
local function rebirthMultiplier() return 1 + (state.rebirths * 0.5) end
local function prestigeMultiplier() return 3 ^ state.prestige end
local function titleMultiplier() return titles[state.titleIndex].mult end
local function totalMultiplier() return rebirthMultiplier() * prestigeMultiplier() * titleMultiplier() end
local function effectiveClick() return (state.clickPower + state.rebirthUpgrades.permClick.level * 15) * state.clickMultiplier * totalMultiplier() end
local function effectivePerSecond() return state.perSecond * (state.clickPower + state.rebirthUpgrades.permClick.level * 15) end
local function rebirthCost() return math.floor(15000 * (3 ^ state.rebirths)) end
local function prestigeCost() return 10 * (state.prestige + 1) end

local function rebirthUpgCost(name)
    if name == "startCoins" then return 1 + state.rebirthUpgrades.startCoins.level
    else return 2 + state.rebirthUpgrades.permClick.level * 2 end
end

local function rollTitle()
    local roll = math.random(1, 10000)
    if roll <= 5970 then return 2
    elseif roll <= 8970 then return 3
    elseif roll <= 9470 then return 4
    elseif roll <= 9900 then return 5
    elseif roll <= 9990 then return 6
    else return 7 end
end

local function updateUI()
    local ec, eps = effectiveClick(), effectivePerSecond()
    local ct = titles[state.titleIndex]

    labels.coins.Text = "Coins: " .. formatNumber(state.coins)
    labels.stats.Text = "Click: " .. formatNumber(ec) .. "  |  /Sec: " .. formatNumber(eps)
    labels.mult.Text = "Total Mult: x" .. formatNumber(totalMultiplier())
    labels.clickSub.Text = "+" .. formatNumber(ec) .. " coins"
    labels.title.Text = "Title: " .. ct.name .. " (x" .. ct.mult .. ")"
    labels.title.Color = ct.color

    local c1 = getCost(state.upgrades.click)
    labels.u1Info.Text = "Level: " .. state.upgrades.click.level
    labels.u1Cost.Text = "Cost: " .. formatNumber(c1)
    labels.b1Bg.Color = state.coins >= c1 and Color3.fromRGB(40, 170, 40) or Color3.fromRGB(120, 40, 40)

    local c2 = getCost(state.upgrades.auto)
    labels.u2Info.Text = "Level: " .. state.upgrades.auto.level .. " (" .. state.perSecond .. " clicks/s)"
    labels.u2Cost.Text = "Cost: " .. formatNumber(c2)
    labels.b2Bg.Color = state.coins >= c2 and Color3.fromRGB(40, 170, 40) or Color3.fromRGB(120, 40, 40)

    local c3 = getCost(state.upgrades.multi)
    labels.u3Info.Text = "Level: " .. state.upgrades.multi.level .. " (x" .. state.clickMultiplier .. ")"
    labels.u3Cost.Text = "Cost: " .. formatNumber(c3)
    labels.b3Bg.Color = state.coins >= c3 and Color3.fromRGB(40, 170, 40) or Color3.fromRGB(120, 40, 40)

    labels.rbStats.Text = "Rebirths: " .. state.rebirths .. "  |  Tokens: " .. state.rebirthTokens
    labels.rbMult.Text = "Rebirth Multiplier: x" .. string.format("%.1f", rebirthMultiplier())
    labels.rbReq.Text = "Requirement: " .. formatNumber(rebirthCost()) .. " coins"
    labels.rbBg.Color = state.coins >= rebirthCost() and Color3.fromRGB(200, 140, 30) or Color3.fromRGB(100, 60, 20)

    local rc1 = rebirthUpgCost("startCoins")
    labels.ru1Info.Text = "Level: " .. state.rebirthUpgrades.startCoins.level .. " (+" .. (state.rebirthUpgrades.startCoins.level * 1000) .. " coins)"
    labels.ru1Cost.Text = "Cost: " .. rc1 .. " Token" .. (rc1 > 1 and "s" or "")
    labels.rb1Bg.Color = state.rebirthTokens >= rc1 and Color3.fromRGB(180, 130, 30) or Color3.fromRGB(80, 50, 20)

    local rc2 = rebirthUpgCost("permClick")
    labels.ru2Info.Text = "Level: " .. state.rebirthUpgrades.permClick.level .. " (+" .. (state.rebirthUpgrades.permClick.level * 15) .. " click)"
    labels.ru2Cost.Text = "Cost: " .. rc2 .. " Tokens"
    labels.rb2Bg.Color = state.rebirthTokens >= rc2 and Color3.fromRGB(180, 130, 30) or Color3.fromRGB(80, 50, 20)

    local pCost = prestigeCost()
    labels.prStats.Text = "Prestige: " .. state.prestige
    labels.prMult.Text = "Prestige Multiplier: x" .. formatNumber(prestigeMultiplier())
    labels.prReq.Text = "Requirement: " .. pCost .. " Rebirths"
    labels.prBg.Color = state.rebirths >= pCost and Color3.fromRGB(160, 60, 240) or Color3.fromRGB(60, 20, 80)

    labels.rollTitle.Text = ct.name; labels.rollTitle.Color = ct.color
    labels.rollTitleMult.Text = "Multiplier: x" .. ct.mult
    labels.rollBg.Color = (state.coins >= ROLL_COST and not state.rolling) and Color3.fromRGB(200, 160, 30) or Color3.fromRGB(80, 60, 15)

    if isfile(SAVE_FILE) then
        labels.saveStatus.Text = "Status: Save file found"; labels.saveStatus.Color = Color3.fromRGB(100, 220, 100)
    else
        labels.saveStatus.Text = "Status: No save found"; labels.saveStatus.Color = Color3.fromRGB(180, 180, 100)
    end

    local tabBgs = {labels.tab1Bg, labels.tab2Bg, labels.tab3Bg, labels.tab4Bg}
    local tabLbls = {labels.tab1Label, labels.tab2Label, labels.tab3Label, labels.tab4Label}
    for i = 1, 4 do
        tabBgs[i].Color = (i == state.currentTab) and Color3.fromRGB(50, 50, 90) or Color3.fromRGB(30, 30, 50)
        tabLbls[i].Color = (i == state.currentTab) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
    end
end

local function doClick()
    state.coins = state.coins + effectiveClick()
    labels.clickBg.Color = Color3.fromRGB(60, 220, 100)
    task.spawn(function()
        task.wait(0.08)
        if state.running then labels.clickBg.Color = Color3.fromRGB(40, 160, 70) end
    end)
    updateUI()
end

local function buyUpgrade(name)
    local upg = state.upgrades[name]
    local cost = getCost(upg)
    if state.coins < cost then notify("Not Enough Coins!", "Need " .. formatNumber(cost), 2); return end
    state.coins = state.coins - cost
    upg.level = upg.level + 1
    if name == "click" then state.clickPower = state.clickPower + 1
    elseif name == "auto" then state.perSecond = state.perSecond + 1
    elseif name == "multi" then state.clickMultiplier = state.clickMultiplier * 2 end
    updateUI()
end

local function doRebirth()
    local cost = rebirthCost()
    if state.coins < cost then notify("Can't Rebirth!", "Need " .. formatNumber(cost) .. " coins", 2); return end
    state.rebirths = state.rebirths + 1
    state.rebirthTokens = state.rebirthTokens + 1
    local sc = state.rebirthUpgrades.startCoins.level * 1000
    state.coins = sc; state.clickPower = 1; state.clickMultiplier = 1; state.perSecond = 0
    state.upgrades.click.level = 0; state.upgrades.auto.level = 0; state.upgrades.multi.level = 0
    notify("REBIRTH #" .. state.rebirths, "x" .. string.format("%.1f", rebirthMultiplier()) .. " multiplier! +" .. sc .. " starting coins", 3)
    updateUI()
end

local function buyRebirthUpgrade(name)
    local cost = rebirthUpgCost(name)
    if state.rebirthTokens < cost then notify("Not Enough Tokens!", "Need " .. cost .. " tokens", 2); return end
    state.rebirthTokens = state.rebirthTokens - cost
    state.rebirthUpgrades[name].level = state.rebirthUpgrades[name].level + 1
    local lvl = state.rebirthUpgrades[name].level
    if name == "startCoins" then notify("Upgraded!", "Starting Coins Lv." .. lvl .. " (+" .. (lvl * 1000) .. ")", 2)
    else notify("Upgraded!", "Perm Click Lv." .. lvl .. " (+" .. (lvl * 15) .. ")", 2) end
    updateUI()
end

local function doPrestige()
    local cost = prestigeCost()
    if state.rebirths < cost then notify("Can't Prestige!", "Need " .. cost .. " rebirths (have " .. state.rebirths .. ")", 2); return end
    state.prestige = state.prestige + 1
    state.coins = 0; state.clickPower = 1; state.clickMultiplier = 1; state.perSecond = 0
    state.rebirths = 0; state.rebirthTokens = 0
    state.upgrades.click.level = 0; state.upgrades.auto.level = 0; state.upgrades.multi.level = 0
    state.rebirthUpgrades.startCoins.level = 0; state.rebirthUpgrades.permClick.level = 0
    state.titleIndex = 1
    notify("PRESTIGE " .. state.prestige .. "!", "x" .. formatNumber(prestigeMultiplier()) .. " permanent multiplier!", 4)
    updateUI()
end

local function doRoulette()
    if state.rolling then return end
    if state.coins < ROLL_COST then notify("Not Enough Coins!", "Need " .. formatNumber(ROLL_COST) .. " coins", 2); return end
    state.coins = state.coins - ROLL_COST; state.rolling = true; updateUI()
    task.spawn(function()
        local finalIndex = rollTitle()
        local spins = 20 + math.random(5, 15)
        for i = 1, spins do
            local fi = (i == spins) and finalIndex or math.random(2, #titles)
            local t = titles[fi]
            labels.rollResult.Text = t.name; labels.rollResult.Color = t.color
            labels.rollResultMult.Text = "x" .. t.mult .. " multiplier"; labels.rollResultMult.Color = t.color
            labels.rollBoxBg.Color = Color3.fromRGB(math.random(20, 50), math.random(20, 50), math.random(30, 60))
            task.wait(0.05 + (i / spins) * 0.25)
        end
        state.titleIndex = finalIndex
        local won = titles[finalIndex]
        labels.rollBoxBg.Color = Color3.fromRGB(25, 25, 45)
        labels.rollResult.Text = won.name; labels.rollResult.Color = won.color
        labels.rollResultMult.Text = "x" .. won.mult .. " multiplier!"; labels.rollResultMult.Color = won.color
        local msgs = {[7] = {"MYTHICAL!!!", "The Elite! x100!", 6}, [6] = {"LEGENDARY!!!", "Executive! x30!", 5}, [5] = {"RARE!", "LUA Lead! x8!", 4}, [4] = {"Nice!", "Vetted Script Dev! x3!", 3}, [3] = {"Rolled!", "Script Developer! x1.5", 2}, [2] = {"Rolled!", "Matcha Buyer! x1.1", 2}}
        local m = msgs[finalIndex]
        notify(m[1], "You got " .. m[2] .. " multiplier!", m[3])
        state.rolling = false; updateUI()
    end)
end

local function resetAll()
    state.coins = 0; state.clickPower = 1; state.clickMultiplier = 1; state.perSecond = 0
    state.upgrades.click.level = 0; state.upgrades.auto.level = 0; state.upgrades.multi.level = 0
    state.rebirths = 0; state.rebirthTokens = 0
    state.rebirthUpgrades.startCoins.level = 0; state.rebirthUpgrades.permClick.level = 0
    state.prestige = 0; state.titleIndex = 1
    pcall(function() if isfile(SAVE_FILE) then writefile(SAVE_FILE, "") end end)
    notify("RESET COMPLETE", "All progress has been wiped!", 3); updateUI()
end

local function cleanup()
    state.running = false; saveGame()
    for _, obj in ipairs(allObjects) do pcall(function() obj:Remove() end) end
    allObjects, tabObjects, objectData = {}, {{},{},{},{}}, {}
    notify("Game Closed", "Progress saved. Thanks for playing!", 3)
end

local mouse = game:GetService("Players").LocalPlayer:GetMouse()

task.spawn(function()
    local last = false
    while state.running do
        if isrbxactive() then
            local pressed = ismouse1pressed()
            local mx, my = mouse.X, mouse.Y
            if pressed and not last and not dragging then
                if hitXY(mx, my, px, py, pw, 42) and not hit(mx, my, btn.close) then
                    dragging = true; dragOffX = mx - px; dragOffY = my - py
                else
                    if hit(mx, my, btn.close) then cleanup(); return end
                    if hit(mx, my, btn.tab1) then switchTab(1); updateUI()
                    elseif hit(mx, my, btn.tab2) then switchTab(2); updateUI()
                    elseif hit(mx, my, btn.tab3) then switchTab(3); updateUI()
                    elseif hit(mx, my, btn.tab4) then switchTab(4); updateUI() end
                    if state.currentTab == 1 then
                        if hit(mx, my, btn.click) then doClick()
                        elseif hit(mx, my, btn.buy1) then buyUpgrade("click")
                        elseif hit(mx, my, btn.buy2) then buyUpgrade("auto")
                        elseif hit(mx, my, btn.buy3) then buyUpgrade("multi") end
                    elseif state.currentTab == 2 then
                        if hit(mx, my, btn.rebirth) then doRebirth()
                        elseif hit(mx, my, btn.rbuy1) then buyRebirthUpgrade("startCoins")
                        elseif hit(mx, my, btn.rbuy2) then buyRebirthUpgrade("permClick")
                        elseif hit(mx, my, btn.prestige) then doPrestige() end
                    elseif state.currentTab == 3 then
                        if hit(mx, my, btn.roll) then doRoulette() end
                    elseif state.currentTab == 4 then
                        if hit(mx, my, btn.save) then saveGame()
                        elseif hit(mx, my, btn.load) then loadGame(); updateUI()
                        elseif hit(mx, my, btn.reset) then resetAll()
                        elseif hit(mx, my, btn.export) then setclipboard(base64encode(serializeState())); notify("Exported!", "Save code copied to clipboard!", 2) end
                    end
                end
            end
            if dragging then
                if pressed then
                    px = mx - dragOffX; py = my - dragOffY; repositionAll()
                else dragging = false end
            end
            last = pressed
        end
        task.wait(0.016)
    end
end)

task.spawn(function()
    while state.running do
        local eps = effectivePerSecond()
        if eps > 0 then state.coins = state.coins + eps; updateUI() end
        task.wait(1)
    end
end)

task.spawn(function()
    while state.running do task.wait(60); if state.running then saveGame() end end
end)

loadGame(); switchTab(1); updateUI()
notify("Incremental Game v2.3", "Rebalanced everything, added Titles", 4)