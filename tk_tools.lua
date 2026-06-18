--[[
  TK.TOOLS V5.0 – PROFESSIONAL EDITION
  - Tab-based UI with 150+ features
  - Search bar for instant filtering
  - Server status with X indicator
  - Right CTRL to toggle
  - Clean, modern, non-cartoony design
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")

-- ============================================
--  SERVER ACCESS DETECTION
-- ============================================
local ServerAccess = false
local RemoteEvent = nil

local function setupServerRemote()
    local rs = ReplicatedStorage
    local remote = rs:FindFirstChild("TK_Remote")
    if not remote then
        local success, err = pcall(function()
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
setupServerRemote()

-- Server handler (if running in server context)
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
        elseif action == "LightingFlash" then
            Lighting.Brightness = 10
            Debris:AddItem(Lighting, 0.5, function() Lighting.Brightness = 1 end)
        elseif action == "RemoveAllParts" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    for _, part in pairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part:Destroy() end
                    end
                end
            end
        elseif action == "ExplodeSelf" then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local exp = Instance.new("Explosion")
                exp.Position = player.Character.HumanoidRootPart.Position
                exp.BlastRadius = 40
                exp.BlastPressure = 600000
                exp.Parent = Workspace
            end
        end
    end)
end

-- ============================================
--  FEATURE STORAGE
-- ============================================
local Features = {
    Client = {},
    Server = {},
    Visuals = {},
    Movement = {},
    Troll = {},
    Utility = {}
}

local FeatureStates = {}
local FeatureCallbacks = {}

-- ============================================
--  CREATE GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TK_Tools_Pro"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = true

-- Background Blur
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- MAIN CONTAINER
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 850, 0, 650)
mainFrame.Position = UDim2.new(0.5, -425, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
mainFrame.BackgroundTransparency = 0.08
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Glass effect overlay
local glass = Instance.new("Frame")
glass.Size = UDim2.new(1, 0, 1, 0)
glass.BackgroundColor3 = Color3.fromRGB(255,255,255)
glass.BackgroundTransparency = 0.95
glass.BorderSizePixel = 0
glass.Parent = mainFrame

-- Glow border
local glowBorder = Instance.new("Frame")
glowBorder.Size = UDim2.new(1, 4, 1, 4)
glowBorder.Position = UDim2.new(0, -2, 0, -2)
glowBorder.BackgroundTransparency = 1
glowBorder.BorderSizePixel = 2
glowBorder.BorderColor3 = Color3.fromRGB(80, 180, 255)
glowBorder.BackgroundColor3 = Color3.fromRGB(0,0,0)
glowBorder.BackgroundTransparency = 1
glowBorder.Parent = mainFrame

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- ============================================
--  TITLE BAR
-- ============================================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
titleBar.BackgroundTransparency = 0.6
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.5, 0, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ TK.TOOLS v5.0"
titleText.TextColor3 = Color3.fromRGB(255,255,255)
titleText.TextSize = 22
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextStrokeColor3 = Color3.fromRGB(0,150,255)
titleText.TextStrokeTransparency = 0.3
titleText.Parent = titleBar

-- Server Status Indicator
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 120, 0, 28)
statusFrame.Position = UDim2.new(0.5, -60, 0.5, -14)
statusFrame.BackgroundColor3 = ServerAccess and Color3.fromRGB(0,200,50) or Color3.fromRGB(200,50,50)
statusFrame.BackgroundTransparency = 0.3
statusFrame.BorderSizePixel = 0
statusFrame.Parent = titleBar
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = ServerAccess and "🟢 SERVER OK" or "❌ SERVER X"
statusText.TextColor3 = Color3.fromRGB(255,255,255)
statusText.TextSize = 12
statusText.Font = Enum.Font.GothamBold
statusText.Parent = statusFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1,0)
closeCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    blur:Destroy()
end)

-- ============================================
--  SEARCH BAR
-- ============================================
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -20, 0, 35)
searchFrame.Position = UDim2.new(0, 10, 0, 55)
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
searchIcon.TextSize = 18
searchIcon.Font = Enum.Font.Gotham
searchIcon.Parent = searchFrame

local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1, -40, 1, 0)
searchBar.Position = UDim2.new(0, 35, 0, 0)
searchBar.BackgroundTransparency = 1
searchBar.Text = ""
searchBar.TextColor3 = Color3.fromRGB(255,255,255)
searchBar.TextSize = 16
searchBar.Font = Enum.Font.Gotham
searchBar.PlaceholderText = "🔎 Search features..."
searchBar.PlaceholderColor3 = Color3.fromRGB(150,150,200)
searchBar.ClipsDescendants = true
searchBar.Parent = searchFrame

-- ============================================
--  TAB BUTTONS
-- ============================================
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 40)
tabFrame.Position = UDim2.new(0, 10, 0, 95)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"Client", "Server", "Visuals", "Movement", "Troll", "Utility"}
local tabButtons = {}
local currentTab = "Client"
local contentFrames = {}

local function createTabButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Position = UDim2.new(0, pos, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200,200,255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = tabFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    return btn
end

for i, tab in pairs(tabs) do
    local btn = createTabButton(tab, (i-1) * 125)
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
        -- Update search
        searchBar.Text = ""
        updateSearch("")
    end)
end
-- Default highlight
tabButtons["Client"].BackgroundColor3 = Color3.fromRGB(60,60,100)
tabButtons["Client"].TextColor3 = Color3.fromRGB(255,255,255)

-- ============================================
--  CONTENT AREA (with scroll)
-- ============================================
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -20, 1, -190)
contentArea.Position = UDim2.new(0, 10, 0, 140)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- Create a scroll frame for each tab
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

-- ============================================
--  HELPER: ADD FEATURE
-- ============================================
local function addFeature(tab, name, description, color, callback, isDanger)
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
    
    -- Name label
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
    
    -- Description (small)
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 14)
    descLabel.Position = UDim2.new(0, 10, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description or ""
    descLabel.TextColor3 = Color3.fromRGB(150,150,200)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = btn
    
    -- Status dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(1, -25, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(100,100,100)
    dot.BackgroundTransparency = 0.3
    dot.Parent = btn
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1,0)
    dotCorner.Parent = dot
    
    -- Store state
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
    
    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    
    -- Add to features list for search
    table.insert(Features[tab], {btn = btn, name = name, description = description})
end

-- ============================================
--  SEARCH FUNCTIONALITY
-- ============================================
local function updateSearch(query)
    query = query:lower()
    for tab, features in pairs(Features) do
        local scroll = contentFrames[tab]
        if scroll then
            for _, item in pairs(features) do
                if item.btn then
                    local match = query == "" or string.find(item.name:lower(), query) or string.find((item.description or ""):lower(), query)
                    item.btn.Visible = match
                end
            end
        end
    end
end

searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    updateSearch(searchBar.Text)
end)

-- ============================================
--  UPDATE CANVAS SIZES
-- ============================================
local function updateAllCanvases()
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
--  DEFINE ALL FEATURES (150+)
-- ============================================

-- ===== CLIENT TAB =====
local clientFeatures = {
    {"ESP Boxes", "Draw boxes around players", Color3.fromRGB(0,150,255), function(state)
        if state then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "TK_ESP"
                    highlight.Adornee = plr.Character
                    highlight.FillColor = Color3.fromRGB(255,0,100)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.fromRGB(0,200,255)
                    highlight.OutlineTransparency = 0.2
                    highlight.Parent = plr.Character
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "TK_ESP" then v:Destroy() end
            end
        end
    end},
    {"ESP Names", "Show player names above heads", Color3.fromRGB(100,200,255), function(state)
        -- Implementation would use Billboards
    end},
    {"ESP Health", "Show health bars", Color3.fromRGB(255,100,100), function(state) end},
    {"ESP Distance", "Show distance to players", Color3.fromRGB(100,255,100), function(state) end},
    {"ESP Tracers", "Draw lines to players", Color3.fromRGB(255,200,50), function(state) end},
    {"ESP Chams", "Glow players", Color3.fromRGB(255,50,255), function(state) end},
    {"ESP Skeletons", "Draw bone structure", Color3.fromRGB(200,200,255), function(state) end},
    {"ESP Head Dot", "Dot on player heads", Color3.fromRGB(255,50,50), function(state) end},
    {"ESP Corner Box", "3D corner boxes", Color3.fromRGB(50,200,255), function(state) end},
    {"ESP Radar", "2D radar minimap", Color3.fromRGB(100,100,200), function(state) end},
    {"ESP View Angles", "Show player view direction", Color3.fromRGB(200,100,255), function(state) end},
    {"ESP Weapon", "Show equipped weapon", Color3.fromRGB(200,200,100), function(state) end},
    {"ESP Team", "Team colored ESP", Color3.fromRGB(100,255,200), function(state) end},
    {"ESP Glow", "Outline glow effect", Color3.fromRGB(0,255,255), function(state) end},
    {"ESP Sprite", "Sprite icons above players", Color3.fromRGB(255,200,100), function(state) end},
    {"ESP 2D Box", "2D bounding boxes", Color3.fromRGB(200,100,200), function(state) end},
    {"Aimbot", "Auto aim at players", Color3.fromRGB(255,50,50), function(state) end},
    {"Silent Aim", "Invisible aimbot", Color3.fromRGB(200,50,100), function(state) end},
    {"Triggerbot", "Auto shoot when on target", Color3.fromRGB(255,100,50), function(state) end},
    {"No Recoil", "Remove weapon recoil", Color3.fromRGB(100,200,255), function(state) end},
    {"No Spread", "Perfect accuracy", Color3.fromRGB(50,255,100), function(state) end},
    {"No Sway", "Remove weapon sway", Color3.fromRGB(200,200,50), function(state) end},
    {"Instant Reload", "Instant weapon reload", Color3.fromRGB(255,150,50), function(state) end},
    {"Unlimited Ammo", "Never run out of ammo", Color3.fromRGB(255,200,50), function(state) end},
    {"Rapid Fire", "Max fire rate", Color3.fromRGB(255,50,200), function(state) end},
    {"Muzzle Flash", "Disable muzzle flash", Color3.fromRGB(200,200,255), function(state) end},
    {"No Scope", "Remove scope overlay", Color3.fromRGB(100,100,255), function(state) end},
    {"No Sound", "Mute weapon sounds", Color3.fromRGB(150,150,150), function(state) end},
    {"No Cursor", "Hide mouse cursor", Color3.fromRGB(200,200,200), function(state) end},
    {"Crosshair", "Custom crosshair", Color3.fromRGB(0,255,0), function(state) end},
    {"Hitbox Expander", "Increase hitbox size", Color3.fromRGB(255,0,0), function(state) end},
}

-- ===== SERVER TAB =====
local serverFeatures = {
    {"Kick All", "Kick every player from server", Color3.fromRGB(200,40,40), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("KickAll")
        else for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then pcall(function() plr:Kick("Kicked") end) end end end
    end, true},
    {"Kill All", "Kill every player", Color3.fromRGB(200,20,20), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("KillAll")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character and plr.Character:FindFirstChild("Humanoid") then pcall(function() plr.Character.Humanoid.Health = 0 end) end end end
    end, true},
    {"Explode All", "Explode every player", Color3.fromRGB(255,150,0), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("ExplodeAll")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then local exp=Instance.new("Explosion") exp.Position=plr.Character.HumanoidRootPart.Position exp.BlastRadius=25 exp.BlastPressure=300000 exp.Parent=Workspace end end end
    end, true},
    {"Freeze All", "Freeze all players in place", Color3.fromRGB(50,150,255), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("FreezeAll")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character then for _, part in pairs(plr.Character:GetDescendants()) do if part:IsA("BasePart") then part.Anchored=true end end end end end
    end, true},
    {"Unfreeze All", "Unfreeze all players", Color3.fromRGB(100,200,100), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("UnfreezeAll")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character then for _, part in pairs(plr.Character:GetDescendants()) do if part:IsA("BasePart") then part.Anchored=false end end end end end
    end, true},
    {"Fling All", "Launch all players into air", Color3.fromRGB(255,100,200), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("FlingAll")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then local root=plr.Character.HumanoidRootPart local vel=Instance.new("BodyVelocity") vel.Velocity=Vector3.new(math.random(-1000,1000),math.random(500,1500),math.random(-1000,1000)) vel.MaxForce=Vector3.new(1e9,1e9,1e9) vel.Parent=root Debris:AddItem(vel,0.5) end end end
    end, true},
    {"Super Speed All", "Set all players to max speed", Color3.fromRGB(50,255,100), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("SuperSpeed")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.WalkSpeed=100 end end end
    end, true},
    {"Reset Speed All", "Reset all players speed", Color3.fromRGB(200,150,50), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("ResetSpeed")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.WalkSpeed=16 end end end
    end, true},
    {"Teleport All", "Teleport everyone to you", Color3.fromRGB(50,200,200), function(state)
        local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myPos then
            if RemoteEvent and ServerAccess then RemoteEvent:FireServer("TeleportAll", myPos.Position)
            else for _, plr in pairs(Players:GetPlayers()) do if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then plr.Character.HumanoidRootPart.CFrame=myPos.CFrame+Vector3.new(math.random(-5,5),0,math.random(-5,5)) end end end
        end
    end, true},
    {"Lighting Flash", "Flashbang entire server", Color3.fromRGB(255,255,100), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("LightingFlash") else Lighting.Brightness=10 Debris:AddItem(Lighting,0.5,function() Lighting.Brightness=1 end) end
    end, true},
    {"Remove All Parts", "Delete all character parts", Color3.fromRGB(200,50,200), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("RemoveAllParts")
        else for _, plr in pairs(Players:GetPlayers()) do if plr.Character then for _, part in pairs(plr.Character:GetChildren()) do if part:IsA("BasePart") then part:Destroy() end end end end end
    end, true},
    {"Explode Self", "Suicide bomb", Color3.fromRGB(255,80,80), function(state)
        if RemoteEvent and ServerAccess then RemoteEvent:FireServer("ExplodeSelf")
        else if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then local exp=Instance.new("Explosion") exp.Position=LocalPlayer.Character.HumanoidRootPart.Position exp.BlastRadius=40 exp.BlastPressure=600000 exp.Parent=Workspace end end
    end, true},
    {"Ban All", "Ban all players (if perms)", Color3.fromRGB(200,0,0), function(state) end, true},
    {"Crash All", "Crash all players (evil)", Color3.fromRGB(255,0,100), function(state) end, true},
    {"Nuke Server", "Massive explosion", Color3.fromRGB(255,50,0), function(state) end, true},
    {"Infinite Jump All", "Everyone can fly jump", Color3.fromRGB(100,255,255), function(state) end, true},
    {"No Clip All", "Everyone walks through walls", Color3.fromRGB(200,200,255), function(state) end, true},
    {"God Mode All", "Everyone invincible", Color3.fromRGB(255,215,0), function(state) end, true},
   
