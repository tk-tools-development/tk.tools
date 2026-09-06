-- Roblox API Mock Framework for unit testing tk_tools.lua
-- Provides mock implementations of Roblox services, instances, and types

local RobloxMock = {}

-------------------------------------------------------
-- Vector3
-------------------------------------------------------
local Vector3 = {}
Vector3.__index = Vector3

function Vector3.new(x, y, z)
    return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, Vector3)
end

function Vector3.__add(a, b)
    return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

function Vector3.__sub(a, b)
    return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

function Vector3.__mul(a, b)
    if type(a) == "number" then
        return Vector3.new(a * b.X, a * b.Y, a * b.Z)
    elseif type(b) == "number" then
        return Vector3.new(a.X * b, a.Y * b, a.Z * b)
    end
    return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end

function Vector3.__eq(a, b)
    return a.X == b.X and a.Y == b.Y and a.Z == b.Z
end

function Vector3.__tostring(v)
    return string.format("Vector3(%g, %g, %g)", v.X, v.Y, v.Z)
end

-------------------------------------------------------
-- Vector2
-------------------------------------------------------
local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    return setmetatable({ X = x or 0, Y = y or 0 }, Vector2)
end

-------------------------------------------------------
-- CFrame
-------------------------------------------------------
local CFrame = {}
CFrame.__index = CFrame

function CFrame.new(x, y, z)
    if type(x) == "table" and getmetatable(x) == Vector3 then
        return setmetatable({ Position = x }, CFrame)
    end
    return setmetatable({ Position = Vector3.new(x or 0, y or 0, z or 0) }, CFrame)
end

function CFrame.Angles(rx, ry, rz)
    return setmetatable({ Position = Vector3.new(0, 0, 0), _rx = rx, _ry = ry, _rz = rz }, CFrame)
end

function CFrame.__mul(a, b)
    return CFrame.new(a.Position + (b.Position or Vector3.new(0, 0, 0)))
end

function CFrame.__add(a, b)
    if getmetatable(b) == Vector3 then
        return CFrame.new(a.Position + b)
    end
    return a
end

-------------------------------------------------------
-- UDim / UDim2
-------------------------------------------------------
local UDim = {}
UDim.__index = UDim
function UDim.new(scale, offset)
    return setmetatable({ Scale = scale or 0, Offset = offset or 0 }, UDim)
end

local UDim2 = {}
UDim2.__index = UDim2
function UDim2.new(xs, xo, ys, yo)
    return setmetatable({
        X = UDim.new(xs, xo),
        Y = UDim.new(ys, yo),
    }, UDim2)
end

-------------------------------------------------------
-- Color3 / ColorSequence / NumberSequence
-------------------------------------------------------
local Color3 = {}
Color3.__index = Color3

function Color3.fromRGB(r, g, b)
    return setmetatable({ R = (r or 0) / 255, G = (g or 0) / 255, B = (b or 0) / 255 }, Color3)
end

function Color3.fromHSV(h, s, v)
    return setmetatable({ R = h, G = s, B = v, _hsv = true }, Color3)
end

local ColorSequenceKeypoint = {}
function ColorSequenceKeypoint.new(time, color)
    return { Time = time, Value = color }
end

local ColorSequence = {}
function ColorSequence.new(keypoints)
    return { Keypoints = keypoints }
end

local NumberSequenceKeypoint = {}
function NumberSequenceKeypoint.new(time, value)
    return { Time = time, Value = value }
end

local NumberSequence = {}
function NumberSequence.new(keypoints)
    return { Keypoints = keypoints }
end

-------------------------------------------------------
-- BrickColor
-------------------------------------------------------
local BrickColor = {}
function BrickColor.Random()
    return { Name = "Random", Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)) }
end

-------------------------------------------------------
-- TweenInfo
-------------------------------------------------------
local TweenInfo = {}
TweenInfo.__index = TweenInfo
function TweenInfo.new(time, style, dir, count, reverses, delay)
    return setmetatable({
        Time = time or 1,
        EasingStyle = style,
        EasingDirection = dir,
        RepeatCount = count or 0,
        Reverses = reverses or false,
        DelayTime = delay or 0,
    }, TweenInfo)
end

-------------------------------------------------------
-- Enum
-------------------------------------------------------
local Enum = {
    Font = {
        Gotham = "Gotham",
        GothamBold = "GothamBold",
        GothamSemibold = "GothamSemibold",
    },
    TextXAlignment = {
        Left = "Left",
        Center = "Center",
        Right = "Right",
    },
    SortOrder = {
        LayoutOrder = "LayoutOrder",
    },
    KeyCode = {
        RightControl = "RightControl",
    },
    CameraMode = {
        Classic = "Classic",
        LockFirstPerson = "LockFirstPerson",
    },
    Material = {
        Neon = "Neon",
    },
}

-------------------------------------------------------
-- Instance (mock Roblox object)
-------------------------------------------------------
local Instance = {}
Instance.__index = Instance

local instanceCount = 0

function Instance.new(className, parent)
    instanceCount = instanceCount + 1
    local obj = setmetatable({
        ClassName = className,
        Name = className,
        Parent = nil,
        _children = {},
        _destroyed = false,
        _id = instanceCount,
        _connections = {},
        _propertyChangedSignals = {},
    }, Instance)

    -- Class-specific defaults
    if className == "Humanoid" then
        obj.Health = 100
        obj.MaxHealth = 100
        obj.WalkSpeed = 16
        obj.JumpPower = 50
    elseif className == "HumanoidRootPart" or className == "Part" or className == "BasePart" then
        obj.Position = Vector3.new(0, 0, 0)
        obj.CFrame = CFrame.new(0, 0, 0)
        obj.Anchored = false
        obj.CanCollide = true
        obj.Size = Vector3.new(2, 2, 2)
        obj.Color = Color3.fromRGB(128, 128, 128)
        obj.BrickColor = BrickColor.Random()
        obj.Material = "Plastic"
    elseif className == "BodyVelocity" then
        obj.Velocity = Vector3.new(0, 0, 0)
        obj.MaxForce = Vector3.new(0, 0, 0)
    elseif className == "Explosion" then
        obj.Position = Vector3.new(0, 0, 0)
        obj.BlastRadius = 4
        obj.BlastPressure = 500000
    elseif className == "Highlight" then
        obj.Adornee = nil
        obj.FillColor = Color3.fromRGB(255, 0, 0)
        obj.FillTransparency = 0.5
        obj.OutlineColor = Color3.fromRGB(255, 255, 255)
        obj.OutlineTransparency = 0
    elseif className == "RemoteEvent" then
        obj._serverCallbacks = {}
        obj.OnServerEvent = {
            Connect = function(_, callback)
                table.insert(obj._serverCallbacks, callback)
                return { Disconnect = function() end }
            end,
        }
    elseif className == "Sound" then
        obj.SoundId = ""
        obj.Volume = 1
        obj.PlayOnRemove = false
        obj.Playing = false
    elseif className == "Tool" then
        obj.RequiresHandle = true
    elseif className == "ScreenGui" then
        obj.ResetOnSpawn = true
        obj.Enabled = true
    elseif className == "Frame" then
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Position = UDim2.new(0, 0, 0, 0)
        obj.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        obj.BackgroundTransparency = 0
        obj.BorderSizePixel = 1
        obj.BorderColor3 = Color3.fromRGB(0, 0, 0)
        obj.ClipsDescendants = false
        obj.Visible = true
        obj.ZIndex = 1
    elseif className == "TextLabel" then
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Position = UDim2.new(0, 0, 0, 0)
        obj.BackgroundTransparency = 0
        obj.Text = ""
        obj.TextColor3 = Color3.fromRGB(0, 0, 0)
        obj.TextSize = 14
        obj.Font = "Legacy"
        obj.TextXAlignment = "Center"
        obj.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        obj.TextStrokeTransparency = 1
    elseif className == "TextButton" then
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Position = UDim2.new(0, 0, 0, 0)
        obj.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        obj.BackgroundTransparency = 0
        obj.BorderSizePixel = 1
        obj.Text = ""
        obj.TextColor3 = Color3.fromRGB(0, 0, 0)
        obj.TextSize = 14
        obj.Font = "Legacy"
        obj.Visible = true
        obj._clickCallbacks = {}
        obj._enterCallbacks = {}
        obj._leaveCallbacks = {}
        obj.MouseButton1Click = {
            Connect = function(_, callback)
                table.insert(obj._clickCallbacks, callback)
                return { Disconnect = function() end }
            end,
        }
        obj.MouseEnter = {
            Connect = function(_, callback)
                table.insert(obj._enterCallbacks, callback)
                return { Disconnect = function() end }
            end,
        }
        obj.MouseLeave = {
            Connect = function(_, callback)
                table.insert(obj._leaveCallbacks, callback)
                return { Disconnect = function() end }
            end,
        }
    elseif className == "TextBox" then
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.Position = UDim2.new(0, 0, 0, 0)
        obj.BackgroundTransparency = 0
        obj.Text = ""
        obj.TextColor3 = Color3.fromRGB(0, 0, 0)
        obj.TextSize = 14
        obj.Font = "Legacy"
        obj.PlaceholderText = ""
        obj.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    elseif className == "ScrollingFrame" then
        obj.Size = UDim2.new(0, 0, 0, 0)
        obj.BackgroundTransparency = 0
        obj.BorderSizePixel = 1
        obj.CanvasSize = UDim2.new(0, 0, 0, 0)
        obj.ScrollBarThickness = 12
        obj.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        obj.ScrollBarImageTransparency = 0
        obj.Visible = true
    elseif className == "UIListLayout" then
        obj.SortOrder = "LayoutOrder"
        obj.Padding = UDim.new(0, 0)
    elseif className == "UICorner" then
        obj.CornerRadius = UDim.new(0, 0)
    elseif className == "UIGradient" then
        obj.Color = nil
        obj.Rotation = 0
        obj.Transparency = nil
    end

    if parent then
        obj.Parent = parent
        table.insert(parent._children, obj)
    end

    return obj
end

function Instance:IsA(className)
    local hierarchy = {
        Part = { "BasePart", "Part" },
        HumanoidRootPart = { "BasePart", "Part", "HumanoidRootPart" },
        BasePart = { "BasePart" },
        Humanoid = { "Humanoid" },
        TextButton = { "TextButton", "GuiButton", "GuiObject" },
        Frame = { "Frame", "GuiObject" },
        ScrollingFrame = { "ScrollingFrame", "GuiObject" },
    }
    local classes = hierarchy[self.ClassName] or { self.ClassName }
    for _, c in ipairs(classes) do
        if c == className then return true end
    end
    return false
end

function Instance:FindFirstChild(name)
    for _, child in ipairs(self._children) do
        if child.Name == name and not child._destroyed then
            return child
        end
    end
    return nil
end

function Instance:WaitForChild(name)
    return self:FindFirstChild(name)
end

function Instance:GetChildren()
    local result = {}
    for _, child in ipairs(self._children) do
        if not child._destroyed then
            table.insert(result, child)
        end
    end
    return result
end

function Instance:GetDescendants()
    local result = {}
    local function collect(obj)
        for _, child in ipairs(obj._children) do
            if not child._destroyed then
                table.insert(result, child)
                collect(child)
            end
        end
    end
    collect(self)
    return result
end

function Instance:Destroy()
    self._destroyed = true
    if self.Parent then
        for i, child in ipairs(self.Parent._children) do
            if child == self then
                table.remove(self.Parent._children, i)
                break
            end
        end
    end
    self.Parent = nil
end

function Instance:GetPropertyChangedSignal(prop)
    if not self._propertyChangedSignals[prop] then
        self._propertyChangedSignals[prop] = {
            _callbacks = {},
            Connect = function(signal, callback)
                table.insert(signal._callbacks, callback)
                return { Disconnect = function() end }
            end,
        }
    end
    return self._propertyChangedSignals[prop]
end

function Instance:FireServer(...)
    if self.ClassName == "RemoteEvent" then
        for _, cb in ipairs(self._serverCallbacks) do
            cb(nil, ...)
        end
    end
end

function Instance:Play()
    if self.ClassName == "Sound" then
        self.Playing = true
    end
end

function Instance:Kick(msg)
    self._kicked = true
    self._kickMessage = msg
end

-------------------------------------------------------
-- Mock Services
-------------------------------------------------------
local function createPlayersService()
    local playerList = {}
    local service = {
        _type = "PlayersService",
        GetPlayers = function(self)
            return playerList
        end,
        _addPlayer = function(self, player)
            table.insert(playerList, player)
        end,
        _clearPlayers = function(self)
            playerList = {}
        end,
    }
    return service
end

local function createMockPlayer(name, opts)
    opts = opts or {}
    local player = Instance.new("Player")
    player.Name = name
    player._kicked = false

    -- PlayerGui
    local playerGui = Instance.new("Folder")
    playerGui.Name = "PlayerGui"
    playerGui.Parent = player
    table.insert(player._children, playerGui)

    -- Backpack
    local backpack = Instance.new("Folder")
    backpack.Name = "Backpack"
    backpack.Parent = player
    table.insert(player._children, backpack)

    player.Backpack = backpack
    player.CameraMode = Enum.CameraMode.Classic

    -- Chatted signal
    player.Chatted = {
        Fire = function(_, msg) player._lastChat = msg end,
    }

    -- CharacterAdded signal
    player.CharacterAdded = {
        Connect = function(_, callback)
            player._characterAddedCallback = callback
            return { Disconnect = function() end }
        end,
    }

    -- Kick
    function player:Kick(msg)
        self._kicked = true
        self._kickMessage = msg
    end

    -- Character setup
    if opts.hasCharacter ~= false then
        local char = Instance.new("Model")
        char.Name = name .. "'s Character"

        local humanoid = Instance.new("Humanoid")
        humanoid.Name = "Humanoid"
        humanoid.Health = opts.health or 100
        humanoid.WalkSpeed = opts.walkSpeed or 16
        humanoid.JumpPower = opts.jumpPower or 50
        humanoid.Parent = char
        table.insert(char._children, humanoid)

        local rootPart = Instance.new("HumanoidRootPart")
        rootPart.Name = "HumanoidRootPart"
        rootPart.Position = opts.position or Vector3.new(0, 5, 0)
        rootPart.CFrame = CFrame.new(rootPart.Position)
        rootPart.Anchored = false
        rootPart.CanCollide = true
        rootPart.Parent = char
        table.insert(char._children, rootPart)

        if opts.extraParts then
            for _, partName in ipairs(opts.extraParts) do
                local part = Instance.new("Part")
                part.Name = partName
                part.Anchored = false
                part.CanCollide = true
                part.Parent = char
                table.insert(char._children, part)
            end
        end

        player.Character = char
    else
        player.Character = nil
    end

    return player
end

local function createWorkspace()
    local ws = Instance.new("Folder")
    ws.Name = "Workspace"
    ws.Gravity = 196.2
    ws.CurrentCamera = {
        CFrame = CFrame.new(0, 0, 0),
    }
    return ws
end

local function createLighting()
    return {
        Brightness = 1,
        FogEnd = 1000,
        Shadows = true,
    }
end

local function createTweenService()
    return {
        Create = function(self, obj, tweenInfo, goals)
            return {
                Play = function()
                    for k, v in pairs(goals) do
                        obj[k] = v
                    end
                end,
            }
        end,
    }
end

local function createRunService()
    return {
        IsServer = function(self) return false end,
    }
end

local function createUserInputService()
    local callbacks = {}
    return {
        InputBegan = {
            Connect = function(_, callback)
                table.insert(callbacks, callback)
                return { Disconnect = function() end }
            end,
        },
        _callbacks = callbacks,
    }
end

local function createReplicatedStorage()
    local rs = Instance.new("Folder")
    rs.Name = "ReplicatedStorage"
    return rs
end

local function createDebris()
    return {
        AddItem = function(self, item, lifetime)
            -- no-op in tests; tracked for assertions
            item._debrisLifetime = lifetime
        end,
    }
end

-------------------------------------------------------
-- Global Environment Setup
-------------------------------------------------------
function RobloxMock.setup()
    local env = {}

    env.Players = createPlayersService()
    env.Workspace = createWorkspace()
    env.Lighting = createLighting()
    env.TweenService = createTweenService()
    env.RunService = createRunService()
    env.UserInputService = createUserInputService()
    env.ReplicatedStorage = createReplicatedStorage()
    env.Debris = createDebris()

    env.Vector3 = Vector3
    env.Vector2 = Vector2
    env.CFrame = CFrame
    env.UDim = UDim
    env.UDim2 = UDim2
    env.Color3 = Color3
    env.ColorSequence = ColorSequence
    env.ColorSequenceKeypoint = ColorSequenceKeypoint
    env.NumberSequence = NumberSequence
    env.NumberSequenceKeypoint = NumberSequenceKeypoint
    env.BrickColor = BrickColor
    env.TweenInfo = TweenInfo
    env.Enum = Enum
    env.Instance = Instance

    -- Create a local player
    env.LocalPlayer = createMockPlayer("LocalPlayer", {
        hasCharacter = true,
        extraParts = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" },
    })

    -- game:GetService mock
    env.game = {
        GetService = function(self, serviceName)
            if serviceName == "Players" then return env.Players
            elseif serviceName == "UserInputService" then return env.UserInputService
            elseif serviceName == "TweenService" then return env.TweenService
            elseif serviceName == "RunService" then return env.RunService
            elseif serviceName == "Workspace" then return env.Workspace
            elseif serviceName == "ReplicatedStorage" then return env.ReplicatedStorage
            elseif serviceName == "Lighting" then return env.Lighting
            elseif serviceName == "Debris" then return env.Debris
            elseif serviceName == "VirtualUser" then
                return {
                    CaptureController = function() end,
                    ClickButton2 = function(_, pos) end,
                }
            end
            return nil
        end,
    }

    -- Roblox globals
    env.task = {
        wait = function(t) end,
    }
    env.spawn = function(fn) fn() end
    env.tick = function() return os.clock() end

    return env
end

function RobloxMock.createMockPlayer(name, opts)
    return createMockPlayer(name, opts)
end

function RobloxMock.resetInstanceCount()
    instanceCount = 0
end

-- Export types for test assertions
RobloxMock.Vector3 = Vector3
RobloxMock.Vector2 = Vector2
RobloxMock.CFrame = CFrame
RobloxMock.UDim = UDim
RobloxMock.UDim2 = UDim2
RobloxMock.Color3 = Color3
RobloxMock.Instance = Instance
RobloxMock.Enum = Enum

return RobloxMock
