-- Standalone Rejoin Script - GUI Compatible (BUTTON ONLY)
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local RejoinModule = {}

function RejoinModule.Execute()
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("🔄 REJOIN SCRIPT STARTED")
    print("━━━━━━━━━━━━━━━━━━━━━━")
    
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    local placeId = game.PlaceId
    
    print("📍 PlaceId:", placeId)
    print("🌐 Teleporting to new server...")
    print("━━━━━━━━━━━━━━━━━━━━━━")
    
    -- Teleport ke server baru
    local success, err = pcall(function()
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
    
    if success then
        print("✅ Rejoin request sent!")
        return true
    else
        warn("❌ Rejoin failed:", err)
        return false, err
    end
end

return RejoinModule
