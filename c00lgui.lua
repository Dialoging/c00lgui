local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local CurrentPage = 1
local MAX_PAGES = 5

local Colors = {
    BG = Color3.fromRGB(0,0,0),
    Border = Color3.fromRGB(255,0,0),
    Text = Color3.fromRGB(255,255,255),
    Active = Color3.fromRGB(255,0,0),
    Inactive = Color3.fromRGB(0,0,0)
}

local Modules = {
    Page1 = {"Movement", "Player Control", "Fly", "Noclip", "Walkspeed", "Jump Power", "Infinite Jump", "Speed Hack", "No Fall Damage", "Click TP", "Teleport To", "Bring Player", "Anti-AFK", "Spam Jump"},
    Page2 = {"Combat", "Offensive", "Kill All", "Kill Aura", "Server Kill", "Fling Player", "Fling All", "Freeze Player", "Spin Player", "Orbit Player", "God Mode", "Forcefield", "Target Player", ""},
    Page3 = {"Render", "Visual Effects", "ESP Box", "ESP Name", "ESP 2D", "Tracers", "Fullbright", "X-Ray", "Remove Fog", "Particle Emit", "Texture Replace", "Invisible", "", ""},
    Page4 = {"Tools", "Equipment", "BTools", "Knife", "Sword", "Katana", "Scythe", "Ban Hammer", "Bomb", "Rocket", "Gravity Gun", "Telekinesis", "", ""},
    Page5 = {"Fun", "Misc", "Seizure", "Freecam", "Server List", "Chicken Arms", "Jerk", "Sit", "", "", "", "", "", ""}
}

local Tooltips = {
    ["Fly"] = "Fly around using WASD, Space to go up, Shift to go down",
    ["Noclip"] = "Phase through all solid objects and walls",
    ["Walkspeed"] = "Adjust how fast your character walks",
    ["Jump Power"] = "Control your jump height with custom values",
    ["Infinite Jump"] = "Jump infinitely without touching the ground",
    ["Speed Hack"] = "Multiply your speed by any amount",
    ["No Fall Damage"] = "Never take damage from falling",
    ["Click TP"] = "Click anywhere to teleport instantly",
    ["Teleport To"] = "Teleport to the targeted player",
    ["Bring Player"] = "Bring targeted player to your location",
    ["Anti-AFK"] = "Prevents being kicked for inactivity",
    ["Spam Jump"] = "Automatically spam jump repeatedly",
    ["Kill All"] = "Fling all players in the server",
    ["Kill Aura"] = "Automatically fling nearby players",
    ["Server Kill"] = "Fling the targeted player",
    ["Fling Player"] = "Launch target player with velocity",
    ["Fling All"] = "Fling every player at once",
    ["Freeze Player"] = "Lock target player in place",
    ["Spin Player"] = "Make target spin rapidly",
    ["Orbit Player"] = "Orbit around the targeted player",
    ["God Mode"] = "Become invincible with infinite health",
    ["Forcefield"] = "Spawn protective forcefield around you",
    ["Target Player"] = "Select player for targeting abilities",
    ["ESP Box"] = "3D boxes around all players through walls",
    ["ESP Name"] = "Player names floating above their heads",
    ["ESP 2D"] = "2D boxes on screen showing player positions",
    ["Tracers"] = "Lines pointing from screen center to all players",
    ["Fullbright"] = "Maximum brightness with no shadows",
    ["X-Ray"] = "See through all walls and objects",
    ["Remove Fog"] = "Clear all fog for unlimited visibility",
    ["Particle Emit"] = "Spawn red particle effects on target",
    ["Texture Replace"] = "Replace every texture in game with custom",
    ["Invisible"] = "Hide your character model underground",
    ["BTools"] = "Building tools for moving and deleting parts",
    ["Knife"] = "Sharp knife for close combat",
    ["Sword"] = "Classic medieval sword",
    ["Katana"] = "Japanese samurai blade",
    ["Scythe"] = "Death's reaper scythe weapon",
    ["Ban Hammer"] = "Legendary banhammer of justice",
    ["Bomb"] = "Explosive device that detonates",
    ["Rocket"] = "Rocket launcher with explosives",
    ["Gravity Gun"] = "Manipulate objects with gravity",
    ["Telekinesis"] = "Move objects with your mind",
    ["Seizure"] = "Make your character have a seizure server-side",
    ["Freecam"] = "Move camera freely without moving character",
    ["Server List"] = "View all players in the server",
    ["Chicken Arms"] = "Flap your arms like a chicken",
    ["Jerk"] = "Smack your legs repeatedly",
    ["Sit"] = "Sit down animation"
}

local ToolIDs = {
    ["Knife"] = 142785488, ["Sword"] = 125013769, ["Katana"] = 88885539, ["Scythe"] = 95951330,
    ["Ban Hammer"] = 10468797, ["Bomb"] = 12884143, ["Rocket"] = 12844699,
    ["Gravity Gun"] = 92142841, ["Telekinesis"] = 91360081
}

local State = {
    Invisible = false, Fly = false, FlySpeed = 50, Walk = 16, Jump = 50, AntiAFK = false,
    ClickTPOn = false, Noclip = false, God = false, ESPBox = false, ESPName = false, ESP2D = false,
    InfiniteJump = false, Fullbright = false, SpeedHack = false, SpeedMultiplier = 2,
    NoFallDamage = false, KillAura = false, SpamJump = false, XRay = false, Tracers = false,
    TextureReplace = false, TargetPlayer = nil, Orbiting = false, Freecam = false, Seizure = false,
    ChickenArms = false, Jerk = false, Sitting = false
}

local ActiveButtons = {}
local ESPBoxes, ESPNames, ESP2DBoxes, TracerLines, ParticleEmitters, OriginalTextures = {}, {}, {}, {}, {}, {}

local function getChar() return Player.Character or Player.CharacterAdded:Wait() end
local function getRoot() return getChar():WaitForChild("HumanoidRootPart") end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end

local function setInvisible(on)
    State.Invisible = on
    for _,v in pairs(getChar():GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.CFrame = v.CFrame + Vector3.new(0, on and -500 or 500, 0)
        end
    end
end

local function setWalk(n)
    State.Walk = n
    if getHum() then getHum().WalkSpeed = n end
end

local function setJump(n)
    State.Jump = n
    if getHum() then getHum().JumpPower = n end
end

local function startFly()
    State.Fly = true
    local r = getRoot()
    local bp = Instance.new("BodyPosition", r)
    local bg = Instance.new("BodyGyro", r)
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bp.D, bp.P = 1000, 10000
    while State.Fly do
        local cf = workspace.CurrentCamera.CFrame
        bg.CFrame = cf
        local spd = State.FlySpeed
        bp.Position = r.Position + Vector3.new(0, 0.1, 0) + cf.LookVector * (UserInput:IsKeyDown(Enum.KeyCode.W) and spd or 0)
        if UserInput:IsKeyDown(Enum.KeyCode.S) then bp.Position = bp.Position - cf.LookVector * spd end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then bp.Position = bp.Position - cf.RightVector * spd end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then bp.Position = bp.Position + cf.RightVector * spd end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then bp.Position = bp.Position + Vector3.new(0, spd, 0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then bp.Position = bp.Position - Vector3.new(0, spd, 0) end
        task.wait()
    end
    bp:Destroy()
    bg:Destroy()
end

local function startAntiAFK()
    State.AntiAFK = true
    while State.AntiAFK do
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
        wait(60)
    end
end

local function giveBTools()
    for _,t in pairs({"Move", "Clone", "Delete"}) do
        local bin = Instance.new("HopperBin")
        bin.Name = t
        bin.BinType = t == "Move" and Enum.BinType.GameTool or (t == "Clone" and Enum.BinType.Clone or Enum.BinType.Hammer)
        bin.Parent = Player.Backpack
    end
end

local function giveTool(name)
    local id = ToolIDs[name]
    if not id then return end
    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = true
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 4, 1)
    handle.Parent = tool
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://" .. id
    mesh.TextureId = "rbxassetid://" .. id
    mesh.Parent = handle
    tool.Parent = Player.Backpack
end

Mouse.Button1Down:Connect(function()
    if State.ClickTPOn and Mouse.Target then
        getRoot().CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
    end
end)

local function createESP(player, espType)
    if player == Player then return end
    if espType == "Box" then
        if ESPBoxes[player] then return end
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 5, 4)
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.7
        box.AlwaysOnTop = true
        box.ZIndex = 10
        ESPBoxes[player] = box
        RunService.RenderStepped:Connect(function()
            if State.ESPBox and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                box.Adornee = player.Character.HumanoidRootPart
                box.Parent = player.Character.HumanoidRootPart
            else
                box.Parent = nil
            end
        end)
    elseif espType == "Name" then
        if ESPNames[player] then return end
        local bill = Instance.new("BillboardGui")
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 100, 0, 50)
        bill.StudsOffset = Vector3.new(0, 2, 0)
        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = player.Name
        txt.TextColor3 = Color3.fromRGB(255, 0, 0)
        txt.TextStrokeTransparency = 0
        txt.TextSize = 14
        ESPNames[player] = bill
        RunService.RenderStepped:Connect(function()
            if State.ESPName and player.Character and player.Character:FindFirstChild("Head") then
                bill.Adornee = player.Character.Head
                bill.Parent = player.Character.Head
            else
                bill.Parent = nil
            end
        end)
    elseif espType == "2D" then
        if ESP2DBoxes[player] then return end
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = Color3.fromRGB(255, 0, 0)
        box.Thickness = 2
        box.Transparency = 1
        box.Filled = false
        ESP2DBoxes[player] = box
        RunService.RenderStepped:Connect(function()
            if State.ESP2D and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                end
            else
                box.Visible = false
            end
        end)
    elseif espType == "Tracer" then
        if TracerLines[player] then return end
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 0, 0)
        line.Thickness = 2
        line.Transparency = 1
        TracerLines[player] = line
        RunService.RenderStepped:Connect(function()
            if State.Tracers and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local screenSize = workspace.CurrentCamera.ViewportSize
                    line.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end)
    end
end

local function setupESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            createESP(p, "Box")
            createESP(p, "Name")
            createESP(p, "2D")
            createESP(p, "Tracer")
        end
    end
    Players.PlayerAdded:Connect(function(p)
        createESP(p, "Box")
        createESP(p, "Name")
        createESP(p, "2D")
        createESP(p, "Tracer")
    end)
end

UserInput.JumpRequest:Connect(function()
    if State.InfiniteJump and getHum() then
        getHum():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function setFullbright(on)
    State.Fullbright = on
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = on and 2 or 1
    Lighting.ClockTime = on and 14 or 12
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = not on
    Lighting.OutdoorAmbient = on and Color3.fromRGB(128, 128, 128) or Color3.fromRGB(70, 70, 70)
end

RunService.Heartbeat:Connect(function()
    if State.SpeedHack and getHum() then
        getHum().WalkSpeed = State.Walk * State.SpeedMultiplier
    end
end)

local function flingKill(targetPlayer)
    if not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local myRoot = getRoot()
    local originalPos = myRoot.Position
    for i = 1, 10 do
        myRoot.CFrame = targetRoot.CFrame
        myRoot.AssemblyLinearVelocity = Vector3.new(2000, 2000, 2000)
        RunService.Heartbeat:Wait()
    end
    myRoot.CFrame = CFrame.new(originalPos)
    myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

local function startKillAura()
    State.KillAura = true
    while State.KillAura do
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and (targetRoot.Position - getRoot().Position).Magnitude < 20 then
                    flingKill(p)
                    task.wait(0.5)
                end
            end
        end
        task.wait(0.1)
    end
end

local function startSpamJump()
    State.SpamJump = true
    while State.SpamJump do
        if getHum() then getHum():ChangeState(Enum.HumanoidStateType.Jumping) end
        task.wait(0.2)
    end
end

local function setXRay(on)
    State.XRay = on
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not Players:GetPlayerFromCharacter(v.Parent) then
            v.LocalTransparencyModifier = on and 0.7 or 0
        end
    end
end

local function replaceTextures(on)
    State.TextureReplace = on
    local textureId = "rbxassetid://10560525674"
    if on then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                if not OriginalTextures[v] then OriginalTextures[v] = v.Texture end
                v.Texture = textureId
            elseif v:IsA("MeshPart") then
                if not OriginalTextures[v] then OriginalTextures[v] = v.TextureID end
                v.TextureID = textureId
            end
        end
    else
        for obj, orig in pairs(OriginalTextures) do
            if obj and obj.Parent then
                if obj:IsA("Texture") or obj:IsA("Decal") then obj.Texture = orig
                elseif obj:IsA("MeshPart") then obj.TextureID = orig end
            end
        end
        OriginalTextures = {}
    end
end

local function startSeizure()
    State.Seizure = true
    while State.Seizure do
        local h = getHum()
        if h then
            h.PlatformStand = true
            h.Sit = true
            local r = getRoot()
            r.AssemblyAngularVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
            r.AssemblyLinearVelocity = Vector3.new(math.random(-50,50), math.random(-50,50), math.random(-50,50))
        end
        task.wait(0.1)
    end
end

local OriginalJoints = {}

local function startChickenArms()
    State.ChickenArms = true
    local char = getChar()
    
    -- Store original joint positions
    local leftShoulder = char:FindFirstChild("Left Shoulder", true)
    local rightShoulder = char:FindFirstChild("Right Shoulder", true)
    if leftShoulder then OriginalJoints["LeftShoulder"] = leftShoulder.C0 end
    if rightShoulder then OriginalJoints["RightShoulder"] = rightShoulder.C0 end
    
    while State.ChickenArms do
        local leftShoulder = char:FindFirstChild("Left Shoulder", true)
        local rightShoulder = char:FindFirstChild("Right Shoulder", true)
        if leftShoulder and rightShoulder then
            leftShoulder.C0 = OriginalJoints["LeftShoulder"] * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-45, 45)), 0)
            rightShoulder.C0 = OriginalJoints["RightShoulder"] * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-45, 45)), 0)
        end
        task.wait(0.1)
    end
    
    -- Reset to original positions
    if leftShoulder and OriginalJoints["LeftShoulder"] then
        leftShoulder.C0 = OriginalJoints["LeftShoulder"]
    end
    if rightShoulder and OriginalJoints["RightShoulder"] then
        rightShoulder.C0 = OriginalJoints["RightShoulder"]
    end
end

local function startJerk()
    State.Jerk = true
    local char = getChar()
    
    -- Store original joint positions
    local leftHip = char:FindFirstChild("Left Hip", true)
    local rightHip = char:FindFirstChild("Right Hip", true)
    if leftHip then OriginalJoints["LeftHip"] = leftHip.C0 end
    if rightHip then OriginalJoints["RightHip"] = rightHip.C0 end
    
    while State.Jerk do
        local leftHip = char:FindFirstChild("Left Hip", true)
        local rightHip = char:FindFirstChild("Right Hip", true)
        if leftHip and rightHip then
            leftHip.C0 = OriginalJoints["LeftHip"] * CFrame.Angles(math.rad(math.random(-60, 60)), 0, 0)
            rightHip.C0 = OriginalJoints["RightHip"] * CFrame.Angles(math.rad(math.random(-60, 60)), 0, 0)
        end
        task.wait(0.05)
    end
    
    -- Reset to original positions
    if leftHip and OriginalJoints["LeftHip"] then
        leftHip.C0 = OriginalJoints["LeftHip"]
    end
    if rightHip and OriginalJoints["RightHip"] then
        rightHip.C0 = OriginalJoints["RightHip"]
    end
end

local InstantActions = {
    ["Teleport To"] = true, ["Bring Player"] = true, ["BTools"] = true, ["Server Kill"] = true,
    ["Fling Player"] = true, ["Fling All"] = true, ["Kill All"] = true, ["Spin Player"] = true,
    ["Remove Fog"] = true, ["Server List"] = true, ["Knife"] = true, ["Sword"] = true,
    ["Katana"] = true, ["Scythe"] = true, ["Ban Hammer"] = true, ["Bomb"] = true,
    ["Rocket"] = true, ["Gravity Gun"] = true, ["Telekinesis"] = true
}

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "c00lgui_dialoging"

local Tooltip = Instance.new("TextLabel", gui)
Tooltip.Size = UDim2.new(0, 250, 0, 50)
Tooltip.BackgroundColor3 = Colors.BG
Tooltip.BorderColor3 = Colors.Border
Tooltip.BorderSizePixel = 2
Tooltip.TextColor3 = Colors.Text
Tooltip.TextSize = 11
Tooltip.Font = Enum.Font.SourceSans
Tooltip.TextWrapped = true
Tooltip.Visible = false
Tooltip.ZIndex = 1000

local Arrow = Instance.new("TextButton", gui)
Arrow.Size = UDim2.new(0, 30, 0, 60)
Arrow.Position = UDim2.new(0, 10, 0.5, -30)
Arrow.BackgroundColor3 = Colors.BG
Arrow.BorderColor3 = Colors.Border
Arrow.BorderSizePixel = 2
Arrow.Text = ">>"
Arrow.TextColor3 = Colors.Text
Arrow.TextSize = 18
Arrow.Font = Enum.Font.SourceSansBold

local Main = Instance.new("Frame", gui)
Main.Size = UDim2.new(0, 250, 0, 320)
Main.Position = UDim2.new(0, 50, 0.5, -160)
Main.BackgroundColor3 = Colors.BG
Main.BorderColor3 = Colors.Border
Main.BorderSizePixel = 1
Main.Active = true
Main.Draggable = true
Main.Visible = false

local MainFrame = Instance.new("Frame", Main)
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1

local function createLabel(text, parent, size, pos, isBtn)
    local e = isBtn and Instance.new("TextButton") or Instance.new("TextLabel")
    e.Size = size or UDim2.new(1, 0, 1, 0)
    e.Position = pos or UDim2.new(0, 0, 0, 0)
    e.BackgroundColor3 = Colors.BG
    e.BorderColor3 = Colors.Border
    e.BorderSizePixel = 1
    e.Text = text
    e.TextColor3 = Colors.Text
    e.TextSize = 14
    e.Font = Enum.Font.SourceSans
    e.TextXAlignment = Enum.TextXAlignment.Center
    e.TextYAlignment = Enum.TextYAlignment.Center
    e.Parent = parent
    return e
end

createLabel("c00lgui - Dialoging", MainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), false).TextSize = 16

local Nav = createLabel("", MainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 30), false)
local NavLay = Instance.new("UIListLayout", Nav)
NavLay.FillDirection = Enum.FillDirection.Horizontal
NavLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLay.Padding = UDim.new(0, 10)

local LeftArr = createLabel("<", Nav, UDim2.new(0, 20, 1, 0), nil, true)
LeftArr.BorderSizePixel = 0
local RightArr = createLabel(">", Nav, UDim2.new(0, 20, 1, 0), nil, true)
RightArr.BorderSizePixel = 0

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -90)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1

local Grid = Instance.new("UIGridLayout", Content)
Grid.CellSize = UDim2.new(0.5, 0, 0, 25)
Grid.CellPadding = UDim2.new(0, 0, 0, 0)

local function handleAction(text, btn, toggled)
    if InstantActions[text] then
        if text == "Teleport To" and State.TargetPlayer and State.TargetPlayer.Character then
            local targetRoot = State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then getRoot().CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0) end
        elseif text == "Bring Player" and State.TargetPlayer and State.TargetPlayer.Character then
            local targetRoot = State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then targetRoot.CFrame = getRoot().CFrame + Vector3.new(3, 0, 0) end
        elseif text == "BTools" then giveBTools()
        elseif text == "Server Kill" or text == "Fling Player" then
            if State.TargetPlayer then flingKill(State.TargetPlayer) end
        elseif text == "Fling All" or text == "Kill All" then
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then flingKill(p) task.wait(0.2) end
            end
        elseif text == "Spin Player" and State.TargetPlayer and State.TargetPlayer.Character then
            local targetRoot = State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local spin = Instance.new("BodyAngularVelocity", targetRoot)
                spin.MaxTorque = Vector3.new(0, math.huge, 0)
                spin.AngularVelocity = Vector3.new(0, 50, 0)
                task.wait(3)
                spin:Destroy()
            end
        elseif text == "Remove Fog" then
            game:GetService("Lighting").FogEnd = 100000
        elseif text == "Server List" then
            local serverList = Instance.new("Frame", gui)
            serverList.Size = UDim2.new(0, 250, 0, 350)
            serverList.Position = UDim2.new(0.5, -125, 0.5, -175)
            serverList.BackgroundColor3 = Colors.BG
            serverList.BorderColor3 = Colors.Border
            serverList.BorderSizePixel = 2
            createLabel("Server Players", serverList, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), false)
            local scroll = Instance.new("ScrollingFrame", serverList)
            scroll.Size = UDim2.new(1, -10, 1, -70)
            scroll.Position = UDim2.new(0, 5, 0, 35)
            scroll.BackgroundColor3 = Colors.BG
            scroll.BorderColor3 = Colors.Border
            scroll.ScrollBarThickness = 6
            local layout = Instance.new("UIListLayout", scroll)
            layout.Padding = UDim.new(0, 2)
            for _,p in pairs(Players:GetPlayers()) do
                local plabel = createLabel(p.Name .. " [" .. p.DisplayName .. "]", scroll, UDim2.new(1, -10, 0, 25), nil, false)
                plabel.TextSize = 12
            end
            local close = createLabel("Close", serverList, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), true)
            close.MouseButton1Click:Connect(function() serverList:Destroy() end)
        else
            giveTool(text)
        end
        return
    end
    
    ActiveButtons[text] = toggled
    btn.BackgroundColor3 = toggled and Colors.Active or Colors.Inactive
    
    if text == "Fly" then
        local box = Instance.new("TextBox", btn)
        box.Size = UDim2.new(0, 40, 0, 20)
        box.Position = UDim2.new(1, -45, 0, 2)
        box.Text = tostring(State.FlySpeed)
        box.TextColor3 = Color3.fromRGB(255,0,0)
        box.BackgroundColor3 = Color3.fromRGB(0,0,0)
        box.BorderSizePixel = 1
        box.FocusLost:Connect(function()
            State.FlySpeed = tonumber(box.Text) or 50
            box.Text = tostring(State.FlySpeed)
        end)
        if toggled then task.spawn(startFly) else State.Fly = false end
        
    elseif text == "Noclip" then
        State.Noclip = toggled
        RunService.Stepped:Connect(function()
            if State.Noclip then
                for _,v in pairs(getChar():GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
        
    elseif text == "Walkspeed" then
        local box = Instance.new("TextBox", btn)
        box.Size = UDim2.new(0, 40, 0, 20)
        box.Position = UDim2.new(1, -45, 0, 2)
        box.Text = tostring(State.Walk)
        box.TextColor3 = Color3.fromRGB(255,0,0)
        box.BackgroundColor3 = Color3.fromRGB(0,0,0)
        box.BorderSizePixel = 1
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text) or 16
            box.Text = tostring(n)
            setWalk(n)
        end)
        
    elseif text == "Jump Power" then
        local box = Instance.new("TextBox", btn)
        box.Size = UDim2.new(0, 40, 0, 20)
        box.Position = UDim2.new(1, -45, 0, 2)
        box.Text = tostring(State.Jump)
        box.TextColor3 = Color3.fromRGB(255,0,0)
        box.BackgroundColor3 = Color3.fromRGB(0,0,0)
        box.BorderSizePixel = 1
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text) or 50
            box.Text = tostring(n)
            setJump(n)
        end)
        
    elseif text == "Infinite Jump" then
        State.InfiniteJump = toggled
        
    elseif text == "Speed Hack" then
        State.SpeedHack = toggled
        local box = Instance.new("TextBox", btn)
        box.Size = UDim2.new(0, 40, 0, 20)
        box.Position = UDim2.new(1, -45, 0, 2)
        box.Text = tostring(State.SpeedMultiplier)
        box.TextColor3 = Color3.fromRGB(255,0,0)
        box.BackgroundColor3 = Color3.fromRGB(0,0,0)
        box.BorderSizePixel = 1
        box.FocusLost:Connect(function()
            State.SpeedMultiplier = tonumber(box.Text) or 2
            box.Text = tostring(State.SpeedMultiplier)
        end)
        
    elseif text == "No Fall Damage" then
        State.NoFallDamage = toggled
        if getHum() then
            getHum().StateChanged:Connect(function(old, new)
                if State.NoFallDamage and new == Enum.HumanoidStateType.Freefall then
                    getHum():ChangeState(Enum.HumanoidStateType.Flying)
                    task.wait(0.1)
                    getHum():ChangeState(Enum.HumanoidStateType.Landed)
                end
            end)
        end
        
    elseif text == "Click TP" then
        State.ClickTPOn = toggled
        
    elseif text == "Anti-AFK" then
        if toggled then task.spawn(startAntiAFK) end
        State.AntiAFK = toggled
        
    elseif text == "Spam Jump" then
        if toggled then task.spawn(startSpamJump) else State.SpamJump = false end
        
    elseif text == "Kill Aura" then
        if toggled then task.spawn(startKillAura) else State.KillAura = false end
        
    elseif text == "Freeze Player" then
        if State.TargetPlayer and State.TargetPlayer.Character then
            for _,v in pairs(State.TargetPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.Anchored = toggled end
            end
        end
        
    elseif text == "Orbit Player" then
        if toggled then
            State.Orbiting = true
            task.spawn(function()
                while State.Orbiting do
                    if State.TargetPlayer and State.TargetPlayer.Character then
                        local targetRoot = State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local angle = tick() * 2
                            local radius = 10
                            local pos = targetRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                            getRoot().CFrame = CFrame.new(pos, targetRoot.Position)
                        end
                    end
                    task.wait()
                end
            end)
        else
            State.Orbiting = false
        end
        
    elseif text == "God Mode" then
        State.God = toggled
        local h = getHum()
        if h then
            h.MaxHealth = toggled and 1e9 or 100
            h.Health = h.MaxHealth
        end
        
    elseif text == "Forcefield" then
        if toggled then
            Instance.new("ForceField", getChar())
        else
            local ff = getChar():FindFirstChildOfClass("ForceField")
            if ff then ff:Destroy() end
        end
        
    elseif text == "Target Player" then
        local selector = Instance.new("Frame", gui)
        selector.Size = UDim2.new(0, 200, 0, 300)
        selector.Position = UDim2.new(0.5, -100, 0.5, -150)
        selector.BackgroundColor3 = Colors.BG
        selector.BorderColor3 = Colors.Border
        selector.BorderSizePixel = 2
        createLabel("Select Target", selector, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), false)
        local scroll = Instance.new("ScrollingFrame", selector)
        scroll.Size = UDim2.new(1, -10, 1, -70)
        scroll.Position = UDim2.new(0, 5, 0, 35)
        scroll.BackgroundColor3 = Colors.BG
        scroll.BorderColor3 = Colors.Border
        scroll.ScrollBarThickness = 6
        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, 2)
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= Player then
                local pbtn = createLabel(p.Name, scroll, UDim2.new(1, -10, 0, 25), nil, true)
                pbtn.MouseButton1Click:Connect(function()
                    State.TargetPlayer = p
                    selector:Destroy()
                    btn.Text = "Target: " .. p.Name
                end)
            end
        end
        local close = createLabel("Close", selector, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), true)
        close.MouseButton1Click:Connect(function() selector:Destroy() end)
        
    elseif text == "ESP Box" then
        State.ESPBox = toggled
        if toggled then setupESP() end
        
    elseif text == "ESP Name" then
        State.ESPName = toggled
        if toggled then setupESP() end
        
    elseif text == "ESP 2D" then
        State.ESP2D = toggled
        if toggled then setupESP() end
        
    elseif text == "Tracers" then
        State.Tracers = toggled
        if toggled then setupESP() end
        
    elseif text == "Fullbright" then
        setFullbright(toggled)
        
    elseif text == "X-Ray" then
        setXRay(toggled)
        
    elseif text == "Particle Emit" then
        if toggled then
            local particle = Instance.new("ParticleEmitter", getRoot())
            particle.Texture = "rbxasset://textures/particles/smoke_main.dds"
            particle.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
            particle.Size = NumberSequence.new(2)
            particle.Lifetime = NumberRange.new(2, 4)
            particle.Rate = 50
            particle.Speed = NumberRange.new(5, 10)
            particle.SpreadAngle = Vector2.new(360, 360)
            particle.Name = "CustomParticle"
            table.insert(ParticleEmitters, particle)
        else
            for _,p in pairs(ParticleEmitters) do
                if p then p:Destroy() end
            end
            ParticleEmitters = {}
        end
        
    elseif text == "Texture Replace" then
        replaceTextures(toggled)
        
    elseif text == "Invisible" then
        setInvisible(toggled)
        
    elseif text == "Seizure" then
        if toggled then
            task.spawn(startSeizure)
        else
            State.Seizure = false
            local h = getHum()
            if h then
                h.PlatformStand = false
                h.Sit = false
                h.WalkSpeed = State.Walk
                h.JumpPower = State.Jump
            end
        end
        
    elseif text == "Freecam" then
        if toggled then
            task.spawn(function()
                State.Freecam = true
                local camera = workspace.CurrentCamera
                local originalSubject = camera.CameraSubject
                camera.CameraType = Enum.CameraType.Scriptable
                camera.CameraSubject = nil
                local speed = 50
                local rotSpeed = 2
                local function updateCamera()
                    if not State.Freecam then return end
                    local cf = camera.CFrame
                    local move = Vector3.new(0,0,0)
                    if UserInput:IsKeyDown(Enum.KeyCode.H) then move = move + cf.LookVector end
                    if UserInput:IsKeyDown(Enum.KeyCode.N) then move = move - cf.LookVector end
                    if UserInput:IsKeyDown(Enum.KeyCode.B) then move = move - cf.RightVector end
                    if UserInput:IsKeyDown(Enum.KeyCode.M) then move = move + cf.RightVector end
                    if UserInput:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                    if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                    local delta = UserInput:GetMouseDelta()
                    cf = cf * CFrame.Angles(0, -delta.X * rotSpeed * 0.01, 0)
                    cf = cf * CFrame.Angles(-delta.Y * rotSpeed * 0.01, 0, 0)
                    cf = cf + move * speed * 0.016
                    camera.CFrame = cf
                end
                local conn = RunService.RenderStepped:Connect(updateCamera)
                while State.Freecam do task.wait() end
                conn:Disconnect()
                camera.CameraType = Enum.CameraType.Custom
                camera.CameraSubject = originalSubject
            end)
        else
            State.Freecam = false
        end
        
    elseif text == "Chicken Arms" then
        if toggled then task.spawn(startChickenArms) else State.ChickenArms = false end
        
    elseif text == "Jerk" then
        if toggled then task.spawn(startJerk) else State.Jerk = false end
        
    elseif text == "Sit" then
        State.Sitting = toggled
        local h = getHum()
        if h then h.Sit = toggled end
    end
end

local function updatePage()
    for _,v in pairs(Content:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end
    end
    
    local data = Modules["Page"..CurrentPage]
    createLabel(data[1], Content, UDim2.new(1, 0, 0, 25), nil, false).TextSize = 12
    createLabel(data[2], Content, UDim2.new(1, 0, 0, 25), nil, false).TextSize = 12
    
    for i = 3, #data do
        local text = data[i]
        local btn = createLabel(text, Content, UDim2.new(1, 0, 0, 25), nil, true)
        btn.TextSize = 14
        btn.BackgroundColor3 = ActiveButtons[text] and Colors.Active or Colors.Inactive
        
        if text == "" then 
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            continue 
        end
        
        btn.MouseEnter:Connect(function()
            if Tooltips[text] then
                Tooltip.Text = Tooltips[text]
                local mousePos = UserInput:GetMouseLocation()
                Tooltip.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y + 10)
                Tooltip.Visible = true
            end
        end)
        
        btn.MouseMoved:Connect(function()
            if Tooltip.Visible then
                local mousePos = UserInput:GetMouseLocation()
                Tooltip.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y + 10)
            end
        end)
        
        btn.MouseLeave:Connect(function()
            Tooltip.Visible = false
        end)
        
        btn.MouseButton1Click:Connect(function()
            local toggled = not ActiveButtons[text]
            handleAction(text, btn, toggled)
        end)
    end
end

LeftArr.MouseButton1Click:Connect(function()
    CurrentPage = (CurrentPage - 2 + MAX_PAGES) % MAX_PAGES + 1
    updatePage()
end)

RightArr.MouseButton1Click:Connect(function()
    CurrentPage = CurrentPage % MAX_PAGES + 1
    updatePage()
end)

createLabel("Kill Gui", MainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), true).MouseButton1Click:Connect(function()
    Main:Destroy()
end)

updatePage()

local function toggle()
    Main.Visible = not Main.Visible
    Arrow.Text = Main.Visible and "<<" or ">>"
end

Arrow.MouseButton1Click:Connect(toggle)
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        toggle()
    end
end)
