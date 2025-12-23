-- ⚡ ULTRA BLATANT AUTO FISHING MODULE - NO GUI VERSION
-- Untuk diintegrasikan dengan GUI eksternal

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
local RE_FishingStopped = netFolder:WaitForChild("RE/FishingStopped")

-- Module
local UltraBlatant = {}
UltraBlatant.Active = false
UltraBlatant.Stats = {
    castCount = 0,
    startTime = 0
}

UltraBlatant.Settings = {
    CompleteDelay = 0.73,
    CancelDelay = 0.3,
    ReCastDelay = 0.001
}

-- State tracking
local FishingState = {
    lastCompleteTime = 0,
    completeCooldown = 0.4,
    isInCycle = false
}

----------------------------------------------------------------
-- CORE FUNCTIONS
----------------------------------------------------------------

local function safeFire(func)
    task.spawn(function()
        local success, err = pcall(func)
        if not success then
            warn("⚠️ Ultra Blatant Network error:", err)
        end
    end)
end

local function protectedComplete()
    local now = tick()
    
    if now - FishingState.lastCompleteTime < FishingState.completeCooldown then
        return false
    end
    
    FishingState.lastCompleteTime = now
    safeFire(function()
        RE_FishingCompleted:FireServer()
    end)
    
    return true
end

local function performCast()
    local now = tick()
    
    UltraBlatant.Stats.castCount = UltraBlatant.Stats.castCount + 1
    
    safeFire(function()
        RF_ChargeFishingRod:InvokeServer({[1] = now})
    end)
    safeFire(function()
        RF_RequestMinigame:InvokeServer(1, 0, now)
    end)
end

local function fishingLoop()
    while UltraBlatant.Active do
        FishingState.isInCycle = true
        
        -- 1. CAST
        performCast()
        
        -- 2. WAIT CompleteDelay
        task.wait(UltraBlatant.Settings.CompleteDelay)
        
        -- 3. COMPLETE
        if UltraBlatant.Active then
            protectedComplete()
        end
        
        -- 4. WAIT CancelDelay
        task.wait(UltraBlatant.Settings.CancelDelay)
        
        -- 5. CANCEL
        if UltraBlatant.Active then
            safeFire(function()
                RF_CancelFishingInputs:InvokeServer()
            end)
        end
        
        FishingState.isInCycle = false
        
        -- 6. INSTANT RE-CAST
        task.wait(UltraBlatant.Settings.ReCastDelay)
    end
    
    FishingState.isInCycle = false
end

-- Backup listener
local lastEventTime = 0

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not UltraBlatant.Active then return end
    
    local now = tick()
    
    if now - lastEventTime < 0.2 then
        return
    end
    lastEventTime = now
    
    if now - FishingState.lastCompleteTime < 0.3 then
        return
    end
    
    task.spawn(function()
        task.wait(UltraBlatant.Settings.CompleteDelay)
        
        if protectedComplete() then
            task.wait(UltraBlatant.Settings.CancelDelay)
            safeFire(function()
                RF_CancelFishingInputs:InvokeServer()
            end)
        end
    end)
end)

----------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------

-- ⭐ NEW: Update Settings function
function UltraBlatant.UpdateSettings(completeDelay, cancelDelay)
    if completeDelay ~= nil then
        UltraBlatant.Settings.CompleteDelay = completeDelay
        print("✅ UltraBlatant CompleteDelay updated:", completeDelay)
    end
    
    if cancelDelay ~= nil then
        UltraBlatant.Settings.CancelDelay = cancelDelay
        print("✅ UltraBlatant CancelDelay updated:", cancelDelay)
    end
end

function UltraBlatant.Start()
    if UltraBlatant.Active then 
        return false
    end
    
    UltraBlatant.Active = true
    UltraBlatant.Stats.castCount = 0
    UltraBlatant.Stats.startTime = tick()
    
    FishingState.lastCompleteTime = 0
    
    print("🎣 [Ultra Blatant] Enabling game auto fishing...")
    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    task.wait(0.2)
    
    task.spawn(fishingLoop)
    print("✅ [Ultra Blatant] Started!")
    return true
end

function UltraBlatant.Stop()
    if not UltraBlatant.Active then 
        return false
    end
    
    UltraBlatant.Active = false
    
    
    -- Enable game auto fishing (biarkan tetap nyala)
    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    task.wait(0.2)
    
    -- Cancel fishing inputs
    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    return true
end

function UltraBlatant.UpdateSettings(completeDelay, cancelDelay, reCastDelay)
    if completeDelay then
        UltraBlatant.Settings.CompleteDelay = completeDelay
    end
    if cancelDelay then
        UltraBlatant.Settings.CancelDelay = cancelDelay
    end
    if reCastDelay then
        UltraBlatant.Settings.ReCastDelay = reCastDelay
    end
end

function UltraBlatant.GetStats()
    local runtime = math.floor(tick() - UltraBlatant.Stats.startTime)
    local cps = runtime > 0 and math.floor(UltraBlatant.Stats.castCount / runtime * 10) / 10 or 0
    
    return {
        castCount = UltraBlatant.Stats.castCount,
        runtime = runtime,
        cps = cps,
        isActive = UltraBlatant.Active,
        isInCycle = FishingState.isInCycle
    }
end


return UltraBlatant
