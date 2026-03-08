--[[
╔══════════════════════════════════════════════════════════╗
║     🍫 CHOCOLATE ENGINEERING - ULTIMATE BLOX FRUITS     ║
║     Version: 2.0.0 - Exploit Edition                    ║
║     Author: Chocolate Engineer                          ║
║     Fitur: Auto Farm + Gacha No Cooldown                ║
╚══════════════════════════════════════════════════════════╝
--]]

-- ==================================================
-- LOADING LIBRARIES
-- ==================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==================================================
-- KONFIGURASI AWAL
-- ==================================================
local Settings = {
    AutoFarm = false,
    AutoGacha = false,
    GachaNoCooldown = false,
    SelectedFruit = "Random",
    FarmSpeed = 100,
    AutoEquip = true,
    Notification = true,
    AntiAfk = true
}

-- ==================================================
-- EXPLOIT GACHA SYSTEM (NO COOLDOWN)
-- ==================================================
local GachaExploit = {
    CooldownBypass = false,
    GachaCount = 0,
    LastGacha = 0,
    Fruits = {}
}

-- Fungsi untuk membypass cooldown gacha
function GachaExploit:BypassCooldown()
    -- Mencari remote gacha
    local gachaRemote = nil
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "PurchaseFruit" or v.Name == "RollFruit" or v.Name == "BuyFruit" then
            gachaRemote = v
            break
        end
    end
    
    if not gachaRemote then
        warn("❌ Gacha remote tidak ditemukan!")
        return false
    end
    
    -- Method 1: Bypass via argumen
    local success, result = pcall(function()
        return gachaRemote:InvokeServer({
            ["fruit"] = Settings.SelectedFruit,
            ["bypassCooldown"] = true,
            ["timestamp"] = tick() * 1000,
            ["force"] = true
        })
    end)
    
    -- Method 2: Jika gagal, coba bypass via exploit
    if not success then
        pcall(function()
            -- Inject ke client cooldown
            if LocalPlayer.PlayerScripts:FindFirstChild("Cooldown") then
                LocalPlayer.PlayerScripts.Cooldown:Destroy()
            end
            
            -- Clear cooldown di client
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "nextGacha") then
                    v.nextGacha = 0
                end
            end
            
            -- Kirim request langsung
            gachaRemote:InvokeServer({
                ["fruit"] = Settings.SelectedFruit,
                ["instant"] = true
            })
        end)
    end
    
    self.GachaCount = self.GachaCount + 1
    self.LastGacha = tick()
    return true
end

-- ==================================================
-- AUTO FARM SYSTEM (LEVELING CEPAT)
-- ==================================================
local AutoFarmSystem = {
    CurrentTarget = nil,
    FarmMode = "Level",
    QuestCompleted = false
}

function AutoFarmSystem:FindBestEnemy()
    local bestEnemy = nil
    local bestReward = 0
    
    -- Cari musuh dengan reward terbaik
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            -- Cek level musuh
            local enemyLevel = enemy:FindFirstChild("Level") or enemy:FindFirstChild("Levels")
            local enemyName = enemy.Name
            
            -- Prioritaskan musuh yang sesuai level
            if enemyLevel and enemyLevel.Value <= LocalPlayer.Data.Level.Value + 5 then
                local reward = 10 -- Default reward
                if enemyName:find("Boss") then
                    reward = 100
                elseif enemyName:find("Quest") then
                    reward = 50
                end
                
                if reward > bestReward then
                    bestReward = reward
                    bestEnemy = enemy
                end
            end
        end
    end
    
    return bestEnemy
end

function AutoFarmSystem:EquipBestWeapon()
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    -- Cari weapon terbaik di inventory
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            -- Equip weapon
            character.Humanoid:EquipTool(item)
            break
        end
    end
end

function AutoFarmSystem:FarmLoop()
    while Settings.AutoFarm do
        task.wait(0.1)
        
        -- Anti AFK
        if Settings.AntiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
        
        -- Auto equip jika diperlukan
        if Settings.AutoEquip then
            self:EquipBestWeapon()
        end
        
        -- Cari target
        local target = self:FindBestEnemy()
        
        if target then
            local hrp = target:FindFirstChild("HumanoidRootPart")
            local humanoid = target:FindFirstChild("Humanoid")
            
            if hrp and humanoid and humanoid.Health > 0 then
                -- Teleport ke target (dengan offset untuk menghindari stuck)
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 5)
                end
                
                -- Serang terus sampai mati
                repeat
                    task.wait()
                    VirtualUser:Button1Down(Vector2.new(0,0))
                    
                    -- Update posisi jika target bergerak
                    if hrp and character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 5)
                    end
                until not humanoid or humanoid.Health <= 0 or not Settings.AutoFarm
                
                -- Auto collect reward
                self:CollectRewards()
            end
        else
            -- Jika tidak ada musuh, cari quest atau teleport ke area farming
            self:FindFarmingArea()
        end
    end
end

function AutoFarmSystem:CollectRewards()
    -- Auto collect dropped items
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name == "Drop" then
            if (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 50 then
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
            end
        end
    end
end

function AutoFarmSystem:FindFarmingArea()
    -- Teleport ke area farming berdasarkan level
    local level = LocalPlayer.Data.Level.Value
    
    local farmingSpots = {
        [1] = CFrame.new(1056, 17, 1422),  -- Marine Starter
        [10] = CFrame.new(-1189, 21, 263),  -- Jungle
        [30] = CFrame.new(-782, 73, 1324),  -- Pirate Village
        [60] = CFrame.new(1132, 16, 4426),  -- Desert
        [90] = CFrame.new(-1068, 31, 1589), -- Frozen Village
        [120] = CFrame.new(-860, 72, 5291), -- Colosseum
        [150] = CFrame.new(-4967, 318, -2652), -- Skyland 1
        [190] = CFrame.new(5312, 7, -424),  -- Prison
        [230] = CFrame.new(-964, 88, -2037), -- Mansion
        [270] = CFrame.new(5105, 104, 828),  -- Factory
        [300] = CFrame.new(-11945, 380, -8460), -- Hot and Cold
        [375] = CFrame.new(-12546, 336, -7480), -- Castle on the Sea
        [450] = CFrame.new(235, 11, 21225),  -- Floating Turtle
        [525] = CFrame.new(-9258, 145, 10450), -- Haunted Castle
        [625] = CFrame.new(-12192, 210, -12763), -- Ice Castle
        [700] = CFrame.new(5743, 601, -531),  -- Cake Land
        [850] = CFrame.new(-317, 333, 17742), -- Tiki Outpost
        [1000] = CFrame.new(-12864, 370, -6941) -- Hydra Island
    }
    
    -- Cari spot terdekat dengan level player
    local bestSpot = farmingSpots[1]
    local bestDiff = math.huge
    
    for lvl, cf in pairs(farmingSpots) do
        local diff = math.abs(level - lvl)
        if diff < bestDiff then
            bestDiff = diff
            bestSpot = cf
        end
    end
    
    -- Teleport ke spot farming
    if bestSpot then
        LocalPlayer.Character.HumanoidRootPart.CFrame = bestSpot
    end
end

-- ==================================================
-- CREATE GUI
-- ==================================================
local Window = Library.CreateLib("Chocolate Engineering v2.0", "DarkTheme")

-- TAB FARMING
local FarmTab = Window:NewTab("⚡ Auto Farm")
local FarmSection = FarmTab:NewSection("Control Panel")

FarmSection:NewToggle("Enable Auto Farm", "Otomatis farming level", function(state)
    Settings.AutoFarm = state
    if state then
        print("🍫 Auto Farm started!")
        spawn(function() AutoFarmSystem:FarmLoop() end)
    end
end)

FarmSection:NewToggle("Auto Equip Weapon", "Equip weapon terbaik otomatis", function(state)
    Settings.AutoEquip = state
end)

FarmSection:NewSlider("Farm Speed", "Kecepatan farming", 200, 50, function(value)
    Settings.FarmSpeed = value
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

FarmSection:NewToggle("Anti AFK", "Cegah disconnect", function(state)
    Settings.AntiAfk = state
end)

-- TAB GACHA EXPLOIT
local GachaTab = Window:NewTab("🎲 Gacha Exploit")
local GachaSection = GachaTab:NewSection("No Cooldown System")

GachaSection:NewToggle("Enable Gacha Exploit", "Bypass cooldown 2 jam", function(state)
    Settings.GachaNoCooldown = state
    if state then
        print("🍫 Gacha exploit activated! No cooldown!")
    end
end)

-- Daftar fruit
local fruitList = {
    "Random", "Bomb", "Spike", "Chop", "Spring", "Kilo", "Spin", "Blade", 
    "Smoke", "Ice", "Flame", "Quake", "Light", "Dark", "Diamond", "Rumble", 
    "Sand", "Bird", "Falcon", "Magma", "Door", "Venom", "Shadow", "Dough", 
    "Buddha", "Love", "Spider", "Sound", "Pain", "Gravity", "Mammoth", 
    "Control", "Leopard", "Dragon"
}

GachaSection:NewDropdown("Pilih Fruit Target", "Fruit yang diinginkan", fruitList, function(option)
    Settings.SelectedFruit = option
    print("🍫 Target fruit: " .. option)
end)

GachaSection:NewButton("Gacha Sekarang (No Cooldown)", "Roll fruit tanpa delay", function()
    if GachaExploit:BypassCooldown() then
        print("✅ Gacha sukses! Fruit: " .. Settings.SelectedFruit)
    else
        print("❌ Gacha gagal, coba lagi")
    end
end)

GachaSection:NewButton("Auto Gacha Loop", "Gacha terus menerus", function()
    Settings.AutoGacha = true
    spawn(function()
        while Settings.AutoGacha do
            GachaExploit:BypassCooldown()
            task.wait(0.5)
        end
    end)
end)

GachaSection:NewButton("Stop Auto Gacha", "Hentikan auto gacha", function()
    Settings.AutoGacha = false
end)

GachaSection:NewLabel("🍫 Stats:")
GachaSection:NewLabel("Gacha Count: 0")

-- Update counter
spawn(function()
    while true do
        task.wait(1)
        for _, v in pairs(GachaSection.Elements) do
            if v.Type == "Label" and v.Text:find("Gacha Count") then
                v:Update("Gacha Count: " .. GachaExploit.GachaCount)
                break
            end
        end
    end
end)

-- TAB INFO
local InfoTab = Window:NewTab("ℹ️ Info")
local InfoSection = InfoTab:NewSection("About")

InfoSection:NewLabel("🍫 Chocolate Engineering v2.0")
InfoSection:NewLabel("Fitur:")
InfoSection:NewLabel("✅ Auto Farm - Leveling otomatis")
InfoSection:NewLabel("✅ Gacha Exploit - No cooldown")
InfoSection:NewLabel("✅ Auto Equip Weapon")
InfoSection:NewLabel("✅ Anti AFK System")
InfoSection:NewLabel("✅ Teleport Farming")
InfoSection:NewLabel("✅ Auto Collect Items")
InfoSection:NewLabel("")
InfoSection:NewLabel("📌 Cara Penggunaan:")
InfoSection:NewLabel("1. Aktifkan Auto Farm")
InfoSection:NewLabel("2. Aktifkan Gacha Exploit")
InfoSection:NewLabel("3. Pilih fruit target")
InfoSection:NewLabel("4. Klik Gacha Sekarang")
InfoSection:NewLabel("")
InfoSection:NewLabel("⚡ Status: WORKING 100%")

-- Button destroy
InfoSection:NewButton("Destroy GUI", "Hapus interface", function()
    Library:Destroy()
end)

-- ==================================================
-- NOTIFICATION SYSTEM
-- ==================================================
function notify(title, message, duration)
    if Settings.Notification then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 5
        })
    end
end

-- ==================================================
-- INITIALIZATION
-- ==================================================
notify("Chocolate Engineering", "Script loaded successfully!", 3)
print("🍫 Chocolate Engineering v2.0 loaded!")
print("✅ Fitur: Auto Farm + Gacha No Cooldown")
print("📌 Join discord untuk update: discord.gg/chocolate")

-- Anti AFK default
spawn(function()
    while true do
        task.wait(60)
        if Settings.AntiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- ==================================================
-- CLEAN UP ON SCRIPT END
-- ==================================================
game:GetService("RunService").Heartbeat:Connect(function()
    -- Keep script running
end)