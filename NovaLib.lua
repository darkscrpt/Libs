--[[
    NovaUI - A modern Roblox UI Library
    Inspired by Rayfield, Obsidian, and other popular UI libraries
    Version: 1.0.0
    Author: NovaUI
    License: MIT
]]

--==============================================================
-- SERVICES
--==============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--==============================================================
-- CONFIGURATION
--==============================================================
local Config = {
    Theme = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(35, 35, 42),
        Tertiary = Color3.fromRGB(45, 45, 55),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(102, 115, 255),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(160, 160, 175),
        Border = Color3.fromRGB(60, 60, 70),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(240, 180, 60),
        Error = Color3.fromRGB(230, 80, 80),
        ToggleOn = Color3.fromRGB(88, 101, 242),
        ToggleOff = Color3.fromRGB(70, 70, 80),
    },
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    AnimationSpeed = 0.2,
    CornerRadius = 8,
    ElementHeight = 32,
    ElementSpacing = 6,
    Padding = 12,
    DefaultSize = Vector2.new(560, 460),
    MinWidth = 400,
    MinHeight = 300,
}

--==============================================================
-- UTILITIES
--==============================================================
local Utility = {}

function Utility.Create(className, properties)
    local instance = Instance.new(className)
    for key, value in pairs(properties or {}) do
        if key ~= "Parent" then
            instance[key] = value
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility.Tween(instance, properties, duration, style, direction)
    duration = duration or Config.AnimationSpeed
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

function Utility.Round(number, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(number * mult + 0.5) / mult
end

function Utility.GetTextBounds(text, font, size, width)
    return game:GetService("TextService"):GetTextSize(text, size, font, width)
end

function Utility.LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

function Utility.HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
    )
end

--==============================================================
-- UI LIBRARY CORE
--==============================================================
local NovaUI = {}
NovaUI.__index = NovaUI
NovaUI.Flags = {}
NovaUI.Windows = {}
NovaUI.Notifications = {}
NovaUI.Theme = Config.Theme
NovaUI.Config = Config
NovaUI.Utility = Utility

--==============================================================
-- DRAGGING SYSTEM
--==============================================================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--==============================================================
-- RESIZE SYSTEM
--==============================================================
local function MakeResizable(frame, minWidth, minHeight)
    minWidth = minWidth or 300
    minHeight = minHeight or 200

    local resizeHandle = Utility.Create("TextButton", {
        Name = "ResizeHandle",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        Text = "",
        ZIndex = 10,
    })

    local icon = Utility.Create("ImageLabel", {
        Parent = resizeHandle,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://5053178234",
        ImageColor3 = Config.Theme.SubText,
        ImageTransparency = 0.4,
    })

    local resizing = false
    local startSize, startPos, startMouse

    resizeHandle.MouseEnter:Connect(function()
        icon.ImageTransparency = 0
    end)

    resizeHandle.MouseLeave:Connect(function()
        icon.ImageTransparency = 0.4
    end)

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = frame.AbsoluteSize
            startMouse = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            local newWidth = math.max(minWidth, startSize.X + delta.X)
            local newHeight = math.max(minHeight, startSize.Y + delta.Y)
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

--==============================================================
-- NOTIFICATION SYSTEM
--==============================================================
local function CreateNotification(title, content, duration)
    duration = duration or 5

    local screenGui = NovaUI.NotificationGui
    if not screenGui then
        screenGui = Utility.Create("ScreenGui", {
            Name = "NovaUI_Notifications",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui,
        })
        NovaUI.NotificationGui = screenGui
    end

    local holder = Utility.Create("Frame", {
        Name = "NotificationHolder",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 340, 0, 0),
        Position = UDim2.new(1, -360, 1, -20),
        AnchorPoint = Vector2.new(0, 1),
    })

    -- Shift existing notifications up
    for _, child in ipairs(screenGui:GetChildren()) do
        if child:IsA("Frame") and child ~= holder and child.Name == "NotificationHolder" then
            local currentY = child.Position.Y.Offset
            Utility.Tween(child, { Position = UDim2.new(1, -360, 1, currentY - 80) }, 0.2)
        end
    end

    local main = Utility.Create("Frame", {
        Name = "Main",
        Parent = holder,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70),
        ClipsDescendants = true,
    })

    Utility.Create("UICorner", {
        Parent = main,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("UIStroke", {
        Parent = main,
        Color = Config.Theme.Border,
        Thickness = 1,
    })

    local accent = Utility.Create("Frame", {
        Name = "Accent",
        Parent = main,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
    })

    Utility.Create("UICorner", {
        Parent = accent,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 10),
        Size = UDim2.new(1, -30, 0, 18),
        Font = Config.FontBold,
        Text = title,
        TextColor3 = Config.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Utility.Create("TextLabel", {
        Name = "Content",
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 30),
        Size = UDim2.new(1, -30, 0, 32),
        Font = Config.Font,
        Text = content,
        TextColor3 = Config.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    -- Progress bar
    local progressBg = Utility.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
    })

    local progress = Utility.Create("Frame", {
        Parent = progressBg,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
    })

    Utility.Tween(progress, { Size = UDim2.new(0, 0, 1, 0) }, duration)

    task.delay(duration, function()
        Utility.Tween(main, { BackgroundTransparency = 1 }, 0.3)
        Utility.Tween(holder, { Position = UDim2.new(1, -360, 1, holder.Position.Y.Offset - 80) }, 0.3)
        task.wait(0.3)
        holder:Destroy()
    end)

    return holder
end

NovaUI.Notify = CreateNotification

--==============================================================
-- WINDOW CLASS
--==============================================================
function NovaUI:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "NovaUI Window"
    local windowSize = options.Size or Config.DefaultSize
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

    local self = setmetatable({}, NovaUI)
    self.Name = windowName
    self.Tabs = {}
    self.ActiveTab = nil
    self.Elements = {}
    self.Flags = {}
    self.Minimized = false

    -- ScreenGui setup
    local screenGui = Utility.Create("ScreenGui", {
        Name = "NovaUI_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    self.ScreenGui = screenGui

    -- Blur background
    local blur = Utility.Create("BlurEffect", {
        Parent = game:GetService("Lighting"),
        Size = 0,
        Name = "NovaUI_Blur_" .. HttpService:GenerateGUID(false),
    })
    self.Blur = blur

    -- Main window frame
    local main = Utility.Create("Frame", {
        Name = "Main",
        Parent = screenGui,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        Position = UDim2.new(0.5, -windowSize.X / 2, 0.5, -windowSize.Y / 2),
        ClipsDescendants = true,
    })
    self.Main = main

    Utility.Create("UICorner", {
        Parent = main,
        CornerRadius = UDim.new(0, Config.CornerRadius),
    })

    Utility.Create("UIStroke", {
        Parent = main,
        Color = Config.Theme.Border,
        Thickness = 1,
    })

    -- Header
    local header = Utility.Create("Frame", {
        Name = "Header",
        Parent = main,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
    })
    self.Header = header

    Utility.Create("UICorner", {
        Parent = header,
        CornerRadius = UDim.new(0, Config.CornerRadius),
    })

    local headerFix = Utility.Create("Frame", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -Config.CornerRadius),
        Size = UDim2.new(1, 0, 0, Config.CornerRadius),
    })

    -- Window title
    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Config.FontBold,
        Text = windowName,
        TextColor3 = Config.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Accent dot
    Utility.Create("Frame", {
        Name = "Dot",
        Parent = header,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0.5, -3),
        Size = UDim2.new(0, 6, 0, 6),
    })

    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Name = "Close",
        Parent = header,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -34, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Text = "",
        AutoButtonColor = false,
    })

    Utility.Create("UICorner", {
        Parent = closeBtn,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("TextLabel", {
        Parent = closeBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.FontBold,
        Text = "×",
        TextColor3 = Config.Theme.SubText,
        TextSize = 18,
    })

    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, { BackgroundColor3 = Config.Theme.Error }, 0.15)
    end)

    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    -- Minimize button
    local minBtn = Utility.Create("TextButton", {
        Name = "Minimize",
        Parent = header,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -62, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Text = "",
        AutoButtonColor = false,
    })

    Utility.Create("UICorner", {
        Parent = minBtn,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("TextLabel", {
        Parent = minBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.FontBold,
        Text = "—",
        TextColor3 = Config.Theme.SubText,
        TextSize = 14,
    })

    minBtn.MouseEnter:Connect(function()
        Utility.Tween(minBtn, { BackgroundColor3 = Config.Theme.Accent }, 0.15)
    end)

    minBtn.MouseLeave:Connect(function()
        Utility.Tween(minBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
    end)

    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    -- Tab container (left sidebar)
    local tabContainer = Utility.Create("Frame", {
        Name = "TabContainer",
        Parent = main,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40),
    })
    self.TabContainer = tabContainer

    local tabScroll = Utility.Create("ScrollingFrame", {
        Name = "TabScroll",
        Parent = tabContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    self.TabScroll = tabScroll

    Utility.Create("UIListLayout", {
        Parent = tabScroll,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Content container (right side)
    local contentContainer = Utility.Create("Frame", {
        Name = "ContentContainer",
        Parent = main,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40),
    })
    self.ContentContainer = contentContainer

    Utility.Create("UIStroke", {
        Parent = contentContainer,
        Color = Config.Theme.Border,
        Thickness = 1,
        Transparency = 0.5,
    })

    -- Make draggable
    MakeDraggable(main, header)

    -- Make resizable
    MakeResizable(main, Config.MinWidth, Config.MinHeight)

    -- Toggle with keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
        end
    end)

    -- Open animation
    main.Size = UDim2.new(0, 0, 0, 0)
    main.BackgroundTransparency = 1
    Utility.Tween(main, {
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        BackgroundTransparency = 0,
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    Utility.Tween(blur, { Size = 12 }, 0.3)

    -- Store window
    table.insert(NovaUI.Windows, self)

    self:SelectTab(nil)
    return self
end

function NovaUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    local targetSize = self.Minimized and UDim2.new(0, self.Main.AbsoluteSize.X, 0, 40)
        or UDim2.new(0, self.Main.AbsoluteSize.X, 0, self.Main.AbsoluteSize.Y)

    if self.Minimized then
        Utility.Tween(self.Main, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 40) }, 0.25)
        self.TabContainer.Visible = false
        self.ContentContainer.Visible = false
    else
        Utility.Tween(self.Main, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 460) }, 0.25)
        task.wait(0.1)
        self.TabContainer.Visible = true
        self.ContentContainer.Visible = true
    end
end

function NovaUI:Destroy()
    if self.Blur then
        Utility.Tween(self.Blur, { Size = 0 }, 0.3)
        task.delay(0.3, function()
            if self.Blur then self.Blur:Destroy() end
        end)
    end

    Utility.Tween(self.Main, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    task.delay(0.3, function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end)

    for i, w in ipairs(NovaUI.Windows) do
        if w == self then
            table.remove(NovaUI.Windows, i)
            break
        end
    end
end

--==============================================================
-- TAB CLASS
--==============================================================
function NovaUI:CreateTab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or nil

    local tab = {}
    tab.Name = tabName
    tab.Window = self
    tab.Elements = {}
    tab.Container = nil
    tab.Button = nil

    -- Tab button
    local button = Utility.Create("TextButton", {
        Name = tabName .. "_Tab",
        Parent = self.TabScroll,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Text = "",
        AutoButtonColor = false,
    })
    tab.Button = button

    Utility.Create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 6),
    })

    local iconLabel = nil
    if tabIcon then
        iconLabel = Utility.Create("ImageLabel", {
            Name = "Icon",
            Parent = button,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = tabIcon,
            ImageColor3 = Config.Theme.SubText,
        })
    end

    local label = Utility.Create("TextLabel", {
        Name = "Label",
        Parent = button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, tabIcon and 34 or 14, 0, 0),
        Size = UDim2.new(1, tabIcon and -40 or -20, 1, 0),
        Font = Config.FontMedium,
        Text = tabName,
        TextColor3 = Config.Theme.SubText,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    tab.Label = label

    -- Indicator line
    local indicator = Utility.Create("Frame", {
        Name = "Indicator",
        Parent = button,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 3, 0, 16),
        Visible = false,
    })
    tab.Indicator = indicator

    Utility.Create("UICorner", {
        Parent = indicator,
        CornerRadius = UDim.new(0, 2),
    })

    -- Content container
    local container = Utility.Create("ScrollingFrame", {
        Name = tabName .. "_Container",
        Parent = self.ContentContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    tab.Container = container

    Utility.Create("UIListLayout", {
        Parent = container,
        Padding = UDim.new(0, Config.ElementSpacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    Utility.Create("UIPadding", {
        Parent = container,
        PaddingRight = UDim.new(0, 8),
    })

    -- Button interactions
    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Utility.Tween(button, { BackgroundColor3 = Config.Theme.Secondary }, 0.15)
        end
    end)

    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Utility.Tween(button, { BackgroundColor3 = Config.Theme.Background }, 0.15)
        end
    end)

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    -- Auto select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function NovaUI:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        if t == tab then
            t.Container.Visible = true
            t.Indicator.Visible = true
            Utility.Tween(t.Button, { BackgroundColor3 = Config.Theme.Secondary }, 0.15)
            if t.Label then
                Utility.Tween(t.Label, { TextColor3 = Config.Theme.Text }, 0.15)
            end
        else
            t.Container.Visible = false
            t.Indicator.Visible = false
            Utility.Tween(t.Button, { BackgroundColor3 = Config.Theme.Background }, 0.15)
            if t.Label then
                Utility.Tween(t.Label, { TextColor3 = Config.Theme.SubText }, 0.15)
            end
        end
    end
    self.ActiveTab = tab
end

--==============================================================
-- SECTION ELEMENT
--==============================================================
function NovaUI:AddSection(tab, name)
    local section = {}

    local frame = Utility.Create("Frame", {
        Name = "Section_" .. name,
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
    })

    Utility.Create("UICorner", {
        Parent = frame,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Config.FontBold,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Utility.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -9),
        Size = UDim2.new(0, 3, 0, 18),
    })

    section.Frame = frame
    return section
end

--==============================================================
-- ELEMENT FACTORY HELPERS
--==============================================================
local function CreateElementBase(tab, height)
    local frame = Utility.Create("Frame", {
        Name = "Element",
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or Config.ElementHeight),
    })

    Utility.Create("UICorner", {
        Parent = frame,
        CornerRadius = UDim.new(0, 6),
    })

    return frame
end

--==============================================================
-- BUTTON ELEMENT
--==============================================================
function NovaUI:AddButton(tab, options)
    options = options or {}
    local name = options.Name or "Button"
    local callback = options.Callback or function() end

    local button = Utility.Create("TextButton", {
        Name = "Button_" .. name,
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Config.ElementHeight),
        Text = "",
        AutoButtonColor = false,
    })

    Utility.Create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("TextLabel", {
        Parent = button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    button.MouseEnter:Connect(function()
        Utility.Tween(button, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
    end)

    button.MouseLeave:Connect(function()
        Utility.Tween(button, { BackgroundColor3 = Config.Theme.Secondary }, 0.15)
    end)

    button.MouseButton1Click:Connect(function()
        Utility.Tween(button, { BackgroundColor3 = Config.Theme.Accent }, 0.1)
        task.delay(0.1, function()
            Utility.Tween(button, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
        end)
        pcall(callback)
    end)

    return { Instance = button }
end

--==============================================================
-- TOGGLE ELEMENT
--==============================================================
function NovaUI:AddToggle(tab, options)
    options = options or {}
    local name = options.Name or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end
    local flag = options.Flag

    local frame = CreateElementBase(tab)

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local toggleBg = Utility.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default and Config.Theme.ToggleOn or Config.Theme.ToggleOff,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -56, 0.5, -10),
        Size = UDim2.new(0, 44, 0, 20),
    })

    Utility.Create("UICorner", {
        Parent = toggleBg,
        CornerRadius = UDim.new(1, 0),
    })

    local knob = Utility.Create("Frame", {
        Parent = toggleBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
    })

    Utility.Create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(1, 0),
    })

    local state = default

    local function setState(value, fireCallback)
        state = value
        if state then
            Utility.Tween(toggleBg, { BackgroundColor3 = Config.Theme.ToggleOn }, 0.2)
            Utility.Tween(knob, { Position = UDim2.new(1, -18, 0.5, -8) }, 0.2)
        else
            Utility.Tween(toggleBg, { BackgroundColor3 = Config.Theme.ToggleOff }, 0.2)
            Utility.Tween(knob, { Position = UDim2.new(0, 2, 0.5, -8) }, 0.2)
        end
        if fireCallback then
            pcall(callback, state)
        end
    end

    local clickBtn = Utility.Create("TextButton", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
    })

    clickBtn.MouseButton1Click:Connect(function()
        setState(not state, true)
    end)

    local element = {
        Instance = frame,
        Set = function(value)
            setState(value, false)
        end,
        Get = function()
            return state
        end,
        Toggle = function()
            setState(not state, true)
        end,
    }

    if flag then
        NovaUI.Flags[flag] = element
    end

    if default then
        pcall(callback, state)
    end

    return element
end

--==============================================================
-- SLIDER ELEMENT
--==============================================================
function NovaUI:AddSlider(tab, options)
    options = options or {}
    local name = options.Name or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local suffix = options.Suffix or ""
    local callback = options.Callback or function() end
    local flag = options.Flag

    local frame = CreateElementBase(tab, 48)

    Utility.Create("TextLabel", {
        Name = "NameLabel",
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(0.7, 0, 0, 16),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local valueLabel = Utility.Create("TextLabel", {
        Name = "ValueLabel",
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 6),
        Size = UDim2.new(0.3, -12, 0, 16),
        Font = Config.FontMedium,
        Text = tostring(default) .. suffix,
        TextColor3 = Config.Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local barBg = Utility.Create("Frame", {
        Name = "BarBg",
        Parent = frame,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 1, -20),
        Size = UDim2.new(1, -24, 0, 6),
    })

    Utility.Create("UICorner", {
        Parent = barBg,
        CornerRadius = UDim.new(1, 0),
    })

    local percentage = (default - min) / (max - min)
    percentage = math.clamp(percentage, 0, 1)

    local barFill = Utility.Create("Frame", {
        Name = "BarFill",
        Parent = barBg,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(percentage, 0, 1, 0),
    })

    Utility.Create("UICorner", {
        Parent = barFill,
        CornerRadius = UDim.new(1, 0),
    })

    local knob = Utility.Create("Frame", {
        Name = "Knob",
        Parent = barBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(percentage, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
    })

    Utility.Create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(1, 0),
    })

    local value = default
    local dragging = false

    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local newValue = Utility.Round(min + (max - min) * relX, options.Decimals or 0)
        if newValue ~= value then
            value = newValue
            valueLabel.Text = tostring(value) .. suffix
            Utility.Tween(barFill, { Size = UDim2.new(relX, 0, 1, 0) }, 0.05)
            Utility.Tween(knob, { Position = UDim2.new(relX, 0, 0.5, 0) }, 0.05)
            pcall(callback, value)
        end
    end

    local hitbox = Utility.Create("TextButton", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -32),
        Size = UDim2.new(1, 0, 0, 28),
        Text = "",
    })

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local element = {
        Instance = frame,
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local p = (v - min) / (max - min)
            valueLabel.Text = tostring(v) .. suffix
            Utility.Tween(barFill, { Size = UDim2.new(p, 0, 1, 0) }, 0.15)
            Utility.Tween(knob, { Position = UDim2.new(p, 0, 0.5, 0) }, 0.15)
        end,
        Get = function()
            return value
        end,
    }

    if flag then
        NovaUI.Flags[flag] = element
    end

    return element
end

--==============================================================
-- TEXTBOX ELEMENT
--==============================================================
function NovaUI:AddTextbox(tab, options)
    options = options or {}
    local name = options.Name or "Textbox"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter text..."
    local callback = options.Callback or function() end
    local flag = options.Flag

    local frame = CreateElementBase(tab)

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local boxBg = Utility.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.42, 0, 0.5, -12),
        Size = UDim2.new(0.58, -12, 0, 24),
    })

    Utility.Create("UICorner", {
        Parent = boxBg,
        CornerRadius = UDim.new(0, 5),
    })

    local stroke = Utility.Create("UIStroke", {
        Parent = boxBg,
        Color = Config.Theme.Border,
        Thickness = 1,
    })

    local box = Utility.Create("TextBox", {
        Parent = boxBg,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Config.Font,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Config.Theme.SubText,
        TextColor3 = Config.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })

    box.Focused:Connect(function()
        Utility.Tween(stroke, { Color = Config.Theme.Accent }, 0.15)
    end)

    box.FocusLost:Connect(function(enterPressed)
        Utility.Tween(stroke, { Color = Config.Theme.Border }, 0.15)
        if enterPressed then
            pcall(callback, box.Text)
        end
    end)

    box:GetPropertyChangedSignal("Text"):Connect(function()
        pcall(callback, box.Text)
    end)

    local element = {
        Instance = frame,
        Set = function(v)
            box.Text = v
        end,
        Get = function()
            return box.Text
        end,
    }

    if flag then
        NovaUI.Flags[flag] = element
    end

    return element
end

--==============================================================
-- KEYBIND ELEMENT
--==============================================================
function NovaUI:AddKeybind(tab, options)
    options = options or {}
    local name = options.Name or "Keybind"
    local default = options.Default or Enum.KeyCode.E
    local callback = options.Callback or function() end
    local flag = options.Flag

    local frame = CreateElementBase(tab)

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local keyBtn = Utility.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -92, 0.5, -12),
        Size = UDim2.new(0, 80, 0, 24),
        Text = "",
        AutoButtonColor = false,
    })

    Utility.Create("UICorner", {
        Parent = keyBtn,
        CornerRadius = UDim.new(0, 5),
    })

    local keyLabel = Utility.Create("TextLabel", {
        Parent = keyBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.FontMedium,
        Text = default.Name,
        TextColor3 = Config.Theme.Text,
        TextSize = 13,
    })

    local currentKey = default
    local listening = false

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLabel.Text = "..."
        Utility.Tween(keyBtn, { BackgroundColor3 = Config.Theme.Accent }, 0.15)
    end)

    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyLabel.Text = currentKey.Name
                listening = false
                Utility.Tween(keyBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
            end
            return
        end
        if not gameProcessed and input.KeyCode == currentKey then
            pcall(callback)
        end
    end)

    local element = {
        Instance = frame,
        Set = function(key)
            currentKey = key
            keyLabel.Text = key.Name
        end,
        Get = function()
            return currentKey
        end,
        Destroy = function()
            connection:Disconnect()
        end,
    }

    if flag then
        NovaUI.Flags[flag] = element
    end

    return element
end

--==============================================================
-- DROPDOWN ELEMENT
--==============================================================
function NovaUI:AddDropdown(tab, options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local items = options.Items or {}
    local default = options.Default
    local callback = options.Callback or function() end
    local flag = options.Flag

    local frame = CreateElementBase(tab, 40)
    frame.ClipsDescendants = false

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, -9),
        Size = UDim2.new(0.4, 0, 0, 18),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local dropBtn = Utility.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.42, 0, 0.5, -12),
        Size = UDim2.new(0.58, -12, 0, 24),
        Text = "",
        AutoButtonColor = false,
    })

    Utility.Create("UICorner", {
        Parent = dropBtn,
        CornerRadius = UDim.new(0, 5),
    })

    local selectedLabel = Utility.Create("TextLabel", {
        Parent = dropBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Config.Font,
        Text = default or "Select...",
        TextColor3 = Config.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local arrow = Utility.Create("TextLabel", {
        Parent = dropBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -22, 0, 0),
        Size = UDim2.new(0, 16, 1, 0),
        Font = Config.FontBold,
        Text = "▾",
        TextColor3 = Config.Theme.SubText,
        TextSize = 12,
    })

    -- Dropdown list
    local listFrame = Utility.Create("Frame", {
        Parent = self.ScreenGui,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 0),
        Visible = false,
        ZIndex = 50,
    })

    Utility.Create("UICorner", {
        Parent = listFrame,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("UIStroke", {
        Parent = listFrame,
        Color = Config.Theme.Border,
        Thickness = 1,
    })

    local listScroll = Utility.Create("ScrollingFrame", {
        Parent = listFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 4),
        Size = UDim2.new(1, -8, 1, -8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })

    Utility.Create("UIListLayout", {
        Parent = listScroll,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local currentValue = default
    local open = false

    local function updatePosition()
        listFrame.Position = UDim2.new(0, dropBtn.AbsolutePosition.X, 0, dropBtn.AbsolutePosition.Y + 28)
        listFrame.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, math.min(#items * 26 + 8, 150))
    end

    local function rebuildItems()
        for _, child in ipairs(listScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for i, item in ipairs(items) do
            local itemBtn = Utility.Create("TextButton", {
                Parent = listScroll,
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                Text = "",
                AutoButtonColor = false,
            })

            Utility.Create("UICorner", {
                Parent = itemBtn,
                CornerRadius = UDim.new(0, 4),
            })

            Utility.Create("TextLabel", {
                Parent = itemBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Font = Config.Font,
                Text = tostring(item),
                TextColor3 = Config.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            itemBtn.MouseEnter:Connect(function()
                Utility.Tween(itemBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.1)
            end)

            itemBtn.MouseLeave:Connect(function()
                Utility.Tween(itemBtn, { BackgroundColor3 = Config.Theme.Secondary }, 0.1)
            end)

            itemBtn.MouseButton1Click:Connect(function()
                currentValue = item
                selectedLabel.Text = tostring(item)
                listFrame.Visible = false
                open = false
                pcall(callback, item)
            end)
        end
    end

    rebuildItems()

    dropBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            updatePosition()
            listFrame.Visible = true
        else
            listFrame.Visible = false
        end
    end)

    dropBtn.MouseEnter:Connect(function()
        Utility.Tween(dropBtn, { BackgroundColor3 = Config.Theme.Accent }, 0.15)
    end)

    dropBtn.MouseLeave:Connect(function()
        if not open then
            Utility.Tween(dropBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
        end
    end)

    local element = {
        Instance = frame,
        Set = function(v)
            currentValue = v
            selectedLabel.Text = tostring(v)
        end,
        Get = function()
            return currentValue
        end,
        Refresh = function(newItems)
            items = newItems
            rebuildItems()
        end,
        Open = function()
            open = true
            updatePosition()
            listFrame.Visible = true
        end,
        Close = function()
            open = false
            listFrame.Visible = false
        end,
    }

    if flag then
        NovaUI.Flags[flag] = element
    end

    return element
end

--==============================================================
-- LABEL ELEMENT
--==============================================================
function NovaUI:AddLabel(tab, text)
    local frame = Utility.Create("Frame", {
        Parent = tab.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
    })

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.FontMedium,
        Text = text,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local element = {
        Instance = frame,
        Set = function(v)
            frame:FindFirstChildOfClass("TextLabel").Text = v
        end,
        Get = function()
            return frame:FindFirstChildOfClass("TextLabel").Text
        end,
    }

    return element
end

--==============================================================
-- DIVIDER ELEMENT
--==============================================================
function NovaUI:AddDivider(tab)
    local divider = Utility.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
    })

    return { Instance = divider }
end

--==============================================================
-- COLORPICKER ELEMENT
--==============================================================
function NovaUI:AddColorPicker(tab, options)
    options = options or {}
    local name = options.Name or "Color Picker"
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local callback = options.Callback or function() end
    local flag = options.Flag

    local frame = CreateElementBase(tab)

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local colorBtn = Utility.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -66, 0.5, -10),
        Size = UDim2.new(0, 54, 0, 20),
        Text = "",
        AutoButtonColor = false,
    })

    Utility.Create("UICorner", {
        Parent = colorBtn,
        CornerRadius = UDim.new(0, 5),
    })

    local currentColor = default

    colorBtn.MouseButton1Click:Connect(function()
        local pickerGui = Utility.Create("ScreenGui", {
            Parent = CoreGui,
            ResetOnSpawn = false,
        })

        local bg = Utility.Create("Frame", {
            Parent = pickerGui,
            BackgroundColor3 = Config.Theme.Background,
            Size = UDim2.new(0, 200, 0, 160),
            Position = UDim2.new(0, Mouse.X, 0, Mouse.Y),
        })

        Utility.Create("UICorner", {
            Parent = bg,
            CornerRadius = UDim.new(0, 6),
        })

        Utility.Create("UIStroke", {
            Parent = bg,
            Color = Config.Theme.Border,
            Thickness = 1,
        })

        local preview = Utility.Create("Frame", {
            Parent = bg,
            BackgroundColor3 = currentColor,
            Position = UDim2.new(0, 10, 1, -50),
            Size = UDim2.new(1, -20, 0, 36),
        })

        Utility.Create("UICorner", {
            Parent = preview,
            CornerRadius = UDim.new(0, 5),
        })

        local function makeSlider(y, color, label)
            local lbl = Utility.Create("TextLabel", {
                Parent = bg,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, y),
                Size = UDim2.new(0, 16, 0, 16),
                Font = Config.FontBold,
                Text = label,
                TextColor3 = Config.Theme.Text,
                TextSize = 13,
            })

            local bar = Utility.Create("Frame", {
                Parent = bg,
                BackgroundColor3 = Config.Theme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 30, 0, y + 4),
                Size = UDim2.new(1, -40, 0, 8),
            })

            Utility.Create("UICorner", {
                Parent = bar,
                CornerRadius = UDim.new(1, 0),
            })

            local val = currentColor[color == "R" and "R" or color == "G" and "G" or "B"]
            local fill = Utility.Create("Frame", {
                Parent = bar,
                BackgroundColor3 = color == "R" and Color3.fromRGB(255, 80, 80)
                    or color == "G" and Color3.fromRGB(80, 255, 80)
                    or Color3.fromRGB(80, 80, 255),
                BorderSizePixel = 0,
                Size = UDim2.new(val, 0, 1, 0),
            })

            Utility.Create("UICorner", {
                Parent = fill,
                CornerRadius = UDim.new(1, 0),
            })

            local knob = Utility.Create("Frame", {
                Parent = bar,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(val, 0, 0.5, 0),
                Size = UDim2.new(0, 12, 0, 12),
            })

            Utility.Create("UICorner", {
                Parent = knob,
                CornerRadius = UDim.new(1, 0),
            })

            local dragging = false

            local function updateColor(input)
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                currentColor = Color3.new(
                    color == "R" and p or currentColor.R,
                    color == "G" and p or currentColor.G,
                    color == "B" and p or currentColor.B
                )
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                preview.BackgroundColor3 = currentColor
                colorBtn.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
            end

            local hitbox = Utility.Create("TextButton", {
                Parent = bg,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 30, 0, y - 4),
                Size = UDim2.new(1, -40, 0, 16),
                Text = "",
            })

            hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateColor(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateColor(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
        end

        makeSlider(10, "R", "R")
        makeSlider(38, "G", "G")
        makeSlider(66, "B", "B")

        local closeBtn = Utility.Create("TextButton", {
            Parent = bg,
            BackgroundColor3 = Config.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 1, -46),
            Size = UDim2.new(1, -20, 0, 0),
            Text = "",
            AutoButtonColor = false,
        })

        -- Reposition preview/close
        preview.Position = UDim2.new(0, 10, 0, 96)
        preview.Size = UDim2.new(0, 60, 0, 24)

        closeBtn.Position = UDim2.new(0, 80, 0, 96)
        closeBtn.Size = UDim2.new(1, -90, 0, 24)

        Utility.Create("UICorner", {
            Parent = closeBtn,
            CornerRadius = UDim.new(0, 5),
        })

        Utility.Create("TextLabel", {
            Parent = closeBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Config.FontBold,
            Text = "Apply",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
        })

        closeBtn.MouseButton1Click:Connect(function()
            pickerGui:Destroy()
        end)

        MakeDraggable(bg)
    end)

    local element = {
        Instance = frame,
        Set = function(color)
            currentColor = color
            colorBtn.BackgroundColor3 = color
        end,
        Get = function()
            return currentColor
        end,
    }

    if flag then
        NovaUI.Flags[flag] = element
    end

    return element
end

--==============================================================
-- PARAGRAPH ELEMENT
--==============================================================
function NovaUI:AddParagraph(tab, options)
    options = options or {}
    local title = options.Title or ""
    local content = options.Content or ""

    local frame = Utility.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
    })

    Utility.Create("UICorner", {
        Parent = frame,
        CornerRadius = UDim.new(0, 6),
    })

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Config.FontBold,
        Text = title,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local contentLabel = Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -24, 0, 28),
        Font = Config.Font,
        Text = content,
        TextColor3 = Config.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    local element = {
        Instance = frame,
        Set = function(v)
            contentLabel.Text = v
        end,
        Get = function()
            return contentLabel.Text
        end,
    }

    return element
end

--==============================================================
-- SEARCH BAR ELEMENT
--==============================================================
function NovaUI:AddSearchBar(tab, options)
    options = options or {}
    local placeholder = options.Placeholder or "Search..."
    local callback = options.Callback or function() end

    local frame = Utility.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
    })

    Utility.Create("UICorner", {
        Parent = frame,
        CornerRadius = UDim.new(0, 6),
    })

    local stroke = Utility.Create("UIStroke", {
        Parent = frame,
        Color = Config.Theme.Border,
        Thickness = 1,
    })

    local icon = Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Font = Config.FontBold,
        Text = "🔍",
        TextColor3 = Config.Theme.SubText,
        TextSize = 14,
    })

    local box = Utility.Create("TextBox", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Config.Font,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Config.Theme.SubText,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })

    box:GetPropertyChangedSignal("Text"):Connect(function()
        pcall(callback, box.Text)
    end)

    box.Focused:Connect(function()
        Utility.Tween(stroke, { Color = Config.Theme.Accent }, 0.15)
    end)

    box.FocusLost:Connect(function()
        Utility.Tween(stroke, { Color = Config.Theme.Border }, 0.15)
    end)

    return {
        Instance = frame,
        Set = function(v) box.Text = v end,
        Get = function() return box.Text end,
    }
end

--==============================================================
-- FLAG MANAGEMENT
--==============================================================
function NovaUI:GetFlag(flagName)
    return NovaUI.Flags[flagName]
end

function NovaUI:GetFlags()
    return NovaUI.Flags
end

--==============================================================
-- INITIALIZATION
--==============================================================
print("[NovaUI] Loaded version 1.0.0")

return NovaUI
