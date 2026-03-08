--[[
╔══════════════════════════════════════════════════════════╗
║     🍫 CHOCOLATE ENGINEERING - AUTO FARM MODULE         ║
║     Version: 2.0.0 - Core Farming System                ║
║     Author: Chocolate Engineer                          ║
╚══════════════════════════════════════════════════════════╝
--]]

local AutoFarm = {}
local Utils = require(script.Parent.utils)

-- ==================================================
-- KONFIGURASI
-- ==================================================
AutoFarm.Settings = {
    Enabled = false,
    Mode = "Level",          -- Level, Boss, Quest, Material
    TargetLevel = 2550,      -- Target level maksimal
    AutoEquip = true,
    AutoCollect = true,
    AutoQuest = true,
    AutoBuy = true,
    FarmRadius = 500,
    AttackSpeed = 0.1,
    SafeMode = true,
    AntiAfk = true
}

AutoFarm.Stats = {
    LevelStart = Utils:GetPlayerLevel(),
    LevelCurrent = Utils:GetPlayerLevel(),
    EnemiesKilled = 0,
    FarmingTime = 0,
    LastUpdate = tick()
}

-- ==================================================
-- FARMING SPOTS DATABASE
-- ==================================================
AutoFarm.Spots = {
    [1] = { -- Sea 1 (Level 1-700)
        {Name = "Marine Starter", Level = 1, CFrame = CFrame.new(1056, 17, 1422)},
        {Name = "Jungle", Level = 10, CFrame = CFrame.new(-1189, 21, 263)},
        {Name = "Pirate Village", Level = 30, CFrame = CFrame.new(-782, 73, 1324)},
        {Name = "Desert", Level = 60, CFrame = CFrame.new(1132, 16, 4426)},
        {Name = "Frozen Village", Level = 90, CFrame = CFrame.new(-1068, 31, 1589)},
        {Name = "Colosseum", Level = 120, CFrame = CFrame.new(-860, 72, 5291)},
        {Name = "Skyland 1", Level = 150, CFrame = CFrame.new(-4967, 318, -2652)},
        {Name = "Skyland 2", Level = 190, CFrame = CFrame.new(5312, 7, -424)},
        {Name = "Prison", Level = 230, CFrame = CFrame.new(-964, 88, -2037)},
        {Name = "Mansion", Level = 270, CFrame = CFrame.new(5105, 104, 828)},
        {Name = "Factory", Level = 300, CFrame = CFrame.new(-11945, 380, -8460)},
    },
    
    [2] = { -- Sea 2 (Level 700-1500)
        {Name = "Hot and Cold", Level = 375, CFrame = CFrame.new(-12546, 336, -7480)},
        {Name = "Castle on the Sea", Level = 450, CFrame = CFrame.new(235, 11, 21225)},
        {Name = "Floating Turtle", Level = 525, CFrame = CFrame.new(-9258, 145, 10450)},
        {Name = "Haunted Castle", Level = 600, CFrame = CFrame.new(-12192, 210, -12763)},
        {Name = "Ice Castle", Level = 675, CFrame = CFrame.new(5743, 601, -531)},
    },
    
    [3] = { -- Sea 3 (Level 1500+)
        {Name = "Cake Land", Level = 700, CFrame = CFrame.new(-317, 333, 17742)},
        {Name = "Tiki Outpost", Level = 825, CFrame = CFrame.new(1520, 148, 100)},
        {Name = "Hydra Island", Level = 950, CFrame = CFrame.new(-12864, 370, -6941)},
        {Name = "Great Tree", Level = 1075, CFrame = CFrame.new(2682, 168, -7250)},
        {Name = "Floating Island", Level = 1200, CFrame = CFrame.new(-1120, 230, 3950)},
    }
}

-- ==================================================
-- CORE FARMING FUNCTIONS
-- ==================================================
function AutoFarm:GetBestFarmingSpot()
    local level = Utils:GetPlayerLevel()
    local bestSpot = nil
    local bestDiff = math.huge
    
    -- Tentukan sea berdasarkan level
    local sea = 1
    if level > 700 then sea = 2 end
    if level > 1500 then sea = 3 end
    
    -- Cari spot dengan level terdekat
    for _, spot in pairs(self.Spots[sea]) do
        local diff = math.abs(level - spot.Level)
        if diff < bestDiff and spot.Level <= level + 50 then
            bestDiff = diff
            bestSpot = spot
        end
    end
    
    return bestSpot
end

function AutoFarm:GoToFarmingSpot()
    local spot = self:GetBestFarmingSpot()
    if spot then
        Utils:SmoothTeleport(spot.CFrame, 1)
        Utils:Notify("🍫 AutoFarm", "Moving to: " .. spot.Name, 3, "info")
        return true
    end
    return false
end

function AutoFarm:FindTarget()
    local enemies = Utils:FindAllEnemiesInRadius(self.Settings.FarmRadius)
    local bestTarget = nil
    local bestScore = 0
    
    for _, enemy in pairs(enemies) do
        local humanoid = enemy:FindFirstChild("Humanoid")
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        
        if humanoid and hrp and humanoid.Health > 0 then
            local score = 100
            
            -- Prioritaskan quest target
            if self.Settings.AutoQuest and Utils:HasQuest() then
                local questTarget = Utils:GetQuestTarget()
                if questTarget and enemy.Name:find(questTarget) then
                    score = score + 1000
                end
            end
            
            -- Prioritaskan boss
            if enemy.Name:find("Boss") then
                score = score + 500
            end
            
            -- Semakin dekat semakin tinggi score
            local distance = Utils:GetDistanceTo(hrp.Position)
            score = score + (500 - distance)
            
            if score > bestScore then
                bestScore = score
                bestTarget = enemy
            end
        end
    end
    
    return bestTarget
end

function AutoFarm:AttackTarget(target)
    if not target then return false end
    
    local humanoid = target:FindFirstChild("Humanoid")
    local hrp = target:FindFirstChild("HumanoidRootPart")
    
    if humanoid and hrp and humanoid.Health > 0 then
        -- Teleport ke target
        local root = Utils:GetRootPart()
        if root then
            root.CFrame = hrp.CFrame * CFrame.new(0, 0, 5)
        end
        
        -- Auto equip weapon
        if self.Settings.AutoEquip then
            Utils:EquipTool()
        end
        
        -- Serang sampai mati
        local attackStart = tick()
        while humanoid and humanoid.Health > 0 and self.Settings.Enabled do
            Utils:Attack()
            task.wait(self.Settings.AttackSpeed)
            
            -- Update posisi jika target bergerak
            if hrp and root then
                root.CFrame = hrp.CFrame * CFrame.new(0, 0, 5)
            end
            
            -- Anti stuck
            if tick() - attackStart > 30 then
                break
            end
        end
        
        self.Stats.EnemiesKilled = self.Stats.EnemiesKilled + 1
        return true
    end
    
    return false
end

-- ==================================================
-- AUTO FARM LOOP
-- ==================================================
function AutoFarm:Start()
    self.Settings.Enabled = true
    self.Stats.LevelStart = Utils:GetPlayerLevel()
    self.Stats.FarmingTime = tick()
    
    Utils:Notify("🍫 AutoFarm", "Auto Farm Started!", 3, "success")
    
    -- Farming loop
    spawn(function()
        while self.Settings.Enabled do
            task.wait()
            
            -- Anti AFK
            if self.Settings.AntiAfk then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
            
            -- Update stats
            self.Stats.LevelCurrent = Utils:GetPlayerLevel()
            
            -- Cek apakah perlu pindah spot
            if self.Settings.Mode == "Level" then
                local currentSpot = self:GetBestFarmingSpot()
                if currentSpot then
                    local distance = Utils:GetDistanceTo(currentSpot.CFrame.Position)
                    if distance > 1000 then
                        self:GoToFarmingSpot()
                    end
                end
            end
            
            -- Cari dan serang target
            local target = self:FindTarget()
            if target then
                self:AttackTarget(target)
            else
                -- Jika tidak ada target, cari quest atau pindah spot
                task.wait(2)
                self:GoToFarmingSpot()
            end
            
            -- Auto collect item
            if self.Settings.AutoCollect then
                Utils:CollectAllItems(self.Settings.FarmRadius)
            end
            
            -- Auto buy jika perlu
            if self.Settings.AutoBuy then
                self:AutoBuyItems()
            end
        end
    end)
end

function AutoFarm:Stop()
    self.Settings.Enabled = false
    Utils:Notify("🍫 AutoFarm", "Auto Farm Stopped", 3, "warning")
end

-- ==================================================
-- AUTO BUY
-- ==================================================
function AutoFarm:AutoBuyItems()
    -- Auto buy fighting style
    pcall(function()
        -- Implementasi auto buy
    end)
end

-- ==================================================
-- BOSS FARMING
-- ==================================================
function AutoFarm:FarmBoss()
    while self.Settings.Enabled and self.Settings.Mode == "Boss" do
        local boss = Utils:FindBoss()
        if boss then
            self:AttackTarget(boss)
        else
            task.wait(5)
        end
    end
end

-- ==================================================
-- STATS & REPORT
-- ==================================================
function AutoFarm:GetStats()
    local runtime = tick() - self.Stats.FarmingTime
    local levelsGained = self.Stats.LevelCurrent - self.Stats.LevelStart
    
    return {
        Runtime = string.format("%.1f minutes", runtime / 60),
        LevelsGained = levelsGained,
        EnemiesKilled = self.Stats.EnemiesKilled,
        CurrentLevel = self.Stats.LevelCurrent,
        KillRate = string.format("%.1f kills/min", self.Stats.EnemiesKilled / (runtime / 60))
    }
end

function AutoFarm:PrintStats()
    local stats = self:GetStats()
    print("=== 🍫 Auto Farm Statistics ===")
    print("Runtime: " .. stats.Runtime)
    print("Levels Gained: " .. stats.LevelsGained)
    print("Current Level: " .. stats.CurrentLevel)
    print("Enemies Killed: " .. stats.EnemiesKilled)
    print("Kill Rate: " .. stats.KillRate)
    print("================================")
end

-- ==================================================
-- INITIALIZATION
-- ==================================================
function AutoFarm:Init()
    Utils:Notify("🍫 AutoFarm", "Auto Farm Module Loaded", 2, "chocolate")
    return self
end

return AutoFarm:Init()