-- [BETA] SkibidiWare Release v0.7


local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Stats      = game:GetService("Stats")
local CoreGui    = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ── Saved lighting ───────────────────────────────────────────────────────────
local originalLighting = {
	Brightness     = Lighting.Brightness,
	ClockTime      = Lighting.ClockTime,
	FogEnd         = Lighting.FogEnd,
	FogStart       = Lighting.FogStart,
	GlobalShadows  = Lighting.GlobalShadows,
	Ambient        = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function rainbow()
	return Color3.fromHSV((tick() % 10) / 15, 1, 1)
end

local playerColors = {}
local function getPlayerColor(p)
	if not playerColors[p.UserId] then
		local h = (p.UserId * 0.618033988749895) % 1
		playerColors[p.UserId] = Color3.fromHSV(h, 0.85, 1)
	end
	return playerColors[p.UserId]
end

local function worldToViewport(pos)
	local cam = workspace.CurrentCamera
	local vp, onScreen = cam:WorldToViewportPoint(pos)
	return Vector2.new(vp.X, vp.Y), onScreen, vp.Z
end

-- ── GUI root ─────────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name           = "SkibidiWare"
gui.ResetOnSpawn   = false
gui.DisplayOrder   = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent         = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size             = UDim2.fromOffset(595, 400)
main.Position         = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint      = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderColor3     = Color3.fromRGB(75, 75, 75)
main.Parent           = gui

local stroke = Instance.new("UIStroke")
stroke.Color  = Color3.fromRGB(75, 75, 75)
stroke.Parent = main

local accent = Instance.new("Frame")
accent.Size            = UDim2.new(1, 0, 0, 2)
accent.BorderSizePixel = 0
accent.Parent          = main

local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 24)
titleBar.Position         = UDim2.fromOffset(0, 2)
titleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = main

local titleHolder = Instance.new("Frame")
titleHolder.Size                   = UDim2.fromScale(1, 1)
titleHolder.BackgroundTransparency = 1
titleHolder.Parent                 = titleBar

local skibidiLabel = Instance.new("TextLabel")
skibidiLabel.BackgroundTransparency = 1
skibidiLabel.Size       = UDim2.fromOffset(55, 24)
skibidiLabel.Position   = UDim2.new(0.5, -42, 0, 0)
skibidiLabel.Text       = "SKIBIDI"
skibidiLabel.Font       = Enum.Font.ArialBold
skibidiLabel.TextSize   = 14
skibidiLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
skibidiLabel.Parent     = titleHolder

local wareLabel = Instance.new("TextLabel")
wareLabel.BackgroundTransparency = 1
wareLabel.Size     = UDim2.fromOffset(45, 24)
wareLabel.Position = UDim2.new(0.5, 10, 0, 0)
wareLabel.Text     = "WARE"
wareLabel.Font     = Enum.Font.ArialBold
wareLabel.TextSize = 14
wareLabel.Parent   = titleHolder

-- ── Title buttons ─────────────────────────────────────────────────────────────
local function makeTitleButton(text, x)
	local b = Instance.new("TextButton")
	b.Size             = UDim2.fromOffset(18, 18)
	b.Position         = UDim2.new(1, x, 0, 3)
	b.Text             = text
	b.Font             = Enum.Font.ArialBold
	b.TextSize         = 12
	b.TextColor3       = Color3.fromRGB(220, 220, 220)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.BorderColor3     = Color3.fromRGB(70, 70, 70)
	b.Parent           = titleBar
	return b
end

local closeBtn    = makeTitleButton("X", -22)
local minimizeBtn = makeTitleButton("-", -44)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ── Tab bar & content ─────────────────────────────────────────────────────────
local tabBar = Instance.new("Frame")
tabBar.Size             = UDim2.new(1, 0, 0, 24)
tabBar.Position         = UDim2.fromOffset(0, 26)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tabBar.BorderSizePixel  = 0
tabBar.Parent           = main

local content = Instance.new("Frame")
content.Size                   = UDim2.new(1, 0, 1, -50)
content.Position               = UDim2.fromOffset(0, 50)
content.BackgroundTransparency = 1
content.Parent                 = main

-- ── Minimize ──────────────────────────────────────────────────────────────────
local minimized = false
local fullSize  = main.Size
minimizeBtn.MouseButton1Click:Connect(function()
	minimized       = not minimized
	tabBar.Visible  = not minimized
	content.Visible = not minimized
	main.Size       = minimized and UDim2.fromOffset(610, 26) or fullSize
end)

-- ── Draggable window ──────────────────────────────────────────────────────────
local windowDragging = false
local windowDragStart, windowStartPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		windowDragging  = true
		windowDragStart = input.Position
		windowStartPos  = main.Position
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		windowDragging = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if windowDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - windowDragStart
		main.Position = UDim2.new(
			windowStartPos.X.Scale, windowStartPos.X.Offset + delta.X,
			windowStartPos.Y.Scale, windowStartPos.Y.Offset + delta.Y
		)
	end
end)

-- ── Pages & tabs ──────────────────────────────────────────────────────────────
local pages = {}
local function createPage(name)
	local p = Instance.new("Frame")
	p.Size                   = UDim2.fromScale(1, 1)
	p.BackgroundTransparency = 1
	p.Visible                = false
	p.Parent                 = content
	pages[name]              = p
	return p
end
local function showPage(name)
	for _, v in pairs(pages) do v.Visible = false end
	pages[name].Visible = true
end

local tabs = {"Rage", "Visuals", "Misc", "Config"}
for i, name in ipairs(tabs) do
	local b = Instance.new("TextButton")
	b.Size             = UDim2.fromOffset(90, 24)
	b.Position         = UDim2.fromOffset((i - 1) * 92, 0)
	b.Text             = name
	b.Font             = Enum.Font.Arial
	b.TextSize         = 12
	b.TextColor3       = Color3.fromRGB(220, 220, 220)
	b.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	b.BorderColor3     = Color3.fromRGB(70, 70, 70)
	b.Parent           = tabBar
	createPage(name)
	b.MouseButton1Click:Connect(function()
		showPage(name)
		for _, v in ipairs(tabBar:GetChildren()) do
			if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(24, 24, 24) end
		end
		b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end)
end
showPage("Rage")

-- ── Widget helpers ────────────────────────────────────────────────────────────
local PAD = 15
_G._SW_RainbowFills = {}

local function group(parent, text, x, y, w, h)
	local frame = Instance.new("Frame")
	frame.Size             = UDim2.fromOffset(w, h)
	frame.Position         = UDim2.fromOffset(x, y)
	frame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	frame.BorderColor3     = Color3.fromRGB(92, 92, 92)
	frame.Parent           = parent
	local label = Instance.new("TextLabel")
	label.Size             = UDim2.fromOffset(120, 14)
	label.Position         = UDim2.fromOffset(8, -7)
	label.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	label.Text             = " " .. text .. " "
	label.TextColor3       = Color3.fromRGB(220, 220, 220)
	label.Font             = Enum.Font.ArialBold
	label.TextSize         = 12
	label.Parent           = frame
	return frame
end

local function checkbox(parent, text, x, y, callback)
	local state  = false
	local holder = Instance.new("TextButton")
	holder.Size                   = UDim2.fromOffset(240, 16)
	holder.Position               = UDim2.fromOffset(x, y)
	holder.BackgroundTransparency = 1
	holder.Text                   = ""
	holder.Parent                 = parent

	local box = Instance.new("Frame")
	box.Size             = UDim2.fromOffset(12, 12)
	box.Position         = UDim2.fromOffset(0, 2)
	box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	box.BorderColor3     = Color3.fromRGB(80, 80, 80)
	box.Parent           = holder

	local fill = Instance.new("Frame")
	fill.Size            = UDim2.new(1, -4, 1, -4)
	fill.Position        = UDim2.fromOffset(2, 2)
	fill.BorderSizePixel = 0
	fill.Visible         = false
	fill.Parent          = box
	table.insert(_G._SW_RainbowFills, fill)

	local textLabel = Instance.new("TextLabel")
	textLabel.Size                   = UDim2.new(1, -18, 1, 0)
	textLabel.Position               = UDim2.fromOffset(18, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text                   = text
	textLabel.Font                   = Enum.Font.Arial
	textLabel.TextSize               = 12
	textLabel.TextColor3             = Color3.fromRGB(220, 220, 220)
	textLabel.TextXAlignment         = Enum.TextXAlignment.Left
	textLabel.Parent                 = holder

	holder.MouseButton1Click:Connect(function()
		state        = not state
		fill.Visible = state
		if callback then callback(state) end
	end)
	return holder
end

local function slider(parent, text, x, y, minVal, maxVal, defaultVal, callback)
	local TRACK_W    = 240
	local currentVal = defaultVal
	local draggingSlider = false

	local holder = Instance.new("Frame")
	holder.Size                   = UDim2.fromOffset(TRACK_W, 30)
	holder.Position               = UDim2.fromOffset(x, y)
	holder.BackgroundTransparency = 1
	holder.Parent                 = parent

	local labelText = Instance.new("TextLabel")
	labelText.Size                   = UDim2.fromOffset(TRACK_W, 14)
	labelText.BackgroundTransparency = 1
	labelText.Font                   = Enum.Font.Arial
	labelText.TextSize               = 12
	labelText.TextColor3             = Color3.fromRGB(220, 220, 220)
	labelText.TextXAlignment         = Enum.TextXAlignment.Left
	labelText.Text                   = text .. ": " .. defaultVal
	labelText.Parent                 = holder

	local track = Instance.new("Frame")
	track.Size             = UDim2.fromOffset(TRACK_W, 4)
	track.Position         = UDim2.fromOffset(0, 20)
	track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	track.BorderColor3     = Color3.fromRGB(80, 80, 80)
	track.ClipsDescendants = false
	track.Parent           = holder

	local fillBar = Instance.new("Frame")
	fillBar.Size            = UDim2.fromScale((defaultVal - minVal) / (maxVal - minVal), 1)
	fillBar.BorderSizePixel = 0
	fillBar.Parent          = track
	table.insert(_G._SW_RainbowFills, fillBar)

	local knob = Instance.new("Frame")
	knob.Size             = UDim2.fromOffset(10, 10)
	knob.AnchorPoint      = Vector2.new(0.5, 0.5)
	knob.Position         = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	knob.BorderColor3     = Color3.fromRGB(100, 100, 100)
	knob.Parent           = track

	local function applyMouse(mouseX)
		local pct  = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		currentVal = math.floor(minVal + pct * (maxVal - minVal))
		knob.Position  = UDim2.new(pct, 0, 0.5, 0)
		fillBar.Size   = UDim2.fromScale(pct, 1)
		labelText.Text = text .. ": " .. currentVal
		if callback then callback(currentVal) end
	end

	knob.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
	end)
	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			applyMouse(inp.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
	end)
	UIS.InputChanged:Connect(function(inp)
		if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
			applyMouse(inp.Position.X)
		end
	end)
	return holder
end

-- ── Rage page ─────────────────────────────────────────────────────────────────
local rageMain  = group(pages.Rage, "Main",  PAD, PAD, 275, 200)
local rageOther = group(pages.Rage, "Other", 305, PAD, 275, 200)

-- ── Module references (resolved once at load time) ────────────────────────────
local RS      = game:GetService("ReplicatedStorage")
local modules = RS:FindFirstChild("Modules")

local GunController    = nil
local CameraController = nil
local FirearmRuntime   = nil

local function safeRequire(obj)
	if not obj then return nil end
	local ok, result = pcall(require, obj)
	return ok and result or nil
end

if modules then
	local clientControllers = modules:FindFirstChild("Client") and modules.Client:FindFirstChild("Controllers")
	if clientControllers then
		GunController    = safeRequire(clientControllers:FindFirstChild("GunController"))
		CameraController = safeRequire(clientControllers:FindFirstChild("CameraController"))
	end
end

local runtimeRegistry = RS:FindFirstChild("Registries") and RS.Registries:FindFirstChild("FirearmRuntime")
if runtimeRegistry then
	FirearmRuntime = safeRequire(runtimeRegistry)
end

-- ── Fire Rate ─────────────────────────────────────────────────────────────────

local originalFireRates = {}  -- [data_ref_id] = original value

local function setFireRate(sliderVal)
	-- sliderVal: 0 = stock, 100 = fastest (0.08 s between shots)
	local targetRate = 0.08 + (1 - sliderVal / 100) * 0.92  -- 0.08 at 100, 1.0 at 0 (arbitrary stock cap)

	-- Patch the runtime table entries
	if FirearmRuntime then
		for id, data in pairs(FirearmRuntime) do
			if type(data) == "table" and data.FireRate then
				-- save original per entry once
				if originalFireRates[id] == nil then
					originalFireRates[id] = data.FireRate
				end
				if sliderVal == 0 then
					data.FireRate = originalFireRates[id]
				else
					data.FireRate = math.max(0.08, math.min(originalFireRates[id], targetRate))
				end
			end
		end
	end

	-- Patch the currently held weapon on GunController
	if GunController then
		if GunController.Weapon then
			if originalFireRates["_weapon"] == nil then
				originalFireRates["_weapon"] = GunController.Weapon.FireRate
			end
			if sliderVal == 0 then
				GunController.Weapon.FireRate = originalFireRates["_weapon"]
			else
				GunController.Weapon.FireRate = math.max(0.08, math.min(
					originalFireRates["_weapon"] or 0.5, targetRate))
			end
		end
	end
end

-- ── Recoil ────────────────────────────────────────────────────────────────────


local savedRecoilFuncs = {}

local function enableNoRecoil()
	if GunController then
		savedRecoilFuncs.ApplyRecoil          = GunController.ApplyRecoil
		savedRecoilFuncs._FireScriptedRecoil  = GunController._FireScriptedRecoil
		GunController.ApplyRecoil             = function() end
		GunController._FireScriptedRecoil     = function() end
	end
	if CameraController then
		savedRecoilFuncs.Recoil               = CameraController.Recoil
		savedRecoilFuncs.BoomKick             = CameraController.BoomKick
		savedRecoilFuncs.SetRecoilProfile     = CameraController.SetRecoilProfile
		if CameraController.Recoil           then CameraController.Recoil           = function() end end
		if CameraController.BoomKick         then CameraController.BoomKick         = function() end end
		if CameraController.SetRecoilProfile then CameraController.SetRecoilProfile = function() end end
	end
end

local function disableNoRecoil()
	if GunController then
		if savedRecoilFuncs.ApplyRecoil         then GunController.ApplyRecoil         = savedRecoilFuncs.ApplyRecoil         end
		if savedRecoilFuncs._FireScriptedRecoil then GunController._FireScriptedRecoil = savedRecoilFuncs._FireScriptedRecoil end
	end
	if CameraController then
		if savedRecoilFuncs.Recoil           then CameraController.Recoil           = savedRecoilFuncs.Recoil           end
		if savedRecoilFuncs.BoomKick         then CameraController.BoomKick         = savedRecoilFuncs.BoomKick         end
		if savedRecoilFuncs.SetRecoilProfile then CameraController.SetRecoilProfile = savedRecoilFuncs.SetRecoilProfile end
	end
	savedRecoilFuncs = {}
end

-- ── Rage Main UI ──────────────────────────────────────────────────────────────
checkbox(rageMain, "No Recoil", 12, 18, function(enabled)
	if enabled then enableNoRecoil() else disableNoRecoil() end
end)

slider(rageMain, "Fire Rate", 12, 38, 0, 100, 0, function(val)
	setFireRate(val)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- VISUALS PAGE
-- ═══════════════════════════════════════════════════════════════════════════════
local playersGroup = group(pages.Visuals, "Players", PAD, PAD, 275, 300)
local worldGroup   = group(pages.Visuals, "World",   305, PAD, 275, 320)

-- ── ESP CONFIG STATE ─────────────────────────────────────────────────────────
local espEnabled       = false
local espConnections   = {}
local espHighlights    = {}
local espSubOptions    = {}

local showNames        = false
local showDistance     = false
local showHealthBar    = false
local showHeadDot      = false
local showBoxESP       = false

local espColorMode     = "unique"
local espFillAlpha     = 0.5
local espOutlineAlpha  = 0

-- ── ESP COLOR RESOLVER ───────────────────────────────────────────────────────
local function resolveESPColor(p)
	if espColorMode == "rainbow" then
		return rainbow()
	elseif espColorMode == "team" and p.Team then
		return p.Team.TeamColor.Color
	else
		return getPlayerColor(p)
	end
end

-- ── ESP CORE ─────────────────────────────────────────────────────────────────
local function removeESP(character)
	if not espHighlights[character] then return end
	for _, v in pairs(espHighlights[character]) do
		if typeof(v) == "RBXScriptConnection" then v:Disconnect()
		elseif typeof(v) == "Instance" and v.Parent then v:Destroy() end
	end
	espHighlights[character] = nil
end

local function applyESP(p)
	local character = p.Character
	if not character then return end
	if espHighlights[character] then return end
	espHighlights[character] = {}
	local track = espHighlights[character]

	local hrp  = character:FindFirstChild("HumanoidRootPart")
	          or character:FindFirstChildWhichIsA("BasePart")
	local head = character:FindFirstChild("Head")
	local col  = resolveESPColor(p)

	-- ── Highlight glow ────────────────────────────────────────────────────────
	local highlight = Instance.new("Highlight")
	highlight.Name                = "PlayerESP"
	highlight.Adornee             = character
	highlight.FillColor           = col
	highlight.OutlineColor        = col
	highlight.FillTransparency    = espFillAlpha
	highlight.OutlineTransparency = espOutlineAlpha
	highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent              = character
	table.insert(track, highlight)

	-- ── Name label (above box) ────────────────────────────────────────────────
	local nameBB = Instance.new("BillboardGui")
	nameBB.Name        = "ESPNameBillboard"
	nameBB.Size        = UDim2.fromOffset(160, 18)
	nameBB.StudsOffset = Vector3.new(0, 3.5, 0)
	nameBB.AlwaysOnTop = true
	nameBB.Adornee     = hrp
	nameBB.Enabled     = showNames
	nameBB.Parent      = character

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size                   = UDim2.fromScale(1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font                   = Enum.Font.ArialBold
	nameLabel.TextSize               = 13
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
	nameLabel.TextColor3             = col
	nameLabel.Text                   = p.Name
	nameLabel.Parent                 = nameBB
	table.insert(track, nameBB)

	-- ── Distance label (below box) ────────────────────────────────────────────
	-- StudsOffset Y=-3.5 places it just below the feet.
	local distBB = Instance.new("BillboardGui")
	distBB.Name        = "ESPDistBillboard"
	distBB.Size        = UDim2.fromOffset(100, 14)
	distBB.StudsOffset = Vector3.new(0, -3.5, 0)
	distBB.AlwaysOnTop = true
	distBB.Adornee     = hrp
	distBB.Enabled     = showDistance
	distBB.Parent      = character

	local distLabel = Instance.new("TextLabel")
	distLabel.Size                   = UDim2.fromScale(1, 1)
	distLabel.BackgroundTransparency = 1
	distLabel.Font                   = Enum.Font.Arial
	distLabel.TextSize               = 11
	distLabel.TextStrokeTransparency = 0
	distLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
	distLabel.TextColor3             = col
	distLabel.Text                   = "0m"
	distLabel.Parent                 = distBB
	table.insert(track, distBB)

	-- ── Head dot ─────────────────────────────────────────────────────────────
	if head then
		local headDotBB = Instance.new("BillboardGui")
		headDotBB.Name        = "ESPHeadDot"
		headDotBB.Size        = UDim2.fromOffset(0, 0)
		headDotBB.SizeOffset  = Vector2.new(0.7, 0.7)   -- ~0.7 studs diameter, scales with distance
		headDotBB.StudsOffset = Vector3.new(0, 0.4, 0)
		headDotBB.AlwaysOnTop = true
		headDotBB.Adornee     = head
		headDotBB.Enabled     = showHeadDot
		headDotBB.Parent      = character

		local dot = Instance.new("Frame")
		dot.Size                   = UDim2.fromScale(1, 1)
		dot.BackgroundColor3       = col
		dot.BackgroundTransparency = 0.3
		dot.BorderSizePixel        = 0
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent       = dot
		dot.Parent          = headDotBB
		table.insert(track, headDotBB)
	end

	-- ── Box ESP (BillboardGui 4-line border) ──────────────────────────────────
	local boxBB = Instance.new("BillboardGui")
	boxBB.Name                  = "ESPBoxBillboard"
	boxBB.Size                  = UDim2.fromOffset(30, 52)
	boxBB.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
	boxBB.AlwaysOnTop           = true
	boxBB.Adornee               = hrp
	boxBB.Enabled               = showBoxESP
	boxBB.Parent                = character

	local T = 1
	local function makeBoxLine(sx, sy, px, py)
		local l = Instance.new("Frame")
		l.Size             = UDim2.fromOffset(sx, sy)
		l.Position         = UDim2.fromOffset(px, py)
		l.BackgroundColor3 = col
		l.BorderSizePixel  = 0
		l.Parent           = boxBB
		return l
	end
	local bTop   = makeBoxLine(30, T, 0,      0)
	local bBot   = makeBoxLine(30, T, 0,      52 - T)
	local bLeft  = makeBoxLine(T, 52, 0,      0)
	local bRight = makeBoxLine(T, 52, 30 - T, 0)
	table.insert(track, boxBB)

	-- ── Health bar (vertical, left side of box) ───────────────────────────────
	-- StudsOffset X=-1.8 puts it just to the left of the box edge
	local healthBB = Instance.new("BillboardGui")
	healthBB.Name        = "ESPHealthBar"
	healthBB.Size        = UDim2.fromOffset(4, 52)  -- matches box height
	healthBB.StudsOffset = Vector3.new(-1.8, 0, 0)
	healthBB.AlwaysOnTop = true
	healthBB.Adornee     = hrp
	healthBB.Enabled     = showHealthBar
	healthBB.Parent      = character

	local barBg = Instance.new("Frame")
	barBg.Size             = UDim2.fromScale(1, 1)
	barBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	barBg.BorderSizePixel  = 0
	barBg.Parent           = healthBB

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 2)
	barCorner.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Name             = "HealthFill"
	barFill.Size             = UDim2.fromScale(1, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
	barFill.BorderSizePixel  = 0
	barFill.AnchorPoint      = Vector2.new(0, 1)
	barFill.Position         = UDim2.fromScale(0, 1)
	barFill.Parent           = barBg
	table.insert(track, healthBB)

	-- ── Per-frame updater ─────────────────────────────────────────────────────
	local conn = RunService.RenderStepped:Connect(function()
		if not character or not character.Parent then return end

		local hum   = character:FindFirstChildWhichIsA("Humanoid")
		local lchar = player.Character
		local lroot = lchar and lchar:FindFirstChild("HumanoidRootPart")
		local eroot = character:FindFirstChild("HumanoidRootPart")

		local c = resolveESPColor(p)
		highlight.FillColor           = c
		highlight.OutlineColor        = c
		highlight.FillTransparency    = espFillAlpha
		highlight.OutlineTransparency = espOutlineAlpha

		nameLabel.TextColor3 = c
		distLabel.TextColor3 = c
		if head then
			local hd = character:FindFirstChild("ESPHeadDot")
			if hd then
				local dot2 = hd:FindFirstChildWhichIsA("Frame")
				if dot2 then dot2.BackgroundColor3 = c end
			end
		end
		bTop.BackgroundColor3   = c
		bBot.BackgroundColor3   = c
		bLeft.BackgroundColor3  = c
		bRight.BackgroundColor3 = c

		if showDistance and lroot and eroot then
			distLabel.Text = math.floor((lroot.Position - eroot.Position).Magnitude) .. "m"
		end

		if hum then
			local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			local r   = math.floor(255 * (1 - pct))
			local g   = math.floor(255 * pct)
			barFill.Size             = UDim2.new(1, 0, pct, 0)
			barFill.BackgroundColor3 = Color3.fromRGB(r, g, 0)
		end
	end)
	table.insert(track, conn)
end

local function enableESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			applyESP(p)
			local c1 = p.CharacterAdded:Connect(function()
				task.wait(0.5)
				applyESP(p)
			end)
			local c2 = p.CharacterRemoving:Connect(function(char)
				removeESP(char)
			end)
			table.insert(espConnections, c1)
			table.insert(espConnections, c2)
		end
	end
	local c3 = Players.PlayerAdded:Connect(function(p)
		if p ~= player then
			p.CharacterAdded:Connect(function()
				task.wait(0.5)
				applyESP(p)
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
	espHighlights  = {}
end

local function refreshESPBillboards()
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

-- ── Players group UI ──────────────────────────────────────────────────────────
local function setSubOptionsVisible(v)
	for _, h in ipairs(espSubOptions) do h.Visible = v end
end

local function sub(text, y, cb)
	local h = checkbox(playersGroup, text, 22, y, cb)
	h.Visible = false
	table.insert(espSubOptions, h)
	return h
end

checkbox(playersGroup, "Player ESP", 12, 18, function(enabled)
	espEnabled = enabled
	setSubOptionsVisible(enabled)
	if enabled then enableESP() else disableESP() end
end)

sub("Box ESP",    40,  function(e) showBoxESP    = e; refreshESPBillboards() end)
sub("Names",      60,  function(e) showNames     = e; refreshESPBillboards() end)
sub("Distance",   80,  function(e) showDistance  = e; refreshESPBillboards() end)
sub("Health Bar", 100, function(e) showHealthBar = e; refreshESPBillboards() end)
sub("Head Dot",   120, function(e) showHeadDot   = e; refreshESPBillboards() end)

-- Color mode
local colorLabel = Instance.new("TextLabel")
colorLabel.Size                   = UDim2.fromOffset(240, 14)
colorLabel.Position               = UDim2.fromOffset(22, 142)
colorLabel.BackgroundTransparency = 1
colorLabel.Font                   = Enum.Font.Arial
colorLabel.TextSize               = 11
colorLabel.TextColor3             = Color3.fromRGB(160, 160, 160)
colorLabel.TextXAlignment         = Enum.TextXAlignment.Left
colorLabel.Text                   = "Color Mode:"
colorLabel.Visible                = false
colorLabel.Parent                 = playersGroup
table.insert(espSubOptions, colorLabel)

local colorModes   = {"Unique", "Rainbow", "Team"}
local colorButtons = {}
for i, mode in ipairs(colorModes) do
	local b = Instance.new("TextButton")
	b.Size             = UDim2.fromOffset(58, 14)
	b.Position         = UDim2.fromOffset(22 + (i - 1) * 62, 158)
	b.Text             = mode
	b.Font             = Enum.Font.Arial
	b.TextSize         = 10
	b.TextColor3       = Color3.fromRGB(200, 200, 200)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	b.BorderColor3     = Color3.fromRGB(70, 70, 70)
	b.Visible          = false
	b.Parent           = playersGroup
	table.insert(espSubOptions, b)
	colorButtons[i] = b
	b.MouseButton1Click:Connect(function()
		espColorMode = mode:lower()
		for j, btn in ipairs(colorButtons) do
			btn.BackgroundColor3 = j == i and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
		end
	end)
end
colorButtons[1].BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local fillSlider = slider(playersGroup, "Fill Alpha", 22, 180, 0, 100, 50, function(v)
	espFillAlpha = v / 100
end)
fillSlider.Visible = false
table.insert(espSubOptions, fillSlider)

local outlineSlider = slider(playersGroup, "Outline Alpha", 22, 218, 0, 100, 0, function(v)
	espOutlineAlpha = v / 100
end)
outlineSlider.Visible = false
table.insert(espSubOptions, outlineSlider)

-- ── World group UI ────────────────────────────────────────────────────────────
checkbox(worldGroup, "Fullbright", 12, 18, function(enabled)
	if enabled then
		Lighting.Brightness     = 3
		Lighting.ClockTime      = 15
		Lighting.FogEnd         = 100000
		Lighting.GlobalShadows  = false
		Lighting.Ambient        = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	else
		Lighting.Brightness     = originalLighting.Brightness
		Lighting.ClockTime      = originalLighting.ClockTime
		Lighting.FogEnd         = originalLighting.FogEnd
		Lighting.GlobalShadows  = originalLighting.GlobalShadows
		Lighting.Ambient        = originalLighting.Ambient
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
					h.Name                = "SpawnESP"
					h.Adornee             = v
					h.FillTransparency    = 0.8
					h.OutlineTransparency = 1
					h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
					h.Parent              = v
				end
			else
				local h = v:FindFirstChild("SpawnESP")
				if h then h:Destroy() end
			end
		end
	end
end)

checkbox(worldGroup, "Night Vision", 12, 118, function(enabled)
	if enabled then
		Lighting.Brightness     = 0.5
		Lighting.Ambient        = Color3.fromRGB(0, 60, 0)
		Lighting.OutdoorAmbient = Color3.fromRGB(0, 80, 20)
		Lighting.FogEnd         = 100000
	else
		Lighting.Brightness     = originalLighting.Brightness
		Lighting.Ambient        = originalLighting.Ambient
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
		Lighting.FogEnd         = originalLighting.FogEnd
	end
end)

checkbox(worldGroup, "Remove Decals", 12, 138, function(enabled)
	if enabled then
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SpecialMesh") then
				v.Transparency = 1
			end
		end
	else
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 0
			end
		end
	end
end)

local wireframeEnabled = false
local wireframeHighlights = {}
checkbox(worldGroup, "Wireframe World", 12, 158, function(enabled)
	wireframeEnabled = enabled
	if enabled then
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v:IsDescendantOf(player.Character or Instance.new("Folder")) then
				if not wireframeHighlights[v] then
					local h = Instance.new("Highlight")
					h.Adornee             = v
					h.FillTransparency    = 1
					h.OutlineTransparency = 0
					h.OutlineColor        = Color3.fromRGB(0, 200, 255)
					h.DepthMode           = Enum.HighlightDepthMode.Occluded
					h.Parent              = v
					wireframeHighlights[v] = h
				end
				v.LocalTransparencyModifier = 1
			end
		end
	else
		for part, h in pairs(wireframeHighlights) do
			if h and h.Parent then h:Destroy() end
			if part and part.Parent then
				part.LocalTransparencyModifier = 0
			end
		end
		wireframeHighlights = {}
	end
end)

slider(worldGroup, "Time of Day", 12, 185, 0, 24, math.floor(Lighting.ClockTime), function(v)
	Lighting.ClockTime = v
end)

slider(worldGroup, "Fog Distance", 12, 225, 0, 10000, math.floor(Lighting.FogEnd), function(v)
	Lighting.FogEnd   = v
	Lighting.FogStart = math.max(0, v - 200)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MISC PAGE  –  Movement (noclip + fly only) + Credits
-- Removed: Speed Hack, Walk Speed slider, Custom Jump, Jump Power slider, Inf Jump
-- ═══════════════════════════════════════════════════════════════════════════════
local movementGroup = group(pages.Misc, "Movement", PAD, PAD, 275, 160)
local creditsGroup  = group(pages.Misc, "Credits",  305, PAD, 275, 200)

-- ── State ────────────────────────────────────────────────────────────────────
local noclipEnabled  = false
local flyEnabled     = false
local flySpeed       = 50
local antiAFKEnabled = false

local function getCharHum()
	local char = player.Character
	if not char then return nil, nil end
	return char, char:FindFirstChildOfClass("Humanoid")
end

-- ── Noclip ───────────────────────────────────────────────────────────────────
checkbox(movementGroup, "Noclip", 12, 18, function(enabled)
	noclipEnabled = enabled
	if not enabled then
		local char = player.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	if not noclipEnabled then return end
	local char = player.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = false end
	end
end)

-- ── Fly ──────────────────────────────────────────────────────────────────────
checkbox(movementGroup, "Fly", 12, 38, function(enabled)
	flyEnabled = enabled
	local char, hum = getCharHum()
	if hum then hum.PlatformStand = enabled end
end)

slider(movementGroup, "Fly Speed", 12, 58, 10, 500, 50, function(val)
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
	if UIS:IsKeyDown(Enum.KeyCode.W)           then moveDir += cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S)           then moveDir -= cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.D)           then moveDir += cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.A)           then moveDir -= cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space)       then moveDir += Vector3.new(0, 1, 0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
	if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
	hrp.AssemblyLinearVelocity = moveDir * flySpeed
end)

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	if flyEnabled then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = true end
	end
end)

-- ── Anti-AFK ─────────────────────────────────────────────────────────────────
checkbox(movementGroup, "Anti-AFK", 12, 98, function(enabled)
	antiAFKEnabled = enabled
end)

local antiAFKTimer = 0
RunService.Heartbeat:Connect(function(dt)
	if not antiAFKEnabled then antiAFKTimer = 0 return end
	antiAFKTimer += dt
	if antiAFKTimer >= 60 then
		antiAFKTimer = 0
		local vInputService = game:GetService("VirtualInputManager")
		vInputService:SendKeyEvent(true,  Enum.KeyCode.ButtonL3, false, game)
		vInputService:SendKeyEvent(false, Enum.KeyCode.ButtonL3, false, game)
	end
end)

-- ── Credits ───────────────────────────────────────────────────────────────────
local credits = Instance.new("TextLabel")
credits.Size                   = UDim2.new(1, -20, 1, -30)
credits.Position               = UDim2.fromOffset(10, 20)
credits.BackgroundTransparency = 1
credits.TextXAlignment         = Enum.TextXAlignment.Left
credits.TextYAlignment         = Enum.TextYAlignment.Top
credits.TextWrapped            = true
credits.Font                   = Enum.Font.Code
credits.TextSize               = 13
credits.TextColor3             = Color3.fromRGB(220, 220, 220)
credits.Text                   = [[
Developed by: Kvnny14

Contributors:
- ksaloll

Current Version: 0.7

Z-CORD
SKIBIDIWARE
]]
credits.Parent = creditsGroup

-- ── Config page ───────────────────────────────────────────────────────────────
group(pages.Config, "Configs", PAD, PAD, 275, 200)
local settingsGroup = group(pages.Config, "Settings", 305, PAD, 275, 200)

local menuKey = Enum.KeyCode.Insert
local keybindButton = Instance.new("TextButton")
keybindButton.Size             = UDim2.fromOffset(60, 20)
keybindButton.Position         = UDim2.fromOffset(10, 20)
keybindButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
keybindButton.BorderColor3     = Color3.fromRGB(80, 80, 80)
keybindButton.Font             = Enum.Font.Arial
keybindButton.TextSize         = 12
keybindButton.TextColor3       = Color3.fromRGB(220, 220, 220)
keybindButton.Text             = "Insert"
keybindButton.Parent           = settingsGroup

local waitingForKey = false
keybindButton.MouseButton1Click:Connect(function()
	waitingForKey      = true
	keybindButton.Text = "..."
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
		menuKey            = input.KeyCode
		keybindButton.Text = string.upper(menuKey.Name)
		waitingForKey      = false
		return
	end
	if input.KeyCode == menuKey then
		gui.Enabled = not gui.Enabled
	end
end)

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size                   = UDim2.fromOffset(100, 20)
keybindLabel.Position               = UDim2.fromOffset(80, 20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font                   = Enum.Font.Arial
keybindLabel.TextSize               = 12
keybindLabel.TextColor3             = Color3.fromRGB(220, 220, 220)
keybindLabel.TextXAlignment         = Enum.TextXAlignment.Left
keybindLabel.Text                   = "Menu Keybind"
keybindLabel.Parent                 = settingsGroup

-- ── Watermark ─────────────────────────────────────────────────────────────────
local watermarkGui       = nil
local watermarkScreenGui = nil
local wmDragging         = false
local wmDragStart, wmStartPos

local function getPing()
	local network = Stats:FindFirstChild("Network")
	if not network then return "?" end
	local ss = network:FindFirstChild("ServerStatsItem")
	if not ss then return "?" end
	local pi = ss:FindFirstChild("Data Ping")
	if not pi then return "?" end
	return tostring(pi:GetValueString())
end

local function removeWatermark()
	if watermarkScreenGui then
		watermarkScreenGui:Destroy()
		watermarkScreenGui = nil
	end
	watermarkGui = nil
end

local fps        = 0
local frameCount = 0
local lastFPSUpdate = tick()

local function createWatermark()
	if watermarkGui then return end
	watermarkScreenGui = Instance.new("ScreenGui")
	watermarkScreenGui.Name           = "SkibidiWareWatermark"
	watermarkScreenGui.ResetOnSpawn   = false
	watermarkScreenGui.IgnoreGuiInset = true
	watermarkScreenGui.Parent         = CoreGui

	watermarkGui = Instance.new("Frame")
	watermarkGui.Size             = UDim2.fromOffset(340, 24)
	watermarkGui.Position         = UDim2.fromOffset(200, 200)
	watermarkGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	watermarkGui.BorderColor3     = Color3.fromRGB(45, 45, 45)
	watermarkGui.Active           = true
	watermarkGui.Parent           = watermarkScreenGui

	local wmTopBar = Instance.new("Frame")
	wmTopBar.Size            = UDim2.new(1, 0, 0, 2)
	wmTopBar.BorderSizePixel = 0
	wmTopBar.Parent          = watermarkGui

	local wmSkibidi = Instance.new("TextLabel")
	wmSkibidi.BackgroundTransparency = 1
	wmSkibidi.Position       = UDim2.fromOffset(8, 3)
	wmSkibidi.Size           = UDim2.fromOffset(45, 18)
	wmSkibidi.Font           = Enum.Font.ArialBold
	wmSkibidi.TextSize       = 14
	wmSkibidi.TextColor3     = Color3.fromRGB(255, 255, 255)
	wmSkibidi.TextXAlignment = Enum.TextXAlignment.Left
	wmSkibidi.Text           = "Skibidi"
	wmSkibidi.Parent         = watermarkGui

	local wmWare = Instance.new("TextLabel")
	wmWare.BackgroundTransparency = 1
	wmWare.Position       = UDim2.fromOffset(52, 3)
	wmWare.Size           = UDim2.fromOffset(40, 18)
	wmWare.Font           = Enum.Font.ArialBold
	wmWare.TextSize       = 14
	wmWare.TextXAlignment = Enum.TextXAlignment.Left
	wmWare.Text           = "Ware"
	wmWare.Parent         = watermarkGui

	local wmInfo = Instance.new("TextLabel")
	wmInfo.BackgroundTransparency = 1
	wmInfo.Position       = UDim2.fromOffset(92, 3)
	wmInfo.Size           = UDim2.fromOffset(240, 18)
	wmInfo.Font           = Enum.Font.Arial
	wmInfo.TextSize       = 13
	wmInfo.TextColor3     = Color3.fromRGB(220, 220, 220)
	wmInfo.TextXAlignment = Enum.TextXAlignment.Left
	wmInfo.Parent         = watermarkGui

	watermarkGui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			wmDragging  = true
			wmDragStart = input.Position
			wmStartPos  = watermarkGui.Position
		end
	end)
	watermarkGui.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then wmDragging = false end
	end)
	UIS.InputChanged:Connect(function(input)
		if wmDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - wmDragStart
			watermarkGui.Position = UDim2.new(
				wmStartPos.X.Scale, wmStartPos.X.Offset + delta.X,
				wmStartPos.Y.Scale, wmStartPos.Y.Offset + delta.Y
			)
		end
	end)

	table.insert(_G._SW_RainbowFills, wmTopBar)
	table.insert(_G._SW_RainbowFills, wmWare)

	RunService.RenderStepped:Connect(function()
		if not watermarkGui then return end
		wmInfo.Text = string.format("| FPS: %d | Ping: %s", fps, getPing())
	end)
end

checkbox(settingsGroup, "Watermark", 10, 50, function(enabled)
	if enabled then createWatermark() else removeWatermark() end
end)

-- ── Master RenderStepped ──────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
	local c = rainbow()

	accent.BackgroundColor3 = c
	wareLabel.TextColor3    = c

	for _, v in ipairs(workspace:GetDescendants()) do
		local esp = v:FindFirstChild("SpawnESP")
		if esp and esp:IsA("Highlight") then
			esp.FillColor    = c
			esp.OutlineColor = c
		end
	end

	for _, fill in ipairs(_G._SW_RainbowFills) do
		if fill and fill.Parent then
			if fill:IsA("TextLabel") then
				fill.TextColor3 = c
			else
				fill.BackgroundColor3 = c
			end
		end
	end

	frameCount += 1
	local now = tick()
	if now - lastFPSUpdate >= 0.3 then
		fps           = math.floor(frameCount / (now - lastFPSUpdate))
		frameCount    = 0
		lastFPSUpdate = now
	end
end)