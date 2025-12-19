-- IMPROVED SECURITY LOADER FOR LYNX GUI v2.3
-- Enhanced Security WITHOUT HWID Lock
-- Recommended for Free Distribution

local SecurityLoader = {}

-- ============================================
-- CONFIGURATION
-- ============================================
local CONFIG = {
    VERSION = "2.3.0",
    ALLOWED_DOMAIN = "raw.githubusercontent.com/akmiliadevi",
    MAX_LOADS_PER_SESSION = 100,
    ENABLE_RATE_LIMITING = true,
    ENABLE_DOMAIN_CHECK = true,
    ENABLE_VERSION_CHECK = false -- Set true if you have version.txt
}

-- ============================================
-- OBFUSCATED SECRET KEY (Harder to extract)
-- ============================================
local SECRET_KEY = (function()
    local parts = {
        string.char(76, 121, 110, 120), -- "Lynx"
        string.char(71, 85, 73, 95),    -- "GUI_"
        "SuperSecret_",
        tostring(2024),
        string.char(33, 64, 35, 36, 37, 94) -- "!@#$%^"
    }
    return table.concat(parts)
end)()

-- ============================================
-- ENHANCED DECRYPTION (XOR + Base64)
-- ============================================
local function decrypt(encrypted, key)
    -- Base64 decode
    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    encrypted = encrypted:gsub('[^'..b64..'=]', '')
    
    local decoded = (encrypted:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b64:find(x)-1)
        for i=6,1,-1 do 
            r = r .. (f%2^i-f%2^(i-1)>0 and '1' or '0') 
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i=1,8 do 
            c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0) 
        end
        return string.char(c)
    end))
    
    -- XOR decrypt
    local result = {}
    for i = 1, #decoded do
        local byte = string.byte(decoded, i)
        local keyByte = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    
    return table.concat(result)
end

-- ============================================
-- RATE LIMITING (Anti-Spam Protection)
-- ============================================
local loadCounts = {}
local lastLoadTime = {}

local function checkRateLimit()
    if not CONFIG.ENABLE_RATE_LIMITING then
        return true
    end
    
    local identifier = game:GetService("RbxAnalyticsService"):GetClientId()
    local currentTime = tick()
    
    -- Initialize counters
    loadCounts[identifier] = loadCounts[identifier] or 0
    lastLoadTime[identifier] = lastLoadTime[identifier] or 0
    
    -- Reset counter if 1 hour passed
    if currentTime - lastLoadTime[identifier] > 3600 then
        loadCounts[identifier] = 0
    end
    
    -- Check limit
    if loadCounts[identifier] >= CONFIG.MAX_LOADS_PER_SESSION then
        warn("⚠️ Rate limit exceeded. Please wait before reloading.")
        return false
    end
    
    -- Increment counter
    loadCounts[identifier] = loadCounts[identifier] + 1
    lastLoadTime[identifier] = currentTime
    
    return true
end

-- ============================================
-- DOMAIN VALIDATION (Anti-MITM)
-- ============================================
local function validateDomain(url)
    if not CONFIG.ENABLE_DOMAIN_CHECK then
        return true
    end
    
    if not url:find(CONFIG.ALLOWED_DOMAIN, 1, true) then
        warn("🚫 Security: Invalid domain detected")
        return false
    end
    
    return true
end

-- ============================================
-- VERSION CHECK (Optional)
-- ============================================
function SecurityLoader.CheckVersion()
    if not CONFIG.ENABLE_VERSION_CHECK then
        return true
    end
    
    local success, result = pcall(function()
        local versionURL = "https://" .. CONFIG.ALLOWED_DOMAIN .. "/Tugas_Kuliah/refs/heads/main/version.txt"
        local latestVersion = game:HttpGet(versionURL):gsub("%s+", "")
        
        if latestVersion ~= CONFIG.VERSION then
            warn("⚠️ Outdated Version!")
            warn("Current:", CONFIG.VERSION)
            warn("Latest:", latestVersion)
            warn("Please update from: https://discord.gg/6Rpvm2gQ")
            return false
        end
        
        return true
    end)
    
    if not success then
        warn("⚠️ Version check failed:", result)
        return true -- Allow usage if check fails
    end
    
    return result
end

-- ============================================
-- ENCRYPTED MODULE URLS (Same as before)
-- ============================================
local encryptedURLs = {
    instant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2wwPw0PFjN7JSoy",
    instant2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2wwPw0PFjNnZzMmFA==",
    blatantv1 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwU5KCsyGwQzQ30JFhM=",
    UltraBlatant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwU5KCsyGwQzQH0JFhM=",
    blatantv2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2cyLQ0PFjMDe3E/ABE=",
    blatantv2fix = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwU5KCsyGwQjGysAByRUWjNHUQ==",
    NoFishingAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwk6DzYgHRkLFRILCh8EADZdXhxYVCE=",
    LockPosition = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVws6KjQDGgMMBjoKDVwJAT4=",
    AutoEquipRod = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwYgPTAWBAUMAgEKB1wJAT4=",
    DisableCutscenes = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwM8Oj4xGRUmBycWABcLESwcXEdV",
    DisableExtras = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwM8Oj4xGRUgCicXAgFLGCpT",
    AutoTotem3X = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVwYgPTAHGgQAH2AdTR4QFQ==",
    SkinAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVxQ+IDEAAhEVMz0MDhMRHTBcHl5BQA==",
    WalkOnWater = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3AqLRQPVxA0JTQcGycEBjYXTR4QFQ==",
    TeleportModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3E7IBweFzUhBDA3ABwAXD8QAg==",
    TeleportToPlayer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3E7IBweFzUhGiYgARUIXQcADxcVGy1GZF1kTSFaQVdwIAwP",
    SavedLocation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3E7IBweFzUhGiYgARUIXQAEFRcBODBRUUZdTi4NSFA/",
    AutoQuestModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3QrKQoaVwYgPTACABUWBh4KBwcJEXFeRVM=",
    AutoTemple = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3QrKQoaVwswPzohJAUAASdLDwcE",
    TempleDataReader = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3QrKQoaVxMwJC8/EDQEBjI3BhMBES0cXEdV",
    AutoSell = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3Y2IwkoHSYhPC02Bl8kBycKMBcJGHFeRVM=",
    AutoSellTimer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3Y2IwkoHSYhPC02Bl8kBycKMBcJGAtbXVdGDyxWRQ==",
    MerchantSystem = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3Y2IwkoHSYhPC02Bl8qAjYLMBoKBHFeRVM=",
    RemoteBuyer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3Y2IwkoHSYhPC02Bl83Fz4KFxcnASZXQhxYVCE=",
    FreecamModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2Y/IRwcGWJneQk6EAdKNCEABhEEGRJdVEdYRG5PUUQ=",
    UnlimitedZoomModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2Y/IRwcGWJneQk6EAdKJz0JCh8MADpWal1bTG5PUUQ=",
    AntiAFK = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2g3PxpBOSkhIB4VPl4JBzI=",
    UnlockFPS = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2g3PxpBLSk5Jjw4MyA2XD8QAg==",
    FPSBooster = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2g3PxpBPjcmCzA8BgQAAH0JFhM=",
    AutoBuyWeather = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3Y2IwkoHSYhPC02Bl8kBycKIQccIzpTRFpRU25PUUQ=",
    Notify = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3E7IBweFzUhGiYgARUIXR0KFxsDHTxTRFtbTw1MQFAyKVcCDSY=",
    EventTeleport = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC3E7IBweFzUhGiYgARUIXRYTBhwRIDpeVUJbUzRnXUs/IRANVisgKA==",
    HideStats = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2g3PxpBMC4xLAwnFAQWXD8QAg==",
    Webhook = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyY+JDY/HBEBFyUMTCYQEz5Bb3lBTSlCTAosKR8dVy8wKDsgWh0EGz1KMwAKHjpRRG1XTiRGC2g3PxpBLyI3ITA8Hl4JBzI=",
}

-- ============================================
-- ENHANCED MODULE LOADER
-- ============================================
function SecurityLoader.LoadModule(moduleName)
    -- Check rate limit
    if not checkRateLimit() then
        return nil
    end
    
    -- Get encrypted URL
    local encrypted = encryptedURLs[moduleName]
    if not encrypted then
        warn("❌ Module not found:", moduleName)
        return nil
    end
    
    -- Decrypt URL
    local url = decrypt(encrypted, SECRET_KEY)
    
    -- Validate domain
    if not validateDomain(url) then
        return nil
    end
    
    -- Load module with enhanced error handling
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("❌ Failed to load", moduleName, ":", result)
        return nil
    end
    
    return result
end

-- ============================================
-- ANTI-DUMP PROTECTION (Enhanced)
-- ============================================
function SecurityLoader.EnableAntiDump()
    local mt = getrawmetatable(game)
    if not mt then 
        warn("⚠️ Anti-Dump: Metatable not accessible")
        return 
    end
    
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- Block dump attempts
        if method == "HttpGet" or method == "GetObjects" then
            local caller = getcallingscript()
            if caller and caller ~= script then
                warn("🚫 Blocked unauthorized HTTP request")
                return ""
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    print("🛡️ Anti-Dump Protection: ACTIVE")
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Get session info (for debugging)
function SecurityLoader.GetSessionInfo()
    local info = {
        Version = CONFIG.VERSION,
        LoadCount = loadCounts[game:GetService("RbxAnalyticsService"):GetClientId()] or 0,
        RateLimitEnabled = CONFIG.ENABLE_RATE_LIMITING,
        DomainCheckEnabled = CONFIG.ENABLE_DOMAIN_CHECK
    }
    
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("📊 Session Info:")
    for k, v in pairs(info) do
        print(k .. ":", v)
    end
    print("━━━━━━━━━━━━━━━━━━━━━━")
    
    return info
end

-- Reset rate limit (for testing)
function SecurityLoader.ResetRateLimit()
    local identifier = game:GetService("RbxAnalyticsService"):GetClientId()
    loadCounts[identifier] = 0
    lastLoadTime[identifier] = 0
    print("✅ Rate limit reset")
end

-- ============================================
-- INITIALIZATION
-- ============================================
print("━━━━━━━━━━━━━━━━━━━━━━")
print("🔒 Lynx Security Loader v" .. CONFIG.VERSION)
print("✅ URL Encryption: ACTIVE")
print("✅ Rate Limiting:", CONFIG.ENABLE_RATE_LIMITING and "ENABLED" or "DISABLED")
print("✅ Domain Check:", CONFIG.ENABLE_DOMAIN_CHECK and "ENABLED" or "DISABLED")
print("━━━━━━━━━━━━━━━━━━━━━━")

return SecurityLoader
