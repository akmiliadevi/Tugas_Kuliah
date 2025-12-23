-- ⚡ ULTRA SPEED AUTO FISHING v29.3 (Fast Mode - Auto-Sync with GUI Config)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Hentikan script lama jika masih aktif
if _G.FishingScriptFast then
    _G.FishingScriptFast.Stop()
    task.wait(0.1)
end

-- Inisialisasi koneksi network
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
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

-- ⭐ AUTO-LOAD SETTINGS FROM CONFIG
local function loadConfigSettings()
    -- Cek apakah GetConfigValue tersedia
    if _G.GetConfigValue then
        local maxWait = _G.GetConfigValue("InstantFishing.FishingDelay", 1.30)
        local cancelDelay = _G.GetConfigValue("InstantFishing.CancelDelay", 0.19)
        print("✅ Fast Mode: Loaded settings from config")
        print("   MaxWaitTime:", maxWait, "| CancelDelay:", cancelDelay)
        return maxWait, cancelDelay
    else
        print("⚠️ Fast Mode: Config system not ready, using defaults")
        return 1.30, 0.19
    end
end

-- Load settings saat module pertama kali diinisialisasi
local initialMaxWait, initialCancelDelay = loadConfigSettings()

-- Modul utama
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Connections = {},
    -- ⭐ Settings langsung dari config
    Settings = {
        FishingDelay = 0.01,
        CancelDelay = initialCancelDelay,           -- ⭐ Auto-loaded dari config
        HookDetectionDelay = 0.05,
        RetryDelay = 0.1,
        MaxWaitTime = initialMaxWait,               -- ⭐ Auto-loaded dari config
    }
}

_G.FishingScriptFast = fishing

-- ⭐ Auto-refresh settings setiap kali akan Start
local function refreshSettings()
    if _G.GetConfigValue then
        fishing.Settings.MaxWaitTime = _G.GetConfigValue("InstantFishing.FishingDelay", 1.30)
        fishing.Settings.CancelDelay = _G.GetConfigValue("InstantFishing.CancelDelay", 0.19)
        print("🔄 Fast Mode: Settings refreshed from config")
        print("   MaxWaitTime:", fishing.Settings.MaxWaitTime, "| CancelDelay:", fishing.Settings.CancelDelay)
    end
end

-- Nonaktifkan animasi
local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("fish") or name:find("rod") or name:find("cast") or name:find("reel") then
                track:Stop(0)
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

-- Fungsi cast (⭐ Menggunakan Settings.MaxWaitTime dan Settings.CancelDelay)
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1

    local castSuccess = pcall(function()
        RF_ChargeFishingRod:InvokeServer({[10] = tick()})
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        fishing.WaitingHook = true

        -- ⭐ Gunakan Settings.MaxWaitTime
        task.delay(fishing.Settings.MaxWaitTime * 0.7, function()
            if fishing.WaitingHook and fishing.Running then
                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)
            end
        end)

        -- ⭐ Gunakan Settings.MaxWaitTime
        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)

                task.wait(fishing.Settings.RetryDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
    end)

    if not castSuccess then
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end

-- Start (⭐ Auto-refresh settings sebelum start)
function fishing.Start()
    if fishing.Running then return end
    
    -- ⭐ Refresh settings dari config sebelum start
    refreshSettings()
    
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0

    print("✅ Fast Mode Started with:")
    print("   MaxWaitTime:", fishing.Settings.MaxWaitTime, "s")
    print("   CancelDelay:", fishing.Settings.CancelDelay, "s")

    disableFishingAnim()

    fishing.Connections.Minigame = RE_MinigameChanged.OnClientEvent:Connect(function(state)
        if fishing.WaitingHook and typeof(state) == "string" then
            local s = string.lower(state)
            if string.find(s, "hook") or string.find(s, "bite") or string.find(s, "catch") then
                fishing.WaitingHook = false
                task.wait(fishing.Settings.HookDetectionDelay)

                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)

                -- ⭐ Gunakan Settings.CancelDelay dari config
                task.wait(fishing.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end
    end)

    fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(_, data)
        if fishing.Running then
            fishing.WaitingHook = false
            fishing.TotalFish += 1

            pcall(function()
                -- ⭐ Gunakan Settings.CancelDelay dari config
                task.wait(fishing.Settings.CancelDelay)
                RF_CancelFishingInputs:InvokeServer()
            end)

            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then
                fishing.Cast()
            end
        end
    end)

    fishing.Connections.AnimDisabler = task.spawn(function()
        while fishing.Running do
            disableFishingAnim()
            task.wait(0.15)
        end
    end)

    task.wait(0.5)
    fishing.Cast()
end

-- Stop
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
    
    print("✅ Fast Mode stopped - Game auto fishing enabled, can change rod/skin")
end

-- ⭐ Function untuk update settings dari GUI (tetap ada untuk backward compatibility)
function fishing.UpdateSettings(maxWaitTime, cancelDelay)
    if maxWaitTime then
        fishing.Settings.MaxWaitTime = maxWaitTime
        print("✅ Fast Mode MaxWaitTime updated to:", maxWaitTime)
    end
    if cancelDelay then
        fishing.Settings.CancelDelay = cancelDelay
        print("✅ Fast Mode CancelDelay updated to:", cancelDelay)
    end
end

return fishing
