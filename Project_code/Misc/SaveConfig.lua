-- SaveConfig.lua - Lynx GUI Configuration Manager
-- ULTRA SAFE VERSION - Fixed for GUI integration

print("[SaveConfig] 🔄 Module starting...")

-- ============================================
-- SAFETY CHECKS
-- ============================================
local function safeCheck()
    assert(game, "game is nil")
    assert(game.GetService, "game.GetService is nil")
    return true
end

pcall(safeCheck)

-- ============================================
-- MAIN MODULE
-- ============================================
local SaveConfig = {
    ConfigFile = "LynxGUI_Config.json",
    _data = {},
    _loaded = false
}

-- Default configuration
local DefaultConfig = {
    InstantFishingMode = "None",
    InstantFishingEnabled = false,
    FishingDelay = 1.30,
    CancelDelay = 0.19,
    HideStatsEnabled = false,
    HideStatsFakeName = "Guest",
    HideStatsFakeLevel = "1",
    WebhookEnabled = false,
    WebhookURL = "",
    WebhookDiscordID = "",
    WebhookSelectedRarities = {},
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function deepCopy(original)
    if type(original) ~= "table" then 
        return original 
    end
    
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = type(v) == "table" and deepCopy(v) or v
    end
    return copy
end

-- ============================================
-- CORE FUNCTIONS
-- ============================================

function SaveConfig.Initialize()
    SaveConfig._data = deepCopy(DefaultConfig)
    SaveConfig._loaded = true
    print("[SaveConfig] ✅ Initialized")
    return true
end

function SaveConfig.Save()
    if not writefile then
        warn("[SaveConfig] ⚠️ writefile not available")
        return false, "Executor tidak support writefile"
    end
    
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        local encoded = HttpService:JSONEncode(SaveConfig._data)
        writefile(SaveConfig.ConfigFile, encoded)
    end)
    
    if success then
        print("[SaveConfig] ✅ Saved")
        return true, "Config tersimpan!"
    else
        warn("[SaveConfig] ❌ Save failed:", err)
        return false, "Gagal: " .. tostring(err)
    end
end

function SaveConfig.Load()
    if not isfile or not readfile then
        warn("[SaveConfig] ⚠️ File functions not available")
        SaveConfig.Initialize()
        return false, "Executor tidak support readfile"
    end
    
    if not isfile(SaveConfig.ConfigFile) then
        SaveConfig.Initialize()
        return false, "Tidak ada config tersimpan"
    end
    
    local success, result = pcall(function()
        local data = readfile(SaveConfig.ConfigFile)
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONDecode(data)
    end)
    
    if success and result then
        -- Merge with defaults
        for key, value in pairs(DefaultConfig) do
            if result[key] == nil then
                result[key] = value
            end
        end
        
        SaveConfig._data = result
        SaveConfig._loaded = true
        print("[SaveConfig] ✅ Loaded")
        return true, "Config dimuat!"
    else
        SaveConfig.Initialize()
        return false, "Gagal load config"
    end
end

function SaveConfig.Get(key)
    return SaveConfig._data[key]
end

function SaveConfig.Set(key, value)
    SaveConfig._data[key] = value
end

function SaveConfig.GetAll()
    return SaveConfig._data
end

function SaveConfig.Reset()
    SaveConfig.Initialize()
    return SaveConfig.Save()
end

function SaveConfig.Delete()
    if not delfile or not isfile then
        SaveConfig.Initialize()
        return true, "Reset to defaults"
    end
    
    pcall(function()
        if isfile(SaveConfig.ConfigFile) then
            delfile(SaveConfig.ConfigFile)
        end
    end)
    
    SaveConfig.Initialize()
    return true, "Config dihapus!"
end

function SaveConfig.Exists()
    if not isfile then 
        return false 
    end
    
    local success, result = pcall(function()
        return isfile(SaveConfig.ConfigFile)
    end)
    
    return success and result or false
end

-- ============================================
-- GUI INTERACTION FUNCTIONS
-- ============================================

function SaveConfig.CollectFromGUI(guiVars)
    if type(guiVars) ~= "table" then
        warn("[SaveConfig] guiVars is not table")
        return false
    end
    
    print("[SaveConfig] 📥 Collecting...")
    
    local collected = 0
    
    -- Simple variables
    local simpleVars = {
        {"InstantFishingMode", "currentInstantMode"},
        {"InstantFishingEnabled", "isInstantFishingEnabled"},
        {"FishingDelay", "fishingDelayValue"},
        {"CancelDelay", "cancelDelayValue"},
        {"HideStatsFakeName", "currentFakeName"},
        {"HideStatsFakeLevel", "currentFakeLevel"},
        {"WebhookURL", "currentWebhookURL"},
        {"WebhookDiscordID", "currentDiscordID"},
        {"WebhookSelectedRarities", "selectedRarities"},
    }
    
    for _, pair in ipairs(simpleVars) do
        local configKey, varName = pair[1], pair[2]
        local value = guiVars[varName]
        if value ~= nil then
            SaveConfig.Set(configKey, value)
            print("  ✓", configKey)
            collected = collected + 1
        end
    end
    
    -- HideStats enabled state
    local hideStats = guiVars.HideStats
    if hideStats and type(hideStats.IsEnabled) == "function" then
        local ok, enabled = pcall(hideStats.IsEnabled)
        if ok then
            SaveConfig.Set("HideStatsEnabled", enabled)
            print("  ✓ HideStatsEnabled")
            collected = collected + 1
        end
    end
    
    print("[SaveConfig] ✅ Collected", collected, "settings")
    return true
end

function SaveConfig.ApplyToGUI(guiVars)
    if type(guiVars) ~= "table" then
        warn("[SaveConfig] guiVars is not table")
        return false
    end
    
    print("[SaveConfig] 🎨 Applying...")
    
    local config = SaveConfig.GetAll()
    local applied = 0
    
    -- Apply simple variables
    local simpleVars = {
        {"currentFakeName", "HideStatsFakeName"},
        {"currentFakeLevel", "HideStatsFakeLevel"},
        {"currentInstantMode", "InstantFishingMode"},
        {"isInstantFishingEnabled", "InstantFishingEnabled"},
        {"fishingDelayValue", "FishingDelay"},
        {"cancelDelayValue", "CancelDelay"},
        {"currentWebhookURL", "WebhookURL"},
        {"currentDiscordID", "WebhookDiscordID"},
        {"selectedRarities", "WebhookSelectedRarities"},
    }
    
    for _, pair in ipairs(simpleVars) do
        local varName, configKey = pair[1], pair[2]
        if config[configKey] ~= nil and guiVars[varName] ~= nil then
            guiVars[varName] = config[configKey]
            print("  ✓", varName)
            applied = applied + 1
        end
    end
    
    -- Update instant modules
    local instant = guiVars.instant
    if instant and type(instant) == "table" and instant.Settings then
        instant.Settings.MaxWaitTime = config.FishingDelay or 1.30
        instant.Settings.CancelDelay = config.CancelDelay or 0.19
        print("  ✓ instant")
        applied = applied + 1
    end
    
    local instant2 = guiVars.instant2
    if instant2 and type(instant2) == "table" and instant2.Settings then
        instant2.Settings.MaxWaitTime = config.FishingDelay or 1.30
        instant2.Settings.CancelDelay = config.CancelDelay or 0.19
        print("  ✓ instant2")
        applied = applied + 1
    end
    
    -- Update TextBoxes
    local fakeNameBox = guiVars.fakeNameTextBox
    if fakeNameBox and typeof(fakeNameBox) == "Instance" then
        pcall(function()
            fakeNameBox.Text = config.HideStatsFakeName or "Guest"
            print("  ✓ fakeNameTextBox")
            applied = applied + 1
        end)
    end
    
    local fakeLevelBox = guiVars.fakeLevelTextBox
    if fakeLevelBox and typeof(fakeLevelBox) == "Instance" then
        pcall(function()
            fakeLevelBox.Text = config.HideStatsFakeLevel or "1"
            print("  ✓ fakeLevelTextBox")
            applied = applied + 1
        end)
    end
    
    -- Update HideStats
    local hideStats = guiVars.HideStats
    if hideStats and guiVars.hideStatsLoaded then
        if type(hideStats.SetFakeName) == "function" then
            pcall(function()
                hideStats.SetFakeName(config.HideStatsFakeName or "Guest")
                print("  ✓ HideStats.SetFakeName")
                applied = applied + 1
            end)
        end
        
        if type(hideStats.SetFakeLevel) == "function" then
            pcall(function()
                hideStats.SetFakeLevel(config.HideStatsFakeLevel or "1")
                print("  ✓ HideStats.SetFakeLevel")
                applied = applied + 1
            end)
        end
        
        if config.HideStatsEnabled and type(hideStats.Enable) == "function" then
            pcall(function()
                hideStats.Enable()
                print("  ✓ HideStats.Enable")
                applied = applied + 1
            end)
        end
    end
    
    -- Update Webhook TextBoxes
    local webhookBox = guiVars.webhookTextBox
    if webhookBox and typeof(webhookBox) == "Instance" then
        pcall(function()
            webhookBox.Text = config.WebhookURL or ""
            print("  ✓ webhookTextBox")
            applied = applied + 1
        end)
    end
    
    local discordIDBox = guiVars.discordIDTextBox
    if discordIDBox and typeof(discordIDBox) == "Instance" then
        pcall(function()
            discordIDBox.Text = config.WebhookDiscordID or ""
            print("  ✓ discordIDTextBox")
            applied = applied + 1
        end)
    end
    
    -- Update Checkboxes
    local checkboxes = guiVars.checkboxes
    if checkboxes and type(checkboxes) == "table" and config.WebhookSelectedRarities then
        for _, rarity in ipairs(config.WebhookSelectedRarities) do
            local checkbox = checkboxes[rarity]
            if checkbox and type(checkbox.setSelected) == "function" then
                pcall(function()
                    checkbox.setSelected(true)
                    print("  ✓ Checkbox", rarity)
                    applied = applied + 1
                end)
            end
        end
    end
    
    print("[SaveConfig] ✅ Applied", applied, "settings")
    return true
end

-- ============================================
-- INITIALIZE
-- ============================================
SaveConfig.Initialize()
print("[SaveConfig] ✅ Module ready")

return SaveConfig
