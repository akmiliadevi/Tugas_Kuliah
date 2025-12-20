-- LynxGUI_v2.3.lua - Galaxy Edition (OPTIMIZED)
-- BAGIAN 1/6: Core Setup, Services, Loading System
-- FREE NOT FOR SALE

repeat task.wait() until game:IsLoaded()

-- ============================================
-- SERVICES & CORE VARIABLES
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

repeat task.wait() until localPlayer:FindFirstChild("PlayerGui")

-- Detect platform
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
            Icon = "rbxassetid://111416780887356"
        })
    end)
end

-- ============================================
-- MODULE LOADING SYSTEM WITH ERROR HANDLING
-- ============================================
local Modules = {}
local ModuleStatus = {}
local totalModules = 0
local loadedModules = 0
local DEBUG_MODE = false -- Set true untuk debug

-- Send initial loading notification
SendNotification("🎣 Lynx Script", "Loading modules, please wait...", 3)

-- Load Security Loader
local SecurityLoader
local loaderSuccess = pcall(function()
    SecurityLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/akmiliadevi/Tugas_Kuliah/refs/heads/main/SecurityLoader.lua"))()
end)

if not loaderSuccess then
    SendNotification("❌ Error", "Failed to load SecurityLoader!", 5)
    warn("❌ SecurityLoader failed to load")
else
    if DEBUG_MODE then
        print("✅ SecurityLoader loaded successfully")
    end
end

-- Module list - MATCHED WITH SecurityLoader (35 modules)
local ModuleList = {
    "instant", "instant2", "blatantv1", "UltraBlatant", "blatantv2", "blatantv2fix",
    "NoFishingAnimation", "LockPosition", "AutoEquipRod", "DisableCutscenes",
    "DisableExtras", "AutoTotem3X", "SkinAnimation", "WalkOnWater",
    "TeleportModule", "TeleportToPlayer", "SavedLocation", "AutoQuestModule",
    "AutoTemple", "TempleDataReader", "AutoSell", "AutoSellTimer",
    "MerchantSystem", "RemoteBuyer", "FreecamModule", "UnlimitedZoomModule",
    "AntiAFK", "UnlockFPS", "FPSBooster", "AutoBuyWeather", "Notify",
    "GoodPerfectionStable", "EventTeleportDynamic", "HideStats", "Webhook"
}

totalModules = #ModuleList

-- Load modules asynchronously
local function LoadModules()
    if not SecurityLoader then
        warn("❌ Cannot load modules: SecurityLoader not available")
        SendNotification("❌ Critical Error", "SecurityLoader failed to initialize!", 5)
        return
    end
    
    for _, moduleName in ipairs(ModuleList) do
        task.spawn(function()
            local success, result = pcall(function()
                return SecurityLoader.LoadModule(moduleName)
            end)
            
            if success and result then
                Modules[moduleName] = result
                ModuleStatus[moduleName] = "✅ Loaded"
                loadedModules = loadedModules + 1
                
                if DEBUG_MODE then
                    print("✅ " .. moduleName .. " loaded successfully")
                end
            else
                Modules[moduleName] = nil
                ModuleStatus[moduleName] = "❌ Failed"
                
                if DEBUG_MODE then
                    warn("❌ " .. moduleName .. " failed to load: " .. tostring(result))
                end
            end
        end)
    end
    
    -- Wait for critical modules (at least 50%)
    local maxWait = 15 -- Increased from 10 to 15 seconds
    local waited = 0
    while loadedModules < totalModules * 0.5 and waited < maxWait do
        task.wait(0.5)
        waited = waited + 0.5
    end
    
    local loadPercent = math.floor((loadedModules / totalModules) * 100)
    SendNotification("✨ Lynx Script Ready", 
        loadedModules .. "/" .. totalModules .. " modules loaded (" .. loadPercent .. "%)", 
        4)
    
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("✨ Lynx GUI v2.3")
    print("FREE NOT FOR SALE")
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("📦 Modules: " .. loadedModules .. "/" .. totalModules .. " loaded")
    
    if DEBUG_MODE then
        print("━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 MODULE STATUS:")
        for name, status in pairs(ModuleStatus) do
            print(status .. " " .. name)
        end
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━")
end

-- Start loading
if SecurityLoader then
    LoadModules()
else
    warn("⚠️ GUI will run with limited functionality (no SecurityLoader)")
    SendNotification("⚠️ Warning", "Running in limited mode - some features may not work!", 5)
end

-- Safe module getter with error reporting
local function GetModule(name)
    if not Modules[name] then
        if DEBUG_MODE then
            warn("⚠️ Module '" .. name .. "' not loaded or failed to load")
        end
    end
    return Modules[name]
end

-- ============================================
-- COLOR PALETTE
-- ============================================
local colors = {
    primary = Color3.fromRGB(255, 140, 0),
    secondary = Color3.fromRGB(147, 112, 219),
    accent = Color3.fromRGB(186, 85, 211),
    galaxy1 = Color3.fromRGB(123, 104, 238),
    galaxy2 = Color3.fromRGB(72, 61, 139),
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
    glow = Color3.fromRGB(138, 43, 226),
}

-- Window configuration
local windowSize = UDim2.new(0, 420, 0, 280)
local minWindowSize = Vector2.new(380, 250)
local maxWindowSize = Vector2.new(550, 400)
local sidebarWidth = 140

-- ============================================
-- BAGIAN 2/6: GUI Structure & Window Creation
-- ============================================

local gui = new("ScreenGui", {
    Name = "LynxGUI_Galaxy",
    Parent = localPlayer.PlayerGui,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 2147483647
})

local function bringToFront()
    gui.DisplayOrder = 2147483647
end

-- Main Window Container
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

-- Inner shadow effect
local innerShadow = new("Frame", {
    Parent = win,
    Size = UDim2.new(1, -2, 1, -2),
    Position = UDim2.new(0, 1, 0, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 2
})
new("UICorner", {Parent = innerShadow, CornerRadius = UDim.new(0, 11)})
new("UIStroke", {
    Parent = innerShadow,
    Color = Color3.fromRGB(0, 0, 0),
    Thickness = 1,
    Transparency = 0.8
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
new("UIStroke", {
    Parent = sidebar,
    Color = colors.primary,
    Thickness = 1,
    Transparency = 0.95
})

-- Script Header
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

-- Gradient overlay
local gradient = new("UIGradient", {
    Parent = scriptHeader,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(72, 61, 139))
    },
    Rotation = 45,
    Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.97),
        NumberSequenceKeypoint.new(1, 0.99)
    }
})

-- Drag Handle
local headerDragHandle = new("Frame", {
    Parent = scriptHeader,
    Size = UDim2.new(0, 40, 0, 3),
    Position = UDim2.new(0.5, -20, 0, 8),
    BackgroundColor3 = colors.primary,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    ZIndex = 6
})
new("UICorner", {Parent = headerDragHandle, CornerRadius = UDim.new(1, 0)})
new("UIStroke", {
    Parent = headerDragHandle,
    Color = colors.primary,
    Thickness = 1,
    Transparency = 0.85
})

-- Title with glow
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
    TextStrokeTransparency = 0.9,
    TextStrokeColor3 = colors.primary,
    ZIndex = 6
})

-- Title glow effect
local titleGlow = new("TextLabel", {
    Parent = scriptHeader,
    Text = "LynX",
    Size = titleLabel.Size,
    Position = titleLabel.Position,
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextColor3 = colors.primary,
    TextTransparency = 0.7,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
})

-- Animated glow pulse
task.spawn(function()
    while true do
        TweenService:Create(titleGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0.4
        }):Play()
        task.wait(2)
        TweenService:Create(titleGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0.7
        }):Play()
        task.wait(2)
    end
end)

-- Separator
local separator = new("Frame", {
    Parent = scriptHeader,
    Size = UDim2.new(0, 2, 0, 25),
    Position = UDim2.new(0, 95, 0.5, -12.5),
    BackgroundColor3 = colors.primary,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 6
})
new("UICorner", {Parent = separator, CornerRadius = UDim.new(1, 0)})
new("UIStroke", {
    Parent = separator,
    Color = colors.primary,
    Thickness = 1,
    Transparency = 0.7
})

local subtitleLabel = new("TextLabel", {
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

-- Minimize button
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
        BackgroundColor3 = colors.galaxy1,
        BackgroundTransparency = 0.2,
        TextColor3 = colors.text,
        TextTransparency = 0,
        Size = UDim2.new(0, 32, 0, 32)
    }):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.25), {
        Thickness = 1.5,
        Transparency = 0.4
    }):Play()
end)

btnMinHeader.MouseLeave:Connect(function()
    TweenService:Create(btnMinHeader, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundColor3 = colors.bg4,
        BackgroundTransparency = 0.5,
        TextColor3 = colors.textDim,
        TextTransparency = 0.3,
        Size = UDim2.new(0, 30, 0, 30)
    }):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.25), {
        Thickness = 0,
        Transparency = 0.8
    }):Play()
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
new("UIStroke", {
    Parent = contentBg,
    Color = colors.primary,
    Thickness = 1,
    Transparency = 0.95
})

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
new("UIStroke", {
    Parent = topBar,
    Color = colors.primary,
    Thickness = 1,
    Transparency = 0.95
})

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

local resizeStroke = new("UIStroke", {
    Parent = resizeHandle,
    Color = colors.primary,
    Thickness = 0,
    Transparency = 0.8
})

resizeHandle.MouseEnter:Connect(function()
    TweenService:Create(resizeHandle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 0.3,
        TextTransparency = 0,
        Size = UDim2.new(0, 20, 0, 20)
    }):Play()
    TweenService:Create(resizeStroke, TweenInfo.new(0.25), {
        Thickness = 1.5,
        Transparency = 0.5
    }):Play()
end)

resizeHandle.MouseLeave:Connect(function()
    if not resizing then
        TweenService:Create(resizeHandle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0.6,
            TextTransparency = 0.4,
            Size = UDim2.new(0, 18, 0, 18)
        }):Play()
        TweenService:Create(resizeStroke, TweenInfo.new(0.25), {
            Thickness = 0,
            Transparency = 0.8
        }):Play()
    end
end)

-- Pages
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
    new("UIListLayout", {
        Parent = page,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    new("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4)
    })
    pages[name] = page
    return page
end

-- Create all pages
local mainPage = createPage("Main")
local teleportPage = createPage("Teleport")
local questPage = createPage("Quest")
local shopPage = createPage("Shop")
local webhookPage = createPage("Webhook")
local cameraViewPage = createPage("CameraView")
local settingsPage = createPage("Settings")
local infoPage = createPage("Info")
mainPage.Visible = true

-- ============================================
-- BAGIAN 3/6: Navigation & UI Components
-- ============================================

-- Navigation Button Creation
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
    new("UIStroke", {
        Parent = indicator,
        Color = colors.primary,
        Thickness = 2,
        Transparency = 0.7
    })
    
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
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 0.8
            }):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.3), {
                TextTransparency = 0,
                TextColor3 = colors.primary
            }):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.3), {
                TextTransparency = 0.2
            }):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if page ~= currentPage then
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.3), {
                TextTransparency = 0.3,
                TextColor3 = colors.textDim
            }):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.3), {
                TextTransparency = 0.4
            }):Play()
        end
    end)
    
    navButtons[page] = {btn = btn, icon = iconLabel, text = textLabel, indicator = indicator}
    return btn
end

-- Page Switching Function
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

-- Create Navigation Buttons
local btnMain = createNavButton("Dashboard", "🏠", "Main", 1)
local btnTeleport = createNavButton("Teleport", "🌍", "Teleport", 2)
local btnQuest = createNavButton("Quest", "📜", "Quest", 3)
local btnShop = createNavButton("Shop", "🛒", "Shop", 4)
local btnWebhook = createNavButton("Webhook", "🔗", "Webhook", 5)
local btnCameraView = createNavButton("Camera View", "📷", "CameraView", 6)
local btnSettings = createNavButton("Settings", "⚙️", "Settings", 7)
local btnInfo = createNavButton("About", "ℹ️", "Info", 8)

-- Connect Navigation Buttons
btnMain.MouseButton1Click:Connect(function() switchPage("Main", "Main Dashboard") end)
btnTeleport.MouseButton1Click:Connect(function() switchPage("Teleport", "Teleport System") end)
btnQuest.MouseButton1Click:Connect(function() switchPage("Quest", "Auto Quest") end)
btnShop.MouseButton1Click:Connect(function() switchPage("Shop", "Shop Features") end)
btnWebhook.MouseButton1Click:Connect(function() switchPage("Webhook", "Webhook Page") end)
btnCameraView.MouseButton1Click:Connect(function() switchPage("CameraView", "Camera View Settings") end)
btnSettings.MouseButton1Click:Connect(function() switchPage("Settings", "Settings") end)
btnInfo.MouseButton1Click:Connect(function() switchPage("Info", "About Lynx") end)

-- ============================================
-- UI COMPONENT FUNCTIONS
-- ============================================

-- Category Component
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
    
    local categoryStroke = new("UIStroke", {
        Parent = categoryFrame,
        Color = colors.border,
        Thickness = 0,
        Transparency = 0.8
    })
    
    local header = new("TextButton", {
        Parent = categoryFrame,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        ZIndex = 7
    })
    
    local titleLabel = new("TextLabel", {
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
        ClipsDescendants = true,
        ZIndex = 7
    })
    new("UIListLayout", {Parent = contentContainer, Padding = UDim.new(0, 6)})
    new("UIPadding", {Parent = contentContainer, PaddingBottom = UDim.new(0, 8)})
    
    local isOpen = false
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        contentContainer.Visible = isOpen
        TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = isOpen and 180 or 0}):Play()
        TweenService:Create(categoryFrame, TweenInfo.new(0.25), {
            BackgroundTransparency = isOpen and 0.4 or 0.6
        }):Play()
        TweenService:Create(categoryStroke, TweenInfo.new(0.25), {Thickness = isOpen and 1 or 0}):Play()
    end)
    
    return contentContainer
end

-- Toggle Component
local function makeToggle(parent, label, callback)
    local frame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 7
    })
    
    local labelText = new("TextLabel", {
        Parent = frame,
        Text = label,
        Size = UDim2.new(0.68, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
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
    btn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(toggleBg, TweenInfo.new(0.25), {BackgroundColor3 = on and colors.primary or colors.bg4}):Play()
        TweenService:Create(toggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = on and colors.text or colors.textDim
        }):Play()
        pcall(callback, on)
    end)
end

-- Input Component (Horizontal)
local function makeInput(parent, label, defaultValue, callback)
    local frame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 7
    })
    
    local lbl = new("TextLabel", {
        Parent = frame,
        Text = label,
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
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
    
    local inputStroke = new("UIStroke", {
        Parent = inputBg,
        Color = colors.border,
        Thickness = 1,
        Transparency = 0.7
    })
    
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
    
    inputBox.Focused:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {
            Color = colors.primary,
            Thickness = 1.5,
            Transparency = 0.3
        }):Play()
    end)
    
    inputBox.FocusLost:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {
            Color = colors.border,
            Thickness = 1,
            Transparency = 0.7
        }):Play()
        
        local value = tonumber(inputBox.Text)
        if value then
            pcall(callback, value)
        else
            inputBox.Text = tostring(defaultValue)
        end
    end)
end

-- Button Component
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
    
    local btnStroke = new("UIStroke", {
        Parent = btnFrame,
        Color = colors.primary,
        Thickness = 0,
        Transparency = 0.7
    })
    
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
    
    button.MouseEnter:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, 0, 0, 35)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Thickness = 1.5}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, 32)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Thickness = 0}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 30)}):Play()
        task.wait(0.1)
        TweenService:Create(btnFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 32)}):Play()
        pcall(callback)
    end)
    
    return btnFrame
end

-- ============================================
-- BAGIAN 4/6: Dropdown Component & Main Page Features
-- ============================================

-- Dropdown Component
local function makeDropdown(parent, title, icon, items, onSelect, uniqueId)
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
    
    local dropStroke = new("UIStroke", {
        Parent = dropdownFrame,
        Color = colors.border,
        Thickness = 0,
        Transparency = 0.8
    })
    
    local header = new("TextButton", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, -12, 0, 36),
        Position = UDim2.new(0, 6, 0, 2),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 8
    })
    
    local iconLabel = new("TextLabel", {
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
    
    local titleLabel = new("TextLabel", {
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
    
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listContainer.Visible = isOpen
        
        TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = isOpen and 180 or 0}):Play()
        TweenService:Create(dropdownFrame, TweenInfo.new(0.25), {
            BackgroundTransparency = isOpen and 0.35 or 0.5
        }):Play()
        TweenService:Create(dropStroke, TweenInfo.new(0.25), {Thickness = isOpen and 1 or 0}):Play()
        
        if isOpen then
            listContainer.Size = UDim2.new(1, -12, 0, math.min(#items * 28, 140))
        end
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
        
        local itemStroke = new("UIStroke", {
            Parent = itemBtn,
            Color = colors.border,
            Thickness = 0,
            Transparency = 0.8
        })
        
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
                TweenService:Create(itemBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = colors.primary,
                    BackgroundTransparency = 0.3
                }):Play()
                TweenService:Create(btnLabel, TweenInfo.new(0.2), {TextColor3 = colors.text}):Play()
                TweenService:Create(itemStroke, TweenInfo.new(0.2), {Thickness = 1}):Play()
            end
        end)
        
        itemBtn.MouseLeave:Connect(function()
            if selectedItem ~= itemName then
                TweenService:Create(itemBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = colors.bg4,
                    BackgroundTransparency = 0.6
                }):Play()
                TweenService:Create(btnLabel, TweenInfo.new(0.2), {TextColor3 = colors.textDim}):Play()
                TweenService:Create(itemStroke, TweenInfo.new(0.2), {Thickness = 0}):Play()
            end
        end)
        
        itemBtn.MouseButton1Click:Connect(function()
            selectedItem = itemName
            statusLabel.Text = "✓ " .. itemName
            statusLabel.TextColor3 = colors.success
            pcall(onSelect, itemName)
            
            task.wait(0.1)
            isOpen = false
            listContainer.Visible = false
            TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = 0}):Play()
            TweenService:Create(dropdownFrame, TweenInfo.new(0.25), {
                BackgroundTransparency = 0.5
            }):Play()
            TweenService:Create(dropStroke, TweenInfo.new(0.25), {Thickness = 0}):Play()
        end)
    end
    
    return dropdownFrame
end

-- ============================================
-- MAIN PAGE FEATURES
-- ============================================

-- Auto Fishing Category
local catAutoFishing = makeCategory(mainPage, "Auto Fishing", "🎣")
local currentInstantMode = "None"
local fishingDelayValue = 1.30
local cancelDelayValue = 0.19
local isInstantFishingEnabled = false

makeDropdown(catAutoFishing, "Instant Fishing Mode", "⚡", {"Fast", "Perfect"}, function(mode)
    currentInstantMode = mode
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    
    if instant then instant.Stop() end
    if instant2 then instant2.Stop() end
    
    if isInstantFishingEnabled then
        if mode == "Fast" and instant then
            instant.Settings.MaxWaitTime = fishingDelayValue
            instant.Settings.CancelDelay = cancelDelayValue
            instant.Start()
        elseif mode == "Perfect" and instant2 then
            instant2.Settings.MaxWaitTime = fishingDelayValue
            instant2.Settings.CancelDelay = cancelDelayValue
            instant2.Start()
        end
    else
        if instant then
            instant.Settings.MaxWaitTime = fishingDelayValue
            instant.Settings.CancelDelay = cancelDelayValue
        end
        if instant2 then
            instant2.Settings.MaxWaitTime = fishingDelayValue
            instant2.Settings.CancelDelay = cancelDelayValue
        end
    end
end, "InstantFishingMode")

makeToggle(catAutoFishing, "Enable Instant Fishing", function(on)
    isInstantFishingEnabled = on
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    
    if on then
        if currentInstantMode == "Fast" and instant then
            instant.Start()
        elseif currentInstantMode == "Perfect" and instant2 then
            instant2.Start()
        end
    else
        if instant then instant.Stop() end
        if instant2 then instant2.Stop() end
    end
end)

makeInput(catAutoFishing, "Fishing Delay", 1.30, function(v)
    fishingDelayValue = v
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    if instant then instant.Settings.MaxWaitTime = v end
    if instant2 then instant2.Settings.MaxWaitTime = v end
end)

makeInput(catAutoFishing, "Cancel Delay", 0.19, function(v)
    cancelDelayValue = v
    local instant = GetModule("instant")
    local instant2 = GetModule("instant2")
    if instant then instant.Settings.CancelDelay = v end
    if instant2 then instant2.Settings.CancelDelay = v end
end)

-- Blatant Tester Category
local catBlatantV2 = makeCategory(mainPage, "Blatant Tester", "🎯")

makeToggle(catBlatantV2, "Blatant Tester", function(on)
    local blatantv2fix = GetModule("blatantv2fix")
    if blatantv2fix then
        if on then blatantv2fix.Start() else blatantv2fix.Stop() end
    end
end)

makeInput(catBlatantV2, "Complete Delay", 0.5, function(v)
    local blatantv2fix = GetModule("blatantv2fix")
    if blatantv2fix then
        blatantv2fix.Settings.CompleteDelay = v
    end
end)

makeInput(catBlatantV2, "Cancel Delay", 0.1, function(v)
    local blatantv2fix = GetModule("blatantv2fix")
    if blatantv2fix then
        blatantv2fix.Settings.CancelDelay = v
    end
end)

-- Blatant V1 Category
local catBlatantV1 = makeCategory(mainPage, "Blatant V1", "💀")

makeToggle(catBlatantV1, "Blatant Mode", function(on)
    local blatantv1 = GetModule("blatantv1")
    if blatantv1 then
        if on then blatantv1.Start() else blatantv1.Stop() end
    end
end)

makeInput(catBlatantV1, "Complete Delay", 0.05, function(v)
    local blatantv1 = GetModule("blatantv1")
    if blatantv1 then blatantv1.Settings.CompleteDelay = v end
end)

makeInput(catBlatantV1, "Cancel Delay", 0.1, function(v)
    local blatantv1 = GetModule("blatantv1")
    if blatantv1 then blatantv1.Settings.CancelDelay = v end
end)

-- Ultra Blatant V2 Category
local catUltraBlatant = makeCategory(mainPage, "Blatant V2", "⚡")

makeToggle(catUltraBlatant, "Ultra Blatant Mode", function(on)
    local UltraBlatant = GetModule("UltraBlatant")
    if UltraBlatant then
        if on then UltraBlatant.Start() else UltraBlatant.Stop() end
    end
end)

makeInput(catUltraBlatant, "Complete Delay", 0.05, function(v)
    local UltraBlatant = GetModule("UltraBlatant")
    if UltraBlatant then UltraBlatant.UpdateSettings(v, nil, nil) end
end)

makeInput(catUltraBlatant, "Cancel Delay", 0.1, function(v)
    local UltraBlatant = GetModule("UltraBlatant")
    if UltraBlatant then UltraBlatant.UpdateSettings(nil, v, nil) end
end)

-- Fast Auto Fishing Perfect Category
local catBlatantV2Fast = makeCategory(mainPage, "Fast Auto Fishing Perfect", "🔥")

makeToggle(catBlatantV2Fast, "Blatant Features", function(on)
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then
        if on then blatantv2.Start() else blatantv2.Stop() end
    end
end)

makeInput(catBlatantV2Fast, "Fishing Delay", 0.05, function(v)
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then blatantv2.Settings.FishingDelay = v end
end)

makeInput(catBlatantV2Fast, "Cancel Delay", 0.01, function(v)
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then blatantv2.Settings.CancelDelay = v end
end)

makeInput(catBlatantV2Fast, "Timeout Delay", 0.8, function(v)
    local blatantv2 = GetModule("blatantv2")
    if blatantv2 then blatantv2.Settings.TimeoutDelay = v end
end)

-- Support Features Category
local catSupport = makeCategory(mainPage, "Support Features", "🛠️")

makeToggle(catSupport, "No Fishing Animation", function(on)
    local NoFishingAnimation = GetModule("NoFishingAnimation")
    if NoFishingAnimation then
        if on then NoFishingAnimation.StartWithDelay() else NoFishingAnimation.Stop() end
    end
end)

makeToggle(catSupport, "Lock Position", function(on)
    local LockPosition = GetModule("LockPosition")
    local Notify = GetModule("Notify")
    if LockPosition then
        if on then
            LockPosition.Start()
            if Notify then Notify.Send("Lock Position", "Posisi dikunci!", 4) end
        else
            LockPosition.Stop()
            if Notify then Notify.Send("Lock Position", "Posisi dilepas!", 4) end
        end
    end
end)

makeToggle(catSupport, "Auto Equip Rod", function(on)
    local AutoEquipRod = GetModule("AutoEquipRod")
    local Notify = GetModule("Notify")
    if AutoEquipRod then
        if on then
            AutoEquipRod.Start()
            if Notify then Notify.Send("Auto Equip Rod", "Rod auto equip aktif!", 4) end
        else
            AutoEquipRod.Stop()
            if Notify then Notify.Send("Auto Equip Rod", "Auto equip dimatikan!", 4) end
        end
    end
end)

makeToggle(catSupport, "Disable Cutscenes", function(on)
    local DisableCutscenes = GetModule("DisableCutscenes")
    local Notify = GetModule("Notify")
    if DisableCutscenes then
        if on then
            local success = DisableCutscenes.Start()
            if Notify then
                if success then
                    Notify.Send("Disable Cutscenes", "✓ Cutscenes dimatikan!", 4)
                else
                    Notify.Send("Disable Cutscenes", "⚠ Sudah aktif!", 3)
                end
            end
        else
            local success = DisableCutscenes.Stop()
            if Notify then
                if success then
                    Notify.Send("Disable Cutscenes", "✓ Cutscenes normal.", 4)
                else
                    Notify.Send("Disable Cutscenes", "⚠ Sudah nonaktif!", 3)
                end
            end
        end
    end
end)

makeToggle(catSupport, "Disable Obtained Fish Notification", function(on)
    local DisableExtras = GetModule("DisableExtras")
    local Notify = GetModule("Notify")
    if DisableExtras then
        if on then
            DisableExtras.StartSmallNotification()
            if Notify then Notify.Send("Disable Notification", "✓ Notifikasi dinonaktifkan!", 4) end
        else
            DisableExtras.StopSmallNotification()
            if Notify then Notify.Send("Disable Notification", "Notifikasi aktif kembali.", 3) end
        end
    end
end)

makeToggle(catSupport, "Disable Skin Effect", function(on)
    local DisableExtras = GetModule("DisableExtras")
    local Notify = GetModule("Notify")
    if DisableExtras then
        if on then
            DisableExtras.StartSkinEffect()
            if Notify then Notify.Send("Disable Skin Effect", "✓ Skin effect dihapus!", 4) end
        else
            DisableExtras.StopSkinEffect()
            if Notify then Notify.Send("Disable Skin Effect", "Skin effect aktif kembali.", 3) end
        end
    end
end)

makeToggle(catSupport, "Walk On Water", function(on)
    local WalkOnWater = GetModule("WalkOnWater")
    local Notify = GetModule("Notify")
    if WalkOnWater then
        if on then
            WalkOnWater.Start()
            if Notify then Notify.Send("Walk On Water", "✓ Berjalan di air aktif!", 4) end
        else
            WalkOnWater.Stop()
            if Notify then Notify.Send("Walk On Water", "Walk on water dimatikan.", 3) end
        end
    end
end)

makeToggle(catSupport, "Good/Perfection Stable Mode", function(on)
    local GoodPerfectionStable = GetModule("GoodPerfectionStable")
    local Notify = GetModule("Notify")
    if GoodPerfectionStable then
        if on then
            GoodPerfectionStable.Start()
            if Notify then Notify.Send("Good/Perfection Stable", "Fitur dihidupkan!", 4) end
        else
            GoodPerfectionStable.Stop()
            if Notify then Notify.Send("Good/Perfection Stable", "Fitur dimatikan!", 4) end
        end
    end
end)

-- Auto Totem Category
local catAutoTotem = makeCategory(mainPage, "Auto Spawn 3X Totem", "🛠️")

makeButton(catAutoTotem, "Auto Totem 3X", function()
    local AutoTotem3X = GetModule("AutoTotem3X")
    local Notify = GetModule("Notify")
    if AutoTotem3X then
        if AutoTotem3X.IsRunning() then
            local success, message = AutoTotem3X.Stop()
            if success and Notify then
                Notify.Send("Auto Totem 3X", "⏹ " .. message, 4)
            end
        else
            local success, message = AutoTotem3X.Start()
            if Notify then
                if success then
                    Notify.Send("Auto Totem 3X", "▶ " .. message, 4)
                else
                    Notify.Send("Auto Totem 3X", "⚠ " .. message, 3)
                end
            end
        end
    end
end)

-- Skin Animation Category
local catSkin = makeCategory(mainPage, "Skin Animation", "✨")

makeButton(catSkin, "⚔️ Eclipse Katana", function()
    local SkinAnimation = GetModule("SkinAnimation")
    local Notify = GetModule("Notify")
    if SkinAnimation then
        local success = SkinAnimation.SwitchSkin("Eclipse")
        if success then
            if Notify then Notify.Send("Skin Animation", "⚔️ Eclipse Katana diaktifkan!", 4) end
            if not SkinAnimation.IsEnabled() then
                SkinAnimation.Enable()
            end
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
            if Notify then Notify.Send("Skin Animation", "🔱 Holy Trident diaktifkan!", 4) end
            if not SkinAnimation.IsEnabled() then
                SkinAnimation.Enable()
            end
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
            if Notify then Notify.Send("Skin Animation", "💀 Soul Scythe diaktifkan!", 4) end
            if not SkinAnimation.IsEnabled() then
                SkinAnimation.Enable()
            end
        elseif Notify then
            Notify.Send("Skin Animation", "⚠ Gagal mengganti skin!", 3)
        end
    end
end)

makeToggle(catSkin, "Enable Skin Animation", function(on)
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
                if success then
                    Notify.Send("Skin Animation", "✓ Skin Animation dimatikan!", 4)
                else
                    Notify.Send("Skin Animation", "⚠ Sudah nonaktif!", 3)
                end
            end
        end
    end
end)

-- ============================================
-- BAGIAN 5/6: Teleport, Quest, Shop Pages
-- ============================================

-- TELEPORT PAGE
local TeleportModule = GetModule("TeleportModule")
local TeleportToPlayer = GetModule("TeleportToPlayer")
local SavedLocation = GetModule("SavedLocation")
local EventTeleport = GetModule("EventTeleportDynamic")

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

-- Player Teleport with Auto Refresh
local playerDropdown
local function updatePlayerList()
    local playerItems = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(playerItems, player.Name)
        end
    end
    table.sort(playerItems)
    
    if playerDropdown and playerDropdown.Parent then
        playerDropdown:Destroy()
    end
    
    if TeleportToPlayer then
        playerDropdown = makeDropdown(teleportPage, "Teleport to Player", "👤", playerItems, function(selectedPlayer)
            TeleportToPlayer.TeleportTo(selectedPlayer)
        end, "PlayerTeleport")
    end
end

updatePlayerList()

Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    task.wait(0.1)
    updatePlayerList()
end)

-- Saved Location Category
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

-- Event Teleport Category
local catTeleport = makeCategory(teleportPage, "Event Teleport", "🎯")
local selectedEventName = nil

if EventTeleport then
    local eventNames = EventTeleport.GetEventNames() or {"- No events -"}
    
    makeDropdown(catTeleport, "Pilih Event", "📌", eventNames, function(selected)
        selectedEventName = selected
        SendNotification("Event", "Event dipilih: " .. tostring(selected), 3)
    end, "EventTeleport")
    
    makeToggle(catTeleport, "Enable Auto Teleport", function(on)
        if on then
            if selectedEventName and EventTeleport.HasCoords(selectedEventName) then
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
        if selectedEventName then
            local ok = EventTeleport.TeleportNow(selectedEventName)
            if ok then
                SendNotification("Teleport", "Teleported ke " .. selectedEventName, 3)
            else
                SendNotification("Teleport", "Teleport gagal!", 3)
            end
        else
            SendNotification("Teleport", "Event belum dipilih!", 3)
        end
    end)
end

-- QUEST PAGE
local AutoQuestModule = GetModule("AutoQuestModule")
local AutoTemple = GetModule("AutoTemple")
local TempleDataReader = GetModule("TempleDataReader")

-- Deep Sea Quest Category
local catDeepSea = makeCategory(questPage, "Deep Sea Quest (Ghostfinn Rod)")

local deepSeaProgressFrame = new("Frame", {
    Parent = catDeepSea,
    Size = UDim2.new(1, 0, 0, 160),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex = 7
})
new("UICorner", {Parent = deepSeaProgressFrame, CornerRadius = UDim.new(0, 8)})
new("UIStroke", {Parent = deepSeaProgressFrame, Color = colors.border, Thickness = 1, Transparency = 0.7})

local deepSeaLabel = new("TextLabel", {
    Parent = deepSeaProgressFrame,
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = AutoQuestModule and AutoQuestModule.GetQuestInfo("DeepSeaQuest") or "Loading...",
    Font = Enum.Font.GothamBold,
    TextSize = 8,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 8
})

makeButton(catDeepSea, "Refresh Progress", function()
    if AutoQuestModule then
        deepSeaLabel.Text = AutoQuestModule.GetQuestInfo("DeepSeaQuest")
        SendNotification("Refresh", "Progress updated!", 2)
    end
end)

makeToggle(catDeepSea, "Auto Teleport", function(on)
    if AutoQuestModule then
        if on then
            AutoQuestModule.StartAutoTeleport("DeepSeaQuest")
            SendNotification("Auto Teleport", "Deep Sea Quest Auto Teleport AKTIF!", 2)
        else
            AutoQuestModule.StopAutoTeleport()
            SendNotification("Auto Teleport", "Deep Sea Quest Auto Teleport DIMATIKAN!", 2)
        end
        deepSeaLabel.Text = AutoQuestModule.GetQuestInfo("DeepSeaQuest")
    end
end)

-- Element Quest Category
local catElement = makeCategory(questPage, "Element Quest (Element Rod)")

local elementProgressFrame = new("Frame", {
    Parent = catElement,
    Size = UDim2.new(1, 0, 0, 160),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex = 7
})
new("UICorner", {Parent = elementProgressFrame, CornerRadius = UDim.new(0, 8)})
new("UIStroke", {Parent = elementProgressFrame, Color = colors.border, Thickness = 1, Transparency = 0.7})

local elementLabel = new("TextLabel", {
    Parent = elementProgressFrame,
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = AutoQuestModule and AutoQuestModule.GetQuestInfo("ElementQuest") or "Loading...",
    Font = Enum.Font.GothamBold,
    TextSize = 8,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 8
})

makeButton(catElement, "Refresh Progress", function()
    if AutoQuestModule then
        elementLabel.Text = AutoQuestModule.GetQuestInfo("ElementQuest")
        SendNotification("Refresh", "Progress updated!", 2)
    end
end)

makeToggle(catElement, "Auto Teleport", function(on)
    if AutoQuestModule then
        if on then
            AutoQuestModule.StartAutoTeleport("ElementQuest")
            SendNotification("Auto Teleport", "Element Quest Auto Teleport AKTIF!", 2)
        else
            AutoQuestModule.StopAutoTeleport()
            SendNotification("Auto Teleport", "Element Quest Auto Teleport DIMATIKAN!", 2)
        end
        elementLabel.Text = AutoQuestModule.GetQuestInfo("ElementQuest")
    end
end)

-- Real-time Quest Updates
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            if deepSeaLabel and deepSeaLabel.Parent and AutoQuestModule then
                deepSeaLabel.Text = AutoQuestModule.GetQuestInfo("DeepSeaQuest")
            end
        end)
        pcall(function()
            if elementLabel and elementLabel.Parent and AutoQuestModule then
                elementLabel.Text = AutoQuestModule.GetQuestInfo("ElementQuest")
            end
        end)
    end
end)

-- Temple Quest Category
local catTemple = makeCategory(questPage, "Sacred Temple", "⛩️")

local templeProgressFrame = new("Frame", {
    Parent = catTemple,
    Size = UDim2.new(1, 0, 0, 120),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex = 7
})
new("UICorner", {Parent = templeProgressFrame, CornerRadius = UDim.new(0, 8)})
new("UIStroke", {Parent = templeProgressFrame, Color = colors.border, Thickness = 1, Transparency = 0.7})

local templeLabel = new("TextLabel", {
    Parent = templeProgressFrame,
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "Loading Temple Status...",
    Font = Enum.Font.GothamBold,
    TextSize = 8,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 8
})

local function BuildTempleText(status)
    return "Sacred Temple Progress:\n\n" ..
           "- Crescent Artifact: " .. (status["Crescent Artifact"] and "✔️" or "❌") .. "\n" ..
           "- Arrow Artifact: " .. (status["Arrow Artifact"] and "✔️" or "❌") .. "\n" ..
           "- Diamond Artifact: " .. (status["Diamond Artifact"] and "✔️" or "❌") .. "\n" ..
           "- Hourglass Artifact: " .. (status["Hourglass Diamond Artifact"] and "✔️" or "❌")
end

if TempleDataReader then
    TempleDataReader.OnTempleUpdate(function(status)
        templeLabel.Text = BuildTempleText(status)
    end)
end

makeButton(catTemple, "Refresh Progress", function()
    if TempleDataReader then
        local status = TempleDataReader.GetTempleStatus()
        templeLabel.Text = BuildTempleText(status)
        SendNotification("Refresh", "Temple progress updated!", 2)
    end
end)

makeToggle(catTemple, "Auto Open Sacred Temple", function(on)
    if AutoTemple then
        if on then
            AutoTemple.Start()
            SendNotification("Temple", "Auto Sacred Temple AKTIF!", 2)
        else
            AutoTemple.Stop()
            SendNotification("Temple", "Auto Sacred Temple DIMATIKAN!", 2)
        end
        
        if TempleDataReader then
            templeLabel.Text = BuildTempleText(TempleDataReader.GetTempleStatus())
        end
    end
end)

-- SHOP PAGE
local AutoSell = GetModule("AutoSell")
local AutoSellTimer = GetModule("AutoSellTimer")
local MerchantSystem = GetModule("MerchantSystem")
local RemoteBuyer = GetModule("RemoteBuyer")
local AutoBuyWeather = GetModule("AutoBuyWeather")

-- Sell All Category
local catSell = makeCategory(shopPage, "Sell All", "💰")

makeButton(catSell, "Sell All Now", function()
    if AutoSell and AutoSell.SellOnce then
        AutoSell.SellOnce()
    end
end)

-- Auto Sell Timer Category
local catTimer = makeCategory(shopPage, "Auto Sell Timer", "⏰")

makeInput(catTimer, "Sell Interval (seconds)", 5, function(value)
    if AutoSellTimer then
        AutoSellTimer.SetInterval(value)
    end
end)

makeToggle(catTimer, "Auto Sell Timer", function(on)
    if AutoSellTimer then
        if on then
            AutoSellTimer.Start(AutoSellTimer.Interval)
        else
            AutoSellTimer.Stop()
        end
    end
end)

-- Auto Buy Weather Category
local catWeather = makeCategory(shopPage, "Auto Buy Weather", "🌦️")

if AutoBuyWeather then
    local weatherCheckboxContainer = new("Frame", {
        Parent = catWeather,
        Size = UDim2.new(1, 0, 0, 210),
        BackgroundColor3 = colors.bg2,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    new("UICorner", {Parent = weatherCheckboxContainer, CornerRadius = UDim.new(0, 8)})
    new("UIStroke", {Parent = weatherCheckboxContainer, Color = colors.border, Thickness = 1, Transparency = 0.95})
    
    local selectedWeathers = {}
    local checkboxes = {}
    
    local function createWeatherCheckbox(parent, weatherName, yPos)
        local checkboxRow = new("Frame", {
            Parent = parent,
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
        
        local label = new("TextLabel", {
            Parent = checkboxRow,
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text = weatherName,
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            TextColor3 = colors.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 9
        })
        
        local isSelected = false
        checkbox.MouseButton1Click:Connect(function()
            isSelected = not isSelected
            checkmark.Visible = isSelected
            
            if isSelected then
                table.insert(selectedWeathers, weatherName)
                TweenService:Create(checkbox, TweenInfo.new(0.25), {BackgroundColor3 = colors.primary}):Play()
            else
                local idx = table.find(selectedWeathers, weatherName)
                if idx then table.remove(selectedWeathers, idx) end
                TweenService:Create(checkbox, TweenInfo.new(0.25), {BackgroundColor3 = colors.bg1}):Play()
            end
            
            if AutoBuyWeather then
                AutoBuyWeather.SetSelected(selectedWeathers)
            end
        end)
        
        return {checkbox = checkbox, checkmark = checkmark, isSelected = function() return isSelected end}
    end
    
    for i, weather in ipairs(AutoBuyWeather.AllWeathers) do
        checkboxes[weather] = createWeatherCheckbox(weatherCheckboxContainer, weather, (i - 1) * 33 + 5)
    end
    
    makeToggle(catWeather, "Enable Auto Weather", function(on)
        if on then
            if #selectedWeathers == 0 then
                SendNotification("Auto Weather", "Pilih minimal 1 cuaca!", 3)
                return
            end
            AutoBuyWeather.Start()
        else
            AutoBuyWeather.Stop()
        end
    end)
end

-- Merchant Category
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

-- Buy Rod Category
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

-- Buy Bait Category
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

-- ============================================
-- BAGIAN 6/6: Webhook, Camera, Settings, Info Pages + Controls & Animations
-- ============================================

-- WEBHOOK PAGE
local WebhookModule = GetModule("Webhook")

local catWebhook = makeCategory(webhookPage, "Discord Webhook Fish Caught", "🔔")

-- Info Container
local webhookInfoContainer = new("Frame", {
    Parent = catWebhook,
    Size = UDim2.new(1, 0, 0, 70),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    ZIndex = 7
})
new("UICorner", {Parent = webhookInfoContainer, CornerRadius = UDim.new(0, 8)})

local webhookInfoText = new("TextLabel", {
    Parent = webhookInfoContainer,
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "📌 WEBHOOK INFO\nKirim notifikasi Discord saat menangkap ikan!\nMasukkan Discord Webhook URL di bawah.",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 8
})

-- Webhook URL Input
local currentWebhookURL = ""
local webhookInputContainer = new("Frame", {
    Parent = catWebhook,
    Size = UDim2.new(1, 0, 0, 70),
    BackgroundColor3 = colors.bg2,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    ZIndex = 7
})
new("UICorner", {Parent = webhookInputContainer, CornerRadius = UDim.new(0, 8)})

local webhookLabel = new("TextLabel", {
    Parent = webhookInputContainer,
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 6),
    BackgroundTransparency = 1,
    Text = "Discord Webhook URL",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = colors.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 8
})

local webhookTextBox = new("TextBox", {
    Parent = webhookInputContainer,
    Size = UDim2.new(1, -20, 0, 32),
    Position = UDim2.new(0, 10, 0, 30),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextColor3 = colors.text,
    PlaceholderColor3 = colors.textDimmer,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 8
})
new("UICorner", {Parent = webhookTextBox, CornerRadius = UDim.new(0, 6)})
new("UIPadding", {Parent = webhookTextBox, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

webhookTextBox.FocusLost:Connect(function()
    currentWebhookURL = webhookTextBox.Text
    if WebhookModule and currentWebhookURL ~= "" then
        WebhookModule:SetWebhookURL(currentWebhookURL)
        SendNotification("Webhook", "Webhook URL tersimpan!", 2)
    end
end)

-- Enable Webhook Toggle
makeToggle(catWebhook, "Enable Webhook", function(on)
    if WebhookModule then
        if on then
            if currentWebhookURL == "" then
                SendNotification("Error", "Masukkan Webhook URL dulu!", 3)
                return
            end
            local success = WebhookModule:Start()
            if success then
                SendNotification("Webhook", "Webhook logging aktif!", 4)
            end
        else
            WebhookModule:Stop()
            SendNotification("Webhook", "Webhook logging dinonaktifkan.", 3)
        end
    end
end)

-- Test Webhook Button
makeButton(catWebhook, "Test Webhook Connection", function()
    if currentWebhookURL == "" then
        SendNotification("Error", "Masukkan Webhook URL dulu!", 3)
        return
    end
    
    local HttpService = game:GetService("HttpService")
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    
    if requestFunc then
        local testPayload = {
            embeds = {{
                title = "🎣 Webhook Test Successful!",
                description = "Your Discord webhook is working correctly!",
                color = 3447003,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        pcall(function()
            requestFunc({
                Url = currentWebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(testPayload)
            })
        end)
        
        SendNotification("Success", "Test message sent! Check Discord.", 4)
    else
        SendNotification("Error", "HTTP request tidak didukung!", 3)
    end
end)

-- CAMERA VIEW PAGE
local FreecamModule = GetModule("FreecamModule")
local UnlimitedZoomModule = GetModule("UnlimitedZoomModule")

if FreecamModule then
    FreecamModule.SetMainGuiName("LynxGUI_Galaxy")
end

-- Unlimited Zoom Category
local catZoom = makeCategory(cameraViewPage, "Unlimited Zoom", "🔭")

makeToggle(catZoom, "Enable Unlimited Zoom", function(on)
    if UnlimitedZoomModule then
        if on then
            local success = UnlimitedZoomModule.Enable()
            if success then
                SendNotification("Zoom", "Unlimited Zoom aktif!", 4)
            end
        else
            UnlimitedZoomModule.Disable()
            SendNotification("Zoom", "Unlimited Zoom nonaktif.", 3)
        end
    end
end)

-- Freecam Category
local catFreecam = makeCategory(cameraViewPage, "Freecam Camera", "📷")

if not isMobile then
    local noteContainer = new("Frame", {
        Parent = catFreecam,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = colors.bg3,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    new("UICorner", {Parent = noteContainer, CornerRadius = UDim.new(0, 8)})
    
    local noteText = new("TextLabel", {
        Parent = noteContainer,
        Size = UDim2.new(1, -24, 1, -24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = "📌 FREECAM CONTROLS (PC)\n1. Toggle freecam on\n2. Press F3 to activate\n3. WASD - Move | Mouse - Rotate",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = colors.text,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 8
    })
end

makeToggle(catFreecam, "Enable Freecam", function(on)
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

makeInput(catFreecam, "Movement Speed", 50, function(value)
    if FreecamModule then
        FreecamModule.SetSpeed(value)
    end
end)

makeInput(catFreecam, "Mouse Sensitivity", 0.3, function(value)
    if FreecamModule then
        FreecamModule.SetSensitivity(value)
    end
end)

-- SETTINGS PAGE
local AntiAFK = GetModule("AntiAFK")
local UnlockFPS = GetModule("UnlockFPS")
local FPSBooster = GetModule("FPSBooster")
local HideStats = GetModule("HideStats")

-- Anti-AFK Category
local catAFK = makeCategory(settingsPage, "Anti-AFK Protection", "🧍‍♂️")

makeToggle(catAFK, "Enable Anti-AFK", function(on)
    if AntiAFK then
        if on then AntiAFK.Start() else AntiAFK.Stop() end
    end
end)

-- Server Features Category
local catServer = makeCategory(settingsPage, "Server Features", "🔄")

makeButton(catServer, "Rejoin Server", function()
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        TeleportService:Teleport(game.PlaceId, localPlayer)
    end)
    SendNotification("Rejoin", "Teleporting to new server...", 3)
end)

-- FPS Booster Category
local catBoost = makeCategory(settingsPage, "FPS Booster", "⚡")

makeToggle(catBoost, "Enable FPS Booster", function(on)
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

-- FPS Unlocker Category
local catFPS = makeCategory(settingsPage, "FPS Unlocker", "🎞️")

makeDropdown(catFPS, "Select FPS Limit", "⚙️", {"60 FPS", "90 FPS", "120 FPS", "240 FPS"}, function(selected)
    local fpsValue = tonumber(selected:match("%d+"))
    if fpsValue and UnlockFPS then
        UnlockFPS.SetCap(fpsValue)
    end
end, "FPSDropdown")

-- Hide Stats Category
local catHideStats = makeCategory(settingsPage, "Hide Stats Identifier", "👤")

local hideStatsInfoContainer = new("Frame", {
    Parent = catHideStats,
    Size = UDim2.new(1, 0, 0, 70),
    BackgroundColor3 = colors.bg3,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    ZIndex = 7
})
new("UICorner", {Parent = hideStatsInfoContainer, CornerRadius = UDim.new(0, 8)})

local hideStatsInfoText = new("TextLabel", {
    Parent = hideStatsInfoContainer,
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "📌 HIDE STATS INFO\nSembunyikan nama dan level asli Anda!\nMasukkan fake name & level di bawah.",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = colors.text,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 8
})

makeToggle(catHideStats, "⚡ Enable Hide Stats", function(on)
    if HideStats then
        if on then
            HideStats.Enable()
            SendNotification("Hide Stats", "Hide Stats aktif!", 3)
        else
            HideStats.Disable()
            SendNotification("Hide Stats", "Hide Stats dimatikan.", 3)
        end
    end
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

local infoText = new("TextLabel", {
    Parent = infoContainer,
    Size = UDim2.new(1, -24, 0, 100),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "# LynX v2.3\nFree Not For Sale\n━━━━━━━━━━━━━━━━━━━━━━\nCreated by Beee\nRefined Edition 2024",
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

-- Module Status Display
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
    task.wait(2)
    local statusText = "📦 MODULE STATUS (" .. loadedModules .. "/" .. totalModules .. " loaded)\n━━━━━━━━━━━━━━━━━━━━━━\n"
    for name, status in pairs(ModuleStatus) do
        statusText = statusText .. status .. " " .. name .. "\n"
    end
    moduleStatusText.Text = statusText
end)

-- ============================================
-- MINIMIZE SYSTEM
-- ============================================
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
        Image = "rbxassetid://111416780887356",
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
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            icon.Position = newPos
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

-- ============================================
-- DRAGGING SYSTEM
-- ============================================
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

-- ============================================
-- RESIZING SYSTEM
-- ============================================
local resizing = false
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

-- ============================================
-- OPENING ANIMATION
-- ============================================
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

-- ============================================
-- FINAL SUCCESS MESSAGE
-- ============================================
print("━━━━━━━━━━━━━━━━━━━━━━")
print("✨ Lynx GUI v2.3 OPTIMIZED")
print("FREE NOT FOR SALE")
print("━━━━━━━━━━━━━━━━━━━━━━")
print("💎 Created by Lynx Team")
print("📦 Modules: " .. loadedModules .. "/" .. totalModules .. " loaded")
print("━━━━━━━━━━━━━━━━━━━━━━")
