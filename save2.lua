-- ConfigSystem.lua - Manual Save Version with Unsaved Changes Tracker
local HttpService = game:GetService("HttpService")

local ConfigSystem = {}
ConfigSystem.Version = "1.2"

local CONFIG_FOLDER = "LynxGUI_Configs"
local CONFIG_FILE = CONFIG_FOLDER .. "/lynx_config.json"

-- Default Config (sama seperti sebelumnya)
local DefaultConfig = {
    InstantFishing = { Mode = "None", Enabled = false, FishingDelay = 1.30, CancelDelay = 0.19 },
    BlatantTester = { Enabled = false, CompleteDelay = 0.5, CancelDelay = 0.1 },
    BlatantV1 = { Enabled = false, CompleteDelay = 0.05, CancelDelay = 0.1 },
    UltraBlatant = { Enabled = false, CompleteDelay = 0.05, CancelDelay = 0.1 },
    FastAutoPerfect = { Enabled = false, FishingDelay = 0.05, CancelDelay = 0.01, TimeoutDelay = 0.8 },
    Support = {
        NoFishingAnimation = false, LockPosition = false, AutoEquipRod = false,
        DisableCutscenes = false, DisableObtainedNotif = false, DisableSkinEffect = false,
        WalkOnWater = false, GoodPerfectionStable = false, PingFPSMonitor = false
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

-- Save Function
function ConfigSystem.Save()
    print("💾 [ConfigSystem] Saving configuration...")
    
    local success, err = pcall(function()
        EnsureFolderExists()
        local jsonData = HttpService:JSONEncode(CurrentConfig)
        writefile(CONFIG_FILE, jsonData)
    end)
    
    if success then
        print("✅ [ConfigSystem] Configuration saved!")
        lastSavedConfig = DeepCopy(CurrentConfig)
        return true, "Config saved!"
    else
        warn("❌ [ConfigSystem] Save failed:", err)
        return false, "Save failed: " .. tostring(err)
    end
end

-- Load Function
function ConfigSystem.Load()
    print("🔄 [ConfigSystem] Loading configuration...")
    
    EnsureFolderExists()
    CurrentConfig = DeepCopy(DefaultConfig)
    
    if isfile(CONFIG_FILE) then
        local success, result = pcall(function()
            local jsonData = readfile(CONFIG_FILE)
            local loadedConfig = HttpService:JSONDecode(jsonData)
            MergeTables(CurrentConfig, loadedConfig)
        end)
        
        if success then
            print("✅ [ConfigSystem] Configuration loaded!")
            lastSavedConfig = DeepCopy(CurrentConfig)
            return true, CurrentConfig
        else
            warn("❌ [ConfigSystem] Load failed:", result)
            return false, CurrentConfig
        end
    else
        print("⚠️ [ConfigSystem] No saved config, using defaults")
        return false, CurrentConfig
    end
end

-- Get/Set Functions
function ConfigSystem.GetConfig()
    return CurrentConfig
end

function ConfigSystem.Get(path)
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local value = CurrentConfig
    for _, key in ipairs(keys) do
        if type(value) == "table" then
            value = value[key]
        else
            return nil
        end
    end
    
    return value
end

function ConfigSystem.Set(path, value)
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local target = CurrentConfig
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(target[key]) ~= "table" then
            target[key] = {}
        end
        target = target[key]
    end
    
    target[keys[#keys]] = value
end

-- ✅ CRITICAL: Add this function!
function ConfigSystem.HasUnsavedChanges()
    if not lastSavedConfig then return false end
    
    local currentJson = HttpService:JSONEncode(CurrentConfig)
    local savedJson = HttpService:JSONEncode(lastSavedConfig)
    
    return currentJson ~= savedJson
end

function ConfigSystem.MarkAsSaved()
    lastSavedConfig = DeepCopy(CurrentConfig)
end

-- Utility Functions
function ConfigSystem.PrintStatus()
    print("=== LYNX GUI CONFIG STATUS ===")
    print("📦 Version:", ConfigSystem.Version)
    print("📁 Folder:", CONFIG_FOLDER)
    print("📄 File:", CONFIG_FILE)
    print("✅ Config exists:", isfile(CONFIG_FILE) and "YES" or "NO")
    print("💾 Unsaved changes:", ConfigSystem.HasUnsavedChanges() and "YES" or "NO")
    print("==============================")
end

function ConfigSystem.Reset()
    print("🔄 [ConfigSystem] Resetting to defaults...")
    CurrentConfig = DeepCopy(DefaultConfig)
    local success, message = ConfigSystem.Save()
    if success then
        print("✅ [ConfigSystem] Reset complete!")
    end
    return success, message
end

function ConfigSystem.Delete()
    if isfile(CONFIG_FILE) then
        delfile(CONFIG_FILE)
        print("🗑️ [ConfigSystem] Config file deleted!")
        return true
    else
        print("⚠️ [ConfigSystem] No config file to delete")
        return false
    end
end

function ConfigSystem.Cleanup()
    lastSavedConfig = nil
    print("🧹 [ConfigSystem] Cleanup complete!")
end

-- Initialization
print("🚀 [ConfigSystem v1.2] Loaded (Manual Save Mode)")
ConfigSystem.Load()

return ConfigSystem
