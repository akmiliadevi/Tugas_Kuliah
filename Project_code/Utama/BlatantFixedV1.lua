-- ⚠️ BLATANT V2 AUTO FISHING - PERFECT CAST MODULE
-- EXTERNAL GUI COMPATIBLE - NO INTERNAL GUI
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

-- Module table
local BlatantV2 = {}
BlatantV2.Active = false
BlatantV2.Stats = {
    castCount = 0,
    perfectCasts = 0,
    startTime = 0
}

-- Settings (accessible from external GUI)
BlatantV2.Settings = {
    ChargeDelay = 0.007,      -- Charge delay untuk perfect cast (timing)
    CompleteDelay = 0.001,    -- Delay sebelum complete
    CancelDelay = 0.001       -- Delay setelah complete
}

----------------------------------------------------------------
-- CORE FISHING FUNCTIONS
----------------------------------------------------------------

local function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

local function ultraSpamLoop()
    while BlatantV2.Active do
        local startTime = tick()
        
        -- 1. Start charging
        safeFire(function()
            RF_ChargeFishingRod:InvokeServer({[1] = startTime})
        end)
        
        -- 2. Wait for perfect timing (ChargeDelay)
        task.wait(BlatantV2.Settings.ChargeDelay)
        
        -- 3. Release at perfect timing
        local releaseTime = tick()
        safeFire(function()
            RF_RequestMinigame:InvokeServer(1, 0, releaseTime)
        end)
        
        BlatantV2.Stats.castCount = BlatantV2.Stats.castCount + 1
        BlatantV2.Stats.perfectCasts = BlatantV2.Stats.perfectCasts + 1
        
        -- 4. Wait CompleteDelay then fire complete
        task.wait(BlatantV2.Settings.CompleteDelay)
        
        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)
        
        -- 5. Cancel with CancelDelay
        task.wait(BlatantV2.Settings.CancelDelay)
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end
end

-- Backup listener
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not BlatantV2.Active then return end
    
    task.spawn(function()
        task.wait(BlatantV2.Settings.CompleteDelay)
        
        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)
        
        task.wait(BlatantV2.Settings.CancelDelay)
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end)
end)

----------------------------------------------------------------
-- PUBLIC API (Compatible dengan GUI pattern kamu)
----------------------------------------------------------------

-- ⭐ NEW: Update Settings function
function BlatantV2.UpdateSettings(completeDelay, cancelDelay)
    if completeDelay ~= nil then
        BlatantV2.Settings.CompleteDelay = completeDelay
        print("✅ UltraBlatant CompleteDelay updated:", completeDelay)
    end
    
    if cancelDelay ~= nil then
        BlatantV2.Settings.CancelDelay = cancelDelay
        print("✅ UltraBlatant CancelDelay updated:", cancelDelay)
    end
end


-- Start function
function BlatantV2.Start()
    if BlatantV2.Active then 
        print("⚠️ Blatant V2 already running!")
        return
    end
    
    BlatantV2.Active = true
    BlatantV2.Stats.castCount = 0
    BlatantV2.Stats.perfectCasts = 0
    BlatantV2.Stats.startTime = tick()
    
    print("🎯 Blatant V2 started - Perfect Cast Mode")
    print("⏱️ Charge Delay: " .. BlatantV2.Settings.ChargeDelay .. "s")
    
    task.spawn(ultraSpamLoop)
end

-- Stop function
function BlatantV2.Stop()
    if not BlatantV2.Active then 
        return
    end
    
    BlatantV2.Active = false
    
    -- Calculate stats
    local runtime = tick() - BlatantV2.Stats.startTime
    local castsPerMinute = (BlatantV2.Stats.castCount / runtime) * 60
    
    print("✅ Blatant V2 stopped")
    print("📊 Total Casts: " .. BlatantV2.Stats.castCount)
    print("🎯 Perfect Casts: " .. BlatantV2.Stats.perfectCasts)
    print("⏱️ Runtime: " .. math.floor(runtime) .. "s")
    print("📈 Casts/min: " .. math.floor(castsPerMinute))
    
    -- Enable game auto fishing
    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    task.wait(0.2)
    
    -- Cancel fishing inputs
    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    print("🎣 Game auto fishing enabled, can change rod/skin")
end

-- Return module
return BlatantV2
