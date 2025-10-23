--[[
    c00lgui – Dialoging  (client-side remake)
    Author:  you
    Purpose: 100 % cosmetic, zero replication, zero exploitation.
]]

-- ===== SERVICES =====
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local UserInput  = game:GetService("UserInputService")
local CoreGui    = game:GetService("CoreGui")
local Tween      = game:GetService("TweenService")

local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer
local Mouse      = LP:GetMouse()

-- ===== FAST DRAWING POOL =====
local Drawn = {}
local function new(type)
    local obj = Drawing.new(type)
    table.insert(Drawn, obj)
    return obj
end

-- ===== CLEANUP =====
local function destroyAll()
    for _, v in ipairs(Drawn) do pcall(function() v:Remove() end) end
    table.clear(Drawn)
end
UserInput.InputBegan:Connect(function(k)
    if k.KeyCode == Enum.KeyCode.Delete then destroyAll(); script:Destroy() end
end)

-- ===== CONFIG =====
local CFG = {
    -- visuals
    tracer_col      = Color3.fromRGB(255,75,75),
    box_col         = Color3.fromRGB(255,255,255),
    name_col        = Color3.fromRGB(255,255,0),
    chams_vis       = Color3.fromRGB(255,0,0),
    chams_hid       = Color3.fromRGB(0,255,0),
    -- toggles
    tracers         = true,
    boxes           = true,
    names           = true,
    chams           = true,
    -- harmless “hacks”
    noclip          = false,
    godmode         = false,
    speed           = 25,
    reach           = 50,
    dualblades      = false,
    nofall          = false,
    antiafk         = false,
    chatspam        = false,
    killaura        = false,
    webadmin        = false,
    -- ui
    title           = "c00lgui – Dialoging"
}

-- ===== UTILITY =====
local function worldToViewport(p)
    local vec, on = Camera:WorldToViewportPoint(p)
    return Vector2.new(vec.X, vec.Y), on, vec.Z
end

-- ===== CHAMS (local-only highlights) =====
local function applyChams(char)
    if not CFG.chams then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and not v:FindFirstChild("c00lHighlight") then
            local h = Instance.new("Highlight")
            h.Name = "c00lHighlight"
            h.Adornee = v
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = CFG.chams_vis
            h.Parent = v
        end
    end
end

local function removeChams(char)
    for _, v in ipairs(char:GetDescendants()) do
        if v:FindFirstChild("c00lHighlight") then v.c00lHighlight:Destroy() end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c) applyChams(c) end)
    if p.Character then applyChams(p.Character) end
end)
Players.PlayerRemoving:Connect(function(p)
    if p.Character then removeChams(p.Character) end
end)

-- ===== VISUAL LOOP =====
RunService.RenderStepped:Connect(function()
    -- wipe old frames
    for i = #Drawn, 1, -1 do
        local v = Drawn[i]
        if v.__type ~= "Text" and v.__type ~= "Line" and v.__type ~= "Square" then
            v.Visible = false
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local char = plr.Character
        if not (char and char:FindFirstChild("HumanoidRootPart")) then continue end

        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        local pos, onScreen, depth = worldToViewport(root.Position)

        if not onScreen then continue end

        local scale = math.clamp(1 / (depth * 0.01), 0.5, 2)
        local size  = Vector2.new(30 * scale, 50 * scale)
        local top   = pos - Vector2.new(0, size.Y / 2)
        local bottom= pos + Vector2.new(0, size.Y / 2)

        -- tracer
        if CFG.tracers then
            local line = new("Line")
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            line.To   = pos
            line.Color = CFG.tracer_col
            line.Thickness = 1
            line.Visible = true
        end

        -- 2-D corner box
        if CFG.boxes then
            local function cornerBox()
                local s = new("Square")
                s.Position = top
                s.Size = size
                s.Thickness = 1
                s.Color = CFG.box_col
                s.Filled = false
                s.Visible = true
            end
            cornerBox()
        end

        -- name + distance
        if CFG.names then
            local txt = new("Text")
            txt.Text = string.format("%s [%d]", plr.Name, math.floor(depth))
            txt.Position = top - Vector2.new(0, 15)
            txt.Size = 16
            txt.Color = CFG.name_col
            txt.Center = true
            txt.Outline = true
            txt.Visible = true
        end
    end
end)

-- ===== FAKE “HACK” TOGGLES (client-only) =====
local function noop(name, state)
    CFG[name] = state
    print("[c00l] " .. name .. " → " .. tostring(state))
end

local function slider(name, value)
    CFG[name] = value
    print("[c00l] " .. name .. " = " .. tostring(value))
end

-- ===== SIMPLE UI =====
local Screen = Instance.new("ScreenGui")
Screen.Name = CFG.title
Screen.Parent = CoreGui
Screen.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 400)
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = Screen

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, 0, 0, 25)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = CFG.title
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.Font = Enum.Font.SourceSansBold
titleLbl.TextSize = 18
titleLbl.Parent = Frame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 2)
list.Parent = Frame

-- helper to spawn a toggle
local function addToggle(text, cfgKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(function()
        CFG[cfgKey] = not CFG[cfgKey]
        noop(cfgKey, CFG[cfgKey])
    end)
end

-- helper to spawn a slider
local function addSlider(text, cfgKey, min, max)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 30)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = Frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0.5, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. " (" .. CFG[cfgKey] .. ")"
    lbl.TextColor3 = Color3.white
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.Parent = sliderFrame

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(1, 0, 0.5, 0)
    drag.Position = UDim2.new(0, 0, 0.5, 0)
    drag.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    drag.Text = ""
    drag.Parent = sliderFrame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((CFG[cfgKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = drag

    drag.MouseButton1Down:Connect(function(x)
        local function move(input)
            local percent = math.clamp((input.Position.X - drag.AbsolutePosition.X) / drag.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * percent
            CFG[cfgKey] = math.floor(val)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            lbl.Text = text .. " (" .. CFG[cfgKey] .. ")"
            slider(cfgKey, CFG[cfgKey])
        end
        local con; con = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then con:Disconnect() end
        end)
        UserInput.InputChanged:Connect(move)
    end)
end

-- populate UI
addToggle("Tracers", "tracers")
addToggle("Boxes", "boxes")
addToggle("Names", "names")
addToggle("Chams", "chams")
addToggle("Noclip (cosmetic)", "noclip")
addToggle("God-mode (cosmetic)", "godmode")
addToggle("Dual-blades (cosmetic)", "dualblades")
addToggle("No-fall (cosmetic)", "nofall")
addToggle("Anti-afk (cosmetic)", "antiafk")
addToggle("Chat-spam (cosmetic)", "chatspam")
addToggle("Kill-aura (cosmetic)", "killaura")
addToggle("Web-admin (cosmetic)", "webadmin")
addSlider("Speed", "speed", 16, 100)
addSlider("Reach", "reach", 0, 50)

-- ===== CLEANUP ON LEAVE =====
Players.PlayerRemoving:Connect(function(p) if p == LP then destroyAll(); Screen:Destroy() end end)
