-- ⚡ ULTRA PERFECT CAST AUTO FISHING v35.0 (Fixed Stuck & Stop)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

if _G.FishingScript then
    _G.FishingScript.Stop()
    task.wait(0.1)
end

local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = netFolder:WaitForChild("RF/UpdateAutoFishingState")  -- ⭐ ADDED
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")
local RE_FishingStopped = netFolder:WaitForChild("RE/FishingStopped")  -- ⭐ ADDED untuk detect fail

local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    PerfectCasts = 0,
    AmazingCasts = 0,
    FailedCasts = 0,  -- ⭐ ADDED
    Connections = {},
    Settings = {
        FishingDelay = 0.07,
        CancelDelay = 0.19,
        HookDetectionDelay = 0.03,
        RetryDelay = 0.04,
        MaxWaitTime = 1.5,
        FailTimeout = 2.5,  -- ⭐ ADDED: Timeout untuk detect stuck
        PerfectChargeTime = 0.34,
        PerfectReleaseDelay = 0.005,
        PerfectPower = 0.95,
        UseMultiDetection = true,
        UseVisualDetection = true,
        UseSoundDetection = false,
    }
}

_G.FishingScript = fishing

local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("fish") or name:find("rod") or name:find("cast") or name:find("reel") then
                track:Stop(0)
                track.TimePosition = 0
            end
        end
    end)

    task.spawn(function()
        local rod = Character:FindFirstChild("Rod") or Character:FindFirstChildWhichIsA("Tool")
        if rod and rod:FindFirstChild("Handle") then
            local handle = rod.Handle
            local weld = handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("Motor6D")
            if weld then
                weld.C0 = CFrame.new(0, -1, -1.2) * CFrame.Angles(math.rad(-10), 0, 0)
            end
        end
    end)
end

-- ⭐ ADDED: Function untuk handle failed cast (kail tidak menyentuh air)
local function handleFailedCast()
    fishing.WaitingHook = false
    fishing.FailedCasts += 1
    
    -- Cancel & reset state
    pcall(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    task.wait(fishing.Settings.RetryDelay)
    
    -- Retry cast
    if fishing.Running then
        fishing.PerfectCast()
    end
end

function fishing.PerfectCast()
    if not fishing.Running or fishing.WaitingHook then 
        return 
    end

    disableFishingAnim()
    fishing.CurrentCycle += 1

    local castSuccess = pcall(function()
        local startTime = tick()
        local chargeData = {[1] = startTime}
        
        local chargeResult = RF_ChargeFishingRod:InvokeServer(chargeData)
        if not chargeResult then 
            error("Charge fishing rod failed") 
        end

        local waitTime = fishing.Settings.PerfectChargeTime
        local endTime = tick() + waitTime
        while tick() < endTime and fishing.Running do
            task.wait(0.01)
        end

        task.wait(fishing.Settings.PerfectReleaseDelay)

        local releaseTime = tick()
        local perfectPower = fishing.Settings.PerfectPower

        local minigameResult = RF_RequestMinigame:InvokeServer(
            perfectPower,
            0,
            releaseTime
        )
        
        -- ⭐ FIX: Check jika minigame failed (kail tidak menyentuh air)
        if not minigameResult then 
            handleFailedCast()
            return
        end

        fishing.WaitingHook = true
        local hookDetected = false
        local castStartTime = tick()  -- ⭐ ADDED: Track cast time
        local eventDetection

        eventDetection = RE_MinigameChanged.OnClientEvent:Connect(function(state)
            if fishing.WaitingHook and typeof(state) == "string" then
                local s = state:lower()
                if s:find("hook") or s:find("bite") or s:find("catch") or s == "!" then
                    hookDetected = true
                    eventDetection:Disconnect()
                    
                    fishing.WaitingHook = false

                    task.wait(fishing.Settings.HookDetectionDelay)
                    pcall(function()
                        RE_FishingCompleted:FireServer()
                    end)

                    task.wait(fishing.Settings.CancelDelay)
                    pcall(function()
                        RF_CancelFishingInputs:InvokeServer()
                    end)

                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then
                        fishing.PerfectCast()
                    end
                end
            end
        end)

        -- ⭐ ENHANCED: Timeout dengan fail detection
        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                if not hookDetected then
                    fishing.WaitingHook = false
                    eventDetection:Disconnect()

                    pcall(function()
                        RE_FishingCompleted:FireServer()
                    end)

                    task.wait(fishing.Settings.RetryDelay)
                    pcall(function()
                        RF_CancelFishingInputs:InvokeServer()
                    end)

                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then
                        fishing.PerfectCast()
                    end
                end
            end
        end)
        
        -- ⭐ ADDED: Emergency fail timeout (untuk detect stuck)
        task.delay(fishing.Settings.FailTimeout, function()
            if fishing.WaitingHook and fishing.Running then
                local elapsedTime = tick() - castStartTime
                
                -- Jika masih waiting setelah FailTimeout, berarti stuck
                if elapsedTime >= fishing.Settings.FailTimeout then
                    if eventDetection then
                        eventDetection:Disconnect()
                    end
                    
                    handleFailedCast()
                end
            end
        end)
    end)

    if not castSuccess then
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then
            fishing.PerfectCast()
        end
    end
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.PerfectCasts = 0
    fishing.AmazingCasts = 0
    fishing.FailedCasts = 0  -- ⭐ ADDED

    disableFishingAnim()

    -- ⭐ ADDED: Listen untuk fishing stopped (detect kail tidak menyentuh air)
    fishing.Connections.FishingStopped = RE_FishingStopped.OnClientEvent:Connect(function()
        if fishing.Running and fishing.WaitingHook then
            handleFailedCast()
        end
    end)

    fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
        if fishing.Running then
            fishing.WaitingHook = false
            fishing.TotalFish += 1

            local castResult = data and data.CastResult or "Unknown"
            if castResult == "Perfect" then
                fishing.PerfectCasts += 1
            elseif castResult == "Amazing" then
                fishing.AmazingCasts += 1
            end

            task.wait(fishing.Settings.CancelDelay)
            pcall(function()
                RF_CancelFishingInputs:InvokeServer()
            end)

            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then
                fishing.PerfectCast()
            end
        end
    end)

    fishing.Connections.AnimDisabler = task.spawn(function()
        while fishing.Running do
            disableFishingAnim()
            task.wait(0.1)
        end
    end)

    fishing.Connections.StatsReporter = task.spawn(function()
        while fishing.Running do
            task.wait(30)
        end
    end)

    task.wait(0.3)
    fishing.PerfectCast()
end

-- ⭐ ENHANCED Stop - Nyalakan auto fishing game
function fishing.Stop()
    if not fishing.Running then return end
    fishing.Running = false
    fishing.WaitingHook = false

    for _, conn in pairs(fishing.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        elseif typeof(conn) == "thread" then
            task.cancel(conn)
        end
    end

    fishing.Connections = {}
    
    -- ⭐ Nyalakan auto fishing game (biarkan tetap nyala)
    pcall(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    -- Wait sebentar untuk game process
    task.wait(0.2)
    
    -- Cancel fishing inputs untuk memastikan karakter berhenti
    pcall(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
end

return fishing
