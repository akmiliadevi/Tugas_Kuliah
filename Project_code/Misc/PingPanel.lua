local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MonitorModule = {}

local lastFrameTime = tick()
local fpsHistory = {}
local maxFPSHistory = 20
local updateConnection
local pingUpdateConnection

local function createMonitorGUI()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LynxPanelMonitor"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 10
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 250, 0, 100)
    container.Position = UDim2.new(0, 100, 0, 300)
    container.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    container.BorderSizePixel = 0
    container.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(60, 70, 90)
    containerStroke.Thickness = 2
    containerStroke.Parent = container
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local logoIcon = Instance.new("ImageLabel")
    logoIcon.Name = "LogoIcon"
    logoIcon.Size = UDim2.new(0, 30, 0, 30)
    logoIcon.Position = UDim2.new(0, 10, 0, 5)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image = "rbxassetid://118176705805619" -- Logo Lynx
    logoIcon.ScaleType = Enum.ScaleType.Fit
    logoIcon.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 45, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "LYNX PANEL"
    titleLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, -20, 0, 1)
    separator.Position = UDim2.new(0, 10, 0, 40)
    separator.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    separator.BorderSizePixel = 0
    separator.Parent = container
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = container
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingLabel"
    pingLabel.Size = UDim2.new(1, 0, 0, 20)
    pingLabel.Position = UDim2.new(0, 0, 0, 5)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 0 ms"
    pingLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    pingLabel.TextSize = 15
    pingLabel.Font = Enum.Font.GothamMedium
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Parent = content

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(1, 0, 0, 20)
    fpsLabel.Position = UDim2.new(0, 0, 0, 30)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    fpsLabel.TextSize = 15
    fpsLabel.Font = Enum.Font.GothamMedium
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = content

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
        PingLabel = pingLabel,
        FPSLabel = fpsLabel,
        LogoIcon = logoIcon
    }
end

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

local function updatePingColor(pingLabel, value)
    local ping = tonumber(value)
    if ping <= 50 then
        pingLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    elseif ping <= 100 then
        pingLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    elseif ping <= 150 then
        pingLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
    else
        pingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

local function updateFPSColor(fpsLabel, value)
    local fps = tonumber(value)
    if fps >= 55 then
        fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    elseif fps >= 40 then
        fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    elseif fps >= 25 then
        fpsLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
    else
        fpsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

function MonitorModule:Show()
    if self.GUI then
        self.GUI.ScreenGui.Enabled = true
        return
    end
    
    print("🚀 Starting Lynx Panel Monitor...")
    
    self.GUI = createMonitorGUI()

    updateConnection = RunService.RenderStepped:Connect(function()
        if not self.GUI or not self.GUI.ScreenGui or not self.GUI.ScreenGui.Parent then
            if updateConnection then
                updateConnection:Disconnect()
            end
            return
        end
        
        local fps = getFPS()
        self.GUI.FPSLabel.Text = "FPS: " .. tostring(fps)
        updateFPSColor(self.GUI.FPSLabel, fps)
    end)
    
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
            self.GUI.PingLabel.Text = "Ping: " .. ping .. " ms"
            updatePingColor(self.GUI.PingLabel, ping)
            lastPingUpdate = currentTime
        end
    end)
    
    print("✅ Lynx Panel Monitor loaded!")
end

function MonitorModule:Hide()
    if self.GUI and self.GUI.ScreenGui then
        self.GUI.ScreenGui.Enabled = false
    end
end

function MonitorModule:Toggle()
    if self.GUI and self.GUI.ScreenGui then
        self.GUI.ScreenGui.Enabled = not self.GUI.ScreenGui.Enabled
    else
        self:Show()
    end
end

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
    print("✅ Lynx Monitor destroyed")
end

function MonitorModule:SetLogo(imageId)
    if self.GUI and self.GUI.LogoIcon then
        self.GUI.LogoIcon.Image = imageId
    end
end

function MonitorModule:SetPosition(x, y)
    if self.GUI and self.GUI.Container then
        self.GUI.Container.Position = UDim2.new(0, x, 0, y)
    end
end

return MonitorModule
