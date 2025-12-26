-- ConfigSystem.lua - Dirty Flags + Debounced Auto-Save Version
local HttpService = game:GetService("HttpService")

local ConfigSystem = {}
ConfigSystem.Version = "2.0-DirtyFlags"

local CONFIG_FOLDER = "LynxGUI_Configs"
local CONFIG_FILE = CONFIG_FOLDER .. "/lynx_config.json"

-- ✅ Auto-Save Settings
local AUTO_SAVE_DELAY = 5 -- Delay sebelum auto-save (detik)
local saveTimer = nil
local isDirty = false

-- ✅ WHITELIST: Paths yang akan di-save saat minimize
local SAVE_ON_MINIMIZE_PATHS = {
    "InstantFishing",
    "BlatantTester",
    "BlatantV1",
    "UltraBlatant",
    "FastAutoPerfect",
    "Support",
    "AutoFavorite",
    "SkinAnimation",
    "Shop.AutoSellTimer",
    "Shop.AutoBuyWeather",
    "Webhook",
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

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
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

local function IsPathWhitelisted(path)
    for _, whitelistedPath in ipairs(SAVE_ON_MINIMIZE_PATHS) do
        if path:sub(1, #whitelistedPath) == whitelistedPath then
            return true
        end
    end
    return false
end

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

-- ============================================
-- CORE SAVE FUNCTION (Real Save)
-- ============================================
local function RealSave(selectiveOnly)
    local success, err = pcall(function()
        EnsureFolderExists()
        
        local configToSave
        
        if selectiveOnly then
            -- Load existing config
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
            
            configToSave = existingConfig
        else
            -- Save ALL config
            configToSave = CurrentConfig
        end
        
        local jsonData = HttpService:JSONEncode(configToSave)
        writefile(CONFIG_FILE, jsonData)
    end)
    
    if success then
        lastSavedConfig = DeepCopy(CurrentConfig)
        isDirty = false
        return true, "Config saved!"
    else
        return false, "Save failed: " .. tostring(err)
    end
end

-- ============================================
-- DEBOUNCED AUTO-SAVE SCHEDULER
-- ============================================
local function ScheduleSave(selectiveOnly)
    -- Cancel timer jika ada perubahan baru
    if saveTimer then
        pcall(function() task.cancel(saveTimer) end)
        saveTimer = nil
    end
    
    -- Buat timer baru
    saveTimer = task.delay(AUTO_SAVE_DELAY, function()
        if isDirty then
            RealSave(selectiveOnly)
            print("[ConfigSystem] Auto-saved after " .. AUTO_SAVE_DELAY .. "s delay")
        end
        saveTimer = nil
    end)
end

-- ============================================
-- PUBLIC API
-- ============================================

-- Set value dengan auto-save scheduling
function ConfigSystem.Set(path, value)
    local currentValue = GetValueFromPath(CurrentConfig, path)
    
    -- Cek apakah value benar-benar berubah
    local currentJson = HttpService:JSONEncode(currentValue or {})
    local newJson = HttpService:JSONEncode(value or {})
    
    if currentJson ~= newJson then
        SetValueInPath(CurrentConfig, path, value)
        isDirty = true
        
        -- Schedule auto-save (selective mode)
        ScheduleSave(true)
    end
end

-- Get value
function ConfigSystem.Get(path)
    return GetValueFromPath(CurrentConfig, path)
end

-- Get entire config
function ConfigSystem.GetConfig()
    return CurrentConfig
end

-- Force save immediately (untuk manual save button)
function ConfigSystem.Save()
    if saveTimer then
        pcall(function() task.cancel(saveTimer) end)
        saveTimer = nil
    end
    
    return RealSave(false)
end

-- Save ONLY whitelisted paths immediately (untuk minimize)
function ConfigSystem.SaveSelective()
    if saveTimer then
        pcall(function() task.cancel(saveTimer) end)
        saveTimer = nil
    end
    
    return RealSave(true)
end

-- Load config
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
            isDirty = false
            return true, CurrentConfig
        else
            return false, CurrentConfig
        end
    else
        isDirty = false
        return false, CurrentConfig
    end
end

-- Check if there are unsaved changes
function ConfigSystem.HasUnsavedChanges()
    return isDirty
end

-- Mark as saved (reset dirty flag)
function ConfigSystem.MarkAsSaved()
    isDirty = false
    lastSavedConfig = DeepCopy(CurrentConfig)
end

-- Reset to default
function ConfigSystem.Reset()
    CurrentConfig = DeepCopy(DefaultConfig)
    isDirty = true
    return ConfigSystem.Save()
end

-- Delete config file
function ConfigSystem.Delete()
    if isfile(CONFIG_FILE) then
        delfile(CONFIG_FILE)
        isDirty = false
        lastSavedConfig = nil
        return true
    else
        return false
    end
end

-- Cleanup (cancel pending saves)
function ConfigSystem.Cleanup()
    if saveTimer then
        pcall(function() task.cancel(saveTimer) end)
        saveTimer = nil
    end
    
    -- Force save if dirty
    if isDirty then
        RealSave(true)
    end
    
    lastSavedConfig = nil
end

-- Set auto-save delay
function ConfigSystem.SetAutoSaveDelay(seconds)
    AUTO_SAVE_DELAY = math.max(1, seconds)
end

-- Get auto-save delay
function ConfigSystem.GetAutoSaveDelay()
    return AUTO_SAVE_DELAY
end

-- ============================================
-- INITIALIZATION
-- ============================================
ConfigSystem.Load()

return ConfigSystem
