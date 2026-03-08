--[[
╔══════════════════════════════════════════════════════════╗
║     🍫 CHOCOLATE ENGINEERING - ALL IN ONE FILE          ║
║     Version: 2.0.1 - No Folder Structure                ║
║     Author: Chocolate Engineer                          ║
╚══════════════════════════════════════════════════════════╝
--]]

-- ==================================================
-- LOAD MODULES DENGAN LOADSTRING (bukan require)
-- ==================================================

-- Pertama, kita perlu base URL GitHub kamu
-- GANTI 'USERNAME' dan 'REPO' dengan punya kamu ya!
local BASE_URL = "https://raw.githubusercontent.com/USERNAME/REPO/main/"

-- Load Utils
local Utils = loadstring(game:HttpGet(BASE_URL .. "utils.lua"))()

-- Load AutoFarm
local AutoFarm = loadstring(game:HttpGet(BASE_URL .. "auto_farm.lua"))()

-- Load GachaExploit
local GachaExploit = loadstring(game:HttpGet(BASE_URL .. "gacha_exploit.lua"))()

-- Load Config (opsional)
local Config = loadstring(game:HttpGet(BASE_URL .. "config.lua"))()

-- ==================================================
-- GABUNGKAN DENGAN CONFIG DARI USER
-- ==================================================
if Config then
    -- Terapkan config ke module
    if Config.AutoFarm then
        for k, v in pairs(Config.AutoFarm) do
            AutoFarm.Settings[k] = v
        end
    end
    
    if Config.Gacha then
        for k, v in pairs(Config.Gacha) do
            GachaExploit.Settings[k] = v
        end
    end
end

-- ==================================================
-- GUI SETUP - TEMA COKLAT
-- ==================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Chocolate Engineering v2.0", "DarkTheme")

-- ==================================================
-- TAB AUTO FARM
-- ==================================================
local FarmTab = Window:NewTab("⚡ Auto Farm")
local FarmSection = FarmTab:NewSection("Control Panel")

FarmSection:NewToggle("Enable Auto Farm", "Otomatis farming level", function(state)
    if state then
        AutoFarm:Start()
    else
        AutoFarm:Stop()
    end
end)

FarmSection:NewToggle("Auto Equip Weapon", "Equip weapon terbaik", function(state)
    AutoFarm.Settings.AutoEquip = state
end)

FarmSection:NewSlider("Farm Speed", "Kecepatan farming", 200, 50, function(value)
    AutoFarm.Settings.AttackSpeed = value / 1000
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

FarmSection:NewDropdown("Farm Mode", "Pilih mode farming", {"Level", "Boss", "Quest"}, function(option)
    AutoFarm.Settings.Mode = option
end)

FarmSection:NewButton("Go to Best Spot", "Teleport ke area farming", function()
    AutoFarm:GoToFarmingSpot()
end)

-- ==================================================
-- TAB GACHA EXPLOIT
-- ==================================================
local GachaTab = Window:NewTab("🎲 Gacha Exploit")
local GachaSection = GachaTab:NewSection("No Cooldown System")

-- Daftar fruit
local fruitList = {
    "Random", "Bomb", "Spike", "Chop", "Spring", "Kilo", "Spin", "Blade", 
    "Smoke", "Flame", "Ice", "Sand", "Dark", "Light", "Magma", "Quake", 
    "Rumble", "Door", "Diamond", "Venom", "Shadow", "Dough", "Buddha", 
    "Love", "Spider", "Sound", "Pain", "Gravity", "Mammoth", "Control", 
    "Leopard", "Dragon"
}

GachaSection:NewDropdown("Target Fruit", "Pilih fruit incaran", fruitList, function(option)
    GachaExploit.Settings.TargetFruit = option
end)

GachaSection:NewToggle("Enable Gacha Exploit", "Aktifkan bypass cooldown", function(state)
    GachaExploit.Settings.Enabled = state
    if state then
        Utils:Notify("🎲 Gacha", "Exploit activated! No cooldown!", 3, "success")
    end
end)

GachaSection:NewButton("Gacha Sekali", "Roll fruit 1x (no cooldown)", function()
    GachaExploit:RollFruit()
end)

GachaSection:NewButton("Auto Gacha (Loop)", "Gacha terus menerus", function()
    GachaExploit:StartAutoGacha()
end)

GachaSection:NewButton("Stop Auto Gacha", "Hentikan auto gacha", function()
    GachaExploit:StopAutoGacha()
end)

GachaSection:NewButton("Show Stats", "Lihat statistik gacha", function()
    GachaExploit:PrintStats()
    Utils:Notify("📊 Stats", "Cek console untuk detail", 3, "info")
end)

-- ==================================================
-- TAB INFO & STATS
-- ==================================================
local InfoTab = Window:NewTab("ℹ️ Info")
local InfoSection = InfoTab:NewSection("About")

InfoSection:NewLabel("🍫 Chocolate Engineering v2.0.1")
InfoSection:NewLabel("✅ Auto Farm - Leveling otomatis")
InfoSection:NewLabel("✅ Gacha Exploit - No cooldown 2 jam")
InfoSection:NewLabel("✅ Auto Equip & Auto Collect")
InfoSection:NewLabel("✅ Anti AFK System")
InfoSection:NewLabel("")
InfoSection:NewLabel("📌 Status: 100% WORKING")
InfoSection:NewLabel("")

-- Live stats
InfoSection:NewLabel("⚡ Live Stats:")
local levelLabel = InfoSection:NewLabel("Level: " .. Utils:GetPlayerLevel())
local gachaLabel = InfoSection:NewLabel("Gacha Count: 0")

-- Update stats setiap detik
spawn(function()
    while true do
        task.wait(1)
        levelLabel:Update("Level: " .. Utils:GetPlayerLevel())
        gachaLabel:Update("Gacha Count: " .. GachaExploit.Stats.TotalGacha)
    end
end)

InfoSection:NewButton("Destroy GUI", "Hapus interface", function()
    Library:Destroy()
end)

-- ==================================================
-- INITIALIZATION
-- ==================================================
Utils:Notify("🍫 Chocolate Engineering", "Script loaded successfully!", 3, "chocolate")
print("✅ Chocolate Engineering v2.0.1 loaded!")
print("📌 Fitur: Auto Farm + Gacha No Cooldown")
print("🔗 GitHub: https://github.com/USERNAME/REPO")
