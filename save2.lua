-- ConfigSystem.lua - Selective Save on Minimize Version
local HttpService = game:GetService("HttpService")

local ConfigSystem = {}
ConfigSystem.Version = "1.4"

local CONFIG_FOLDER = "LynxGUI_Configs"
local CONFIG_FILE = CONFIG_FOLDER .. "/lynx_config.json"

-- ✅ WHITELIST: Paths yang akan di-save saat minimize
local SAVE_ON_MINIMIZE_PATHS = {
    -- Main/Dashboard Page (SEMUA)
    "InstantFishing",
    "BlatantTester",
    "BlatantV1",
    "UltraBlatant",
    "FastAutoPerfect",
    "Support",
    "AutoFavorite",
    "SkinAnimation",
    
    -- Shop Page (HANYA yang dipilih)
    "Shop.AutoSellTimer",
    "Shop.AutoBuyWeather",
    
    -- Webhook Page (SEMUA)
    "Webhook",
    
    -- Settings Page (HANYA yang dipilih)
    "Settings.AntiAFK",
    "Settings.FPSBooster",
    "Settings.DisableRendering",
    "Settings.FPSLimit",
    "Settings.HideStats",
}

-- Default Config
local DefaultConfig = {
    InstantFishing = { Mode = "None", Enabled = false, FishingDelay = 1.30, CancelDelay = 0.19 },
    BlatantTester = { Enabled = false, CompleteDelay = 0.5, CancelDelay = 0.1 },
    BlatantV1 = { Enabled = false, CompleteDelay = 0.05, CancelDelay = 0.1 },
    UltraBlatant = { Enabled = false, CompleteDelay = 0.05, CancelDelay = 0.1 },
    FastAutoPerfect = { Enabled = false, FishingDelay = 0.05, CancelDelay = 0.01, TimeoutDelay = 0.8 },
    Support = {
        NoFishingAnimation = false, LockPosition = false, AutoEquipRod = false,
        DisableCutscenes = false, DisableObtainedNotif = false, DisableSkinEffect = false,
        WalkOnWater = false, GoodPerfectionStable = false, PingFPSMonitor = false,
        SkinAnimation = { Enabled = false, Current = "Eclipse" }
    },
    Teleport = { SavedLocation = nil, LastEventSelected = nil, AutoTeleportEvent = false },
    Shop = {
        AutoSellTimer = { Enabled = false, Interval = 5 },
        AutoBuyWeather = { Enabled = false, SelectedWeathers = {} }
    },
    Webhook = { Enabled = false, URL = "", DiscordID = "", EnabledRarities = {} },
    CameraView = {
        UnlimitedZoom = false,
        Freecam = { Enabled = false, Speed = 50, Sensitivity = 0.3 }
    },
    Settings = {
        AntiAFK = false, FPSBooster = false, DisableRendering = false, FPSLimit = 60,
        HideStats = { Enabled = false, FakeName = "Guest", FakeLevel = "1" }
    },
    AutoFavorite = { EnabledTiers = {}, EnabledVariants = {} },
    SkinAnimation = { Enabled = false, Current = "Eclipse" }
}

local CurrentConfig = {}
local lastSavedConfig = nil

-- Utility Functions
local function DeepCopy(original)
    if type(original) ~= "table" then return original end
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = type(v) == "table" and DeepCopy(v) or v
    end
    return copy
end

local function MergeTables(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            MergeTables(target[k], v)
        else
            target[k] = v
        end
    end
end

local function EnsureFolderExists()
    if not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
end

-- ✅ Check if path is in whitelist
local function IsPathWhitelisted(path)
    for _, whitelistedPath in ipairs(SAVE_ON_MINIMIZE_PATHS) do
        if path:sub(1, #whitelistedPath) == whitelistedPath then
            return true
        end
    end
    return false
end

-- ✅ Get value from nested table using path
local function GetValueFromPath(tbl, path)
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local value = tbl
    for _, key in ipairs(keys) do
        if type(value) == "table" then
            value = value[key]
        else
            return nil
        end
    end
    
    return value
end

-- ✅ Set value in nested table using path
local function SetValueInPath(tbl, path, value)
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local target = tbl
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(target[key]) ~= "table" then
            target[key] = {}
        end
        target = target[key]
    end
    
    target[keys[#keys]] = value
end

-- ✅ Save ONLY whitelisted paths
function ConfigSystem.SaveSelective()
    local success, err = pcall(function()
        EnsureFolderExists()
        
        -- Load existing config (or use default)
        local existingConfig = DeepCopy(DefaultConfig)
        if isfile(CONFIG_FILE) then
            local jsonData = readfile(CONFIG_FILE)
            local loadedConfig = HttpService:JSONDecode(jsonData)
            MergeTables(existingConfig, loadedConfig)
        end
        
        -- Update ONLY whitelisted paths
        for _, path in ipairs(SAVE_ON_MINIMIZE_PATHS) do
            local currentValue = GetValueFromPath(CurrentConfig, path)
            if currentValue ~= nil then
                SetValueInPath(existingConfig, path, DeepCopy(currentValue))
            end
        end
        
        -- Save merged config
        local jsonData = HttpService:JSONEncode(existingConfig)
        writefile(CONFIG_FILE, jsonData)
    end)
    
    if success then
        lastSavedConfig = DeepCopy(CurrentConfig)
        return true, "Config saved!"
    else
        return false, "Save failed: " .. tostring(err)
    end
end

-- Save ALL (untuk manual save button)
function ConfigSystem.Save()
    local success, err = pcall(function()
        EnsureFolderExists()
        local jsonData = HttpService:JSONEncode(CurrentConfig)
        writefile(CONFIG_FILE, jsonData)
    end)
    
    if success then
        lastSavedConfig = DeepCopy(CurrentConfig)
        return true, "Config saved!"
    else
        return false, "Save failed: " .. tostring(err)
    end
end

-- Load Function
function ConfigSystem.Load()
    EnsureFolderExists()
    CurrentConfig = DeepCopy(DefaultConfig)
    
    if isfile(CONFIG_FILE) then
        local success, result = pcall(function()
            local jsonData = readfile(CONFIG_FILE)
            local loadedConfig = HttpService:JSONDecode(jsonData)
            MergeTables(CurrentConfig, loadedConfig)
        end)
        
        if success then
            lastSavedConfig = DeepCopy(CurrentConfig)
            return true, CurrentConfig
        else
            return false, CurrentConfig
        end
    else
        return false, CurrentConfig
    end
end

-- Get/Set Functions
function ConfigSystem.GetConfig()
    return CurrentConfig
end

function ConfigSystem.Get(path)
    return GetValueFromPath(CurrentConfig, path)
end

function ConfigSystem.Set(path, value)
    SetValueInPath(CurrentConfig, path, value)
end

function ConfigSystem.HasUnsavedChanges()
    if not lastSavedConfig then return false end
    
    -- Check ONLY whitelisted paths
    for _, path in ipairs(SAVE_ON_MINIMIZE_PATHS) do
        local currentValue = GetValueFromPath(CurrentConfig, path)
        local savedValue = GetValueFromPath(lastSavedConfig, path)
        
        local currentJson = HttpService:JSONEncode(currentValue or {})
        local savedJson = HttpService:JSONEncode(savedValue or {})
        
        if currentJson ~= savedJson then
            return true
        end
    end
    
    return false
end

function ConfigSystem.MarkAsSaved()
    lastSavedConfig = DeepCopy(CurrentConfig)
end

-- Utility Functions
function ConfigSystem.Reset()
    CurrentConfig = DeepCopy(DefaultConfig)
    local success, message = ConfigSystem.Save()
    return success, message
end

function ConfigSystem.Delete()
    if isfile(CONFIG_FILE) then
        delfile(CONFIG_FILE)
        return true
    else
        return false
    end
end

function ConfigSystem.Cleanup()
    lastSavedConfig = nil
end

-- Initialization
ConfigSystem.Load()

return ConfigSystem
