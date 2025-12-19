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

-- =======================
-- Internal state
-- =======================
local running = false
local currentEventName = nil
local heartbeatConn = nil

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

-- find parts/models in workspace that are close to a Vector3 position
local function findNearbyObject(centerPos, radius)
    -- Simple, robust approach: scan workspace descendants for BasePart whose position is within radius.
    -- This is heavier but reliable across games. Limit scanning to reasonable number of descendants.
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
    local maxChecks = 2000 -- tuneable, avoid scanning entire huge workspace every tick
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

-- Given an eventName, find the "active coordinate" in this server:
-- strategy:
-- 1) iterate declared coords for event (if any)
-- 2) for each declared coord, search workspace for nearby spawned parts/models (using radius)
-- 3) if found a part, return that part.Position (or part itself)
-- 4) if none found, return best fallback declared coord (closest to player)
local function resolveActivePosition(eventName)
    local coords = module.Events[eventName]
    if not coords or #coords == 0 then
        return nil -- no static coords to use
    end

    -- try to find spawned part near each declared coord
    for _, coord in ipairs(coords) do
        local part = findNearbyObject(coord, module.SearchRadius)
        if part then
            -- if found, return part's CFrame.Position (more accurate than declared coord)
            return part.Position, part
        end
    end

    -- fallback: return closest declared coord to player
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
        return best, nil
    end

    -- last-resort: first coordinate
    return coords[1], nil
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
        return true
    end
    return false
end

-- Exposed simple call: teleport once now to eventName (resolve active pos)
function module.TeleportNow(eventName)
    if not eventName then return false end
    local ok, posOrPart = pcall(function()
        return resolveActivePosition(eventName)
    end)
    if not ok or not posOrPart then
        return false
    end

    -- resolveActivePosition returns (pos, part) ; pcall returned that.
    local pos = posOrPart
    if type(pos) == "userdata" and pos.ClassName == "Instance" then
        -- unlikely because resolve returns Vector3 first; handle if swapped
        pos = pos.Position
    end

    return doTeleportToPos(pos)
end

-- Start auto-follow/teleport loop to chosen event
function module.Start(eventName)
    if running then return false end
    if not eventName then return false end
    if not module.Events[eventName] then return false end

    running = true
    currentEventName = eventName

    -- heartbeat loop: every ScanInterval, try to resolve active pos and teleport
    heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        -- offtick logic: use a timer to avoid running every frame
    end)

    -- We'll use a simple loop in task.spawn to avoid doing heavy work in Heartbeat directly
    task.spawn(function()
        while running do
            local ok, posOrPart = pcall(function()
                return resolveActivePosition(currentEventName)
            end)

            if ok and posOrPart then
                local pos = posOrPart
                if typeof(pos) == "Instance" then
                    pos = pos.Position
                end
                doTeleportToPos(pos)
            end

            task.wait(module.ScanInterval)
        end
    end)

    return true
end

function module.Stop()
    running = false
    currentEventName = nil
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

return module
