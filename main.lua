local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local originalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient
}

local function rainbow()
	return Color3.fromHSV((tick() % 10) / 15,1,1)
end

local gui = Instance.new("ScreenGui")
gui.Name = "SkibidiWare"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(595,380)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderColor3 = Color3.fromRGB(75,75,75)
main.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(75,75,75)
stroke.Parent = main

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1,0,0,2)
accent.BorderSizePixel = 0
accent.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,24)
titleBar.Position = UDim2.fromOffset(0,2)
titleBar.BackgroundColor3 = Color3.fromRGB(24,24,24)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleHolder = Instance.new("Frame")
titleHolder.Size = UDim2.fromScale(1,1)
titleHolder.BackgroundTransparency = 1
titleHolder.Parent = titleBar

local skibidi = Instance.new("TextLabel")
skibidi.BackgroundTransparency = 1
skibidi.Size = UDim2.fromOffset(55,24)
skibidi.Position = UDim2.new(0.5,-42,0,0)
skibidi.Text = "SKIBIDI"
skibidi.Font = Enum.Font.ArialBold
skibidi.TextSize = 14
skibidi.TextColor3 = Color3.fromRGB(220,220,220)
skibidi.Parent = titleHolder

local ware = Instance.new("TextLabel")
ware.BackgroundTransparency = 1
ware.Size = UDim2.fromOffset(45,24)
ware.Position = UDim2.new(0.5,10,0,0)
ware.Text = "WARE"
ware.Font = Enum.Font.ArialBold
ware.TextSize = 14
ware.Parent = titleHolder

RunService.RenderStepped:Connect(function()
	local c = rainbow()
	accent.BackgroundColor3 = c
	ware.TextColor3 = c
end)

RunService.RenderStepped:Connect(function()

	local c = rainbow()

	for _,v in ipairs(workspace:GetDescendants()) do
		local esp = v:FindFirstChild("SpawnESP")

		if esp and esp:IsA("Highlight") then
			esp.FillColor = c
			esp.OutlineColor = c
		end
	end

end)

local function makeTitleButton(text,x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(18,18)
	b.Position = UDim2.new(1,x,0,3)
	b.Text = text
	b.Font = Enum.Font.ArialBold
	b.TextSize = 12
	b.TextColor3 = Color3.fromRGB(220,220,220)
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.BorderColor3 = Color3.fromRGB(70,70,70)
	b.Parent = titleBar
	return b
end

local close = makeTitleButton("X",-22)
local minimize = makeTitleButton("-",-44)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,24)
tabBar.Position = UDim2.fromOffset(0,26)
tabBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1,0,1,-50)
content.Position = UDim2.fromOffset(0,50)
content.BackgroundTransparency = 1
content.Parent = main

local minimized = false
local fullSize = main.Size

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	tabBar.Visible = not minimized
	content.Visible = not minimized
	main.Size = minimized and UDim2.fromOffset(610,26) or fullSize
end)

local dragging
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local pages = {}

local function createPage(name)
	local p = Instance.new("Frame")
	p.Size = UDim2.fromScale(1,1)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = content
	pages[name] = p
	return p
end

local function showPage(name)
	for _,v in pairs(pages) do
		v.Visible = false
	end
	pages[name].Visible = true
end

local tabs = {"Rage","Visuals","Misc","Config"}

for i,name in ipairs(tabs) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(90,24)
	b.Position = UDim2.fromOffset((i-1)*92,0)
	b.Text = name
	b.Font = Enum.Font.Arial
	b.TextSize = 12
	b.TextColor3 = Color3.fromRGB(220,220,220)
	b.BackgroundColor3 = Color3.fromRGB(24,24,24)
	b.BorderColor3 = Color3.fromRGB(70,70,70)
	b.Parent = tabBar

	createPage(name)

	b.MouseButton1Click:Connect(function()
		showPage(name)

		for _,v in ipairs(tabBar:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundColor3 = Color3.fromRGB(24,24,24)
			end
		end

		b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	end)
end

showPage("Rage")

local function group(parent,text,x,y,w,h)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(w,h)
	frame.Position = UDim2.fromOffset(x,y)
	frame.BackgroundColor3 = Color3.fromRGB(16,16,16)
	frame.BorderColor3 = Color3.fromRGB(92,92,92)
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(120,14)
	label.Position = UDim2.fromOffset(8,-7)
	label.BackgroundColor3 = Color3.fromRGB(16,16,16)
	label.Text = " "..text.." "
	label.TextColor3 = Color3.fromRGB(220,220,220)
	label.Font = Enum.Font.ArialBold
	label.TextSize = 12
	label.Parent = frame

	return frame
end

local function checkbox(parent,text,x,y,callback)
	local state = false

	local holder = Instance.new("TextButton")
	holder.Size = UDim2.fromOffset(180,16)
	holder.Position = UDim2.fromOffset(x,y)
	holder.BackgroundTransparency = 1
	holder.Text = ""
	holder.Parent = parent

	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(12,12)
	box.Position = UDim2.fromOffset(0,2)
	box.BackgroundColor3 = Color3.fromRGB(20,20,20)
	box.BorderColor3 = Color3.fromRGB(80,80,80)
	box.Parent = holder

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1,-4,1,-4)
	fill.Position = UDim2.fromOffset(2,2)
	fill.BorderSizePixel = 0
	fill.Visible = false
	fill.Parent = box

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1,-18,1,0)
	textLabel.Position = UDim2.fromOffset(18,0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.Font = Enum.Font.Arial
	textLabel.TextSize = 12
	textLabel.TextColor3 = Color3.fromRGB(220,220,220)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = holder

	RunService.RenderStepped:Connect(function()
		fill.BackgroundColor3 = rainbow()
	end)

	holder.MouseButton1Click:Connect(function()
		state = not state
		fill.Visible = state

		if callback then
			callback(state)
		end
	end)
end

local PAD = 15

local rageMain = group(pages.Rage,"Main",PAD,PAD,275,200)
local rageOther = group(pages.Rage,"Other",305,PAD,275,200)

group(pages.Visuals,"Players",PAD,PAD,275,200)

local worldGroup = group(
	pages.Visuals,
	"World",
	305,
	PAD,
	275,
	200
)

group(pages.Misc,"Movement",PAD,PAD,275,200)

local Credats = group(
	pages.Misc,
	"CREDITS",
	305,
	PAD,
	275,
	200
)

group(pages.Config,"Configs",PAD,PAD,275,200)

local settingsGroup = group(
	pages.Config,
	"Settings",
	305,
	PAD,
	275,
	200
)
-- Keybind Setting

local menuKey = Enum.KeyCode.Insert

local keybindButton = Instance.new("TextButton")
keybindButton.Size = UDim2.fromOffset(60,20)
keybindButton.Position = UDim2.fromOffset(10,20)
keybindButton.BackgroundColor3 = Color3.fromRGB(22,22,22)
keybindButton.BorderColor3 = Color3.fromRGB(80,80,80)
keybindButton.Font = Enum.Font.Arial
keybindButton.TextSize = 12
keybindButton.TextColor3 = Color3.fromRGB(220,220,220)
keybindButton.Text = "Insert"
keybindButton.Parent = settingsGroup

local waitingForKey = false

keybindButton.MouseButton1Click:Connect(function()
	waitingForKey = true
	keybindButton.Text = "..."
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	-- Listening for new bind
	if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
		menuKey = input.KeyCode
		keybindButton.Text = string.upper(menuKey.Name)
		waitingForKey = false
		return
	end

	-- Toggle menu
	if input.KeyCode == menuKey then
		gui.Enabled = not gui.Enabled
	end
end)

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.fromOffset(100,20)
keybindLabel.Position = UDim2.fromOffset(80,20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = Enum.Font.Arial
keybindLabel.TextSize = 12
keybindLabel.TextColor3 = Color3.fromRGB(220,220,220)
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Text = "Menu Keybind"
keybindLabel.Parent = settingsGroup

checkbox(worldGroup,"Fullbright",12,18,function(enabled)

	if enabled then
		Lighting.Brightness = 3
		Lighting.ClockTime = 15
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.new(1,1,1)
		Lighting.OutdoorAmbient = Color3.new(1,1,1)
	else
		Lighting.Brightness = originalLighting.Brightness
		Lighting.ClockTime = originalLighting.ClockTime
		Lighting.FogEnd = originalLighting.FogEnd
		Lighting.GlobalShadows = originalLighting.GlobalShadows
		Lighting.Ambient = originalLighting.Ambient
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
	end
end)

checkbox(worldGroup,"No Shadows",12,38,function(enabled)

	if enabled then
		Lighting.GlobalShadows = false
	else
		Lighting.GlobalShadows = true
	end

end)


checkbox(worldGroup,"Low Quality",12,58,function(enabled)

settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

checkbox(worldGroup,"Remove Materials",12,78,function(enabled)

for _,v in ipairs(workspace:GetDescendants()) do
	if v:IsA("BasePart") then
		v.Material = Enum.Material.SmoothPlastic
	end
end
end)

checkbox(worldGroup,"Show Spawns",12,98,function(enabled)

	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("SpawnLocation") then

			if enabled then

				if not v:FindFirstChild("SpawnESP") then
					local h = Instance.new("Highlight")
					h.Name = "SpawnESP"
					h.Adornee = v
					h.FillTransparency = 0.8
					h.OutlineTransparency = 1
					h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					h.Parent = v
				end

			else

				local h = v:FindFirstChild("SpawnESP")
				if h then
					h:Destroy()
				end

			end
		end
	end
end)
local rageMain = group(pages.Rage,"Main",PAD,PAD,275,200)

checkbox(rageMain, "Remove Recoil", 12, 18, function(enabled)
local RS = game.ReplicatedStorage
local modules = RS.Modules

local GunController = require(modules.Client.Controllers.GunController)

GunController.ApplyRecoil = function() end
GunController._FireScriptedRecoil = function() end

local CameraController = require(modules.Client.Controllers.CameraController)

if CameraController.Recoil then
    CameraController.Recoil = function() end
end

if CameraController.BoomKick then
    CameraController.BoomKick = function() end
end

if CameraController.SetRecoilProfile then
    CameraController.SetRecoilProfile = function() end
end
end)
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1,-20,1,-30)
credits.Position = UDim2.fromOffset(10,20)
credits.BackgroundTransparency = 1
credits.TextXAlignment = Enum.TextXAlignment.Left
credits.TextYAlignment = Enum.TextYAlignment.Top
credits.TextWrapped = true
credits.Font = Enum.Font.Code
credits.TextSize = 13
credits.TextColor3 = Color3.fromRGB(220,220,220)

credits.Text = [[
Developed by: Kvnny14

Contributors:

- ksaloll

Current Version: 0.1

Z-CORD
SKIBIDIWARE
]]

credits.Parent = Credats