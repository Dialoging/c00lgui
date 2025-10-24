local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CurrentPage = 1
local MAX_PAGES = 5

local C = {
    BG = Color3.fromRGB(0,0,0),
    Border = Color3.fromRGB(255,0,0),
    Text = Color3.fromRGB(255,255,255),
    Active = Color3.fromRGB(255,0,0),
    Inactive = Color3.fromRGB(0,0,0)
}

local Modules = {
    Page1 = {
        "Movement", "Player Control",
        "Fly", "Noclip", "Walkspeed", "Jump Power",
        "Infinite Jump", "Speed Hack", "No Fall Damage", "Click TP",
        "Teleport To", "Bring Player", "Anti-AFK", "Spam Jump"
    },
    Page2 = {
        "Combat", "Offensive",
        "Kill All", "Kill Aura", "Server Kill", "Fling Player",
        "Fling All", "Freeze Player", "Spin Player", "Orbit Player",
        "God Mode", "Forcefield", "Target Player", ""
    },
    Page3 = {
        "Render", "Visual Effects",
        "ESP Box", "ESP Name", "ESP 2D", "Tracers",
        "Fullbright", "X-Ray", "Remove Fog", "Particle Emit",
        "Texture Replace", "Invisible", "", ""
    },
    Page4 = {
        "Tools", "Equipment",
        "BTools", "Knife", "Sword", "Katana",
        "Scythe", "Ban Hammer", "Bomb", "Rocket",
        "Gravity Gun", "Telekinesis", "", ""
    },
    Page5 = {
        "Fun", "Misc",
        "Seizure", "Freecam", "Server List", "",
        "", "", "", "",
        "", "", "", ""
    }
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
    ["Server List"] = "View all players in the server"
}

local ToolIDs = {
    ["Knife"] = 142785488,
    ["Sword"] = 125013769,
    ["Katana"] = 88885539,
    ["Scythe"] = 95951330,
    ["Ban Hammer"] = 10468797,
    ["Bomb"] = 12884143,
    ["Rocket"] = 12844699,
    ["Gravity Gun"] = 92142841,
    ["Telekinesis"] = 91360081
}

local States = {
    Invisible = false,
    Fly = false,
    FlySpeed = 50,
    Walk = 16,
    Jump = 50,
    AntiAFK = false,
    ClickTPOn = false,
    Noclip = false,
    God = false,
    ESPBox = false,
    ESPName = false,
    ESP2D = false,
    InfiniteJump = false,
    Fullbright = false,
    SpeedHack = false,
    SpeedMultiplier = 2,
    NoFallDamage = false,
    KillAura = false,
    SpamJump = false,
    XRay = false,
    Tracers = false,
    TextureReplace = false,
    TargetPlayer = nil,
    Orbiting = false,
    Freecam = false,
    Seizure = false
}

local ActiveButtons = {}
local ESPBoxes = {}
local ESPNames = {}
local ESP2DBoxes = {}
local TracerLines = {}
local ParticleEmitters = {}
local OriginalTextures = {}
local FlingPower = 2000

local function char()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function root()
    return char():WaitForChild("HumanoidRootPart")
end

local function hum()
    return char():FindFirstChildOfClass("Humanoid")
end

local function setInvisible(on)
    States.Invisible = on
    for _,v in pairs(char():GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            if on then
                v.CFrame = v.CFrame - Vector3.new(0, 500, 0)
            else
                v.CFrame = v.CFrame + Vector3.new(0, 500, 0)
            end
        end
    end
end

local function setWalk(n)
    States.Walk = n
    if hum() then hum().WalkSpeed = n end
end

local function setJump(n)
    States.Jump = n
    if hum() then hum().JumpPower = n end
end

local function startFly()
    States.Fly = true
    local r = root()
    local bp = Instance.new("BodyPosition", r)
    local bg = Instance.new("BodyGyro", r)
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bp.D, bp.P = 1000, 10000
    while States.Fly do
        local cf = workspace.CurrentCamera.CFrame
        bg.CFrame = cf
        local spd = States.FlySpeed
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

local function stopFly() States.Fly = false end

local function startAntiAFK()
    States.AntiAFK = true
    while States.AntiAFK do
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
        wait(60)
    end
end

local function giveBTools()
    local Move = Instance.new("HopperBin")
    Move.Name = "Move"
    Move.BinType = Enum.BinType.GameTool
    Move.Parent = LocalPlayer.Backpack
    
    local Clone = Instance.new("HopperBin")
    Clone.Name = "Clone"
    Clone.BinType = Enum.BinType.Clone
    Clone.Parent = LocalPlayer.Backpack
    
    local Delete = Instance.new("HopperBin")
    Delete.Name = "Delete"
    Delete.BinType = Enum.BinType.Hammer
    Delete.Parent = LocalPlayer.Backpack
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
    
    tool.Parent = LocalPlayer.Backpack
end

Mouse.Button1Down:Connect(function()
    if States.ClickTPOn and Mouse.Target then
        root().CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
    end
end)

local function createESPBox(player)
    if ESPBoxes[player] or player == LocalPlayer then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 5, 4)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.7
    box.AlwaysOnTop = true
    box.ZIndex = 10
    ESPBoxes[player] = box
    
    RunService.RenderStepped:Connect(function()
        if States.ESPBox and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = player.Character.HumanoidRootPart
            box.Parent = player.Character.HumanoidRootPart
        else
            box.Parent = nil
        end
    end)
end

local function createESPName(player)
    if ESPNames[player] or player == LocalPlayer then return end
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
        if States.ESPName and player.Character and player.Character:FindFirstChild("Head") then
            bill.Adornee = player.Character.Head
            bill.Parent = player.Character.Head
        else
            bill.Parent = nil
        end
    end)
end

local function createESP2D(player)
    if ESP2DBoxes[player] or player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    
    ESP2DBoxes[player] = box
    
    RunService.RenderStepped:Connect(function()
        if States.ESP2D and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
end

local function createTracer(player)
    if TracerLines[player] or player == LocalPlayer then return end
    
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 2
    line.Transparency = 1
    
    TracerLines[player] = line
    
    RunService.RenderStepped:Connect(function()
        if States.Tracers and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

local function setupESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            createESPBox(p)
            createESPName(p)
            createESP2D(p)
            createTracer(p)
        end
    end
    Players.PlayerAdded:Connect(function(p)
        createESPBox(p)
        createESPName(p)
        createESP2D(p)
        createTracer(p)
    end)
end

UserInput.JumpRequest:Connect(function()
    if States.InfiniteJump and hum() then
        hum():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function setFullbright(on)
    States.Fullbright = on
    local Lighting = game:GetService("Lighting")
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    end
end

local function removeFog()
    local Lighting = game:GetService("Lighting")
    Lighting.FogEnd = 100000
end

RunService.Heartbeat:Connect(function()
    if States.SpeedHack and hum() then
        hum().WalkSpeed = States.Walk * States.SpeedMultiplier
    end
end)

local function setNoFallDamage(on)
    States.NoFallDamage = on
    if hum() then
        hum().StateChanged:Connect(function(old, new)
            if States.NoFallDamage and new == Enum.HumanoidStateType.Freefall then
                hum():ChangeState(Enum.HumanoidStateType.Flying)
                task.wait(0.1)
                hum():ChangeState(Enum.HumanoidStateType.Landed)
            end
        end)
    end
end

local function flingKill(targetPlayer)
    if not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local myRoot = root()
    local originalPos = myRoot.Position
    
    for i = 1, 10 do
        myRoot.CFrame = targetRoot.CFrame
        myRoot.AssemblyLinearVelocity = Vector3.new(FlingPower, FlingPower, FlingPower)
        RunService.Heartbeat:Wait()
    end
    
    myRoot.CFrame = CFrame.new(originalPos)
    myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

local function startKillAura()
    States.KillAura = true
    
    while States.KillAura do
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and (targetRoot.Position - root().Position).Magnitude < 20 then
                    flingKill(p)
                    task.wait(0.5)
                end
            end
        end
        task.wait(0.1)
    end
end

local function startSpamJump()
    States.SpamJump = true
    while States.SpamJump do
        if hum() then
            hum():ChangeState(Enum.HumanoidStateType.Jumping)
        end
        task.wait(0.2)
    end
end

local function setXRay(on)
    States.XRay = on
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not Players:GetPlayerFromCharacter(v.Parent) then
            if on then
                v.LocalTransparencyModifier = 0.7
            else
                v.LocalTransparencyModifier = 0
            end
        end
    end
end

local function replaceTextures(on)
    States.TextureReplace = on
    local textureId = "rbxassetid://10560525674"
    
    if on then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                if not OriginalTextures[v] then
                    OriginalTextures[v] = v.Texture
                end
                v.Texture = textureId
            elseif v:IsA("SurfaceAppearance") then
                if not OriginalTextures[v] then
                    OriginalTextures[v] = {
                        ColorMap = v.ColorMap,
                        MetalnessMap = v.MetalnessMap,
                        NormalMap = v.NormalMap,
                        RoughnessMap = v.RoughnessMap
                    }
                end
                v.ColorMap = textureId
                v.MetalnessMap = textureId
                v.NormalMap = textureId
                v.RoughnessMap = textureId
            elseif v:IsA("MeshPart") then
                if not OriginalTextures[v] then
                    OriginalTextures[v] = v.TextureID
                end
                v.TextureID = textureId
            elseif v:IsA("Sky") then
                if not OriginalTextures[v] then
                    OriginalTextures[v] = {
                        SkyboxBk = v.SkyboxBk,
                        SkyboxDn = v.SkyboxDn,
                        SkyboxFt = v.SkyboxFt,
                        SkyboxLf = v.SkyboxLf,
                        SkyboxRt = v.SkyboxRt,
                        SkyboxUp = v.SkyboxUp
                    }
                end
                v.SkyboxBk = textureId
                v.SkyboxDn = textureId
                v.SkyboxFt = textureId
                v.SkyboxLf = textureId
                v.SkyboxRt = textureId
                v.SkyboxUp = textureId
            end
        end
        
        for _,v in pairs(game:GetService("Lighting"):GetDescendants()) do
            if v:IsA("Sky") then
                if not OriginalTextures[v] then
                    OriginalTextures[v] = {
                        SkyboxBk = v.SkyboxBk,
                        SkyboxDn = v.SkyboxDn,
                        SkyboxFt = v.SkyboxFt,
                        SkyboxLf = v.SkyboxLf,
                        SkyboxRt = v.SkyboxRt,
                        SkyboxUp = v.SkyboxUp
                    }
                end
                v.SkyboxBk = textureId
                v.SkyboxDn = textureId
                v.SkyboxFt = textureId
                v.SkyboxLf = textureId
                v.SkyboxRt = textureId
                v.SkyboxUp = textureId
            end
        end
    else
        for obj, orig in pairs(OriginalTextures) do
            if obj and obj.Parent then
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Texture = orig
                elseif obj:IsA("SurfaceAppearance") then
                    obj.ColorMap = orig.ColorMap
                    obj.MetalnessMap = orig.MetalnessMap
                    obj.NormalMap = orig.NormalMap
                    obj.RoughnessMap = orig.RoughnessMap
                elseif obj:IsA("MeshPart") then
                    obj.TextureID = orig
                elseif obj:IsA("Sky") then
                    obj.SkyboxBk = orig.SkyboxBk
                    obj.SkyboxDn = orig.SkyboxDn
                    obj.SkyboxFt = orig.SkyboxFt
                    obj.SkyboxLf = orig.SkyboxLf
                    obj.SkyboxRt = orig.SkyboxRt
                    obj.SkyboxUp = orig.SkyboxUp
                end
            end
        end
        OriginalTextures = {}
    end
end

local function createParticleEmitter(target)
    local targetPart
    if target == "Self" then
        targetPart = root()
    elseif target == "Mouse" then
        targetPart = Mouse.Target
    elseif States.TargetPlayer and States.TargetPlayer.Character then
        targetPart = States.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    
    if not targetPart then return end
    
    local particle = Instance.new("ParticleEmitter", targetPart)
    particle.Texture = "rbxasset://textures/particles/smoke_main.dds"
    particle.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    particle.Size = NumberSequence.new(2)
    particle.Lifetime = NumberRange.new(2, 4)
    particle.Rate = 50
    particle.Speed = NumberRange.new(5, 10)
    particle.SpreadAngle = Vector2.new(360, 360)
    particle.Name = "CustomParticle"
    
    table.insert(ParticleEmitters, particle)
    return particle
end

local function flingPlayer()
    if not States.TargetPlayer or not States.TargetPlayer.Character then return end
    flingKill(States.TargetPlayer)
end

local function bringPlayer()
    if not States.TargetPlayer or not States.TargetPlayer.Character then return end
    local targetRoot = States.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        targetRoot.CFrame = root().CFrame + Vector3.new(3, 0, 0)
    end
end

local function teleportToPlayer()
    if not States.TargetPlayer or not States.TargetPlayer.Character then return end
    local targetRoot = States.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        root().CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
    end
end

local function freezePlayer(freeze)
    if not States.TargetPlayer or not States.TargetPlayer.Character then return end
    for _,v in pairs(States.TargetPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = freeze
        end
    end
end

local function orbitPlayer()
    States.Orbiting = true
    while States.Orbiting do
        if States.TargetPlayer and States.TargetPlayer.Character then
            local targetRoot = States.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local angle = tick() * 2
                local radius = 10
                local pos = targetRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                root().CFrame = CFrame.new(pos, targetRoot.Position)
            end
        end
        task.wait()
    end
end

local function spinPlayer()
    if not States.TargetPlayer or not States.TargetPlayer.Character then return end
    local targetRoot = States.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        local spin = Instance.new("BodyAngularVelocity", targetRoot)
        spin.MaxTorque = Vector3.new(0, math.huge, 0)
        spin.AngularVelocity = Vector3.new(0, 50, 0)
        task.wait(3)
        spin:Destroy()
    end
end

local function startSeizure()
    States.Seizure = true
    while States.Seizure do
        local h = hum()
        if h then
            h.PlatformStand = true
            h.Sit = true
            h.Jump = true
            h.AutoRotate = false
            h.WalkSpeed = 0
            h.JumpPower = 0
            local r = root()
            r.AssemblyAngularVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
            r.AssemblyLinearVelocity = Vector3.new(math.random(-50,50), math.random(-50,50), math.random(-50,50))
            for _,v in pairs(char():GetDescendants()) do
                if v:IsA("Motor6D") then
                    v.CurrentAngle = math.random(-180,180)
                end
            end
        end
        task.wait(0.1)
    end
end

local function stopSeizure()
    States.Seizure = false
    local h = hum()
    if h then
        h.PlatformStand = false
        h.Sit = false
        h.Jump = false
        h.AutoRotate = true
        h.WalkSpeed = States.Walk
        h.JumpPower = States.Jump
    end
end

local function startFreecam()
    States.Freecam = true
    local camera = workspace.CurrentCamera
    local originalCFrame = camera.CFrame
    local originalSubject = camera.CameraSubject
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CameraSubject = nil
    
    local speed = 50
    local rotSpeed = 2
    
    local function updateCamera()
        if not States.Freecam then return end
        local cf = camera.CFrame
        local move = Vector3.new(0,0,0)
        
        if UserInput:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        
        local delta = UserInput:GetMouseDelta()
        cf = cf * CFrame.Angles(0, -delta.X * rotSpeed * 0.01, 0)
        cf = cf * CFrame.Angles(-delta.Y * rotSpeed * 0.01, 0, 0)
        cf = cf + move * speed * 0.016
        
        camera.CFrame = cf
    end
    
    local conn = RunService.RenderStepped:Connect(updateCamera)
    
    while States.Freecam do
        task.wait()
    end
    
    conn:Disconnect()
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = originalSubject
end

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "c00lgui_dialoging"

local Tooltip = Instance.new("TextLabel")
Tooltip.Size = UDim2.new(0, 250, 0, 50)
Tooltip.BackgroundColor3 = C.BG
Tooltip.BorderColor3 = C.Border
Tooltip.BorderSizePixel = 2
Tooltip.TextColor3 = C.Text
Tooltip.TextSize = 11
Tooltip.Font = Enum.Font.SourceSans
Tooltip.TextWrapped = true
Tooltip.Visible = false
Tooltip.ZIndex = 1000
Tooltip.Parent = gui

local Arrow = Instance.new("TextButton")
Arrow.Size = UDim2.new(0, 30, 0, 60)
Arrow.Position = UDim2.new(0, 10, 0.5, -30)
Arrow.BackgroundColor3 = C.BG
Arrow.BorderColor3 = C.Border
Arrow.BorderSizePixel = 2
Arrow.Text = ">>"
Arrow.TextColor3 = C.Text
Arrow.TextSize = 18
Arrow.Font = Enum.Font.SourceSansBold
Arrow.Parent = gui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 320)
Main.Position = UDim2.new(0, 50, 0.5, -160)
Main.BackgroundColor3 = C.BG
Main.BorderColor3 = C.Border
Main.BorderSizePixel = 1
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = gui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = Main

local function style(text, parent, size, pos, isBtn)
    local e = isBtn and Instance.new("TextButton") or Instance.new("TextLabel")
    e.Size = size or UDim2.new(1, 0, 1, 0)
    e.Position = pos or UDim2.new(0, 0, 0, 0)
    e.BackgroundColor3 = C.BG
    e.BorderColor3 = C.Border
    e.BorderSizePixel = 1
    e.Text = text
    e.TextColor3 = C.Text
    e.TextSize = 14
    e.Font = Enum.Font.SourceSans
    e.TextXAlignment = Enum.TextXAlignment.Center
    e.TextYAlignment = Enum.TextYAlignment.Center
    e.Parent = parent
    return e
end

style("c00lgui - Dialoging", MainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), false).TextSize = 16

local Nav = style("", MainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 30), false)
local NavLay = Instance.new("UIListLayout", Nav)
NavLay.FillDirection = Enum.FillDirection.Horizontal
NavLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLay.Padding = UDim.new(0, 10)

local LeftArr = style("<", Nav, UDim2.new(0, 20, 1, 0), nil, true)
LeftArr.BorderSizePixel = 0
local RightArr = style(">", Nav, UDim2.new(0, 20, 1, 0), nil, true)
RightArr.BorderSizePixel = 0

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -90)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Grid = Instance.new("UIGridLayout", Content)
Grid.CellSize = UDim2.new(0.5, 0, 0, 25)
Grid.CellPadding = UDim2.new(0, 0, 0, 0)

local InstantActions = {
    ["Teleport To"] = true,
    ["Bring Player"] = true,
    ["BTools"] = true,
    ["Knife"] = true,
    ["Sword"] = true,
    ["Katana"] = true,
    ["Scythe"] = true,
    ["Ban Hammer"] = true,
    ["Bomb"] = true,
    ["Rocket"] = true,
    ["Gravity Gun"] = true,
    ["Telekinesis"] = true,
    ["Server Kill"] = true,
    ["Fling Player"] = true,
    ["Fling All"] = true,
    ["Kill All"] = true,
    ["Spin Player"] = true,
    ["Remove Fog"] = true,
    ["Server List"] = true
}

local function updatePage()
    for _,v in pairs(Content:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end
    end
    
    local data = Modules["Page"..CurrentPage]
    style(data[1], Content, UDim2.new(1, 0, 0, 25), nil, false).TextSize = 12
    style(data[2], Content, UDim2.new(1, 0, 0, 25), nil, false).TextSize = 12
    
    for i = 3, #data do
        local text = data[i]
        local btn = style(text, Content, UDim2.new(1, 0, 0, 25), nil, true)
        btn.TextSize = 14
        
        local isActive = ActiveButtons[text]
        btn.BackgroundColor3 = isActive and C.Active or C.Inactive
        
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
            if InstantActions[text] then
                if text == "Teleport To" then
                    teleportToPlayer()
                elseif text == "Bring Player" then
                    bringPlayer()
                elseif text == "BTools" then
                    giveBTools()
                elseif text == "Server Kill" then
                    flingPlayer()
                elseif text == "Fling Player" then
                    flingPlayer()
                elseif text == "Fling All" then
                    for _,p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            flingKill(p)
                            task.wait(0.2)
                        end
                    end
                elseif text == "Kill All" then
                    for _,p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            flingKill(p)
                            task.wait(0.3)
                        end
                    end
                elseif text == "Spin Player" then
                    spinPlayer()
                elseif text == "Remove Fog" then
                    removeFog()
                elseif text == "Server List" then
                    local serverList = Instance.new("Frame")
                    serverList.Size = UDim2.new(0, 250, 0, 350)
                    serverList.Position = UDim2.new(0.5, -125, 0.5, -175)
                    serverList.BackgroundColor3 = C.BG
                    serverList.BorderColor3 = C.Border
                    serverList.BorderSizePixel = 2
                    serverList.Parent = gui
                    
                    local title = style("Server Players", serverList, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), false)
                    
                    local scroll = Instance.new("ScrollingFrame", serverList)
                    scroll.Size = UDim2.new(1, -10, 1, -70)
                    scroll.Position = UDim2.new(0, 5, 0, 35)
                    scroll.BackgroundColor3 = C.BG
                    scroll.BorderColor3 = C.Border
                    scroll.ScrollBarThickness = 6
                    
                    local layout = Instance.new("UIListLayout", scroll)
                    layout.Padding = UDim.new(0, 2)
                    
                    for _,p in pairs(Players:GetPlayers()) do
                        local plabel = style(p.Name .. " [" .. p.DisplayName .. "]", scroll, UDim2.new(1, -10, 0, 25), nil, false)
                        plabel.TextSize = 12
                    end
                    
                    local close = style("Close", serverList, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), true)
                    close.MouseButton1Click:Connect(function() serverList:Destroy() end)
                else
                    giveTool(text)
                end
                return
            end
            
            local toggled = not ActiveButtons[text]
            ActiveButtons[text] = toggled
            btn.BackgroundColor3 = toggled and C.Active or C.Inactive
            
            if text == "Fly" then
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(0, 40, 0, 20)
                box.Position = UDim2.new(1, -45, 0, 2)
                box.Text = tostring(States.FlySpeed)
                box.TextColor3 = Color3.fromRGB(255,0,0)
                box.BackgroundColor3 = Color3.fromRGB(0,0,0)
                box.BorderSizePixel = 1
                box.Parent = btn
                box.FocusLost:Connect(function()
                    local n = tonumber(box.Text) or 50
                    box.Text = tostring(n)
                    States.FlySpeed = n
                end)
                if toggled then startFly() else stopFly() end
                
            elseif text == "Noclip" then
                States.Noclip = toggled
                RunService.Stepped:Connect(function()
                    if States.Noclip then
                        for _,v in pairs(char():GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end)
                
            elseif text == "Walkspeed" then
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(0, 40, 0, 20)
                box.Position = UDim2.new(1, -45, 0, 2)
                box.Text = tostring(States.Walk)
                box.TextColor3 = Color3.fromRGB(255,0,0)
                box.BackgroundColor3 = Color3.fromRGB(0,0,0)
                box.BorderSizePixel = 1
                box.Parent = btn
                box.FocusLost:Connect(function()
                    local n = tonumber(box.Text) or 16
                    box.Text = tostring(n)
                    setWalk(n)
                end)
                
            elseif text == "Jump Power" then
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(0, 40, 0, 20)
                box.Position = UDim2.new(1, -45, 0, 2)
                box.Text = tostring(States.Jump)
                box.TextColor3 = Color3.fromRGB(255,0,0)
                box.BackgroundColor3 = Color3.fromRGB(0,0,0)
                box.BorderSizePixel = 1
                box.Parent = btn
                box.FocusLost:Connect(function()
                    local n = tonumber(box.Text) or 50
                    box.Text = tostring(n)
                    setJump(n)
                end)
                
            elseif text == "Infinite Jump" then
                States.InfiniteJump = toggled
                
            elseif text == "Speed Hack" then
                States.SpeedHack = toggled
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(0, 40, 0, 20)
                box.Position = UDim2.new(1, -45, 0, 2)
                box.Text = tostring(States.SpeedMultiplier)
                box.TextColor3 = Color3.fromRGB(255,0,0)
                box.BackgroundColor3 = Color3.fromRGB(0,0,0)
                box.BorderSizePixel = 1
                box.Parent = btn
                box.FocusLost:Connect(function()
                    local n = tonumber(box.Text) or 2
                    box.Text = tostring(n)
                    States.SpeedMultiplier = n
                end)
                
            elseif text == "No Fall Damage" then
                setNoFallDamage(toggled)
                
            elseif text == "Click TP" then
                States.ClickTPOn = toggled
                
            elseif text == "Anti-AFK" then
                if toggled then task.spawn(startAntiAFK) end
                States.AntiAFK = toggled
                
            elseif text == "Spam Jump" then
                if toggled then task.spawn(startSpamJump) else States.SpamJump = false end
                
            elseif text == "Kill Aura" then
                if toggled then task.spawn(startKillAura) else States.KillAura = false end
                
            elseif text == "Freeze Player" then
                freezePlayer(toggled)
                
            elseif text == "Orbit Player" then
                if toggled then task.spawn(orbitPlayer) else States.Orbiting = false end
                
            elseif text == "God Mode" then
                States.God = toggled
                local h = hum()
                if h then
                    h.MaxHealth = toggled and 1e9 or 100
                    h.Health = h.MaxHealth
                end
                
            elseif text == "Forcefield" then
                if toggled then
                    Instance.new("ForceField", char())
                else
                    local ff = char():FindFirstChildOfClass("ForceField")
                    if ff then ff:Destroy() end
                end
                
            elseif text == "Target Player" then
                local selector = Instance.new("Frame")
                selector.Size = UDim2.new(0, 200, 0, 300)
                selector.Position = UDim2.new(0.5, -100, 0.5, -150)
                selector.BackgroundColor3 = C.BG
                selector.BorderColor3 = C.Border
                selector.BorderSizePixel = 2
                selector.Parent = gui
                
                local title = style("Select Target", selector, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), false)
                
                local scroll = Instance.new("ScrollingFrame", selector)
                scroll.Size = UDim2.new(1, -10, 1, -70)
                scroll.Position = UDim2.new(0, 5, 0, 35)
                scroll.BackgroundColor3 = C.BG
                scroll.BorderColor3 = C.Border
                scroll.ScrollBarThickness = 6
                
                local layout = Instance.new("UIListLayout", scroll)
                layout.Padding = UDim.new(0, 2)
                
                for _,p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then
                        local pbtn = style(p.Name, scroll, UDim2.new(1, -10, 0, 25), nil, true)
                        pbtn.MouseButton1Click:Connect(function()
                            States.TargetPlayer = p
                            selector:Destroy()
                            btn.Text = "Target: " .. p.Name
                        end)
                    end
                end
                
                local close = style("Close", selector, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), true)
                close.MouseButton1Click:Connect(function() selector:Destroy() end)
                
            elseif text == "ESP Box" then
                States.ESPBox = toggled
                if toggled then setupESP() end
                
            elseif text == "ESP Name" then
                States.ESPName = toggled
                if toggled then setupESP() end
                
            elseif text == "ESP 2D" then
                States.ESP2D = toggled
                if toggled then setupESP() end
                
            elseif text == "Tracers" then
                States.Tracers = toggled
                if toggled then setupESP() end
                
            elseif text == "Fullbright" then
                setFullbright(toggled)
                
            elseif text == "X-Ray" then
                setXRay(toggled)
                
            elseif text == "Particle Emit" then
                if toggled then
                    createParticleEmitter("Self")
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
                    stopSeizure()
                end
                
            elseif text == "Freecam" then
                if toggled then
                    task.spawn(startFreecam)
                else
                    States.Freecam = false
                end
            end
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

style("Close", MainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), true).MouseButton1Click:Connect(function()
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
end
