-- ==============================================================
--           ⭐ PERFORMANCE OPTIMIZER MODULE (UNIFIED) ⭐
--               3-in-1: FPS Booster + 3D Rendering Control
-- ==============================================================

local PerformanceModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- ==============================================================
--                    FPS BOOSTER SECTION
-- ==============================================================

local FPSBooster = {
    Enabled = false,
    OriginalStates = {
        reflectance = {},
        transparency = {},
        lighting = {},
        effects = {},
        waterProperties = {}
    },
    NewObjectConnection = nil
}

-- Optimize single object
local function optimizeObject(obj)
    if not FPSBooster.Enabled then return end
    
    pcall(function()
        -- Optimize BasePart
        if obj:IsA("BasePart") then
            if not FPSBooster.OriginalStates.reflectance[obj] then
                FPSBooster.OriginalStates.reflectance[obj] = obj.Reflectance
            end
            obj.Reflectance = 0
            obj.CastShadow = false
        end
        
        -- Disable Decals & Textures
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if not FPSBooster.OriginalStates.transparency[obj] then
                FPSBooster.OriginalStates.transparency[obj] = obj.Transparency
            end
            obj.Transparency = 1
        end
        
        -- Disable SurfaceAppearance
        if obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        end
        
        -- Disable Particles
        if obj:IsA("ParticleEmitter") then
            obj.Enabled = false
        end
        
        -- Disable Trails
        if obj:IsA("Trail") then
            obj.Enabled = false
        end
        
        -- Disable Beams
        if obj:IsA("Beam") then
            obj.Enabled = false
        end
        
        -- Disable Fire, Smoke, Sparkles
        if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
    end)
end

-- Restore single object
local function restoreObject(obj)
    pcall(function()
        if obj:IsA("BasePart") then
            if FPSBooster.OriginalStates.reflectance[obj] then
                obj.Reflectance = FPSBooster.OriginalStates.reflectance[obj]
                obj.CastShadow = true
            end
        end
        
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if FPSBooster.OriginalStates.transparency[obj] then
                obj.Transparency = FPSBooster.OriginalStates.transparency[obj]
            end
        end
        
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = true
        end
        
        if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = true
        end
    end)
end

-- Enable FPS Booster
function FPSBooster.Enable()
    if FPSBooster.Enabled then
        return false, "Already enabled"
    end
    
    FPSBooster.Enabled = true
    
    -- Optimize existing objects
    for _, obj in ipairs(workspace:GetDescendants()) do
        optimizeObject(obj)
    end
    
    -- Optimize Terrain Water
    if Terrain then
        pcall(function()
            FPSBooster.OriginalStates.waterProperties = {
                WaterReflectance = Terrain.WaterReflectance,
                WaterWaveSize = Terrain.WaterWaveSize,
                WaterWaveSpeed = Terrain.WaterWaveSpeed
            }
            
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
        end)
    end
    
    -- Optimize Lighting
    FPSBooster.OriginalStates.lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart
    }
    
    Lighting.GlobalShadows = false
    Lighting.FogStart = 0
    Lighting.FogEnd = 1000000
    
    -- Disable Post-Processing
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            FPSBooster.OriginalStates.effects[effect] = effect.Enabled
            effect.Enabled = false
        end
    end
    
    -- Set minimum quality
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    -- Hook new objects
    FPSBooster.NewObjectConnection = workspace.DescendantAdded:Connect(function(obj)
        if FPSBooster.Enabled then
            task.wait(0.1)
            optimizeObject(obj)
        end
    end)
    
    return true, "FPS Booster enabled"
end

-- Disable FPS Booster
function FPSBooster.Disable()
    if not FPSBooster.Enabled then
        return false, "Already disabled"
    end
    
    FPSBooster.Enabled = false
    
    -- Restore objects
    for _, obj in ipairs(workspace:GetDescendants()) do
        restoreObject(obj)
    end
    
    -- Restore Terrain Water
    if Terrain and FPSBooster.OriginalStates.waterProperties then
        pcall(function()
            Terrain.WaterReflectance = FPSBooster.OriginalStates.waterProperties.WaterReflectance
            Terrain.WaterWaveSize = FPSBooster.OriginalStates.waterProperties.WaterWaveSize
            Terrain.WaterWaveSpeed = FPSBooster.OriginalStates.waterProperties.WaterWaveSpeed
        end)
    end
    
    -- Restore Lighting
    if FPSBooster.OriginalStates.lighting.GlobalShadows ~= nil then
        Lighting.GlobalShadows = FPSBooster.OriginalStates.lighting.GlobalShadows
        Lighting.FogEnd = FPSBooster.OriginalStates.lighting.FogEnd
        Lighting.FogStart = FPSBooster.OriginalStates.lighting.FogStart
    end
    
    -- Restore Post-Processing
    for effect, state in pairs(FPSBooster.OriginalStates.effects) do
        if effect and effect.Parent then
            effect.Enabled = state
        end
    end
    
    -- Restore quality
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    
    -- Disconnect hook
    if FPSBooster.NewObjectConnection then
        FPSBooster.NewObjectConnection:Disconnect()
        FPSBooster.NewObjectConnection = nil
    end
    
    -- Clear states
    FPSBooster.OriginalStates = {
        reflectance = {},
        transparency = {},
        lighting = {},
        effects = {},
        waterProperties = {}
    }
    
    return true, "FPS Booster disabled"
end

-- ==============================================================
--                 3D RENDERING CONTROL SECTION
-- ==============================================================

local Render3D = {
    Enabled = false,
    RenderConnection = nil,
    ScreenOverlay = nil,
    CurrentMode = nil -- "white" or "black"
}

-- Create screen overlay
local function createScreenOverlay(mode)
    -- Remove existing overlay
    if Render3D.ScreenOverlay then
        pcall(function()
            Render3D.ScreenOverlay:Destroy()
        end)
        Render3D.ScreenOverlay = nil
    end
    
    local success, overlay = pcall(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        if not PlayerGui then
            error("PlayerGui not found")
        end
        
        -- Create ScreenGui
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "Render3D_Overlay"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 999998
        ScreenGui.IgnoreGuiInset = true
        
        -- Create overlay frame
        local Overlay = Instance.new("Frame")
        Overlay.Name = "Overlay"
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.Position = UDim2.new(0, 0, 0, 0)
        Overlay.BorderSizePixel = 0
        Overlay.BackgroundTransparency = 0
        
        -- Set color
        if mode == "black" then
            Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        else
            Overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        Overlay.Parent = ScreenGui
        ScreenGui.Parent = PlayerGui
        
        Render3D.ScreenOverlay = ScreenGui
        Render3D.CurrentMode = mode
        
        return ScreenGui
    end)
    
    if not success then
        warn("[Render3D] Failed to create overlay:", overlay)
        return nil
    end
    
    return overlay
end

-- Remove screen overlay
local function removeScreenOverlay()
    if Render3D.ScreenOverlay then
        pcall(function()
            Render3D.ScreenOverlay:Destroy()
        end)
        Render3D.ScreenOverlay = nil
    end
end

-- Enable 3D rendering disable (White Screen)
function Render3D.EnableWhite()
    if Render3D.Enabled and Render3D.CurrentMode == "white" then
        return false, "Already enabled (white)"
    end
    
    -- If black is active, just change mode
    if Render3D.Enabled and Render3D.CurrentMode == "black" then
        createScreenOverlay("white")
        return true, "Changed to white screen"
    end
    
    -- Fresh enable
    local success, err = pcall(function()
        Render3D.RenderConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                RunService:Set3dRenderingEnabled(false)
            end)
        end)
        
        Render3D.Enabled = true
        createScreenOverlay("white")
    end)
    
    if not success then
        return false, "Failed: " .. tostring(err)
    end
    
    return true, "White screen enabled"
end

-- Enable 3D rendering disable (Black Screen)
function Render3D.EnableBlack()
    if Render3D.Enabled and Render3D.CurrentMode == "black" then
        return false, "Already enabled (black)"
    end
    
    -- If white is active, just change mode
    if Render3D.Enabled and Render3D.CurrentMode == "white" then
        createScreenOverlay("black")
        return true, "Changed to black screen"
    end
    
    -- Fresh enable
    local success, err = pcall(function()
        Render3D.RenderConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                RunService:Set3dRenderingEnabled(false)
            end)
        end)
        
        Render3D.Enabled = true
        createScreenOverlay("black")
    end)
    
    if not success then
        return false, "Failed: " .. tostring(err)
    end
    
    return true, "Black screen enabled"
end

-- Disable 3D rendering control
function Render3D.Disable()
    if not Render3D.Enabled then
        return false, "Already disabled"
    end
    
    local success, err = pcall(function()
        -- Disconnect render loop
        if Render3D.RenderConnection then
            Render3D.RenderConnection:Disconnect()
            Render3D.RenderConnection = nil
        end
        
        -- Re-enable rendering
        RunService:Set3dRenderingEnabled(true)
        
        Render3D.Enabled = false
        
        -- Remove overlay
        removeScreenOverlay()
        Render3D.CurrentMode = nil
    end)
    
    if not success then
        return false, "Failed: " .. tostring(err)
    end
    
    return true, "3D rendering restored"
end

-- Handle respawn
local function setupRespawnHandler()
    if LocalPlayer then
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            
            -- Restore render state if was enabled
            if Render3D.Enabled then
                pcall(function()
                    RunService:Set3dRenderingEnabled(false)
                end)
                
                -- Recreate overlay
                if Render3D.CurrentMode then
                    createScreenOverlay(Render3D.CurrentMode)
                end
            end
        end)
    end
end

-- ==============================================================
--                    PUBLIC API EXPORTS
-- ==============================================================

-- FPS Booster API
PerformanceModule.FPSBooster = {
    Enable = FPSBooster.Enable,
    Disable = FPSBooster.Disable,
    IsEnabled = function() return FPSBooster.Enabled end
}

-- 3D Rendering Control API
PerformanceModule.Render3D = {
    EnableWhite = Render3D.EnableWhite,
    EnableBlack = Render3D.EnableBlack,
    Disable = Render3D.Disable,
    IsEnabled = function() return Render3D.Enabled end,
    GetMode = function() return Render3D.CurrentMode end
}

-- Utility function to check if any feature is active
function PerformanceModule.IsAnyActive()
    return FPSBooster.Enabled or Render3D.Enabled
end

-- Get status of all features
function PerformanceModule.GetStatus()
    return {
        fpsBooster = FPSBooster.Enabled,
        render3D = Render3D.Enabled,
        render3DMode = Render3D.CurrentMode
    }
end

-- ==============================================================
--                    INITIALIZATION
-- ==============================================================

-- Setup respawn handler
setupRespawnHandler()

-- Return module
return PerformanceModule
