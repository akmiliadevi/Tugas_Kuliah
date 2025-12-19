-- ========================================
-- FISH WEBHOOK MODULE V3.0
-- File terpisah untuk di-load via loadstring
-- ========================================

local WebhookModule = {}

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- CONFIG (Akan di-set dari GUI)
--------------------------------------------------
WebhookModule.Config = {
    WebhookURL = "", -- Akan diisi dari GUI
    DiscordUserID = "",
    DebugMode = false,
    EnabledRarities = {} -- Filter rarity yang aktif
}

--------------------------------------------------
-- MODULES
--------------------------------------------------
local Items = require(ReplicatedStorage:WaitForChild("Items"))
local Variants = require(ReplicatedStorage:WaitForChild("Variants"))

--------------------------------------------------
-- TIER CONFIG
--------------------------------------------------
local TIER_NAMES = {
    [1] = "Common",
    [2] = "Uncommon", 
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "SECRET"
}

local TIER_COLORS = {
    [1] = 9807270,
    [2] = 3066993,
    [3] = 3447003,
    [4] = 10181046,
    [5] = 15844367,
    [6] = 15548997,
    [7] = 16711680
}

--------------------------------------------------
-- STATE
--------------------------------------------------
local isRunning = false
local eventConnection = nil

--------------------------------------------------
-- HTTP REQUEST
--------------------------------------------------
local function request(data)
    local requestFunc = (syn and syn.request) or 
        (http and http.request) or 
        http_request or 
        (fluxus and fluxus.request) or
        request
    
    if requestFunc then
        return requestFunc(data)
    end
end

--------------------------------------------------
-- DEBUG PRINT
--------------------------------------------------
local function debugPrint(...)
    -- Debug mode disabled by default untuk production
    -- Uncomment baris di bawah jika butuh troubleshooting
    -- if WebhookModule.Config.DebugMode then
    --     print("[WEBHOOK DEBUG]", ...)
    -- end
end

--------------------------------------------------
-- GET PLAYER DISPLAY NAME
--------------------------------------------------
local function getPlayerDisplayName()
    -- Gunakan DisplayName jika tersedia, fallback ke Name jika tidak
    return LocalPlayer.DisplayName or LocalPlayer.Name
end

--------------------------------------------------
-- DISCORD IMAGE URL
--------------------------------------------------
local function getDiscordImageUrl(assetId)
    if not assetId then return nil end
    
    local thumbnailUrl = string.format(
        "https://thumbnails.roblox.com/v1/assets?assetIds=%s&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false",
        tostring(assetId)
    )
    
    local rbxcdnUrl = string.format(
        "https://tr.rbxcdn.com/180DAY-%s/420/420/Image/Png",
        tostring(assetId)
    )
    
    local success, result = pcall(function()
        local response = request({
            Url = thumbnailUrl,
            Method = "GET"
        })
        
        if response and response.Body then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.data and data.data[1] and data.data[1].imageUrl then
                return data.data[1].imageUrl
            end
        end
    end)
    
    if success and result then
        debugPrint("✅ Got thumbnail URL:", result)
        return result
    end
    
    debugPrint("⚠️ Thumbnail API failed, using rbxcdn fallback")
    return rbxcdnUrl
end

--------------------------------------------------
-- GET FISH IMAGE
--------------------------------------------------
local function getFishImageUrl(fish)
    debugPrint("=== SEARCHING FOR IMAGE ===")
    debugPrint("Fish Name:", fish.Data.Name)
    
    local assetId = nil
    
    if fish.Data.Icon then
        assetId = tostring(fish.Data.Icon):match("%d+")
        debugPrint("Found Icon ID:", assetId)
    elseif fish.Data.ImageId then
        assetId = tostring(fish.Data.ImageId)
        debugPrint("Found ImageId:", assetId)
    elseif fish.Data.Image then
        assetId = tostring(fish.Data.Image):match("%d+")
        debugPrint("Found Image ID:", assetId)
    end
    
    if assetId then
        local discordUrl = getDiscordImageUrl(assetId)
        if discordUrl then
            debugPrint("✅ Discord-compatible URL:", discordUrl)
            return discordUrl
        end
    end
    
    debugPrint("❌ NO IMAGE FOUND - Using placeholder")
    return "https://i.imgur.com/8yZqFqM.png"
end

--------------------------------------------------
-- GET FISH DATA
--------------------------------------------------
local function getFish(itemId)
    for _, f in pairs(Items) do
        if f.Data and f.Data.Id == itemId then
            return f
        end
    end
end

--------------------------------------------------
-- GET VARIANT DATA
--------------------------------------------------
local function getVariant(id)
    if not id then return nil end
    
    local idStr = tostring(id)
    
    for _, v in pairs(Variants) do
        if v.Data then
            if tostring(v.Data.Id) == idStr or tostring(v.Data.Name) == idStr then
                debugPrint("✅ Found variant:", v.Data.Name or v.Data.Id)
                return v
            end
        end
    end
    
    debugPrint("❌ Variant not found for ID:", idStr)
    return nil
end

--------------------------------------------------
-- SEND WEBHOOK
--------------------------------------------------
local function send(fish, meta, extra)
    -- Validasi webhook URL
    if not WebhookModule.Config.WebhookURL or WebhookModule.Config.WebhookURL == "" then
        warn("❌ Webhook URL belum diisi!")
        return
    end
    
    local tier = TIER_NAMES[fish.Data.Tier] or "Unknown"
    local color = TIER_COLORS[fish.Data.Tier] or 3447003
    
    -- FILTER RARITY: Cek apakah rarity ini diaktifkan
    -- PENTING: Jika EnabledRarities kosong (length = 0), kirim SEMUA
    -- Jika EnabledRarities ada isinya, hanya kirim yang ada di list
    if WebhookModule.Config.EnabledRarities and #WebhookModule.Config.EnabledRarities > 0 then
        local isEnabled = false
        
        for _, enabledTier in ipairs(WebhookModule.Config.EnabledRarities) do
            if enabledTier == tier then
                isEnabled = true
                break
            end
        end
        
        if not isEnabled then
            -- Skip fish yang tidak ada di filter
            return
        end
    end
    
    local mutationText = "None"
    local finalPrice = fish.SellPrice or 0
    local variantId = nil
    
    if extra then
        variantId = extra.Variant or extra.Mutation or extra.VariantId or extra.MutationId
    end
    
    if not variantId and meta then
        variantId = meta.Variant or meta.Mutation or meta.VariantId or meta.MutationId
    end
    
    local isShiny = (meta and meta.Shiny) or (extra and extra.Shiny)
    if isShiny then
        mutationText = "Shiny"
        finalPrice = finalPrice * 2
    end
    
    if variantId then
        local v = getVariant(variantId)
        if v then
            mutationText = v.Data.Name .. " (" .. v.SellMultiplier .. "x)"
            finalPrice = finalPrice * v.SellMultiplier
        else
            mutationText = variantId
        end
    end
    
    local imageUrl = getFishImageUrl(fish)
    
    -- PERUBAHAN UTAMA: Gunakan Display Name daripada Username
    local playerDisplayName = getPlayerDisplayName()
    local mention = WebhookModule.Config.DiscordUserID ~= "" and "<@" .. WebhookModule.Config.DiscordUserID .. "> " or ""
    
    local congratsMsg = string.format(
        "%s **%s** You have obtained a new **%s** fish!",
        mention,
        playerDisplayName,  -- Menggunakan Display Name
        tier
    )
    
    local fields = {
        {
            name = "Fish Name :",
            value = "> " .. fish.Data.Name,
            inline = false
        },
        {
            name = "Fish Tier :",
            value = "> " .. tier,
            inline = false
        },
        {
            name = "Weight :",
            value = string.format("> %.2f Kg", meta.Weight or 0),
            inline = false
        },
        {
            name = "Mutation :",
            value = "> " .. mutationText,
            inline = false
        },
        {
            name = "Sell Price :",
            value = "> $" .. math.floor(finalPrice),
            inline = false
        }
    }
    
    local payload = {
        embeds = {{
            author = {
                name = "Lynxx Webhook | Fish Caught"
            },
            description = congratsMsg,
            color = color,
            fields = fields,
            image = {
                url = imageUrl
            },
            footer = {
                text = "Lynxx Webhook • " .. os.date("%m/%d/%Y %H:%M"),
                icon_url = "https://i.imgur.com/shnNZuT.png"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    local success, err = pcall(function()
        request({
            Url = WebhookModule.Config.WebhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)
    
    if success then
        print("✅ Webhook sent:", fish.Data.Name, "-", tier)
    else
        warn("❌ Webhook failed:", err)
    end
end

--------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------

-- Set Webhook URL
function WebhookModule:SetWebhookURL(url)
    self.Config.WebhookURL = url
    debugPrint("Webhook URL set:", url)
end

-- Set Discord User ID (optional)
function WebhookModule:SetDiscordUserID(id)
    self.Config.DiscordUserID = id
    debugPrint("Discord User ID set:", id)
end

-- Enable/Disable Debug Mode
function WebhookModule:SetDebugMode(enabled)
    self.Config.DebugMode = enabled
    debugPrint("Debug mode:", enabled and "ENABLED" or "DISABLED")
end

-- Set Enabled Rarities Filter
function WebhookModule:SetEnabledRarities(rarities)
    self.Config.EnabledRarities = rarities
    debugPrint("Enabled rarities:", table.concat(rarities, ", "))
end

-- Get available tier names
function WebhookModule:GetTierNames()
    return TIER_NAMES
end

-- Start webhook logger
function WebhookModule:Start()
    if isRunning then
        warn("⚠️ Webhook logger sudah berjalan!")
        return false
    end
    
    if not self.Config.WebhookURL or self.Config.WebhookURL == "" then
        warn("❌ Webhook URL belum diisi!")
        return false
    end
    
    local Event = ReplicatedStorage.Packages
        ._Index["sleitnick_net@0.2.0"]
        .net["RE/ObtainedNewFishNotification"]
    
    eventConnection = Event.OnClientEvent:Connect(function(itemId, metadata, extraData)
        debugPrint("\n=== NEW FISH EVENT ===")
        debugPrint("Item ID:", itemId)
        
        local fish = getFish(itemId)
        if fish then
            task.spawn(function()
                send(fish, metadata, extraData)
            end)
        end
    end)
    
    isRunning = true
    print("✅ Fish Webhook Logger V3.0 Started!")
    return true
end

-- Stop webhook logger
function WebhookModule:Stop()
    if not isRunning then
        warn("⚠️ Webhook logger tidak berjalan!")
        return false
    end
    
    if eventConnection then
        eventConnection:Disconnect()
        eventConnection = nil
    end
    
    isRunning = false
    print("⏹️ Fish Webhook Logger Stopped!")
    return true
end

-- Check if running
function WebhookModule:IsRunning()
    return isRunning
end

-- Get current config
function WebhookModule:GetConfig()
    return self.Config
end

return WebhookModule
