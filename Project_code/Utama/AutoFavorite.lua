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
-- GET GAME EVENTS
-- ============================================
local FavoriteEvent = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE/FavoriteItem")

local NotificationEvent = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE/ObtainedNewFishNotification")

-- ============================================
-- FISH DATA HELPER
-- ============================================
local itemsModule = require(ReplicatedStorage:WaitForChild("Items"))

local function getFishData(itemId)
    for _, fish in pairs(itemsModule) do
        if fish.Data and fish.Data.Id == itemId then
            return fish
        end
    end
    return nil
end

-- ============================================
-- TIER MANAGEMENT
-- ============================================

-- Enable tier(s) for auto favorite
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

-- Disable tier(s)
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

-- Clear all tier selections
function AutoFavoriteModule.ClearTiers()
    AUTO_FAVORITE_TIERS = {}
    AUTO_FAVORITE_ENABLED = false
end

-- Get enabled tiers
function AutoFavoriteModule.GetEnabledTiers()
    local enabled = {}
    for tier, _ in pairs(AUTO_FAVORITE_TIERS) do
        table.insert(enabled, TIER_NAMES[tier])
    end
    return enabled
end

-- Check if tier is enabled
function AutoFavoriteModule.IsTierEnabled(tierName)
    local tier = TIER_MAP[tierName]
    return tier and AUTO_FAVORITE_TIERS[tier] == true
end

-- ============================================
-- VARIANT/MUTATION MANAGEMENT
-- ============================================

-- Enable variant(s) for auto favorite
function AutoFavoriteModule.EnableVariants(variantNames)
    if type(variantNames) == "string" then
        variantNames = {variantNames}
    end
    
    for _, variantName in ipairs(variantNames) do
        AUTO_FAVORITE_VARIANTS[variantName] = true
        AUTO_FAVORITE_VARIANT_ENABLED = true
    end
end

-- Disable variant(s)
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

-- Clear all variant selections
function AutoFavoriteModule.ClearVariants()
    AUTO_FAVORITE_VARIANTS = {}
    AUTO_FAVORITE_VARIANT_ENABLED = false
end

-- Get enabled variants
function AutoFavoriteModule.GetEnabledVariants()
    local enabled = {}
    for variant, _ in pairs(AUTO_FAVORITE_VARIANTS) do
        table.insert(enabled, variant)
    end
    return enabled
end

-- Check if variant is enabled
function AutoFavoriteModule.IsVariantEnabled(variantName)
    return AUTO_FAVORITE_VARIANTS[variantName] == true
end

-- ============================================
-- STATUS & INFO
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
        "Ghost", "Gold", "Frozen ", "1x1x1x1", "Stone", "Sandy",
        "Noob", "Moon Fragment", "Festive", "Albino", "Arctic Frost", "Disco"
    }
end

-- ============================================
-- AUTO FAVORITE LOGIC
-- ============================================

NotificationEvent.OnClientEvent:Connect(function(itemId, metadata, extraData, boolFlag)
    local inventoryItem = extraData and extraData.InventoryItem
    local uuid = inventoryItem and inventoryItem.UUID
    
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

return AutoFavoriteModule
