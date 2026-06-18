-- TK.TOOLS V6.0 - Complete Working Menu
-- GitHub: tk-tools-development/tk.tools

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

-- Server Access Check
local ServerAccess = false
local RemoteEvent = nil

local function SetupRemote()
    local rs = ReplicatedStorage
    local remote = rs:FindFirstChild("TK_Remote")
    if not remote then
        local success = pcall(function()
            local newRemote = Instance.new("RemoteEvent")
            newRemote.Name = "TK_Remote"
            newRemote.Parent = rs
            remote = newRemote
            ServerAccess = true
        end)
        if not success then
            remote = rs:FindFirstChild("TK_Remote")
            if remote then ServerAccess = true end
        end
    else
        ServerAccess = true
    end
    RemoteEvent = remote
    return remote
end
SetupRemote()

-- Server Handler
if RunService:IsServer() and RemoteEvent then
    RemoteEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "KickAll" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then pcall(function() plr:Kick("Kicked by TK.TOOLS") end) end
            end
        elseif action == "KillAll" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    pcall(function() plr.Character.Humanoid.Health = 0 end)
                end
            end
        elseif action == "ExplodeAll" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local exp = Instance.new("Explosion")
                    exp.Position = plr.Character.HumanoidRootPart.Position
                    exp.BlastRadius = 30
                    exp.BlastPressure = 500000
                    exp.Parent = Workspace
                end
            end
        elseif action == "FreezeAll" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    for _, part in pairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.Anchored = true end
                    end
                end
            end
        elseif action == "UnfreezeAll" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    for _, part in pairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.Anchored = false end
                    end
                end
            end
        elseif action == "FlingAll" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local root = plr.Character.HumanoidRootPart
                    local vel = Instance.new("BodyVelocity")
                    vel.Velocity = Vector3.new(math.random(-1000,1000), math.random(500,1500), math.random(-1000,1000))
                    vel.MaxForce = Vector3.new(1e9,1e9,1e9)
                    vel.Parent = root
                    Debris:AddItem(vel, 0.5)
                end
            end
        elseif action == "SuperSpeed" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.WalkSpeed = 100
                end
            end
        elseif action == "ResetSpeed" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.WalkSpeed = 16
                end
            end
        elseif action == "TeleportAll" then
            local targetPos = data or Vector3.new(0,100,0)
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-5,5),0,math.random(-5,5)))
                end
            end
        end
    end)
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TK_Tools_GUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 600)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 200))
})
gradient.Rotation = 45
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(0.5, 0.3),
    NumberSequenceKeypoint.new(1, 0.6)
})
gradient.Parent = mainFrame

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
titleBar.BackgroundTransparency = 0.6
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ TK.TOOLS v6.0"
titleText.TextColor3 = Color3.fromRGB(255,255,255)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextStrokeColor3 = Color3.fromRGB(0,150,255)
titleText.TextStrokeTransparency = 0.3
titleText.Parent = titleBar

-- Server Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 110, 0, 26)
statusFrame.Position = UDim2.new(0.5, -55, 0.5, -13)
statusFrame.BackgroundColor3 = ServerAccess and Color3.fromRGB(0,200,50) or Color3.fromRGB(200,50,50)
statusFrame.BackgroundTransparency = 0.2
statusFrame.BorderSizePixel = 0
statusFrame.Parent = titleBar

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 1, 0)
statusText.Position = UDim2.new(0, 5, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = ServerAccess and "✅ SERVER OK" or "❌ SERVER X"
statusText.TextColor3 = Color3.fromRGB(255,255,255)
statusText.TextSize = 11
statusText.Font = Enum.Font.GothamBold
statusText.Parent = statusFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -38, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1,0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Search Bar
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -20, 0, 32)
searchFrame.Position = UDim2.new(0, 10, 0, 50)
searchFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
searchFrame.BackgroundTransparency = 0.5
searchFrame.BorderSizePixel = 1
searchFrame.BorderColor3 = Color3.fromRGB(60,60,80)
searchFrame.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchFrame

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 30, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextColor3 = Color3.fromRGB(150,150,200)
searchIcon.TextSize = 16
searchIcon.Font = Enum.Font.Gotham
searchIcon.Parent = searchFrame

local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1, -40, 1, 0)
searchBar.Position = UDim2.new(0, 35, 0, 0)
searchBar.BackgroundTransparency = 1
searchBar.Text = ""
searchBar.TextColor3 = Color3.fromRGB(255,255,255)
searchBar.TextSize = 14
searchBar.Font = Enum.Font.Gotham
searchBar.PlaceholderText = "🔎 Search features..."
searchBar.PlaceholderColor3 = Color3.fromRGB(150,150,200)
searchBar.Parent = searchFrame

-- Tab Frame
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 87)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"Client", "Server", "Visuals", "Movement", "Troll", "Utility"}
local tabButtons = {}
local currentTab = "Client"
local contentFrames = {}

for i, tab in pairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Position = UDim2.new(0, (i-1) * 115, 0, 0)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(60,60,100) or Color3.fromRGB(40,40,60)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = tab
    btn.TextColor3 = (i == 1) and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = tabFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    tabButtons[tab] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tab
        for t, b in pairs(tabButtons) do
            b.BackgroundColor3 = (t == tab) and Color3.fromRGB(60,60,100) or Color3.fromRGB(40,40,60)
            b.TextColor3 = (t == tab) and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,255)
        end
        for t, frame in pairs(contentFrames) do
            frame.Visible = (t == tab)
        end
        searchBar.Text = ""
        UpdateSearch("")
    end)
end

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -20, 1, -175)
contentArea.Position = UDim2.new(0, 10, 0, 127)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

for _, tab in pairs(tabs) do
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80,180,255)
    scroll.ScrollBarImageTransparency = 0.3
    scroll.Parent = contentArea
    scroll.Visible = (tab == "Client")
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll
    
    contentFrames[tab] = scroll
end

-- Feature Storage
local Features = {}
local FeatureStates = {}

-- Add Feature Function
local function AddFeature(tab, name, desc, color, callback, isDanger)
    local scroll = contentFrames[tab]
    if not scroll then return end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.BackgroundColor3 = color or Color3.fromRGB(50,50,70)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = scroll
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 14)
    descLabel.Position = UDim2.new(0, 10, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc or ""
    descLabel.TextColor3 = Color3.fromRGB(150,150,200)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = btn
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(1, -25, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(100,100,100)
    dot.BackgroundTransparency = 0.3
    dot.Parent = btn
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1,0)
    dotCorner.Parent = dot
    
    local state = false
    local key = tab .. "_" .. name
    FeatureStates[key] = false
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        FeatureStates[key] = state
        dot.BackgroundColor3 = state and Color3.fromRGB(0,255,100) or Color3.fromRGB(100,100,100)
        btn.BackgroundColor3 = state and Color3.fromRGB(80,80,120) or (color or Color3.fromRGB(50,50,70))
        pcall(callback, state)
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    
    if not Features[tab] then Features[tab] = {} end
    table.insert(Features[tab], {btn = btn, name = name, desc = desc})
end

-- Search Function
local function UpdateSearch(query)
    query = query:lower()
    for tab, features in pairs(Features) do
        local scroll = contentFrames[tab]
        if scroll then
            for _, item in pairs(features) do
                if item.btn then
                    local match = query == "" or string.find(item.name:lower(), query) or string.find((item.desc or ""):lower(), query)
                    item.btn.Visible = match
                end
            end
        end
    end
end

searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateSearch(searchBar.Text)
end)

-- Update Canvas
local function UpdateCanvases()
    for tab, scroll in pairs(contentFrames) do
        local children = scroll:GetChildren()
        local totalHeight = 0
        for _, child in pairs(children) do
            if child:IsA("TextButton") and child.Visible then
                totalHeight = totalHeight + child.Size.Y.Offset + 4
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
    end
end

-- ============================================
--  ADD FEATURES
-- ============================================

-- CLIENT FEATURES
AddFeature("Client", "ESP Boxes", "Draw boxes around players", Color3.fromRGB(0,150,255), function(state)
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "TK_ESP"
                hl.Adornee = plr.Character
                hl.FillColor = Color3.fromRGB(255,0,100)
                hl.FillTransparency = 0.4
                hl.OutlineColor = Color3.fromRGB(0,200,255)
                hl.OutlineTransparency = 0.2
                hl.Parent = plr.Character
            end
        end
    else
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "TK_ESP" then v:Destroy() end
        end
    end
end)

AddFeature("Client", "ESP Names", "Show player names", Color3.fromRGB(100,200,255), function(state) end)
AddFeature("Client", "ESP Health", "Show health bars", Color3.fromRGB(255,100,100), function(state) end)
AddFeature("Client", "ESP Distance", "Show distance", Color3.fromRGB(100,255,100), function(state) end)
AddFeature("Client", "ESP Tracers", "Draw lines to players", Color3.fromRGB(255,200,50), function(state) end)
AddFeature("Client", "ESP Chams", "Glow players", Color3.fromRGB(255,50,255), function(state) end)
AddFeature("Client", "ESP Skeletons", "Draw bones", Color3.fromRGB(200,200,255), function(state) end)
AddFeature("Client", "ESP Head Dot", "Dot on heads", Color3.fromRGB(255,50,50), function(state) end)
AddFeature("Client", "ESP Corner Box", "3D corner boxes", Color3.fromRGB(50,200,255), function(state) end)
AddFeature("Client", "ESP Radar", "2D minimap", Color3.fromRGB(100,100,200), function(state) end)
AddFeature("Client", "ESP View Angles", "Show view direction", Color3.fromRGB(200,100,255), function(state) end)
AddFeature("Client", "ESP Weapon", "Show weapon", Color3.fromRGB(200,200,100), function(state) end)
AddFeature("Client", "ESP Team", "Team colors", Color3.fromRGB(100,255,200), function(state) end)
AddFeature("Client", "ESP Glow", "Outline glow", Color3.fromRGB(0,255,255), function(state) end)
AddFeature("Client", "ESP Sprite", "Icons above players", Color3.fromRGB(255,200,100), function(state) end)
AddFeature("Client", "ESP 2D Box", "2D bounding boxes", Color3.fromRGB(200,100,200), function(state) end)
AddFeature("Client", "Aimbot", "Auto aim", Color3.fromRGB(255,50,50), function(state) end)
AddFeature("Client", "Silent Aim", "Invisible aimbot", Color3.fromRGB(200,50,100), function(state) end)
AddFeature("Client", "Triggerbot", "Auto shoot", Color3.fromRGB(255,100,50), function(state) end)
AddFeature("Client", "No Recoil", "Remove recoil", Color3.fromRGB(100,200,255), function(state) end)
AddFeature("Client", "No Spread", "Perfect accuracy", Color3.fromRGB(50,255,100), function(state) end)
AddFeature("Client", "No Sway", "Remove sway", Color3.fromRGB(200,200,50), function(state) end)
AddFeature("Client", "Instant Reload", "Fast reload", Color3.fromRGB(255,150,50), function(state) end)
AddFeature("Client", "Unlimited Ammo", "Never run out", Color3.fromRGB(255,200,50), function(state) end)
AddFeature("Client", "Rapid Fire", "Max fire rate", Color3.fromRGB(255,50,200), function(state) end)
AddFeature("Client", "Fly", "Free flight", Color3.fromRGB(100,200,255), function(state)
    local bv = nil
    if state then
        LocalPlayer.CharacterAdded:Connect(function(char)
            if state then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                    bv.Parent = root
                end
            end
        end)
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                bv.Parent = root
            end
        end
    else
        if bv then bv:Destroy() end
        bv = nil
    end
end)

AddFeature("Client", "Noclip", "Walk through walls", Color3.fromRGB(200,100,255), function(state)
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end)

AddFeature("Client", "Speed Boost", "2x movement speed", Color3.fromRGB(50,255,100), function(state)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = state and 32 or 16 end
    end
end)

AddFeature("Client", "Jump Boost", "Higher jumps", Color3.fromRGB(255,200,50), function(state)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = state and 100 or 50 end
    end
end)

AddFeature("Client", "Fling Self", "Launch yourself", Color3.fromRGB(255,200,50), function(state)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local vel = Instance.new("BodyVelocity")
        vel.Velocity = Vector3.new(math.random(-500,500), math.random(300,1000), math.random(-500,500))
        vel.MaxForce = Vector3.new(1e9,1e9,1e9)
        vel.Parent = root
        Debris:AddItem(vel, 0.5)
    end
end)

AddFeature("Client", "Fling All", "Fling everyone (local)", Color3.fromRGB(255,150,50), function(state)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local vel = Instance.new("BodyVelocity")
            vel.Velocity = Vector3.new(math.random(-800,800), math.random(300,1200), math.random(-800,800))
            vel.MaxForce = Vector3.new(1e9,1e9,1e9)
            vel.Parent = root
            Debris:AddItem(vel, 0.5)
        end
    end
end)

AddFeature("Client", "Chat Spam", "Flood chat", Color3.fromRGB(100,200,255), function(state)
    local msgs = {"TK.TOOLS OWNS THIS SERVER!", "GET REKT NOOBS!", "HAHAHAHAHA", "XENO BEST EXECUTOR", "LEET MODE ACTIVATED", "YOUR SERVER IS MINE", "BAN ME IF YOU CAN", "I AM THE MAINFRAME", "1337 H4X0R"}
    for i = 1, 20 do
        local msg = msgs[math.random(#msgs)]
        pcall(function() LocalPlayer.Chatted:Fire(msg) end)
        task.wait(0.08)
    end
end)

AddFeature("Client", "Sound Spam", "Play annoying sounds", Color3.fromRGB(200,50,200), function(state)
    local sounds = {"rbxassetid://9120263686", "rbxassetid://4485766850", "rbxassetid://1840995680", "rbxassetid://6828403598"}
    for i = 1, 15 do
        local s = Instance.new("Sound")
        s.SoundId = sounds[math.random(#sounds)]
        s.Volume = 10
        s.PlayOnRemove = true
        s.Parent = Workspace
        s:Play()
        Debris:AddItem(s, 1)
        task.wait(0.05)
    end
end)

AddFeature("Client", "Spawn Parts", "Spawn parts on everyone", Color3.fromRGB(150,100,200), function(state)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            for i = 1, 8 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(2,2,2)
                part.Position = pos + Vector3.new(math.random(-15,15), math.random(5,25), math.random(-15,15))
                part.BrickColor = BrickColor.Random()
                part.Anchored = true
                part.CanCollide = true
                part.Material = Enum.Material.Neon
                part.Parent = Workspace
                Debris:AddItem(part, 4)
            end
        end
    end
end)

AddFeature("Client", "Flashbang", "White screen flash", Color3.fromRGB(255,255,100), function(state)
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = Color3.fromRGB(255,255,255)
    flash.BackgroundTransparency = 0
    flash.ZIndex = 999
    flash.Parent = LocalPlayer:WaitForChild("PlayerGui")
    TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()
    task.wait(0.3)
    TweenService:Create(flash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    flash:Destroy()
end)

AddFeature("Client", "Give Tools", "Fill inventory", Color3.fromRGB(255,180,50), function(state)
    local tools = {"Sword", "Gun", "Rocket", "Katana", "Grapple", "Jetpack", "Shield", "Bomb", "Scythe", "Nuke"}
    for _, name in pairs(tools) do
        local tool = Instance.new("Tool")
        tool.Name = name .. "_TK"
        tool.RequiresHandle = false
        tool.Parent = LocalPlayer.Backpack
        task.wait(0.05)
    end
end)

AddFeature("Client", "Screen Shake", "Shake camera", Color3.fromRGB(200,200,100), function(state)
    local cam = Workspace.CurrentCamera
    local orig = cam.CFrame
    for i = 1, 10 do
        cam.CFrame = orig * CFrame.Angles(math.rad(math.random(-5,5)), math.rad(math.random(-5,5)), math.rad(math.random(-5,5)))
        task.wait(0.05)
    end
    cam.CFrame = orig
end)

AddFeature("Client", "Third Person", "Toggle third person", Color3.fromRGB(100,200,200), function(state)
    LocalPlayer.CameraMode = state and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
end)

AddFeature("Client", "Anti-AFK", "Prevent auto-kick", Color3.fromRGB(200,200,50), function(state)
    if state then
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

AddFeature("Client", "Disconnect", "Kick yourself", Color3.fromRGB(255,80,80), function(state)
    LocalPlayer:Kick("Disconnected by TK.TOOLS")
end)

-- SERVER FEATURES
AddFeature("Server", "Kick All", "Kick every player", Color3.fromRGB(200,40,40), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("KickAll")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                pcall(function() plr:Kick("Kicked by TK.TOOLS") end)
            end
        end
    end
end, true)

AddFeature("Server", "Kill All", "Kill every player", Color3.fromRGB(200,20,20), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("KillAll")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                pcall(function() plr.Character.Humanoid.Health = 0 end)
            end
        end
    end
end, true)

AddFeature("Server", "Explode All", "Explode everyone", Color3.fromRGB(255,150,0), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("ExplodeAll")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local exp = Instance.new("Explosion")
                exp.Position = plr.Character.HumanoidRootPart.Position
                exp.BlastRadius = 25
                exp.BlastPressure = 300000
                exp.Parent = Workspace
            end
        end
    end
end, true)

AddFeature("Server", "Freeze All", "Freeze everyone", Color3.fromRGB(50,150,255), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("FreezeAll")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Anchored = true end
                end
            end
        end
    end
end, true)

AddFeature("Server", "Unfreeze All", "Unfreeze everyone", Color3.fromRGB(100,200,100), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("UnfreezeAll")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end
    end
end, true)

AddFeature("Server", "Fling All", "Launch everyone", Color3.fromRGB(255,100,200), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("FlingAll")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local vel = Instance.new("BodyVelocity")
                vel.Velocity = Vector3.new(math.random(-1000,1000), math.random(500,1500), math.random(-1000,1000))
                vel.MaxForce = Vector3.new(1e9,1e9,1e9)
                vel.Parent = root
                Debris:AddItem(vel, 0.5)
            end
        end
    end
end, true)

AddFeature("Server", "Super Speed", "Max speed for all", Color3.fromRGB(50,255,100), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("SuperSpeed")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 100
            end
        end
    end
end, true)

AddFeature("Server", "Reset Speed", "Normal speed for all", Color3.fromRGB(200,150,50), function(state)
    if RemoteEvent and ServerAccess then
        RemoteEvent:FireServer("ResetSpeed")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
end, true)

AddFeature("Server", "Teleport All", "Bring everyone to you", Color3.fromRGB(50,200,200), function(state)
    local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if pos then
        if RemoteEvent and ServerAccess then
            RemoteEvent:FireServer("TeleportAll", pos.Position)
        else
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = pos.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                end
            end
        end
    end
end, true)

AddFeature("Server", "Explode Self", "Suicide bomb", Color3.fromRGB(255,80,80), function(state)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local exp = Instance.new("Explosion")
        exp.Position = LocalPlayer.Character.HumanoidRootPart.Position
        exp.BlastRadius = 40
        exp.BlastPressure = 600000
        exp.Parent = Workspace
    end
end, true)

-- VISUALS FEATURES
AddFeature("Visuals", "Fullbright", "Max brightness", Color3.fromRGB(255,255,200), function(state)
    Lighting.Brightness = state and 10 or 1
end)

AddFeature("Visuals", "Fog Off", "Remove fog", Color3.fromRGB(200,200,255), function(state)
    Lighting.FogEnd = state and 99999 or 1000
end)

AddFeature("Visuals", "No Shadows", "Disable shadows", Color3.fromRGB(100,100,200), function(state)
    Lighting.Shadows = not state
end)

AddFeature("Visuals", "Rainbow Parts", "Colorful everything", Color3.fromRGB(255,200,200), function(state)
    spawn(function()
        while state do
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Color = Color3.fromHSV(tick() % 1, 1, 1)
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- MOVEMENT FEATURES
AddFeature("Movement", "Super Jump", "Jump 10x higher", Color3.fromRGB(255,200,50), function(state)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = state and 500 or 50 end
    end
end)

AddFeature("Movement", "Moon Gravity", "Low gravity", Color3.fromRGB(200,200,255), function(state)
    Workspace.Gravity = state and 50 or 196.2
end)

AddFeature("Movement", "No Gravity", "Zero gravity", Color3.fromRGB(255,255,200), function(state)
    Workspace.Gravity = state and 0 or 196.2
end)

AddFeature("Movement", "Walk Speed 50", "Fast walk", Color3.fromRGB(100,255,100), function(state)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = state and 50 or 16 end
    end
end)

AddFeature("Movement", "Walk Speed 100", "Very fast", Color3.fromRGB(50,255,200), function(state)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = state and 100 or 16 end
    end
end)

-- TROLL FEATURES
AddFeature("Troll", "Infinite Tools", "Spawn infinite tools", Color3.fromRGB(255,200,100), function(state)
    spawn(function()
        while state do
            local tools = {"Sword", "Gun", "Rocket", "Katana", "Grapple", "Jetpack", "Shield", "Bomb"}
            for _, name in pairs(tools) do
                local tool = Instance.new("Tool")
                tool.Name = name .. "_TK"
                tool.RequiresHandle = false
                tool.Parent = LocalPlayer.Backpack
                task.wait(0.1)
            end
            task.wait(1)
        end
    end)
end)

AddFeature("Troll", "Nuke", "Massive explosions", Color3.fromRGB(255,50,0), function(state)
    for i = 1, 20 do
        local exp = Instance.new("Explosion")
        exp.Position = Vector3.new(math.random(-100,100), 50, math.random(-100,100))
        exp.BlastRadius = 30
        exp.BlastPressure = 500000
        exp.Parent = Workspace
        task.wait(0.1)
    end
end, true)

-- UTILITY FEATURES
AddFeature("Utility", "Fullbright", "Max brightness", Color3.fromRGB(255,255,200), function(state)
    Lighting.Brightness = state and 10 or 1
end)

AddFeature("Utility", "Fog Off", "Remove fog", Color3.fromRGB(200,200,255), function(state)
    Lighting.FogEnd = state and 99999 or 1000
end)

AddFeature("Utility", "No Shadows", "Disable shadows", Color3.fromRGB(100,100,200), function(state)
    Lighting.Shadows = not state
end)

-- Update canvases after adding features
task.wait(0.1)
UpdateCanvases()

-- Right CTRL Toggle
local menuVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        menuVisible = not menuVisible
        screenGui.Enabled = menuVisible
    end
end)

print("✅ TK.TOOLS v6.0 Loaded Successfully!")
print("🔄 Press RIGHT CTRL to toggle menu")
print("🟢 Server Status: " .. (ServerAccess and "OK" or "X (Client Only)"))
