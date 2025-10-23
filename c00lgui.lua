-- c00lgui - Dialoging  |  Client-side visuals
-- Educational only - all drawing stays local

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

----------------------------------
-- Settings
----------------------------------
local Sets = {
    Render = {
        Tracers   = {On=false, Color=Color3.fromRGB(100,150,255), Thick=2},
        ESP       = {On=false, Color=Color3.fromRGB(100,150,255), Thick=2},
        Chams     = {On=false, Fill=Color3.fromRGB(100,150,255), Outline=Color3.fromRGB(150,200,255)},
        Distance  = {On=false, Color=Color3.new(1,1,1)},
        Nametags  = {On=false, Color=Color3.new(1,1,1)},
        HealthBar = {On=false},
        Skeleton  = {On=false, Color=Color3.new(1,1,1)},
        FOVCircle = {On=false, Rad=100, Color=Color3.new(1,1,1)}
    },
    Combat = {
        Aimbot=false, Trigger=false, Spin=false,
        NoRecoil=false, Rapid=false, InfAmmo=false
    },
    Misc = {
        TeamCheck=true, Walk=false, Jump=false,
        Noclip=false, Fly=false, AntiAFK=false
    }
}

----------------------------------
-- ESP engine (unchanged internals)
----------------------------------
local ESPObjects, FOVC = {}, Drawing.new("Circle")
FOVC.NumSides, FOVC.Thick, FOVC.ZIndex = 64, 2, 999

local function TeamMate(p)
    return Sets.Misc.TeamCheck and p.Team==Players.LocalPlayer.Team and p.Team
end
local function NewDraw(t) return Drawing.new(t) end

local function MakeESP(p)
    if p==Players.LocalPlayer then return end
    local e = {
        P=p, Tracer=NewDraw("Line"), Dist=NewDraw("Text"), Name=NewDraw("Text"),
        BoxOut={}, BoxIn={}, Skel={}, Chams={}, HpOut=NewDraw("Square"), HpIn=NewDraw("Square")
    }
    for i=1,4 do e.BoxOut[i]=NewDraw("Line") e.BoxIn[i]=NewDraw("Line") end
    for i=1,6 do e.Skel[i]=NewDraw("Line") end
    e.Dist.Size,e.Name.Size,e.Dist.Center,e.Name.Center=14,14,true,true
    e.Dist.Outline,e.Name.Outline=true,true
    e.HpIn.Filled=true
    return e
end

local function KillESP(e)
    e.Tracer:Remove()
    for i=1,4 do e.BoxOut[i]:Remove() e.BoxIn[i]:Remove() end
    for i=1,6 do e.Skel[i]:Remove() end
    e.Dist:Remove() e.Name:Remove() e.HpOut:Remove() e.HpIn:Remove()
    for _,c in pairs(e.Chams) do pcall(function() c:Destroy() end) end
end

local function UpESP(e)
    local p,char=e.P,p.Character
    local hrp,head,hum=char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChild("Head"), char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum or hum.Health<=0 then
        e.Tracer.Visible=false
        for i=1,4 do e.BoxOut[i].Visible=false e.BoxIn[i].Visible=false end
        for i=1,6 do e.Skel[i].Visible=false end
        e.Dist.Visible=false e.Name.Visible=false e.HpOut.Visible=false e.HpIn.Visible=false
        return
    end
    local team=TeamMate(p)
    local hrp2d,vis=Camera:WorldToViewportPoint(hrp.Position)
    if not vis then
        e.Tracer.Visible=false
        for i=1,4 do e.BoxOut[i].Visible=false e.BoxIn[i].Visible=false end
        for i=1,6 do e.Skel[i].Visible=false end
        e.Dist.Visible=false e.Name.Visible=false e.HpOut.Visible=false e.HpIn.Visible=false
        return
    end
    local head2d=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,.5,0))
    local leg2d=Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
    local col=team and Color3.fromRGB(100,255,100) or Sets.Render.ESP.Color

    --Tracers
    if Sets.Render.Tracers.On and not team then
        e.Tracer.Visible=true
        e.Tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
        e.Tracer.To=Vector2.new(hrp2d.X,hrp2d.Y)
        e.Tracer.Color=Sets.Render.Tracers.Color
        e.Tracer.Thickness=Sets.Render.Tracers.Thick
    else e.Tracer.Visible=false end

    --Box
    if Sets.Render.ESP.On and not team then
        local h=math.abs(head2d.Y-leg2d.Y)
        local w=h/2
        local pts={
            Vector2.new(hrp2d.X-w/2,head2d.Y),
            Vector2.new(hrp2d.X+w/2,head2d.Y),
            Vector2.new(hrp2d.X+w/2,leg2d.Y),
            Vector2.new(hrp2d.X-w/2,leg2d.Y)
        }
        for i=1,4 do
            local n=i%4+1
            e.BoxOut[i].Visible=true e.BoxIn[i].Visible=true
            e.BoxOut[i].From=pts[i] e.BoxOut[i].To=pts[n] e.BoxOut[i].Color=Color3.new(0,0,0) e.BoxOut[i].Thickness=Sets.Render.ESP.Thick+1
            e.BoxIn[i].From=pts[i] e.BoxIn[i].To=pts[n] e.BoxIn[i].Color=col e.BoxIn[i].Thickness=Sets.Render.ESP.Thick
        end
        --Health
        if Sets.Render.HealthBar.On then
            local pct=hum.Health/hum.MaxHealth
            e.HpOut.Visible=true e.HpIn.Visible=true
            e.HpOut.Size=Vector2.new(3,h) e.HpOut.Position=Vector2.new(pts[4].X-8,head2d.Y) e.HpOut.Color=Color3.new(0,0,0)
            e.HpIn.Size=Vector2.new(2,h*pct) e.HpIn.Position=Vector2.new(pts[4].X-7.5,head2d.Y+h*(1-pct)) e.HpIn.Color=Color3.fromRGB(255*(1-pct),255*pct,0)
        else e.HpOut.Visible=false e.HpIn.Visible=false end
    else
        for i=1,4 do e.BoxOut[i].Visible=false e.BoxIn[i].Visible=false end
        e.HpOut.Visible=false e.HpIn.Visible=false
    end

    --Skeleton
    if Sets.Render.Skeleton.On and not team then
        local torso=char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local la=char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local ra=char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        local ll=char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
        local rl=char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
        if torso and la and ra and ll and rl then
            local bones={{head,torso},{torso,la},{torso,ra},{torso,ll},{torso,rl}}
            for i=1,5 do
                local p1,p2=bones[i][1],bones[i][2]
                local v1,v2=Camera:WorldToViewportPoint(p1.Position),Camera:WorldToViewportPoint(p2.Position)
                if v1.Z>0 and v2.Z>0 then
                    e.Skel[i].Visible=true e.Skel[i].From=Vector2.new(v1.X,v1.Y) e.Skel[i].To=Vector2.new(v2.X,v2.Y) e.Skel[i].Color=Sets.Render.Skeleton.Color e.Skel[i].Thickness=1
                else e.Skel[i].Visible=false end
            end
        end
    else for i=1,6 do e.Skel[i].Visible=false end end

    --Distance
    if Sets.Render.Distance.On and not team then
        e.Dist.Visible=true e.Dist.Position=Vector2.new(hrp2d.X,leg2d.Y+5) e.Dist.Text=("%.0f studs"):format((LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude) e.Dist.Color=Sets.Render.Distance.Color
    else e.Dist.Visible=false end

    --Nametags
    if Sets.Render.Nametags.On and not team then
        e.Name.Visible=true e.Name.Position=Vector2.new(hrp2d.X,head2d.Y-15) e.Name.Text=p.Name e.Name.Color=Sets.Render.Nametags.Color
    else e.Name.Visible=false end

    --Chams
    if Sets.Render.Chams.On and not team then
        for _,part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and not e.Chams[part] then
                local h=Instance.new("Highlight") h.Adornee=part h.FillColor=Sets.Render.Chams.Fill h.OutlineColor=Sets.Render.Chams.Outline h.FillTransparency=0.5 h.OutlineTransparency=0 h.Parent=part e.Chams[part]=h
            end
        end
    else
        for part,cham in pairs(e.Chams) do pcall(function() cham:Destroy() end) e.Chams[part]=nil end
    end
end

Players.PlayerAdded:Connect(function(p) ESPObjects[p]=MakeESP(p) end)
Players.PlayerRemoving:Connect(function(p) if ESPObjects[p] then KillESP(ESPObjects[p]) ESPObjects[p]=nil end end)
for _,p in pairs(Players:GetPlayers()) do ESPObjects[p]=MakeESP(p) end

RunService.RenderStepped:Connect(function()
    FOVC.Visible=Sets.Render.FOVCircle.On
    if FOVC.Visible then
        FOVC.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
        FOVC.Radius=Sets.Render.FOVCircle.Rad
        FOVC.Color=Sets.Render.FOVCircle.Color
    end
    for p,e in pairs(ESPObjects) do if p and p.Parent then UpESP(e) end end
end)

----------------------------------
-- GUI (c00lgui – Dialoging style)
----------------------------------
local gui=Instance.new("ScreenGui",game.CoreGui) gui.Name="c00lgui_Dialoging"
local main=Instance.new("Frame") main.Size=UDim2.new(0,420,0,360) main.Position=UDim2.new(0.5,-210,0.5,-180)
main.BackgroundColor3=Color3.fromRGB(20,20,20) main.BorderSizePixel=0 main.Active=true main.Draggable=true main.Parent=gui
Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)

local top=Instance.new("Frame") top.Size=UDim2.new(1,0,0,36) top.BackgroundColor3=Color3.fromRGB(35,35,35) top.BorderSizePixel=0 top.Parent=main
Instance.new("UICorner",top).CornerRadius=UDim.new(0,12)
local ttl=Instance.new("TextLabel") ttl.Size=UDim2.new(1,-40,1,0) ttl.Position=UDim2.new(0,10,0,0)
ttl.BackgroundTransparency=1 ttl.Text="c00lgui - Dialoging" ttl.TextColor3=Color3.new(1,1,1) ttl.TextSize=16
ttl.Font=Enum.Font.GothamSemibold ttl.TextXAlignment=Enum.TextXAlignment.Left ttl.Parent=top

local xb=Instance.new("TextButton") xb.Size=UDim2.new(0,24,0,24) xb.Position=UDim2.new(1,-30,0,6)
xb.BackgroundColor3=Color3.fromRGB(255,70,70) xb.Text="×" xb.TextColor3=Color3.new(1,1,1) xb.TextSize=18
xb.Font=Enum.Font.GothamBold xb.Parent=top Instance.new("UICorner",xb).CornerRadius=UDim.new(0,6)
xb.MouseButton1Click:Connect(function() gui:Destroy() end)

local tbar=Instance.new("Frame") tbar.Size=UDim2.new(1,-20,0,30) tbar.Position=UDim2.new(0,10,0,40)
tbar.BackgroundTransparency=1 tbar.Parent=main
local tlay=Instance.new("UIListLayout",tbar) tlay.FillDirection=Enum.FillDirection.Horizontal tlay.Padding=UDim.new(0,6)

local cview=Instance.new("Frame") cview.Size=UDim2.new(1,-20,1,-80) cview.Position=UDim2.new(0,10,0,70)
cview.BackgroundTransparency=1 cview.ClipsDescendants=true cview.Parent=main

local tabs,frames={},{}
local function Tab(name)
    local b=Instance.new("TextButton") b.Size=UDim2.new(0,70,1,0) b.BackgroundColor3=Color3.fromRGB(30,30,30)
    b.Text=name b.TextColor3=Color3.new(1,1,1) b.TextSize=13 b.Font=Enum.Font.Gotham b.Parent=tbar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local f=Instance.new("ScrollingFrame") f.Size=UDim2.new(1,0,1,0) f.BackgroundTransparency=1
    f.ScrollBarThickness=0 f.Visible=false f.Parent=cview
    local l=Instance.new("UIListLayout",f) l.Padding=UDim.new(0,6)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+10)
    end)
    b.MouseButton1Click:Connect(function()
        for _,v in pairs(frames) do v.Visible=false end
        for _,v in pairs(tabs) do v.BackgroundColor3=Color3.fromRGB(30,30,30) end
        f.Visible=true b.BackgroundColor3=Color3.fromRGB(60,60,60)
    end)
    table.insert(tabs,b) table.insert(frames,f) return f
end

local renTab=Tab("Render")
local comTab=Tab("Combat")
local misTab=Tab("Misc")
local setTab=Tab("Settings")

----------------------------------
-- Controls
----------------------------------
local function Toggle(parent,txt,tbl)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,-8,0,28) f.BackgroundColor3=Color3.fromRGB(30,30,30)
    f.BorderSizePixel=0 f.Parent=parent Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-60,1,0) l.Position=UDim2.new(0,8,0,0)
    l.BackgroundTransparency=1 l.Text=txt l.TextColor3=Color3.new(1,1,1) l.TextSize=13
    l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
    local b=Instance.new("TextButton") b.Size=UDim2.new(0,46,0,20) b.Position=UDim2.new(1,-52,0.5,-10)
    b.BackgroundColor3=tbl.On and Color3.fromRGB(0,170,255) or Color3.fromRGB(50,50,50)
    b.Text=tbl.On and "ON" or "OFF" b.TextColor3=Color3.new(1,1,1) b.TextSize=12
    b.Font=Enum.Font.GothamBold b.Parent=f Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    b.MouseButton1Click:Connect(function()
        tbl.On=not tbl.On
        b.Text=tbl.On and "ON" or "OFF"
        b.BackgroundColor3=tbl.On and Color3.fromRGB(0,170,255) or Color3.fromRGB(50,50,50)
    end)
end

local function Slider(parent,txt,min,max,val,callback)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,-8,0,28) f.BackgroundColor3=Color3.fromRGB(30,30,30)
    f.BorderSizePixel=0 f.Parent=parent Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-60,1,0) l.Position=UDim2.new(0,8,0,0)
    l.BackgroundTransparency=1 l.Text=txt l.TextColor3=Color3.new(1,1,1) l.TextSize=13
    l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
    local box=Instance.new("TextBox") box.Size=UDim2.new(0,46,0,20) box.Position=UDim2.new(1,-52,0.5,-10)
    box.BackgroundColor3=Color3.fromRGB(20,20,20) box.Text=tostring(val) box.TextColor3=Color3.new(1,1,1)
    box.TextSize=12 box.Font=Enum.Font.Gotham box.ClearTextOnFocus=false box.Parent=f
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
    box.FocusLost:Connect(function()
        local n=tonumber(box.Text) or val
        n=math.clamp(n,min,max) box.Text=tostring(n) callback(n)
    end)
end

----------------------------------
-- Fill tabs
----------------------------------
do -- Render
    Toggle(renTab,"Tracers",  Sets.Render.Tracers)
    Toggle(renTab,"ESP Boxes",Sets.Render.ESP)
    Toggle(renTab,"Chams",    Sets.Render.Chams)
    Toggle(renTab,"Distance", Sets.Render.Distance)
    Toggle(renTab,"Nametags", Sets.Render.Nametags)
    Toggle(renTab,"HealthBar",Sets.Render.HealthBar)
    Toggle(renTab,"Skeleton", Sets.Render.Skeleton)
    Toggle(renTab,"FOV Circle",Sets.Render.FOVCircle)
end
do -- Combat
    Toggle(comTab,"Aimbot",     Sets.Combat.Aimbot)
    Toggle(comTab,"Trigger",    Sets.Combat.Trigger)
    Toggle(comTab,"Spin",       Sets.Combat.Spin)
    Toggle(comTab,"No Recoil",  Sets.Combat.NoRecoil)
    Toggle(comTab,"Rapid Fire", Sets.Combat.Rapid)
    Toggle(comTab,"Inf Ammo",   Sets.Combat.InfAmmo)
end
do -- Misc
    Toggle(misTab,"Team Check",Sets.Misc.TeamCheck)
    Toggle(misTab,"WalkSpeed", Sets.Misc.Walk)
    Toggle(misTab,"JumpPower", Sets.Misc.Jump)
    Toggle(misTab,"Noclip",    Sets.Misc.Noclip)
    Toggle(misTab,"Fly",       Sets.Misc.Fly)
    Toggle(misTab,"Anti AFK",  Sets.Misc.AntiAFK)
end
do -- Settings
    Slider(setTab,"ESP Thick",  1,5,Sets.Render.ESP.Thick,     function(v) Sets.Render.ESP.Thick=v end)
    Slider(setTab,"Tracer Thick",1,5,Sets.Render.Tracers.Thick, function(v) Sets.Render.Tracers.Thick=v end)
    Slider(setTab,"FOV Radius", 30,300,Sets.Render.FOVCircle.Rad,function(v) Sets.Render.FOVCircle.Rad=v end)
end

----------------------------------
-- open Render by default
----------------------------------
tabs[1].BackgroundColor3=Color3.fromRGB(60,60,60) frames[1].Visible=true

----------------------------------
-- Toggle with RightShift
----------------------------------
UserInputService.InputBegan:Connect(function(inp,g)
    if not g and inp.KeyCode==Enum.KeyCode.RightShift then main.Visible=not main.Visible end
end)
