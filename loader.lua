-- Material 3 Language Picker → запускает ТВОЙ скрипт

local Colors = {
    Primary = Color3.fromRGB(208, 188, 255),
    OnPrimary = Color3.fromRGB(56, 30, 114),
    PrimaryContainer = Color3.fromRGB(79, 55, 139),
    Surface = Color3.fromRGB(20, 18, 24),
    SurfaceVariant = Color3.fromRGB(73, 69, 79),
    OnSurface = Color3.fromRGB(230, 225, 229),
    OnSurfaceVariant = Color3.fromRGB(202, 196, 208),
    OutlineVariant = Color3.fromRGB(73, 69, 79),
}

-- ============================================================
--   ВСТАВЬ СВОЙ СКРИПТ СЮДА
--   ru → что запустится при выборе "Русский"
--   en → что запустится при выборе "English"
-- ============================================================
local MyScripts = {
    ru = [[
        -- ТВОЙ СКРИПТ для русского
        loadstring(game:HttpGet("https://example.com/ru_script.lua"))()
    ]],
    en = [[
        -- ТВОЙ СКРИПТ для английского
        loadstring(game:HttpGet("https://example.com/en_script.lua"))()
    ]],
}
-- ============================================================

local Locales = {
    ru = {
        question = "Выберите язык",
        subtitle = "Select language",
        loading = "Запуск...",
    },
    en = {
        question = "Select language",
        subtitle = "Выберите язык",
        loading = "Launching...",
    },
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("Material3Menu") then
    CoreGui.Material3Menu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Material3Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 330)
Main.Position = UDim2.new(0.5, -210, 0.5, -165)
Main.BackgroundColor3 = Colors.Surface
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 28)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.OutlineVariant
MainStroke.Thickness = 1
MainStroke.Parent = Main

-- Крестик
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -52, 0, 20)
CloseBtn.BackgroundColor3 = Colors.SurfaceVariant
CloseBtn.BackgroundTransparency = 0.6
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.OnSurfaceVariant
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 5
CloseBtn.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(120, 60, 60),
        BackgroundTransparency = 0.2,
    }):Play()
end)

CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.SurfaceVariant,
        BackgroundTransparency = 0.6,
    }):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -210, 1.5, 0)
    }):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 30)
Title.Position = UDim2.new(0, 24, 0, 28)
Title.BackgroundTransparency = 1
Title.Text = Locales.ru.question
Title.TextColor3 = Colors.OnSurface
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -100, 0, 18)
Subtitle.Position = UDim2.new(0, 24, 0, 60)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = Locales.ru.subtitle
Subtitle.TextColor3 = Colors.OnSurfaceVariant
Subtitle.TextSize = 13
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

local LangContainer = Instance.new("Frame")
LangContainer.Size = UDim2.new(1, -48, 0, 160)
LangContainer.Position = UDim2.new(0, 24, 0, 110)
LangContainer.BackgroundTransparency = 1
LangContainer.Parent = Main

local LangLayout = Instance.new("UIListLayout")
LangLayout.Padding = UDim.new(0, 12)
LangLayout.SortOrder = Enum.SortOrder.LayoutOrder
LangLayout.Parent = LangContainer

local function makeLangButton(text, flag, sub, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 72)
    Btn.BackgroundColor3 = Colors.SurfaceVariant
    Btn.BackgroundTransparency = 0.4
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = order
    Btn.Parent = LangContainer

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 20)
    C.Parent = Btn

    local S = Instance.new("UIStroke")
    S.Color = Colors.OutlineVariant
    S.Thickness = 1
    S.Parent = Btn

    local Flag = Instance.new("TextLabel")
    Flag.Name = "Flag"
    Flag.Size = UDim2.new(0, 40, 0, 40)
    Flag.Position = UDim2.new(0, 20, 0.5, -20)
    Flag.BackgroundTransparency = 1
    Flag.Text = flag
    Flag.TextSize = 26
    Flag.Font = Enum.Font.GothamBold
    Flag.TextColor3 = Colors.OnSurface
    Flag.Parent = Btn

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -100, 0, 24)
    Label.Position = UDim2.new(0, 72, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.OnSurface
    Label.TextSize = 18
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Btn

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Name = "SubLabel"
    SubLabel.Size = UDim2.new(1, -100, 0, 16)
    SubLabel.Position = UDim2.new(0, 72, 0, 42)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = sub
    SubLabel.TextColor3 = Colors.OnSurfaceVariant
    SubLabel.TextSize = 12
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Btn

    local Arrow = Instance.new("TextLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 30, 0, 30)
    Arrow.Position = UDim2.new(1, -45, 0.5, -15)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "›"
    Arrow.TextSize = 28
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextColor3 = Colors.Primary
    Arrow.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.2,
            BackgroundColor3 = Colors.PrimaryContainer
        }):Play()
    end)

    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.4,
            BackgroundColor3 = Colors.SurfaceVariant
        }):Play()
    end)

    return Btn
end

local BtnRU = makeLangButton("Русский", "🇷🇺", "Russian", 1)
local BtnEN = makeLangButton("English", "🇬🇧", "Английский", 2)

local function launchScript(lang, chosenBtn)
    local t = Locales[lang]

    -- Убираем текст
    TweenService:Create(Title, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
    TweenService:Create(Subtitle, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()

    local otherBtn = (chosenBtn == BtnRU) and BtnEN or BtnRU
    TweenService:Create(otherBtn, TweenInfo.new(0.25), {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0)
    }):Play()
    for _, child in ipairs(otherBtn:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
        end
    end

    TweenService:Create(chosenBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, -60),
        BackgroundColor3 = Colors.PrimaryContainer,
        BackgroundTransparency = 0.1
    }):Play()

    local label = chosenBtn:FindFirstChild("Label")
    local subLabel = chosenBtn:FindFirstChild("SubLabel")
    local arrow = chosenBtn:FindFirstChild("Arrow")

    if label then label.Text = t.loading end
    if subLabel then TweenService:Create(subLabel, TweenInfo.new(0.2), { TextTransparency = 1 }):Play() end
    if arrow then TweenService:Create(arrow, TweenInfo.new(0.2), { TextTransparency = 1 }):Play() end

    task.wait(0.5)

    -- === ЗАПУСК ТВОЕГО СКРИПТА ===
    local code = MyScripts[lang]
    if code and code ~= "" then
        local func, err = loadstring(code)
        if func then
            local ok, runErr = pcall(func)
            if not ok then
                warn("[Material3] Ошибка: " .. tostring(runErr))
            end
        else
            warn("[Material3] Ошибка компиляции: " .. tostring(err))
        end
    end
    -- =============================

    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -210, 1.5, 0)
    }):Play()

    task.wait(0.4)
    ScreenGui:Destroy()
end

BtnRU.MouseButton1Click:Connect(function()
    launchScript("ru", BtnRU)
end)

BtnEN.MouseButton1Click:Connect(function()
    launchScript("en", BtnEN)
end)

-- Перетаскивание
local dragging, dragStart, startPos
local header = Instance.new("TextButton")
header.Size = UDim2.new(1, -60, 0, 90)
header.BackgroundTransparency = 1
header.Text = ""
header.ZIndex = 1
header.Parent = Main

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

Main.Position = UDim2.new(0.5, -210, 1.5, 0)
Main:TweenPosition(
    UDim2.new(0.5, -210, 0.5, -165),
    Enum.EasingDirection.Out,
    Enum.EasingStyle.Quint,
    0.5,
    true
)
