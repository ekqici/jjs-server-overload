--- hello this is made by claude
--- im a badass so i couldnt make it myself
--- enjoy!

local playersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

local PLATFORM_POSITION = Vector3.new(-11, -105, 52)
local PLATFORM_SIZE = Vector3.new(2048, 4, 2048)
local OFFLOAD_TIMEOUT = 1
local DRAG_THRESHOLD = 4

local MATERIALS = {
	"SmoothPlastic", "Plastic", "Neon", "Grass", "Ice", "Marble", "Granite",
	"Wood", "Concrete", "Metal", "Glass", "ForceField", "Sand", "Brick",
}

local PLATFORM_COLORS = {
	Color3.fromRGB(120, 120, 120), Color3.fromRGB(110, 90, 255), Color3.fromRGB(60, 190, 120),
	Color3.fromRGB(235, 90, 90), Color3.fromRGB(240, 190, 70), Color3.fromRGB(70, 170, 235),
	Color3.fromRGB(20, 20, 24),
}

local COLOR_BACKGROUND = Color3.fromRGB(22, 22, 30)
local COLOR_PANEL = Color3.fromRGB(34, 34, 46)
local COLOR_ACCENT = Color3.fromRGB(110, 90, 255)
local COLOR_OFF = Color3.fromRGB(64, 64, 80)
local COLOR_TEXT = Color3.fromRGB(235, 235, 245)
local COLOR_MUTED = Color3.fromRGB(150, 150, 170)

local localPlayer = playersService.LocalPlayer

local servicesFolder = replicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
local rightActivated = servicesFolder:WaitForChild("MechamaruService"):WaitForChild("RE"):WaitForChild("RightActivated")
local ultraEvents = servicesFolder:WaitForChild("UltraCannonService"):WaitForChild("RE")
local ultraActivated = ultraEvents:WaitForChild("Activated")
local ultraDeactivated = ultraEvents:WaitForChild("Deactivated")

if shared.autoUltimate then
	local old = shared.autoUltimate
	old.enabled = false
	old.gui:Destroy()
	old.platform:Destroy()

	for _, connection in ipairs(old.connections or {}) do
		connection:Disconnect()
	end
end

local state = { enabled = false, connections = {} }
shared.autoUltimate = state

local platform = Instance.new("Part")
platform.Name = "AutoUltimatePlatform"
platform.Anchored = true
platform.Size = PLATFORM_SIZE
platform.Position = PLATFORM_POSITION
platform.Material = Enum.Material.SmoothPlastic
platform.Color = PLATFORM_COLORS[1]
platform.Parent = workspace

state.platform = platform

local function create(className, properties, parent)
	local object = Instance.new(className)

	for key, value in pairs(properties) do
		object[key] = value
	end

	object.Parent = parent
	return object
end

local function round(object, radius)
	create("UICorner", { CornerRadius = UDim.new(0, radius) }, object)
end

local function createLabel(text, positionY, parent)
	create("TextLabel", {
		Size = UDim2.new(1, -24, 0, 20),
		Position = UDim2.new(0, 12, 0, positionY),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLOR_MUTED,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
end

local screenGui = create("ScreenGui", { Name = "AutoUltimate", ResetOnSpawn = false }, gethui())
state.gui = screenGui

local menu = create("Frame", {
	Size = UDim2.fromOffset(300, 392),
	Position = UDim2.new(0, 100, 0.5, -196),
	BackgroundColor3 = COLOR_BACKGROUND,
	Active = true,
	Draggable = true,
	Visible = false,
}, screenGui)
round(menu, 14)
create("UIStroke", { Color = COLOR_ACCENT, Thickness = 1.5, Transparency = 0.35 }, menu)

create("TextLabel", {
	Size = UDim2.new(1, -60, 0, 44),
	Position = UDim2.new(0, 16, 0, 0),
	BackgroundTransparency = 1,
	Text = "Auto Ult",
	TextColor3 = COLOR_TEXT,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
}, menu)

local closeButton = create("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -40, 0, 8),
	BackgroundColor3 = COLOR_PANEL,
	Text = "×",
	TextColor3 = COLOR_TEXT,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
}, menu)
round(closeButton, 8)

create("Frame", {
	Size = UDim2.new(1, -24, 0, 2),
	Position = UDim2.new(0, 12, 0, 44),
	BackgroundColor3 = COLOR_ACCENT,
	BorderSizePixel = 0,
}, menu)

local function createToggle(text, positionY, initial, callback)
	local row = create("Frame", {
		Size = UDim2.new(1, -24, 0, 42),
		Position = UDim2.new(0, 12, 0, positionY),
		BackgroundColor3 = COLOR_PANEL,
	}, menu)
	round(row, 10)

	create("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLOR_TEXT,
		Font = Enum.Font.GothamMedium,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local track = create("TextButton", {
		Size = UDim2.fromOffset(44, 24),
		Position = UDim2.new(1, -56, 0.5, -12),
		Text = "",
		AutoButtonColor = false,
	}, row)
	round(track, 12)

	local knob = create("Frame", {
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = COLOR_TEXT,
	}, track)
	round(knob, 9)

	local value = initial

	local function render(animate)
		local goal = {
			track = { BackgroundColor3 = value and COLOR_ACCENT or COLOR_OFF },
			knob = { Position = value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) },
		}

		if not animate then
			track.BackgroundColor3 = goal.track.BackgroundColor3
			knob.Position = goal.knob.Position
			return
		end

		local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
		tweenService:Create(track, info, goal.track):Play()
		tweenService:Create(knob, info, goal.knob):Play()
	end

	track.MouseButton1Click:Connect(function()
		value = not value
		render(true)
		callback(value)
	end)

	render(false)
	callback(value)
end

createToggle("Auto Ultimate", 56, false, function(value)
	state.enabled = value
end)

createToggle("Platform", 106, true, function(value)
	platform.Parent = value and workspace or nil
end)

createLabel("MATERIAL", 160, menu)

local materialList = create("ScrollingFrame", {
	Size = UDim2.new(1, -24, 0, 112),
	Position = UDim2.new(0, 12, 0, 182),
	BackgroundColor3 = COLOR_PANEL,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, menu)
round(materialList, 10)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
}, materialList)
create("UIGridLayout", {
	CellSize = UDim2.new(0.5, -4, 0, 26),
	CellPadding = UDim2.fromOffset(6, 6),
}, materialList)

local materialButtons = {}

local function selectMaterial(name)
	platform.Material = Enum.Material[name]

	for buttonName, button in pairs(materialButtons) do
		button.BackgroundColor3 = buttonName == name and COLOR_ACCENT or COLOR_OFF
	end
end

for _, name in ipairs(MATERIALS) do
	local button = create("TextButton", {
		BackgroundColor3 = COLOR_OFF,
		Text = name,
		TextColor3 = COLOR_TEXT,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
	}, materialList)
	round(button, 6)

	materialButtons[name] = button
	button.MouseButton1Click:Connect(function()
		selectMaterial(name)
	end)
end

selectMaterial("SmoothPlastic")

createLabel("COLOR", 306, menu)

local colorRow = create("Frame", {
	Size = UDim2.new(1, -24, 0, 34),
	Position = UDim2.new(0, 12, 0, 328),
	BackgroundTransparency = 1,
}, menu)
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 8),
	VerticalAlignment = Enum.VerticalAlignment.Center,
}, colorRow)

for _, color in ipairs(PLATFORM_COLORS) do
	local swatch = create("TextButton", {
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = color,
		Text = "",
	}, colorRow)
	round(swatch, 15)
	create("UIStroke", { Color = COLOR_TEXT, Thickness = 1, Transparency = 0.6 }, swatch)

	swatch.MouseButton1Click:Connect(function()
		platform.Color = color
	end)
end

local openButton = create("TextButton", {
	Size = UDim2.fromOffset(64, 28),
	Position = UDim2.new(0, 20, 0.5, -14),
	BackgroundColor3 = COLOR_ACCENT,
	Text = "Open",
	TextColor3 = COLOR_TEXT,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	AutoButtonColor = false,
}, screenGui)
round(openButton, 8)

local function setMenuVisible(visible)
	menu.Visible = visible
	openButton.Text = visible and "Close" or "Open"
end

closeButton.MouseButton1Click:Connect(function()
	setMenuVisible(false)
end)

local dragging, dragged, dragStart, startPosition = false, false, nil, nil

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

openButton.InputBegan:Connect(function(input)
	if not isPointer(input) then
		return
	end

	dragging, dragged = true, false
	dragStart = input.Position
	startPosition = openButton.Position
end)

table.insert(state.connections, userInputService.InputChanged:Connect(function(input)
	local isMove = input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
	if not dragging or not isMove then
		return
	end

	local delta = input.Position - dragStart
	if delta.Magnitude > DRAG_THRESHOLD then
		dragged = true
	end

	if dragged then
		openButton.Position = UDim2.new(
			startPosition.X.Scale, startPosition.X.Offset + delta.X,
			startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
		)
	end
end))

table.insert(state.connections, userInputService.InputEnded:Connect(function(input)
	if not dragging or not isPointer(input) then
		return
	end

	dragging = false

	if not dragged then
		setMenuVisible(not menu.Visible)
	end
end))

local function isOverlayActive(object)
	if object:IsA("TextLabel") then
		return object.Visible and object.Text:match("%d") ~= nil
	end

	return object:IsA("GuiObject") and object.Visible and object.AbsoluteSize.X > 1 and object.AbsoluteSize.Y > 1
end

local function isSpecialOnCooldown()
	local main = localPlayer.PlayerGui:FindFirstChild("Main")
	local special = main and main.Controls.Ultimate:FindFirstChild("Special")

	if not special then
		return true
	end

	for _, object in ipairs(special:GetDescendants()) do
		if object:IsA("TextLabel") or object.Name == "Cooldown" then
			if isOverlayActive(object) then
				return true
			end
		end
	end

	return false
end

local function isCannonOnCooldown()
	local main = localPlayer.PlayerGui:FindFirstChild("Main")
	local button = main and main.Controls.Moveset:FindFirstChild("Ultra Cannon")
	local cooldown = button and button:FindFirstChild("Cooldown")

	if not cooldown then
		return true
	end

	return isOverlayActive(cooldown)
end

local function isSpecialActive()
	local characters = workspace:FindFirstChild("Characters")
	local character = characters and characters:FindFirstChild(localPlayer.Name)
	local info = character and character:FindFirstChild("Info")

	return info ~= nil and info:FindFirstChild("Offload") ~= nil
end

local function getCannonTool()
	local character = localPlayer.Character
	local moveset = character and character:FindFirstChild("Moveset")

	if not moveset then
		return nil
	end

	return moveset:FindFirstChild("Ultra Cannon") or moveset:GetChildren()[2]
end

task.spawn(function()
	while screenGui.Parent do
		task.wait(0.1)

		if not state.enabled or isSpecialOnCooldown() then
			continue
		end

		rightActivated:FireServer()

		local pressedAt = os.clock()
		while state.enabled and not isSpecialActive() and os.clock() - pressedAt < OFFLOAD_TIMEOUT do
			task.wait()
		end

		local cannonTool = getCannonTool()
		if isSpecialActive() and cannonTool and not isCannonOnCooldown() then
			ultraActivated:FireServer(cannonTool)
			ultraDeactivated:FireServer(cannonTool, false)
		end

		local startedAt = os.clock()
		while state.enabled and not isSpecialOnCooldown() and os.clock() - startedAt < 1 do
			task.wait()
		end
	end
end)
