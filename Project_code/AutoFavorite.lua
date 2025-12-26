-- ============================================
-- AUTO FAVORITE MODULE - LYNX GUI COMPATIBLEawd
-- Optimized for integration with LynxGUI v2.3.1
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AutoFavoriteModule = {}

-- ============================================
-- CONFIGURATION
-- ============================================
local TIER_MAP = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythic"] = 6,
    ["SECRET"] = 7
}

local TIER_NAMES = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "SECRET"
}

-- ============================================
-- STATE VARIABLES
-- ============================================
local AUTO_FAVORITE_TIERS = {}
local AUTO_FAVORITE_ENABLED = false
local AUTO_FAVORITE_VARIANTS = {}
local AUTO_FAVORITE_VARIANT_ENABLED = false

-- ============================================
-- CACHED REFERENCES (Lazy Load)
-- ============================================
local FavoriteEvent, NotificationEvent, itemsModule
local referencesInitialized = false

local function InitializeReferences()
    if referencesInitialized then return true end
    
    local success = pcall(function()
        FavoriteEvent = ReplicatedStorage:WaitForChild("Packages", 5)
            :WaitForChild("_Index", 5)
            :WaitForChild("sleitnick_net@0.2.0", 5)
            :WaitForChild("net", 5)
            :WaitForChild("RE/FavoriteItem", 5)

        NotificationEvent = ReplicatedStorage:WaitForChild("Packages", 5)
            :WaitForChild("_Index", 5)
            :WaitForChild("sleitnick_net@0.2.0", 5)
            :WaitForChild("net", 5)
            :WaitForChild("RE/ObtainedNewFishNotification", 5)

        itemsModule = require(ReplicatedStorage:WaitForChild("Items", 5))
        referencesInitialized = true
    end)
    
    return success
end

-- ============================================
-- FISH DATA HELPER (Cached)
-- ============================================
local fishDataCache = {}

local function getFishData(itemId)
    if fishDataCache[itemId] then
        return fishDataCache[itemId]
    end
    
    if not itemsModule then 
        InitializeReferences()
        if not itemsModule then return nil end
    end
    
    for _, fish in pairs(itemsModule) do
        if fish.Data and fish.Data.Id == itemId then
            fishDataCache[itemId] = fish
            return fish
        end
    end
    
    return nil
end

-- ============================================
-- TIER MANAGEMENT (GUI Compatible)
-- ============================================
function AutoFavoriteModule.EnableTiers(tierNames)
    if type(tierNames) == "string" then
        tierNames = {tierNames}
    end
    
    for _, tierName in ipairs(tierNames) do
        local tier = TIER_MAP[tierName]
        if tier then
            AUTO_FAVORITE_TIERS[tier] = true
            AUTO_FAVORITE_ENABLED = true
        end
    end
end

function AutoFavoriteModule.DisableTiers(tierNames)
    if type(tierNames) == "string" then
        tierNames = {tierNames}
    end
    
    for _, tierName in ipairs(tierNames) do
        local tier = TIER_MAP[tierName]
        if tier then
            AUTO_FAVORITE_TIERS[tier] = nil
        end
    end
    
    -- Check if any tier still enabled
    local anyEnabled = false
    for _ in pairs(AUTO_FAVORITE_TIERS) do
        anyEnabled = true
        break
    end
    AUTO_FAVORITE_ENABLED = anyEnabled
end

function AutoFavoriteModule.ClearTiers()
    table.clear(AUTO_FAVORITE_TIERS)
    AUTO_FAVORITE_ENABLED = false
end

function AutoFavoriteModule.GetEnabledTiers()
    local enabled = {}
    for tier, _ in pairs(AUTO_FAVORITE_TIERS) do
        table.insert(enabled, TIER_NAMES[tier])
    end
    return enabled
end

function AutoFavoriteModule.IsTierEnabled(tierName)
    local tier = TIER_MAP[tierName]
    return tier and AUTO_FAVORITE_TIERS[tier] == true
end

-- ============================================
-- VARIANT/MUTATION MANAGEMENT (GUI Compatible)
-- ============================================
function AutoFavoriteModule.EnableVariants(variantNames)
    if type(variantNames) == "string" then
        variantNames = {variantNames}
    end
    
    for _, variantName in ipairs(variantNames) do
        AUTO_FAVORITE_VARIANTS[variantName] = true
        AUTO_FAVORITE_VARIANT_ENABLED = true
    end
end

function AutoFavoriteModule.DisableVariants(variantNames)
    if type(variantNames) == "string" then
        variantNames = {variantNames}
    end
    
    for _, variantName in ipairs(variantNames) do
        AUTO_FAVORITE_VARIANTS[variantName] = nil
    end
    
    -- Check if any variant still enabled
    local anyEnabled = false
    for _ in pairs(AUTO_FAVORITE_VARIANTS) do
        anyEnabled = true
        break
    end
    AUTO_FAVORITE_VARIANT_ENABLED = anyEnabled
end

function AutoFavoriteModule.ClearVariants()
    table.clear(AUTO_FAVORITE_VARIANTS)
    AUTO_FAVORITE_VARIANT_ENABLED = false
end

function AutoFavoriteModule.GetEnabledVariants()
    local enabled = {}
    for variant, _ in pairs(AUTO_FAVORITE_VARIANTS) do
        table.insert(enabled, variant)
    end
    return enabled
end

function AutoFavoriteModule.IsVariantEnabled(variantName)
    return AUTO_FAVORITE_VARIANTS[variantName] == true
end

-- ============================================
-- STATUS & INFO (For GUI)
-- ============================================
function AutoFavoriteModule.IsEnabled()
    return AUTO_FAVORITE_ENABLED or AUTO_FAVORITE_VARIANT_ENABLED
end

function AutoFavoriteModule.GetStatus()
    return {
        TierEnabled = AUTO_FAVORITE_ENABLED,
        VariantEnabled = AUTO_FAVORITE_VARIANT_ENABLED,
        EnabledTiers = AutoFavoriteModule.GetEnabledTiers(),
        EnabledVariants = AutoFavoriteModule.GetEnabledVariants()
    }
end

function AutoFavoriteModule.GetAllTiers()
    return {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"}
end

function AutoFavoriteModule.GetAllVariants()
    return {
        "Galaxy", "Corrupt", "Gemstone", "Fairy Dust", "Midnight",
        "Color Burn", "Holographic", "Lightning", "Radioactive",
        "Ghost", "Gold", "Frozen", "1x1x1x1", "Stone", "Sandy",
        "Noob", "Moon Fragment", "Festive", "Albino", "Arctic Frost", "Disco"
    }
end

-- ============================================
-- AUTO FAVORITE CONNECTION (Optimized)
-- ============================================
local connectionEstablished = false

local function EstablishConnection()
    if connectionEstablished then return end
    
    -- Initialize references if not already done
    if not referencesInitialized then
        if not InitializeReferences() then
            warn("⚠️ AutoFavorite: Failed to initialize game events")
            return
        end
    end
    
    -- Setup the connection
    NotificationEvent.OnClientEvent:Connect(function(itemId, metadata, extraData, boolFlag)
        -- Quick exit if no filters enabled
        if not AUTO_FAVORITE_ENABLED and not AUTO_FAVORITE_VARIANT_ENABLED then
            return
        end
        
        local inventoryItem = extraData and extraData.InventoryItem
        local uuid = inventoryItem and inventoryItem.UUID
        
        -- Quick validation
        if not uuid or inventoryItem.Favorited then 
            return 
        end
        
        local shouldFavorite = false
        local favoriteReason = ""
        
        -- =====================
        -- CHECK TIER
        -- =====================
        if AUTO_FAVORITE_ENABLED then
            local fishData = getFishData(itemId)
            if fishData and fishData.Data and fishData.Data.Tier then
                if AUTO_FAVORITE_TIERS[fishData.Data.Tier] then
                    shouldFavorite = true
                    local tierName = TIER_NAMES[fishData.Data.Tier] or "Unknown"
                    favoriteReason = "[TIER: " .. tierName .. "]"
                end
            end
        end
        
        -- =====================
        -- CHECK VARIANT
        -- =====================
        if not shouldFavorite and AUTO_FAVORITE_VARIANT_ENABLED then
            local variantId = metadata and metadata.VariantId
            if variantId and variantId ~= "None" and AUTO_FAVORITE_VARIANTS[variantId] then
                shouldFavorite = true
                favoriteReason = "[VARIANT: " .. variantId .. "]"
            end
        end
        
        -- =====================
        -- EXECUTE FAVORITE
        -- =====================
        if shouldFavorite then
            task.delay(0.35, function()
                local success, err = pcall(function()
                    FavoriteEvent:FireServer(uuid)
                end)
                
                if success then
                    local fishData = getFishData(itemId)
                    local fishName = fishData and fishData.Data and fishData.Data.Name or "Unknown"
                    print(string.format("⭐ Auto favorited: %s %s", fishName, favoriteReason))
                else
                    warn(string.format("❌ Failed to auto favorite: %s", tostring(err)))
                end
            end)
        end
    end)
    
    connectionEstablished = true
    print("✅ AutoFavorite: Connection established")
end

-- Auto-initialize on module load (async)
task.spawn(function()
    task.wait(1) -- Wait for game to fully load
    InitializeReferences()
    EstablishConnection()
end)

-- ============================================
-- CLEANUP
-- ============================================
function AutoFavoriteModule.Cleanup()
    table.clear(AUTO_FAVORITE_TIERS)
    table.clear(AUTO_FAVORITE_VARIANTS)
    table.clear(fishDataCache)
    AUTO_FAVORITE_ENABLED = false
    AUTO_FAVORITE_VARIANT_ENABLED = false
    connectionEstablished = false
    referencesInitialized = false
end

return AutoFavoriteModule
