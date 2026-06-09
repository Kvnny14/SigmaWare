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

local close    = makeTitleButton("X",-22)
local minimize = makeTitleButton("-",-44)

close.MouseButton1Click:Connect(function() gui:Destroy() end)

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

local dragging, dragStart, startPos

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
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
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
	for _,v in pairs(pages) do v.Visible = false end
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
			if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(24,24,24) end
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

-- Returns the holder so callers can control visibility
local function checkbox(parent, text, x, y, callback)
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
		if callback then callback(state) end
	end)

	return holder
end

-- Draggable slider. Returns holder frame.
local function slider(parent, text, x, y, minVal, maxVal, defaultVal, callback)
	local TRACK_W = 220
	local TRACK_H = 4
	local KNOB    = 10

	local currentVal = defaultVal
	local draggingSlider = false

	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(TRACK_W, 30)
	holder.Position = UDim2.fromOffset(x, y)
	holder.BackgroundTransparency = 1
	holder.Parent = parent

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.fromOffset(TRACK_W, 14)
	labelText.BackgroundTransparency = 1
	labelText.Font = Enum.Font.Arial
	labelText.TextSize = 12
	labelText.TextColor3 = Color3.fromRGB(220,220,220)
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Text = text..": "..defaultVal
	labelText.Parent = holder

	local track = Instance.new("Frame")
	track.Size = UDim2.fromOffset(TRACK_W, TRACK_H)
	track.Position = UDim2.fromOffset(0, 20)
	track.BackgroundColor3 = Color3.fromRGB(50,50,50)
	track.BorderColor3 = Color3.fromRGB(80,80,80)
	track.ClipsDescendants = false
	track.Parent = holder

	local fillBar = Instance.new("Frame")
	fillBar.Size = UDim2.fromScale((defaultVal - minVal)/(maxVal - minVal), 1)
	fillBar.BorderSizePixel = 0
	fillBar.Parent = track

	RunService.RenderStepped:Connect(function()
		fillBar.BackgroundColor3 = rainbow()
	end)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(KNOB, KNOB)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
	knob.BorderColor3 = Color3.fromRGB(100,100,100)
	knob.Parent = track

	local function applyMouse(mouseX)
		local abs = track.AbsolutePosition.X
		local sz  = track.AbsoluteSize.X
		local pct = math.clamp((mouseX - abs) / sz, 0, 1)
		currentVal = math.floor(minVal + pct * (maxVal - minVal))
		knob.Position = UDim2.new(pct, 0, 0.5, 0)
		fillBar.Size  = UDim2.fromScale(pct, 1)
		labelText.Text = text..": "..currentVal
		if callback then callback(currentVal) end
	end

	-- Start drag from knob OR track click
	knob.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
		end
	end)
	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			applyMouse(inp.Position.X)
		end
	end)

	-- Global release so drag ends even if mouse left knob
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
		end
	end)

	-- Move while dragging
	UIS.InputChanged:Connect(function(inp)
		if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
			applyMouse(inp.Position.X)
		end
	end)

	return holder
end

local PAD = 15

-- ======= RAGE PAGE =======
local rageMain  = group(pages.Rage,"Main",PAD,PAD,275,200)
local rageOther = group(pages.Rage,"Other",305,PAD,275,200)

-- ======= VISUALS PAGE =======
local playersGroup = group(pages.Visuals,"Players",PAD,PAD,275,200)
local worldGroup   = group(pages.Visuals,"World",305,PAD,275,200)

-- ESP state
local espEnabled    = false
local espConnections = {}
local espHighlights  = {}
local showNames     = false
local showDistance  = false
local showHealthBar = false
local showHeadDot   = false
local showBoxESP    = false

-- Sub-option holders (hidden until ESP master is on)
local espSubOptions = {}

local function setSubOptionsVisible(v)
	for _, h in ipairs(espSubOptions) do
		h.Visible = v
	end
end

local function removeESP(character)
	if not espHighlights[character] then return end
	for _, v in pairs(espHighlights[character]) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		elseif v and v.Parent then
			v:Destroy()
		end
	end
	espHighlights[character] = nil
end

local function applyESP(p)
	local character = p.Character
	if not character then return end
	if espHighlights[character] then return end
	espHighlights[character] = {}

	local hrp = character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChildWhichIsA("BasePart")

	-- Highlight glow
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerESP"
	highlight.Adornee = character
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character
	table.insert(espHighlights[character], highlight)

	-- Name billboard (above head)
	local nameBB = Instance.new("BillboardGui")
	nameBB.Name = "ESPNameBillboard"
	nameBB.Size = UDim2.fromOffset(120,16)
	nameBB.StudsOffset = Vector3.new(0, 3.4, 0)
	nameBB.AlwaysOnTop = true
	nameBB.Adornee = hrp
	nameBB.Enabled = showNames
	nameBB.Parent = character

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1,1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.ArialBold
	nameLabel.TextSize = 13
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
	nameLabel.Text = p.Name
	nameLabel.Parent = nameBB
	table.insert(espHighlights[character], nameBB)

	-- Distance billboard (below feet)
	local distBB = Instance.new("BillboardGui")
	distBB.Name = "ESPDistBillboard"
	distBB.Size = UDim2.fromOffset(80,14)
	distBB.StudsOffset = Vector3.new(0, -3.4, 0)
	distBB.AlwaysOnTop = true
	distBB.Adornee = hrp
	distBB.Enabled = showDistance
	distBB.Parent = character

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.fromScale(1,1)
	distLabel.BackgroundTransparency = 1
	distLabel.Font = Enum.Font.Arial
	distLabel.TextSize = 11
	distLabel.TextStrokeTransparency = 0.3
	distLabel.TextColor3 = Color3.fromRGB(200,200,200)
	distLabel.Text = "0m"
	distLabel.Parent = distBB
	table.insert(espHighlights[character], distBB)

	-- Head dot — tiny circle on top of Head part
	local head = character:FindFirstChild("Head")
	if head then
		local headDotBB = Instance.new("BillboardGui")
		headDotBB.Name = "ESPHeadDot"
		-- Size relative to the head (small)
		headDotBB.Size = UDim2.fromOffset(6, 6)
		headDotBB.StudsOffset = Vector3.new(0, 0.35, 0)
		headDotBB.AlwaysOnTop = true
		headDotBB.Adornee = head
		headDotBB.Enabled = showHeadDot
		headDotBB.Parent = character

		local dot = Instance.new("Frame")
		dot.Size = UDim2.fromScale(1,1)
		dot.BackgroundColor3 = Color3.fromRGB(255,60,60)
		dot.BackgroundTransparency = 0.6
		dot.BorderSizePixel = 0
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1,0)
		corner.Parent = dot
		dot.Parent = headDotBB
		table.insert(espHighlights[character], headDotBB)
	end

	-- Health bar — slim vertical bar to the left (2px wide, 24px tall)
	local healthBB = Instance.new("BillboardGui")
	healthBB.Name = "ESPHealthBar"
	healthBB.Size = UDim2.fromOffset(2, 24)
	healthBB.StudsOffset = Vector3.new(-1.1, 0, 0)
	healthBB.AlwaysOnTop = true
	healthBB.Adornee = hrp
	healthBB.Enabled = showHealthBar
	healthBB.Parent = character

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.fromScale(1,1)
	barBg.BackgroundColor3 = Color3.fromRGB(30,30,30)
	barBg.BorderSizePixel = 0
	barBg.Parent = healthBB

	local barFill = Instance.new("Frame")
	barFill.Name = "HealthFill"
	barFill.Size = UDim2.fromScale(1,1)
	barFill.BackgroundColor3 = Color3.fromRGB(80,255,80)
	barFill.BorderSizePixel = 0
	barFill.AnchorPoint = Vector2.new(0,1)
	barFill.Position = UDim2.fromScale(0,1)
	barFill.Parent = barBg
	table.insert(espHighlights[character], healthBB)

	-- Box ESP — 2D screen-space box drawn with 4 thin frames inside a ScreenGui
	-- We use a BillboardGui sized to the character bounding box as an approximation
	local boxBB = Instance.new("BillboardGui")
	boxBB.Name = "ESPBoxBillboard"
	-- Cover roughly the player silhouette (3 studs tall, 1.5 wide)
	boxBB.Size = UDim2.fromOffset(28, 48)
	boxBB.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
	boxBB.AlwaysOnTop = true
	boxBB.Adornee = hrp
	boxBB.Enabled = showBoxESP
	boxBB.Parent = character

	local T = 1 -- border thickness in px
	local boxColor = Color3.fromRGB(255,255,255)

	local function makeLine(sx,sy,px,py)
		local l = Instance.new("Frame")
		l.Size = UDim2.fromOffset(sx,sy)
		l.Position = UDim2.fromOffset(px,py)
		l.BackgroundColor3 = boxColor
		l.BorderSizePixel = 0
		l.Parent = boxBB
		return l
	end

	local topBar    = makeLine(28, T, 0, 0)
	local botBar    = makeLine(28, T, 0, 48-T)
	local leftBar   = makeLine(T, 48, 0, 0)
	local rightBar  = makeLine(T, 48, 28-T, 0)

	RunService.RenderStepped:Connect(function()
		local c = rainbow()
		topBar.BackgroundColor3  = c
		botBar.BackgroundColor3  = c
		leftBar.BackgroundColor3 = c
		rightBar.BackgroundColor3 = c
	end)

	table.insert(espHighlights[character], boxBB)

	-- Per-frame updater (distance + health)
	local conn = RunService.RenderStepped:Connect(function()
		if not character or not character.Parent then return end

		if showDistance then
			local lchar = Players.LocalPlayer.Character
			local lroot = lchar and lchar:FindFirstChild("HumanoidRootPart")
			local eroot = character:FindFirstChild("HumanoidRootPart")
			if lroot and eroot then
				distLabel.Text = math.floor((lroot.Position - eroot.Position).Magnitude).."m"
			end
		end

		local hum = character:FindFirstChildWhichIsA("Humanoid")
		if hum then
			local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			local r = math.floor(255*(1-pct))
			local g = math.floor(255*pct)
			highlight.FillColor = Color3.fromRGB(r,g,0)
			barFill.Size = UDim2.new(1,0,pct,0)
			barFill.BackgroundColor3 = Color3.fromRGB(r,g,0)
		end
	end)
	table.insert(espHighlights[character], conn)
end

local function enableESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer then
			applyESP(p)
			local c1 = p.CharacterAdded:Connect(function()
				task.wait(0.5) applyESP(p)
			end)
			local c2 = p.CharacterRemoving:Connect(function(char)
				removeESP(char)
			end)
			table.insert(espConnections, c1)
			table.insert(espConnections, c2)
		end
	end
	local c3 = Players.PlayerAdded:Connect(function(p)
		if p ~= Players.LocalPlayer then
			p.CharacterAdded:Connect(function()
				task.wait(0.5) applyESP(p)
			end)
		end
	end)
	table.insert(espConnections, c3)
end

local function disableESP()
	for _, conn in pairs(espConnections) do
		if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
	end
	espConnections = {}
	for character in pairs(espHighlights) do removeESP(character) end
	espHighlights = {}
end

local function refreshESPComponents()
	for character in pairs(espHighlights) do
		local nb = character:FindFirstChild("ESPNameBillboard")
		if nb then nb.Enabled = showNames end
		local db = character:FindFirstChild("ESPDistBillboard")
		if db then db.Enabled = showDistance end
		local hb = character:FindFirstChild("ESPHealthBar")
		if hb then hb.Enabled = showHealthBar end
		local hd = character:FindFirstChild("ESPHeadDot")
		if hd then hd.Enabled = showHeadDot end
		local bx = character:FindFirstChild("ESPBoxBillboard")
		if bx then bx.Enabled = showBoxESP end
	end
end

-- Master ESP toggle
checkbox(playersGroup, "Player ESP", 12, 18, function(enabled)
	espEnabled = enabled
	setSubOptionsVisible(enabled)
	if enabled then enableESP() else disableESP() end
end)

-- Sub-options (hidden by default, shown when ESP is on)
-- Box ESP is first, then the rest
local h5 = checkbox(playersGroup, "Box ESP",    12, 38, function(enabled) showBoxESP = enabled;    refreshESPComponents() end)
local h1 = checkbox(playersGroup, "Names",      12, 58, function(enabled) showNames = enabled;     refreshESPComponents() end)
local h2 = checkbox(playersGroup, "Distance",   12, 78, function(enabled) showDistance = enabled;  refreshESPComponents() end)
local h3 = checkbox(playersGroup, "Health Bar", 12, 98, function(enabled) showHealthBar = enabled; refreshESPComponents() end)
local h4 = checkbox(playersGroup, "Head Dot",   12,118, function(enabled) showHeadDot = enabled;   refreshESPComponents() end)

for _, h in ipairs({h1,h2,h3,h4,h5}) do
	h.Visible = false
	table.insert(espSubOptions, h)
end

-- World group
checkbox(worldGroup, "Fullbright", 12, 18, function(enabled)
	if enabled then
		Lighting.Brightness = 3
		Lighting.ClockTime = 15
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.new(1,1,1)
		Lighting.OutdoorAmbient = Color3.new(1,1,1)
	else
		Lighting.Brightness    = originalLighting.Brightness
		Lighting.ClockTime     = originalLighting.ClockTime
		Lighting.FogEnd        = originalLighting.FogEnd
		Lighting.GlobalShadows = originalLighting.GlobalShadows
		Lighting.Ambient       = originalLighting.Ambient
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
	end
end)

checkbox(worldGroup, "No Shadows", 12, 38, function(enabled)
	Lighting.GlobalShadows = not enabled
end)

checkbox(worldGroup, "Low Quality", 12, 58, function(enabled)
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

checkbox(worldGroup, "Remove Materials", 12, 78, function(enabled)
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
	end
end)

checkbox(worldGroup, "Show Spawns", 12, 98, function(enabled)
	for _, v in ipairs(workspace:GetDescendants()) do
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
				if h then h:Destroy() end
			end
		end
	end
end)

-- ======= MISC PAGE =======
local movementGroup = group(pages.Misc,"Movement",PAD,PAD,275,200)
local Credats = group(pages.Misc,"CREDITS",305,PAD,275,200)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ===== STATE =====
local speedEnabled = false
local jumpEnabled = false
local noclipEnabled = false
local infiniteJump = false

local flyEnabled = false
local flySpeed = 50

local savedSpeed = nil
local savedJump = nil

-- Fixed values (change these if desired)
local SPEED_VALUE = 16
local JUMP_VALUE = 50

-- ===== HUMANOID =====
local function getHum()
	local char = player.Character
	if not char then return end
	return char:FindFirstChildOfClass("Humanoid")
end

-- ===== SPEED =====
checkbox(movementGroup, "Speed BROKEN", 12, 18, function(enabled)
	speedEnabled = enabled

	local hum = getHum()
	if not hum then return end

	if enabled then
		savedSpeed = hum.WalkSpeed
	else
		if savedSpeed then
			hum.WalkSpeed = savedSpeed
		end
	end
end)

-- ===== JUMP =====
checkbox(movementGroup, "Jump Boost BROKEN", 12, 38, function(enabled)
	jumpEnabled = enabled

	local hum = getHum()
	if not hum then return end

	if enabled then
		savedJump = hum.UseJumpPower and hum.JumpPower or hum.JumpHeight
	else
		if savedJump then
			if hum.UseJumpPower then
				hum.JumpPower = savedJump
			else
				hum.JumpHeight = savedJump
			end
		end
	end
end)

-- ===== INFINITE JUMP =====
checkbox(movementGroup, "Infinite Jump BROKEN", 12, 58, function(enabled)
	infiniteJump = enabled
end)

UIS.JumpRequest:Connect(function()
	if not infiniteJump then return end

	local hum = getHum()
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
		hum.Jump = true
	end
end)

-- ===== APPLY LOOP =====
RunService.Heartbeat:Connect(function()
	local hum = getHum()
	if not hum then return end

	if speedEnabled then
		hum.WalkSpeed = SPEED_VALUE
	end

	if jumpEnabled then
		if hum.UseJumpPower then
			hum.JumpPower = JUMP_VALUE
		else
			hum.JumpHeight = JUMP_VALUE
		end
	end
end)
-- ===== NOCLIP =====

local noclipEnabled = false

checkbox(movementGroup, "Noclip", 12, 78, function(enabled)
	noclipEnabled = enabled

	if not enabled then
		local char = player.Character

		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	if not noclipEnabled then
		return
	end

	local char = player.Character
	if not char then
		return
	end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end)

player.CharacterAdded:Connect(function(char)
	task.wait(1)

	if noclipEnabled then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- ===== FLY =====
checkbox(movementGroup, "Fly", 12, 98, function(enabled)
	flyEnabled = enabled

	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = enabled
	end
end)

slider(movementGroup, "Fly Speed", 12, 118, 0, 300, 50, function(val)
	flySpeed = tonumber(val) or 50
end)

RunService.RenderStepped:Connect(function()
	if not flyEnabled then return end

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if not hrp or not cam then return end

	local moveDir = Vector3.zero

	if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end

	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
	end

	hrp.AssemblyLinearVelocity = moveDir * flySpeed
end)


-- Credits
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

Current Version: 0.2

Z-CORD
SKIBIDIWARE
]]
credits.Parent = Credats

-- ======= CONFIG PAGE =======
group(pages.Config,"Configs",PAD,PAD,275,200)

local settingsGroup = group(pages.Config,"Settings",305,PAD,275,200)

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
	if gameProcessed then return end
	if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
		menuKey = input.KeyCode
		keybindButton.Text = string.upper(menuKey.Name)
		waitingForKey = false
		return
	end
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

local watermarkEnabled = false

local watermarkGui
local watermarkScreenGui
local dragging = false
local dragStart, startPos

local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local function getPing()
	local network = Stats:FindFirstChild("Network")
	if not network then
		return "?"
	end

	local serverStats = network:FindFirstChild("ServerStatsItem")
	if not serverStats then
		return "?"
	end

	local pingItem = serverStats:FindFirstChild("Data Ping")
	if not pingItem then
		return "?"
	end

	return tostring(pingItem:GetValueString())
end

local function removeWatermark()
	if watermarkScreenGui then
		watermarkScreenGui:Destroy()
		watermarkScreenGui = nil
	end

	watermarkGui = nil
end

local fps = 0
local frameCount = 0
local lastFPSUpdate = tick()

RunService.RenderStepped:Connect(function()
	frameCount += 1

	local now = tick()

	if now - lastFPSUpdate >= 0.3 then
		fps = math.floor(frameCount / (now - lastFPSUpdate))
		frameCount = 0
		lastFPSUpdate = now
	end
end)

local function createWatermark()
	if watermarkGui then
		return
	end

	watermarkScreenGui = Instance.new("ScreenGui")
	watermarkScreenGui.Name = "SkibidiWareWatermark"
	watermarkScreenGui.ResetOnSpawn = false
	watermarkScreenGui.IgnoreGuiInset = true
	watermarkScreenGui.Parent = CoreGui

	watermarkGui = Instance.new("Frame")
	watermarkGui.Size = UDim2.fromOffset(340, 24)
	watermarkGui.Position = UDim2.fromOffset(200, 200)
	watermarkGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	watermarkGui.BorderColor3 = Color3.fromRGB(45, 45, 45)
	watermarkGui.Parent = watermarkScreenGui
	watermarkGui.Active = true

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 2)
	topBar.BorderSizePixel = 0
	topBar.Parent = watermarkGui

	local skibidi = Instance.new("TextLabel")
	skibidi.BackgroundTransparency = 1
	skibidi.Position = UDim2.fromOffset(8, 3)
	skibidi.Size = UDim2.fromOffset(45, 18)
	skibidi.Font = Enum.Font.ArialBold
	skibidi.TextSize = 14
	skibidi.TextColor3 = Color3.fromRGB(255,255,255)
	skibidi.TextXAlignment = Enum.TextXAlignment.Left
	skibidi.Text = "Skibidi"
	skibidi.Parent = watermarkGui

	local ware = Instance.new("TextLabel")
	ware.BackgroundTransparency = 1
	ware.Position = UDim2.fromOffset(52, 3)
	ware.Size = UDim2.fromOffset(40, 18)
	ware.Font = Enum.Font.ArialBold
	ware.TextSize = 14
	ware.TextXAlignment = Enum.TextXAlignment.Left
	ware.Text = "Ware"
	ware.Parent = watermarkGui

	local info = Instance.new("TextLabel")
	info.BackgroundTransparency = 1
	info.Position = UDim2.fromOffset(92, 3)
	info.Size = UDim2.fromOffset(240, 18)
	info.Font = Enum.Font.Arial
	info.TextSize = 13
	info.TextColor3 = Color3.fromRGB(220,220,220)
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Parent = watermarkGui

	watermarkGui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = watermarkGui.Position
		end
	end)

	watermarkGui.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart

			watermarkGui.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not watermarkGui then
			return
		end

		local c = rainbow()

		topBar.BackgroundColor3 = c
		ware.TextColor3 = c

		info.Text = string.format(
			"| FPS: %d | Ping: %s",
			fps,
			getPing()
		)
	end)
end

checkbox(settingsGroup, "Watermark", 10, 50, function(enabled)
	watermarkEnabled = enabled

	if enabled then
		createWatermark()
	else
		removeWatermark()
	end
end)