--[[
╔══════════════════════════════════════════════════════════╗
║     🍫 CHOCOLATE ENGINEERING - UTILITY FUNCTIONS        ║
║     Version: 2.0.0 - Helper Modules                     ║
║     Author: Chocolate Engineer                          ║
╚══════════════════════════════════════════════════════════╝
--]]

local Utils = {}
local Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

-- ==================================================
-- COLOR UTILITIES
-- ==================================================
Utils.Colors = {
    Red = Color3.new(1, 0, 0),
    Green = Color3.new(0, 1, 0),
    Blue = Color3.new(0, 0, 1),
    Yellow = Color3.new(1, 1, 0),
    Orange = Color3.new(1, 0.5, 0),
    Purple = Color3.new(0.5, 0, 1),
    Pink = Color3.new(1, 0.5, 1),
    Cyan = Color3.new(0, 1, 1),
    White = Color3.new(1, 1, 1),
    Black = Color3.new(0, 0, 0),
    Gray = Color3.new(0.5, 0.5, 0.5),
    Chocolate = Color3.new(0.82, 0.41, 0.12),
    DarkChocolate = Color3.new(0.5, 0.25, 0.07)
}

-- ==================================================
-- NOTIFICATION UTILITIES
-- ==================================================
function Utils:Notify(title, message, duration, type)
    duration = duration or 5
    type = type or "info"
    
    local color = self.Colors.Blue
    if type == "success" then
        color = self.Colors.Green
    elseif type == "error" then
        color = self.Colors.Red
    elseif type == "warning" then
        color = self.Colors.Orange
    elseif type == "chocolate" then
        color = self.Colors.Chocolate
    end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(message),
            Duration = duration,
            Icon = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        })
    end)
    
    -- Console log juga
    print(string.format("[🍫 %s] %s: %s", type:upper(), title, message))
end

-- ==================================================
-- PLAYER UTILITIES
-- ==================================================
function Utils:GetPlayerLevel()
    local success, level = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    return success and level or 1
end

function Utils:GetPlayerBounty()
    local success, bounty = pcall(function()
        return LocalPlayer.Leaderstats.Bounty.Value
    end)
    return success and bounty or 0
end

function Utils:GetPlayerFruit()
    local success, fruit = pcall(function()
        if LocalPlayer.Data.Fruit then
            return LocalPlayer.Data.Fruit.Value
        end
        return "None"
    end)
    return success and fruit or "None"
end

function Utils:GetPlayerRace()
    local success, race = pcall(function()
        return LocalPlayer.Data.Race.Value
    end)
    return success and race or "Human"
end

function Utils:IsInSea(seaNumber)
    local level = self:GetPlayerLevel()
    if seaNumber == 1 then
        return level <= 700
    elseif seaNumber == 2 then
        return level > 700 and level <= 1500
    elseif seaNumber == 3 then
        return level > 1500
    end
    return false
end

-- ==================================================
-- POSITION & MOVEMENT UTILITIES
-- ==================================================
function Utils:GetCharacter()
    return LocalPlayer.Character
end

function Utils:GetHumanoid()
    local char = self:GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

function Utils:GetRootPart()
    local char = self:GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils:Teleport(CFramePosition)
    local root = self:GetRootPart()
    if root then
        root.CFrame = CFramePosition
        return true
    end
    return false
end

function Utils:SmoothTeleport(CFramePosition, duration)
    local root = self:GetRootPart()
    if root then
        local tweenInfo = TweenInfo.new(
            duration or 0.5,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(root, tweenInfo, {CFrame = CFramePosition})
        tween:Play()
        return tween
    end
    return nil
end

function Utils:GetDistanceTo(position)
    local root = self:GetRootPart()
    if root then
        return (root.Position - position).Magnitude
    end
    return math.huge
end

-- ==================================================
-- COMBAT UTILITIES
-- ==================================================
function Utils:EquipTool(toolName)
    local backpack = LocalPlayer.Backpack
    local character = self:GetCharacter()
    
    -- Coba equip dari character dulu
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and (not toolName or tool.Name == toolName) then
                return true
            end
        end
    end
    
    -- Cari di backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and (not toolName or tool.Name == toolName) then
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:EquipTool(tool)
                return true
            end
        end
    end
    
    return false
end

function Utils:Attack()
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0,0))
        task.wait(0.1)
        VirtualUser:Button1Up(Vector2.new(0,0))
    end)
end

function Utils:Click(amount)
    amount = amount or 1
    for i = 1, amount do
        self:Attack()
        task.wait(0.05)
    end
end

-- ==================================================
-- ENTITY UTILITIES
-- ==================================================
function Utils:FindClosestEnemy(maxDistance)
    maxDistance = maxDistance or 1000
    local closest = nil
    local closestDistance = maxDistance
    
    -- Cari di workspace.Enemies
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            local humanoid = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and humanoid.Health > 0 then
                local distance = self:GetDistanceTo(hrp.Position)
                if distance < closestDistance then
                    closestDistance = distance
                    closest = enemy
                end
            end
        end
    end
    
    return closest, closestDistance
end

function Utils:FindAllEnemiesInRadius(radius)
    radius = radius or 500
    local enemies = {}
    local root = self:GetRootPart()
    
    if not root then return enemies end
    
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            local humanoid = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and humanoid.Health > 0 then
                local distance = self:GetDistanceTo(hrp.Position)
                if distance <= radius then
                    table.insert(enemies, enemy)
                end
            end
        end
    end
    
    return enemies
end

function Utils:FindBoss()
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            if enemy.Name:find("Boss") or enemy.Name:find("Factory") then
                local humanoid = enemy:FindFirstChild("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                
                if humanoid and hrp and humanoid.Health > 0 then
                    return enemy
                end
            end
        end
    end
    return nil
end

-- ==================================================
-- ITEM UTILITIES
-- ==================================================
function Utils:FindDroppedItems(radius)
    radius = radius or 500
    local items = {}
    local root = self:GetRootPart()
    
    if not root then return items end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name == "Drop" or v.Name == "Item" or v.Name == "Chest" then
            local distance = self:GetDistanceTo(v.Position)
            if distance <= radius then
                table.insert(items, v)
            end
        end
    end
    
    return items
end

function Utils:CollectItem(item)
    local root = self:GetRootPart()
    if root and item then
        firetouchinterest(root, item, 0)
        task.wait()
        firetouchinterest(root, item, 1)
        return true
    end
    return false
end

function Utils:CollectAllItems(radius)
    local items = self:FindDroppedItems(radius)
    for _, item in pairs(items) do
        self:CollectItem(item)
        task.wait(0.1)
    end
    return #items
end

-- ==================================================
-- QUEST UTILITIES
-- ==================================================
function Utils:GetCurrentQuest()
    local success, quest = pcall(function()
        return LocalPlayer.PlayerGui.Main.Quest
    end)
    return success and quest or nil
end

function Utils:HasQuest()
    local quest = self:GetCurrentQuest()
    return quest and quest.Visible == true
end

function Utils:GetQuestTarget()
    local quest = self:GetCurrentQuest()
    if quest and quest.Visible then
        local title = quest.Container.QuestTitle.Title.Text
        -- Parse quest title untuk dapat target
        return title
    end
    return nil
end

function Utils:CompleteQuest()
    -- Cari quest giver terdekat
    local questGivers = Workspace:FindFirstChild("QuestGivers")
    if questGivers then
        for _, giver in pairs(questGivers:GetChildren()) do
            if giver:FindFirstChild("HumanoidRootPart") then
                return giver
            end
        end
    end
    return nil
end

-- ==================================================
-- SERVER UTILITIES
-- ==================================================
function Utils:GetServerTime()
    return Stats.Network.ServerStatsItem:GetValueString()
end

function Utils:GetPing()
    return Stats.Network.ServerStatsItem:GetValue() * 1000
end

function Utils:RejoinServer()
    local ts = game:GetService("TeleportService")
    local placeId = game.PlaceId
    ts:Teleport(placeId, LocalPlayer)
end

function Utils:HopServer()
    local Http = game:GetService("HttpService")
    local function getServers()
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100", game.PlaceId)
        local response = game:HttpGet(url)
        local data = Http:JSONDecode(response)
        return data.data
    end
    
    local servers = getServers()
    local currentJobId = game.JobId
    
    for _, server in pairs(servers) do
        if server.playing < server.maxPlayers and server.id ~= currentJobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            break
        end
    end
end

-- ==================================================
-- GUI UTILITIES
-- ==================================================
function Utils:CreateDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utils:CreateWatermark(text)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ChocolateWatermark"
    screenGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.Position = UDim2.new(0, 10, 1, -40)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Utils.Colors.Chocolate
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = frame
    
    return screenGui
end

-- ==================================================
-- MATH UTILITIES
-- ==================================================
function Utils:RandomString(length)
    length = length or 10
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

function Utils:Round(number, decimals)
    decimals = decimals or 0
    local mult = 10^decimals
    return math.floor(number * mult + 0.5) / mult
end

function Utils:Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils:Lerp(a, b, t)
    return a + (b - a) * t
end

-- ==================================================
-- SECURITY UTILITIES
-- ==================================================
function Utils:AntiBan()
    -- Deteksi dan hindari ban
    local function checkForBan()
        -- Cek jika ada remote yang mencurigakan
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v.Name:match("Ban") or v.Name:match("Kick") or v.Name:match("Report") then
                -- Log atau handle
                self:Notify("⚠️ Security", "Ban detection active", 2, "warning")
            end
        end
    end
    
    spawn(function()
        while true do
            task.wait(30)
            checkForBan()
        end
    end)
end

function Utils:ClearLogs()
    -- Clear console (untuk executor tertentu)
    pcall(function()
        rconsoleclear()
    end)
end

-- ==================================================
-- WEBHOOK UTILITIES
-- ==================================================
function Utils:SendWebhook(url, data)
    if not url then return false end
    
    local success, response = pcall(function()
        return HttpService:PostAsync(url, HttpService:JSONEncode(data), 
            Enum.HttpContentType.ApplicationJson)
    end)
    
    return success
end

function Utils:DiscordWebhook(url, message, username)
    username = username or "Chocolate Engineering"
    
    local data = {
        content = message,
        username = username
    }
    
    return self:SendWebhook(url, data)
end

-- ==================================================
-- INITIALIZATION
-- ==================================================
function Utils:Init()
    self:Notify("🍫 Utils", "Utility functions loaded", 2, "chocolate")
    
    -- Anti ban default
    self:AntiBan()
    
    -- Create watermark
    self:CreateWatermark("🍫 Chocolate Engineering v2.0")
    
    return self
end

-- Return utils object
return Utils:Init()