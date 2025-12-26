-- ============================================efdef
-- AUTO FAVORITE SYSTEM (MEMORY SAFE & IMPROVED)
-- ============================================

local AutoFavorite = {}

-- Tier mapping
local TIER_MAP = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythic"] = 6,
    ["SECRET"] = 7
}

-- State variables
local AUTO_FAVORITE_TIERS = {}
local AUTO_FAVORITE_VARIANTS = {}
local AUTO_FAVORITE_ENABLED = false

-- Connection management
local activeConnections = {}

-- Get required services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Safe service getter with retries
local function GetServiceSafe(path, maxRetries)
    maxRetries = maxRetries or 5
    local current = ReplicatedStorage
    
    for _, childName in ipairs(path) do
        local attempts = 0
        local child = nil
        
        while attempts < maxRetries do
            child = current:FindFirstChild(childName)
            if child then break end
            attempts = attempts + 1
            task.wait(0.2)
        end
        
        if not child then
            warn(string.format("⚠️ AutoFavorite: Failed to find '%s' after %d attempts", childName, maxRetries))
            return nil
        end
        
        current = child
    end
    
    return current
end

-- Get favorite event with error handling
local FavoriteEvent = GetServiceSafe({
    "Packages", "_Index", "sleitnick_net@0.2.0", "net", "RE/FavoriteItem"
})

-- Get notification event with error handling
local NotificationEvent = GetServiceSafe({
    "Packages", "_Index", "sleitnick_net@0.2.0", "net", "RE/ObtainedNewFishNotification"
})

-- Check if services loaded
if not FavoriteEvent then
    error("❌ AutoFavorite: FavoriteEvent not found!")
end

if not NotificationEvent then
    error("❌ AutoFavorite: NotificationEvent not found!")
end

-- Get fish data helper (cached)
local itemsModule = require(ReplicatedStorage:WaitForChild("Items"))

-- Cache untuk fish data (prevent repeated lookups)
local fishDataCache = {}

local function getFishData(itemId)
    -- Check cache first
    if fishDataCache[itemId] then
        return fishDataCache[itemId]
    end
    
    -- Lookup and cache
    for _, fish in pairs(itemsModule) do
        if fish.Data and fish.Data.Id == itemId then
            fishDataCache[itemId] = fish
            return fish
        end
    end
    
    return nil
end

-- ============================================
-- PUBLIC FUNCTIONS FOR GUI
-- ============================================

function AutoFavorite.GetAllTiers()
    return {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"}
end

function AutoFavorite.GetAllVariants()
    return {
        "Galaxy",
        "Corrupt",
        "Gemstone",
        "Fairy Dust",
        "Midnight",
        "Color Burn",
        "Holographic",
        "Lightning",
        "Radioactive",
        "Ghost",
        "Gold",
        "Frozen",
        "1x1x1x1",
        "Stone",
        "Sandy",
        "Noob",
        "Moon Fragment",
        "Festive",
        "Albino",
        "Arctic Frost",
        "Disco"
    }
end

function AutoFavorite.EnableTiers(selectedTiers)
    for _, tierName in ipairs(selectedTiers) do
        local tier = TIER_MAP[tierName]
        if tier then
            AUTO_FAVORITE_TIERS[tier] = true
        end
    end
    print(string.format("✓ AutoFavorite: Enabled %d tier(s)", #selectedTiers))
end

function AutoFavorite.ClearTiers()
    table.clear(AUTO_FAVORITE_TIERS)
    print("✓ AutoFavorite: Cleared tier filter")
end

function AutoFavorite.EnableVariants(selectedVariants)
    for _, variantName in ipairs(selectedVariants) do
        AUTO_FAVORITE_VARIANTS[variantName] = true
    end
    print(string.format("✓ AutoFavorite: Enabled %d variant(s)", #selectedVariants))
end

function AutoFavorite.ClearVariants()
    table.clear(AUTO_FAVORITE_VARIANTS)
    print("✓ AutoFavorite: Cleared variant filter")
end

function AutoFavorite.GetEnabledTiers()
    local enabled = {}
    for tier, _ in pairs(AUTO_FAVORITE_TIERS) do
        for name, id in pairs(TIER_MAP) do
            if id == tier then
                table.insert(enabled, name)
                break
            end
        end
    end
    return enabled
end

function AutoFavorite.GetEnabledVariants()
    local enabled = {}
    for variant, _ in pairs(AUTO_FAVORITE_VARIANTS) do
        table.insert(enabled, variant)
    end
    return enabled
end

function AutoFavorite.IsEnabled()
    return AUTO_FAVORITE_ENABLED
end

function AutoFavorite.GetStatus()
    return {
        enabled = AUTO_FAVORITE_ENABLED,
        tierCount = #AutoFavorite.GetEnabledTiers(),
        variantCount = #AutoFavorite.GetEnabledVariants(),
        hasFilters = next(AUTO_FAVORITE_TIERS) ~= nil or next(AUTO_FAVORITE_VARIANTS) ~= nil
    }
end

-- ============================================
-- CONNECTION MANAGEMENT
-- ============================================

local function disconnectAll()
    for _, conn in pairs(activeConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(activeConnections)
end

function AutoFavorite:Start()
    -- Disconnect existing connections first
    disconnectAll()
    
    -- Check if filters are set
    if not next(AUTO_FAVORITE_TIERS) and not next(AUTO_FAVORITE_VARIANTS) then
        warn("⚠️ AutoFavorite: No filters enabled! Please select at least one tier or variant.")
        return false
    end
    
    AUTO_FAVORITE_ENABLED = true
    
    -- Create new connection
    local connection = NotificationEvent.OnClientEvent:Connect(function(itemId, metadata, extraData)
        if not AUTO_FAVORITE_ENABLED then 
            return 
        end
        
        -- Early exit checks
        if not extraData or not extraData.InventoryItem then
            return
        end
        
        local inventoryItem = extraData.InventoryItem
        local uuid = inventoryItem.UUID
        
        if not uuid or inventoryItem.Favorited then 
            return 
        end

        local shouldFavorite = false

        -- Check Tier
        if next(AUTO_FAVORITE_TIERS) then
            local fishData = getFishData(itemId)
            if fishData and fishData.Data and fishData.Data.Tier then
                if AUTO_FAVORITE_TIERS[fishData.Data.Tier] then
                    shouldFavorite = true
                end
            end
        end

        -- Check Variant (only if not already marked for favorite)
        if not shouldFavorite and next(AUTO_FAVORITE_VARIANTS) then
            local variantId = metadata and metadata.VariantId
            if variantId and variantId ~= "None" and AUTO_FAVORITE_VARIANTS[variantId] then
                shouldFavorite = true
            end
        end

        -- Execute Favorite
        if shouldFavorite then
            task.delay(0.35, function()
                pcall(function()
                    FavoriteEvent:FireServer(uuid)
                end)
            end)
        end
    end)
    
    -- Store connection
    table.insert(activeConnections, connection)
    
    local status = AutoFavorite.GetStatus()
    print(string.format("✅ AutoFavorite: Started (Tiers: %d, Variants: %d)", 
        status.tierCount, status.variantCount))
    
    return true
end

function AutoFavorite:Stop()
    AUTO_FAVORITE_ENABLED = false
    disconnectAll()
    print("✓ AutoFavorite: Stopped")
end

-- ============================================
-- CLEANUP ON MODULE UNLOAD
-- ============================================

local function cleanup()
    disconnectAll()
    table.clear(AUTO_FAVORITE_TIERS)
    table.clear(AUTO_FAVORITE_VARIANTS)
    table.clear(fishDataCache)
    AUTO_FAVORITE_ENABLED = false
end

-- Register cleanup
if game then
    game:BindToClose(cleanup)
end

-- ============================================
-- MODULE VALIDATION
-- ============================================

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ AutoFavorite Module Loaded")
print("   Version: 1.1.0 (Fixed)")
print("   Tiers Available: " .. #AutoFavorite.GetAllTiers())
print("   Variants Available: " .. #AutoFavorite.GetAllVariants())
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

return AutoFavorite
