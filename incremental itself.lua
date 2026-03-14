local SAVE_FILE = "incremental_save.txt"
local ROLL_COST = 35000
local AUTO_UNLOCK_COST = 75

local function formatNumber(n)
    if n ~= n or n == math.huge or n == -math.huge then return "∞" end
    if n < 0 then return "-" .. formatNumber(-n) end
    if n >= 1e18 then return string.format("%.2fQi", n / 1e18)
    elseif n >= 1e15 then return string.format("%.2fQa", n / 1e15)
    elseif n >= 1e12 then return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

local function safeCost(val)
    if val ~= val or val == math.huge then return 1e18 end
    return math.floor(val)
end

local themes = {
    {
        name = "Default",
        bg = Color3.fromRGB(18, 18, 30), header = Color3.fromRGB(35, 35, 65),
        headerText = Color3.fromRGB(255, 215, 0), tabActive = Color3.fromRGB(50, 50, 90),
        tabInactive = Color3.fromRGB(30, 30, 50), tabTextActive = Color3.fromRGB(255, 255, 255),
        tabTextInactive = Color3.fromRGB(140, 140, 140), card = Color3.fromRGB(35, 35, 60),
        accent = Color3.fromRGB(40, 160, 70), accentAlt = Color3.fromRGB(30, 100, 160),
        textDim = Color3.fromRGB(180, 180, 200), separator = Color3.fromRGB(70, 70, 110),
        footer = Color3.fromRGB(25, 25, 42), footerText = Color3.fromRGB(80, 80, 100),
        coinText = Color3.fromRGB(255, 255, 80), closeBtn = Color3.fromRGB(180, 40, 40),
        nodeOwned = Color3.fromRGB(200, 170, 30), nodeOwnedBorder = Color3.fromRGB(255, 220, 50),
        nodeAvail = Color3.fromRGB(40, 120, 60), nodeAvailBorder = Color3.fromRGB(80, 200, 100),
        nodeLocked = Color3.fromRGB(30, 30, 40), nodeLockedBorder = Color3.fromRGB(50, 50, 60),
        glowOwned = Color3.fromRGB(255, 220, 50), glowAvail = Color3.fromRGB(80, 255, 120),
        glowLocked = Color3.fromRGB(40, 40, 60), lineOwned = Color3.fromRGB(200, 170, 30),
        lineAvail = Color3.fromRGB(80, 120, 60), lineLocked = Color3.fromRGB(40, 40, 50),
        resize = Color3.fromRGB(80, 80, 140),
        omegaNodeOwned = Color3.fromRGB(255, 140, 0), omegaNodeOwnedBorder = Color3.fromRGB(255, 180, 50),
        omegaNodeAvail = Color3.fromRGB(160, 80, 0), omegaNodeAvailBorder = Color3.fromRGB(220, 120, 20),
        omegaNodeLocked = Color3.fromRGB(40, 25, 10), omegaNodeLockedBorder = Color3.fromRGB(70, 40, 15),
        omegaGlowOwned = Color3.fromRGB(255, 160, 30), omegaGlowAvail = Color3.fromRGB(220, 120, 20),
        omegaGlowLocked = Color3.fromRGB(50, 30, 10),
        omegaLineOwned = Color3.fromRGB(255, 160, 30), omegaLineAvail = Color3.fromRGB(160, 80, 0),
        omegaLineLocked = Color3.fromRGB(50, 30, 15),
    },
    {
        name = "Cyberpunk",
        bg = Color3.fromRGB(10, 5, 20), header = Color3.fromRGB(30, 10, 50),
        headerText = Color3.fromRGB(0, 255, 255), tabActive = Color3.fromRGB(50, 15, 80),
        tabInactive = Color3.fromRGB(20, 8, 35), tabTextActive = Color3.fromRGB(0, 255, 255),
        tabTextInactive = Color3.fromRGB(100, 60, 140), card = Color3.fromRGB(25, 10, 45),
        accent = Color3.fromRGB(255, 0, 128), accentAlt = Color3.fromRGB(0, 200, 255),
        textDim = Color3.fromRGB(140, 100, 180), separator = Color3.fromRGB(80, 30, 120),
        footer = Color3.fromRGB(15, 5, 30), footerText = Color3.fromRGB(100, 50, 140),
        coinText = Color3.fromRGB(0, 255, 200), closeBtn = Color3.fromRGB(255, 0, 80),
        nodeOwned = Color3.fromRGB(0, 200, 255), nodeOwnedBorder = Color3.fromRGB(0, 255, 255),
        nodeAvail = Color3.fromRGB(200, 0, 100), nodeAvailBorder = Color3.fromRGB(255, 50, 150),
        nodeLocked = Color3.fromRGB(15, 5, 30), nodeLockedBorder = Color3.fromRGB(40, 20, 60),
        glowOwned = Color3.fromRGB(0, 255, 255), glowAvail = Color3.fromRGB(255, 50, 150),
        glowLocked = Color3.fromRGB(30, 15, 50), lineOwned = Color3.fromRGB(0, 255, 255),
        lineAvail = Color3.fromRGB(200, 0, 100), lineLocked = Color3.fromRGB(30, 15, 50),
        resize = Color3.fromRGB(100, 0, 200),
        omegaNodeOwned = Color3.fromRGB(255, 100, 0), omegaNodeOwnedBorder = Color3.fromRGB(255, 150, 50),
        omegaNodeAvail = Color3.fromRGB(180, 60, 0), omegaNodeAvailBorder = Color3.fromRGB(240, 100, 20),
        omegaNodeLocked = Color3.fromRGB(30, 10, 5), omegaNodeLockedBorder = Color3.fromRGB(60, 25, 10),
        omegaGlowOwned = Color3.fromRGB(255, 130, 20), omegaGlowAvail = Color3.fromRGB(200, 90, 10),
        omegaGlowLocked = Color3.fromRGB(40, 15, 5),
        omegaLineOwned = Color3.fromRGB(255, 130, 20), omegaLineAvail = Color3.fromRGB(180, 60, 0),
        omegaLineLocked = Color3.fromRGB(40, 15, 5),
    },
    {
        name = "Blood Moon",
        bg = Color3.fromRGB(15, 5, 5), header = Color3.fromRGB(50, 10, 10),
        headerText = Color3.fromRGB(255, 80, 50), tabActive = Color3.fromRGB(80, 15, 15),
        tabInactive = Color3.fromRGB(30, 8, 8), tabTextActive = Color3.fromRGB(255, 200, 180),
        tabTextInactive = Color3.fromRGB(120, 60, 60), card = Color3.fromRGB(40, 12, 12),
        accent = Color3.fromRGB(200, 30, 30), accentAlt = Color3.fromRGB(180, 100, 20),
        textDim = Color3.fromRGB(160, 100, 90), separator = Color3.fromRGB(100, 30, 30),
        footer = Color3.fromRGB(20, 5, 5), footerText = Color3.fromRGB(100, 40, 40),
        coinText = Color3.fromRGB(255, 200, 50), closeBtn = Color3.fromRGB(200, 20, 20),
        nodeOwned = Color3.fromRGB(200, 50, 20), nodeOwnedBorder = Color3.fromRGB(255, 80, 30),
        nodeAvail = Color3.fromRGB(120, 80, 20), nodeAvailBorder = Color3.fromRGB(200, 140, 40),
        nodeLocked = Color3.fromRGB(25, 8, 8), nodeLockedBorder = Color3.fromRGB(50, 15, 15),
        glowOwned = Color3.fromRGB(255, 80, 30), glowAvail = Color3.fromRGB(200, 140, 40),
        glowLocked = Color3.fromRGB(40, 10, 10), lineOwned = Color3.fromRGB(255, 80, 30),
        lineAvail = Color3.fromRGB(120, 80, 20), lineLocked = Color3.fromRGB(40, 15, 15),
        resize = Color3.fromRGB(150, 30, 30),
        omegaNodeOwned = Color3.fromRGB(255, 120, 20), omegaNodeOwnedBorder = Color3.fromRGB(255, 160, 50),
        omegaNodeAvail = Color3.fromRGB(150, 70, 10), omegaNodeAvailBorder = Color3.fromRGB(200, 110, 30),
        omegaNodeLocked = Color3.fromRGB(35, 12, 5), omegaNodeLockedBorder = Color3.fromRGB(60, 20, 8),
        omegaGlowOwned = Color3.fromRGB(255, 140, 30), omegaGlowAvail = Color3.fromRGB(180, 80, 10),
        omegaGlowLocked = Color3.fromRGB(45, 15, 5),
        omegaLineOwned = Color3.fromRGB(255, 140, 30), omegaLineAvail = Color3.fromRGB(150, 70, 10),
        omegaLineLocked = Color3.fromRGB(45, 15, 8),
    },
    {
        name = "Emerald",
        bg = Color3.fromRGB(5, 18, 10), header = Color3.fromRGB(10, 40, 20),
        headerText = Color3.fromRGB(50, 255, 120), tabActive = Color3.fromRGB(15, 60, 30),
        tabInactive = Color3.fromRGB(8, 25, 12), tabTextActive = Color3.fromRGB(150, 255, 180),
        tabTextInactive = Color3.fromRGB(50, 120, 70), card = Color3.fromRGB(10, 35, 18),
        accent = Color3.fromRGB(20, 180, 80), accentAlt = Color3.fromRGB(40, 140, 200),
        textDim = Color3.fromRGB(100, 180, 130), separator = Color3.fromRGB(30, 80, 45),
        footer = Color3.fromRGB(5, 22, 12), footerText = Color3.fromRGB(40, 100, 60),
        coinText = Color3.fromRGB(200, 255, 100), closeBtn = Color3.fromRGB(180, 40, 40),
        nodeOwned = Color3.fromRGB(40, 200, 80), nodeOwnedBorder = Color3.fromRGB(80, 255, 130),
        nodeAvail = Color3.fromRGB(30, 120, 60), nodeAvailBorder = Color3.fromRGB(60, 200, 100),
        nodeLocked = Color3.fromRGB(8, 25, 12), nodeLockedBorder = Color3.fromRGB(20, 50, 28),
        glowOwned = Color3.fromRGB(80, 255, 130), glowAvail = Color3.fromRGB(60, 200, 100),
        glowLocked = Color3.fromRGB(15, 35, 20), lineOwned = Color3.fromRGB(80, 255, 130),
        lineAvail = Color3.fromRGB(30, 120, 60), lineLocked = Color3.fromRGB(15, 30, 18),
        resize = Color3.fromRGB(30, 140, 60),
        omegaNodeOwned = Color3.fromRGB(200, 160, 20), omegaNodeOwnedBorder = Color3.fromRGB(240, 200, 50),
        omegaNodeAvail = Color3.fromRGB(120, 90, 10), omegaNodeAvailBorder = Color3.fromRGB(180, 140, 30),
        omegaNodeLocked = Color3.fromRGB(15, 20, 8), omegaNodeLockedBorder = Color3.fromRGB(30, 40, 15),
        omegaGlowOwned = Color3.fromRGB(220, 180, 40), omegaGlowAvail = Color3.fromRGB(150, 110, 20),
        omegaGlowLocked = Color3.fromRGB(20, 25, 10),
        omegaLineOwned = Color3.fromRGB(220, 180, 40), omegaLineAvail = Color3.fromRGB(120, 90, 10),
        omegaLineLocked = Color3.fromRGB(20, 25, 10),
    },
    {
        name = "Midnight",
        bg = Color3.fromRGB(8, 8, 18), header = Color3.fromRGB(15, 15, 40),
        headerText = Color3.fromRGB(180, 180, 255), tabActive = Color3.fromRGB(25, 25, 70),
        tabInactive = Color3.fromRGB(12, 12, 30), tabTextActive = Color3.fromRGB(200, 200, 255),
        tabTextInactive = Color3.fromRGB(80, 80, 140), card = Color3.fromRGB(15, 15, 35),
        accent = Color3.fromRGB(60, 60, 200), accentAlt = Color3.fromRGB(100, 50, 180),
        textDim = Color3.fromRGB(120, 120, 170), separator = Color3.fromRGB(40, 40, 80),
        footer = Color3.fromRGB(10, 10, 25), footerText = Color3.fromRGB(60, 60, 100),
        coinText = Color3.fromRGB(180, 180, 255), closeBtn = Color3.fromRGB(150, 30, 60),
        nodeOwned = Color3.fromRGB(100, 100, 255), nodeOwnedBorder = Color3.fromRGB(150, 150, 255),
        nodeAvail = Color3.fromRGB(40, 40, 150), nodeAvailBorder = Color3.fromRGB(80, 80, 220),
        nodeLocked = Color3.fromRGB(10, 10, 25), nodeLockedBorder = Color3.fromRGB(25, 25, 50),
        glowOwned = Color3.fromRGB(150, 150, 255), glowAvail = Color3.fromRGB(80, 80, 220),
        glowLocked = Color3.fromRGB(15, 15, 35), lineOwned = Color3.fromRGB(150, 150, 255),
        lineAvail = Color3.fromRGB(40, 40, 150), lineLocked = Color3.fromRGB(20, 20, 40),
        resize = Color3.fromRGB(50, 50, 120),
        omegaNodeOwned = Color3.fromRGB(200, 140, 50), omegaNodeOwnedBorder = Color3.fromRGB(240, 180, 80),
        omegaNodeAvail = Color3.fromRGB(120, 80, 20), omegaNodeAvailBorder = Color3.fromRGB(180, 120, 40),
        omegaNodeLocked = Color3.fromRGB(15, 12, 8), omegaNodeLockedBorder = Color3.fromRGB(30, 25, 15),
        omegaGlowOwned = Color3.fromRGB(220, 160, 60), omegaGlowAvail = Color3.fromRGB(140, 90, 20),
        omegaGlowLocked = Color3.fromRGB(20, 15, 8),
        omegaLineOwned = Color3.fromRGB(220, 160, 60), omegaLineAvail = Color3.fromRGB(120, 80, 20),
        omegaLineLocked = Color3.fromRGB(20, 15, 8),
    },
}

local titles = {
    { name = "None", mult = 1, color = Color3.fromRGB(140, 140, 140) },
    { name = "Matcha Buyer", mult = 1.1, color = Color3.fromRGB(120, 255, 120) },
    { name = "Script Developer", mult = 1.5, color = Color3.fromRGB(100, 200, 255) },
    { name = "Vetted Script Developer", mult = 3, color = Color3.fromRGB(50, 130, 255) },
    { name = "LUA Lead", mult = 8, color = Color3.fromRGB(255, 200, 50) },
    { name = "Executive", mult = 30, color = Color3.fromRGB(255, 50, 50) },
    { name = "The Elite", mult = 100, color = Color3.fromRGB(255, 255, 255) },
    { name = "Ascended", mult = 250, color = Color3.fromRGB(180, 50, 255) },
    { name = "Singularity", mult = 50, color = Color3.fromRGB(10, 10, 10) },
    { name = "Quasar", mult = 1900, color = Color3.fromRGB(255, 140, 0) },
    { name = "The Eye", mult = 10000, color = Color3.fromRGB(255, 255, 255) },
}

local astralSkillTree = {
    { id = "root", name = "ROOT", cost = 0, parent = nil, effect = "Unlocks the tree", x = 0.5, y = 0.04 },
    { id = "atk", name = "ATK", cost = 50, parent = "root", effect = "+100 click power", x = 0.2, y = 0.12 },
    { id = "def", name = "DEF", cost = 50, parent = "root", effect = "x1.5 all mult", x = 0.8, y = 0.12 },
    { id = "spd", name = "SPD", cost = 60, parent = "root", effect = "+20% auto speed", x = 0.5, y = 0.14 },
    { id = "crit", name = "CRIT", cost = 150, parent = "atk", effect = "10% chance x5 click", x = 0.08, y = 0.22 },
    { id = "multi", name = "MULTI", cost = 150, parent = "atk", effect = "x3 coin mult", x = 0.32, y = 0.22 },
    { id = "shield", name = "SHIELD", cost = 200, parent = "def", effect = "x2 essence/sec", x = 0.68, y = 0.22 },
    { id = "armor", name = "ARMOR", cost = 200, parent = "def", effect = "x2 void/sec", x = 0.92, y = 0.22 },
    { id = "haste", name = "HASTE", cost = 180, parent = "spd", effect = "x1.5 auto speed", x = 0.5, y = 0.24 },
    { id = "fury", name = "FURY", cost = 300, parent = "crit", effect = "15% crit -> x8", x = 0.04, y = 0.33 },
    { id = "blade", name = "BLADE", cost = 280, parent = "crit", effect = "+250 click power", x = 0.16, y = 0.33 },
    { id = "wealth", name = "WEALTH", cost = 320, parent = "multi", effect = "x5 coin mult", x = 0.30, y = 0.33 },
    { id = "regen", name = "REGEN", cost = 300, parent = "shield", effect = "+5 void/sec", x = 0.70, y = 0.33 },
    { id = "ward", name = "WARD", cost = 350, parent = "armor", effect = "x3 essence mult", x = 0.96, y = 0.33 },
    { id = "rush", name = "RUSH", cost = 260, parent = "haste", effect = "x2 all gen rates", x = 0.42, y = 0.35 },
    { id = "tempo", name = "TEMPO", cost = 260, parent = "haste", effect = "+10 astral/sec", x = 0.58, y = 0.35 },
    { id = "fusion", name = "FUSION", cost = 500, parent = nil, effect = "CRIT+MULTI combined", x = 0.15, y = 0.46, parents = {"fury", "wealth"} },
    { id = "bastion", name = "BASTION", cost = 500, parent = nil, effect = "x4 all defenses", x = 0.85, y = 0.46, parents = {"regen", "ward"} },
    { id = "flow", name = "FLOW", cost = 450, parent = nil, effect = "x3 all gen", x = 0.50, y = 0.48, parents = {"rush", "tempo"} },
    { id = "nova", name = "NOVA", cost = 700, parent = "fusion", effect = "x8 click power", x = 0.08, y = 0.58 },
    { id = "storm", name = "STORM", cost = 700, parent = "fusion", effect = "25% crit -> x12", x = 0.24, y = 0.58 },
    { id = "fort", name = "FORT", cost = 750, parent = "bastion", effect = "x5 ess + void", x = 0.78, y = 0.58 },
    { id = "titan", name = "TITAN", cost = 750, parent = "bastion", effect = "x10 astral/sec", x = 0.94, y = 0.58 },
    { id = "flux", name = "FLUX", cost = 650, parent = "flow", effect = "x4 all currencies", x = 0.50, y = 0.60 },
    { id = "apex", name = "APEX", cost = 1200, parent = nil, effect = "x15 all offensive", x = 0.20, y = 0.74, parents = {"nova", "storm"} },
    { id = "eternal", name = "ETERNAL", cost = 1200, parent = nil, effect = "x15 all defensive", x = 0.80, y = 0.74, parents = {"fort", "titan"} },
    { id = "harmony", name = "HARMONY", cost = 1000, parent = "flux", effect = "x8 everything", x = 0.50, y = 0.76 },
    { id = "omega", name = "OMEGA", cost = 3000, parent = nil, effect = "x50 EVERYTHING", x = 0.5, y = 0.92, parents = {"apex", "eternal", "harmony"} },
}

local omegaSkillTree = {
    { id = "o_root", name = "ORIGIN", cost = 0, parent = nil, effect = "Unlocks Omega tree", x = 0.5, y = 0.02 },
    { id = "o_power", name = "POWER", cost = 100, parent = "o_root", effect = "+500 click power", x = 0.15, y = 0.07 },
    { id = "o_wisdom", name = "WISDOM", cost = 100, parent = "o_root", effect = "x3 all mult", x = 0.5, y = 0.07 },
    { id = "o_chaos", name = "CHAOS", cost = 100, parent = "o_root", effect = "x2 all gen", x = 0.85, y = 0.07 },
    { id = "o_rage", name = "RAGE", cost = 250, parent = "o_power", effect = "20% crit -> x15", x = 0.05, y = 0.13 },
    { id = "o_might", name = "MIGHT", cost = 250, parent = "o_power", effect = "+1000 click", x = 0.25, y = 0.13 },
    { id = "o_insight", name = "INSIGHT", cost = 280, parent = "o_wisdom", effect = "x5 coin mult", x = 0.40, y = 0.13 },
    { id = "o_clarity", name = "CLARITY", cost = 280, parent = "o_wisdom", effect = "x3 ess mult", x = 0.60, y = 0.13 },
    { id = "o_entropy", name = "ENTROPY", cost = 300, parent = "o_chaos", effect = "x4 void gen", x = 0.75, y = 0.13 },
    { id = "o_rift", name = "RIFT", cost = 300, parent = "o_chaos", effect = "x2 astral gen", x = 0.95, y = 0.13 },
    { id = "o_berserk", name = "BERSERK", cost = 500, parent = "o_rage", effect = "30% crit -> x20", x = 0.02, y = 0.20 },
    { id = "o_titan", name = "COLOSSUS", cost = 500, parent = "o_might", effect = "+5000 click", x = 0.18, y = 0.20 },
    { id = "o_sage", name = "SAGE", cost = 550, parent = nil, effect = "x10 coin mult", x = 0.30, y = 0.20, parents = {"o_might", "o_insight"} },
    { id = "o_oracle", name = "ORACLE", cost = 550, parent = "o_clarity", effect = "x5 ess gen", x = 0.50, y = 0.20 },
    { id = "o_void_lord", name = "V.LORD", cost = 600, parent = nil, effect = "x8 void gen", x = 0.70, y = 0.20, parents = {"o_clarity", "o_entropy"} },
    { id = "o_nexus", name = "NEXUS", cost = 600, parent = "o_rift", effect = "+50 astral/sec", x = 0.88, y = 0.20 },
    { id = "o_warp", name = "WARP", cost = 580, parent = "o_rift", effect = "x3 omega gen", x = 0.98, y = 0.20 },
    { id = "o_annihil", name = "ANNIHL", cost = 800, parent = nil, effect = "x25 click", x = 0.08, y = 0.27, parents = {"o_berserk", "o_titan"} },
    { id = "o_fortune", name = "FORTN", cost = 850, parent = "o_sage", effect = "x15 coins", x = 0.28, y = 0.27 },
    { id = "o_transcend", name = "TRSCND", cost = 900, parent = nil, effect = "x10 ess+void", x = 0.50, y = 0.27, parents = {"o_oracle", "o_void_lord"} },
    { id = "o_stellar", name = "STLLAR", cost = 850, parent = "o_nexus", effect = "x8 astral", x = 0.78, y = 0.27 },
    { id = "o_dimension", name = "DIMEN", cost = 900, parent = "o_warp", effect = "x5 omega gen", x = 0.95, y = 0.27 },
    { id = "o_supernova", name = "S.NOVA", cost = 1200, parent = nil, effect = "x50 click total", x = 0.15, y = 0.34, parents = {"o_annihil", "o_fortune"} },
    { id = "o_cosmos", name = "COSMOS", cost = 1200, parent = "o_transcend", effect = "x20 all gen", x = 0.50, y = 0.34 },
    { id = "o_infinity", name = "INFIN", cost = 1200, parent = nil, effect = "x15 astral+omega", x = 0.85, y = 0.34, parents = {"o_stellar", "o_dimension"} },
    { id = "o_godstrike", name = "G.STRK", cost = 1800, parent = "o_supernova", effect = "40% crit -> x30", x = 0.08, y = 0.41 },
    { id = "o_midas", name = "MIDAS", cost = 1800, parent = "o_supernova", effect = "x100 coins", x = 0.25, y = 0.41 },
    { id = "o_eternity", name = "ETRNTY", cost = 2000, parent = "o_cosmos", effect = "x50 all gen", x = 0.42, y = 0.41 },
    { id = "o_singularity", name = "SNGLT", cost = 2000, parent = "o_cosmos", effect = "x30 ess+void", x = 0.58, y = 0.41 },
    { id = "o_multiverse", name = "M.VRSE", cost = 1800, parent = "o_infinity", effect = "x25 astral", x = 0.75, y = 0.41 },
    { id = "o_omniscient", name = "OMNI", cost = 1800, parent = "o_infinity", effect = "x10 omega gen", x = 0.92, y = 0.41 },
    { id = "o_warpath", name = "WRPATH", cost = 2500, parent = nil, effect = "x200 offensive", x = 0.15, y = 0.48, parents = {"o_godstrike", "o_midas"} },
    { id = "o_genesis", name = "GENSS", cost = 2500, parent = nil, effect = "x100 all gen", x = 0.50, y = 0.48, parents = {"o_eternity", "o_singularity"} },
    { id = "o_ascension", name = "ASCNSN", cost = 2500, parent = nil, effect = "x50 astral+omega", x = 0.85, y = 0.48, parents = {"o_multiverse", "o_omniscient"} },
    { id = "o_apocalypse", name = "APCLPS", cost = 3500, parent = nil, effect = "x500 click", x = 0.10, y = 0.55, parents = {"o_warpath"} },
    { id = "o_rebirth_star", name = "R.STAR", cost = 3500, parent = nil, effect = "x200 all gen", x = 0.35, y = 0.55, parents = {"o_warpath", "o_genesis"} },
    { id = "o_void_heart", name = "V.HART", cost = 3500, parent = nil, effect = "x150 void+ess", x = 0.65, y = 0.55, parents = {"o_genesis", "o_ascension"} },
    { id = "o_star_forge", name = "S.FRGE", cost = 3500, parent = nil, effect = "x100 astral+omega", x = 0.90, y = 0.55, parents = {"o_ascension"} },
    { id = "o_divine_L", name = "DIVINE", cost = 5000, parent = nil, effect = "x1000 offensive", x = 0.20, y = 0.63, parents = {"o_apocalypse", "o_rebirth_star"} },
    { id = "o_divine_R", name = "SACRED", cost = 5000, parent = nil, effect = "x500 all gen", x = 0.80, y = 0.63, parents = {"o_void_heart", "o_star_forge"} },
    { id = "o_nexus_core", name = "N.CORE", cost = 5500, parent = nil, effect = "x300 everything", x = 0.50, y = 0.65, parents = {"o_rebirth_star", "o_void_heart"} },
    { id = "o_prime_L", name = "PRIME", cost = 7000, parent = "o_divine_L", effect = "x2000 click", x = 0.12, y = 0.72 },
    { id = "o_prime_R", name = "AXIOM", cost = 7000, parent = "o_divine_R", effect = "x1000 gen", x = 0.88, y = 0.72 },
    { id = "o_convergence", name = "CNVRGE", cost = 8000, parent = "o_nexus_core", effect = "x500 everything", x = 0.50, y = 0.74 },
    { id = "o_zenith_L", name = "ZENITH", cost = 10000, parent = nil, effect = "x5000 offensive", x = 0.25, y = 0.82, parents = {"o_prime_L", "o_convergence"} },
    { id = "o_zenith_R", name = "NADIR", cost = 10000, parent = nil, effect = "x3000 defensive", x = 0.75, y = 0.82, parents = {"o_prime_R", "o_convergence"} },
    { id = "o_absolute", name = "ABSOLUT", cost = 25000, parent = nil, effect = "x10000 EVERYTHING", x = 0.5, y = 0.93, parents = {"o_zenith_L", "o_zenith_R"} },
}

local state = {
    coins = 0, clickPower = 1, clickMultiplier = 1, autoUnlocked = false,
    running = true, currentTab = 1, rolling = false, titleIndex = 1,
    upgrades = {
        click = { level = 0, baseCost = 10, costMult = 1.5 },
        auto  = { level = 0, baseCost = 950, costMult = 6.0 },
        multi = { level = 0, baseCost = 500, costMult = 3.0 },
    },
    rebirths = 0, rebirthTokens = 0,
    rebirthUpgrades = { startCoins = { level = 0 }, permClick = { level = 0 } },
    prestige = 0, tier = 0,
    essence = 0, essenceRebirths = 0, essencePrestige = 0,
    essenceUpgrades = {
        coinBoost = { level = 0, baseCost = 10, costMult = 2.0 },
        essSpeed = { level = 0, baseCost = 25, costMult = 2.2 },
        superClick = { level = 0, baseCost = 50, costMult = 2.5 },
    },
    voidEnergy = 0, voidRebirths = 0, voidPrestige = 0,
    voidUpgrades = {
        voidClick = { level = 0, baseCost = 15, costMult = 2.0 },
        voidFlow = { level = 0, baseCost = 30, costMult = 2.2 },
        cosmicBoost = { level = 0, baseCost = 60, costMult = 2.5 },
        starDrain = { level = 0, baseCost = 40, costMult = 2.3 },
    },
    astralShards = 0, omegaEnergy = 0,
    skillNodes = {}, omegaNodes = {},
    critActive = false, themeIndex = 1, minimized = false,
}

for _, node in ipairs(astralSkillTree) do state.skillNodes[node.id] = false end
for _, node in ipairs(omegaSkillTree) do state.omegaNodes[node.id] = false end

local MIN_W, MIN_H = 320, 400
local MAX_W, MAX_H = 800, 1000
local RESIZE_HANDLE = 10
local MIN_ZOOM, MAX_ZOOM = 0.3, 3.5
local ZOOM_STEP = 0.15
local TREE_HEADER_H = 85
local TREE_FOOTER_H = 10

local astralZoom, astralPanX, astralPanY = 1.0, 0, 0
local omegaZoom, omegaPanX, omegaPanY = 0.6, 0, 0

local updateUI, rebuildAstralTree, rebuildOmegaTree
local repositionTreeNodes

local btn, labels = {}, {}
local allObjects, objectData = {}, {}
local tabObjects = { {}, {}, {}, {}, {}, {}, {}, {} }
local essObjs, voidObjs = {}, {}
local astralObjs, omegaObjs = {}, {}
local glowObjs, omegaGlowObjs = {}, {}
local astralDrawings, omegaDrawings = {}, {}

local astralBuilt, omegaBuilt = false, false

local px, py = 100, 40
local pw, ph = 420, 680
local dragging, dragOffX, dragOffY = false, 0, 0
local resizingC = false
local treeDragging, treeDragLastX, treeDragLastY = false, 0, 0
local activeTreeTab = 0

local zoomPlusWasPressed = false
local zoomMinusWasPressed = false
local clickColorResetPending = false
local saveFileExists = false

local function T() return themes[state.themeIndex] end

local function makeSquare(x, y, w, h, color, zi, tab)
    local s = Drawing.new("Square")
    s.Position = Vector2.new(x, y); s.Size = Vector2.new(w, h)
    s.Color = color; s.Filled = true; s.Visible = true; s.ZIndex = zi or 1; s.Transparency = 1
    table.insert(allObjects, s)
    table.insert(objectData, {obj = s, ox = x - px, oy = y - py, ow = w, oh = h})
    if tab then table.insert(tabObjects[tab], s) end
    return s
end

local function makeText(x, y, str, sz, color, center, zi, tab)
    local t = Drawing.new("Text")
    t.Position = Vector2.new(x, y); t.Text = str; t.Size = sz or 18
    t.Color = color or Color3.fromRGB(255, 255, 255); t.Center = center or false
    t.Outline = true; t.Visible = true; t.ZIndex = zi or 5; t.Transparency = 1
    table.insert(allObjects, t)
    table.insert(objectData, {obj = t, ox = x - px, oy = y - py})
    if tab then table.insert(tabObjects[tab], t) end
    return t
end

local function makeLine(x1, y1, x2, y2, color, thickness, zi, tab)
    local l = Drawing.new("Line")
    l.From = Vector2.new(x1, y1); l.To = Vector2.new(x2, y2)
    l.Color = color; l.Thickness = thickness or 2; l.Visible = true; l.ZIndex = zi or 2; l.Transparency = 1
    table.insert(allObjects, l)
    table.insert(objectData, {obj = l, ox1 = x1 - px, oy1 = y1 - py, ox2 = x2 - px, oy2 = y2 - py, isLine = true})
    if tab then table.insert(tabObjects[tab], l) end
    return l
end

local function makeCircle(x, y, radius, color, zi, tab)
    local c = Drawing.new("Circle")
    c.Position = Vector2.new(x, y); c.Radius = radius
    c.Color = color; c.Filled = true; c.Visible = true; c.ZIndex = zi or 1
    c.Transparency = 0.3; c.NumSides = 24
    table.insert(allObjects, c)
    table.insert(objectData, {obj = c, ox = x - px, oy = y - py, isCircle = true})
    if tab then table.insert(tabObjects[tab], c) end
    return c
end

local function regBtn(name, x, y, w, h)
    btn[name] = {x = x, y = y, w = w, h = h, ox = x - px, oy = y - py}
end

local function hit(mx, my, b) return b and mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h end
local function hitXY(mx, my, x, y, w, h) return mx >= x and mx <= x + w and my >= y and my <= y + h end

local function getTreeArea()
    return px + 5, py + (contentY and (contentY - py) or 78) + TREE_HEADER_H, pw - 10, ph - (contentY and (contentY - py) or 78) - TREE_HEADER_H - TREE_FOOTER_H - 28
end

local function switchTab(tabNum)
    if state.minimized then return end
    state.currentTab = tabNum
    for i = 1, 8 do
        for _, obj in ipairs(tabObjects[i]) do obj.Visible = (i == tabNum) end
    end
    for _, obj in ipairs(essObjs) do obj.Visible = (tabNum == 4 and state.tier >= 1) end
    for _, obj in ipairs(voidObjs) do obj.Visible = (tabNum == 6 and state.tier >= 2) end
    local astralVis = (tabNum == 7 and state.tier >= 3)
    for _, obj in ipairs(astralObjs) do obj.Visible = astralVis end
    for _, g in ipairs(glowObjs) do g.Visible = astralVis end
    local omegaVis = (tabNum == 8 and state.tier >= 4)
    for _, obj in ipairs(omegaObjs) do obj.Visible = omegaVis end
    for _, g in ipairs(omegaGlowObjs) do g.Visible = omegaVis end
    if labels.essLocked then labels.essLocked.Visible = (tabNum == 4 and state.tier < 1) end
    if labels.essLocked2 then labels.essLocked2.Visible = (tabNum == 4 and state.tier < 1) end
    if labels.essLocked3 then labels.essLocked3.Visible = (tabNum == 4 and state.tier < 1) end
    if labels.voidLocked then labels.voidLocked.Visible = (tabNum == 6 and state.tier < 2) end
    if labels.voidLocked2 then labels.voidLocked2.Visible = (tabNum == 6 and state.tier < 2) end
    if labels.voidLocked3 then labels.voidLocked3.Visible = (tabNum == 6 and state.tier < 2) end
    if labels.astralLocked then labels.astralLocked.Visible = (tabNum == 7 and state.tier < 3) end
    if labels.astralLocked2 then labels.astralLocked2.Visible = (tabNum == 7 and state.tier < 3) end
    if labels.astralLocked3 then labels.astralLocked3.Visible = (tabNum == 7 and state.tier < 3) end
    if labels.omegaLocked then labels.omegaLocked.Visible = (tabNum == 8 and state.tier < 4) end
    if labels.omegaLocked2 then labels.omegaLocked2.Visible = (tabNum == 8 and state.tier < 4) end
    if labels.omegaLocked3 then labels.omegaLocked3.Visible = (tabNum == 8 and state.tier < 4) end
end

local function repositionAll()
    for _, d in ipairs(objectData) do
        if d.isLine then
            d.obj.From = Vector2.new(px + d.ox1, py + d.oy1)
            d.obj.To = Vector2.new(px + d.ox2, py + d.oy2)
        else
            d.obj.Position = Vector2.new(px + d.ox, py + d.oy)
        end
    end
    for _, b in pairs(btn) do b.x = px + b.ox; b.y = py + b.oy end
end

repositionTreeNodes = function(tree, labelPrefix, zoom, panX, panY)
    local treeAreaX, treeAreaY, treeAreaW, treeAreaH = getTreeArea()
    local z = zoom
    local baseNodeW, baseNodeH = 50, 30
    local nodeW = math.max(20, math.floor(baseNodeW * z))
    local nodeH = math.max(14, math.floor(baseNodeH * z))
    local canvasW = treeAreaW * z
    local canvasH = treeAreaH * z

    local nodePositions = {}
    for _, node in ipairs(tree) do
        local vx = node.x * canvasW + panX
        local vy = node.y * canvasH + panY
        local sx = treeAreaX + vx - nodeW / 2
        local sy = treeAreaY + vy - nodeH / 2
        local cx = sx + nodeW / 2
        local cy = sy + nodeH / 2
        nodePositions[node.id] = {x = sx, y = sy, cx = cx, cy = cy}
    end

    for _, node in ipairs(tree) do
        local pos = nodePositions[node.id]
        local function updateLinePos(pid)
            local pp = nodePositions[pid]
            local lk = labelPrefix .. "line_" .. pid .. "_" .. node.id
            if pp and labels[lk] then
                labels[lk].From = Vector2.new(pp.cx, pp.cy)
                labels[lk].To = Vector2.new(pos.cx, pos.cy)
            end
        end
        if node.parents then
            for _, pid in ipairs(node.parents) do updateLinePos(pid) end
        elseif node.parent then
            updateLinePos(node.parent)
        end
    end

    for _, node in ipairs(tree) do
        local pos = nodePositions[node.id]
        local bk = labelPrefix .. "node_" .. node.id
        if btn[bk] then
            btn[bk].x = pos.x; btn[bk].y = pos.y
            btn[bk].ox = pos.x - px; btn[bk].oy = pos.y - py
            btn[bk].w = nodeW; btn[bk].h = nodeH
        end
        if labels[labelPrefix .. "nodeGlow_" .. node.id] then
            labels[labelPrefix .. "nodeGlow_" .. node.id].Position = Vector2.new(pos.cx, pos.cy)
        end
        if labels[labelPrefix .. "nodeBorder_" .. node.id] then
            labels[labelPrefix .. "nodeBorder_" .. node.id].Position = Vector2.new(pos.x - 1, pos.y - 1)
            labels[labelPrefix .. "nodeBorder_" .. node.id].Size = Vector2.new(nodeW + 2, nodeH + 2)
        end
        if labels[labelPrefix .. "nodeBg_" .. node.id] then
            labels[labelPrefix .. "nodeBg_" .. node.id].Position = Vector2.new(pos.x, pos.y)
            labels[labelPrefix .. "nodeBg_" .. node.id].Size = Vector2.new(nodeW, nodeH)
        end
        if labels[labelPrefix .. "nodeName_" .. node.id] then
            labels[labelPrefix .. "nodeName_" .. node.id].Position = Vector2.new(pos.cx, pos.y + math.floor(4 * z))
        end
        if labels[labelPrefix .. "nodeCost_" .. node.id] then
            labels[labelPrefix .. "nodeCost_" .. node.id].Position = Vector2.new(pos.cx, pos.y + math.floor(18 * z))
        end
    end
end

local function resizeUI(newW, newH)
    pw = math.clamp(newW, MIN_W, MAX_W)
    ph = math.clamp(newH, MIN_H, MAX_H)
    if labels.bodyBg then labels.bodyBg.Size = Vector2.new(pw, ph) end
    if labels.headerBg then labels.headerBg.Size = Vector2.new(pw, 42) end
    for _, d in ipairs(objectData) do
        if d.obj == labels.headerTitle then d.ox = pw / 2 end
        if d.obj == labels.closeBg then d.ox = pw - 38; d.oy = 6 end
        if d.obj == labels.minBg then d.ox = pw - 72; d.oy = 6 end
        if d.obj == labels.minBtnText then d.ox = pw - 72 + 15; d.oy = 13 end
    end
    if btn.close then btn.close.ox = pw - 38; btn.close.oy = 6 end
    if btn.minimize then btn.minimize.ox = pw - 72; btn.minimize.oy = 6 end
    local tw = math.floor(pw / 8)
    local ltw = pw - tw * 7
    for i = 1, 8 do
        local w = (i == 8) and ltw or tw
        local x = tw * (i - 1)
        if btn["tab" .. i] then btn["tab" .. i].ox = x; btn["tab" .. i].oy = 44; btn["tab" .. i].w = w end
        if labels["tab" .. i .. "Bg"] then
            for _, d in ipairs(objectData) do if d.obj == labels["tab" .. i .. "Bg"] then d.ox = x; d.oy = 44; break end end
            labels["tab" .. i .. "Bg"].Size = Vector2.new(w, 32)
        end
        if labels["tab" .. i .. "L"] then
            for _, d in ipairs(objectData) do if d.obj == labels["tab" .. i .. "L"] then d.ox = x + w / 2; d.oy = 54; break end end
        end
    end
    if labels.footerBg then
        for _, d in ipairs(objectData) do if d.obj == labels.footerBg then d.oy = ph - 28; break end end
        labels.footerBg.Size = Vector2.new(pw, 28)
    end
    if labels.footerText then
        for _, d in ipairs(objectData) do if d.obj == labels.footerText then d.ox = pw / 2; d.oy = ph - 22; break end end
    end
    if labels.resizeC then
        for _, d in ipairs(objectData) do if d.obj == labels.resizeC then d.ox = pw - RESIZE_HANDLE; d.oy = ph - RESIZE_HANDLE; break end end
    end
    if labels.resizeGrip then
        for _, d in ipairs(objectData) do if d.obj == labels.resizeGrip then d.ox = pw - 14; d.oy = ph - 14; break end end
    end
    repositionAll()
    if rebuildAstralTree then rebuildAstralTree() end
    if rebuildOmegaTree then rebuildOmegaTree() end
end

local function toggleMinimize()
    state.minimized = not state.minimized
    if state.minimized then
        for i = 1, 8 do for _, obj in ipairs(tabObjects[i]) do obj.Visible = false end end
        for _, obj in ipairs(essObjs) do obj.Visible = false end
        for _, obj in ipairs(voidObjs) do obj.Visible = false end
        for _, obj in ipairs(astralObjs) do obj.Visible = false end
        for _, obj in ipairs(omegaObjs) do obj.Visible = false end
        for _, g in ipairs(glowObjs) do g.Visible = false end
        for _, g in ipairs(omegaGlowObjs) do g.Visible = false end
        for i = 1, 8 do
            if labels["tab" .. i .. "Bg"] then labels["tab" .. i .. "Bg"].Visible = false end
            if labels["tab" .. i .. "L"] then labels["tab" .. i .. "L"].Visible = false end
        end
        if labels.bodyBg then labels.bodyBg.Visible = false end
        if labels.footerBg then labels.footerBg.Visible = false end
        if labels.footerText then labels.footerText.Visible = false end
        if labels.resizeC then labels.resizeC.Visible = false end
        if labels.resizeGrip then labels.resizeGrip.Visible = false end
        local lockedLabels = {"essLocked","essLocked2","essLocked3","voidLocked","voidLocked2","voidLocked3","astralLocked","astralLocked2","astralLocked3","omegaLocked","omegaLocked2","omegaLocked3"}
        for _, k in ipairs(lockedLabels) do if labels[k] then labels[k].Visible = false end end
        labels.minBtnText.Text = "+"
    else
        if labels.bodyBg then labels.bodyBg.Visible = true end
        for i = 1, 8 do
            if labels["tab" .. i .. "Bg"] then labels["tab" .. i .. "Bg"].Visible = true end
            if labels["tab" .. i .. "L"] then labels["tab" .. i .. "L"].Visible = true end
        end
        if labels.footerBg then labels.footerBg.Visible = true end
        if labels.footerText then labels.footerText.Visible = true end
        if labels.resizeC then labels.resizeC.Visible = true end
        if labels.resizeGrip then labels.resizeGrip.Visible = true end
        labels.minBtnText.Text = "-"
        switchTab(state.currentTab)
    end
end

labels.bodyBg = makeSquare(px, py, pw, ph, T().bg, 1)
labels.headerBg = makeSquare(px, py, pw, 42, T().header, 2)
labels.headerTitle = makeText(px + pw / 2, py + 10, "INCREMENTAL GAME v5", 22, T().headerText, true, 6)
makeText(px + 10, py + 15, "::::", 14, Color3.fromRGB(80, 80, 120), false, 6)

regBtn("close", px + pw - 38, py + 6, 30, 30)
labels.closeBg = makeSquare(btn.close.x, btn.close.y, 30, 30, T().closeBtn, 3)
makeText(btn.close.x + 15, btn.close.y + 7, "X", 18, Color3.fromRGB(255, 255, 255), true, 6)

regBtn("minimize", px + pw - 72, py + 6, 30, 30)
labels.minBg = makeSquare(btn.minimize.x, btn.minimize.y, 30, 30, Color3.fromRGB(60, 60, 100), 3)
labels.minBtnText = makeText(btn.minimize.x + 15, btn.minimize.y + 7, "-", 18, Color3.fromRGB(255, 255, 255), true, 6)

labels.resizeC = makeSquare(px + pw - RESIZE_HANDLE, py + ph - RESIZE_HANDLE, RESIZE_HANDLE, RESIZE_HANDLE, T().resize, 3)
labels.resizeC.Transparency = 0.4
labels.resizeGrip = makeText(px + pw - 14, py + ph - 14, "◢", 12, T().resize, false, 7)

local tabY = py + 44
local tabW = math.floor(pw / 8)
local lastTabW = pw - tabW * 7
local tabNames = {"MAIN", "REBIRTH", "ROLL", "ESSENCE", "CONFIG", "VOID", "ASTRAL", "OMEGA"}

for i = 1, 8 do
    local w = (i == 8) and lastTabW or tabW
    local x = px + tabW * (i - 1)
    regBtn("tab" .. i, x, tabY, w, 32)
    labels["tab" .. i .. "Bg"] = makeSquare(x, tabY, w, 32, (i == 1) and T().tabActive or T().tabInactive, 3)
    labels["tab" .. i .. "L"] = makeText(x + w / 2, tabY + 10, tabNames[i], 10, (i == 1) and T().tabTextActive or T().tabTextInactive, true, 6)
end

local contentY = tabY + 34
labels.footerBg = makeSquare(px, py + ph - 28, pw, 28, T().footer, 2)
labels.footerText = makeText(px + pw / 2, py + ph - 22, "Made by a very annoying socratee, with love", 12, T().footerText, true, 5)

do
    local cY = contentY + 5
    labels.coins = makeText(px+20,cY,"Coins: 0",22,T().coinText,false,5,1); cY=cY+28
    labels.stats = makeText(px+20,cY,"Click: 1 | /Sec: 0",13,T().textDim,false,5,1); cY=cY+20
    labels.mult = makeText(px+20,cY,"Total Mult: x1",12,Color3.fromRGB(140,140,200),false,5,1); cY=cY+18
    labels.title = makeText(px+20,cY,"Title: None",12,Color3.fromRGB(140,140,140),false,5,1); cY=cY+20
    makeSquare(px+15,cY,pw-30,1,T().separator,2,1); cY=cY+8
    regBtn("click",px+30,cY,pw-60,70)
    labels.clickBg = makeSquare(btn.click.x,btn.click.y,pw-60,70,T().accent,2,1)
    makeText(btn.click.x+(pw-60)/2,btn.click.y+14,">>> CLICK <<<",24,Color3.fromRGB(255,255,255),true,6,1)
    labels.clickSub = makeText(btn.click.x+(pw-60)/2,btn.click.y+46,"+1 coins",14,Color3.fromRGB(210,255,210),true,6,1); cY=cY+80
    makeSquare(px+15,cY,pw-30,1,T().separator,2,1); cY=cY+6
    makeText(px+20,cY,"[ UPGRADES ]",16,Color3.fromRGB(160,160,255),false,5,1); cY=cY+24
    makeSquare(px+15,cY,pw-30,60,T().card,2,1)
    makeText(px+25,cY+4,"Click Power +1",14,Color3.fromRGB(255,200,80),false,5,1)
    labels.u1Info = makeText(px+25,cY+22,"Level: 0",12,T().textDim,false,5,1)
    labels.u1Cost = makeText(px+25,cY+38,"Cost: 10",12,T().coinText,false,5,1)
    regBtn("buy1",px+pw-115,cY+16,28,28)
    labels.b1Bg = makeSquare(btn.buy1.x,btn.buy1.y,28,28,Color3.fromRGB(40,150,40),3,1)
    makeText(btn.buy1.x+14,btn.buy1.y+7,"+1",14,Color3.fromRGB(255,255,255),true,6,1)
    regBtn("max1",px+pw-83,cY+16,58,28)
    labels.m1Bg = makeSquare(btn.max1.x,btn.max1.y,58,28,T().accentAlt,3,1)
    labels.m1Text = makeText(btn.max1.x+29,btn.max1.y+7,"MAX",14,Color3.fromRGB(255,255,255),true,6,1); cY=cY+66
    makeSquare(px+15,cY,pw-30,60,T().card,2,1)
    labels.u2Title = makeText(px+25,cY+4,"Auto Clicker [UNLOCK]",14,Color3.fromRGB(80,200,255),false,5,1)
    labels.u2Info = makeText(px+25,cY+22,"Unlocks automatic clicking",12,T().textDim,false,5,1)
    labels.u2Cost = makeText(px+25,cY+38,"Cost: 75",12,T().coinText,false,5,1)
    regBtn("buy2",px+pw-115,cY+16,28,28)
    labels.b2Bg = makeSquare(btn.buy2.x,btn.buy2.y,28,28,Color3.fromRGB(40,150,40),3,1)
    labels.b2Text = makeText(btn.buy2.x+14,btn.buy2.y+7,"BUY",14,Color3.fromRGB(255,255,255),true,6,1)
    regBtn("max2",px+pw-83,cY+16,58,28)
    labels.m2Bg = makeSquare(btn.max2.x,btn.max2.y,58,28,Color3.fromRGB(30,30,30),3,1)
    labels.m2Text = makeText(btn.max2.x+29,btn.max2.y+7,"MAX",14,Color3.fromRGB(80,80,80),true,6,1); cY=cY+66
    makeSquare(px+15,cY,pw-30,60,T().card,2,1)
    makeText(px+25,cY+4,"Click Multiplier x2",14,Color3.fromRGB(255,100,200),false,5,1)
    labels.u3Info = makeText(px+25,cY+22,"Level: 0 (x1)",12,T().textDim,false,5,1)
    labels.u3Cost = makeText(px+25,cY+38,"Cost: 500",12,T().coinText,false,5,1)
    regBtn("buy3",px+pw-115,cY+16,28,28)
    labels.b3Bg = makeSquare(btn.buy3.x,btn.buy3.y,28,28,Color3.fromRGB(40,150,40),3,1)
    makeText(btn.buy3.x+14,btn.buy3.y+7,"+1",14,Color3.fromRGB(255,255,255),true,6,1)
    regBtn("max3",px+pw-83,cY+16,58,28)
    labels.m3Bg = makeSquare(btn.max3.x,btn.max3.y,58,28,T().accentAlt,3,1)
    labels.m3Text = makeText(btn.max3.x+29,btn.max3.y+7,"MAX",14,Color3.fromRGB(255,255,255),true,6,1)
end

do
    local rY = contentY + 5
    makeText(px+20,rY,"[ REBIRTH ]",16,Color3.fromRGB(255,180,50),false,5,2); rY=rY+22
    labels.rbStats = makeText(px+20,rY,"Rebirths: 0 | Tokens: 0",13,Color3.fromRGB(255,220,120),false,5,2); rY=rY+18
    labels.rbMult = makeText(px+20,rY,"Rebirth Mult: x1.0",12,Color3.fromRGB(200,200,160),false,5,2); rY=rY+18
    labels.rbReq = makeText(px+20,rY,"Need: 15K coins",12,T().textDim,false,5,2); rY=rY+20
    regBtn("rebirth",px+30,rY,pw-60,36)
    labels.rbBg = makeSquare(btn.rebirth.x,btn.rebirth.y,pw-60,36,Color3.fromRGB(180,120,30),3,2)
    makeText(btn.rebirth.x+(pw-60)/2,btn.rebirth.y+9,"REBIRTH",18,Color3.fromRGB(255,255,255),true,6,2); rY=rY+44
    makeSquare(px+15,rY,pw-30,1,T().separator,2,2); rY=rY+6
    makeText(px+20,rY,"[ REBIRTH UPGRADES ]",13,Color3.fromRGB(255,200,100),false,5,2); rY=rY+20
    makeSquare(px+15,rY,pw-30,50,Color3.fromRGB(40,35,25),2,2)
    makeText(px+25,rY+4,"Starting Coins (+1,000)",12,Color3.fromRGB(255,220,100),false,5,2)
    labels.ru1Info = makeText(px+25,rY+19,"Lv: 0 (+0)",11,T().textDim,false,5,2)
    labels.ru1Cost = makeText(px+25,rY+34,"Cost: 1 Token",11,Color3.fromRGB(255,200,80),false,5,2)
    regBtn("rbuy1",px+pw-83,rY+12,58,26)
    labels.rb1Bg = makeSquare(btn.rbuy1.x,btn.rbuy1.y,58,26,Color3.fromRGB(150,100,20),3,2)
    makeText(btn.rbuy1.x+29,btn.rbuy1.y+6,"BUY",15,Color3.fromRGB(255,255,255),true,6,2); rY=rY+56
    makeSquare(px+15,rY,pw-30,50,Color3.fromRGB(40,35,25),2,2)
    makeText(px+25,rY+4,"Permanent Click (+15)",12,Color3.fromRGB(255,180,80),false,5,2)
    labels.ru2Info = makeText(px+25,rY+19,"Lv: 0 (+0)",11,T().textDim,false,5,2)
    labels.ru2Cost = makeText(px+25,rY+34,"Cost: 2 Tokens",11,Color3.fromRGB(255,200,80),false,5,2)
    regBtn("rbuy2",px+pw-83,rY+12,58,26)
    labels.rb2Bg = makeSquare(btn.rbuy2.x,btn.rbuy2.y,58,26,Color3.fromRGB(150,100,20),3,2)
    makeText(btn.rbuy2.x+29,btn.rbuy2.y+6,"BUY",15,Color3.fromRGB(255,255,255),true,6,2); rY=rY+58
    makeSquare(px+15,rY,pw-30,1,T().separator,2,2); rY=rY+6
    makeText(px+20,rY,"[ PRESTIGE ]",16,Color3.fromRGB(200,100,255),false,5,2); rY=rY+22
    labels.prStats = makeText(px+20,rY,"Prestige: 0",13,Color3.fromRGB(220,160,255),false,5,2); rY=rY+18
    labels.prMult = makeText(px+20,rY,"Prestige Mult: x1",12,Color3.fromRGB(200,160,220),false,5,2); rY=rY+18
    labels.prReq = makeText(px+20,rY,"Need: 10 Rebirths",12,T().textDim,false,5,2); rY=rY+18
    makeText(px+20,rY,"Resets rebirths & rebirth upgrades!",10,Color3.fromRGB(255,120,120),false,5,2); rY=rY+16
    regBtn("prestige",px+30,rY,pw-60,36)
    labels.prBg = makeSquare(btn.prestige.x,btn.prestige.y,pw-60,36,Color3.fromRGB(130,50,200),3,2)
    makeText(btn.prestige.x+(pw-60)/2,btn.prestige.y+9,"PRESTIGE",18,Color3.fromRGB(255,255,255),true,6,2); rY=rY+44
    makeSquare(px+15,rY,pw-30,1,T().separator,2,2); rY=rY+6
    makeText(px+20,rY,"[ TIER ]",16,Color3.fromRGB(255,100,100),false,5,2); rY=rY+22
    labels.tierStats = makeText(px+20,rY,"Tier: 0 | Mult: x1",13,Color3.fromRGB(255,180,180),false,5,2); rY=rY+18
    labels.tierReq = makeText(px+20,rY,"Need: 2 Prestiges",12,T().textDim,false,5,2); rY=rY+18
    labels.tierDesc = makeText(px+20,rY,"Resets ALL (keeps title). Unlocks Essence.",11,Color3.fromRGB(255,120,120),false,5,2); rY=rY+18
    regBtn("tier",px+30,rY,pw-60,36)
    labels.tierBg = makeSquare(btn.tier.x,btn.tier.y,pw-60,36,Color3.fromRGB(160,40,40),3,2)
    labels.tierBtnText = makeText(btn.tier.x+(pw-60)/2,btn.tier.y+9,"TIER UP",18,Color3.fromRGB(255,255,255),true,6,2)
end

do
    local gY = contentY+5
    makeText(px+20,gY,"[ TITLE ROULETTE ]",18,Color3.fromRGB(255,220,50),false,5,3); gY=gY+24
    labels.rollModeLabel = makeText(px+20,gY,"Mode: Single Roll",12,Color3.fromRGB(180,180,200),false,5,3); gY=gY+16
    makeText(px+20,gY,"Better titles won't be replaced!",11,Color3.fromRGB(140,255,140),false,5,3); gY=gY+18
    makeText(px+20,gY,"Current Title:",14,Color3.fromRGB(200,200,220),false,5,3); gY=gY+20
    labels.rollTitle = makeText(px+20,gY,"None",20,Color3.fromRGB(140,140,140),false,5,3); gY=gY+22
    labels.rollTitleMult = makeText(px+20,gY,"Multiplier: x1",13,T().textDim,false,5,3); gY=gY+20
    makeSquare(px+15,gY,pw-30,1,T().separator,2,3); gY=gY+8
    labels.rollBoxBg = makeSquare(px+25,gY,pw-50,80,Color3.fromRGB(25,25,45),2,3)
    makeSquare(px+25,gY,pw-50,2,Color3.fromRGB(255,215,0),4,3)
    makeSquare(px+25,gY+78,pw-50,2,Color3.fromRGB(255,215,0),4,3)
    makeSquare(px+25,gY,2,80,Color3.fromRGB(255,215,0),4,3)
    makeSquare(px+pw-27,gY,2,80,Color3.fromRGB(255,215,0),4,3)
    labels.rollResult = makeText(px+pw/2,gY+18,"???",28,Color3.fromRGB(100,100,100),true,6,3)
    labels.rollResultMult = makeText(px+pw/2,gY+52,"",14,T().textDim,true,6,3); gY=gY+92
    regBtn("roll",px+30,gY,pw-60,50)
    labels.rollBg = makeSquare(btn.roll.x,btn.roll.y,pw-60,50,Color3.fromRGB(200,160,30),3,3)
    labels.rollBtnText = makeText(btn.roll.x+(pw-60)/2,btn.roll.y+8,"ROLL!",24,Color3.fromRGB(255,255,255),true,6,3)
    labels.rollCostText = makeText(btn.roll.x+(pw-60)/2,btn.roll.y+34,"Cost: 35K coins",12,Color3.fromRGB(255,255,200),true,6,3); gY=gY+62
    makeSquare(px+15,gY,pw-30,1,T().separator,2,3); gY=gY+8
    makeText(px+20,gY,"[ DROP RATES ]",14,T().textDim,false,5,3); gY=gY+18
    local drops = {{"Matcha Buyer (x1.1)","59.67%",2},{"Script Dev (x1.5)","30%",3},{"Vetted Dev (x3)","5%",4},{"LUA Lead (x8)","4.3%",5},{"Executive (x30)","0.9%",6},{"The Elite (x100)","0.1%",7},{"Ascended (x250)","0.03%",8}}
    local bgC = {Color3.fromRGB(30,40,30),Color3.fromRGB(25,35,40),Color3.fromRGB(20,25,40),Color3.fromRGB(40,35,20),Color3.fromRGB(45,20,20),Color3.fromRGB(50,50,50),Color3.fromRGB(35,15,50)}
    for i,d in ipairs(drops) do
        makeSquare(px+15,gY,pw-30,18,bgC[i],2,3)
        makeText(px+22,gY+2,d[1],11,titles[d[3]].color,false,5,3)
        makeText(px+pw-60,gY+2,d[2],11,titles[d[3]].color,false,5,3); gY=gY+20
    end
    labels.omegaDrops1 = makeText(px+22,gY+2,"Singularity (x50)",11,titles[9].color,false,5,3)
    labels.omegaDrops1R = makeText(px+pw-60,gY+2,"0.002%",11,titles[9].color,false,5,3); gY=gY+16
    labels.omegaDrops2 = makeText(px+22,gY+2,"Quasar (x1900)",11,titles[10].color,false,5,3)
    labels.omegaDrops2R = makeText(px+pw-60,gY+2,"0.0004%",11,titles[10].color,false,5,3); gY=gY+16
    labels.omegaDrops3 = makeText(px+22,gY+2,"The Eye (x10000)",11,titles[11].color,false,5,3)
    labels.omegaDrops3R = makeText(px+pw-60,gY+2,"0.00006%",11,titles[11].color,false,5,3)
end

do
    labels.essLocked = makeText(px+pw/2,contentY+180,"LOCKED",28,Color3.fromRGB(100,100,140),true,5,4)
    labels.essLocked2 = makeText(px+pw/2,contentY+215,"Reach Tier 1 to unlock Essence!",14,Color3.fromRGB(140,140,180),true,5,4)
    labels.essLocked3 = makeText(px+pw/2,contentY+238,"Tier up from Rebirth tab",11,Color3.fromRGB(100,100,130),true,5,4)
    local function eS(x,y,w,h,c,z) local s=Drawing.new("Square"); s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h); s.Color=c; s.Filled=true; s.Visible=true; s.ZIndex=z or 1; s.Transparency=1; table.insert(allObjects,s); table.insert(objectData,{obj=s,ox=x-px,oy=y-py,ow=w,oh=h}); table.insert(essObjs,s); return s end
    local function eT(x,y,str,sz,c,cn,z) local t=Drawing.new("Text"); t.Position=Vector2.new(x,y); t.Text=str; t.Size=sz or 18; t.Color=c or Color3.fromRGB(255,255,255); t.Center=cn or false; t.Outline=true; t.Visible=true; t.ZIndex=z or 5; t.Transparency=1; table.insert(allObjects,t); table.insert(objectData,{obj=t,ox=x-px,oy=y-py}); table.insert(essObjs,t); return t end
    local eY = contentY+5
    eT(px+20,eY,"[ ESSENCE ]",16,Color3.fromRGB(0,255,200),false,5); eY=eY+22
    labels.essCount = eT(px+20,eY,"Essence: 0",18,Color3.fromRGB(0,255,200),false,5); eY=eY+22
    labels.essPerSec = eT(px+20,eY,"Essence/sec: 1",12,Color3.fromRGB(100,200,180),false,5); eY=eY+20
    eS(px+15,eY,pw-30,1,T().separator,2); eY=eY+6
    eT(px+20,eY,"[ ESSENCE UPGRADES ]",13,Color3.fromRGB(100,220,200),false,5); eY=eY+20
    local essUpgs = {{"Coin Boost (x1.5/lvl)","eu1","ebuy1",10},{"Essence Speed (+1/sec)","eu2","ebuy2",25},{"Super Click (+25 power)","eu3","ebuy3",50}}
    for _,eu in ipairs(essUpgs) do
        eS(px+15,eY,pw-30,50,Color3.fromRGB(20,40,35),2)
        eT(px+25,eY+4,eu[1],12,Color3.fromRGB(255,255,100),false,5)
        labels[eu[2].."Info"] = eT(px+25,eY+19,"Lv: 0",11,T().textDim,false,5)
        labels[eu[2].."Cost"] = eT(px+25,eY+34,"Cost: "..eu[4],11,Color3.fromRGB(0,220,180),false,5)
        regBtn(eu[3],px+pw-83,eY+12,58,26)
        labels[eu[3]:gsub("buy","b").."Bg"] = eS(btn[eu[3]].x,btn[eu[3]].y,58,26,Color3.fromRGB(0,120,100),3)
        eT(btn[eu[3]].x+29,btn[eu[3]].y+6,"BUY",15,Color3.fromRGB(255,255,255),true,6); eY=eY+56
    end
    eS(px+15,eY,pw-30,1,T().separator,2); eY=eY+6
    eT(px+20,eY,"[ ESSENCE REBIRTH ]",13,Color3.fromRGB(0,200,160),false,5); eY=eY+20
    labels.erStats = eT(px+20,eY,"Rebirths: 0 | Mult: x1",12,Color3.fromRGB(100,200,180),false,5); eY=eY+18
    labels.erReq = eT(px+20,eY,"Need: 1K Essence",12,T().textDim,false,5); eY=eY+20
    regBtn("ereb",px+30,eY,pw-60,34)
    labels.erBg = eS(btn.ereb.x,btn.ereb.y,pw-60,34,Color3.fromRGB(0,130,100),3)
    eT(btn.ereb.x+(pw-60)/2,btn.ereb.y+9,"ESSENCE REBIRTH",16,Color3.fromRGB(255,255,255),true,6); eY=eY+42
    eS(px+15,eY,pw-30,1,T().separator,2); eY=eY+6
    eT(px+20,eY,"[ ESSENCE PRESTIGE ]",13,Color3.fromRGB(0,180,255),false,5); eY=eY+20
    labels.epStats = eT(px+20,eY,"Prestige: 0 | Mult: x1",12,Color3.fromRGB(100,180,255),false,5); eY=eY+18
    labels.epReq = eT(px+20,eY,"Need: 5 Ess. Rebirths",12,T().textDim,false,5); eY=eY+20
    regBtn("epres",px+30,eY,pw-60,34)
    labels.epBg = eS(btn.epres.x,btn.epres.y,pw-60,34,Color3.fromRGB(0,80,180),3)
    eT(btn.epres.x+(pw-60)/2,btn.epres.y+9,"ESSENCE PRESTIGE",16,Color3.fromRGB(255,255,255),true,6)
end

do
    local sY = contentY+5
    makeText(px+20,sY,"[ SAVE & LOAD ]",18,Color3.fromRGB(100,200,150),false,5,5); sY=sY+28
    makeText(px+20,sY,"Auto-saves every 60 seconds.",12,T().textDim,false,5,5); sY=sY+16
    labels.saveStatus = makeText(px+20,sY,"Status: No save",12,Color3.fromRGB(180,180,100),false,5,5); sY=sY+24
    regBtn("save",px+30,sY,pw-60,32); makeSquare(btn.save.x,btn.save.y,pw-60,32,Color3.fromRGB(30,140,80),3,5); makeText(btn.save.x+(pw-60)/2,btn.save.y+8,"SAVE",16,Color3.fromRGB(255,255,255),true,6,5); sY=sY+38
    regBtn("load",px+30,sY,pw-60,32); makeSquare(btn.load.x,btn.load.y,pw-60,32,Color3.fromRGB(30,100,180),3,5); makeText(btn.load.x+(pw-60)/2,btn.load.y+8,"LOAD",16,Color3.fromRGB(255,255,255),true,6,5); sY=sY+40
    makeSquare(px+15,sY,pw-30,1,T().separator,2,5); sY=sY+8
    regBtn("reset",px+30,sY,pw-60,28); makeSquare(btn.reset.x,btn.reset.y,pw-60,28,Color3.fromRGB(160,30,30),3,5); makeText(btn.reset.x+(pw-60)/2,btn.reset.y+7,"RESET ALL",13,Color3.fromRGB(255,255,255),true,6,5); sY=sY+34
    regBtn("export",px+30,sY,pw-60,28); makeSquare(btn.export.x,btn.export.y,pw-60,28,Color3.fromRGB(100,60,160),3,5); makeText(btn.export.x+(pw-60)/2,btn.export.y+7,"COPY SAVE",12,Color3.fromRGB(255,255,255),true,6,5); sY=sY+38
    makeSquare(px+15,sY,pw-30,1,T().separator,2,5); sY=sY+8
    makeText(px+20,sY,"[ THEME ]",14,Color3.fromRGB(200,200,255),false,5,5); sY=sY+20
    labels.themeNameLabel = makeText(px+20,sY,"Current: "..themes[state.themeIndex].name,12,Color3.fromRGB(200,200,220),false,5,5); sY=sY+18
    for i,theme in ipairs(themes) do
        regBtn("theme"..i,px+30,sY,pw-60,22)
        labels["themeBg"..i] = makeSquare(btn["theme"..i].x,btn["theme"..i].y,pw-60,22,(i==state.themeIndex) and Color3.fromRGB(80,80,160) or Color3.fromRGB(40,40,60),3,5)
        makeText(btn["theme"..i].x+(pw-60)/2,btn["theme"..i].y+4,theme.name,11,Color3.fromRGB(220,220,255),true,6,5); sY=sY+26
    end
end

do
    labels.voidLocked = makeText(px+pw/2,contentY+180,"LOCKED",28,Color3.fromRGB(120,40,160),true,5,6)
    labels.voidLocked2 = makeText(px+pw/2,contentY+215,"Reach Tier 2 to unlock!",14,Color3.fromRGB(160,80,200),true,5,6)
    labels.voidLocked3 = makeText(px+pw/2,contentY+238,"Need: 5P + 3EP",11,Color3.fromRGB(120,60,160),true,5,6)
    local function vS(x,y,w,h,c,z) local s=Drawing.new("Square"); s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h); s.Color=c; s.Filled=true; s.Visible=true; s.ZIndex=z or 1; s.Transparency=1; table.insert(allObjects,s); table.insert(objectData,{obj=s,ox=x-px,oy=y-py,ow=w,oh=h}); table.insert(voidObjs,s); return s end
    local function vT(x,y,str,sz,c,cn,z) local t=Drawing.new("Text"); t.Position=Vector2.new(x,y); t.Text=str; t.Size=sz or 18; t.Color=c or Color3.fromRGB(255,255,255); t.Center=cn or false; t.Outline=true; t.Visible=true; t.ZIndex=z or 5; t.Transparency=1; table.insert(allObjects,t); table.insert(objectData,{obj=t,ox=x-px,oy=y-py}); table.insert(voidObjs,t); return t end
    local vY = contentY+5
    vT(px+20,vY,"[ THE VOID ]",16,Color3.fromRGB(180,50,255),false,5); vY=vY+22
    labels.voidCount = vT(px+20,vY,"Void Energy: 0",18,Color3.fromRGB(180,50,255),false,5); vY=vY+22
    labels.voidPerSec = vT(px+20,vY,"Void/sec: 1",12,Color3.fromRGB(140,80,200),false,5); vY=vY+20
    vS(px+15,vY,pw-30,1,Color3.fromRGB(100,40,160),2); vY=vY+6
    local vUpgs = {{"Void Click (+50)","vu1","vbuy1"},{"Void Flow (+1/sec)","vu2","vbuy2"},{"Cosmic Boost (x2)","vu3","vbuy3"},{"Star Drain (x1.5 ess)","vu4","vbuy4"}}
    for _,vu in ipairs(vUpgs) do
        vS(px+15,vY,pw-30,50,Color3.fromRGB(30,15,45),2)
        vT(px+25,vY+4,vu[1],12,Color3.fromRGB(200,140,255),false,5)
        labels[vu[2].."Info"] = vT(px+25,vY+19,"Lv: 0",11,Color3.fromRGB(140,120,160),false,5)
        labels[vu[2].."Cost"] = vT(px+25,vY+34,"Cost: 0",11,Color3.fromRGB(180,50,255),false,5)
        regBtn(vu[3],px+pw-83,vY+12,58,26)
        labels["vb"..vu[2]:sub(3).."Bg"] = vS(btn[vu[3]].x,btn[vu[3]].y,58,26,Color3.fromRGB(100,30,160),3)
        vT(btn[vu[3]].x+29,btn[vu[3]].y+6,"BUY",15,Color3.fromRGB(255,255,255),true,6); vY=vY+56
    end
    vS(px+15,vY,pw-30,1,Color3.fromRGB(100,40,160),2); vY=vY+6
    labels.vrStats = vT(px+20,vY,"Rebirths: 0 | Mult: x1",12,Color3.fromRGB(140,80,200),false,5); vY=vY+18
    labels.vrReq = vT(px+20,vY,"Need: 2K Void",12,T().textDim,false,5); vY=vY+20
    regBtn("vreb",px+30,vY,pw-60,34)
    labels.vrBg = vS(btn.vreb.x,btn.vreb.y,pw-60,34,Color3.fromRGB(120,30,180),3)
    vT(btn.vreb.x+(pw-60)/2,btn.vreb.y+9,"VOID REBIRTH",16,Color3.fromRGB(255,255,255),true,6); vY=vY+42
    labels.vpStats = vT(px+20,vY,"Prestige: 0 | Mult: x1",12,Color3.fromRGB(120,60,255),false,5); vY=vY+18
    labels.vpReq = vT(px+20,vY,"Need: 5 Void Rebirths",12,T().textDim,false,5); vY=vY+20
    regBtn("vpres",px+30,vY,pw-60,34)
    labels.vpBg = vS(btn.vpres.x,btn.vpres.y,pw-60,34,Color3.fromRGB(80,20,160),3)
    vT(btn.vpres.x+(pw-60)/2,btn.vpres.y+9,"VOID PRESTIGE",16,Color3.fromRGB(255,255,255),true,6)
end

labels.astralLocked = makeText(px+pw/2,contentY+180,"LOCKED",28,Color3.fromRGB(200,180,50),true,5,7)
labels.astralLocked2 = makeText(px+pw/2,contentY+215,"Reach Tier 3!",14,Color3.fromRGB(200,180,100),true,5,7)
labels.astralLocked3 = makeText(px+pw/2,contentY+238,"Need: 5P+3EP+3VP",10,Color3.fromRGB(160,140,80),true,5,7)
labels.astralTitle = makeText(px+20,contentY+5,"[ ASTRAL SKILL TREE ]",16,Color3.fromRGB(255,220,50),false,5,7)
labels.astralShards = makeText(px+20,contentY+25,"Astral Shards: 0",14,Color3.fromRGB(255,220,100),false,5,7)
labels.astralPerSec = makeText(px+20,contentY+40,"Shards/sec: 1",11,Color3.fromRGB(200,180,100),false,5,7)
labels.astralZoomLabel = makeText(px+pw-140,contentY+5,"Zoom: 100%",10,Color3.fromRGB(160,160,180),false,5,7)
labels.astralPanHint = makeText(px+pw-140,contentY+16,"+/- Zoom, Drag=Pan",9,Color3.fromRGB(120,120,140),false,5,7)
labels.nodeInfo = makeText(px+20,contentY+55,"Click a node to purchase",12,Color3.fromRGB(160,160,180),false,5,7)
labels.nodeEffect = makeText(px+20,contentY+68,"",11,Color3.fromRGB(200,200,140),false,5,7)

labels.omegaLocked = makeText(px+pw/2,contentY+180,"LOCKED",28,Color3.fromRGB(255,140,0),true,5,8)
labels.omegaLocked2 = makeText(px+pw/2,contentY+215,"Complete full Astral tree!",14,Color3.fromRGB(255,160,50),true,5,8)
labels.omegaLocked3 = makeText(px+pw/2,contentY+238,"All 28 Astral nodes required",10,Color3.fromRGB(200,120,40),true,5,8)
labels.omegaTitle = makeText(px+20,contentY+5,"[ OMEGA SKILL TREE ]",16,Color3.fromRGB(255,140,0),false,5,8)
labels.omegaEnergy = makeText(px+20,contentY+25,"Omega Energy: 0",14,Color3.fromRGB(255,160,50),false,5,8)
labels.omegaPerSec = makeText(px+20,contentY+40,"Omega/sec: 0",11,Color3.fromRGB(200,130,50),false,5,8)
labels.omegaZoomLabel = makeText(px+pw-140,contentY+5,"Zoom: 60%",10,Color3.fromRGB(160,160,180),false,5,8)
labels.omegaPanHint = makeText(px+pw-140,contentY+16,"+/- Zoom, Drag=Pan",9,Color3.fromRGB(120,120,140),false,5,8)
labels.omegaNodeInfo = makeText(px+20,contentY+55,"Click a node to purchase",12,Color3.fromRGB(200,160,100),false,5,8)
labels.omegaNodeEffect = makeText(px+20,contentY+68,"",11,Color3.fromRGB(220,180,100),false,5,8)

local function removeDrawingList(list)
    for _, obj in ipairs(list) do
        pcall(function() obj:Remove() end)
        for j=#allObjects,1,-1 do if allObjects[j]==obj then table.remove(allObjects,j); break end end
        for j=#objectData,1,-1 do if objectData[j].obj==obj then table.remove(objectData,j); break end end
        for j=#astralObjs,1,-1 do if astralObjs[j]==obj then table.remove(astralObjs,j); break end end
        for j=#omegaObjs,1,-1 do if omegaObjs[j]==obj then table.remove(omegaObjs,j); break end end
        for j=#glowObjs,1,-1 do if glowObjs[j]==obj then table.remove(glowObjs,j); break end end
        for j=#omegaGlowObjs,1,-1 do if omegaGlowObjs[j]==obj then table.remove(omegaGlowObjs,j); break end end
    end
end

local function buildGenericTree(tree, nodeState, drawings, objList, glowList, zoom, panX, panY, themePrefix, labelPrefix)
    removeDrawingList(drawings)
    for k in pairs(drawings) do drawings[k] = nil end

    local treeAreaX, treeAreaY, treeAreaW, treeAreaH = getTreeArea()
    local z = zoom
    local baseNodeW, baseNodeH = 50, 30
    local nodeW = math.max(20, math.floor(baseNodeW * z))
    local nodeH = math.max(14, math.floor(baseNodeH * z))
    local fontSize = math.max(6, math.floor(10 * z))
    local fontSizeCost = math.max(5, math.floor(9 * z))
    local canvasW = treeAreaW * z
    local canvasH = treeAreaH * z

    local t = T()
    local lockedB_c = t[themePrefix.."NodeLockedBorder"] or t.nodeLockedBorder
    local locked_c = t[themePrefix.."NodeLocked"] or t.nodeLocked
    local glowL_c = t[themePrefix.."GlowLocked"] or t.glowLocked
    local lineL_c = t[themePrefix.."LineLocked"] or t.lineLocked

    local nodePositions = {}
    for _, node in ipairs(tree) do
        local vx = node.x * canvasW + panX
        local vy = node.y * canvasH + panY
        local sx = treeAreaX + vx - nodeW / 2
        local sy = treeAreaY + vy - nodeH / 2
        nodePositions[node.id] = {x=sx, y=sy, cx=sx+nodeW/2, cy=sy+nodeH/2}
    end

    local function tS(x,y,w,h,c,zi) local s=Drawing.new("Square"); s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h); s.Color=c; s.Filled=true; s.Visible=true; s.ZIndex=zi or 1; s.Transparency=1; table.insert(allObjects,s); table.insert(objectData,{obj=s,ox=x-px,oy=y-py,ow=w,oh=h}); table.insert(objList,s); table.insert(drawings,s); return s end
    local function tT(x,y,str,sz,c,cn,zi) local t2=Drawing.new("Text"); t2.Position=Vector2.new(x,y); t2.Text=str; t2.Size=sz or 18; t2.Color=c or Color3.fromRGB(255,255,255); t2.Center=cn or false; t2.Outline=true; t2.Visible=true; t2.ZIndex=zi or 5; t2.Transparency=1; table.insert(allObjects,t2); table.insert(objectData,{obj=t2,ox=x-px,oy=y-py}); table.insert(objList,t2); table.insert(drawings,t2); return t2 end
    local function tL(x1,y1,x2,y2,c,th,zi) local l=Drawing.new("Line"); l.From=Vector2.new(x1,y1); l.To=Vector2.new(x2,y2); l.Color=c; l.Thickness=th or 2; l.Visible=true; l.ZIndex=zi or 2; l.Transparency=1; table.insert(allObjects,l); table.insert(objectData,{obj=l,ox1=x1-px,oy1=y1-py,ox2=x2-px,oy2=y2-py,isLine=true}); table.insert(objList,l); table.insert(drawings,l); return l end
    local function tG(x,y,r,c,zi) local g=Drawing.new("Circle"); g.Position=Vector2.new(x,y); g.Radius=r; g.Color=c; g.Filled=true; g.Visible=true; g.ZIndex=zi or 1; g.Transparency=0.3; g.NumSides=24; table.insert(allObjects,g); table.insert(objectData,{obj=g,ox=x-px,oy=y-py,isCircle=true}); table.insert(objList,g); table.insert(drawings,g); table.insert(glowList,g); return g end

    for _, node in ipairs(tree) do
        local pos = nodePositions[node.id]
        local function drawLine(pid)
            local pp = nodePositions[pid]
            if pp then labels[labelPrefix.."line_"..pid.."_"..node.id] = tL(pp.cx,pp.cy,pos.cx,pos.cy,lineL_c,math.max(1,math.floor(2*z)),2) end
        end
        if node.parents then for _,pid in ipairs(node.parents) do drawLine(pid) end
        elseif node.parent then drawLine(node.parent) end
    end

    for _, node in ipairs(tree) do
        local pos = nodePositions[node.id]
        regBtn(labelPrefix.."node_"..node.id, pos.x, pos.y, nodeW, nodeH)
        labels[labelPrefix.."nodeGlow_"..node.id] = tG(pos.cx, pos.cy, math.floor(nodeW*0.65), glowL_c, 1)
        labels[labelPrefix.."nodeBorder_"..node.id] = tS(pos.x-1, pos.y-1, nodeW+2, nodeH+2, lockedB_c, 2)
        labels[labelPrefix.."nodeBg_"..node.id] = tS(pos.x, pos.y, nodeW, nodeH, locked_c, 3)
        labels[labelPrefix.."nodeName_"..node.id] = tT(pos.cx, pos.y+math.floor(4*z), node.name, fontSize, Color3.fromRGB(180,180,180), true, 6)
        labels[labelPrefix.."nodeCost_"..node.id] = tT(pos.cx, pos.y+math.floor(18*z), node.cost > 0 and formatNumber(node.cost) or "FREE", fontSizeCost, Color3.fromRGB(140,140,140), true, 6)
    end
end

local function clearTreeLabels(tree, labelPrefix)
    for _, node in ipairs(tree) do
        btn[labelPrefix.."node_"..node.id] = nil
        for _, prefix in ipairs({labelPrefix.."nodeGlow_",labelPrefix.."nodeBorder_",labelPrefix.."nodeBg_",labelPrefix.."nodeName_",labelPrefix.."nodeCost_"}) do
            labels[prefix..node.id] = nil
        end
        if node.parents then for _,pid in ipairs(node.parents) do labels[labelPrefix.."line_"..pid.."_"..node.id] = nil end
        elseif node.parent then labels[labelPrefix.."line_"..node.parent.."_"..node.id] = nil end
    end
end

rebuildAstralTree = function()
    clearTreeLabels(astralSkillTree, "a_")
    buildGenericTree(astralSkillTree, state.skillNodes, astralDrawings, astralObjs, glowObjs, astralZoom, astralPanX, astralPanY, "", "a_")
    labels.astralZoomLabel.Text = "Zoom: "..math.floor(astralZoom*100).."%"
    astralBuilt = true
    local vis = (state.currentTab == 7 and state.tier >= 3 and not state.minimized)
    for _, obj in ipairs(astralObjs) do obj.Visible = vis end
    for _, g in ipairs(glowObjs) do g.Visible = vis end
end

rebuildOmegaTree = function()
    clearTreeLabels(omegaSkillTree, "om_")
    buildGenericTree(omegaSkillTree, state.omegaNodes, omegaDrawings, omegaObjs, omegaGlowObjs, omegaZoom, omegaPanX, omegaPanY, "omega", "om_")
    labels.omegaZoomLabel.Text = "Zoom: "..math.floor(omegaZoom*100).."%"
    omegaBuilt = true
    local vis = (state.currentTab == 8 and state.tier >= 4 and not state.minimized)
    for _, obj in ipairs(omegaObjs) do obj.Visible = vis end
    for _, g in ipairs(omegaGlowObjs) do g.Visible = vis end
end

local function panAstralTree()
    if not astralBuilt then return end
    repositionTreeNodes(astralSkillTree, "a_", astralZoom, astralPanX, astralPanY)
end

local function panOmegaTree()
    if not omegaBuilt then return end
    repositionTreeNodes(omegaSkillTree, "om_", omegaZoom, omegaPanX, omegaPanY)
end

local function isNodeAvail(nodeId, tree, nodeState)
    if nodeState[nodeId] then return false end
    for _, node in ipairs(tree) do
        if node.id == nodeId then
            if node.parents then
                for _,pid in ipairs(node.parents) do if not nodeState[pid] then return false end end
                return true
            elseif node.parent then return nodeState[node.parent] == true
            else return true end
        end
    end
    return false
end

local function getNodeCost(nodeId, tree)
    for _, node in ipairs(tree) do if node.id == nodeId then return node.cost end end
    return 999999
end

local function allAstralOwned()
    for _, node in ipairs(astralSkillTree) do if not state.skillNodes[node.id] then return false end end
    return true
end

local function updateTreeColors(tree, nodeState, labelPrefix, themePrefix, currency)
    local t = T()
    local owned_c = t[themePrefix.."NodeOwned"] or t.nodeOwned
    local ownedB_c = t[themePrefix.."NodeOwnedBorder"] or t.nodeOwnedBorder
    local avail_c = t[themePrefix.."NodeAvail"] or t.nodeAvail
    local availB_c = t[themePrefix.."NodeAvailBorder"] or t.nodeAvailBorder
    local locked_c = t[themePrefix.."NodeLocked"] or t.nodeLocked
    local lockedB_c = t[themePrefix.."NodeLockedBorder"] or t.nodeLockedBorder
    local glowO_c = t[themePrefix.."GlowOwned"] or t.glowOwned
    local glowA_c = t[themePrefix.."GlowAvail"] or t.glowAvail
    local glowL_c = t[themePrefix.."GlowLocked"] or t.glowLocked
    local lineO_c = t[themePrefix.."LineOwned"] or t.lineOwned
    local lineA_c = t[themePrefix.."LineAvail"] or t.lineAvail
    local lineL_c = t[themePrefix.."LineLocked"] or t.lineLocked
    local z = (themePrefix=="omega") and omegaZoom or astralZoom
    for _, node in ipairs(tree) do
        local owned = nodeState[node.id]
        local available = isNodeAvail(node.id, tree, nodeState)
        if not labels[labelPrefix.."nodeBg_"..node.id] then return end
        if owned then
            labels[labelPrefix.."nodeBg_"..node.id].Color = owned_c
            labels[labelPrefix.."nodeBorder_"..node.id].Color = ownedB_c
            labels[labelPrefix.."nodeName_"..node.id].Color = Color3.fromRGB(255,255,255)
            labels[labelPrefix.."nodeCost_"..node.id].Text = "OWNED"
            labels[labelPrefix.."nodeCost_"..node.id].Color = Color3.fromRGB(255,255,200)
            if labels[labelPrefix.."nodeGlow_"..node.id] then labels[labelPrefix.."nodeGlow_"..node.id].Color=glowO_c; labels[labelPrefix.."nodeGlow_"..node.id].Transparency=0.35 end
        elseif available then
            local cost = getNodeCost(node.id, tree); local canAfford = currency >= cost
            labels[labelPrefix.."nodeBg_"..node.id].Color = canAfford and avail_c or Color3.fromRGB(60,60,40)
            labels[labelPrefix.."nodeBorder_"..node.id].Color = canAfford and availB_c or Color3.fromRGB(120,120,60)
            labels[labelPrefix.."nodeName_"..node.id].Color = Color3.fromRGB(220,220,220)
            labels[labelPrefix.."nodeCost_"..node.id].Text = formatNumber(cost)
            labels[labelPrefix.."nodeCost_"..node.id].Color = canAfford and Color3.fromRGB(100,255,100) or Color3.fromRGB(200,200,100)
            if labels[labelPrefix.."nodeGlow_"..node.id] then labels[labelPrefix.."nodeGlow_"..node.id].Color=glowA_c; labels[labelPrefix.."nodeGlow_"..node.id].Transparency=canAfford and 0.25 or 0.12 end
        else
            labels[labelPrefix.."nodeBg_"..node.id].Color = locked_c
            labels[labelPrefix.."nodeBorder_"..node.id].Color = lockedB_c
            labels[labelPrefix.."nodeName_"..node.id].Color = Color3.fromRGB(80,80,80)
            labels[labelPrefix.."nodeCost_"..node.id].Text = "LOCKED"
            labels[labelPrefix.."nodeCost_"..node.id].Color = Color3.fromRGB(80,80,80)
            if labels[labelPrefix.."nodeGlow_"..node.id] then labels[labelPrefix.."nodeGlow_"..node.id].Color=glowL_c; labels[labelPrefix.."nodeGlow_"..node.id].Transparency=0.05 end
        end
        local function updateLine(pid)
            local lk = labelPrefix.."line_"..pid.."_"..node.id
            if labels[lk] then
                if owned then labels[lk].Color=lineO_c; labels[lk].Thickness=math.max(2,math.floor(3*z))
                elseif available then labels[lk].Color=lineA_c; labels[lk].Thickness=math.max(1,math.floor(2*z))
                else labels[lk].Color=lineL_c; labels[lk].Thickness=math.max(1,math.floor(z)) end
            end
        end
        if node.parents then for _,pid in ipairs(node.parents) do updateLine(pid) end
        elseif node.parent then updateLine(node.parent) end
    end
end

local function buyAstralNode(nodeId)
    if state.skillNodes[nodeId] then return end
    if not isNodeAvail(nodeId, astralSkillTree, state.skillNodes) then notify("Unlock parents first!","Locked!",2); return end
    local cost = getNodeCost(nodeId, astralSkillTree)
    if state.astralShards < cost then notify("Need "..formatNumber(cost).." shards","Not Enough!",2); return end
    state.astralShards = state.astralShards - cost
    state.skillNodes[nodeId] = true
    for _,n in ipairs(astralSkillTree) do if n.id==nodeId then notify(n.effect,nodeId:upper().." Unlocked!",3); break end end
    updateTreeColors(astralSkillTree, state.skillNodes, "a_", "", state.astralShards)
    updateUI()
end

local function buyOmegaNode(nodeId)
    if state.omegaNodes[nodeId] then return end
    if not isNodeAvail(nodeId, omegaSkillTree, state.omegaNodes) then notify("Unlock parents first!","Locked!",2); return end
    local cost = getNodeCost(nodeId, omegaSkillTree)
    if state.omegaEnergy < cost then notify("Need "..formatNumber(cost).." omega","Not Enough!",2); return end
    state.omegaEnergy = state.omegaEnergy - cost
    state.omegaNodes[nodeId] = true
    for _,n in ipairs(omegaSkillTree) do if n.id==nodeId then notify(n.effect,nodeId:upper().." Unlocked!",3); break end end
    updateTreeColors(omegaSkillTree, state.omegaNodes, "om_", "omega", state.omegaEnergy)
    updateUI()
end

local function serializeState()
    local ns = ""; for _,n in ipairs(astralSkillTree) do ns = ns..(state.skillNodes[n.id] and "1" or "0") end
    local os = ""; for _,n in ipairs(omegaSkillTree) do os = os..(state.omegaNodes[n.id] and "1" or "0") end
    local p = {math.floor(state.coins),state.clickPower,state.clickMultiplier,state.autoUnlocked and 1 or 0,state.upgrades.click.level,state.upgrades.auto.level,state.upgrades.multi.level,state.rebirths,state.rebirthTokens,state.rebirthUpgrades.startCoins.level,state.rebirthUpgrades.permClick.level,state.prestige,state.titleIndex,state.tier,math.floor(state.essence),state.essenceRebirths,state.essencePrestige,state.essenceUpgrades.coinBoost.level,state.essenceUpgrades.essSpeed.level,state.essenceUpgrades.superClick.level,math.floor(state.voidEnergy),state.voidRebirths,state.voidPrestige,state.voidUpgrades.voidClick.level,state.voidUpgrades.voidFlow.level,state.voidUpgrades.cosmicBoost.level,state.voidUpgrades.starDrain.level,math.floor(state.astralShards),#astralSkillTree..":"..ns,state.themeIndex,math.floor(state.omegaEnergy),#omegaSkillTree..":"..os}
    local s = {}; for i,v in ipairs(p) do s[i]=tostring(v) end; return table.concat(s,",")
end

local function deserializeState(data)
    if not data or data == "" then return false end
    local p = {}; for val in string.gmatch(data,"([^,]+)") do table.insert(p,val) end
    if #p < 12 then return false end
    state.coins=tonumber(p[1])or 0;state.clickPower=tonumber(p[2])or 1;state.clickMultiplier=tonumber(p[3])or 1
    state.autoUnlocked=(tonumber(p[4])or 0)>=1
    state.upgrades.click.level=tonumber(p[5])or 0;state.upgrades.auto.level=tonumber(p[6])or 0;state.upgrades.multi.level=tonumber(p[7])or 0
    state.rebirths=tonumber(p[8])or 0;state.rebirthTokens=tonumber(p[9])or 0
    state.rebirthUpgrades.startCoins.level=tonumber(p[10])or 0;state.rebirthUpgrades.permClick.level=tonumber(p[11])or 0
    state.prestige=tonumber(p[12])or 0;state.titleIndex=tonumber(p[13])or 1;state.tier=tonumber(p[14])or 0;state.essence=tonumber(p[15])or 0
    state.essenceRebirths=tonumber(p[16])or 0;state.essencePrestige=tonumber(p[17])or 0
    state.essenceUpgrades.coinBoost.level=tonumber(p[18])or 0;state.essenceUpgrades.essSpeed.level=tonumber(p[19])or 0;state.essenceUpgrades.superClick.level=tonumber(p[20])or 0
    state.voidEnergy=tonumber(p[21])or 0;state.voidRebirths=tonumber(p[22])or 0;state.voidPrestige=tonumber(p[23])or 0
    state.voidUpgrades.voidClick.level=tonumber(p[24])or 0;state.voidUpgrades.voidFlow.level=tonumber(p[25])or 0;state.voidUpgrades.cosmicBoost.level=tonumber(p[26])or 0;state.voidUpgrades.starDrain.level=tonumber(p[27])or 0
    state.astralShards=tonumber(p[28])or 0
    if p[29] then local d=p[29]; local c=string.find(d,":"); local ns=c and string.sub(d,c+1) or d; for i,n in ipairs(astralSkillTree) do state.skillNodes[n.id]=(i<=#ns and string.sub(ns,i,i)=="1") end end
    state.themeIndex=tonumber(p[30])or 1;state.omegaEnergy=tonumber(p[31])or 0
    if p[32] then local d=p[32]; local c=string.find(d,":"); local ns=c and string.sub(d,c+1) or d; for i,n in ipairs(omegaSkillTree) do state.omegaNodes[n.id]=(i<=#ns and string.sub(ns,i,i)=="1") end end
    if state.themeIndex<1 or state.themeIndex>#themes then state.themeIndex=1 end
    if state.titleIndex<1 or state.titleIndex>#titles then state.titleIndex=1 end
    return true
end

local function updateSaveStatus() pcall(function() if isfile(SAVE_FILE) then local r=readfile(SAVE_FILE); saveFileExists=(r and r~="") else saveFileExists=false end end) end
local function saveGame() local ok,err=pcall(function() writefile(SAVE_FILE,base64encode(serializeState())) end); if ok then saveFileExists=true end; notify(ok and "Saved!" or tostring(err),ok and "Game Saved!" or "Save Failed!",2) end
local function loadGame() pcall(function() if not isfile(SAVE_FILE) then return end; local r=readfile(SAVE_FILE); if not r or r=="" then return end; if deserializeState(base64decode(r)) then saveFileExists=true; notify("Welcome back!","Game Loaded!",2) end end) end

local function getCost(upg) local r=upg.baseCost*(upg.costMult^upg.level); if r~=r or r==math.huge then return 1e18 end; return math.floor(r) end
local function rebirthMultiplier() return 1+(state.rebirths*0.5) end
local function prestigeMultiplier() return math.min(3^state.prestige,1e300) end
local function titleMultiplier() return titles[state.titleIndex].mult end
local function tierMultiplier() if state.tier==0 then return 1 elseif state.tier==1 then return 25 elseif state.tier==2 then return 150 elseif state.tier==3 then return 10000 else return 1000000 end end
local function essenceCoinBoost() return math.min(1.5^state.essenceUpgrades.coinBoost.level,1e300) end
local function essenceRebirthMult() return math.min(2^state.essenceRebirths,1e300) end
local function essencePrestigeMult() return math.min(3^state.essencePrestige,1e300) end
local function cosmicBoostMult() return math.min(2^state.voidUpgrades.cosmicBoost.level,1e300) end
local function voidRebirthMult() return math.min(2^state.voidRebirths,1e300) end
local function voidPrestigeMult() return math.min(4^state.voidPrestige,1e300) end
local function starDrainMult() return math.min(1.5^state.voidUpgrades.starDrain.level,1e300) end

local function sn(id) return state.skillNodes[id] end
local function on(id) return state.omegaNodes[id] end
local function skillDefMult() return sn("def") and 1.5 or 1 end
local function skillMultiMult() return sn("multi") and 3 or 1 end
local function skillFusionMult() return sn("fusion") and 5 or 1 end
local function skillOmegaMult() return sn("omega") and 50 or 1 end
local function skillAtkBonus() return (sn("atk") and 100 or 0)+(sn("blade") and 250 or 0) end
local function skillShieldMult() return (sn("shield") and 2 or 1)*(sn("ward") and 3 or 1) end
local function skillRegenBonus() return sn("regen") and 5 or 0 end
local function skillSpdMult() return sn("spd") and 0.8 or 1 end
local function skillHasteMult() return sn("haste") and 1.5 or 1 end
local function skillWealthMult() return sn("wealth") and 5 or 1 end
local function skillNovaMult() return sn("nova") and 8 or 1 end
local function skillRushMult() return sn("rush") and 2 or 1 end
local function skillTempoBonus() return sn("tempo") and 10 or 0 end
local function skillBastionMult() return sn("bastion") and 4 or 1 end
local function skillFortMult() return sn("fort") and 5 or 1 end
local function skillTitanBonus() return sn("titan") and 10 or 0 end
local function skillFluxMult() return sn("flux") and 4 or 1 end
local function skillApexMult() return sn("apex") and 15 or 1 end
local function skillEternalMult() return sn("eternal") and 15 or 1 end
local function skillHarmonyMult() return sn("harmony") and 8 or 1 end
local function skillArmorMult() return sn("armor") and 2 or 1 end

local function omegaClickBonus() local b=0; if on("o_power") then b=b+500 end; if on("o_might") then b=b+1000 end; if on("o_titan") then b=b+5000 end; return b end
local function omegaCoinMult() local m=1; if on("o_wisdom") then m=m*3 end; if on("o_insight") then m=m*5 end; if on("o_sage") then m=m*10 end; if on("o_fortune") then m=m*15 end; if on("o_midas") then m=m*100 end; if on("o_supernova") then m=m*50 end; return m end
local function omegaGenMult() local m=1; if on("o_chaos") then m=m*2 end; if on("o_cosmos") then m=m*20 end; if on("o_eternity") then m=m*50 end; if on("o_genesis") then m=m*100 end; if on("o_rebirth_star") then m=m*200 end; if on("o_nexus_core") then m=m*300 end; if on("o_convergence") then m=m*500 end; return m end
local function omegaEverythingMult() local m=1; if on("o_absolute") then m=m*10000 end; if on("o_divine_L") then m=m*1000 end; if on("o_divine_R") then m=m*500 end; if on("o_warpath") then m=m*200 end; if on("o_ascension") then m=m*50 end; return m end
local function omegaAstralMult() local m=1; if on("o_rift") then m=m*2 end; if on("o_nexus") then m=m*2 end; if on("o_stellar") then m=m*8 end; if on("o_infinity") then m=m*15 end; if on("o_multiverse") then m=m*25 end; if on("o_star_forge") then m=m*100 end; if on("o_prime_R") then m=m*1000 end; if on("o_zenith_R") then m=m*3000 end; return m end
local function omegaOmegaGenMult() local m=1; if on("o_warp") then m=m*3 end; if on("o_dimension") then m=m*5 end; if on("o_omniscient") then m=m*10 end; return m end
local function omegaCritData() if on("o_godstrike") then return {chance=40,mult=30} elseif on("o_berserk") then return {chance=30,mult=20} elseif on("o_rage") then return {chance=20,mult=15} else return nil end end

local function totalMultiplier() local m=rebirthMultiplier()*prestigeMultiplier()*titleMultiplier()*tierMultiplier()*essenceCoinBoost()*essencePrestigeMult()*cosmicBoostMult()*voidPrestigeMult()*skillDefMult()*skillMultiMult()*skillFusionMult()*skillOmegaMult()*skillWealthMult()*skillNovaMult()*skillApexMult()*skillHarmonyMult()*skillFluxMult()*omegaCoinMult()*omegaEverythingMult(); if m~=m or m==math.huge then return 1e300 end; return m end
local function effectiveClickBase() local base=state.clickPower+state.rebirthUpgrades.permClick.level*15+state.essenceUpgrades.superClick.level*25+state.voidUpgrades.voidClick.level*50+skillAtkBonus()+omegaClickBonus(); local r=base*math.min(state.clickMultiplier,1e300)*totalMultiplier(); if r~=r or r==math.huge then return 1e300 end; return r end
local function effectiveClickWithCrit() local total=effectiveClickBase(); local oCrit=omegaCritData(); if oCrit then if math.random(1,1000)<=(oCrit.chance*10) then total=total*oCrit.mult;state.critActive=true else state.critActive=false end elseif sn("fury") or sn("storm") then local ch,ml=10,5; if sn("storm") then ch=25;ml=12 elseif sn("fury") then ch=15;ml=8 end; if math.random(1,100)<=ch then total=total*ml;state.critActive=true else state.critActive=false end elseif sn("crit") or sn("fusion") then if math.random(1,100)<=10 then total=total*5;state.critActive=true else state.critActive=false end else state.critActive=false end; if total~=total or total==math.huge then return 1e300 end; return total end
local function effectiveAutoClick() return effectiveClickBase() end
local function effectiveClickDisplay() return effectiveClickBase() end
local function autoInterval() local base=math.max(0.05,1.0-state.upgrades.auto.level*0.05); return base*skillSpdMult()/skillHasteMult() end
local function effectivePerSecond() if not state.autoUnlocked then return 0 end; return effectiveClickDisplay()/autoInterval() end
local function effectiveEssPerSec() if state.tier<1 then return 0 end; local r=(1+state.essenceUpgrades.essSpeed.level)*essenceRebirthMult()*starDrainMult()*skillShieldMult()*skillRushMult()*skillBastionMult()*skillFortMult()*skillEternalMult()*omegaGenMult()*omegaEverythingMult(); if r~=r or r==math.huge then return 1e300 end; return r end
local function effectiveVoidPerSec() if state.tier<2 then return 0 end; local r=(1+state.voidUpgrades.voidFlow.level+skillRegenBonus())*voidRebirthMult()*skillArmorMult()*skillRushMult()*skillBastionMult()*skillFortMult()*skillEternalMult()*omegaGenMult()*omegaEverythingMult(); if r~=r or r==math.huge then return 1e300 end; return r end
local function effectiveAstralPerSec() if state.tier<3 then return 0 end; local r=(1+skillTempoBonus()+skillTitanBonus())*skillOmegaMult()*skillFluxMult()*skillHarmonyMult()*omegaGenMult()*omegaAstralMult()*omegaEverythingMult(); if r~=r or r==math.huge then return 1e300 end; return r end
local function effectiveOmegaPerSec() if state.tier<4 then return 0 end; local r=1*omegaOmegaGenMult()*omegaEverythingMult(); if r~=r or r==math.huge then return 1e300 end; return r end

local function rebirthCost() return safeCost(15000*(3^state.rebirths)) end
local function prestigeCost() return 10*(state.prestige+1) end
local function essRebirthCost() return safeCost(1000*(3^state.essenceRebirths)) end
local function essPrestigeCost() return 5*(state.essencePrestige+1) end
local function voidRebirthCost() return safeCost(2000*(3^state.voidRebirths)) end
local function voidPrestigeCost() return 5*(state.voidPrestige+1) end
local function rebirthUpgCost(n) if n=="startCoins" then return 1+state.rebirthUpgrades.startCoins.level else return 2+state.rebirthUpgrades.permClick.level*2 end end
local function tierRequirementsMet() if state.tier==0 then return state.prestige>=2 elseif state.tier==1 then return state.prestige>=5 and state.essencePrestige>=3 elseif state.tier==2 then return state.prestige>=5 and state.essencePrestige>=3 and state.voidPrestige>=3 elseif state.tier==3 then return allAstralOwned() else return false end end

local function rollTitle() local r=math.random(1,10000000); if state.tier>=4 then if r<=6 then return 11 elseif r<=47 then return 10 elseif r<=247 then return 9 elseif r<=3247 then return 8 elseif r<=13247 then return 7 elseif r<=103247 then return 6 elseif r<=533247 then return 5 elseif r<=1033247 then return 4 elseif r<=4033247 then return 3 else return 2 end elseif state.tier>=2 then local r2=math.random(1,10000); if r2<=5967 then return 2 elseif r2<=8967 then return 3 elseif r2<=9467 then return 4 elseif r2<=9897 then return 5 elseif r2<=9987 then return 6 elseif r2<=9997 then return 7 else return 8 end else local r2=math.random(1,10000); if r2<=5970 then return 2 elseif r2<=8970 then return 3 elseif r2<=9470 then return 4 elseif r2<=9900 then return 5 elseif r2<=9990 then return 6 else return 7 end end end

local function applyTheme() local t=T(); labels.bodyBg.Color=t.bg; labels.headerBg.Color=t.header; labels.headerTitle.Color=t.headerText; labels.closeBg.Color=t.closeBtn; labels.footerBg.Color=t.footer; labels.footerText.Color=t.footerText; labels.coins.Color=t.coinText; labels.resizeC.Color=t.resize; labels.resizeGrip.Color=t.resize; for i=1,8 do labels["tab"..i.."Bg"].Color=(i==state.currentTab) and t.tabActive or t.tabInactive; labels["tab"..i.."L"].Color=(i==state.currentTab) and t.tabTextActive or t.tabTextInactive end; for i=1,#themes do if labels["themeBg"..i] then labels["themeBg"..i].Color=(i==state.themeIndex) and Color3.fromRGB(80,80,160) or Color3.fromRGB(40,40,60) end end; labels.themeNameLabel.Text="Current: "..t.name; rebuildAstralTree(); rebuildOmegaTree() end

updateUI = function()
    if state.minimized then return end
    local ec,eps = effectiveClickDisplay(),effectivePerSecond()
    local ct = titles[state.titleIndex]
    labels.coins.Text="Coins: "..formatNumber(state.coins); labels.stats.Text="Click: "..formatNumber(ec).."  |  /Sec: "..formatNumber(eps); labels.mult.Text="Total Mult: x"..formatNumber(totalMultiplier()); labels.clickSub.Text="+"..formatNumber(ec).." coins"; labels.title.Text="Title: "..ct.name.." (x"..ct.mult..")"; labels.title.Color=ct.color
    local c1=getCost(state.upgrades.click); labels.u1Info.Text="Level: "..state.upgrades.click.level; labels.u1Cost.Text="Cost: "..formatNumber(c1); labels.b1Bg.Color=state.coins>=c1 and Color3.fromRGB(40,170,40) or Color3.fromRGB(120,40,40)
    if not state.autoUnlocked then labels.u2Title.Text="Auto Clicker [UNLOCK]"; labels.u2Info.Text="Unlocks auto clicking"; labels.u2Cost.Text="Cost: "..formatNumber(AUTO_UNLOCK_COST); labels.b2Bg.Color=state.coins>=AUTO_UNLOCK_COST and Color3.fromRGB(40,170,40) or Color3.fromRGB(120,40,40); labels.b2Text.Text="BUY"; labels.m2Bg.Color=Color3.fromRGB(30,30,30); labels.m2Text.Color=Color3.fromRGB(80,80,80)
    else local c2=getCost(state.upgrades.auto); labels.u2Title.Text="Auto Speed (-0.05s)"; labels.u2Info.Text="Lv: "..state.upgrades.auto.level.." ("..string.format("%.2f",autoInterval()).."s)"; labels.u2Cost.Text="Cost: "..formatNumber(c2); labels.b2Bg.Color=state.coins>=c2 and Color3.fromRGB(40,170,40) or Color3.fromRGB(120,40,40); labels.b2Text.Text="+1"; if state.rebirths<5 then labels.m2Bg.Color=Color3.fromRGB(30,30,30);labels.m2Text.Color=Color3.fromRGB(80,80,80) else labels.m2Bg.Color=state.coins>=c2 and Color3.fromRGB(30,120,180) or Color3.fromRGB(40,50,70);labels.m2Text.Color=Color3.fromRGB(255,255,255) end end
    local c3=getCost(state.upgrades.multi); labels.u3Info.Text="Level: "..state.upgrades.multi.level.." (x"..formatNumber(state.clickMultiplier)..")"; labels.u3Cost.Text="Cost: "..formatNumber(c3); labels.b3Bg.Color=state.coins>=c3 and Color3.fromRGB(40,170,40) or Color3.fromRGB(120,40,40)
    if state.rebirths<5 then labels.m1Bg.Color=Color3.fromRGB(30,30,30);labels.m1Text.Color=Color3.fromRGB(80,80,80);labels.m3Bg.Color=Color3.fromRGB(30,30,30);labels.m3Text.Color=Color3.fromRGB(80,80,80) else labels.m1Bg.Color=state.coins>=c1 and Color3.fromRGB(30,120,180) or Color3.fromRGB(40,50,70);labels.m1Text.Color=Color3.fromRGB(255,255,255);labels.m3Bg.Color=state.coins>=c3 and Color3.fromRGB(30,120,180) or Color3.fromRGB(40,50,70);labels.m3Text.Color=Color3.fromRGB(255,255,255) end
    labels.rbStats.Text="Rebirths: "..state.rebirths.." | Tokens: "..state.rebirthTokens; labels.rbMult.Text="Rebirth Mult: x"..string.format("%.1f",rebirthMultiplier()); labels.rbReq.Text="Need: "..formatNumber(rebirthCost()).." coins"; labels.rbBg.Color=state.coins>=rebirthCost() and Color3.fromRGB(200,140,30) or Color3.fromRGB(100,60,20)
    local rc1=rebirthUpgCost("startCoins"); labels.ru1Info.Text="Lv: "..state.rebirthUpgrades.startCoins.level.." (+"..formatNumber(state.rebirthUpgrades.startCoins.level*1000)..")"; labels.ru1Cost.Text="Cost: "..rc1.." Token"..(rc1>1 and "s" or ""); labels.rb1Bg.Color=state.rebirthTokens>=rc1 and Color3.fromRGB(180,130,30) or Color3.fromRGB(80,50,20)
    local rc2=rebirthUpgCost("permClick"); labels.ru2Info.Text="Lv: "..state.rebirthUpgrades.permClick.level.." (+"..tostring(state.rebirthUpgrades.permClick.level*15)..")"; labels.ru2Cost.Text="Cost: "..rc2.." Tokens"; labels.rb2Bg.Color=state.rebirthTokens>=rc2 and Color3.fromRGB(180,130,30) or Color3.fromRGB(80,50,20)
    labels.prStats.Text="Prestige: "..state.prestige; labels.prMult.Text="Prestige Mult: x"..formatNumber(prestigeMultiplier()); labels.prReq.Text="Need: "..prestigeCost().." Rebirths"; labels.prBg.Color=state.rebirths>=prestigeCost() and Color3.fromRGB(160,60,240) or Color3.fromRGB(60,20,80)
    labels.tierStats.Text="Tier: "..state.tier.." | Mult: x"..formatNumber(tierMultiplier())
    if state.tier>=4 then labels.tierReq.Text="MAXED";labels.tierBtnText.Text="MAXED";labels.tierBg.Color=Color3.fromRGB(60,60,60);labels.tierDesc.Text="All tiers unlocked!" elseif state.tier==3 then labels.tierReq.Text="Full Astral Tree";labels.tierBtnText.Text="TIER UP";labels.tierDesc.Text="Unlocks Omega! x1M mult!";labels.tierBg.Color=tierRequirementsMet() and Color3.fromRGB(255,140,0) or Color3.fromRGB(80,45,0) elseif state.tier==2 then labels.tierReq.Text="Need: 5P+3EP+3VP";labels.tierBtnText.Text="TIER UP";labels.tierDesc.Text="Unlocks Astral. x10K mult!";labels.tierBg.Color=tierRequirementsMet() and Color3.fromRGB(200,170,30) or Color3.fromRGB(80,60,15) elseif state.tier==1 then labels.tierReq.Text="Need: 5P+3EP";labels.tierBtnText.Text="TIER UP";labels.tierDesc.Text="Unlocks Void. x150 mult!";labels.tierBg.Color=tierRequirementsMet() and Color3.fromRGB(120,30,180) or Color3.fromRGB(50,15,70) else labels.tierReq.Text="Need: 2 Prestiges";labels.tierBtnText.Text="TIER UP";labels.tierDesc.Text="Unlocks Essence. x25 mult!";labels.tierBg.Color=tierRequirementsMet() and Color3.fromRGB(200,50,50) or Color3.fromRGB(80,20,20) end
    labels.rollTitle.Text=ct.name; labels.rollTitle.Color=ct.color; labels.rollTitleMult.Text="Multiplier: x"..ct.mult; local rollCost=state.tier>=4 and (ROLL_COST*10) or ROLL_COST; labels.rollModeLabel.Text=state.tier>=4 and "Mode: 10x Roll (best kept!)" or "Mode: Single Roll"; labels.rollCostText.Text="Cost: "..formatNumber(rollCost).." coins"; labels.rollBtnText.Text=state.tier>=4 and "ROLL x10!" or "ROLL!"; labels.rollBg.Color=(state.coins>=rollCost and not state.rolling) and Color3.fromRGB(200,160,30) or Color3.fromRGB(80,60,15)
    local omegaVis=state.tier>=4; labels.omegaDrops1.Visible=(state.currentTab==3 and omegaVis); labels.omegaDrops1R.Visible=labels.omegaDrops1.Visible; labels.omegaDrops2.Visible=labels.omegaDrops1.Visible; labels.omegaDrops2R.Visible=labels.omegaDrops1.Visible; labels.omegaDrops3.Visible=labels.omegaDrops1.Visible; labels.omegaDrops3R.Visible=labels.omegaDrops1.Visible
    labels.essCount.Text="Essence: "..formatNumber(state.essence); labels.essPerSec.Text="Essence/sec: "..formatNumber(effectiveEssPerSec())
    local eUpgData = {{"coinBoost","eu1","eb1"},{"essSpeed","eu2","eb2"},{"superClick","eu3","eb3"}}
    for _,eu in ipairs(eUpgData) do local upg=state.essenceUpgrades[eu[1]]; local cost=getCost(upg); labels[eu[2].."Info"].Text="Lv: "..upg.level; labels[eu[2].."Cost"].Text="Cost: "..formatNumber(cost).." Ess."; labels[eu[3].."Bg"].Color=state.essence>=cost and Color3.fromRGB(0,150,120) or Color3.fromRGB(40,60,50) end
    labels.erStats.Text="Rebirths: "..state.essenceRebirths.." | Mult: x"..formatNumber(essenceRebirthMult()); labels.erReq.Text="Need: "..formatNumber(essRebirthCost()).." Essence"; labels.erBg.Color=state.essence>=essRebirthCost() and Color3.fromRGB(0,160,120) or Color3.fromRGB(30,60,50)
    labels.epStats.Text="Prestige: "..state.essencePrestige.." | Mult: x"..formatNumber(essencePrestigeMult()); labels.epReq.Text="Need: "..essPrestigeCost().." Ess. Rebirths"; labels.epBg.Color=state.essenceRebirths>=essPrestigeCost() and Color3.fromRGB(0,100,200) or Color3.fromRGB(20,40,70)
    labels.voidCount.Text="Void Energy: "..formatNumber(state.voidEnergy); labels.voidPerSec.Text="Void/sec: "..formatNumber(effectiveVoidPerSec())
    local vUpgKeys = {{"voidClick","vu1","vb1"},{"voidFlow","vu2","vb2"},{"cosmicBoost","vu3","vb3"},{"starDrain","vu4","vb4"}}
    for _,vu in ipairs(vUpgKeys) do local upg=state.voidUpgrades[vu[1]]; local cost=getCost(upg); labels[vu[2].."Info"].Text="Lv: "..upg.level; labels[vu[2].."Cost"].Text="Cost: "..formatNumber(cost).." Void"; labels[vu[3].."Bg"].Color=state.voidEnergy>=cost and Color3.fromRGB(130,40,200) or Color3.fromRGB(50,20,70) end
    labels.vrStats.Text="Rebirths: "..state.voidRebirths.." | Mult: x"..formatNumber(voidRebirthMult()); labels.vrReq.Text="Need: "..formatNumber(voidRebirthCost()).." Void"; labels.vrBg.Color=state.voidEnergy>=voidRebirthCost() and Color3.fromRGB(150,40,220) or Color3.fromRGB(50,15,70)
    labels.vpStats.Text="Prestige: "..state.voidPrestige.." | Mult: x"..formatNumber(voidPrestigeMult()); labels.vpReq.Text="Need: "..voidPrestigeCost().." Void Rebirths"; labels.vpBg.Color=state.voidRebirths>=voidPrestigeCost() and Color3.fromRGB(100,30,200) or Color3.fromRGB(30,10,60)
    labels.astralShards.Text="Astral Shards: "..formatNumber(state.astralShards); labels.astralPerSec.Text="Shards/sec: "..formatNumber(effectiveAstralPerSec())
    labels.omegaEnergy.Text="Omega Energy: "..formatNumber(state.omegaEnergy); labels.omegaPerSec.Text="Omega/sec: "..formatNumber(effectiveOmegaPerSec())
    if state.currentTab==7 and state.tier>=3 and astralBuilt then updateTreeColors(astralSkillTree,state.skillNodes,"a_","",state.astralShards) end
    if state.currentTab==8 and state.tier>=4 and omegaBuilt then updateTreeColors(omegaSkillTree,state.omegaNodes,"om_","omega",state.omegaEnergy) end
    if saveFileExists then labels.saveStatus.Text="Status: Save found";labels.saveStatus.Color=Color3.fromRGB(100,220,100) else labels.saveStatus.Text="Status: No save";labels.saveStatus.Color=Color3.fromRGB(180,180,100) end
    local t=T(); for i=1,8 do labels["tab"..i.."Bg"].Color=(i==state.currentTab) and t.tabActive or t.tabInactive; labels["tab"..i.."L"].Color=(i==state.currentTab) and t.tabTextActive or t.tabTextInactive end
    if state.tier>=4 then labels.tab8L.Color=(state.currentTab==8) and Color3.fromRGB(255,180,50) or Color3.fromRGB(200,120,30) end
    if state.currentTab==4 then labels.essLocked.Visible=state.tier<1;labels.essLocked2.Visible=state.tier<1;labels.essLocked3.Visible=state.tier<1; for _,obj in ipairs(essObjs) do obj.Visible=state.tier>=1 end end
    if state.currentTab==6 then labels.voidLocked.Visible=state.tier<2;labels.voidLocked2.Visible=state.tier<2;labels.voidLocked3.Visible=state.tier<2; for _,obj in ipairs(voidObjs) do obj.Visible=state.tier>=2 end end
    if state.currentTab==7 then labels.astralLocked.Visible=state.tier<3;labels.astralLocked2.Visible=state.tier<3;labels.astralLocked3.Visible=state.tier<3 end
    if state.currentTab==8 then labels.omegaLocked.Visible=state.tier<4;labels.omegaLocked2.Visible=state.tier<4;labels.omegaLocked3.Visible=state.tier<4 end
    for i=1,#themes do if labels["themeBg"..i] then labels["themeBg"..i].Color=(i==state.themeIndex) and Color3.fromRGB(80,80,160) or Color3.fromRGB(40,40,60) end end
end

local function doClick() local gained=effectiveClickWithCrit(); state.coins=state.coins+gained; local t=T(); if state.critActive then labels.clickBg.Color=Color3.fromRGB(math.min(255,math.floor(t.accent.R*255*1.5)),math.min(255,math.floor(t.accent.G*255*1.5)),math.min(255,math.floor(t.accent.B*255*0.5)));labels.clickSub.Text="CRIT! +"..formatNumber(gained) else labels.clickBg.Color=Color3.fromRGB(math.min(255,math.floor(t.accent.R*255+40)),math.min(255,math.floor(t.accent.G*255+40)),math.min(255,math.floor(t.accent.B*255+40))) end; clickColorResetPending=true; task.spawn(function() task.wait(0.08); if state.running and clickColorResetPending then labels.clickBg.Color=T().accent;clickColorResetPending=false end end); updateUI() end
local function buyUpgrade(name) if name=="auto" and not state.autoUnlocked then if state.coins<AUTO_UNLOCK_COST then return end; state.coins=state.coins-AUTO_UNLOCK_COST;state.autoUnlocked=true;updateUI();return end; local upg=state.upgrades[name];local cost=getCost(upg);if state.coins<cost then return end; state.coins=state.coins-cost;upg.level=upg.level+1; if name=="click" then state.clickPower=state.clickPower+1 elseif name=="multi" then state.clickMultiplier=math.min(state.clickMultiplier*2,1e300) end; updateUI() end
local function buyMaxUpgrade(name) if state.rebirths<5 then return end; if name=="auto" and not state.autoUnlocked then return end; local upg=state.upgrades[name]; while true do local cost=getCost(upg);if state.coins<cost then break end; state.coins=state.coins-cost;upg.level=upg.level+1; if name=="click" then state.clickPower=state.clickPower+1 elseif name=="multi" then state.clickMultiplier=math.min(state.clickMultiplier*2,1e300) end end; updateUI() end
local function doRebirth() if state.coins<rebirthCost() then return end; state.rebirths=state.rebirths+1;state.rebirthTokens=state.rebirthTokens+1; local sc=state.rebirthUpgrades.startCoins.level*1000; state.coins=sc;state.clickPower=1;state.clickMultiplier=1;state.autoUnlocked=false; state.upgrades.click.level=0;state.upgrades.auto.level=0;state.upgrades.multi.level=0;updateUI() end
local function buyRebirthUpgrade(name) local cost=rebirthUpgCost(name);if state.rebirthTokens<cost then return end; state.rebirthTokens=state.rebirthTokens-cost;state.rebirthUpgrades[name].level=state.rebirthUpgrades[name].level+1;updateUI() end
local function doPrestige() if state.rebirths<prestigeCost() then return end; state.prestige=state.prestige+1;state.coins=0;state.clickPower=1;state.clickMultiplier=1;state.autoUnlocked=false; state.rebirths=0;state.rebirthTokens=0;state.upgrades.click.level=0;state.upgrades.auto.level=0;state.upgrades.multi.level=0; state.rebirthUpgrades.startCoins.level=0;state.rebirthUpgrades.permClick.level=0;updateUI() end

local function fullReset(keepTitle) local savedTitle=state.titleIndex; state.coins=0;state.clickPower=1;state.clickMultiplier=1;state.autoUnlocked=false; state.upgrades.click.level=0;state.upgrades.auto.level=0;state.upgrades.multi.level=0; state.rebirths=0;state.rebirthTokens=0;state.rebirthUpgrades.startCoins.level=0;state.rebirthUpgrades.permClick.level=0; state.prestige=0;state.essence=0;state.essenceRebirths=0;state.essencePrestige=0; state.essenceUpgrades.coinBoost.level=0;state.essenceUpgrades.essSpeed.level=0;state.essenceUpgrades.superClick.level=0; state.voidEnergy=0;state.voidRebirths=0;state.voidPrestige=0; state.voidUpgrades.voidClick.level=0;state.voidUpgrades.voidFlow.level=0;state.voidUpgrades.cosmicBoost.level=0;state.voidUpgrades.starDrain.level=0; state.astralShards=0;state.omegaEnergy=0; for _,n in ipairs(astralSkillTree) do state.skillNodes[n.id]=false end; for _,n in ipairs(omegaSkillTree) do state.omegaNodes[n.id]=false end; if keepTitle then state.titleIndex=savedTitle else state.titleIndex=1 end end
local function doTier() if state.tier>=4 then return end; if not tierRequirementsMet() then return end; state.tier=state.tier+1; fullReset(true); if state.tier==1 then notify("x25 mult! Essence!","TIER 1!",5) elseif state.tier==2 then notify("x150 mult! Void!","TIER 2!",5) elseif state.tier==3 then notify("x10K mult! Astral!","TIER 3!",6) elseif state.tier==4 then notify("x1M mult! OMEGA!","TIER 4 - OMEGA!",7) end; switchTab(1);rebuildAstralTree();rebuildOmegaTree();updateUI() end
local function buyEssUpgrade(name) local upg=state.essenceUpgrades[name];local cost=getCost(upg);if state.essence<cost then return end; state.essence=state.essence-cost;upg.level=upg.level+1;updateUI() end
local function doEssRebirth() if state.essence<essRebirthCost() then return end;state.essenceRebirths=state.essenceRebirths+1;state.essence=0; state.essenceUpgrades.coinBoost.level=0;state.essenceUpgrades.essSpeed.level=0;state.essenceUpgrades.superClick.level=0;updateUI() end
local function doEssPrestige() if state.essenceRebirths<essPrestigeCost() then return end;state.essencePrestige=state.essencePrestige+1;state.essence=0;state.essenceRebirths=0; state.essenceUpgrades.coinBoost.level=0;state.essenceUpgrades.essSpeed.level=0;state.essenceUpgrades.superClick.level=0;updateUI() end
local function buyVoidUpgrade(name) local upg=state.voidUpgrades[name];local cost=getCost(upg);if state.voidEnergy<cost then return end;state.voidEnergy=state.voidEnergy-cost;upg.level=upg.level+1;updateUI() end
local function doVoidRebirth() if state.voidEnergy<voidRebirthCost() then return end;state.voidRebirths=state.voidRebirths+1;state.voidEnergy=0; state.voidUpgrades.voidClick.level=0;state.voidUpgrades.voidFlow.level=0;state.voidUpgrades.cosmicBoost.level=0;state.voidUpgrades.starDrain.level=0;updateUI() end
local function doVoidPrestige() if state.voidRebirths<voidPrestigeCost() then return end;state.voidPrestige=state.voidPrestige+1;state.voidEnergy=0;state.voidRebirths=0; state.voidUpgrades.voidClick.level=0;state.voidUpgrades.voidFlow.level=0;state.voidUpgrades.cosmicBoost.level=0;state.voidUpgrades.starDrain.level=0;updateUI() end

local function doRoulette() if state.rolling then return end; local rollCost=state.tier>=4 and (ROLL_COST*10) or ROLL_COST; if state.coins<rollCost then return end; state.coins=state.coins-rollCost;state.rolling=true;updateUI(); task.spawn(function() local rollCount=state.tier>=4 and 10 or 1; local bestIdx=state.titleIndex; local bestMult=titles[bestIdx].mult; for roll=1,rollCount do local fi=rollTitle(); local spins=(rollCount>1) and (8+math.random(3,6)) or (20+math.random(5,15)); local maxIdx=state.tier>=4 and #titles or (state.tier>=2 and #titles-3 or #titles-4); for i=1,spins do local idx=(i==spins) and fi or math.random(2,maxIdx); local t2=titles[idx]; labels.rollResult.Text=t2.name;labels.rollResult.Color=t2.color; labels.rollResultMult.Text="x"..t2.mult..(rollCount>1 and " (Roll "..roll.."/"..rollCount..")" or ""); labels.rollResultMult.Color=t2.color; task.wait(0.03+(i/spins)*0.15) end; if titles[fi].mult>bestMult then bestIdx=fi;bestMult=titles[fi].mult end; if rollCount>1 then local tt=titles[fi]; labels.rollResult.Text=tt.name;labels.rollResult.Color=tt.color; if titles[fi].mult>titles[state.titleIndex].mult then labels.rollResultMult.Text="NEW BEST: x"..tt.mult else labels.rollResultMult.Text="x"..tt.mult.." (keeping better)" end; if roll<rollCount then task.wait(0.3) end end end; if bestMult>titles[state.titleIndex].mult then state.titleIndex=bestIdx end; local won=titles[state.titleIndex]; labels.rollBoxBg.Color=Color3.fromRGB(25,25,45); labels.rollResult.Text=won.name;labels.rollResult.Color=won.color; labels.rollResultMult.Text="KEEPING: x"..won.mult.."!";labels.rollResultMult.Color=won.color; state.rolling=false;updateUI() end) end

local function resetAll() fullReset(false); state.tier=0; pcall(function() if isfile(SAVE_FILE) then writefile(SAVE_FILE,base64encode(serializeState())) end end); saveFileExists=false; switchTab(1);rebuildAstralTree();rebuildOmegaTree();updateUI() end
local function cleanup() state.running=false; saveGame(); for _,obj in ipairs(allObjects) do pcall(function() obj:Remove() end) end; allObjects,objectData={},{} end

local function clampPan(pX, pY, zoom, treeAreaW, treeAreaH) local cW=treeAreaW*zoom; local cH=treeAreaH*zoom; local minPX=math.min(0,treeAreaW-cW); local minPY=math.min(0,treeAreaH-cH); return math.clamp(pX,minPX,0), math.clamp(pY,minPY,0) end

local mouse = game:GetService("Players").LocalPlayer:GetMouse()

task.spawn(function()
    local last = false
    while state.running do
        if isrbxactive() then
            local pressed = ismouse1pressed()
            local mx,my = mouse.X, mouse.Y
            local tax,tay,taw,tah = getTreeArea()
            local inAstralTree = state.currentTab==7 and state.tier>=3 and not state.minimized and mx>=tax and mx<=tax+taw and my>=tay and my<=tay+tah
            local inOmegaTree = state.currentTab==8 and state.tier>=4 and not state.minimized and mx>=tax and mx<=tax+taw and my>=tay and my<=tay+tah

            if pressed and not last and not dragging and not resizingC then
                if hit(mx,my,btn.close) then cleanup(); return end
                if hit(mx,my,btn.minimize) then toggleMinimize(); updateUI()
                elseif not state.minimized and hitXY(mx,my,px+pw-RESIZE_HANDLE,py+ph-RESIZE_HANDLE,RESIZE_HANDLE,RESIZE_HANDLE) then resizingC=true; dragOffX=mx; dragOffY=my
                elseif hitXY(mx,my,px,py,pw,42) then dragging=true; dragOffX=mx-px; dragOffY=my-py
                elseif inAstralTree then
                    local clickedNode = false
                    for _,node in ipairs(astralSkillTree) do
                        local bk="a_node_"..node.id
                        if btn[bk] and hit(mx,my,btn[bk]) then
                            if not state.skillNodes[node.id] then
                                labels.nodeInfo.Text=node.name.." - "..node.effect
                                labels.nodeEffect.Text="Cost: "..(node.cost>0 and formatNumber(node.cost).." shards" or "FREE")
                                buyAstralNode(node.id)
                            else labels.nodeInfo.Text=node.name.." - OWNED"; labels.nodeEffect.Text=node.effect end
                            clickedNode = true; break
                        end
                    end
                    if not clickedNode then treeDragging=true; activeTreeTab=7; treeDragLastX=mx; treeDragLastY=my end
                elseif inOmegaTree then
                    local clickedNode = false
                    for _,node in ipairs(omegaSkillTree) do
                        local bk="om_node_"..node.id
                        if btn[bk] and hit(mx,my,btn[bk]) then
                            if not state.omegaNodes[node.id] then
                                labels.omegaNodeInfo.Text=node.name.." - "..node.effect
                                labels.omegaNodeEffect.Text="Cost: "..(node.cost>0 and formatNumber(node.cost).." omega" or "FREE")
                                buyOmegaNode(node.id)
                            else labels.omegaNodeInfo.Text=node.name.." - OWNED"; labels.omegaNodeEffect.Text=node.effect end
                            clickedNode = true; break
                        end
                    end
                    if not clickedNode then treeDragging=true; activeTreeTab=8; treeDragLastX=mx; treeDragLastY=my end
                elseif not state.minimized then
                    for i=1,8 do if hit(mx,my,btn["tab"..i]) then switchTab(i); if i==7 and not astralBuilt then rebuildAstralTree() end; if i==8 and not omegaBuilt then rebuildOmegaTree() end; updateUI(); break end end
                    if state.currentTab==1 then
                        if hit(mx,my,btn.click) then doClick() elseif hit(mx,my,btn.buy1) then buyUpgrade("click") elseif hit(mx,my,btn.max1) then buyMaxUpgrade("click") elseif hit(mx,my,btn.buy2) then buyUpgrade("auto") elseif hit(mx,my,btn.max2) then buyMaxUpgrade("auto") elseif hit(mx,my,btn.buy3) then buyUpgrade("multi") elseif hit(mx,my,btn.max3) then buyMaxUpgrade("multi") end
                    elseif state.currentTab==2 then
                        if hit(mx,my,btn.rebirth) then doRebirth() elseif hit(mx,my,btn.rbuy1) then buyRebirthUpgrade("startCoins") elseif hit(mx,my,btn.rbuy2) then buyRebirthUpgrade("permClick") elseif hit(mx,my,btn.prestige) then doPrestige() elseif hit(mx,my,btn.tier) then doTier() end
                    elseif state.currentTab==3 then if hit(mx,my,btn.roll) then doRoulette() end
                    elseif state.currentTab==4 and state.tier>=1 then
                        if hit(mx,my,btn.ebuy1) then buyEssUpgrade("coinBoost") elseif hit(mx,my,btn.ebuy2) then buyEssUpgrade("essSpeed") elseif hit(mx,my,btn.ebuy3) then buyEssUpgrade("superClick") elseif hit(mx,my,btn.ereb) then doEssRebirth() elseif hit(mx,my,btn.epres) then doEssPrestige() end
                    elseif state.currentTab==5 then
                        if hit(mx,my,btn.save) then saveGame() elseif hit(mx,my,btn.load) then loadGame();applyTheme();updateUI() elseif hit(mx,my,btn.reset) then resetAll() elseif hit(mx,my,btn.export) then setclipboard(base64encode(serializeState())) end
                        for i=1,#themes do if btn["theme"..i] and hit(mx,my,btn["theme"..i]) then state.themeIndex=i;applyTheme();updateUI();break end end
                    elseif state.currentTab==6 and state.tier>=2 then
                        if hit(mx,my,btn.vbuy1) then buyVoidUpgrade("voidClick") elseif hit(mx,my,btn.vbuy2) then buyVoidUpgrade("voidFlow") elseif hit(mx,my,btn.vbuy3) then buyVoidUpgrade("cosmicBoost") elseif hit(mx,my,btn.vbuy4) then buyVoidUpgrade("starDrain") elseif hit(mx,my,btn.vreb) then doVoidRebirth() elseif hit(mx,my,btn.vpres) then doVoidPrestige() end
                    end
                end
            end

            if pressed then
                if dragging then px=mx-dragOffX;py=my-dragOffY;repositionAll()
                elseif resizingC then local dw=mx-dragOffX;local dh=my-dragOffY;dragOffX=mx;dragOffY=my;resizeUI(pw+dw,ph+dh)
                elseif treeDragging then
                    local dx=mx-treeDragLastX;local dy=my-treeDragLastY;treeDragLastX=mx;treeDragLastY=my
                    local _,_,tw,th = getTreeArea()
                    if activeTreeTab==7 then
                        astralPanX=astralPanX+dx;astralPanY=astralPanY+dy
                        astralPanX,astralPanY=clampPan(astralPanX,astralPanY,astralZoom,tw,th)
                        panAstralTree()
                    elseif activeTreeTab==8 then
                        omegaPanX=omegaPanX+dx;omegaPanY=omegaPanY+dy
                        omegaPanX,omegaPanY=clampPan(omegaPanX,omegaPanY,omegaZoom,tw,th)
                        panOmegaTree()
                    end
                end
            else dragging=false;resizingC=false;treeDragging=false end
            last=pressed
        end
        task.wait(0.016)
    end
end)

task.spawn(function()
    while state.running do
        if isrbxactive() and not state.minimized then
            local tax,tay,taw,tah = getTreeArea()
            local mx,my = mouse.X, mouse.Y
            local inTree = mx>=tax and mx<=tax+taw and my>=tay and my<=tay+tah
            local plusPressed = iskeypressed(0x6B) or iskeypressed(0xBB)
            local minusPressed = iskeypressed(0x6D) or iskeypressed(0xBD)
            if inTree and state.currentTab==7 and state.tier>=3 then
                if plusPressed and not zoomPlusWasPressed then local old=astralZoom; astralZoom=math.min(MAX_ZOOM,astralZoom+ZOOM_STEP); if astralZoom~=old then astralPanX,astralPanY=clampPan(astralPanX,astralPanY,astralZoom,taw,tah); rebuildAstralTree() end end
                if minusPressed and not zoomMinusWasPressed then local old=astralZoom; astralZoom=math.max(MIN_ZOOM,astralZoom-ZOOM_STEP); if astralZoom~=old then astralPanX,astralPanY=clampPan(astralPanX,astralPanY,astralZoom,taw,tah); rebuildAstralTree() end end
            elseif inTree and state.currentTab==8 and state.tier>=4 then
                if plusPressed and not zoomPlusWasPressed then local old=omegaZoom; omegaZoom=math.min(MAX_ZOOM,omegaZoom+ZOOM_STEP); if omegaZoom~=old then omegaPanX,omegaPanY=clampPan(omegaPanX,omegaPanY,omegaZoom,taw,tah); rebuildOmegaTree() end end
                if minusPressed and not zoomMinusWasPressed then local old=omegaZoom; omegaZoom=math.max(MIN_ZOOM,omegaZoom-ZOOM_STEP); if omegaZoom~=old then omegaPanX,omegaPanY=clampPan(omegaPanX,omegaPanY,omegaZoom,taw,tah); rebuildOmegaTree() end end
            end
            zoomPlusWasPressed=plusPressed; zoomMinusWasPressed=minusPressed
        end
        task.wait(0.05)
    end
end)

task.spawn(function() while state.running do if state.autoUnlocked then state.coins=state.coins+effectiveAutoClick();updateUI();task.wait(autoInterval()) else task.wait(0.5) end end end)
task.spawn(function() while state.running do local u=false; if state.tier>=1 then state.essence=state.essence+effectiveEssPerSec();u=true end; if state.tier>=2 then state.voidEnergy=state.voidEnergy+effectiveVoidPerSec();u=true end; if state.tier>=3 then state.astralShards=state.astralShards+effectiveAstralPerSec();u=true end; if state.tier>=4 then state.omegaEnergy=state.omegaEnergy+effectiveOmegaPerSec();u=true end; if u then updateUI() end; task.wait(1) end end)
task.spawn(function() local pt=0; while state.running do if not state.minimized then pt=pt+0.05; local pulse=0.2+math.abs(math.sin(pt))*0.2; if state.currentTab==7 and state.tier>=3 then for _,node in ipairs(astralSkillTree) do if state.skillNodes[node.id] and labels["a_nodeGlow_"..node.id] then labels["a_nodeGlow_"..node.id].Transparency=pulse end end end; if state.currentTab==8 and state.tier>=4 then local op=0.25+math.abs(math.sin(pt*1.3))*0.25; for _,node in ipairs(omegaSkillTree) do if state.omegaNodes[node.id] and labels["om_nodeGlow_"..node.id] then labels["om_nodeGlow_"..node.id].Transparency=op end end end end; task.wait(0.05) end end)
task.spawn(function() while state.running do task.wait(60); if state.running then saveGame() end end end)

updateSaveStatus(); loadGame(); applyTheme(); rebuildAstralTree(); rebuildOmegaTree(); switchTab(1); updateUI()
notify("Loaded","Incremental Game v5",4)
