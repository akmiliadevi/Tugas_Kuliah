-- EventTeleportDynamic.lua (ULTRA OPTIMIZED - ZERO STUTTERING) cukiii

local Players = game:GetService("Players")
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

    ["Treasure Hunt"] = nil,
}

-- =======================
-- Config (ULTRA PERFORMANCE)
-- =======================
module.SearchRadius = 25            -- increased for better detection
module.TeleportCheckInterval = 5.0  -- only check teleport need every 5 seconds
module.HeightOffset = 15
module.SafeZoneRadius = 50
module.UseSmartReteleport = true
module.RequireEventActive = true
module.WaitForEventTimeout = 300

-- =======================
-- Internal state
-- =======================
local running = false
local currentEventName = nil
local lastTeleportPosition = nil
local eventIsActive = false
local cachedEventPosition = nil     -- ✅ CACHE position instead of re-scanning
local workspaceChildAddedConn = nil -- ✅ Listen for new objects
local workspaceChildRemovedConn = nil

-- ================
-- Utilities
-- ================
local function safeCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function applyHeightOffset(pos)
    if not pos then return nil end
    return Vector3.new(pos.X, pos.Y + module.HeightOffset, pos.Z)
end

local function isInSafeZone()
    if not module.UseSmartReteleport or not lastTeleportPosition then
        return false
    end
    
    local hrp = getHRP()
    if not hrp then return false end
    
    return (hrp.Position - lastTeleportPosition).Magnitude <= module.SafeZoneRadius
end

-- ✅ REVOLUTIONARY: Use spatial query ONLY (no GetDescendants)
local function findNearbyObjectFast(centerPos, radius)
    -- ONLY use GetPartBoundsInBox - this is 100x faster than GetDescendants
    if not Workspace.GetPartBoundsInBox then
        return nil -- fallback disabled to prevent stuttering
    end
    
    local ok, parts = pcall(function()
        return Workspace:GetPartBoundsInBox(
            CFrame.new(centerPos), 
            Vector3.new(radius*2, radius*2, radius*2)
        )
    end)
    
    if not ok or not parts then return nil end
    
    local bestPart = nil
    local bestDist = math.huge
    
    for _, p in ipairs(parts) do
        if p and p:IsA("BasePart") then
            local d = (p.Position - centerPos).Magnitude
            if d <= radius and d < bestDist then
                bestDist = d
                bestPart = p
            end
        end
    end
    
    return bestPart
end

-- ✅ ASYNC scanning with yielding (prevents frame drops)
local function scanEventCoordsAsync(eventName)
    local coords = module.Events[eventName]
    if not coords or #coords == 0 then return nil end
    
    -- Check each coordinate with yielding between checks
    for i, coord in ipairs(coords) do
        local part = findNearbyObjectFast(coord, module.SearchRadius)
        
        if part then
            local pos = applyHeightOffset(part.Position)
            cachedEventPosition = pos -- ✅ CACHE the result
            return pos
        end
        
        -- ✅ Yield every 2 checks to prevent stuttering
        if i % 2 == 0 then
            task.wait()
        end
    end
    
    return nil
end

-- ✅ EVENT LISTENER: Detect when objects spawn (no scanning needed!)
local function setupEventListeners(eventName)
    local coords = module.Events[eventName]
    if not coords then return end
    
    -- Listen for new objects added to workspace
    workspaceChildAddedConn = Workspace.ChildAdded:Connect(function(child)
        if not running then return end
        
        -- Quick check if it's near any event coordinate
        task.spawn(function()
            task.wait(0.5) -- let object fully load
            
            for _, coord in ipairs(coords) do
                if child:IsA("BasePart") then
                    local dist = (child.Position - coord).Magnitude
                    if dist <= module.SearchRadius then
                        print("🎯 Event object spawned:", child.Name)
                        cachedEventPosition = applyHeightOffset(child.Position)
                        eventIsActive = true
                        return
                    end
                end
                
                -- Check descendants
                for _, desc in ipairs(child:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        local dist = (desc.Position - coord).Magnitude
                        if dist <= module.SearchRadius then
                            print("🎯 Event object spawned:", desc.Name)
                            cachedEventPosition = applyHeightOffset(desc.Position)
                            eventIsActive = true
                            return
                        end
                    end
                end
            end
        end)
    end)
    
    -- Listen for objects removed
    workspaceChildRemovedConn = Workspace.ChildRemoved:Connect(function(child)
        if not running then return end
        -- Event might have ended
        task.spawn(function()
            task.wait(2)
            -- Re-verify event is still active
            local pos = scanEventCoordsAsync(eventName)
            if not pos then
                print("⚠️ Event ended (object removed)")
                eventIsActive = false
                cachedEventPosition = nil
            end
        end)
    end)
end

local function cleanupEventListeners()
    if workspaceChildAddedConn then
        workspaceChildAddedConn:Disconnect()
        workspaceChildAddedConn = nil
    end
    if workspaceChildRemovedConn then
        workspaceChildRemovedConn:Disconnect()
        workspaceChildRemovedConn = nil
    end
end

-- ✅ Use cached position (no scanning during active teleport!)
local function resolveActivePosition()
    if cachedEventPosition and eventIsActive then
        return cachedEventPosition, true
    end
    return nil, false
end

local function doTeleportToPos(pos)
    if not pos then return false end
    local char = safeCharacter()
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    pcall(function()
        if char.PrimaryPart then
            char:PivotTo(CFrame.new(pos))
        else
            hrp.CFrame = CFrame.new(pos)
        end
    end)
    
    lastTeleportPosition = pos
    return true
end

function module.TeleportNow(eventName)
    if not eventName then return false end
    
    local pos, isActive = resolveActivePosition()
    
    if not pos then
        if module.RequireEventActive then
            warn("⚠️ EventTeleport: Event not active")
        end
        return false
    end

    return doTeleportToPos(pos)
end

-- ✅ Initial wait with ASYNC scanning
local function waitForEventActive(eventName, timeout)
    local startTime = tick()
    
    print("🔍 EventTeleport: Waiting for event to start...")
    
    while tick() - startTime < timeout do
        local pos = scanEventCoordsAsync(eventName) -- async with yielding
        
        if pos then
            print("✅ EventTeleport: Event detected!")
            eventIsActive = true
            cachedEventPosition = pos
            return pos
        end
        
        task.wait(3) -- check every 3 seconds during wait phase
    end
    
    warn("⚠️ EventTeleport: Timeout waiting for event")
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
    cachedEventPosition = nil

    -- ✅ Setup event listeners (no continuous scanning!)
    setupEventListeners(eventName)

    task.spawn(function()
        -- Initial scan to find event
        if module.RequireEventActive then
            local initialPos = waitForEventActive(currentEventName, module.WaitForEventTimeout)
            
            if not initialPos then
                warn("❌ EventTeleport: Event did not start, stopping...")
                module.Stop()
                return
            end
            
            doTeleportToPos(initialPos)
        end
        
        -- ✅ LIGHTWEIGHT monitoring loop (uses cache, no scanning!)
        while running do
            if not isInSafeZone() then
                local pos, isActive = resolveActivePosition()
                
                if pos and isActive then
                    doTeleportToPos(pos)
                else
                    -- Only re-scan if cache is invalid
                    print("🔄 Re-scanning event position...")
                    local newPos = scanEventCoordsAsync(currentEventName)
                    if newPos then
                        cachedEventPosition = newPos
                        eventIsActive = true
                        doTeleportToPos(newPos)
                    else
                        eventIsActive = false
                        print("⚠️ Event not found")
                    end
                end
            end

            task.wait(module.TeleportCheckInterval) -- ✅ Only check every 5 seconds
        end
    end)

    return true
end

function module.Stop()
    running = false
    currentEventName = nil
    lastTeleportPosition = nil
    eventIsActive = false
    cachedEventPosition = nil
    cleanupEventListeners()
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
    print("🎯 Height offset:", module.HeightOffset)
end

function module.SetSafeZoneRadius(radius)
    module.SafeZoneRadius = radius or 50
    print("🎯 Safe zone radius:", module.SafeZoneRadius)
end

function module.SetSmartReteleport(enabled)
    module.UseSmartReteleport = enabled
    print("🎯 Smart re-teleport:", enabled and "ON" or "OFF")
end

function module.SetRequireEventActive(enabled)
    module.RequireEventActive = enabled
    print("🎯 Require event active:", enabled and "ON" or "OFF")
end

function module.SetWaitTimeout(seconds)
    module.WaitForEventTimeout = seconds or 300
    print("🎯 Wait timeout:", module.WaitForEventTimeout, "sec")
end

function module.SetTeleportCheckInterval(seconds)
    module.TeleportCheckInterval = math.max(3, seconds or 5)
    print("🎯 Teleport check interval:", module.TeleportCheckInterval, "sec")
end

function module.IsEventActive()
    return eventIsActive
end

-- ✅ Force re-scan (manual refresh)
function module.RefreshEventPosition()
    if not running or not currentEventName then return false end
    
    print("🔄 Manually refreshing event position...")
    task.spawn(function()
        local pos = scanEventCoordsAsync(currentEventName)
        if pos then
            cachedEventPosition = pos
            eventIsActive = true
            print("✅ Position refreshed")
        else
            eventIsActive = false
            cachedEventPosition = nil
            print("❌ Event not found")
        end
    end)
    
    return true
end

return module
