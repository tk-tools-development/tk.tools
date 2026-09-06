-- Testable module extraction from tk_tools.lua
-- Exposes pure logic functions for unit testing without GUI side effects

local M = {}

-------------------------------------------------------
-- SetupRemote: Remote event discovery/creation logic
-------------------------------------------------------
function M.SetupRemote(ReplicatedStorage, InstanceNew)
    local ServerAccess = false
    local remote = nil

    local rs = ReplicatedStorage
    local existing = rs:FindFirstChild("TK_Remote")
    if not existing then
        local success = pcall(function()
            local newRemote = InstanceNew("RemoteEvent")
            newRemote.Name = "TK_Remote"
            newRemote.Parent = rs
            table.insert(rs._children, newRemote)
            existing = newRemote
            ServerAccess = true
        end)
        if not success then
            existing = rs:FindFirstChild("TK_Remote")
            if existing then ServerAccess = true end
        end
    else
        ServerAccess = true
    end
    remote = existing
    return remote, ServerAccess
end

-------------------------------------------------------
-- Server Handler: dispatch actions on remote events
-------------------------------------------------------
function M.HandleServerAction(action, data, sourcePlayer, allPlayers, Workspace, Debris)
    local results = { action = action, affected = {} }

    if action == "KickAll" then
        for _, plr in pairs(allPlayers) do
            if plr ~= sourcePlayer then
                local ok = pcall(function() plr:Kick("Kicked by TK.TOOLS") end)
                table.insert(results.affected, { player = plr.Name, kicked = ok })
            end
        end

    elseif action == "KillAll" then
        for _, plr in pairs(allPlayers) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                pcall(function() plr.Character:FindFirstChild("Humanoid").Health = 0 end)
                table.insert(results.affected, { player = plr.Name, killed = true })
            end
        end

    elseif action == "ExplodeAll" then
        for _, plr in pairs(allPlayers) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(results.affected, { player = plr.Name, exploded = true })
            end
        end

    elseif action == "FreezeAll" then
        for _, plr in pairs(allPlayers) do
            if plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
                table.insert(results.affected, { player = plr.Name, frozen = true })
            end
        end

    elseif action == "UnfreezeAll" then
        for _, plr in pairs(allPlayers) do
            if plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
                table.insert(results.affected, { player = plr.Name, unfrozen = true })
            end
        end

    elseif action == "FlingAll" then
        for _, plr in pairs(allPlayers) do
            if plr ~= sourcePlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(results.affected, { player = plr.Name, flung = true })
            end
        end

    elseif action == "SuperSpeed" then
        for _, plr in pairs(allPlayers) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character:FindFirstChild("Humanoid").WalkSpeed = 100
                table.insert(results.affected, { player = plr.Name, speed = 100 })
            end
        end

    elseif action == "ResetSpeed" then
        for _, plr in pairs(allPlayers) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character:FindFirstChild("Humanoid").WalkSpeed = 16
                table.insert(results.affected, { player = plr.Name, speed = 16 })
            end
        end

    elseif action == "TeleportAll" then
        local targetPos = data or { X = 0, Y = 100, Z = 0 }
        for _, plr in pairs(allPlayers) do
            if plr ~= sourcePlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(results.affected, { player = plr.Name, teleported = true })
            end
        end
    end

    return results
end

-------------------------------------------------------
-- Feature Registration
-------------------------------------------------------
function M.createFeatureSystem()
    local Features = {}
    local FeatureStates = {}

    local system = {}

    function system.addFeature(tab, name, desc, callback)
        local key = tab .. "_" .. name
        FeatureStates[key] = false

        if not Features[tab] then
            Features[tab] = {}
        end

        local feature = {
            name = name,
            desc = desc,
            tab = tab,
            key = key,
            callback = callback,
            visible = true,
        }
        table.insert(Features[tab], feature)
        return feature
    end

    function system.toggleFeature(tab, name)
        local key = tab .. "_" .. name
        local newState = not FeatureStates[key]
        FeatureStates[key] = newState
        -- Find and call callback
        if Features[tab] then
            for _, feature in ipairs(Features[tab]) do
                if feature.name == name and feature.callback then
                    pcall(feature.callback, newState)
                end
            end
        end
        return newState
    end

    function system.getState(tab, name)
        local key = tab .. "_" .. name
        return FeatureStates[key]
    end

    function system.getFeatures()
        return Features
    end

    function system.getStates()
        return FeatureStates
    end

    return system
end

-------------------------------------------------------
-- Search / Filter
-------------------------------------------------------
function M.filterFeatures(features, query)
    query = (query or ""):lower()
    local results = {}

    for tab, tabFeatures in pairs(features) do
        results[tab] = {}
        for _, item in pairs(tabFeatures) do
            local match = query == ""
                or string.find(item.name:lower(), query)
                or string.find((item.desc or ""):lower(), query)
            table.insert(results[tab], {
                name = item.name,
                desc = item.desc,
                visible = match and true or false,
            })
        end
    end

    return results
end

-------------------------------------------------------
-- Canvas size calculation
-------------------------------------------------------
function M.calculateCanvasHeight(items, itemHeight, spacing)
    itemHeight = itemHeight or 34
    spacing = spacing or 4
    local totalHeight = 0
    local visibleCount = 0
    for _, item in pairs(items) do
        if item.visible ~= false then
            totalHeight = totalHeight + itemHeight + spacing
            visibleCount = visibleCount + 1
        end
    end
    return totalHeight + 20, visibleCount
end

-------------------------------------------------------
-- Client Feature Logic (pure functions)
-------------------------------------------------------

function M.applyNoclip(character, enabled)
    if not character then return false end
    local count = 0
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
            count = count + 1
        end
    end
    return count > 0, count
end

function M.applySpeedBoost(character, enabled)
    if not character then return false end
    local hum = character:FindFirstChild("Humanoid")
    if not hum then return false end
    hum.WalkSpeed = enabled and 32 or 16
    return true, hum.WalkSpeed
end

function M.applyJumpBoost(character, enabled)
    if not character then return false end
    local hum = character:FindFirstChild("Humanoid")
    if not hum then return false end
    hum.JumpPower = enabled and 100 or 50
    return true, hum.JumpPower
end

function M.applySuperJump(character, enabled)
    if not character then return false end
    local hum = character:FindFirstChild("Humanoid")
    if not hum then return false end
    hum.JumpPower = enabled and 500 or 50
    return true, hum.JumpPower
end

function M.applyMoonGravity(workspace, enabled)
    workspace.Gravity = enabled and 50 or 196.2
    return workspace.Gravity
end

function M.applyNoGravity(workspace, enabled)
    workspace.Gravity = enabled and 0 or 196.2
    return workspace.Gravity
end

function M.applyWalkSpeed(character, speed, enabled)
    if not character then return false end
    local hum = character:FindFirstChild("Humanoid")
    if not hum then return false end
    hum.WalkSpeed = enabled and speed or 16
    return true, hum.WalkSpeed
end

function M.applyFullbright(lighting, enabled)
    lighting.Brightness = enabled and 10 or 1
    return lighting.Brightness
end

function M.applyFogOff(lighting, enabled)
    lighting.FogEnd = enabled and 99999 or 1000
    return lighting.FogEnd
end

function M.applyNoShadows(lighting, enabled)
    lighting.Shadows = not enabled
    return lighting.Shadows
end

function M.applyThirdPerson(player, enabled)
    player.CameraMode = enabled and "Classic" or "LockFirstPerson"
    return player.CameraMode
end

function M.applyDisconnect(player)
    player:Kick("Disconnected by TK.TOOLS")
    return player._kicked
end

-------------------------------------------------------
-- Server Feature Logic (dispatch with fallback)
-------------------------------------------------------
function M.executeServerFeature(action, remoteEvent, serverAccess, localPlayer, allPlayers)
    if remoteEvent and serverAccess then
        return "remote", action
    else
        return "local", action
    end
end

-------------------------------------------------------
-- ESP Logic
-------------------------------------------------------
function M.applyESP(localPlayer, allPlayers, workspace, enabled)
    local count = 0
    if enabled then
        for _, plr in pairs(allPlayers) do
            if plr ~= localPlayer and plr.Character then
                count = count + 1
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "TK_ESP" then
                v:Destroy()
                count = count + 1
            end
        end
    end
    return count
end

-------------------------------------------------------
-- Fling Logic
-------------------------------------------------------
function M.flingPlayer(character)
    if not character then return false end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return true
end

function M.flingAllPlayers(allPlayers)
    local count = 0
    for _, plr in pairs(allPlayers) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            count = count + 1
        end
    end
    return count
end

-------------------------------------------------------
-- Tool Spawning
-------------------------------------------------------
function M.getToolNames()
    return {"Sword", "Gun", "Rocket", "Katana", "Grapple", "Jetpack", "Shield", "Bomb", "Scythe", "Nuke"}
end

function M.getTrollToolNames()
    return {"Sword", "Gun", "Rocket", "Katana", "Grapple", "Jetpack", "Shield", "Bomb"}
end

-------------------------------------------------------
-- Tab definitions
-------------------------------------------------------
function M.getTabNames()
    return {"Client", "Server", "Visuals", "Movement", "Troll", "Utility"}
end

-------------------------------------------------------
-- Menu toggle
-------------------------------------------------------
function M.handleMenuToggle(input, processed, currentVisible)
    if processed then return currentVisible end
    if input.KeyCode == "RightControl" then
        return not currentVisible
    end
    return currentVisible
end

return M
