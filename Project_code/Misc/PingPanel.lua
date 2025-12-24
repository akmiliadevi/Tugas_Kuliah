-- Ping & FPS Monitor Panel
-- Script untuk monitoring ping dan FPS real-time
-- Horizontal layout seperti game fishing

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Module untuk dipanggil dari GUI utama
local MonitorModule = {}

-- Variables untuk FPS calculation
local lastFrameTime = tick()
local fpsHistory = {}
local maxFPSHistory = 20
local updateConnection
local pingUpdateConnection

-- Fungsi untuk membuat GUI
local function createMonitorGUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PingFPSMonitor"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 10
    
    -- Container Frame (Horizontal)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 470, 0, 50)
    container.Position = UDim2.new(0, 100, 0, 120) -- Top left area
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    -- Ping Panel
    local pingPanel = Instance.new("Frame")
    pingPanel.Name = "PingPanel"
    pingPanel.Size = UDim2.new(0, 225, 1, 0)
    pingPanel.Position = UDim2.new(0, 0, 0, 0)
    pingPanel.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
    pingPanel.BorderSizePixel = 0
    pingPanel.Parent = container
    
    local pingCorner = Instance.new("UICorner")
    pingCorner.CornerRadius = UDim.new(0, 8)
    pingCorner.Parent = pingPanel
    
    -- Ping Icon Container
    local pingIconFrame = Instance.new("Frame")
    pingIconFrame.Name = "IconFrame"
    pingIconFrame.Size = UDim2.new(0, 50, 1, 0)
    pingIconFrame.BackgroundTransparency = 1
    pingIconFrame.Parent = pingPanel
    
    -- Ping Icon (ImageLabel untuk custom icon)
    local pingIcon = Instance.new("ImageLabel")
    pingIcon.Name = "PingIcon"
    pingIcon.Size = UDim2.new(0, 32, 0, 32)
    pingIcon.Position = UDim2.new(0.5, -16, 0.5, -16)
    pingIcon.BackgroundTransparency = 1
    pingIcon.Image = "rbxassetid://0" -- Placeholder, bisa diganti
    pingIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    pingIcon.Parent = pingIconFrame
    
    -- Ping Content
    local pingContent = Instance.new("Frame")
    pingContent.Name = "Content"
    pingContent.Size = UDim2.new(1, -55, 1, 0)
    pingContent.Position = UDim2.new(0, 55, 0, 0)
    pingContent.BackgroundTransparency = 1
    pingContent.Parent = pingPanel
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "Label"
    pingLabel.Size = UDim2.new(1, -10, 0, 18)
    pingLabel.Position = UDim2.new(0, 0, 0, 6)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "NetworkPing"
    pingLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    pingLabel.TextSize = 13
    pingLabel.Font = Enum.Font.GothamMedium
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Parent = pingContent
    
    local pingValue = Instance.new("TextLabel")
    pingValue.Name = "Value"
    pingValue.Size = UDim2.new(1, -10, 0, 22)
    pingValue.Position = UDim2.new(0, 0, 0, 22)
    pingValue.BackgroundTransparency = 1
    pingValue.Text = "0 ms"
    pingValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    pingValue.TextSize = 18
    pingValue.Font = Enum.Font.GothamBold
    pingValue.TextXAlignment = Enum.TextXAlignment.Left
    pingValue.Parent = pingContent
    
    -- FPS Panel
    local fpsPanel = Instance.new("Frame")
    fpsPanel.Name = "FPSPanel"
    fpsPanel.Size = UDim2.new(0, 225, 1, 0)
    fpsPanel.Position = UDim2.new(0, 235, 0, 0)
    fpsPanel.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
    fpsPanel.BorderSizePixel = 0
    fpsPanel.Parent = container
    
    local fpsCorner = Instance.new("UICorner")
    fpsCorner.CornerRadius = UDim.new(0, 8)
    fpsCorner.Parent = fpsPanel
    
    -- FPS Icon Container
    local fpsIconFrame = Instance.new("Frame")
    fpsIconFrame.Name = "IconFrame"
    fpsIconFrame.Size = UDim2.new(0, 50, 1, 0)
    fpsIconFrame.BackgroundTransparency = 1
    fpsIconFrame.Parent = fpsPanel
    
    -- FPS Icon (ImageLabel untuk custom icon)
    local fpsIcon = Instance.new("ImageLabel")
    fpsIcon.Name = "FPSIcon"
    fpsIcon.Size = UDim2.new(0, 32, 0, 32)
    fpsIcon.Position = UDim2.new(0.5, -16, 0.5, -16)
    fpsIcon.BackgroundTransparency = 1
    fpsIcon.Image = "rbxassetid://0" -- Placeholder, bisa diganti
    fpsIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    fpsIcon.Parent = fpsIconFrame
    
    -- FPS Content
    local fpsContent = Instance.new("Frame")
    fpsContent.Name = "Content"
    fpsContent.Size = UDim2.new(1, -55, 1, 0)
    fpsContent.Position = UDim2.new(0, 55, 0, 0)
    fpsContent.BackgroundTransparency = 1
    fpsContent.Parent = fpsPanel
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "Label"
    fpsLabel.Size = UDim2.new(1, -10, 0, 18)
    fpsLabel.Position = UDim2.new(0, 0, 0, 6)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS"
    fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    fpsLabel.TextSize = 13
    fpsLabel.Font = Enum.Font.GothamMedium
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = fpsContent
    
    local fpsValue = Instance.new("TextLabel")
    fpsValue.Name = "Value"
    fpsValue.Size = UDim2.new(1, -10, 0, 22)
    fpsValue.Position = UDim2.new(0, 0, 0, 22)
    fpsValue.BackgroundTransparency = 1
    fpsValue.Text = "60"
    fpsValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    fpsValue.TextSize = 18
    fpsValue.Font = Enum.Font.GothamBold
    fpsValue.TextXAlignment = Enum.TextXAlignment.Left
    fpsValue.Parent = fpsContent
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    local UserInputService = game:GetService("UserInputService")
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    container.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    screenGui.Parent = playerGui
    
    return {
        ScreenGui = screenGui,
        Container = container,
        PingValue = pingValue,
        FPSValue = fpsValue,
        PingIcon = pingIcon,
        FPSIcon = fpsIcon
    }
end

-- Fungsi untuk mendapatkan ping
local function getPing()
    local ping = 0
    pcall(function()
        local networkStats = Stats:FindFirstChild("Network")
        if networkStats then
            local serverStatsItem = networkStats:FindFirstChild("ServerStatsItem")
            if serverStatsItem then
                local pingStr = serverStatsItem["Data Ping"]:GetValueString()
                ping = tonumber(pingStr:match("%d+")) or 0
            end
        end
        
        if ping == 0 then
            ping = math.floor(player:GetNetworkPing() * 1000)
        end
    end)
    return ping
end

-- Fungsi untuk mendapatkan FPS real-time
local function getFPS()
    local currentTime = tick()
    local deltaTime = currentTime - lastFrameTime
    lastFrameTime = currentTime
    
    local currentFPS = 0
    if deltaTime > 0 then
        currentFPS = 1 / deltaTime
    end
    
    table.insert(fpsHistory, currentFPS)
    
    if #fpsHistory > maxFPSHistory then
        table.remove(fpsHistory, 1)
    end
    
    local sum = 0
    for _, fps in ipairs(fpsHistory) do
        sum = sum + fps
    end
    
    local averageFPS = sum / #fpsHistory
    return math.floor(math.clamp(averageFPS, 0, 240))
end

-- Fungsi untuk update warna berdasarkan nilai
local function updatePingColor(pingValue, value)
    local ping = tonumber(value)
    if ping <= 50 then
        pingValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif ping <= 100 then
        pingValue.TextColor3 = Color3.fromRGB(255, 255, 100)
    elseif ping <= 150 then
        pingValue.TextColor3 = Color3.fromRGB(255, 180, 100)
    else
        pingValue.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

local function updateFPSColor(fpsValue, value)
    local fps = tonumber(value)
    if fps >= 55 then
        fpsValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif fps >= 40 then
        fpsValue.TextColor3 = Color3.fromRGB(255, 255, 100)
    elseif fps >= 25 then
        fpsValue.TextColor3 = Color3.fromRGB(255, 180, 100)
    else
        fpsValue.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Fungsi untuk show panel
function MonitorModule:Show()
    if self.GUI then
        self.GUI.ScreenGui.Enabled = true
        return
    end
    
    print("🚀 Starting Ping & FPS Monitor...")
    
    self.GUI = createMonitorGUI()
    
    -- Update loop untuk FPS (real-time)
    updateConnection = RunService.RenderStepped:Connect(function()
        if not self.GUI or not self.GUI.ScreenGui or not self.GUI.ScreenGui.Parent then
            if updateConnection then
                updateConnection:Disconnect()
            end
            return
        end
        
        local fps = getFPS()
        self.GUI.FPSValue.Text = tostring(fps)
        updateFPSColor(self.GUI.FPSValue, fps)
    end)
    
    -- Update ping dengan interval (setiap 0.5 detik)
    local lastPingUpdate = 0
    pingUpdateConnection = RunService.Heartbeat:Connect(function()
        if not self.GUI or not self.GUI.ScreenGui or not self.GUI.ScreenGui.Parent then
            if pingUpdateConnection then
                pingUpdateConnection:Disconnect()
            end
            return
        end
        
        local currentTime = tick()
        if currentTime - lastPingUpdate >= 0.5 then
            local ping = getPing()
            self.GUI.PingValue.Text = ping .. " ms"
            updatePingColor(self.GUI.PingValue, ping)
            lastPingUpdate = currentTime
        end
    end)
    
    print("✅ Ping & FPS Monitor loaded!")
end

-- Fungsi untuk hide panel
function MonitorModule:Hide()
    if self.GUI and self.GUI.ScreenGui then
        self.GUI.ScreenGui.Enabled = false
    end
end

-- Fungsi untuk toggle panel
function MonitorModule:Toggle()
    if self.GUI and self.GUI.ScreenGui then
        self.GUI.ScreenGui.Enabled = not self.GUI.ScreenGui.Enabled
    else
        self:Show()
    end
end

-- Fungsi untuk destroy panel
function MonitorModule:Destroy()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    
    if pingUpdateConnection then
        pingUpdateConnection:Disconnect()
        pingUpdateConnection = nil
    end
    
    if self.GUI and self.GUI.ScreenGui then
        self.GUI.ScreenGui:Destroy()
        self.GUI = nil
    end
    
    fpsHistory = {}
    print("✅ Monitor destroyed")
end

-- Fungsi untuk set custom icon
function MonitorModule:SetPingIcon(imageId)
    if self.GUI and self.GUI.PingIcon then
        self.GUI.PingIcon.Image = imageId
    end
end

function MonitorModule:SetFPSIcon(imageId)
    if self.GUI and self.GUI.FPSIcon then
        self.GUI.FPSIcon.Image = imageId
    end
end

-- Fungsi untuk set posisi
function MonitorModule:SetPosition(x, y)
    if self.GUI and self.GUI.Container then
        self.GUI.Container.Position = UDim2.new(0, x, 0, y)
    end
end

return MonitorModule
