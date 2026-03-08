
---

## 📜 **FILE 3: config.lua** (Konfigurasi)

```lua
--[[
CHOCOLATE ENGINEERING - CONFIGURATION FILE
Edit sesuai kebutuhan Anda
--]]

return {
    -- Auto Farm Settings
    AutoFarm = {
        Enabled = false,           -- Aktif/nonaktif default
        Speed = 100,                -- Kecepatan jalan
        AutoEquip = true,           -- Auto equip weapon
        AutoCollect = true,         -- Auto collect item
        AntiAfk = true,              -- Anti disconnect
        FarmMode = "Level"           -- Level, Boss, atau Quest
    },
    
    -- Gacha Settings
    Gacha = {
        Enabled = false,             -- Aktif/nonaktif
        TargetFruit = "Random",      -- Fruit target
        AutoGacha = false,            -- Auto gacha loop
        GachaDelay = 0.5              -- Delay antar gacha (detik)
    },
    
    -- GUI Settings
    GUI = {
        Theme = "DarkTheme",          -- Tema GUI
        Position = "Center",           -- Posisi GUI
        Size = "Medium"                -- Ukuran (Small, Medium, Large)
    },
    
    -- Security
    Security = {
        UseAltAccount = true,          -- Saran: true
        AntiBan = true,                 -- Proteksi ban
        HideFromLogs = true              -- Sembunyikan dari log
    }
}