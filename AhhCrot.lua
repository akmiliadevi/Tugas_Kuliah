-- LynxGUI v2.3 Optimized - Part 1/8
-- Core Setup & Module Loading System

repeat task.wait() until game:IsLoaded()

-- ============================================
-- ANTI-DUPLICATION
-- ============================================
local GUI_IDENTIFIER = "LynxGUI_Galaxy_v2.3"

local function CloseExistingGUI()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local existingGUI = playerGui:FindFirstChild(GUI_IDENTIFIER)
    
    if existingGUI then
        pcall(function()
            local mainFrame = existingGUI:FindFirstChild("Frame")
            if mainFrame then
                game:GetService("TweenService"):Create(
                    mainFrame, 
                    TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                    {Size = UDim2.new(0, 0, 0, 0)}
                ):Play()
            end
        end)
        task.wait(0.35)
        existingGUI:Destroy()
        task.wait(0.2)
    end
end

CloseExistingGUI()

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

repeat task.wait() until localPlayer:FindFirstChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do 
        inst[k] = v 
    end
    return inst
end

local function SendNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
            Icon = "rbxassetid://118176705805619"
        })
    end)
end

-- ============================================
-- LOADING NOTIFICATION
-- ============================================
local LoadingNotification = {
    Active = false,
    NotificationId = nil,
    StatusLabel = nil,
    ProgressBar = nil,
    ProgressBg = nil,
    TitleLabel = nil
}

function LoadingNotification.Create()
    if LoadingNotification.Active then return end
    LoadingNotification.Active = true
    
    pcall(function()
        local notifGui = new("ScreenGui", {
            Name = "LynxLoadingNotification",
            Parent = localPlayer.PlayerGui,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999999999
        })
        
        local notifFrame = new("Frame", {
            Parent = notifGui,
            Size = UDim2.new(0, 340, 0, 100),
            Position = UDim2.new(1, -360, 1, -120),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0
        })
        new("UICorner", {Parent = notifFrame, CornerRadius = UDim.new(0, 16)})
        
        new("ImageLabel", {
            Parent = notifFrame,
            Size = UDim2.new(0, 45, 0, 45),
            Position = UDim2.new(0, 18, 0, 12),
            BackgroundTransparency = 1,
            Image = "rbxassetid://118176705805619",
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 3
        })
        
        local titleLabel = new("TextLabel", {
            Parent = notifFrame,
            Size = UDim2.new(1, -80, 0, 24),
            Position = UDim2.new(0, 70, 0, 12),
            BackgroundTransparency = 1,
            Text = "Lynx Script Loading",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3
        })
        
        local statusLabel = new("TextLabel", {
            Parent = notifFrame,
            Size = UDim2.new(1, -80, 0, 18),
            Position = UDim2.new(0, 70, 0, 40),
            BackgroundTransparency = 1,
            Text = "Initializing...",
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3
        })
        
        local progressBg = new("Frame", {
            Parent = notifFrame,
            Size = UDim2.new(1, -36, 0, 4),
            Position = UDim2.new(0, 18, 1, -16),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,
            ZIndex = 2
        })
        new("UICorner", {Parent = progressBg, CornerRadius = UDim.new(1, 0)})
        
        local progressBar = new("Frame", {
            Parent = progressBg,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 3
        })
        new("UICorner", {Parent = progressBar, CornerRadius = UDim.new(1, 0)})
        
        LoadingNotification.NotificationId = notifGui
        LoadingNotification.StatusLabel = statusLabel
        LoadingNotification.ProgressBar = progressBar
        LoadingNotification.ProgressBg = progressBg
        LoadingNotification.TitleLabel = titleLabel
        
        notifFrame.Position = UDim2.new(1, 20, 1, -120)
        TweenService:Create(notifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -360, 1, -120)
        }):Play()
    end)
end

function LoadingNotification.Update(loadedCount, totalCount, currentModule)
    if not LoadingNotification.Active then return end
    
    pcall(function()
        if LoadingNotification.StatusLabel then
            local percent = math.floor((loadedCount / totalCount) * 100)
            LoadingNotification.StatusLabel.Text = string.format("%d/%d (%d%%) - %s", 
                loadedCount, totalCount, percent, currentModule or "...")
        end
        
        if LoadingNotification.ProgressBar and LoadingNotification.ProgressBg then
            local targetWidth = (loadedCount / totalCount) * LoadingNotification.ProgressBg.AbsoluteSize.X
            TweenService:Create(LoadingNotification.ProgressBar, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
                Size = UDim2.new(0, targetWidth, 1, 0)
            }):Play()
        end
    end)
end

function LoadingNotification.Complete(success, loadedCount, totalCount)
    if not LoadingNotification.Active then return end
    
    pcall(function()
        if LoadingNotification.TitleLabel then
            LoadingNotification.TitleLabel.Text = success and "Lynx Ready!" or "Loading Complete"
        end
        
        if LoadingNotification.StatusLabel then
            LoadingNotification.StatusLabel.Text = success 
                and string.format("✓ %d modules loaded", loadedCount)
                or string.format("⚠ Loaded %d/%d", loadedCount, totalCount)
        end
        
        if LoadingNotification.ProgressBar then
            TweenService:Create(LoadingNotification.ProgressBar, TweenInfo.new(0.3), {
                BackgroundColor3 = success and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 159, 10)
            }):Play()
        end
        
        task.wait(2.5)
        if LoadingNotification.NotificationId then
            local frame = LoadingNotification.NotificationId:FindFirstChildOfClass("Frame")
            if frame then
                TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                    Position = UDim2.new(1, 20, 1, -120)
                }):Play()
            end
            task.wait(0.5)
            LoadingNotification.NotificationId:Destroy()
        end
        
        LoadingNotification.Active = false
    end)
end

-- ============================================
-- MODULE LOADING
-- ============================================
local Modules = {}
local ModuleStatus = {}
local totalModules = 0
local loadedModules = 0
local failedModules = {}

local CRITICAL_MODULES = {"HideStats", "Webhook", "Notify"}

LoadingNotification.Create()

-- Load SecurityLoader
local SecurityLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/akmiliadevi/Tugas_Kuliah/refs/heads/main/SecurityLoader.lua"))()

if not SecurityLoader then
    LoadingNotification.Complete(false, 0, 1)
    SendNotification("❌ ERROR", "SecurityLoader failed!", 10)
    return
end

LoadingNotification.Update(1, 32, "SecurityLoader")

-- Module List
local ModuleList = {
    "Notify", "HideStats", "Webhook", "PingFPSMonitor",
    "instant", "instant2", "blatantv1", "UltraBlatant", "blatantv2", "blatantv2fix", "AutoFavorite",
    "GoodPerfectionStable",
    "NoFishingAnimation", "LockPosition", "AutoEquipRod", "DisableCutscenes",
    "DisableExtras", "AutoTotem3X", "SkinAnimation", "WalkOnWater",
    "TeleportModule", "TeleportToPlayer", "SavedLocation", "EventTeleportDynamic",
    "AutoQuestModule", "AutoTemple", "TempleDataReader",
    "AutoSell", "AutoSellTimer", "MerchantSystem", "RemoteBuyer", "AutoBuyWeather",
    "FreecamModule", "UnlimitedZoomModule", "AntiAFK", "UnlockFPS", "FPSBooster", "DisableRendering"
}

totalModules = #ModuleList

if totalModules == 0 then
    LoadingNotification.Complete(false, 0, 0)
    SendNotification("❌ Error", "Module list empty!", 10)
    return
end

-- Module Loading with Retry
local MAX_RETRIES = 3
local RETRY_DELAY = 1

local function LoadModuleWithRetry(moduleName, retryCount)
    retryCount = retryCount or 0
    
    local success, result = pcall(function()
        return SecurityLoader.LoadModule(moduleName)
    end)
    
    if success and result then
        Modules[moduleName] = result
        ModuleStatus[moduleName] = "✅"
        loadedModules = loadedModules + 1
        return true
    else
        if retryCount < MAX_RETRIES then
            task.wait(RETRY_DELAY)
            return LoadModuleWithRetry(moduleName, retryCount + 1)
        else
            Modules[moduleName] = nil
            ModuleStatus[moduleName] = "❌"
            table.insert(failedModules, moduleName)
            return false
        end
    end
end

local function LoadAllModules()
    local startTime = tick()
    
    for _, moduleName in ipairs(ModuleList) do
        local isCritical = table.find(CRITICAL_MODULES, moduleName) ~= nil
        LoadingNotification.Update(loadedModules, totalModules, moduleName)
        
        local success = LoadModuleWithRetry(moduleName)
        
        if not success and isCritical then
            LoadingNotification.Complete(false, loadedModules, totalModules)
            SendNotification("❌ CRITICAL", moduleName .. " failed!", 10)
            error("CRITICAL MODULE FAILED: " .. moduleName)
            return false
        end
    end
    
    LoadingNotification.Complete(true, loadedModules, totalModules)
    return true
end

local loadSuccess = LoadAllModules()

if not loadSuccess then
    error("Module loading failed")
    return
end

local function GetModule(name)
    return Modules[name]
end

-- ============================================
-- COLOR PALETTE
-- ============================================
local colors = {
    primary = Color3.fromRGB(255, 140, 0),
    secondary = Color3.fromRGB(147, 112, 219),
    accent = Color3.fromRGB(186, 85, 211),
    success = Color3.fromRGB(34, 197, 94),
    warning = Color3.fromRGB(251, 191, 36),
    danger = Color3.fromRGB(239, 68, 68),
    
    bg1 = Color3.fromRGB(10, 10, 10),
    bg2 = Color3.fromRGB(18, 18, 18),
    bg3 = Color3.fromRGB(25, 25, 25),
    bg4 = Color3.fromRGB(35, 35, 35),
    
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(180, 180, 180),
    textDimmer = Color3.fromRGB(120, 120, 120),
    
    border = Color3.fromRGB(50, 50, 50),
}

-- ============================================
-- GUI STRUCTURE
-- ============================================
local windowSize = UDim2.new(0, 420, 0, 280)
local minWindowSize = Vector2.new(380, 250)
local maxWindowSize = Vector2.new(550, 400)
local sidebarWidth = 140

local gui = new("ScreenGui", {
    Name = GUI_IDENTIFIER,
    Parent = localPlayer.PlayerGui,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 2147483647
})

local function bringToFront()
    gui.DisplayOrder = 2147483647
end

-- Main Window
local win = new("Frame", {
    Parent = gui,
    Size = windowSize,
    Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
    BackgroundColor3 = colors.bg1,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ClipsDescendants = false,
    ZIndex = 3
})
new("UICorner", {Parent = win, CornerRadius = UDim.new(0, 12)})
new("UIStroke", {
    Parent = win,
    Color = colors.primary,
    Thickness = 1,
    Transparency = 0.9,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
})

-- Sidebar
local sidebar = new("Frame", {
    Parent = win,
    Size = UDim2.new(0, sidebarWidth, 1, -45),
    Position = UDim2.new(0, 0, 0, 45),
    BackgroundColor3 = colors.bg2,
    BackgroundTransparency = 0.75,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 4
})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 12)})

-- Header
local scriptHeader = new("Frame", {
    Parent = win,
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = colors.bg2,
    BackgroundTransparency = 0.75,
    BorderSizePixel = 0,
    ZIndex = 5
})
new("UICorner", {Parent = scriptHeader, CornerRadius = UDim.new(0, 12)})

-- Title
local titleLabel = new("TextLabel", {
    Parent = scriptHeader,
    Text = "LynX",
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextColor3 = colors.primary,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6
})

-- Subtitle
new("TextLabel", {
    Parent = scriptHeader,
    Text = "Free Not For Sale",
    Size = UDim2.new(0, 150, 1, 0),
    Position = UDim2.new(0, 105, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = colors.textDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 0.3,
    ZIndex = 6
})

-- Part 2/8: Navigation & UI Components

-- Minimize Button
local btnMinHeader = new("TextButton", {
    Parent = scriptHeader,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -38, 0.5, -15),
    BackgroundColor3 = colors.bg4,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Text = "─",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = colors.textDim,
    TextTransparency = 0.3,
    AutoButtonColor = false,
    ZIndex = 7
})
new("UICorner", {Parent = btnMinHeader, CornerRadius = UDim.new(0, 8)})

local btnStroke = new("UIStroke", {
    Parent = btnMinHeader,
    Color = colors.primary,
    Thickness = 0,
    Transparency = 0.8
})

btnMinHeader.MouseEnter:Connect(function()
    TweenService:Create(btnMinHeader, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundColor3 = colors.accent,
        BackgroundTransparency = 0.2,
        TextTransparency = 0
    }):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.25), {Thickness = 1.5, Transparency = 0.4}):Play()
end)

btnMinHeader.MouseLeave:Connect(function()
    TweenService:Create(btnMinHeader, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundColor3 = colors.bg4,
        BackgroundTransparency = 0.5,
        TextTransparency = 0.3
    }):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.25), {Thickness = 0, Transparency = 0.8}):Play()
end)

-- Navigation Container
local navContainer = new("ScrollingFrame", {
    Parent = sidebar,
    Size = UDim2.new(1, -8, 1, -12),
    Position = UDim2.new(0, 4, 0, 6),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = colors.primary,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ClipsDescendants = true,
    ZIndex = 5
})
new("UIListLayout", {
    Parent = navContainer,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
})

-- Content Area
local contentBg = new("Frame", {
    Parent = win,
    Size = UDim2.new(1, -(sidebarWidth + 10), 1, -52),
    Position = UDim2.new(0, sidebarWidth + 5, 0, 47),
    BackgroundColor3 = colors.bg2,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 4
})
new("UICorner", {Parent = contentBg, CornerRadius = UDim.new(0, 12)})

-- Top Bar
local topBar = new("Frame", {
    Parent = contentBg,
    Size = UDim2.new(1, -8, 0, 32),
    Position = UDim2.new(0, 4, 0, 4),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    ZIndex = 5
})
new("UICorner", {Parent = topBar, CornerRadius = UDim.new(0, 10)})

local pageTitle = new("TextLabel", {
    Parent = topBar,
    Text = "Main Dashboard",
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BackgroundTransparency = 1,
    TextColor3 = colors.text,
    TextTransparency = 0.2,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6
})

-- Resize Handle
local resizing = false
local resizeHandle = new("TextButton", {
    Parent = win,
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(1, -18, 1, -18),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    Text = "⋰",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = colors.textDim,
    TextTransparency = 0.4,
    AutoButtonColor = false,
    ZIndex = 100
})
new("UICorner", {Parent = resizeHandle, CornerRadius = UDim.new(0, 6)})

-- ============================================
-- PAGES
-- ============================================
local pages = {}
local currentPage = "Main"
local navButtons = {}

local function createPage(name)
    local page = new("ScrollingFrame", {
        Parent = contentBg,
        Size = UDim2.new(1, -16, 1, -44),
        Position = UDim2.new(0, 8, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.primary,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 5
    })
    new("UIListLayout", {Parent = page, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
    new("UIPadding", {Parent = page, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
    pages[name] = page
    return page
end

-- Create Pages
local mainPage = createPage("Main")
local teleportPage = createPage("Teleport")
local shopPage = createPage("Shop")
local webhookPage = createPage("Webhook")
local cameraViewPage = createPage("CameraView")
local settingsPage = createPage("Settings")
local infoPage = createPage("Info")
mainPage.Visible = true

-- Navigation Button
local function createNavButton(text, icon, page, order)
    local btn = new("TextButton", {
        Parent = navContainer,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = page == currentPage and colors.bg3 or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = page == currentPage and 0.7 or 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
        ZIndex = 6
    })
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 9)})
    
    local indicator = new("Frame", {
        Parent = btn,
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = colors.primary,
        BorderSizePixel = 0,
        Visible = page == currentPage,
        ZIndex = 7
    })
    new("UICorner", {Parent = indicator, CornerRadius = UDim.new(1, 0)})
    
    local iconLabel = new("TextLabel", {
        Parent = btn,
        Text = icon,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = page == currentPage and colors.primary or colors.textDim,
        TextTransparency = page == currentPage and 0 or 0.3,
        ZIndex = 7
    })
    
    local textLabel = new("TextLabel", {
        Parent = btn,
        Text = text,
        Size = UDim2.new(1, -45, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = page == currentPage and colors.text or colors.textDim,
        TextTransparency = page == currentPage and 0.1 or 0.4,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })
    
    btn.MouseEnter:Connect(function()
        if page ~= currentPage then
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.3), {TextTransparency = 0, TextColor3 = colors.primary}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.3), {TextTransparency = 0.2}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if page ~= currentPage then
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.3), {TextTransparency = 0.3, TextColor3 = colors.textDim}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.3), {TextTransparency = 0.4}):Play()
        end
    end)
    
    navButtons[page] = {btn = btn, icon = iconLabel, text = textLabel, indicator = indicator}
    return btn
end

-- Switch Page
local function switchPage(pageName, pageTitle_text)
    if currentPage == pageName then return end
    for _, page in pairs(pages) do page.Visible = false end
    
    for name, btnData in pairs(navButtons) do
        local isActive = name == pageName
        TweenService:Create(btnData.btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundColor3 = isActive and colors.bg3 or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = isActive and 0.7 or 1
        }):Play()
        btnData.indicator.Visible = isActive
        TweenService:Create(btnData.icon, TweenInfo.new(0.3), {
            TextColor3 = isActive and colors.primary or colors.textDim,
            TextTransparency = isActive and 0 or 0.3
        }):Play()
        TweenService:Create(btnData.text, TweenInfo.new(0.3), {
            TextColor3 = isActive and colors.text or colors.textDim,
            TextTransparency = isActive and 0.1 or 0.4
        }):Play()
    end
    
    pages[pageName].Visible = true
    pageTitle.Text = pageTitle_text
    currentPage = pageName
end

-- Create Nav Buttons
local btnMain = createNavButton("Dashboard", "🏠", "Main", 1)
local btnTeleport = createNavButton("Teleport", "🌍", "Teleport", 2)
local btnShop = createNavButton("Shop", "🛒", "Shop", 3)
local btnWebhook = createNavButton("Webhook", "🔗", "Webhook", 4)
local btnCameraView = createNavButton("Camera View", "📷", "CameraView", 5)
local btnSettings = createNavButton("Settings", "⚙️", "Settings", 6)
local btnInfo = createNavButton("About", "ℹ️", "Info", 7)

btnMain.MouseButton1Click:Connect(function() switchPage("Main", "Main Dashboard") end)
btnTeleport.MouseButton1Click:Connect(function() switchPage("Teleport", "Teleport System") end)
btnShop.MouseButton1Click:Connect(function() switchPage("Shop", "Shop Features") end)
btnWebhook.MouseButton1Click:Connect(function() switchPage("Webhook", "Webhook Page") end)
btnCameraView.MouseButton1Click:Connect(function() switchPage("CameraView", "Camera View Settings") end)
btnSettings.MouseButton1Click:Connect(function() switchPage("Settings", "Settings") end)
btnInfo.MouseButton1Click:Connect(function() switchPage("Info", "About Lynx") end)

-- ============================================
-- UI COMPONENTS
-- ============================================

-- Category
local function makeCategory(parent, title, icon)
    local categoryFrame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = colors.bg3,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
        ZIndex = 6
    })
    new("UICorner", {Parent = categoryFrame, CornerRadius = UDim.new(0, 6)})
    
    local header = new("TextButton", {
        Parent = categoryFrame,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 7
    })
    
    new("TextLabel", {
        Parent = header,
        Text = title,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })
    
    local arrow = new("TextLabel", {
        Parent = header,
        Text = "▼",
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = colors.primary,
        ZIndex = 8
    })
    
    local contentContainer = new("Frame", {
        Parent = categoryFrame,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 38),
        BackgroundTransparency = 1,
        Visible = false,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 7
    })
    new("UIListLayout", {Parent = contentContainer, Padding = UDim.new(0, 6)})
    new("UIPadding", {Parent = contentContainer, PaddingBottom = UDim.new(0, 8)})
    
    local isOpen = false
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        contentContainer.Visible = isOpen
        TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = isOpen and 180 or 0}):Play()
    end)
    
    return contentContainer
end

-- Toggle
local function makeToggle(parent, label, callback)
    local frame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 7
    })
    
    new("TextLabel", {
        Parent = frame,
        Text = label,
        Size = UDim2.new(0.68, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextColor3 = colors.text,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextWrapped = true,
        ZIndex = 8
    })
    
    local toggleBg = new("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -38, 0.5, -10),
        BackgroundColor3 = colors.bg4,
        BorderSizePixel = 0,
        ZIndex = 8
    })
    new("UICorner", {Parent = toggleBg, CornerRadius = UDim.new(1, 0)})
    
    local toggleCircle = new("Frame", {
        Parent = toggleBg,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = colors.textDim,
        BorderSizePixel = 0,
        ZIndex = 9
    })
    new("UICorner", {Parent = toggleCircle, CornerRadius = UDim.new(1, 0)})
    
    local btn = new("TextButton", {
        Parent = toggleBg,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 10
    })
    
    local on = false
    local isUpdating = false
    
    local function updateVisual(newState, animate)
        on = newState
        local duration = animate and 0.25 or 0
        
        TweenService:Create(toggleBg, TweenInfo.new(duration), {
            BackgroundColor3 = on and colors.primary or colors.bg4
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(duration, Enum.EasingStyle.Back), {
            Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = on and colors.text or colors.textDim
        }):Play()
    end
    
    btn.MouseButton1Click:Connect(function()
        if isUpdating then return end
        on = not on
        updateVisual(on, true)
        pcall(callback, on)
    end)
    
    return {
        toggle = btn,
        setOn = function(val, silent)
            if on == val then return end
            isUpdating = silent or false
            updateVisual(val, not silent)
            if not silent then pcall(callback, val) end
            isUpdating = false
        end,
        getState = function() return on end
    }
end

-- Input
local function makeInput(parent, label, defaultValue, callback)
    local frame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 7
    })
    
    new("TextLabel", {
        Parent = frame,
        Text = label,
        Size = UDim2.new(0.55, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        ZIndex = 8
    })
    
    local inputBg = new("Frame", {
        Parent = frame,
        Size = UDim2.new(0.42, 0, 0, 28),
        Position = UDim2.new(0.58, 0, 0.5, -14),
        BackgroundColor3 = colors.bg4,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 8
    })
    new("UICorner", {Parent = inputBg, CornerRadius = UDim.new(0, 6)})
    
    local inputBox = new("TextBox", {
        Parent = inputBg,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(defaultValue),
        PlaceholderText = "0.00",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = colors.text,
        PlaceholderColor3 = colors.textDimmer,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 9
    })
    
    inputBox.FocusLost:Connect(function()
        local value = tonumber(inputBox.Text)
        if value then pcall(callback, value) else inputBox.Text = tostring(defaultValue) end
    end)
    
    return inputBox
end

-- Button
local function makeButton(parent, label, callback)
    local btnFrame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = colors.primary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 8
    })
    new("UICorner", {Parent = btnFrame, CornerRadius = UDim.new(0, 6)})
    
    local button = new("TextButton", {
        Parent = btnFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = colors.text,
        AutoButtonColor = false,
        ZIndex = 9
    })
    
    button.MouseButton1Click:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 30)}):Play()
        task.wait(0.1)
        TweenService:Create(btnFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 32)}):Play()
        pcall(callback)
    end)
    
    return btnFrame
end

-- Part 3/8: Dropdown & Checkbox Components

-- Dropdown
local function makeDropdown(parent, title, icon, items, onSelect, uniqueId, defaultValue)
    local dropdownFrame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = colors.bg4,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 7,
        Name = uniqueId or "Dropdown"
    })
    new("UICorner", {Parent = dropdownFrame, CornerRadius = UDim.new(0, 6)})
    
    local header = new("TextButton", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, -12, 0, 36),
        Position = UDim2.new(0, 6, 0, 2),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 8
    })
    
    new("TextLabel", {
        Parent = header,
        Text = icon,
        Size = UDim2.new(0, 24, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = colors.primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9
    })
    
    new("TextLabel", {
        Parent = header,
        Text = title,
        Size = UDim2.new(1, -70, 0, 14),
        Position = UDim2.new(0, 26, 0, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9
    })
    
    local statusLabel = new("TextLabel", {
        Parent = header,
        Text = "None Selected",
        Size = UDim2.new(1, -70, 0, 12),
        Position = UDim2.new(0, 26, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = colors.textDimmer,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9
    })
    
    local arrow = new("TextLabel", {
        Parent = header,
        Text = "▼",
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = colors.primary,
        ZIndex = 9
    })
    
    local listContainer = new("ScrollingFrame", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, -12, 0, 0),
        Position = UDim2.new(0, 6, 0, 42),
        BackgroundTransparency = 1,
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = colors.primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10
    })
    new("UIListLayout", {Parent = listContainer, Padding = UDim.new(0, 4)})
    new("UIPadding", {Parent = listContainer, PaddingBottom = UDim.new(0, 8)})
    
    local isOpen = false
    local selectedItem = nil
    
    local function setSelectedItem(itemName, triggerCallback)
        selectedItem = itemName
        statusLabel.Text = "✓ " .. itemName
        statusLabel.TextColor3 = colors.success
        if triggerCallback then pcall(onSelect, itemName) end
    end
    
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listContainer.Visible = isOpen
        TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = isOpen and 180 or 0}):Play()
        if isOpen then listContainer.Size = UDim2.new(1, -12, 0, math.min(#items * 28, 140)) end
    end)
    
    for _, itemName in ipairs(items) do
        local itemBtn = new("TextButton", {
            Parent = listContainer,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = colors.bg4,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 11
        })
        new("UICorner", {Parent = itemBtn, CornerRadius = UDim.new(0, 5)})
        
        local btnLabel = new("TextLabel", {
            Parent = itemBtn,
            Text = itemName,
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 8,
            TextColor3 = colors.textDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12
        })
        
        itemBtn.MouseEnter:Connect(function()
            if selectedItem ~= itemName then
                TweenService:Create(itemBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
                TweenService:Create(btnLabel, TweenInfo.new(0.2), {TextColor3 = colors.text}):Play()
            end
        end)
        
        itemBtn.MouseLeave:Connect(function()
            if selectedItem ~= itemName then
                TweenService:Create(itemBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
                TweenService:Create(btnLabel, TweenInfo.new(0.2), {TextColor3 = colors.textDim}):Play()
            end
        end)
        
        itemBtn.MouseButton1Click:Connect(function()
            setSelectedItem(itemName, true)
            task.wait(0.1)
            isOpen = false
            listContainer.Visible = false
            TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = 0}):Play()
        end)
    end
    
    if defaultValue and table.find(items, defaultValue) then
        task.spawn(function()
            task.wait(0.1)
            setSelectedItem(defaultValue, false)
        end)
    end
    
    return dropdownFrame
end

-- Checkbox List
local function makeCheckboxList(parent, items, colorMap, onSelectionChange)
    local selectedItems = {}
    local checkboxRefs = {}
    
    local listContainer = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, #items * 33 + 10),
        BackgroundColor3 = colors.bg2,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    new("UICorner", {Parent = listContainer, CornerRadius = UDim.new(0, 8)})
    
    local function createCheckbox(itemName, yPos)
        local checkboxRow = new("Frame", {
            Parent = listContainer,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, yPos),
            BackgroundColor3 = colors.bg3,
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            ZIndex = 8
        })
        new("UICorner", {Parent = checkboxRow, CornerRadius = UDim.new(0, 6)})
        
        local checkbox = new("TextButton", {
            Parent = checkboxRow,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 8, 0, 3),
            BackgroundColor3 = colors.bg1,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 9
        })
        new("UICorner", {Parent = checkbox, CornerRadius = UDim.new(0, 4)})
        
        local itemColor = (colorMap and colorMap[itemName]) or colors.primary
        new("UIStroke", {
            Parent = checkbox,
            Color = itemColor,
            Thickness = 2,
            Transparency = 0.7
        })
        
        local checkmark = new("TextLabel", {
            Parent = checkbox,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "✓",
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = colors.text,
            Visible = false,
            ZIndex = 10
        })
        
        new("TextLabel", {
            Parent = checkboxRow,
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text = itemName,
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            TextColor3 = colors.text,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 9
        })
        
        local isSelected = false
        
        checkbox.MouseButton1Click:Connect(function()
            isSelected = not isSelected
            checkmark.Visible = isSelected
            
            if isSelected then
                if not table.find(selectedItems, itemName) then
                    table.insert(selectedItems, itemName)
                end
                TweenService:Create(checkbox, TweenInfo.new(0.25), {
                    BackgroundColor3 = itemColor,
                    BackgroundTransparency = 0.2
                }):Play()
            else
                local idx = table.find(selectedItems, itemName)
                if idx then table.remove(selectedItems, idx) end
                TweenService:Create(checkbox, TweenInfo.new(0.25), {
                    BackgroundColor3 = colors.bg1,
                    BackgroundTransparency = 0.4
                }):Play()
            end
            
            if onSelectionChange then pcall(onSelectionChange, selectedItems) end
        end)
        
        return {
            checkbox = checkbox,
            checkmark = checkmark,
            isSelected = function() return isSelected end,
            setSelected = function(val)
                if isSelected ~= val then checkbox.MouseButton1Click:Fire() end
            end
        }
    end
    
    for i, itemName in ipairs(items) do
        checkboxRefs[itemName] = createCheckbox(itemName, (i - 1) * 33 + 5)
    end
    
    return {
        GetSelected = function() return selectedItems end,
        SelectAll = function()
            for _, item in ipairs(items) do
                if checkboxRefs[item] and not checkboxRefs[item].isSelected() then
                    checkboxRefs[item].setSelected(true)
                end
            end
        end,
        ClearAll = function()
            for _, item in ipairs(items) do
                if checkboxRefs[item] and checkboxRefs[item].isSelected() then
                    checkboxRefs[item].setSelected(false)
                end
            end
        end,
        SelectSpecific = function(itemList)
            for _, item in ipairs(items) do
                if checkboxRefs[item] then
                    local shouldSelect = table.find(itemList, item) ~= nil
                    if checkboxRefs[item].isSelected() ~= shouldSelect then
                        checkboxRefs[item].setSelected(shouldSelect)
                    end
                end
            end
        end
    }
end

local function makeCheckboxDropdown(parent, title, items, colorMap, onChange)
    local selected = {}
    local refs = {}
    
    local frame = new("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = colors.bg4, BackgroundTransparency = 0.5, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 7})
    new("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 6)})
    
    local header = new("TextButton", {Parent = frame, Size = UDim2.new(1, -12, 0, 36), Position = UDim2.new(0, 6, 0, 2), BackgroundTransparency = 1, Text = "", ZIndex = 8})
    new("TextLabel", {Parent = header, Text = title, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = colors.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9})
    
    local status = new("TextLabel", {Parent = header, Text = "0", Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = colors.primary, ZIndex = 9})
    
    local list = new("ScrollingFrame", {Parent = frame, Size = UDim2.new(1, -12, 0, 0), Position = UDim2.new(0, 6, 0, 42), BackgroundTransparency = 1, Visible = false, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = colors.primary, BorderSizePixel = 0, ZIndex = 10})
    new("UIListLayout", {Parent = list, Padding = UDim.new(0, 3)})
    
    local open = false
    header.MouseButton1Click:Connect(function()
        open = not open
        list.Visible = open
        if open then list.Size = UDim2.new(1, -12, 0, math.min(#items * 24 + 6, 180)) end
    end)
    
    for _, name in ipairs(items) do
        local row = new("TextButton", {Parent = list, Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = colors.bg4, BackgroundTransparency = 0.7, BorderSizePixel = 0, Text = "", ZIndex = 11})
        new("UICorner", {Parent = row, CornerRadius = UDim.new(0, 4)})
        
        local check = new("TextLabel", {Parent = row, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 4, 0, 3), BackgroundColor3 = colors.bg1, BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = colors.text, ZIndex = 12})
        new("UICorner", {Parent = check, CornerRadius = UDim.new(0, 3)})
        if colorMap and colorMap[name] then new("UIStroke", {Parent = check, Color = colorMap[name], Thickness = 2, Transparency = 0.7}) end
        
        new("TextLabel", {Parent = row, Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 24, 0, 0), BackgroundTransparency = 1, Text = name, Font = Enum.Font.GothamBold, TextSize = 8, TextColor3 = colors.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12})
        
        local on = false
        
        -- Ekstrak logika toggle ke fungsi terpisah
        local function toggleCheckbox()
            on = not on
            check.Text = on and "✓" or ""
            if on then 
                table.insert(selected, name) 
            else 
                local idx = table.find(selected, name)
                if idx then table.remove(selected, idx) end
            end
            status.Text = tostring(#selected)
            pcall(onChange, selected)
        end
        
        row.MouseButton1Click:Connect(toggleCheckbox)
        
        -- Gunakan fungsi toggle untuk set
        refs[name] = {
            set = function(v) 
                if on ~= v then 
                    toggleCheckbox() 
                end 
            end, 
            get = function() return on end
        }
    end
    
    return {
        GetSelected = function() return selected end,
        SelectSpecific = function(list) 
            for n, r in pairs(refs) do 
                r.set(table.find(list, n) ~= nil) 
            end 
        end
    }
end

-- ============================================
-- CONFIG SYSTEM
-- ============================================
local ConfigSystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/akmiliadevi/Tugas_Kuliah/refs/heads/main/Project_code/Misc/SaveConfig.lua"))()

local function GetConfigValue(path, default)
    if ConfigSystem then
        local success, value = pcall(function() return ConfigSystem.Get(path) end)
        if success and value ~= nil then return value end
    end
    return default
end

local function SetConfigValue(path, value)
    if ConfigSystem then pcall(function() ConfigSystem.Set(path, value) end) end
end

local function SaveCurrentConfig()
    if ConfigSystem then pcall(function() ConfigSystem.Save() end) end
end

-- ============================================
-- TOGGLE REFERENCES
-- ============================================
local ToggleReferences = {}

-- ============================================
-- AUTO FISHING
-- ============================================
local catAutoFishing = makeCategory(mainPage, "Auto Fishing", "🎣")

local savedInstantMode = GetConfigValue("InstantFishing.Mode", "Fast")
local savedFishingDelay = GetConfigValue("InstantFishing.FishingDelay", 1.30)
local savedCancelDelay = GetConfigValue("InstantFishing.CancelDelay", 0.19)
local savedInstantEnabled = GetConfigValue("InstantFishing.Enabled", false)

local currentInstantMode = savedInstantMode
local fishingDelayValue = savedFishingDelay
local cancelDelayValue = savedCancelDelay
local isInstantFishingEnabled = false

task.spawn(function()
    task.wait(0.5)
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    
    if instant then
        instant.Settings.MaxWaitTime = savedFishingDelay
        instant.Settings.CancelDelay = savedCancelDelay
    end
    
    if instant2 then
        instant2.Settings.MaxWaitTime = savedFishingDelay
        instant2.Settings.CancelDelay = savedCancelDelay
    end
end)

makeDropdown(catAutoFishing, "Instant Fishing Mode", "⚡", {"Fast", "Perfect"}, function(mode)
    currentInstantMode = mode
    SetConfigValue("InstantFishing.Mode", mode)
    SaveCurrentConfig()
    
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    
    if instant then instant.Stop() end
    if instant2 then instant2.Stop() end
    
    if instant then
        instant.Settings.MaxWaitTime = fishingDelayValue
        instant.Settings.CancelDelay = cancelDelayValue
    end
    if instant2 then
        instant2.Settings.MaxWaitTime = fishingDelayValue
        instant2.Settings.CancelDelay = cancelDelayValue
    end
    
    if isInstantFishingEnabled then
        if mode == "Fast" and instant then instant.Start()
        elseif mode == "Perfect" and instant2 then instant2.Start() end
    end
end, "InstantFishingMode", savedInstantMode)

ToggleReferences.InstantFishing = makeToggle(catAutoFishing, "Enable Instant Fishing", function(on)
    isInstantFishingEnabled = on
    SetConfigValue("InstantFishing.Enabled", on)
    SaveCurrentConfig()
    
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    
    if on then
        if currentInstantMode == "Fast" and instant then instant.Start()
        elseif currentInstantMode == "Perfect" and instant2 then instant2.Start() end
    else
        if instant then instant.Stop() end
        if instant2 then instant2.Stop() end
    end
end)

task.spawn(function()
    task.wait(0.5)
    if savedInstantEnabled and ToggleReferences.InstantFishing then
        ToggleReferences.InstantFishing.setOn(savedInstantEnabled, true)
        isInstantFishingEnabled = true
        
        local instant = GetModule("instant")
        local instant2 = GetModule("instant2")
        
        if currentInstantMode == "Fast" and instant then instant.Start()
        elseif currentInstantMode == "Perfect" and instant2 then instant2.Start() end
    end
end)

makeInput(catAutoFishing, "Fishing Delay", savedFishingDelay, function(v)
    fishingDelayValue = v
    SetConfigValue("InstantFishing.FishingDelay", v)
    SaveCurrentConfig()
    
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    if instant then instant.Settings.MaxWaitTime = v end
    if instant2 then instant2.Settings.MaxWaitTime = v end
end)

makeInput(catAutoFishing, "Cancel Delay", savedCancelDelay, function(v)
    cancelDelayValue = v
    SetConfigValue("InstantFishing.CancelDelay", v)
    SaveCurrentConfig()
    
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    if instant then instant.Settings.CancelDelay = v end
    if instant2 then instant2.Settings.CancelDelay = v end
end)

-- ============================================
-- BLATANT MODES
-- ============================================

-- Blatant Tester
local catBlatantV2 = makeCategory(mainPage, "Blatant Tester", "🎯")

local savedBlatantTesterCompleteDelay = GetConfigValue("BlatantTester.CompleteDelay", 0.5)
local savedBlatantTesterCancelDelay = GetConfigValue("BlatantTester.CancelDelay", 0.1)

task.spawn(function()
    task.wait(0.5)
    local blatantv2fix = GetModule("blatantv2fix")
    if blatantv2fix then
        blatantv2fix.Settings.CompleteDelay = savedBlatantTesterCompleteDelay
        blatantv2fix.Settings.CancelDelay = savedBlatantTesterCancelDelay
    end
end)

ToggleReferences.BlatantTester = makeToggle(catBlatantV2, "Blatant Tester", function(on)
    SetConfigValue("BlatantTester.Enabled", on)
    SaveCurrentConfig()
    local blatantv2fix = GetModule("blatantv2fix")
    if blatantv2fix then
        if on then blatantv2fix.Start() else blatantv2fix.Stop() end
    end
end)

makeInput(catBlatantV2, "Complete Delay", savedBlatantTesterCompleteDelay, function(v)
    SetConfigValue("BlatantTester.CompleteDelay", v)
    SaveCurrentConfig()
    local blatantv2fix = GetModule("blatantv2fix")
    if blatantv2fix then blatantv2fix.Settings.CompleteDelay = v end
end)

makeInput(catBlatantV2, "Cancel Delay", savedBlatantTesterCancelDelay, function(v)
    SetConfigValue("BlatantTester.CancelDelay", v)
    SaveCurrentConfig()
    local blatantv2fix = GetModule("blatantv2fix")
    if blatantv2fix then blatantv2fix.Settings.CancelDelay = v end
end)

-- Blatant V1
local catBlatantV1 = makeCategory(mainPage, "Blatant V1", "💀")

local savedBlatantV1CompleteDelay = GetConfigValue("BlatantV1.CompleteDelay", 0.05)
local savedBlatantV1CancelDelay = GetConfigValue("BlatantV1.CancelDelay", 0.1)

task.spawn(function()
    task.wait(0.5)
    local blatantv1 = GetModule("blatantv1")
    if blatantv1 then
        blatantv1.Settings.CompleteDelay = savedBlatantV1CompleteDelay
        blatantv1.Settings.CancelDelay = savedBlatantV1CancelDelay
    end
end)

ToggleReferences.BlatantV1 = makeToggle(catBlatantV1, "Blatant Mode", function(on)
    SetConfigValue("BlatantV1.Enabled", on)
    SaveCurrentConfig()
    local blatantv1 = GetModule("blatantv1")
    if blatantv1 then
        if on then blatantv1.Start() else blatantv1.Stop() end
    end
end)

makeInput(catBlatantV1, "Complete Delay", savedBlatantV1CompleteDelay, function(v)
    SetConfigValue("BlatantV1.CompleteDelay", v)
    SaveCurrentConfig()
    local blatantv1 = GetModule("blatantv1")
    if blatantv1 then blatantv1.Settings.CompleteDelay = v end
end)

makeInput(catBlatantV1, "Cancel Delay", savedBlatantV1CancelDelay, function(v)
    SetConfigValue("BlatantV1.CancelDelay", v)
    SaveCurrentConfig()
    local blatantv1 = GetModule("blatantv1")
    if blatantv1 then blatantv1.Settings.CancelDelay = v end
end)

-- Part 4/8: More Blatant Modes & Support Features

-- Ultra Blatant V2
local catUltraBlatant = makeCategory(mainPage, "Blatant V2", "⚡")

local savedUltraBlatantCompleteDelay = GetConfigValue("UltraBlatant.CompleteDelay", 0.05)
local savedUltraBlatantCancelDelay = GetConfigValue("UltraBlatant.CancelDelay", 0.1)

task.spawn(function()
    task.wait(0.5)
    local UltraBlatant = GetModule("UltraBlatant")
    if UltraBlatant then
        if UltraBlatant.Settings then
            UltraBlatant.Settings.CompleteDelay = savedUltraBlatantCompleteDelay
            UltraBlatant.Settings.CancelDelay = savedUltraBlatantCancelDelay
        elseif UltraBlatant.UpdateSettings then
            UltraBlatant.UpdateSettings(savedUltraBlatantCompleteDelay, savedUltraBlatantCancelDelay, nil)
        end
    end
end)

ToggleReferences.UltraBlatant = makeToggle(catUltraBlatant, "Blatant Mode", function(on)
    SetConfigValue("UltraBlatant.Enabled", on)
    SaveCurrentConfig()
    local UltraBlatant = GetModule("UltraBlatant")
    if UltraBlatant then
        if on then UltraBlatant.Start() else UltraBlatant.Stop() end
    end
end)

makeInput(catUltraBlatant, "Complete Delay", savedUltraBlatantCompleteDelay, function(v)
    SetConfigValue("UltraBlatant.CompleteDelay", v)
    SaveCurrentConfig()
    local UltraBlatant = GetModule("UltraBlatant")
    if UltraBlatant then
        if UltraBlatant.Settings then
            UltraBlatant.Settings.CompleteDelay = v
        elseif UltraBlatant.UpdateSettings then
            UltraBlatant.UpdateSettings(v, nil, nil)
        end
    end
end)

makeInput(catUltraBlatant, "Cancel Delay", savedUltraBlatantCancelDelay, function(v)
    SetConfigValue("UltraBlatant.CancelDelay", v)
    SaveCurrentConfig()
    local UltraBlatant = GetModule("UltraBlatant")
    if UltraBlatant then
        if UltraBlatant.Settings then
            UltraBlatant.Settings.CancelDelay = v
        elseif UltraBlatant.UpdateSettings then
            UltraBlatant.UpdateSettings(nil, v, nil)
        end
    end
end)

-- Fast Auto Fishing Perfect
local catBlatantV2Fast = makeCategory(mainPage, "Fast Auto Fishing Perfect", "🔥")

ToggleReferences.FastAutoPerfect = makeToggle(catBlatantV2Fast, "Fast Fishing Features", function(on)
    SetConfigValue("FastAutoPerfect.Enabled", on)
    SaveCurrentConfig()
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then
        if on then blatantv2.Start() else blatantv2.Stop() end
    end
end)

makeInput(catBlatantV2Fast, "Fishing Delay", GetConfigValue("FastAutoPerfect.FishingDelay", 0.05), function(v)
    SetConfigValue("FastAutoPerfect.FishingDelay", v)
    SaveCurrentConfig()
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then blatantv2.Settings.FishingDelay = v end
end)

makeInput(catBlatantV2Fast, "Cancel Delay", GetConfigValue("FastAutoPerfect.CancelDelay", 0.01), function(v)
    SetConfigValue("FastAutoPerfect.CancelDelay", v)
    SaveCurrentConfig()
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then blatantv2.Settings.CancelDelay = v end
end)

makeInput(catBlatantV2Fast, "Timeout Delay", GetConfigValue("FastAutoPerfect.TimeoutDelay", 0.8), function(v)
    SetConfigValue("FastAutoPerfect.TimeoutDelay", v)
    SaveCurrentConfig()
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then blatantv2.Settings.TimeoutDelay = v end
end)

-- ============================================
-- SUPPORT FEATURES
-- ============================================
local catSupport = makeCategory(mainPage, "Support Features", "🛠️")

ToggleReferences.NoFishingAnimation = makeToggle(catSupport, "No Fishing Animation", function(on)
    SetConfigValue("Support.NoFishingAnimation", on)
    SaveCurrentConfig()
    local NoFishingAnimation = GetModule("NoFishingAnimation")
    if NoFishingAnimation then
        if on then NoFishingAnimation.StartWithDelay() else NoFishingAnimation.Stop() end
    end
end)

ToggleReferences.PingFPSMonitor = makeToggle(catSupport, "Ping & FPS Monitor", function(on)
    SetConfigValue("Support.PingFPSMonitor", on)
    SaveCurrentConfig()
    local PingFPSMonitor = GetModule("PingFPSMonitor")
    if PingFPSMonitor then
        if on then 
            PingFPSMonitor:Show()
        else 
            PingFPSMonitor:Hide()
        end
    end
end)

ToggleReferences.LockPosition = makeToggle(catSupport, "Lock Position", function(on)
    SetConfigValue("Support.LockPosition", on)
    SaveCurrentConfig()
    local LockPosition = GetModule("LockPosition")
    if LockPosition then
        if on then LockPosition.Start() else LockPosition.Stop() end
    end
end)

ToggleReferences.AutoEquipRod = makeToggle(catSupport, "Auto Equip Rod", function(on)
    SetConfigValue("Support.AutoEquipRod", on)
    SaveCurrentConfig()
    local AutoEquipRod = GetModule("AutoEquipRod")
    if AutoEquipRod then
        if on then AutoEquipRod.Start() else AutoEquipRod.Stop() end
    end
end)

ToggleReferences.DisableCutscenes = makeToggle(catSupport, "Disable Cutscenes", function(on)
    SetConfigValue("Support.DisableCutscenes", on)
    SaveCurrentConfig()
    local DisableCutscenes = GetModule("DisableCutscenes")
    if DisableCutscenes then
        if on then DisableCutscenes.Start() else DisableCutscenes.Stop() end
    end
end)

ToggleReferences.DisableObtainedNotif = makeToggle(catSupport, "Disable Obtained Fish Notification", function(on)
    SetConfigValue("Support.DisableObtainedNotif", on)
    SaveCurrentConfig()
    local DisableExtras = GetModule("DisableExtras")
    if DisableExtras then
        if on then DisableExtras.StartSmallNotification() else DisableExtras.StopSmallNotification() end
    end
end)

ToggleReferences.DisableSkinEffect = makeToggle(catSupport, "Disable Skin Effect", function(on)
    SetConfigValue("Support.DisableSkinEffect", on)
    SaveCurrentConfig()
    local DisableExtras = GetModule("DisableExtras")
    if DisableExtras then
        if on then DisableExtras.StartSkinEffect() else DisableExtras.StopSkinEffect() end
    end
end)

ToggleReferences.WalkOnWater = makeToggle(catSupport, "Walk On Water", function(on)
    SetConfigValue("Support.WalkOnWater", on)
    SaveCurrentConfig()
    local WalkOnWater = GetModule("WalkOnWater")
    if WalkOnWater then
        if on then WalkOnWater.Start() else WalkOnWater.Stop() end
    end
end)

ToggleReferences.GoodPerfectionStable = makeToggle(catSupport, "Good/Perfection Stable Mode", function(on)
    SetConfigValue("Support.GoodPerfectionStable", on)
    SaveCurrentConfig()
    local GoodPerfectionStable = GetModule("GoodPerfectionStable")
    if GoodPerfectionStable then
        if on then GoodPerfectionStable.Start() else GoodPerfectionStable.Stop() end
    end
end)

-- ============================================
-- AUTO FAVORITE (MINIMAL)
-- ============================================
local catAutoFav = makeCategory(mainPage, "Auto Favorite", "⭐")
local AutoFavorite = GetModule("AutoFavorite")

if AutoFavorite then
    local tierSys = makeCheckboxDropdown(catAutoFav, "Tier Filter", AutoFavorite.GetAllTiers(), {Common = Color3.fromRGB(150, 150, 150), Uncommon = Color3.fromRGB(76, 175, 80), Rare = Color3.fromRGB(33, 150, 243), Epic = Color3.fromRGB(156, 39, 176), Legendary = Color3.fromRGB(255, 152, 0), Mythic = Color3.fromRGB(255, 0, 0), SECRET = Color3.fromRGB(0, 255, 170)}, function(sel) AutoFavorite.ClearTiers() AutoFavorite.EnableTiers(sel) SetConfigValue("AutoFavorite.EnabledTiers", sel) SaveCurrentConfig() end)
    
    local varSys = makeCheckboxDropdown(catAutoFav, "Variant Filter", AutoFavorite.GetAllVariants(), nil, function(sel) AutoFavorite.ClearVariants() AutoFavorite.EnableVariants(sel) SetConfigValue("AutoFavorite.EnabledVariants", sel) SaveCurrentConfig() end)
    
    task.spawn(function()
        task.wait(0.5)
        tierSys.SelectSpecific(GetConfigValue("AutoFavorite.EnabledTiers", {}))
        varSys.SelectSpecific(GetConfigValue("AutoFavorite.EnabledVariants", {}))
    end)
end

--auto totem
local catAutoTotem = makeCategory(mainPage, "Auto Spawn 3X Totem", "🛠️")

makeButton(catAutoTotem, "Auto Totem 3X", function()
    local AutoTotem3X = GetModule("AutoTotem3X")
    local Notify = GetModule("Notify")
    if AutoTotem3X then
        if AutoTotem3X.IsRunning() then
            local success, message = AutoTotem3X.Stop()
            if success and Notify then Notify.Send("Auto Totem 3X", "⏹ " .. message, 4) end
        else
            local success, message = AutoTotem3X.Start()
            if Notify then
                if success then Notify.Send("Auto Totem 3X", "▶ " .. message, 4)
                else Notify.Send("Auto Totem 3X", "⚠ " .. message, 3) end
            end
        end
    end
end)

local catSkin = makeCategory(mainPage, "Skin Animation", "✨")

makeButton(catSkin, "⚔️ Eclipse Katana", function()
    local SkinAnimation = GetModule("SkinAnimation")
    local Notify = GetModule("Notify")
    if SkinAnimation then
        local success = SkinAnimation.SwitchSkin("Eclipse")
        if success then
            SetConfigValue("Support.SkinAnimation.Current", "Eclipse")
            SaveCurrentConfig()
            if Notify then Notify.Send("Skin Animation", "⚔️ Eclipse Katana diaktifkan!", 4) end
            if not SkinAnimation.IsEnabled() then SkinAnimation.Enable() end
        elseif Notify then
            Notify.Send("Skin Animation", "⚠ Gagal mengganti skin!", 3)
        end
    end
end)

makeButton(catSkin, "🔱 Holy Trident", function()
    local SkinAnimation = GetModule("SkinAnimation")
    local Notify = GetModule("Notify")
    if SkinAnimation then
        local success = SkinAnimation.SwitchSkin("HolyTrident")
        if success then
            SetConfigValue("Support.SkinAnimation.Current", "HolyTrident")
            SaveCurrentConfig()
            if Notify then Notify.Send("Skin Animation", "🔱 Holy Trident diaktifkan!", 4) end
            if not SkinAnimation.IsEnabled() then SkinAnimation.Enable() end
        elseif Notify then
            Notify.Send("Skin Animation", "⚠ Gagal mengganti skin!", 3)
        end
    end
end)

makeButton(catSkin, "💀 Soul Scythe", function()
    local SkinAnimation = GetModule("SkinAnimation")
    local Notify = GetModule("Notify")
    if SkinAnimation then
        local success = SkinAnimation.SwitchSkin("SoulScythe")
        if success then
            SetConfigValue("Support.SkinAnimation.Current", "SoulScythe")
            SaveCurrentConfig()
            if Notify then Notify.Send("Skin Animation", "💀 Soul Scythe diaktifkan!", 4) end
            if not SkinAnimation.IsEnabled() then SkinAnimation.Enable() end
        elseif Notify then
            Notify.Send("Skin Animation", "⚠ Gagal mengganti skin!", 3)
        end
    end
end)

makeToggle(catSkin, "Enable Skin Animation", function(on)
    SetConfigValue("Support.SkinAnimation.Enabled", on)
    SaveCurrentConfig()
    local SkinAnimation = GetModule("SkinAnimation")
    local Notify = GetModule("Notify")
    if SkinAnimation then
        if on then
            local success = SkinAnimation.Enable()
            if Notify then
                if success then
                    local currentSkin = SkinAnimation.GetCurrentSkin()
                    local icon = currentSkin == "Eclipse" and "⚔️" or (currentSkin == "HolyTrident" and "🔱" or "💀")
                    Notify.Send("Skin Animation", "✓ " .. icon .. " " .. currentSkin .. " aktif!", 4)
                else
                    Notify.Send("Skin Animation", "⚠ Sudah aktif!", 3)
                end
            end
        else
            local success = SkinAnimation.Disable()
            if Notify then
                if success then Notify.Send("Skin Animation", "✓ Skin Animation dimatikan!", 4)
                else Notify.Send("Skin Animation", "⚠ Sudah nonaktif!", 3) end
            end
        end
    end
end)

-- TELEPORT PAGE
local TeleportModule = GetModule("TeleportModule")
local TeleportToPlayer = GetModule("TeleportToPlayer")
local SavedLocation = GetModule("SavedLocation")
-- Location Teleport
if TeleportModule then
    local locationItems = {}
    for name, _ in pairs(TeleportModule.Locations) do
        table.insert(locationItems, name)
    end
    table.sort(locationItems)
    
    makeDropdown(teleportPage, "Teleport to Location", "📍", locationItems, function(selectedLocation)
        TeleportModule.TeleportTo(selectedLocation)
    end, "LocationTeleport")
end
-- Player Teleport
local playerDropdown
local function updatePlayerList()
    local playerItems = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(playerItems, player.Name)
        end
    end
    table.sort(playerItems)
    
    if #playerItems == 0 then playerItems = {"No other players"} end
    
    if playerDropdown and playerDropdown.Parent then playerDropdown:Destroy() end
    
    if TeleportToPlayer then
        playerDropdown = makeDropdown(teleportPage, "Teleport to Player", "👤", playerItems, function(selectedPlayer)
            if selectedPlayer ~= "No other players" then
                TeleportToPlayer.TeleportTo(selectedPlayer)
            end
        end, "PlayerTeleport")
    end
end

updatePlayerList()

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    updatePlayerList()
end)

-- Saved Location
local catSaved = makeCategory(teleportPage, "Saved Location", "⭐")

makeButton(catSaved, "Save Current Location", function()
    if SavedLocation then
        SavedLocation.Save()
        SendNotification("Saved Location", "Lokasi berhasil disimpan.", 3)
    end
end)

makeButton(catSaved, "Teleport Saved Location", function()
    if SavedLocation then
        if SavedLocation.Teleport() then
            SendNotification("Teleported", "Berhasil teleport ke lokasi tersimpan.", 3)
        else
            SendNotification("Error", "Tidak ada lokasi yang disimpan!", 3)
        end
    end
end)

makeButton(catSaved, "Reset Saved Location", function()
    if SavedLocation then
        SavedLocation.Reset()
        SendNotification("Reset", "Lokasi tersimpan telah dihapus.", 3)
    end
end)

-- Event Teleport
local catTeleport = makeCategory(teleportPage, "Event Teleport", "🎯")
local selectedEventName = GetConfigValue("Teleport.LastEventSelected", nil)
local EventTeleport = GetModule("EventTeleportDynamic")

if EventTeleport then
    local eventNames = EventTeleport.GetEventNames() or {}
    
    if #eventNames == 0 then eventNames = {"- No events available -"} end
    
    makeDropdown(catTeleport, "Pilih Event", "📌", eventNames, function(selected)
        if selected ~= "- No events available -" then
            selectedEventName = selected
            SetConfigValue("Teleport.LastEventSelected", selected)
            SaveCurrentConfig()
            SendNotification("Event", "Event dipilih: " .. tostring(selected), 3)
        end
    end, "EventTeleport")
    
    ToggleReferences.AutoTeleportEvent = makeToggle(catTeleport, "Enable Auto Teleport", function(on)
        SetConfigValue("Teleport.AutoTeleportEvent", on)
        SaveCurrentConfig()
        
        if on then
            if selectedEventName and selectedEventName ~= "- No events available -" and EventTeleport.HasCoords(selectedEventName) then
                EventTeleport.Start(selectedEventName)
                SendNotification("Auto Teleport", "Mulai auto teleport ke " .. selectedEventName, 4)
            else
                SendNotification("Auto Teleport", "Pilih event yang memiliki koordinat dulu!", 3)
            end
        else
            EventTeleport.Stop()
            SendNotification("Auto Teleport", "Auto teleport dihentikan.", 3)
        end
    end)
    
    makeButton(catTeleport, "Teleport Now", function()
        if selectedEventName and selectedEventName ~= "- No events available -" then
            local ok = EventTeleport.TeleportNow(selectedEventName)
            if ok then SendNotification("Teleport", "Teleported ke " .. selectedEventName, 3)
            else SendNotification("Teleport", "Teleport gagal!", 3) end
        else
            SendNotification("Teleport", "Event belum dipilih!", 3)
        end
    end)
end

-- SHOP PAGE
local AutoSell = GetModule("AutoSell")
local MerchantSystem = GetModule("MerchantSystem")
local RemoteBuyer = GetModule("RemoteBuyer")

-- Sell All
local catSell = makeCategory(shopPage, "Sell All", "💰")

makeButton(catSell, "Sell All Now", function()
    if AutoSell and AutoSell.SellOnce then AutoSell.SellOnce() end
end)

-- Auto Sell Timer
local catTimer = makeCategory(shopPage, "Auto Sell Timer", "⏰")
local AutoSellTimer = GetModule("AutoSellTimer")

if AutoSellTimer then
    makeInput(catTimer, "Sell Interval (seconds)", GetConfigValue("Shop.AutoSellTimer.Interval", 5), function(value)
        SetConfigValue("Shop.AutoSellTimer.Interval", value)
        SaveCurrentConfig()
        if AutoSellTimer then pcall(function() AutoSellTimer.SetInterval(value) end) end
    end)

    ToggleReferences.AutoSellTimer = makeToggle(catTimer, "Auto Sell Timer", function(on)
        SetConfigValue("Shop.AutoSellTimer.Enabled", on)
        SaveCurrentConfig()
        if AutoSellTimer then
            pcall(function()
                if on then
                    local interval = GetConfigValue("Shop.AutoSellTimer.Interval", 5)
                    AutoSellTimer.Start(interval)
                else
                    AutoSellTimer.Stop()
                end
            end)
        end
    end)
else
    new("TextLabel", {
        Parent = catTimer,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "⚠️ AutoSellTimer module not available",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = colors.warning,
        TextWrapped = true,
        ZIndex = 8
    })
end

-- Auto Buy Weather
local catWeather = makeCategory(shopPage, "Auto Buy Weather", "🌦️")
local AutoBuyWeather = GetModule("AutoBuyWeather")

if AutoBuyWeather then
    local weatherCheckboxSystem = makeCheckboxList(
        catWeather,
        AutoBuyWeather.AllWeathers,
        nil,
        function(selectedWeathers)
            AutoBuyWeather.SetSelected(selectedWeathers)
            SetConfigValue("Shop.AutoBuyWeather.SelectedWeathers", selectedWeathers)
            SaveCurrentConfig()
        end
    )
    
    ToggleReferences.AutoBuyWeather = makeToggle(catWeather, "Enable Auto Weather", function(on)
        SetConfigValue("Shop.AutoBuyWeather.Enabled", on)
        SaveCurrentConfig()
        
        if on then
            local selected = weatherCheckboxSystem.GetSelected()
            if #selected == 0 then
                SendNotification("Auto Weather", "Pilih minimal 1 cuaca!", 3)
                return
            end
            AutoBuyWeather.Start()
            SendNotification("Auto Weather", "Auto buy weather aktif!", 3)
        else
            AutoBuyWeather.Stop()
            SendNotification("Auto Weather", "Auto buy weather dimatikan.", 3)
        end
    end)
end

-- Remote Merchant
local catMerchant = makeCategory(shopPage, "Remote Merchant", "🛒")

makeButton(catMerchant, "Open Merchant", function()
    if MerchantSystem then
        MerchantSystem.Open()
        SendNotification("Merchant", "Merchant dibuka!", 3)
    end
end)

makeButton(catMerchant, "Close Merchant", function()
    if MerchantSystem then
        MerchantSystem.Close()
        SendNotification("Merchant", "Merchant ditutup!", 3)
    end
end)

-- Buy Rod
local catRod = makeCategory(shopPage, "Buy Rod", "🎣")

if RemoteBuyer then
    local RodData = {
        ["Chrome Rod"] = {id = 7, price = 437000},
        ["Lucky Rod"] = {id = 4, price = 15000},
        ["Starter Rod"] = {id = 1, price = 50},
        ["Carbon Rod"] = {id = 76, price = 750},
        ["Astral Rod"] = {id = 5, price = 1000000},
    }
    
    local RodList = {}
    local RodMap = {}
    for rodName, info in pairs(RodData) do
        local display = rodName .. " (" .. tostring(info.price) .. ")"
        table.insert(RodList, display)
        RodMap[display] = rodName
    end
    
    local SelectedRod = nil
    
    makeDropdown(catRod, "Select Rod", "🎣", RodList, function(displayName)
        SelectedRod = RodMap[displayName]
        SendNotification("Rod Selected", "Rod: " .. SelectedRod, 3)
    end, "RodDropdown")
    
    makeButton(catRod, "BUY SELECTED ROD", function()
        if SelectedRod then
            RemoteBuyer.BuyRod(RodData[SelectedRod].id)
            SendNotification("Buy Rod", "Membeli " .. SelectedRod .. "...", 3)
        else
            SendNotification("Buy Rod", "Pilih rod dulu!", 3)
        end
    end)
end

-- Buy Bait
local catBait = makeCategory(shopPage, "Buy Bait", "🪱")

if RemoteBuyer then
    local BaitData = {
        ["Chroma Bait"] = {id = 6, price = 290000},
        ["Luck Bait"] = {id = 2, price = 1000},
        ["Midnight Bait"] = {id = 3, price = 3000},
    }
    
    local BaitList = {}
    local BaitMap = {}
    for baitName, info in pairs(BaitData) do
        local display = baitName .. " (" .. tostring(info.price) .. ")"
        table.insert(BaitList, display)
        BaitMap[display] = baitName
    end
    
    local SelectedBait = nil
    
    makeDropdown(catBait, "Select Bait", "🪱", BaitList, function(displayName)
        SelectedBait = BaitMap[displayName]
        SendNotification("Bait Selected", "Bait: " .. SelectedBait, 3)
    end, "BaitDropdown")
    
    makeButton(catBait, "BUY SELECTED BAIT", function()
        if SelectedBait then
            RemoteBuyer.BuyBait(BaitData[SelectedBait].id)
            SendNotification("Buy Bait", "Membeli " .. SelectedBait .. "...", 3)
        else
            SendNotification("Buy Bait", "Pilih bait dulu!", 3)
        end
    end)
end

-- WEBHOOK PAGE
local catWebhook = makeCategory(webhookPage, "Webhook Configuration", "🔗")
local WebhookModule = GetModule("Webhook")
local currentWebhookURL = GetConfigValue("Webhook.URL", "")
local currentDiscordID = GetConfigValue("Webhook.DiscordID", "")

-- CEK SUPPORT EXECUTOR
local isWebhookSupported = false
if WebhookModule then
    isWebhookSupported = WebhookModule:IsSupported()
    
    if not isWebhookSupported then
        -- WARNING BANNER
        local warningFrame = new("Frame", {
            Parent = catWebhook,
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = colors.danger,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            ZIndex = 7
        })
        new("UICorner", {Parent = warningFrame, CornerRadius = UDim.new(0, 8)})
        
        new("TextLabel", {
            Parent = warningFrame,
            Size = UDim2.new(1, -24, 1, -24),
            Position = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            Text = "⚠️ WEBHOOK NOT SUPPORTED\n\nYour executor doesn't support HTTP requests.\nPlease use: Xeno, Synapse X, Script-Ware, or Fluxus.",
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            TextColor3 = colors.text,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 8
        })
        
        print("❌ Webhook: Executor tidak support HTTP requests!")
    else
        -- Aktifkan simple mode untuk keamanan
        WebhookModule:SetSimpleMode(true)
        print("✅ Webhook: Executor support detected!")
    end
end

-- Webhook URL Input (disabled jika tidak support)
local webhookURLFrame = new("Frame", {
    Parent = catWebhook,
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    ZIndex = 7
})

new("TextLabel", {
    Parent = webhookURLFrame,
    Text = "Webhook URL" .. (not isWebhookSupported and " (Disabled)" or ""),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    TextColor3 = not isWebhookSupported and colors.textDimmer or colors.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    ZIndex = 8
})

local webhookURLBg = new("Frame", {
    Parent = webhookURLFrame,
    Size = UDim2.new(1, 0, 0, 35),
    Position = UDim2.new(0, 0, 0, 22),
    BackgroundColor3 = colors.bg4,
    BackgroundTransparency = not isWebhookSupported and 0.8 or 0.4,
    BorderSizePixel = 0,
    ZIndex = 8
})
new("UICorner", {Parent = webhookURLBg, CornerRadius = UDim.new(0, 6)})

local webhookTextBox = new("TextBox", {
    Parent = webhookURLBg,
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 6, 0, 0),
    BackgroundTransparency = 1,
    Text = currentWebhookURL,
    PlaceholderText = not isWebhookSupported and "Not supported on this executor" or "https://discord.com/api/webhooks/...",
    Font = Enum.Font.Gotham,
    TextSize = 8,
    TextColor3 = not isWebhookSupported and colors.textDimmer or colors.text,
    PlaceholderColor3 = colors.textDimmer,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    TextEditable = isWebhookSupported,
    ZIndex = 9
})

if isWebhookSupported then
    webhookTextBox.FocusLost:Connect(function()
        currentWebhookURL = webhookTextBox.Text
        SetConfigValue("Webhook.URL", currentWebhookURL)
        SaveCurrentConfig()
        
        if WebhookModule and currentWebhookURL ~= "" then
            pcall(function() WebhookModule:SetWebhookURL(currentWebhookURL) end)
            SendNotification("Webhook", "Webhook URL tersimpan!", 2)
        end
    end)
end

-- Discord ID Input (disabled jika tidak support)
local discordIDFrame = new("Frame", {
    Parent = catWebhook,
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    ZIndex = 7
})

new("TextLabel", {
    Parent = discordIDFrame,
    Text = "Discord User ID (Optional)" .. (not isWebhookSupported and " (Disabled)" or ""),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    TextColor3 = not isWebhookSupported and colors.textDimmer or colors.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    ZIndex = 8
})

local discordIDBg = new("Frame", {
    Parent = discordIDFrame,
    Size = UDim2.new(1, 0, 0, 35),
    Position = UDim2.new(0, 0, 0, 22),
    BackgroundColor3 = colors.bg4,
    BackgroundTransparency = not isWebhookSupported and 0.8 or 0.4,
    BorderSizePixel = 0,
    ZIndex = 8
})
new("UICorner", {Parent = discordIDBg, CornerRadius = UDim.new(0, 6)})

local discordIDTextBox = new("TextBox", {
    Parent = discordIDBg,
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 6, 0, 0),
    BackgroundTransparency = 1,
    Text = currentDiscordID,
    PlaceholderText = not isWebhookSupported and "Not supported on this executor" or "123456789012345678",
    Font = Enum.Font.Gotham,
    TextSize = 8,
    TextColor3 = not isWebhookSupported and colors.textDimmer or colors.text,
    PlaceholderColor3 = colors.textDimmer,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    TextEditable = isWebhookSupported,
    ZIndex = 9
})

if isWebhookSupported then
    discordIDTextBox.FocusLost:Connect(function()
        currentDiscordID = discordIDTextBox.Text
        SetConfigValue("Webhook.DiscordID", currentDiscordID)
        SaveCurrentConfig()
        
        if WebhookModule then
            pcall(function() WebhookModule:SetDiscordUserID(currentDiscordID) end)
            if currentDiscordID ~= "" then
                SendNotification("Webhook", "Discord ID tersimpan!", 2)
            end
        end
    end)
end

-- Rarity Filter (sesuai dengan TIER_NAMES dari Webhook Module)
local AllRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"}
local rarityColors = {
    Common = Color3.fromRGB(150, 150, 150),      -- Tier 1
    Uncommon = Color3.fromRGB(76, 175, 80),      -- Tier 2
    Rare = Color3.fromRGB(33, 150, 243),         -- Tier 3
    Epic = Color3.fromRGB(156, 39, 176),         -- Tier 4
    Legendary = Color3.fromRGB(255, 152, 0),     -- Tier 5
    Mythic = Color3.fromRGB(255, 0, 0),          -- Tier 6 - Merah
    SECRET = Color3.fromRGB(0, 255, 170)         -- Tier 7 - Hijau Tosca
}

local rarityCheckboxSystem = makeCheckboxList(
    catWebhook,
    AllRarities,
    rarityColors,
    function(selectedRarities)
        if WebhookModule and isWebhookSupported then
            pcall(function() WebhookModule:SetEnabledRarities(selectedRarities) end)
        end
        SetConfigValue("Webhook.EnabledRarities", selectedRarities)
        SaveCurrentConfig()
    end
)

-- Disable checkbox jika tidak support
if not isWebhookSupported then
    task.spawn(function()
        task.wait(0.5)
        for _, rarity in ipairs(AllRarities) do
            -- Visual indication bahwa disabled
            -- (checkbox system sudah jadi, tidak perlu diubah)
        end
    end)
end

-- Toggle Webhook (disabled jika tidak support)
ToggleReferences.Webhook = makeToggle(catWebhook, "Enable Webhook" .. (not isWebhookSupported and " (Not Supported)" or ""), function(on)
    -- BLOCK jika tidak support
    if not isWebhookSupported then
        SendNotification("Error", "Webhook not supported on this executor!", 3)
        -- Reset toggle
        if ToggleReferences.Webhook then
            task.spawn(function()
                task.wait(0.1)
                ToggleReferences.Webhook.setOn(false, true)
            end)
        end
        return
    end
    
    SetConfigValue("Webhook.Enabled", on)
    SaveCurrentConfig()
    
    if not WebhookModule then
        SendNotification("Error", "Webhook module tidak tersedia!", 3)
        return
    end
    
    if on then
        if currentWebhookURL == "" then
            SendNotification("Error", "Masukkan Webhook URL dulu!", 3)
            -- Reset toggle
            if ToggleReferences.Webhook then
                task.spawn(function()
                    task.wait(0.1)
                    ToggleReferences.Webhook.setOn(false, true)
                end)
            end
            return
        end
        
        local success = pcall(function()
            WebhookModule:SetWebhookURL(currentWebhookURL)
            if currentDiscordID ~= "" then
                WebhookModule:SetDiscordUserID(currentDiscordID)
            end
            local selected = rarityCheckboxSystem.GetSelected()
            WebhookModule:SetEnabledRarities(selected)
            WebhookModule:Start()
        end)
        
        if success then
            local selected = rarityCheckboxSystem.GetSelected()
            local filterInfo = #selected > 0 
                and (" (Filter: " .. table.concat(selected, ", ") .. ")")
                or " (All rarities)"
            SendNotification("Webhook", "Webhook logging aktif!" .. filterInfo, 4)
        else
            SendNotification("Error", "Failed to start webhook!", 3)
            -- Reset toggle
            if ToggleReferences.Webhook then
                task.spawn(function()
                    task.wait(0.1)
                    ToggleReferences.Webhook.setOn(false, true)
                end)
            end
        end
    else
        pcall(function() WebhookModule:Stop() end)
        SendNotification("Webhook", "Webhook logging dinonaktifkan.", 3)
    end
end)

-- Auto-disable webhook toggle jika tidak support
if not isWebhookSupported then
    task.spawn(function()
        task.wait(0.5)
        if ToggleReferences.Webhook then
            ToggleReferences.Webhook.setOn(false, true)
        end
    end)
end

-- CAMERA VIEW PAGE
local catZoom = makeCategory(cameraViewPage, "Unlimited Zoom", "🔍")
local UnlimitedZoomModule = GetModule("UnlimitedZoomModule")

ToggleReferences.UnlimitedZoom = makeToggle(catZoom, "Enable Unlimited Zoom", function(on)
    SetConfigValue("CameraView.UnlimitedZoom", on)
    SaveCurrentConfig()
    
    if UnlimitedZoomModule then
        if on then
            local success = UnlimitedZoomModule.Enable()
            if success then SendNotification("Zoom", "Unlimited Zoom aktif!", 4) end
        else
            UnlimitedZoomModule.Disable()
            SendNotification("Zoom", "Unlimited Zoom nonaktif.", 3)
        end
    end
end)

local catFreecam = makeCategory(cameraViewPage, "Freecam", "📹")
local FreecamModule = GetModule("FreecamModule")

ToggleReferences.Freecam = makeToggle(catFreecam, "Enable Freecam", function(on)
    SetConfigValue("CameraView.Freecam.Enabled", on)
    SaveCurrentConfig()
    
    if FreecamModule then
        if on then
            if not isMobile then
                FreecamModule.EnableF3Keybind(true)
                SendNotification("Freecam", "Freecam siap! Tekan F3.", 4)
            else
                FreecamModule.Start()
                SendNotification("Freecam", "Freecam aktif!", 4)
            end
        else
            FreecamModule.EnableF3Keybind(false)
            SendNotification("Freecam", "Freecam nonaktif.", 3)
        end
    end
end)

makeInput(catFreecam, "Movement Speed", GetConfigValue("CameraView.Freecam.Speed", 50), function(value)
    SetConfigValue("CameraView.Freecam.Speed", value)
    SaveCurrentConfig()
    if FreecamModule then FreecamModule.SetSpeed(value) end
end)

makeInput(catFreecam, "Mouse Sensitivity", GetConfigValue("CameraView.Freecam.Sensitivity", 0.3), function(value)
    SetConfigValue("CameraView.Freecam.Sensitivity", value)
    SaveCurrentConfig()
    if FreecamModule then FreecamModule.SetSensitivity(value) end
end)

-- SETTINGS PAGE
local catAFK = makeCategory(settingsPage, "Anti-AFK", "⏱️")
local AntiAFK = GetModule("AntiAFK")

ToggleReferences.AntiAFK = makeToggle(catAFK, "Enable Anti-AFK", function(on)
    SetConfigValue("Settings.AntiAFK", on)
    SaveCurrentConfig()
    if AntiAFK then
        if on then AntiAFK.Start() else AntiAFK.Stop() end
    end
end)

local catBoost = makeCategory(settingsPage, "Performance", "⚡")
local FPSBooster = GetModule("FPSBooster")
local DisableRenderingModule = GetModule("DisableRendering")

ToggleReferences.FPSBooster = makeToggle(catBoost, "Enable FPS Booster", function(on)
    SetConfigValue("Settings.FPSBooster", on)
    SaveCurrentConfig()
    
    if FPSBooster then
        if on then
            FPSBooster.Enable()
            SendNotification("FPS Booster", "FPS Booster diaktifkan!", 3)
        else
            FPSBooster.Disable()
            SendNotification("FPS Booster", "FPS Booster dimatikan.", 3)
        end
    end
end)

ToggleReferences.DisableRendering = makeToggle(catBoost, "Disable 3D Rendering", function(on)
    SetConfigValue("Settings.DisableRendering", on)
    SaveCurrentConfig()
    
    if DisableRenderingModule then
        if on then DisableRenderingModule.Start() else DisableRenderingModule.Stop() end
    end
end)

local catFPS = makeCategory(settingsPage, "FPS Settings", "🎮")
local UnlockFPS = GetModule("UnlockFPS")

makeDropdown(catFPS, "Select FPS Limit", "⚙️", {"60 FPS", "90 FPS", "120 FPS", "240 FPS"}, function(selected)
    local fpsValue = tonumber(selected:match("%d+"))
    SetConfigValue("Settings.FPSLimit", fpsValue)
    SaveCurrentConfig()
    if fpsValue and UnlockFPS then UnlockFPS.SetCap(fpsValue) end
end, "FPSDropdown")

-- Hide Stats
local catHideStats = makeCategory(settingsPage, "Hide Stats", "👤")
local HideStats = GetModule("HideStats")
local currentFakeName = GetConfigValue("Settings.HideStats.FakeName", "Guest")
local currentFakeLevel = GetConfigValue("Settings.HideStats.FakeLevel", "1")

-- Fake Name Input
local fakeNameFrame = new("Frame", {
    Parent = catHideStats,
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    ZIndex = 7
})

new("TextLabel", {
    Parent = fakeNameFrame,
    Text = "Fake Name",
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    TextColor3 = colors.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    ZIndex = 8
})

local fakeNameBg = new("Frame", {
    Parent = fakeNameFrame,
    Size = UDim2.new(1, 0, 0, 35),
    Position = UDim2.new(0, 0, 0, 22),
    BackgroundColor3 = colors.bg4,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 8
})
new("UICorner", {Parent = fakeNameBg, CornerRadius = UDim.new(0, 6)})

local fakeNameTextBox = new("TextBox", {
    Parent = fakeNameBg,
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 6, 0, 0),
    BackgroundTransparency = 1,
    Text = currentFakeName,
    PlaceholderText = "Guest",
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextColor3 = colors.text,
    PlaceholderColor3 = colors.textDimmer,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 9
})

fakeNameTextBox.FocusLost:Connect(function()
    local value = fakeNameTextBox.Text
    if value and value ~= "" then
        currentFakeName = value
        SetConfigValue("Settings.HideStats.FakeName", value)
        SaveCurrentConfig()
        if HideStats then
            pcall(function() HideStats.SetFakeName(value) end)
            SendNotification("Hide Stats", "Fake name set: " .. value, 2)
        end
    end
end)

-- Fake Level Input
local fakeLevelFrame = new("Frame", {
    Parent = catHideStats,
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    ZIndex = 7
})

new("TextLabel", {
    Parent = fakeLevelFrame,
    Text = "Fake Level",
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    TextColor3 = colors.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    ZIndex = 8
})

local fakeLevelBg = new("Frame", {
    Parent = fakeLevelFrame,
    Size = UDim2.new(1, 0, 0, 35),
    Position = UDim2.new(0, 0, 0, 22),
    BackgroundColor3 = colors.bg4,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 8
})
new("UICorner", {Parent = fakeLevelBg, CornerRadius = UDim.new(0, 6)})

local fakeLevelTextBox = new("TextBox", {
    Parent = fakeLevelBg,
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 6, 0, 0),
    BackgroundTransparency = 1,
    Text = currentFakeLevel,
    PlaceholderText = "1",
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextColor3 = colors.text,
    PlaceholderColor3 = colors.textDimmer,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 9
})

fakeLevelTextBox.FocusLost:Connect(function()
    local value = fakeLevelTextBox.Text
    if value and value ~= "" then
        currentFakeLevel = value
        SetConfigValue("Settings.HideStats.FakeLevel", value)
        SaveCurrentConfig()
        if HideStats then
            pcall(function() HideStats.SetFakeLevel(value) end)
            SendNotification("Hide Stats", "Fake level set: " .. value, 2)
        end
    end
end)

ToggleReferences.HideStats = makeToggle(catHideStats, "⚡ Enable Hide Stats", function(on)
    SetConfigValue("Settings.HideStats.Enabled", on)
    SaveCurrentConfig()
    
    if not HideStats then
        SendNotification("Error", "Hide Stats module tidak tersedia!", 3)
        return
    end
    
    if on then
        pcall(function()
            if currentFakeName ~= "" and currentFakeName ~= "Guest" then
                HideStats.SetFakeName(currentFakeName)
            end
            if currentFakeLevel ~= "" and currentFakeLevel ~= "1" then
                HideStats.SetFakeLevel(currentFakeLevel)
            end
            HideStats.Enable()
        end)
        SendNotification("Hide Stats", "✓ Hide Stats aktif!\nName: " .. currentFakeName .. " | Level: " .. currentFakeLevel, 4)
    else
        pcall(function() HideStats.Disable() end)
        SendNotification("Hide Stats", "✓ Hide Stats dimatikan!", 3)
    end
end)

-- Server Features
local catServer = makeCategory(settingsPage, "Server Features", "🔄")

makeButton(catServer, "Rejoin Server", function()
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        TeleportService:Teleport(game.PlaceId, localPlayer)
    end)
    SendNotification("Rejoin", "Teleporting to new server...", 3)
end)

-- Config Management
local catConfig = makeCategory(settingsPage, "Configuration Management", "💾")

local configStatusContainer = new("Frame", {
    Parent = catConfig,
    Size = UDim2.new(1, 0, 0, 85),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    ZIndex = 7
})
new("UICorner", {Parent = configStatusContainer, CornerRadius = UDim.new(0, 8)})

local configStatusText = new("TextLabel", {
    Parent = configStatusContainer,
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "Loading config status...",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 8
})

makeButton(catConfig, "💾 Save Current Config", function()
    if ConfigSystem then
        local success, message = ConfigSystem.Save()
        if success then
            SendNotification("Config", "✓ Configuration saved!", 3)
        else
            SendNotification("Config Error", message or "Failed to save", 3)
        end
    else
        SendNotification("Error", "ConfigSystem not loaded!", 3)
    end
end)

makeButton(catConfig, "🔄 Reload Config", function()
    if ConfigSystem then
        local success = ConfigSystem.Load()
        if success then
            SendNotification("Config", "✓ Configuration reloaded!", 3)
        else
            SendNotification("Config", "⚠ No saved config found", 3)
        end
    else
        SendNotification("Error", "ConfigSystem not loaded!", 3)
    end
end)

makeButton(catConfig, "🔃 Reset to Default", function()
    if ConfigSystem then
        local success, message = ConfigSystem.Reset()
        if success then
            SendNotification("Config", "✓ Reset to defaults!", 3)
        else
            SendNotification("Error", message or "Failed to reset", 3)
        end
    else
        SendNotification("Error", "ConfigSystem not loaded!", 3)
    end
end)

makeButton(catConfig, "🗑️ Delete Config File", function()
    if ConfigSystem then
        if ConfigSystem.Delete() then
            SendNotification("Config", "✓ Config file deleted!", 3)
        else
            SendNotification("Config", "⚠ No config file found", 3)
        end
    else
        SendNotification("Error", "ConfigSystem not loaded!", 3)
    end
end)

task.spawn(function()
    task.wait(1)
    pcall(function()
        if ConfigSystem and configStatusText and configStatusText.Parent then
            local hasConfigFile = false
            pcall(function() hasConfigFile = isfile("LynxGUI_Configs/lynx_config.json") end)
            
            local statusIcon = hasConfigFile and "✅" or "⚠️"
            local statusMsg = hasConfigFile and "Config file exists" or "No config saved yet"
            
            configStatusText.Text = string.format(
                "📦 CONFIG STATUS\n%s %s\n\n💡 Settings auto-save on change!\n📁 Folder: LynxGUI_Configs\n📄 File: lynx_config.json",
                statusIcon, statusMsg
            )
        end
    end)
end)

-- INFO PAGE
local infoContainer = new("Frame", {
    Parent = infoPage,
    Size = UDim2.new(1, 0, 0, 200),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex = 6
})
new("UICorner", {Parent = infoContainer, CornerRadius = UDim.new(0, 8)})

new("TextLabel", {
    Parent = infoContainer,
    Size = UDim2.new(1, -24, 0, 100),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "# LynX v2.3 Optimized\nFree Not For Sale\n━━━━━━━━━━━━━━━━━━━━━━\nCreated by Beee\nRefined Edition 2024",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 7
})

local linkButton = new("TextButton", {
    Parent = infoContainer,
    Size = UDim2.new(1, -24, 0, 25),
    Position = UDim2.new(0, 12, 0, 115),
    BackgroundTransparency = 1,
    Text = "🔗 Discord: https://discord.gg/6Rpvm2gQ",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(88, 101, 242),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7
})

linkButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/6Rpvm2gQ")
    linkButton.Text = "✅ Link copied to clipboard!"
    task.wait(2)
    linkButton.Text = "🔗 Discord: https://discord.gg/6Rpvm2gQ"
end)

-- Module Status
local moduleStatusContainer = new("Frame", {
    Parent = infoPage,
    Size = UDim2.new(1, 0, 0, 150),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex = 6
})
new("UICorner", {Parent = moduleStatusContainer, CornerRadius = UDim.new(0, 8)})

local moduleStatusText = new("TextLabel", {
    Parent = moduleStatusContainer,
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "Loading module status...",
    Font = Enum.Font.Gotham,
    TextSize = 8,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 7
})

task.spawn(function()
    task.wait(0.5)
    pcall(function()
        if moduleStatusText and moduleStatusText.Parent then
            local statusText = "📦 MODULE STATUS (" .. loadedModules .. "/" .. totalModules .. " loaded)\n━━━━━━━━━━━━━━━━━━━━━━\n"
            
            local sortedModules = {}
            for name, status in pairs(ModuleStatus) do
                table.insert(sortedModules, {name = name, status = status})
            end
            table.sort(sortedModules, function(a, b) return a.name < b.name end)
            
            for _, moduleInfo in ipairs(sortedModules) do
                statusText = statusText .. moduleInfo.status .. " " .. moduleInfo.name .. "\n"
            end
            
            moduleStatusText.Text = statusText
        end
    end)
end)

-- MINIMIZE SYSTEM
local minimized = false
local icon
local savedIconPos = UDim2.new(0, 20, 0, 100)

local function createMinimizedIcon()
    if icon then return end
    
    icon = new("ImageLabel", {
        Parent = gui,
        Size = UDim2.new(0, 50, 0, 50),
        Position = savedIconPos,
        BackgroundColor3 = colors.bg2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Image = "rbxassetid://118176705805619",
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 100
    })
    new("UICorner", {Parent = icon, CornerRadius = UDim.new(0, 10)})
    
    local dragging, dragStart, startPos, dragMoved = false, nil, nil, false
    
    icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragMoved, dragStart, startPos = true, false, input.Position, icon.Position
        end
    end)
    
    icon.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.sqrt(delta.X^2 + delta.Y^2) > 5 then dragMoved = true end
            icon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    icon.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                savedIconPos = icon.Position
                if not dragMoved then
                    bringToFront()
                    win.Visible = true
                    TweenService:Create(win, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = windowSize,
                        Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
                    }):Play()
                    if icon then icon:Destroy() icon = nil end
                    minimized = false
                end
            end
        end
    end)
end

btnMinHeader.MouseButton1Click:Connect(function()
    if not minimized then
        TweenService:Create(win, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.35)
        win.Visible = false
        createMinimizedIcon()
        minimized = true
    end
end)

-- DRAGGING SYSTEM
local dragging, dragStart, startPos = false, nil, nil

scriptHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bringToFront()
        dragging, dragStart, startPos = true, input.Position, win.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- RESIZING SYSTEM
local resizeStart, startSize = nil, nil

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing, resizeStart, startSize = true, input.Position, win.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        local newWidth = math.clamp(startSize.X.Offset + delta.X, minWindowSize.X, maxWindowSize.X)
        local newHeight = math.clamp(startSize.Y.Offset + delta.Y, minWindowSize.Y, maxWindowSize.Y)
        win.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

-- OPENING ANIMATION
task.spawn(function()
    win.Size = UDim2.new(0, 0, 0, 0)
    win.Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
    win.BackgroundTransparency = 1
    
    task.wait(0.1)
    
    TweenService:Create(win, TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
        Size = windowSize
    }):Play()
    
    TweenService:Create(win, TweenInfo.new(0.5), {
        BackgroundTransparency = 0.25
    }):Play()
end)

-- APPLY CONFIG ON STARTUP
local function ApplyLoadedConfig()
    if not ConfigSystem then return end
    
    task.spawn(function()
        task.wait(0.5)
        
        -- Main Page - Auto Fishing
        if ToggleReferences.InstantFishing then
            local enabled = GetConfigValue("InstantFishing.Enabled", false)
            ToggleReferences.InstantFishing.setOn(enabled, true)
            isInstantFishingEnabled = enabled
        end
        
        -- Blatant Modes
        if ToggleReferences.BlatantTester then
            ToggleReferences.BlatantTester.setOn(GetConfigValue("BlatantTester.Enabled", false), true)
        end
        if ToggleReferences.BlatantV1 then
            ToggleReferences.BlatantV1.setOn(GetConfigValue("BlatantV1.Enabled", false), true)
        end
        if ToggleReferences.UltraBlatant then
            ToggleReferences.UltraBlatant.setOn(GetConfigValue("UltraBlatant.Enabled", false), true)
        end
        if ToggleReferences.FastAutoPerfect then
            ToggleReferences.FastAutoPerfect.setOn(GetConfigValue("FastAutoPerfect.Enabled", false), true)
        end
        
        -- Support Features
        if ToggleReferences.NoFishingAnimation then
            ToggleReferences.NoFishingAnimation.setOn(GetConfigValue("Support.NoFishingAnimation", false), true)
        end
        if ToggleReferences.LockPosition then
            ToggleReferences.LockPosition.setOn(GetConfigValue("Support.LockPosition", false), true)
        end
        if ToggleReferences.AutoEquipRod then
            ToggleReferences.AutoEquipRod.setOn(GetConfigValue("Support.AutoEquipRod", false), true)
        end
        if ToggleReferences.DisableCutscenes then
            ToggleReferences.DisableCutscenes.setOn(GetConfigValue("Support.DisableCutscenes", false), true)
        end
        if ToggleReferences.DisableObtainedNotif then
            ToggleReferences.DisableObtainedNotif.setOn(GetConfigValue("Support.DisableObtainedNotif", false), true)
        end
        if ToggleReferences.DisableSkinEffect then
            ToggleReferences.DisableSkinEffect.setOn(GetConfigValue("Support.DisableSkinEffect", false), true)
        end
        if ToggleReferences.WalkOnWater then
            ToggleReferences.WalkOnWater.setOn(GetConfigValue("Support.WalkOnWater", false), true)
        end
        if ToggleReferences.GoodPerfectionStable then
            ToggleReferences.GoodPerfectionStable.setOn(GetConfigValue("Support.GoodPerfectionStable", false), true)
        end
        
        -- Teleport
        if ToggleReferences.AutoTeleportEvent then
            ToggleReferences.AutoTeleportEvent.setOn(GetConfigValue("Teleport.AutoTeleportEvent", false), true)
        end
        
        -- Shop
        if ToggleReferences.AutoSellTimer then
            ToggleReferences.AutoSellTimer.setOn(GetConfigValue("Shop.AutoSellTimer.Enabled", false), true)
        end
        if ToggleReferences.AutoBuyWeather then
            ToggleReferences.AutoBuyWeather.setOn(GetConfigValue("Shop.AutoBuyWeather.Enabled", false), true)
        end
        
        -- Webhook
        if ToggleReferences.Webhook then
            ToggleReferences.Webhook.setOn(GetConfigValue("Webhook.Enabled", false), true)
        end
        
        -- Camera View
        if ToggleReferences.UnlimitedZoom then
            ToggleReferences.UnlimitedZoom.setOn(GetConfigValue("CameraView.UnlimitedZoom", false), true)
        end
        if ToggleReferences.Freecam then
            ToggleReferences.Freecam.setOn(GetConfigValue("CameraView.Freecam.Enabled", false), true)
        end
        
        -- Settings
        if ToggleReferences.AntiAFK then
            ToggleReferences.AntiAFK.setOn(GetConfigValue("Settings.AntiAFK", false), true)
        end
        if ToggleReferences.FPSBooster then
            ToggleReferences.FPSBooster.setOn(GetConfigValue("Settings.FPSBooster", false), true)
        end
        if ToggleReferences.DisableRendering then
            ToggleReferences.DisableRendering.setOn(GetConfigValue("Settings.DisableRendering", false), true)
        end
        if ToggleReferences.HideStats then
            ToggleReferences.HideStats.setOn(GetConfigValue("Settings.HideStats.Enabled", false), true)
        end
    end)

    -- Start Modules Based on Config
    task.spawn(function()
        task.wait(1)
        
        -- Auto Fishing
        if GetConfigValue("InstantFishing.Enabled", false) then
            local instant = GetModule("instant")
            local instant2 = GetModule("instant2")
            if currentInstantMode == "Fast" and instant then
                instant.Settings.MaxWaitTime = fishingDelayValue
                instant.Settings.CancelDelay = cancelDelayValue
                instant.Start()
            elseif currentInstantMode == "Perfect" and instant2 then
                instant2.Settings.MaxWaitTime = fishingDelayValue
                instant2.Settings.CancelDelay = cancelDelayValue
                instant2.Start()
            end
        end
        
        -- Support Features
        if GetConfigValue("Support.NoFishingAnimation", false) then
            local NoFishingAnimation = GetModule("NoFishingAnimation")
            if NoFishingAnimation then NoFishingAnimation.StartWithDelay() end
        end
        
        if GetConfigValue("Support.LockPosition", false) then
            local LockPosition = GetModule("LockPosition")
            if LockPosition then LockPosition.Start() end
        end
        
        if GetConfigValue("Support.AutoEquipRod", false) then
            local AutoEquipRod = GetModule("AutoEquipRod")
            if AutoEquipRod then AutoEquipRod.Start() end
        end
        
        if GetConfigValue("Support.DisableCutscenes", false) then
            local DisableCutscenes = GetModule("DisableCutscenes")
            if DisableCutscenes then DisableCutscenes.Start() end
        end
        
        if GetConfigValue("Support.DisableObtainedNotif", false) then
            local DisableExtras = GetModule("DisableExtras")
            if DisableExtras then DisableExtras.StartSmallNotification() end
        end
        
        if GetConfigValue("Support.DisableSkinEffect", false) then
            local DisableExtras = GetModule("DisableExtras")
            if DisableExtras then DisableExtras.StartSkinEffect() end
        end
        
        if GetConfigValue("Support.WalkOnWater", false) then
            local WalkOnWater = GetModule("WalkOnWater")
            if WalkOnWater then WalkOnWater.Start() end
        end
        
        if GetConfigValue("Support.GoodPerfectionStable", false) then
            local GoodPerfectionStable = GetModule("GoodPerfectionStable")
            if GoodPerfectionStable then GoodPerfectionStable.Start() end
        end
        
        -- Blatant Modes
        if GetConfigValue("BlatantTester.Enabled", false) then
            local blatantv2fix = GetModule("blatantv2fix")
            if blatantv2fix then blatantv2fix.Start() end
        end
        
        if GetConfigValue("BlatantV1.Enabled", false) then
            local blatantv1 = GetModule("blatantv1")
            if blatantv1 then blatantv1.Start() end
        end
        
        if GetConfigValue("UltraBlatant.Enabled", false) then
            local UltraBlatant = GetModule("UltraBlatant")
            if UltraBlatant then UltraBlatant.Start() end
        end
        
        if GetConfigValue("FastAutoPerfect.Enabled", false) then
            local blatantv2 = GetModule("blatantv2")
            if blatantv2 then blatantv2.Start() end
        end
        
        -- Teleport
        if GetConfigValue("Teleport.AutoTeleportEvent", false) and EventTeleport then
            if selectedEventName and selectedEventName ~= "- No events available -" and EventTeleport.HasCoords(selectedEventName) then
                EventTeleport.Start(selectedEventName)
            end
        end
        
        -- Shop
        if GetConfigValue("Shop.AutoSellTimer.Enabled", false) and AutoSellTimer then
            local interval = GetConfigValue("Shop.AutoSellTimer.Interval", 5)
            pcall(function()
                AutoSellTimer.SetInterval(interval)
                AutoSellTimer.Start(interval)
            end)
        end
        
        if GetConfigValue("Shop.AutoBuyWeather.Enabled", false) and AutoBuyWeather then
            local savedWeathers = GetConfigValue("Shop.AutoBuyWeather.SelectedWeathers", {})
            if #savedWeathers > 0 then
                AutoBuyWeather.SetSelected(savedWeathers)
                AutoBuyWeather.Start()
            end
        end
        
        -- Webhook
        if WebhookModule and GetConfigValue("Webhook.Enabled", false) then
            local savedURL = GetConfigValue("Webhook.URL", "")
            local savedID = GetConfigValue("Webhook.DiscordID", "")
            local savedRarities = GetConfigValue("Webhook.EnabledRarities", {})
            
            if savedURL ~= "" then
                pcall(function()
                    WebhookModule:SetWebhookURL(savedURL)
                    if savedID ~= "" then
                        WebhookModule:SetDiscordUserID(savedID)
                    end
                    if #savedRarities > 0 and rarityCheckboxSystem then
                        rarityCheckboxSystem.SelectSpecific(savedRarities)
                        WebhookModule:SetEnabledRarities(savedRarities)
                    end
                    WebhookModule:Start()
                end)
            end
        end
        
        -- Camera View
        if GetConfigValue("CameraView.UnlimitedZoom", false) and UnlimitedZoomModule then
            UnlimitedZoomModule.Enable()
        end
        
        if GetConfigValue("CameraView.Freecam.Enabled", false) and FreecamModule then
            if not isMobile then
                FreecamModule.EnableF3Keybind(true)
            else
                FreecamModule.Start()
            end
        end
        
        -- Settings
        if GetConfigValue("Settings.AntiAFK", false) and AntiAFK then
            AntiAFK.Start()
        end
        
        if GetConfigValue("Settings.FPSBooster", false) and FPSBooster then
            FPSBooster.Enable()
        end
        
        if GetConfigValue("Settings.DisableRendering", false) and DisableRenderingModule then
            DisableRenderingModule.Start()
        end
        
        local savedFPS = GetConfigValue("Settings.FPSLimit", nil)
        if savedFPS and UnlockFPS then
            UnlockFPS.SetCap(savedFPS)
        end
        
        -- Hide Stats
        if HideStats and GetConfigValue("Settings.HideStats.Enabled", false) then
            local savedName = GetConfigValue("Settings.HideStats.FakeName", "Guest")
            local savedLevel = GetConfigValue("Settings.HideStats.FakeLevel", "1")
            
            pcall(function()
                HideStats.SetFakeName(savedName)
                HideStats.SetFakeLevel(savedLevel)
                HideStats.Enable()
            end)
        end
        
        -- Skin Animation
        if GetConfigValue("Support.SkinAnimation.Enabled", false) then
            local SkinAnimation = GetModule("SkinAnimation")
            if SkinAnimation then
                local savedSkin = GetConfigValue("Support.SkinAnimation.Current", "Eclipse")
                pcall(function()
                    SkinAnimation.SwitchSkin(savedSkin)
                    SkinAnimation.Enable()
                end)
            end
        end
    end)
end

-- Apply Config on Startup
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        ApplyLoadedConfig()
    end)
end)

-- PERFORMANCE OPTIMIZATIONS
-- Reduce GUI Update Frequency for Low-End Devices
if isMobile or UserInputService:GetPlatform() == Enum.Platform.Android or UserInputService:GetPlatform() == Enum.Platform.IOS then
    -- Disable animations for mobile
    local function disableAnimations(obj)
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("UIGradient") then
                child.Enabled = false
            end
        end
    end
    
    task.spawn(function()
        task.wait(2)
        disableAnimations(gui)
    end)
end

-- Cleanup disconnected connections
local connections = {}

local function addConnection(conn)
    table.insert(connections, conn)
end

local function cleanupConnections()
    for _, conn in ipairs(connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    connections = {}
end

-- Cleanup on GUI destroy
gui.Destroying:Connect(function()
    cleanupConnections()
    
    -- Stop all active modules
    for _, module in pairs(Modules) do
        if module and type(module) == "table" then
            if module.Stop then
                pcall(function() module.Stop() end)
            end
        end
    end
end)

-- FINAL SUCCESS NOTIFICATION
SendNotification("✨ Lynx GUI v2.3", "Loaded! " .. loadedModules .. "/" .. totalModules .. " modules ready.", 5)
-- CONSOLE OUTPUT (Minimal)
print("━━━━━━━━━━━━━━━━━━━━━━")
print("✨ Lynx GUI v2.3 Optimized")
print("━━━━━━━━━━━━━━━━━━━━━━")
print("📦 Modules: " .. loadedModules .. "/" .. totalModules)

local hideStatsOK = (HideStats ~= nil)
local webhookOK = (WebhookModule ~= nil)
local notifyOK = (GetModule("Notify") ~= nil)

print("✅ HideStats: " .. (hideStatsOK and "OK" or "MISSING"))
print("✅ Webhook: " .. (webhookOK and "OK" or "MISSING"))
print("✅ Notify: " .. (notifyOK and "OK" or "MISSING"))

if hideStatsOK and webhookOK and notifyOK then
    print("🎉 All critical systems operational!")
else
    print("⚠️  Some modules missing")
end

print("━━━━━━━━━━━━━━━━━━━━━━")
print("🎮 GUI Ready!")
print("━━━━━━━━━━━━━━━━━━━━━━")

-- ============================================
-- OPTIMIZATION FEATURES
-- ============================================

-- 1. Reduced Memory Footprint
--    - Cleared unused variables after initialization
--    - Removed excessive logging
--    - Optimized module loading

-- 2. Performance Enhancements
--    - Disabled animations on mobile devices
--    - Reduced tween complexity
--    - Optimized scroll frame rendering

-- 3. Low-End Device Support
--    - Automatic performance mode detection
--    - Reduced visual effects on mobile
--    - Memory cleanup after initialization

-- 4. Code Optimization
--    - Removed redundant code
--    - Simplified function calls
--    - Reduced nested loops

-- 5. Config System
--    - Auto-save on change
--    - State restoration on load
--    - Persistent settings across sessions

-- ============================================
-- FEATURES SUMMARY
-- ============================================

-- Core Features:
-- ✓ Auto Fishing (Fast & Perfect modes)
-- ✓ Blatant Fishing Modes (V1, V2, Tester)
-- ✓ Support Features (No Animation, Lock Position, etc.)
-- ✓ Auto Totem & Skin Animation
-- ✓ Teleport System (Location, Player, Event)
-- ✓ Shop Features (Auto Sell, Buy Weather, Remote Merchant)
-- ✓ Webhook Integration with Rarity Filters
-- ✓ Camera View (Unlimited Zoom, Freecam)
-- ✓ Performance Settings (FPS Booster, Anti-AFK)
-- ✓ Hide Stats System
-- ✓ Config Management (Save/Load/Reset)

-- GUI Features:
-- ✓ Modern UI with smooth animations
-- ✓ Draggable & Resizable window
-- ✓ Minimize to icon
-- ✓ Navigation system with 7 pages
-- ✓ Dropdown & Checkbox components
-- ✓ Toggle & Input components
-- ✓ Category collapsible sections
-- ✓ Auto-save configuration
-- ✓ State restoration on startup

-- Optimization Features:
-- ✓ Mobile device support
-- ✓ Low-end device optimization
-- ✓ Memory cleanup
-- ✓ Performance mode
-- ✓ Reduced visual effects on mobile
-- ✓ Efficient rendering

-- ============================================
-- DEVICE-SPECIFIC OPTIMIZATIONS
-- ============================================

if isMobile then
    -- Mobile-specific optimizations
    task.spawn(function()
        task.wait(3)
        
        -- Reduce scroll sensitivity
        for _, page in pairs(pages) do
            if page:IsA("ScrollingFrame") then
                page.ScrollingEnabled = true
                page.ScrollBarThickness = 4
            end
        end
        
        -- Increase touch target sizes
        for _, btn in pairs(navButtons) do
            if btn.btn then
                btn.btn.Size = UDim2.new(1, 0, 0, 42)
            end
        end
    end)
end

-- Low-end device detection
local function isLowEndDevice()
    local fps = 0
    local frameCount = 0
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if frameCount >= 60 then
            fps = frameCount / 1
            conn:Disconnect()
        end
    end)
    
    task.wait(1.5)
    
    return fps < 30
end

-- Apply low-end optimizations if needed
task.spawn(function()
    task.wait(2)
    
    if isLowEndDevice() then
        -- Disable unnecessary visual effects
        pcall(function()
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("UIGradient") then
                    obj.Enabled = false
                elseif obj:IsA("UIStroke") then
                    obj.Enabled = false
                end
            end
        end)
        
        -- Reduce tween speed
        for _, btn in pairs(navButtons) do
            if btn.btn then
                btn.btn.AutoButtonColor = true
            end
        end
    end
end)

-- ERROR HANDLING & RECOVERY
-- Global error handler
local function safeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        warn("Error:", err)
    end
    return success
end

-- Module safety wrapper
local function safeModuleCall(moduleName, methodName, ...)
    local module = GetModule(moduleName)
    if module and module[methodName] then
        return safeCall(module[methodName], ...)
    end
    return false
end

-- FINALIZATION
-- Mark GUI as fully loaded
local guiLoaded = true

-- Export functions (if needed)
local LynxGUI = {
    Version = "2.3.0",
    IsLoaded = function() return guiLoaded end,
    GetModule = GetModule,
    GetConfig = GetConfigValue,
    SetConfig = SetConfigValue,
    SaveConfig = SaveCurrentConfig,
}

-- Make accessible globally (optional)
_G.LynxGUI = LynxGUI

-- Cleanup function
function LynxGUI:Destroy()
    if gui then
        gui:Destroy()
    end
    cleanupConnections()
    guiLoaded = false
end

-- Final console output
print("\n✅ LynxGUI v2.3 Optimized - Fully Loaded!")
print("💾 Config System: " .. (ConfigSystem and "Active" or "Inactive"))
print("📱 Device: " .. (isMobile and "Mobile" or "Desktop"))
print("⚡ Performance Mode: " .. (isLowEndDevice() and "Enabled" or "Standard"))
print("\n🎮 Enjoy!\n")

-- FINAL NOTIFICATION
SendNotification("✨ Lynx GUI v2.3", "Loaded! " .. loadedModules .. "/" .. totalModules .. " modules ready.", 5)
