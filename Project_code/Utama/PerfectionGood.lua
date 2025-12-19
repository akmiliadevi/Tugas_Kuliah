-- Auto Fish Module untuk Roblox
-- Module ini dapat diintegrasikan dengan GUI eksternal

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Module Table
local GoodPerfectionStable = {}
GoodPerfectionStable.Enabled = false

-- Fungsi untuk menghapus UIGradient
local function removeUIGradient()
    local success, err = pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        if not playerGui then
            return false
        end
        
        local fishing = playerGui:FindFirstChild("Fishing")
        if not fishing then
            return false
        end
        
        local main = fishing:FindFirstChild("Main")
        if not main then
            return false
        end
        
        local display = main:FindFirstChild("Display")
        if not display then
            return false
        end
        
        local animationBG = display:FindFirstChild("AnimationBG")
        if not animationBG then
            return false
        end
        
        local uiGradient = animationBG:FindFirstChild("UIGradient")
        
        if uiGradient then
            uiGradient:Destroy()
            return true
        else
            return true -- Return true karena tujuan tercapai (tidak ada gradient)
        end
    end)
    
    if not success then
        return false
    end
    
    return true
end

-- Fungsi untuk mengaktifkan auto fishing in-game
local function enableAutoFishing(state)
    local success, err = pcall(function()
        -- Cari RemoteFunction atau RemoteEvent untuk UpdateAutoFishingState
        local updateAutoFishing = nil
        
        -- Coba cari di ReplicatedStorage
        for _, item in pairs(ReplicatedStorage:GetDescendants()) do
            if item.Name == "UpdateAutoFishingState" or item.Name == "RF" then
                if item:IsA("RemoteFunction") or item:IsA("RemoteEvent") then
                    updateAutoFishing = item
                    break
                end
            end
        end
        
        -- Jika tidak ditemukan, coba cari dengan nama alternatif
        if not updateAutoFishing then
            updateAutoFishing = ReplicatedStorage:FindFirstChild("RF", true) or
                               ReplicatedStorage:FindFirstChild("UpdateAutoFishingState", true) or
                               ReplicatedStorage:FindFirstChild("RemoteFunction", true) or
                               ReplicatedStorage:FindFirstChild("AutoFishing", true)
        end
        
        if updateAutoFishing then
            -- Invoke/Fire berdasarkan tipe
            if updateAutoFishing:IsA("RemoteFunction") then
                local result = updateAutoFishing:InvokeServer(state)
                return true
            elseif updateAutoFishing:IsA("RemoteEvent") then
                updateAutoFishing:FireServer(state)
                return true
            end
        else
            -- Metode alternatif: Cari di PlayerGui button dan klik
            local success2 = pcall(function()
                local playerGui = LocalPlayer.PlayerGui
                local fishing = playerGui:FindFirstChild("Fishing")
                if fishing then
                    local autoButton = fishing:FindFirstChild("Auto", true)
                    if autoButton and autoButton:IsA("GuiButton") then
                        -- Simulasi klik button
                        for _, connection in pairs(getconnections(autoButton.MouseButton1Click)) do
                            connection:Fire()
                        end
                        return true
                    end
                end
            end)
            
            if success2 then
                return true
            end
            
            return false
        end
    end)
    
    if not success then
        return false
    end
    
    return true
end

-- Fungsi Start - Dipanggil saat toggle ON
function GoodPerfectionStable.Start()
    GoodPerfectionStable.Enabled = true
    
    -- Tunggu sebentar untuk memastikan game sudah siap
    task.wait(0.3)
    
    -- Hapus UIGradient
    local gradientRemoved = removeUIGradient()
    
    -- Tunggu sebentar sebelum mengaktifkan auto
    task.wait(0.5)
    
    -- Aktifkan auto fishing in-game
    local autoEnabled = enableAutoFishing(true)
    
    return (gradientRemoved and autoEnabled)
end

-- Fungsi Stop - Dipanggil saat toggle OFF
function GoodPerfectionStable.Stop()
    GoodPerfectionStable.Enabled = false
    
    -- Nonaktifkan auto fishing in-game
    enableAutoFishing(false)
    
    return true
end

-- Fungsi untuk check status
function GoodPerfectionStable.IsEnabled()
    return GoodPerfectionStable.Enabled
end

-- Export module
return GoodPerfectionStable
