-- EventTeleportDynamic.lua
-- Single-file module: event coordinates + dynamic detection + teleport functions
-- Put this file on your raw hosting and call it from GUI via loadstring or require

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local module = {}

-- =======================
-- Event coordinate database (copy from game's module)
-- =======================
module.Events = {
    ["Shark Hunt"] = {
        Vector3.new(1.64999, -1.3500, 2095.72),
        Vector3.new(1369.94, -1.3500, 930.125),
        Vector3.new(-1585.5, -1.3500, 1242.87),
        Vector3.new(-1896.8, -1.3500, 2634.37),
    },

    ["Worm Hunt"] = {
        Vector3.new(2190.85, -1.3999, 97.5749),
        Vector3.new(-2450.6, -1.3999, 139.731),
        Vector3.new(-267.47, -1.3999, 5188.53),
    },

    ["Megalodon Hunt"] = {
        Vector3.new(-1076.3, -1.3999, 1676.19),
        Vector3.new(-1191.8, -1.3999, 3597.30),
        Vector3.new(412.700, -1.3999, 4134.39),
    },

    ["Ghost Shark Hunt"] = {
        Vector3.new(489.558, -1.3500, 25.4060),
        Vector3.new(-1358.2, -1.3500, 4100.55),
        Vector3.new(627.859, -1.3500, 3798.08),
    },

    ["Treasure Hunt"] = nil, -- no static coords
}

-- =======================
-- Config
-- =======================
module.SearchRadius = 16            -- radius (studs) to consider "spawned object at coord"
module.ScanInterval = 0.75          -- seconds between active scans when module is started
module.UseClosestPartAsTarget = true -- if true, will teleport to nearest BasePart found; else teleport to declared coordinate
module.HeightOffset = 15            -- studs to add to Y position (prevents drowning)
module.SafeZoneRadius = 50          -- studs - player can move within this radius before re-teleport
module.UseSmartReteleport = true    -- only re-teleport if player leaves safe zone
module.RequireEventActive = true    -- ⬅️ NEW: only teleport if event is actually active/spawned
module.WaitForEventTimeout = 300    -- ⬅️ NEW: max seconds to wait for event (5 minutes)

-- =======================
-- Internal state
-- =======================
local running = false
local currentEventName = nil
local heartbeatConn = nil
local lastTeleportPosition = nil
local eventIsActive = false         -- ⬅️ NEW: tracks if event is currently spawned
local lastEventCheckTime = 0        -- ⬅️ NEW: throttle event detection

-- ================
-- Utilities
-- ================
local function safeCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char
end

local function getHRP()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("HumanoidRootPart"))
end

-- Apply height offset to position
local function applyHeightOffset(pos)
    if not pos then return nil end
    return Vector3.new(pos.X, pos.Y + module.HeightOffset, pos.Z)
end

-- Check if player is within safe zone
local function isInSafeZone()
    if not module.UseSmartReteleport then
        return false -- always allow teleport if smart reteleport disabled
    end
    
    if not lastTeleportPosition then
        return false -- no previous teleport, allow teleport
    end
    
    local hrp = getHRP()
    if not hrp then
        return false
    end
    
    local distance = (hrp.Position - lastTeleportPosition).Magnitude
    return distance <= module.SafeZoneRadius
end

-- find parts/models in workspace that are close to a Vector3 position
local function findNearbyObject(centerPos, radius)
    local bestPart = nil
    local bestDist = math.huge

    -- fast path: if GetPartBoundsInBox exists, use it to get parts in region
    if Workspace.GetPartBoundsInBox then
        local ok, parts = pcall(function()
            return Workspace:GetPartBoundsInBox(CFrame.new(centerPos), Vector3.new(radius*2, radius*2, radius*2))
        end)
        if ok and parts then
            for _, p in ipairs(parts) do
                if p and p:IsA("BasePart") then
                    local d = (p.Position - centerPos).Magnitude
                    if d <= radius and d < bestDist then
                        bestDist = d
                        bestPart = p
                    end
                end
            end
            if bestPart then return bestPart end
        end
    end

    -- fallback: full scan but break early after certain threshold to avoid big cost
    local checked = 0
    local maxChecks = 2000
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") then
            checked = checked + 1
            local d = (inst.Position - centerPos).Magnitude
            if d <= radius and d < bestDist then
                bestDist = d
                bestPart = inst
            end
            if checked >= maxChecks then break end
        end
    end

    return bestPart
end

-- ⬅️ NEW: Check if event is actually active/spawned in the world
local function checkEventActive(eventName)
    local coords = module.Events[eventName]
    if not coords or #coords == 0 then
        return false, nil -- no coords to check
    end

    -- Check each coordinate for spawned objects
    for _, coord in ipairs(coords) do
        local part = findNearbyObject(coord, module.SearchRadius)
        if part then
            -- Found a spawned object near coordinate = event is active!
            return true, applyHeightOffset(part.Position)
        end
    end

    return false, nil -- no spawned objects found = event not active
end

-- Given an eventName, find the "active coordinate" in this server
local function resolveActivePosition(eventName)
    local coords = module.Events[eventName]
    if not coords or #coords == 0 then
        return nil, false -- no static coords to use
    end

    -- ⬅️ NEW: Check if event is actually active
    local isActive, activePos = checkEventActive(eventName)
    
    if module.RequireEventActive and not isActive then
        -- Event not spawned yet, don't return any position
        return nil, false
    end
    
    if isActive and activePos then
        -- Event is active, return the position we found
        return activePos, true
    end

    -- Fallback: return closest declared coord to player (only if RequireEventActive is disabled)
    if not module.RequireEventActive then
        local hrp = getHRP()
        if hrp then
            local best = nil
            local minD = math.huge
            for _, coord in ipairs(coords) do
                local d = (hrp.Position - coord).Magnitude
                if d < minD then
                    minD = d
                    best = coord
                end
            end
            return applyHeightOffset(best), false
        end
        
        -- last-resort: first coordinate with height offset
        return applyHeightOffset(coords[1]), false
    end
    
    return nil, false
end

-- Teleport helper (safe)
local function doTeleportToPos(pos)
    if not pos then return false end
    local char = safeCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- use PivotTo if available for better reliability
        if char.PrimaryPart then
            pcall(function() char:PivotTo(CFrame.new(pos)) end)
        else
            pcall(function() char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(pos) end)
        end
        
        lastTeleportPosition = pos
        return true
    end
    return false
end

-- Exposed simple call: teleport once now to eventName (resolve active pos)
function module.TeleportNow(eventName)
    if not eventName then return false end
    
    local ok, result = pcall(function()
        return resolveActivePosition(eventName)
    end)
    
    if not ok then
        warn("⚠️ EventTeleport: Error resolving position:", result)
        return false
    end
    
    local pos, isActive = result, false
    if type(result) == "table" then
        pos, isActive = result[1], result[2]
    end
    
    if not pos then
        if module.RequireEventActive then
            warn("⚠️ EventTeleport: Event not active yet, waiting...")
        end
        return false
    end

    return doTeleportToPos(pos)
end

-- ⬅️ NEW: Wait for event to become active before teleporting
local function waitForEventActive(eventName, timeout)
    local startTime = tick()
    local checkInterval = 2 -- check every 2 seconds
    
    print("🔍 EventTeleport: Waiting for event to start...")
    
    while tick() - startTime < timeout do
        local isActive, activePos = checkEventActive(eventName)
        
        if isActive and activePos then
            print("✅ EventTeleport: Event detected! Teleporting...")
            eventIsActive = true
            return activePos
        end
        
        task.wait(checkInterval)
    end
    
    warn("⚠️ EventTeleport: Timeout waiting for event (", timeout, "seconds)")
    return nil
end

-- Start auto-follow/teleport loop to chosen event
function module.Start(eventName)
    if running then return false end
    if not eventName then return false end
    if not module.Events[eventName] then return false end

    running = true
    currentEventName = eventName
    lastTeleportPosition = nil
    eventIsActive = false

    -- heartbeat loop
    heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        -- placeholder for future use
    end)

    -- Main loop in separate thread
    task.spawn(function()
        -- ⬅️ NEW: Wait for event to become active first
        if module.RequireEventActive then
            local initialPos = waitForEventActive(currentEventName, module.WaitForEventTimeout)
            
            if not initialPos then
                warn("❌ EventTeleport: Event did not start within timeout, stopping...")
                module.Stop()
                return
            end
            
            -- Event is active, do first teleport
            doTeleportToPos(initialPos)
        end
        
        -- Continue monitoring and re-teleporting
        while running do
            -- Check if player is still in safe zone
            if not isInSafeZone() then
                local pos, isActive = resolveActivePosition(currentEventName)
                
                if pos and isActive then
                    eventIsActive = true
                    doTeleportToPos(pos)
                elseif module.RequireEventActive and not isActive then
                    -- Event ended or disappeared
                    if eventIsActive then
                        print("⚠️ EventTeleport: Event ended, stopping auto-teleport...")
                        eventIsActive = false
                        -- Optionally stop or just pause teleporting
                        -- module.Stop()
                    end
                end
            end

            task.wait(module.ScanInterval)
        end
    end)

    return true
end

function module.Stop()
    running = false
    currentEventName = nil
    lastTeleportPosition = nil
    eventIsActive = false
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    return true
end

-- Utility: get event list (names)
function module.GetEventNames()
    local list = {}
    for name, _ in pairs(module.Events) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

-- Utility: returns whether event has static coords
function module.HasCoords(eventName)
    local v = module.Events[eventName]
    return v ~= nil and #v > 0
end

-- Allow user to customize height offset
function module.SetHeightOffset(offset)
    module.HeightOffset = offset or 15
    print("🎯 EventTeleport: Height offset set to", module.HeightOffset, "studs")
end

-- Allow user to customize safe zone radius
function module.SetSafeZoneRadius(radius)
    module.SafeZoneRadius = radius or 50
    print("🎯 EventTeleport: Safe zone radius set to", module.SafeZoneRadius, "studs")
end

-- Toggle smart re-teleport
function module.SetSmartReteleport(enabled)
    module.UseSmartReteleport = enabled
    print("🎯 EventTeleport: Smart re-teleport", enabled and "enabled" or "disabled")
end

-- ⬅️ NEW: Toggle require event active
function module.SetRequireEventActive(enabled)
    module.RequireEventActive = enabled
    print("🎯 EventTeleport: Require event active", enabled and "enabled" or "disabled")
end

-- ⬅️ NEW: Set wait timeout
function module.SetWaitTimeout(seconds)
    module.WaitForEventTimeout = seconds or 300
    print("🎯 EventTeleport: Wait timeout set to", module.WaitForEventTimeout, "seconds")
end

-- ⬅️ NEW: Check if event is currently active
function module.IsEventActive()
    return eventIsActive
end

return module
