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

-- === Material 3 палитра ===
local M3 = {
	Primary = Color3.fromRGB(208, 188, 255),
	OnPrimary = Color3.fromRGB(56, 30, 114),
	PrimaryContainer = Color3.fromRGB(79, 55, 139),
	OnPrimaryContainer = Color3.fromRGB(234, 221, 255),
	SecondaryContainer = Color3.fromRGB(74, 68, 88),
	OnSecondaryContainer = Color3.fromRGB(232, 222, 248),
	Surface = Color3.fromRGB(20, 18, 24),
	SurfaceContainer = Color3.fromRGB(33, 31, 38),
	SurfaceContainerHigh = Color3.fromRGB(43, 41, 48),
	SurfaceVariant = Color3.fromRGB(73, 69, 79),
	OnSurface = Color3.fromRGB(230, 225, 229),
	OnSurfaceVariant = Color3.fromRGB(202, 196, 208),
	Outline = Color3.fromRGB(147, 143, 153),
	OutlineVariant = Color3.fromRGB(73, 69, 79),
	Error = Color3.fromRGB(242, 184, 181),
	OnError = Color3.fromRGB(96, 20, 16),
}

local localPlayer = playersService.LocalPlayer

local servicesFolder = replicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
local rightActivated = servicesFolder:WaitForChild("MechamaruService"):WaitForChild("RE"):WaitForChild("RightActivated")
local ultraEvents = servicesFolder:WaitForChild("UltraCannonService"):WaitForChild("RE")
local ultraActivated = ultraEvents:WaitForChild("Activated")
local ultraDeactivated = ultraEvents:WaitForChild("Deactivated")

for _, key in ipairs({ "autoUltimate", "autoOverload" }) do
	local old = shared[key]

	if old then
		old.enabled = false
		old.gui:Destroy()
		old.platform:Destroy()

		for _, connection in ipairs(old.connections or {}) do
			connection:Disconnect()
		end
	end
end

local state = { enabled = false, connections = {} }
shared.autoOverload = state

local platform = Instance.new("Part")
platform.Name = "OverloadPlatform"
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

local function addStroke(object, color, thickness, transparency)
	create("UIStroke", {
		Color = color or M3.OutlineVariant,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
	}, object)
end

local function createLabel(text, positionY, parent)
	create("TextLabel", {
		Size = UDim2.new(1, -32, 0, 20),
		Position = UDim2.new(0, 16, 0, positionY),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = M3.OnSurfaceVariant,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
end

local screenGui = create("ScreenGui", { Name = "AutoOverload", ResetOnSpawn = false, IgnoreGuiInset = true }, gethui())
state.gui = screenGui


local notice = create("Frame", {
	Name = "Notice",
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromOffset(320, 52),
	Position = UDim2.new(0.5, 0, 0, 60),
	BackgroundColor3 = M3.SurfaceContainerHigh,
	BackgroundTransparency = 0,
	Active = true,
}, screenGui)
round(notice, 16)
addStroke(notice, M3.OutlineVariant, 1, 0)

-- Иконка слева
local noticeIcon = create("TextLabel", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(0, 14, 0.5, -14),
	BackgroundColor3 = M3.PrimaryContainer,
	Text = "!",
	TextColor3 = M3.OnPrimaryContainer,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	BackgroundTransparency = 0,
}, notice)
round(noticeIcon, 14)


local noticeText = create("TextLabel", {
	Size = UDim2.new(1, -110, 1, 0),
	Position = UDim2.new(0, 52, 0, 0),
	BackgroundTransparency = 1,
	Text = "В пустоте есть платформа",
	TextColor3 = M3.OnSurface,
	Font = Enum.Font.GothamMedium,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
}, notice)


local noticeClose = create("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -40, 0.5, -14),
	BackgroundColor3 = M3.SurfaceVariant,
	BackgroundTransparency = 0.5,
	Text = "✕",
	TextColor3 = M3.OnSurfaceVariant,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = false,
	ZIndex = 3,
}, notice)
round(noticeClose, 14)

noticeClose.MouseEnter:Connect(function()
	tweenService:Create(noticeClose, TweenInfo.new(0.15), {
		BackgroundColor3 = M3.Error,
		BackgroundTransparency = 0,
		TextColor3 = M3.OnError,
	}):Play()
end)

noticeClose.MouseLeave:Connect(function()
	tweenService:Create(noticeClose, TweenInfo.new(0.15), {
		BackgroundColor3 = M3.SurfaceVariant,
		BackgroundTransparency = 0.5,
		TextColor3 = M3.OnSurfaceVariant,
	}):Play()
end)

noticeClose.MouseButton1Click:Connect(function()
	notice.Visible = false
end)


local noticeDragging, noticeDragStart, noticeStartPos = false, nil, nil

noticeText.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		noticeDragging = true
		noticeDragStart = input.Position
		noticeStartPos = notice.Position
	end
end)

table.insert(state.connections, userInputService.InputChanged:Connect(function(input)
	if not noticeDragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - noticeDragStart
		notice.Position = UDim2.new(
			noticeStartPos.X.Scale, noticeStartPos.X.Offset + delta.X,
			noticeStartPos.Y.Scale, noticeStartPos.Y.Offset + delta.Y
		)
	end
end))

table.insert(state.connections, userInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		noticeDragging = false
	end
end))


local menu = create("Frame", {
	Size = UDim2.fromOffset(320, 420),
	Position = UDim2.new(0, 100, 0.5, -210),
	BackgroundColor3 = M3.Surface,
	Active = true,
	Draggable = true,
	Visible = false,
}, screenGui)
round(menu, 28)
addStroke(menu, M3.OutlineVariant, 1, 0)

create("TextLabel", {
	Size = UDim2.new(1, -80, 0, 30),
	Position = UDim2.new(0, 24, 0, 22),
	BackgroundTransparency = 1,
	Text = "Overload",
	TextColor3 = M3.OnSurface,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
}, menu)

create("TextLabel", {
	Size = UDim2.new(1, -80, 0, 16),
	Position = UDim2.new(0, 24, 0, 50),
	BackgroundTransparency = 1,
	Text = "Auto Ultimate",
	TextColor3 = M3.OnSurfaceVariant,
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, menu)

local closeButton = create("TextButton", {
	Size = UDim2.fromOffset(36, 36),
	Position = UDim2.new(1, -52, 0, 20),
	BackgroundColor3 = M3.SurfaceContainerHigh,
	BackgroundTransparency = 0,
	Text = "✕",
	TextColor3 = M3.OnSurfaceVariant,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	AutoButtonColor = false,
}, menu)
round(closeButton, 18)

closeButton.MouseEnter:Connect(function()
	tweenService:Create(closeButton, TweenInfo.new(0.15), {
		BackgroundColor3 = M3.Error,
		TextColor3 = M3.OnError,
	}):Play()
end)

closeButton.MouseLeave:Connect(function()
	tweenService:Create(closeButton, TweenInfo.new(0.15), {
		BackgroundColor3 = M3.SurfaceContainerHigh,
		TextColor3 = M3.OnSurfaceVariant,
	}):Play()
end)


local function createToggle(text, positionY, initial, callback)
	local row = create("Frame", {
		Size = UDim2.new(1, -32, 0, 56),
		Position = UDim2.new(0, 16, 0, positionY),
		BackgroundColor3 = M3.SurfaceContainer,
	}, menu)
	round(row, 16)

	create("TextLabel", {
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = M3.OnSurface,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local track = create("TextButton", {
		Size = UDim2.fromOffset(52, 32),
		Position = UDim2.new(1, -68, 0.5, -16),
		BackgroundColor3 = M3.SurfaceVariant,
		Text = "",
		AutoButtonColor = false,
	}, row)
	round(track, 16)

	create("UIStroke", {
		Color = M3.Outline,
		Thickness = 2,
		Transparency = 0,
	}, track)

	local knob = create("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = M3.Outline,
		BorderSizePixel = 0,
	}, track)
	round(knob, 8)

	local value = initial

	local function render(animate)
		local goals = {
			track = {
				BackgroundColor3 = value and M3.Primary or M3.SurfaceVariant,
			},
			knob = {
				Size = value and UDim2.fromOffset(24, 24) or UDim2.fromOffset(16, 16),
				Position = value and UDim2.fromOffset(24, 4) or UDim2.fromOffset(8, 8),
				BackgroundColor3 = value and M3.OnPrimary or M3.Outline,
			},
			stroke = {
				Transparency = value and 1 or 0,
			},
		}

		if not animate then
			track.BackgroundColor3 = goals.track.BackgroundColor3
			knob.Size = goals.knob.Size
			knob.Position = goals.knob.Position
			knob.BackgroundColor3 = goals.knob.BackgroundColor3
			track:FindFirstChildOfClass("UIStroke").Transparency = goals.stroke.Transparency
			return
		end

		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quint)
		tweenService:Create(track, info, goals.track):Play()
		tweenService:Create(knob, info, goals.knob):Play()
		tweenService:Create(track:FindFirstChildOfClass("UIStroke"), info, goals.stroke):Play()
	end

	track.MouseButton1Click:Connect(function()
		value = not value
		render(true)
		callback(value)
	end)

	render(false)
	callback(value)
end

createToggle("Авто Overload", 84, false, function(value)
	state.enabled = value
end)

createToggle("Платформа", 148, true, function(value)
	platform.Parent = value and workspace or nil
	notice.Visible = value
end)

createLabel("МАТЕРИАЛ", 216, menu)

local materialList = create("ScrollingFrame", {
	Size = UDim2.new(1, -32, 0, 110),
	Position = UDim2.new(0, 16, 0, 238),
	BackgroundColor3 = M3.SurfaceContainer,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = M3.Primary,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, menu)
round(materialList, 16)
create("UIPadding", {
	PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
	PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
}, materialList)
create("UIGridLayout", {
	CellSize = UDim2.new(0.5, -4, 0, 30),
	CellPadding = UDim2.fromOffset(6, 6),
}, materialList)

local materialButtons = {}

local function selectMaterial(name)
	platform.Material = Enum.Material[name]

	for buttonName, button in pairs(materialButtons) do
		local isActive = buttonName == name
		if isActive then
			button.BackgroundColor3 = M3.SecondaryContainer
			button.TextColor3 = M3.OnSecondaryContainer
		else
			button.BackgroundColor3 = M3.SurfaceContainerHigh
			button.TextColor3 = M3.OnSurfaceVariant
		end
	end
end

for _, name in ipairs(MATERIALS) do
	local button = create("TextButton", {
		BackgroundColor3 = M3.SurfaceContainerHigh,
		Text = name,
		TextColor3 = M3.OnSurfaceVariant,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		AutoButtonColor = false,
	}, materialList)
	round(button, 8)

	button.MouseEnter:Connect(function()
		if platform.Material ~= Enum.Material[name] then
			tweenService:Create(button, TweenInfo.new(0.15), {
				BackgroundColor3 = M3.SurfaceVariant,
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if platform.Material ~= Enum.Material[name] then
			tweenService:Create(button, TweenInfo.new(0.15), {
				BackgroundColor3 = M3.SurfaceContainerHigh,
			}):Play()
		end
	end)

	materialButtons[name] = button
	button.MouseButton1Click:Connect(function()
		selectMaterial(name)
	end)
end

selectMaterial("SmoothPlastic")

createLabel("ЦВЕТ", 360, menu)

local colorRow = create("Frame", {
	Size = UDim2.new(1, -32, 0, 36),
	Position = UDim2.new(0, 16, 0, 382),
	BackgroundTransparency = 1,
}, menu)
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 8),
	VerticalAlignment = Enum.VerticalAlignment.Center,
}, colorRow)

for _, color in ipairs(PLATFORM_COLORS) do
	local swatch = create("TextButton", {
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = color,
		Text = "",
		AutoButtonColor = false,
	}, colorRow)
	round(swatch, 16)
	create("UIStroke", { Color = M3.OutlineVariant, Thickness = 1, Transparency = 0.3 }, swatch)

	swatch.MouseButton1Click:Connect(function()
		platform.Color = color
	end)

	swatch.MouseEnter:Connect(function()
		tweenService:Create(swatch, TweenInfo.new(0.15), {
			Size = UDim2.fromOffset(36, 36),
		}):Play()
	end)

	swatch.MouseLeave:Connect(function()
		tweenService:Create(swatch, TweenInfo.new(0.15), {
			Size = UDim2.fromOffset(32, 32),
		}):Play()
	end)
end

local openButton = create("TextButton", {
	Size = UDim2.fromOffset(80, 28),
	Position = UDim2.new(0, 20, 0.5, -14),
	BackgroundColor3 = M3.Primary,
	Text = "Открыть",
	TextColor3 = M3.OnPrimary,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	AutoButtonColor = false,
}, screenGui)
round(openButton, 14)

openButton.MouseEnter:Connect(function()
	tweenService:Create(openButton, TweenInfo.new(0.15), {
		BackgroundColor3 = M3.Primary:Lerp(Color3.new(1,1,1), 0.1),
	}):Play()
end)

openButton.MouseLeave:Connect(function()
	tweenService:Create(openButton, TweenInfo.new(0.15), {
		BackgroundColor3 = M3.Primary,
	}):Play()
end)

local function setMenuVisible(visible)
	menu.Visible = visible
	openButton.Text = visible and "Закрыть" or "Открыть"
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
