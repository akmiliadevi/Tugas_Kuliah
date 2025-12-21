-- =====================================================
-- DISABLE 3D RENDERING MODULE (CLEAN VERSION)
-- For integration with Lynx GUI v2.3
-- =====================================================

local DisableRendering = {}

-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- CONFIGURATION
-- =====================================================
DisableRendering.Settings = {
    ShowFPSCounter = true,
    FPSUpdateRate = 0.5,
    DefaultScreenMode = "white", -- "white" or "black"
    AutoPersist = true -- Keep active after respawn
}

-- =====================================================
-- STATE VARIABLES
-- =====================================================
local State = {
    RenderingDisabled = false,
    RenderConnection = nil,
    FPSConnection = nil,
    FPSGui = nil,
    FPSLabel = nil,
    ScreenOverlay = nil,
    CurrentScreenMode = DisableRendering.Settings.DefaultScreenMode
}

-- =====================================================
-- SCREEN OVERLAY FUNCTIONS
-- =====================================================
local function createScreenOverlay(mode)
    -- Remove existing overlay
    if State.ScreenOverlay then
        pcall(function()
            State.ScreenOverlay:Destroy()
        end)
        State.ScreenOverlay = nil
    end
    
    local success, result = pcall(function()
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
        
        -- Set color based on mode
        if mode == "black" then
            Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        else
            Overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        Overlay.Parent = ScreenGui
        
        ScreenGui.Parent = PlayerGui
        
        State.ScreenOverlay = ScreenGui
        State.CurrentScreenMode = mode
        
        return ScreenGui
    end)
    
    if not success then
        warn("[DisableRendering] Failed to create overlay:", result)
        return nil
    end
    
    return result
end

local function removeScreenOverlay()
    if State.ScreenOverlay then
        pcall(function()
            State.ScreenOverlay:Destroy()
        end)
        State.ScreenOverlay = nil
    end
end

-- =====================================================
-- FPS COUNTER FUNCTIONS
-- =====================================================
local function createFPSCounter()
    if State.FPSGui then 
        return State.FPSLabel 
    end
    
    local success, result = pcall(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        if not PlayerGui then
            error("PlayerGui not found")
        end
        
        -- Create ScreenGui
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "FPSCounter_Render3D"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 999999
        
        -- Create Frame
        local Frame = Instance.new("Frame")
        Frame.Name = "FPSFrame"
        Frame.Size = UDim2.new(0, 120, 0, 40)
        Frame.Position = UDim2.new(1, -130, 0, 10)
        Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Frame.BackgroundTransparency = 0.3
        Frame.BorderSizePixel = 0
        Frame.Parent = ScreenGui
        
        -- Add corner
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = Frame
        
        -- Create Label
        local Label = Instance.new("TextLabel")
        Label.Name = "FPSLabel"
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 16
        Label.TextColor3 = Color3.fromRGB(0, 255, 0)
        Label.Text = "FPS: --"
        Label.TextStrokeTransparency = 0.5
        Label.Parent = Frame
        
        ScreenGui.Parent = PlayerGui
        
        State.FPSGui = ScreenGui
        State.FPSLabel = Label
        
        return Label
    end)
    
    if not success then
        warn("[DisableRendering] Failed to create FPS counter:", result)
        return nil
    end
    
    return result
end

local function startFPSCounter()
    if State.FPSConnection then return end
    
    local label = createFPSCounter()
    if not label then return end
    
    local lastUpdate = tick()
    local frames = 0
    
    State.FPSConnection = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        
        if now - lastUpdate >= DisableRendering.Settings.FPSUpdateRate then
            local fps = math.floor(frames / (now - lastUpdate))
            
            -- Update label safely
            pcall(function()
                label.Text = string.format("FPS: %d", fps)
                
                -- Color based on FPS
                if fps >= 50 then
                    label.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif fps >= 30 then
                    label.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    label.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
            
            frames = 0
            lastUpdate = now
        end
    end)
end

local function stopFPSCounter()
    if State.FPSConnection then
        State.FPSConnection:Disconnect()
        State.FPSConnection = nil
    end
    
    if State.FPSGui then
        pcall(function()
            State.FPSGui:Destroy()
        end)
        State.FPSGui = nil
        State.FPSLabel = nil
    end
end

-- =====================================================
-- PUBLIC API FUNCTIONS
-- =====================================================

-- Start disable rendering
function DisableRendering.Start()
    if State.RenderingDisabled then
        return false, "Already disabled"
    end
    
    local success, err = pcall(function()
        -- Disable 3D rendering
        State.RenderConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                RunService:Set3dRenderingEnabled(false)
            end)
        end)
        
        State.RenderingDisabled = true
        
        -- Create screen overlay
        createScreenOverlay(State.CurrentScreenMode)
        
        -- Start FPS counter if enabled
        if DisableRendering.Settings.ShowFPSCounter then
            task.wait(0.1)
            startFPSCounter()
        end
    end)
    
    if not success then
        warn("[DisableRendering] Failed to start:", err)
        return false, "Failed to start"
    end
    
    return true, "Rendering disabled"
end

-- Stop disable rendering
function DisableRendering.Stop()
    if not State.RenderingDisabled then
        return false, "Already enabled"
    end
    
    local success, err = pcall(function()
        -- Disconnect render loop
        if State.RenderConnection then
            State.RenderConnection:Disconnect()
            State.RenderConnection = nil
        end
        
        -- Re-enable rendering
        RunService:Set3dRenderingEnabled(true)
        
        State.RenderingDisabled = false
        
        -- Remove screen overlay
        removeScreenOverlay()
        
        -- Stop FPS counter
        stopFPSCounter()
    end)
    
    if not success then
        warn("[DisableRendering] Failed to stop:", err)
        return false, "Failed to stop"
    end
    
    return true, "Rendering enabled"
end

-- Toggle rendering
function DisableRendering.Toggle()
    if State.RenderingDisabled then
        return DisableRendering.Stop()
    else
        return DisableRendering.Start()
    end
end

-- Change screen mode
function DisableRendering.SetScreenMode(mode)
    if mode ~= "black" and mode ~= "white" then
        return false, "Invalid mode (use 'black' or 'white')"
    end
    
    State.CurrentScreenMode = mode
    
    -- If already running, recreate overlay
    if State.RenderingDisabled then
        createScreenOverlay(mode)
    end
    
    return true, "Screen mode set to " .. mode
end

-- Get current status
function DisableRendering.IsDisabled()
    return State.RenderingDisabled
end

function DisableRendering.GetScreenMode()
    return State.CurrentScreenMode
end

-- Toggle FPS counter
function DisableRendering.ToggleFPS(enabled)
    DisableRendering.Settings.ShowFPSCounter = enabled
    
    if enabled and State.RenderingDisabled then
        startFPSCounter()
    else
        stopFPSCounter()
    end
    
    return true, "FPS counter " .. (enabled and "enabled" or "disabled")
end

-- =====================================================
-- AUTO-PERSIST ON RESPAWN
-- =====================================================
if DisableRendering.Settings.AutoPersist then
    LocalPlayer.CharacterAdded:Connect(function()
        if State.RenderingDisabled then
            task.wait(0.5)
            pcall(function()
                RunService:Set3dRenderingEnabled(false)
            end)
            
            -- Recreate overlay
            createScreenOverlay(State.CurrentScreenMode)
            
            -- Recreate FPS counter if enabled
            if DisableRendering.Settings.ShowFPSCounter then
                task.wait(0.1)
                startFPSCounter()
            end
        end
    end)
end

-- =====================================================
-- CLEANUP FUNCTION
-- =====================================================
function DisableRendering.Cleanup()
    -- Enable rendering if disabled
    if State.RenderingDisabled then
        pcall(function()
            RunService:Set3dRenderingEnabled(true)
        end)
    end
    
    -- Disconnect all connections
    if State.RenderConnection then
        State.RenderConnection:Disconnect()
    end
    
    -- Remove overlays
    removeScreenOverlay()
    
    -- Stop FPS counter
    stopFPSCounter()
end

return DisableRendering
