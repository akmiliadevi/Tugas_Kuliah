-- EventTeleportDynamic.lua (OPTIMIZED VERSION - NO STUTTERING)
-- Single-file module: event coordinates + dynamic detection + teleport functions
-- PERFORMANCE IMPROVEMENTS:
-- ✅ Reduced scan frequency from 0.75s to 3s
-- ✅ Limited object checks per scan (500 max)
-- ✅ Round-robin coordinate checking (1 coord per scan instead of all)
-- ✅ Removed unused Heartbeat connection
-- ✅ Batch processing with skip optimization

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local module = {}

-- =======================
-- Event coordinate database
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
-- Config (OPTIMIZED FOR PERFORMANCE)
-- =======================
module.SearchRadius = 16            -- radius (studs) to consider "spawned object at coord"
module.ScanInterval = 3.0           -- ✅ INCREASED: seconds between scans (reduced from 0.75 to prevent lag)
module.MaxObjectsToCheck = 500      -- ✅ NEW: limit objects checked per scan
module.UseClosestPartAsTarget = true
module.HeightOffset = 15            -- studs to add to Y position
module.SafeZoneRadius = 50          -- studs - player can move within this radius
module.UseSmartReteleport = true    -- only re-teleport if player leaves safe zone
module.RequireEventActive = true    -- only teleport if event is active
module.WaitForEventTimeout = 300    -- max seconds to wait for event (5 minutes)

-- =======================
-- Internal state
-- =======================
local running = false
local currentEventName = nil
local lastTeleportPosition = nil
local eventIsActive = false
local lastEventCheckTime = 0
local coordCheckIndex = 1           -- ✅ NEW: for round-robin coordinate checking

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

local function applyHeightOffset(pos)
    if not pos then return nil end
    return Vector3.new(pos.X, pos.Y + module.HeightOffset, pos.Z)
end

local function isInSafeZone()
    if not module.UseSmartReteleport then
        return false
    end
    
    if not lastTeleportPosition then
        return false
    end
    
    local hrp = getHRP()
    if not hrp then
        return false
    end
    
    local distance = (hrp.Position - lastTeleportPosition).Magnitude
    return distance <= module.SafeZoneRadius
end

-- ✅ OPTIMIZED: find parts near position with performance limits
local function findNearbyObject(centerPos, radius)
    local bestPart = nil
    local bestDist = math.huge

    -- Priority 1: Use spatial query (fastest method)
    if Workspace.GetPartBoundsInBox then
        local ok, parts = pcall(function()
            return Workspace:GetPartBoundsInBox(
                CFrame.new(centerPos), 
                Vector3.new(radius*2, radius*2, radius*2)
            )
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

    -- Priority 2: Limited fallback scan with skip optimization
    local checked = 0
    local descendants = Workspace:GetDescendants()
    local skipFactor = math.max(1, math.floor(#descendants / module.MaxObjectsToCheck))
    
    for i = 1, #descendants, skipFactor do
        if checked >= module.MaxObjectsToCheck then break end
        
        local inst = descendants[i]
        if inst and inst:IsA("BasePart") then
            checked = checked + 1
            local d = (inst.Position - centerPos).Magnitude
            if d <= radius and d < bestDist then
                bestDist = d
                bestPart = inst
            end
        end
    end

    return bestPart
end

-- ✅ OPTIMIZED: Round-robin check (only 1 coordinate per call)
local function checkEventActive(eventName)
    local coords = module.Events[eventName]
    if not coords or #coords == 0 then
        return false, nil
    end

    -- Check only ONE coordinate per call using round-robin
    coordCheckIndex = (coordCheckIndex % #coords) + 1
    local coord = coords[coordCheckIndex]
    
    local part = findNearbyObject(coord, module.SearchRadius)
    
    if part then
        return true, applyHeightOffset(part.Position)
    end

    return false, nil
end

local function resolveActivePosition(eventName)
    local coords = module.Events[eventName]
    if not coords or #coords == 0 then
        return nil, false
    end

    local isActive, activePos = checkEventActive(eventName)
    
    if module.RequireEventActive and not isActive then
        return nil, false
    end
    
    if isActive and activePos then
        return activePos, true
    end

    -- Fallback for non-required mode
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
        
        return applyHeightOffset(coords[1]), false
    end
    
    return nil, false
end

local function doTeleportToPos(pos)
    if not pos then return false end
    local char = safeCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
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
            warn("⚠️ EventTeleport: Event not active yet")
        end
        return false
    end

    return doTeleportToPos(pos)
end

local function waitForEventActive(eventName, timeout)
    local startTime = tick()
    local checkInterval = 3 -- ✅ OPTIMIZED: increased from 2s to 3s
    
    print("🔍 EventTeleport: Waiting for event to start...")
    
    while tick() - startTime < timeout do
        -- Check multiple coordinates during wait phase
        local coords = module.Events[eventName]
        if coords then
            for _, coord in ipairs(coords) do
                local part = findNearbyObject(coord, module.SearchRadius)
                if part then
                    print("✅ EventTeleport: Event detected! Teleporting...")
                    eventIsActive = true
                    return applyHeightOffset(part.Position)
                end
            end
        end
        
        task.wait(checkInterval)
    end
    
    warn("⚠️ EventTeleport: Timeout waiting for event (", timeout, "seconds)")
    return nil
end

function module.Start(eventName)
    if running then return false end
    if not eventName then return false end
    if not module.Events[eventName] then return false end

    running = true
    currentEventName = eventName
    lastTeleportPosition = nil
    eventIsActive = false
    coordCheckIndex = 1 -- ✅ Reset round-robin index

    -- ✅ REMOVED: Unused Heartbeat connection (was causing overhead)

    -- Main loop in separate thread
    task.spawn(function()
        -- Wait for event to become active first
        if module.RequireEventActive then
            local initialPos = waitForEventActive(currentEventName, module.WaitForEventTimeout)
            
            if not initialPos then
                warn("❌ EventTeleport: Event did not start within timeout, stopping...")
                module.Stop()
                return
            end
            
            doTeleportToPos(initialPos)
        end
        
        -- Continue monitoring and re-teleporting
        while running do
            if not isInSafeZone() then
                local pos, isActive = resolveActivePosition(currentEventName)
                
                if pos and isActive then
                    eventIsActive = true
                    doTeleportToPos(pos)
                elseif module.RequireEventActive and not isActive then
                    if eventIsActive then
                        print("⚠️ EventTeleport: Event ended")
                        eventIsActive = false
                    end
                end
            end

            task.wait(module.ScanInterval) -- ✅ Now 3 seconds instead of 0.75
        end
    end)

    return true
end

function module.Stop()
    running = false
    currentEventName = nil
    lastTeleportPosition = nil
    eventIsActive = false
    coordCheckIndex = 1
    return true
end

function module.GetEventNames()
    local list = {}
    for name, _ in pairs(module.Events) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

function module.HasCoords(eventName)
    local v = module.Events[eventName]
    return v ~= nil and #v > 0
end

function module.SetHeightOffset(offset)
    module.HeightOffset = offset or 15
    print("🎯 EventTeleport: Height offset set to", module.HeightOffset, "studs")
end

function module.SetSafeZoneRadius(radius)
    module.SafeZoneRadius = radius or 50
    print("🎯 EventTeleport: Safe zone radius set to", module.SafeZoneRadius, "studs")
end

function module.SetSmartReteleport(enabled)
    module.UseSmartReteleport = enabled
    print("🎯 EventTeleport: Smart re-teleport", enabled and "enabled" or "disabled")
end

function module.SetRequireEventActive(enabled)
    module.RequireEventActive = enabled
    print("🎯 EventTeleport: Require event active", enabled and "enabled" or "disabled")
end

function module.SetWaitTimeout(seconds)
    module.WaitForEventTimeout = seconds or 300
    print("🎯 EventTeleport: Wait timeout set to", module.WaitForEventTimeout, "seconds")
end

-- ✅ NEW: Set scan interval (allow user to customize performance)
function module.SetScanInterval(seconds)
    module.ScanInterval = math.max(1, seconds or 3) -- minimum 1 second
    print("🎯 EventTeleport: Scan interval set to", module.ScanInterval, "seconds")
end

-- ✅ NEW: Set max objects to check per scan
function module.SetMaxObjectsToCheck(count)
    module.MaxObjectsToCheck = math.max(100, count or 500)
    print("🎯 EventTeleport: Max objects per scan set to", module.MaxObjectsToCheck)
end

function module.IsEventActive()
    return eventIsActive
end

return module
