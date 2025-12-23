-- ⚡ ULTRA BLATANT AUTO FISHING v2.0 - AUTO SYNC WITH GUI CONFIG
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Network initialization
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = netFolder:WaitForChild("RF/UpdateAutoFishingState")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")

-- ⭐ SAFE CONFIG LOADING - Check if function exists
local function safeGetConfig(key, default)
    if _G.GetConfigValue and type(_G.GetConfigValue) == "function" then
        local success, value = pcall(function()
            return _G.GetConfigValue(key, default)
        end)
        if success and value ~= nil then
            return value
        end
    end
    return default
end

-- ⭐ Load saved settings dari GUI config
local function loadSavedSettings()
    local completeDelay = safeGetConfig("UltraBlatant.CompleteDelay", 0.001)
    local cancelDelay = safeGetConfig("UltraBlatant.CancelDelay", 0.001)
    
    if _G.GetConfigValue then
        print("✅ [UltraBlatant] Loaded settings from config")
    else
        print("⚠️ [UltraBlatant] Config not ready yet, using defaults")
    end
    print("   CompleteDelay:", completeDelay, "| CancelDelay:", cancelDelay)
    
    return {
        CompleteDelay = completeDelay,
        CancelDelay = cancelDelay
    }
end

local savedSettings = loadSavedSettings()

-- Module table
local UltraBlatant = {}
UltraBlatant.Active = false
UltraBlatant.Stats = {
    castCount = 0,
    startTime = 0
}

-- ⭐ Settings langsung dari config (dengan auto-load)
UltraBlatant.Settings = {
    CompleteDelay = savedSettings.CompleteDelay,
    CancelDelay = savedSettings.CancelDelay
}

----------------------------------------------------------------
-- CORE FUNCTIONS
----------------------------------------------------------------

local function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

-- MAIN SPAM LOOP
local function ultraSpamLoop()
    while UltraBlatant.Active do
        local currentTime = tick()
        
        -- 1x CHARGE & REQUEST (CASTING)
        safeFire(function()
            RF_ChargeFishingRod:InvokeServer({[1] = currentTime})
        end)
        safeFire(function()
            RF_RequestMinigame:InvokeServer(1, 0, currentTime)
        end)
        
        UltraBlatant.Stats.castCount = UltraBlatant.Stats.castCount + 1
        
        -- Wait CompleteDelay then fire complete once
        task.wait(UltraBlatant.Settings.CompleteDelay)
        
        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)
        
        -- Cancel with CancelDelay
        task.wait(UltraBlatant.Settings.CancelDelay)
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end
end

-- BACKUP LISTENER
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not UltraBlatant.Active then return end
    
    task.spawn(function()
        task.wait(UltraBlatant.Settings.CompleteDelay)
        
        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)
        
        task.wait(UltraBlatant.Settings.CancelDelay)
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end)
end)

----------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------

-- ⭐ Auto-refresh settings dari config sebelum start (seperti instant mode)
local function refreshSettings()
    local completeDelay = safeGetConfig("UltraBlatant.CompleteDelay", UltraBlatant.Settings.CompleteDelay)
    local cancelDelay = safeGetConfig("UltraBlatant.CancelDelay", UltraBlatant.Settings.CancelDelay)
    
    UltraBlatant.Settings.CompleteDelay = completeDelay
    UltraBlatant.Settings.CancelDelay = cancelDelay
    
    if _G.GetConfigValue then
        print("🔄 [UltraBlatant] Settings refreshed from config")
        print("   CompleteDelay:", UltraBlatant.Settings.CompleteDelay, "| CancelDelay:", UltraBlatant.Settings.CancelDelay)
    end
end

-- Start function (⭐ dengan auto-refresh)
function UltraBlatant.Start()
    if UltraBlatant.Active then 
        print("⚠️ Ultra Blatant already running!")
        return
    end
    
    -- ⭐ Refresh settings dari config sebelum start
    refreshSettings()
    
    UltraBlatant.Active = true
    UltraBlatant.Stats.castCount = 0
    UltraBlatant.Stats.startTime = tick()
    
    print("✅ [UltraBlatant] Started with:")
    print("   CompleteDelay:", UltraBlatant.Settings.CompleteDelay, "s")
    print("   CancelDelay:", UltraBlatant.Settings.CancelDelay, "s")
    
    task.spawn(ultraSpamLoop)
end

-- Stop function
function UltraBlatant.Stop()
    if not UltraBlatant.Active then 
        return
    end
    
    UltraBlatant.Active = false
    
    print("✅ [UltraBlatant] Stopped. Stats:")
    print("   Total Casts:", UltraBlatant.Stats.castCount)
    print("   Runtime:", math.floor(tick() - UltraBlatant.Stats.startTime), "seconds")
    
    -- ⭐ Nyalakan auto fishing game (biarkan tetap nyala)
    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    -- Wait sebentar untuk game process
    task.wait(0.2)
    
    -- Cancel fishing inputs untuk memastikan karakter berhenti
    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    print("✅ [UltraBlatant] Game auto fishing enabled, can change rod/skin")
end

-- ⭐ Update Settings function (backward compatibility dengan GUI)
function UltraBlatant.UpdateSettings(completeDelay, cancelDelay)
    if completeDelay ~= nil then
        UltraBlatant.Settings.CompleteDelay = completeDelay
        print("✅ [UltraBlatant] CompleteDelay updated:", completeDelay)
    end
    
    if cancelDelay ~= nil then
        UltraBlatant.Settings.CancelDelay = cancelDelay
        print("✅ [UltraBlatant] CancelDelay updated:", cancelDelay)
    end
end

-- Return module
return UltraBlatant
