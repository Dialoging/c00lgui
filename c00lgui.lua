local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "c00lgui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 360) -- Adjusted size to better fit image proportions
Main.Position = UDim2.new(0.5, -250, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background
Main.BorderSizePixel = 1
Main.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Red border
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local TopLeftHeader = Instance.new("TextLabel")
TopLeftHeader.Size = UDim2.new(0.5, 0, 0, 30)
TopLeftHeader.Position = UDim2.new(0, 0, 0, 0)
TopLeftHeader.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopLeftHeader.BorderColor3 = Color3.fromRGB(255, 0, 0)
TopLeftHeader.BorderSizePixel = 1
TopLeftHeader.Text = "c00lgui - Dialoging"
TopLeftHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
TopLeftHeader.TextSize = 14
TopLeftHeader.Font = Enum.Font.SourceSansBold
TopLeftHeader.TextScaled = false
TopLeftHeader.Parent = Main

local TopRightHeader = Instance.new("TextLabel")
TopRightHeader.Size = UDim2.new(0.5, 0, 0, 30)
TopRightHeader.Position = UDim2.new(0.5, 0, 0, 0)
TopRightHeader.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopRightHeader.BorderColor3 = Color3.fromRGB(255, 0, 0)
TopRightHeader.BorderSizePixel = 1
TopRightHeader.Text = "Settings"
TopRightHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
TopRightHeader.TextSize = 14
TopRightHeader.Font = Enum.Font.SourceSansBold
TopRightHeader.TextScaled = false
TopRightHeader.Parent = Main

-- Left Navigation (< >)
local LeftNavFrame = Instance.new("Frame")
LeftNavFrame.Size = UDim2.new(0.5, 0, 0, 30)
LeftNavFrame.Position = UDim2.new(0, 0, 0, 30)
LeftNavFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LeftNavFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
LeftNavFrame.BorderSizePixel = 1
LeftNavFrame.Parent = Main

local LeftNavLayout = Instance.new("UIListLayout")
LeftNavLayout.FillDirection = Enum.FillDirection.Horizontal
LeftNavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
LeftNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
LeftNavLayout.Parent = LeftNavFrame

local LeftArrow = Instance.new("TextButton")
LeftArrow.Size = UDim2.new(0, 20, 1, 0)
LeftArrow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LeftArrow.BorderColor3 = Color3.fromRGB(255, 0, 0)
LeftArrow.BorderSizePixel = 0
LeftArrow.Text = "<"
LeftArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
LeftArrow.TextSize = 18
LeftArrow.Font = Enum.Font.SourceSansBold
LeftArrow.Parent = LeftNavFrame

local RightArrow = Instance.new("TextButton")
RightArrow.Size = UDim2.new(0, 20, 1, 0)
RightArrow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightArrow.BorderColor3 = Color3.fromRGB(255, 0, 0)
RightArrow.BorderSizePixel = 0
RightArrow.Text = ">"
RightArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
RightArrow.TextSize = 18
RightArrow.Font = Enum.Font.SourceSansBold
RightArrow.Parent = LeftNavFrame

-- Right Navigation (< >)
local RightNavFrame = Instance.new("Frame")
RightNavFrame.Size = UDim2.new(0.5, 0, 0, 30)
RightNavFrame.Position = UDim2.new(0.5, 0, 0, 30)
RightNavFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightNavFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
RightNavFrame.BorderSizePixel = 1
RightNavFrame.Parent = Main

local RightNavLayout = Instance.new("UIListLayout")
RightNavLayout.FillDirection = Enum.FillDirection.Horizontal
RightNavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
RightNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
RightNavLayout.Parent = RightNavFrame

local RightLeftArrow = Instance.new("TextButton")
RightLeftArrow.Size = UDim2.new(0, 20, 1, 0)
RightLeftArrow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightLeftArrow.BorderColor3 = Color3.fromRGB(255, 0, 0)
RightLeftArrow.BorderSizePixel = 0
RightLeftArrow.Text = "<"
RightLeftArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
RightLeftArrow.TextSize = 18
RightLeftArrow.Font = Enum.Font.SourceSansBold
RightLeftArrow.Parent = RightNavFrame

local RightRightArrow = Instance.new("TextButton")
RightRightArrow.Size = UDim2.new(0, 20, 1, 0)
RightRightArrow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightRightArrow.BorderColor3 = Color3.fromRGB(255, 0, 0)
RightRightArrow.BorderSizePixel = 0
RightRightArrow.Text = ">"
RightRightArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
RightRightArrow.TextSize = 18
RightRightArrow.Font = Enum.Font.SourceSansBold
RightRightArrow.Parent = RightNavFrame

-- Content Grid for Weapon Scripts / Gear Tools (Left Side)
local LeftContentGrid = Instance.new("Frame")
LeftContentGrid.Size = UDim2.new(0.5, 0, 1, -120) -- Takes up 50% width, adjusted height
LeftContentGrid.Position = UDim2.new(0, 0, 0, 60)
LeftContentGrid.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LeftContentGrid.BorderColor3 = Color3.fromRGB(255, 0, 0)
LeftContentGrid.BorderSizePixel = 1
LeftContentGrid.Parent = Main

local LeftGridLayout = Instance.new("UIGridLayout")
LeftGridLayout.CellSize = UDim2.new(0.5, 0, 0, 30) -- Two columns, fixed height cells
LeftGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
LeftGridLayout.StartCorner = Enum.StartCorner.TopLeft
LeftGridLayout.FillDirection = Enum.FillDirection.Horizontal
LeftGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
LeftGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
LeftGridLayout.Parent = LeftContentGrid

local function createGridButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0) -- Fill cell
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    btn.BorderSizePixel = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSans
    btn.Parent = parent
    return btn
end

-- Populate Left Content Grid
createGridButton("Weapon Scripts", LeftContentGrid)
createGridButton("GearTools", LeftContentGrid)
createGridButton("xBow", LeftContentGrid)
createGridButton("Wand", LeftContentGrid)
createGridButton("Custom Gear", LeftContentGrid)
createGridButton("Stamper Tools", LeftContentGrid)
createGridButton("Drage", LeftContentGrid)
createGridButton("Dual Blades", LeftContentGrid)
createGridButton("Tool Stealer", LeftContentGrid)
createGridButton("Insert Tool", LeftContentGrid)
createGridButton("Eyelinser", LeftContentGrid)
createGridButton("Knife", LeftContentGrid)
createGridButton("Minigun", LeftContentGrid)
createGridButton("Laser Rifle", LeftContentGrid)
createGridButton("Lightsaber", LeftContentGrid)
createGridButton("Master Hand", LeftContentGrid)
createGridButton("Draw Tool", LeftContentGrid)
-- Blank cell to fill the row
createGridButton("", LeftContentGrid).BackgroundTransparency = 1 
createGridButton("Staff", LeftContentGrid)
createGridButton("Techno Gauntiet", LeftContentGrid)
-- Blank cell to fill the row
createGridButton("", LeftContentGrid).BackgroundTransparency = 1 
createGridButton("", LeftContentGrid).BackgroundTransparency = 1 
createGridButton("Plane", LeftContentGrid)
createGridButton("Snowball", LeftContentGrid)
-- Blank cell to fill the row
createGridButton("", LeftContentGrid).BackgroundTransparency = 1 
createGridButton("", LeftContentGrid).BackgroundTransparency = 1 
createGridButton("Suicide Vest", LeftContentGrid)
createGridButton("Lance", LeftContentGrid)

-- Content Grid for Settings (Right Side)
local RightContentGrid = Instance.new("Frame")
RightContentGrid.Size = UDim2.new(0.5, 0, 1, -120) -- Takes up 50% width, adjusted height
RightContentGrid.Position = UDim2.new(0.5, 0, 0, 60)
RightContentGrid.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightContentGrid.BorderColor3 = Color3.fromRGB(255, 0, 0)
RightContentGrid.BorderSizePixel = 1
RightContentGrid.Parent = Main

local RightGridLayout = Instance.new("UIGridLayout")
RightGridLayout.CellSize = UDim2.new(0.5, 0, 0, 30) -- Two columns, fixed height cells
RightGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
RightGridLayout.StartCorner = Enum.StartCorner.TopLeft
RightGridLayout.FillDirection = Enum.FillDirection.Horizontal
RightGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
RightGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
RightGridLayout.Parent = RightContentGrid

-- Populate Right Content Grid
createGridButton("Billboard Gui Color", RightContentGrid)
local colorInputs = {
    createGridButton("0", RightContentGrid),
    createGridButton("255", RightContentGrid),
    createGridButton("0", RightContentGrid)
}
-- Setting 'Name' takes up 3 columns visually
local nameBtn = createGridButton("Name", RightContentGrid)
nameBtn.LayoutOrder = 1 -- Ensure it's placed correctly

createGridButton("Anti Robloxian Range", RightContentGrid)
createGridButton("12", RightContentGrid)
createGridButton("Chat Spam Text", RightContentGrid)
createGridButton("Join team c00lkid!", RightContentGrid)

createGridButton("Leaderstat Name", RightContentGrid)
createGridButton("Leaderstat Amount", RightContentGrid)
createGridButton("KOs", RightContentGrid)
createGridButton("1", RightContentGrid)

createGridButton("Walkspeed Amount", RightContentGrid)
createGridButton("50", RightContentGrid)
-- Blank cells to fill remaining space
createGridButton("", RightContentGrid).BackgroundTransparency = 1
createGridButton("", RightContentGrid).BackgroundTransparency = 1
createGridButton("", RightContentGrid).BackgroundTransparency = 1
createGridButton("", RightContentGrid).BackgroundTransparency = 1

-- Page numbers and action buttons at the bottom
local BottomFrame = Instance.new("Frame")
BottomFrame.Size = UDim2.new(1, 0, 0, 60)
BottomFrame.Position = UDim2.new(0, 0, 1, -60)
BottomFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BottomFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
BottomFrame.BorderSizePixel = 1
BottomFrame.Parent = Main

local BottomGridLayout = Instance.new("UIGridLayout")
BottomGridLayout.CellSize = UDim2.new(0.25, 0, 0.5, 0) -- 4 columns, 2 rows
BottomGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
BottomGridLayout.StartCorner = Enum.StartCorner.TopLeft
BottomGridLayout.FillDirection = Enum.FillDirection.Horizontal
BottomGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
BottomGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
BottomGridLayout.Parent = BottomFrame

createGridButton("Page 2", BottomFrame)
createGridButton("Page 2", BottomFrame) -- This looks like an error in the image, but replicating

local CloseButton = createGridButton("Close", BottomFrame)
CloseButton.TextSize = 16
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local SaveIDsButton = createGridButton("Save IDs", BottomFrame)
SaveIDsButton.TextSize = 16

local LoadIDsButton = createGridButton("Load IDs", BottomFrame)
LoadIDsButton.TextSize = 16

-- Right-side scroll indicator, just a visual line
local ScrollIndicator = Instance.new("Frame")
ScrollIndicator.Size = UDim2.new(0, 10, 1, -60) -- Thin vertical frame
ScrollIndicator.Position = UDim2.new(1, -10, 0, 60)
ScrollIndicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScrollIndicator.BorderColor3 = Color3.fromRGB(255, 0, 0)
ScrollIndicator.BorderSizePixel = 1
ScrollIndicator.Parent = Main

local ScrollArrowUp = Instance.new("TextLabel")
ScrollArrowUp.Size = UDim2.new(1, 0, 0, 20)
ScrollArrowUp.Position = UDim2.new(0, 0, 0, 0)
ScrollArrowUp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScrollArrowUp.BorderColor3 = Color3.fromRGB(255, 0, 0)
ScrollArrowUp.BorderSizePixel = 0
ScrollArrowUp.Text = "<" -- Rotated arrow (visual)
ScrollArrowUp.TextColor3 = Color3.fromRGB(255, 255, 255)
ScrollArrowUp.TextSize = 16
ScrollArrowUp.Font = Enum.Font.SourceSansBold
ScrollArrowUp.Rotation = 90 -- Visually rotate
ScrollArrowUp.Parent = ScrollIndicator

local ScrollArrowDown = Instance.new("TextLabel")
ScrollArrowDown.Size = UDim2.new(1, 0, 0, 20)
ScrollArrowDown.Position = UDim2.new(0, 0, 1, -20)
ScrollArrowDown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScrollArrowDown.BorderColor3 = Color3.fromRGB(255, 0, 0)
ScrollArrowDown.BorderSizePixel = 0
ScrollArrowDown.Text = "<" -- Rotated arrow (visual)
ScrollArrowDown.TextColor3 = Color3.fromRGB(255, 255, 255)
ScrollArrowDown.TextSize = 16
ScrollArrowDown.Font = Enum.Font.SourceSansBold
ScrollArrowDown.Rotation = -90 -- Visually rotate
ScrollArrowDown.Parent = ScrollIndicator


-- Toggle GUI visibility with Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
