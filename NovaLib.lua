--[[
    NovaUI v2.0 - Modern Roblox UI Library
    Rewritten for a sharper, cleaner aesthetic.
    Uses icons from icons.rest (Lucide icon set)
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
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--==============================================================
-- CONFIGURATION
--==============================================================
local Config = {
    Theme = {
        Background = Color3.fromRGB(20, 20, 24),
        Secondary = Color3.fromRGB(30, 30, 36),
        Tertiary = Color3.fromRGB(40, 40, 48),
        Quaternary = Color3.fromRGB(50, 50, 60),
        Accent = Color3.fromRGB(120, 80, 255),
        AccentSecondary = Color3.fromRGB(180, 140, 255),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(140, 140, 155),
        Border = Color3.fromRGB(55, 55, 65),
        Success = Color3.fromRGB(80, 220, 130),
        Warning = Color3.fromRGB(255, 180, 70),
        Error = Color3.fromRGB(255, 90, 90),
        ToggleOn = Color3.fromRGB(120, 80, 255),
        ToggleOff = Color3.fromRGB(60, 60, 70),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    AnimationSpeed = 0.25,
    CornerRadius = 10,
    ElementHeight = 34,
    ElementSpacing = 8,
    DefaultSize = Vector2.new(600, 480),
    MinWidth = 420,
    MinHeight = 320,
    IconSize = 16,
}

--==============================================================
-- ICON SYSTEM (icons.rest / Lucide)
--==============================================================
local Icons = {
    -- UI Navigation
    Home = "rbxassetid://10723407383",
    Settings = "rbxassetid://10734898355",
    Info = "rbxassetid://10734904191",
    List = "rbxassetid://10734911770",
    Palette = "rbxassetid://10734922069",
    Wrench = "rbxassetid://10734936564",
    User = "rbxassetid://10734948940",
    
    -- Actions
    Close = "rbxassetid://10734897593",
    Minimize = "rbxassetid://10734897593",
    Check = "rbxassetid://10734897983",
    X = "rbxassetid://10734897983",
    Plus = "rbxassetid://10734905351",
    Search = "rbxassetid://10734940165",
    Refresh = "rbxassetid://10734935063",
    Copy = "rbxassetid://10734898475",
    Eye = "rbxassetid://10734903172",
    EyeOff = "rbxassetid://10734903172",
    
    -- Status
    Success = "rbxassetid://10734897983",
    Warning = "rbxassetid://10734936967",
    Error = "rbxassetid://10734897983",
    Bell = "rbxassetid://10734895955",
    Star = "rbxassetid://10734945940",
    Heart = "rbxassetid://10734905351",
    
    -- Misc
    ChevronDown = "rbxassetid://10734895495",
    ChevronUp = "rbxassetid://10734895495",
    ChevronRight = "rbxassetid://10734895955",
    ChevronLeft = "rbxassetid://10734895955",
    Drag = "rbxassetid://10734911770",
    Maximize = "rbxassetid://10734897593",
    Play = "rbxassetid://10734934538",
    Pause = "rbxassetid://10734922069",
    Save = "rbxassetid://10734934677",
    Trash = "rbxassetid://10734948940",
    Edit = "rbxassetid://10734903172",
}

-- Helper to get an icon (fallback safe)
local function GetIcon(name)
    return Icons[name] or Icons.Info
end

--==============================================================
-- UTILITY FUNCTIONS
--==============================================================
local Utility = {}

function Utility.Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Utility.Tween(inst, props, duration, style, dir)
    duration = duration or Config.AnimationSpeed
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(inst, TweenInfo.new(duration, style, dir), props)
    tween:Play()
    return tween
end

function Utility.Round(num, dec)
    local m = 10 ^ (dec or 0)
    return math.floor(num * m + 0.5) / m
end

function Utility.LerpColor(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

function Utility.GetTextSize(text, font, size, width)
    return TextService:GetTextSize(text, size, font, width or 1000)
end

--==============================================================
-- CORE LIBRARY
--==============================================================
local NovaUI = {}
NovaUI.__index = NovaUI
NovaUI.Flags = {}
NovaUI.Windows = {}
NovaUI.Theme = Config.Theme
NovaUI.Config = Config
NovaUI.Icons = Icons
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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--==============================================================
-- RESIZING SYSTEM
--==============================================================
local function MakeResizable(frame, minW, minH)
    minW = minW or 320
    minH = minH or 240

    local handle = Utility.Create("TextButton", {
        Name = "ResizeHandle",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        Text = "",
        ZIndex = 10,
    })

    Utility.Create("ImageLabel", {
        Parent = handle,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = GetIcon("Drag"),
        ImageColor3 = Config.Theme.SubText,
        ImageTransparency = 0.5,
    })

    local resizing = false
    local startSize, startMouse

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = frame.AbsoluteSize
            startMouse = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            frame.Size = UDim2.new(0, math.max(minW, startSize.X + delta.X), 0, math.max(minH, startSize.Y + delta.Y))
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
local function CreateNotification(title, content, iconName, duration)
    duration = duration or 5
    iconName = iconName or "Bell"

    local screen = NovaUI.NotificationGui
    if not screen then
        screen = Utility.Create("ScreenGui", {
            Name = "NovaUI_Notifications",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui,
        })
        NovaUI.NotificationGui = screen
    end

    local holder = Utility.Create("Frame", {
        Name = "NotificationHolder",
        Parent = screen,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 360, 0, 0),
        Position = UDim2.new(1, -380, 1, -24),
        AnchorPoint = Vector2.new(0, 1),
    })

    -- Shift existing
    for _, child in ipairs(screen:GetChildren()) do
        if child:IsA("Frame") and child ~= holder and child.Name == "NotificationHolder" then
            local y = child.Position.Y.Offset
            Utility.Tween(child, { Position = UDim2.new(1, -380, 1, y - 90) }, 0.25)
        end
    end

    local main = Utility.Create("Frame", {
        Name = "Main",
        Parent = holder,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 76),
        ClipsDescendants = true,
    })

    Utility.Create("UICorner", { Parent = main, CornerRadius = UDim.new(0, 8) })
    Utility.Create("UIStroke", { Parent = main, Color = Config.Theme.Border, Thickness = 1 })

    -- Icon
    local iconFrame = Utility.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0.5, -18),
        Size = UDim2.new(0, 36, 0, 36),
    })
    Utility.Create("UICorner", { Parent = iconFrame, CornerRadius = UDim.new(0, 6) })
    Utility.Create("ImageLabel", {
        Parent = iconFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 16, 0, 16),
        Image = GetIcon(iconName),
        ImageColor3 = Color3.new(1, 1, 1),
    })

    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 58, 0, 12),
        Size = UDim2.new(1, -70, 0, 18),
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
        Position = UDim2.new(0, 58, 0, 32),
        Size = UDim2.new(1, -70, 0, 32),
        Font = Config.Font,
        Text = content,
        TextColor3 = Config.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    -- Progress
    local progBg = Utility.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
    })
    local prog = Utility.Create("Frame", {
        Parent = progBg,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
    })

    Utility.Tween(prog, { Size = UDim2.new(0, 0, 1, 0) }, duration)

    task.delay(duration, function()
        Utility.Tween(main, { BackgroundTransparency = 1 }, 0.3)
        Utility.Tween(holder, { Position = UDim2.new(1, -380, 1, holder.Position.Y.Offset - 90) }, 0.3)
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

    -- ScreenGui
    local screen = Utility.Create("ScreenGui", {
        Name = "NovaUI_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    self.ScreenGui = screen

    -- Blur
    local blur = Utility.Create("BlurEffect", {
        Parent = game:GetService("Lighting"),
        Size = 0,
        Name = "NovaUI_Blur_" .. HttpService:GenerateGUID(false),
    })
    self.Blur = blur

    -- Main Window
    local main = Utility.Create("Frame", {
        Name = "Main",
        Parent = screen,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        Position = UDim2.new(0.5, -windowSize.X / 2, 0.5, -windowSize.Y / 2),
        ClipsDescendants = true,
    })
    self.Main = main

    Utility.Create("UICorner", { Parent = main, CornerRadius = UDim.new(0, Config.CornerRadius) })
    Utility.Create("UIStroke", { Parent = main, Color = Config.Theme.Border, Thickness = 1 })

    -- Shadow (subtle)
    local shadow = Utility.Create("ImageLabel", {
        Name = "Shadow",
        Parent = main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        Image = "rbxassetid://10734896497",
        ImageColor3 = Config.Theme.Shadow,
        ImageTransparency = 0.7,
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 10, 10),
    })

    -- Header
    local header = Utility.Create("Frame", {
        Name = "Header",
        Parent = main,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 44),
    })
    self.Header = header
    Utility.Create("UICorner", { Parent = header, CornerRadius = UDim.new(0, Config.CornerRadius) })
    Utility.Create("Frame", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -Config.CornerRadius),
        Size = UDim2.new(1, 0, 0, Config.CornerRadius),
    })

    -- Title
    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 46, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Config.FontBold,
        Text = windowName,
        TextColor3 = Config.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Window icon dot
    local dot = Utility.Create("Frame", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
    })
    Utility.Create("UICorner", { Parent = dot, CornerRadius = UDim.new(1, 0) })

    -- Close Button
    local closeBtn = Utility.Create("TextButton", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -36, 0.5, -13),
        Size = UDim2.new(0, 26, 0, 26),
        Text = "",
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", { Parent = closeBtn, CornerRadius = UDim.new(0, 7) })
    Utility.Create("ImageLabel", {
        Parent = closeBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(0, 14, 0, 14),
        Image = GetIcon("Close"),
        ImageColor3 = Config.Theme.SubText,
    })
    closeBtn.MouseEnter:Connect(function() Utility.Tween(closeBtn, { BackgroundColor3 = Config.Theme.Error }, 0.15) end)
    closeBtn.MouseLeave:Connect(function() Utility.Tween(closeBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15) end)
    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    -- Minimize Button
    local minBtn = Utility.Create("TextButton", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -68, 0.5, -13),
        Size = UDim2.new(0, 26, 0, 26),
        Text = "",
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", { Parent = minBtn, CornerRadius = UDim.new(0, 7) })
    Utility.Create("ImageLabel", {
        Parent = minBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(0, 14, 0, 14),
        Image = GetIcon("Minimize"),
        ImageColor3 = Config.Theme.SubText,
    })
    minBtn.MouseEnter:Connect(function() Utility.Tween(minBtn, { BackgroundColor3 = Config.Theme.Accent }, 0.15) end)
    minBtn.MouseLeave:Connect(function() Utility.Tween(minBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15) end)
    minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)

    -- Tab Container (Sidebar)
    local tabContainer = Utility.Create("Frame", {
        Name = "TabContainer",
        Parent = main,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(0, 170, 1, -44),
    })
    self.TabContainer = tabContainer

    local tabScroll = Utility.Create("ScrollingFrame", {
        Parent = tabContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    self.TabScroll = tabScroll
    Utility.Create("UIListLayout", { Parent = tabScroll, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

    -- Content Container
    local contentContainer = Utility.Create("Frame", {
        Name = "ContentContainer",
        Parent = main,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 170, 0, 44),
        Size = UDim2.new(1, -170, 1, -44),
    })
    self.ContentContainer = contentContainer
    Utility.Create("UIStroke", { Parent = contentContainer, Color = Config.Theme.Border, Thickness = 1, Transparency = 0.5 })

    MakeDraggable(main, header)
    MakeResizable(main, Config.MinWidth, Config.MinHeight)

    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
            Utility.Tween(main, { BackgroundTransparency = main.Visible and 0 or 1 }, 0.3)
            if blur then Utility.Tween(blur, { Size = main.Visible and 12 or 0 }, 0.3) end
        end
    end)

    -- Open Animation
    main.Size = UDim2.new(0, 0, 0, 0)
    main.BackgroundTransparency = 1
    Utility.Tween(main, { Size = UDim2.new(0, windowSize.X, 0, windowSize.Y), BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Utility.Tween(blur, { Size = 12 }, 0.3)

    table.insert(NovaUI.Windows, self)
    return self
end

function NovaUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        Utility.Tween(self.Main, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 44) }, 0.3)
        task.delay(0.15, function()
            self.TabContainer.Visible = false
            self.ContentContainer.Visible = false
        end)
    else
        Utility.Tween(self.Main, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 480) }, 0.3)
        task.wait(0.1)
        self.TabContainer.Visible = true
        self.ContentContainer.Visible = true
    end
end

function NovaUI:Destroy()
    if self.Blur then
        Utility.Tween(self.Blur, { Size = 0 }, 0.3)
        task.delay(0.3, function() if self.Blur then self.Blur:Destroy() end end)
    end
    Utility.Tween(self.Main, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.35, function() if self.ScreenGui then self.ScreenGui:Destroy() end end)
    for i, w in ipairs(NovaUI.Windows) do
        if w == self then table.remove(NovaUI.Windows, i) break end
    end
end

--==============================================================
-- TAB CLASS
--==============================================================
function NovaUI:CreateTab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or "List"

    local tab = {}
    tab.Name = tabName
    tab.Window = self
    tab.Elements = {}
    tab.Container = nil
    tab.Button = nil

    local button = Utility.Create("TextButton", {
        Name = tabName .. "_Tab",
        Parent = self.TabScroll,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "",
        AutoButtonColor = false,
    })
    tab.Button = button
    Utility.Create("UICorner", { Parent = button, CornerRadius = UDim.new(0, 7) })

    -- Icon
    Utility.Create("ImageLabel", {
        Name = "Icon",
        Parent = button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = GetIcon(tabIcon),
        ImageColor3 = Config.Theme.SubText,
    })
    tab.Icon = button.Icon

    local label = Utility.Create("TextLabel", {
        Name = "Label",
        Parent = button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Config.FontMedium,
        Text = tabName,
        TextColor3 = Config.Theme.SubText,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    tab.Label = label

    -- Indicator
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
    Utility.Create("UICorner", { Parent = indicator, CornerRadius = UDim.new(0, 2) })

    -- Container
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
    Utility.Create("UIListLayout", { Parent = container, Padding = UDim.new(0, Config.ElementSpacing), SortOrder = Enum.SortOrder.LayoutOrder })
    Utility.Create("UIPadding", { Parent = container, PaddingRight = UDim.new(0, 8) })

    -- Interactions
    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then Utility.Tween(button, { BackgroundColor3 = Config.Theme.Secondary }, 0.15) end
    end)
    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then Utility.Tween(button, { BackgroundColor3 = Config.Theme.Background }, 0.15) end
    end)
    button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end

function NovaUI:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        if t == tab then
            t.Container.Visible = true
            t.Indicator.Visible = true
            Utility.Tween(t.Button, { BackgroundColor3 = Config.Theme.Secondary }, 0.15)
            Utility.Tween(t.Label, { TextColor3 = Config.Theme.Text }, 0.15)
            Utility.Tween(t.Icon, { ImageColor3 = Config.Theme.Accent }, 0.15)
        else
            t.Container.Visible = false
            t.Indicator.Visible = false
            Utility.Tween(t.Button, { BackgroundColor3 = Config.Theme.Background }, 0.15)
            Utility.Tween(t.Label, { TextColor3 = Config.Theme.SubText }, 0.15)
            Utility.Tween(t.Icon, { ImageColor3 = Config.Theme.SubText }, 0.15)
        end
    end
    self.ActiveTab = tab
end

--==============================================================
-- SECTION ELEMENT
--==============================================================
function NovaUI:AddSection(tab, name)
    local frame = Utility.Create("Frame", {
        Name = "Section",
        Parent = tab.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
    })

    Utility.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 3, 0, 16),
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

    return { Frame = frame }
end

--==============================================================
-- ELEMENT BASE
--==============================================================
local function CreateElementBase(tab, height)
    local frame = Utility.Create("Frame", {
        Name = "Element",
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or Config.ElementHeight),
    })
    Utility.Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 7) })
    return frame
end

--==============================================================
-- BUTTON ELEMENT
--==============================================================
function NovaUI:AddButton(tab, options)
    options = options or {}
    local name = options.Name or "Button"
    local icon = options.Icon or "Play"
    local callback = options.Callback or function() end

    local btn = Utility.Create("TextButton", {
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Config.ElementHeight),
        Text = "",
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 7) })

    Utility.Create("ImageLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = GetIcon(icon),
        ImageColor3 = Config.Theme.SubText,
    })
    btn.Icon = btn.ImageLabel

    Utility.Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    btn.MouseEnter:Connect(function()
        Utility.Tween(btn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
        Utility.Tween(btn.Icon, { ImageColor3 = Config.Theme.Accent }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Utility.Tween(btn, { BackgroundColor3 = Config.Theme.Secondary }, 0.15)
        Utility.Tween(btn.Icon, { ImageColor3 = Config.Theme.SubText }, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        Utility.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.1)
        task.delay(0.1, function() Utility.Tween(btn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15) end)
        pcall(callback)
    end)

    return { Instance = btn }
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
        Position = UDim2.new(0, 14, 0, 0),
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
        Position = UDim2.new(1, -60, 0.5, -11),
        Size = UDim2.new(0, 46, 0, 22),
    })
    Utility.Create("UICorner", { Parent = toggleBg, CornerRadius = UDim.new(1, 0) })

    local knob = Utility.Create("Frame", {
        Parent = toggleBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -18, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
    })
    Utility.Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local state = default
    local function setState(val, fire)
        state = val
        if state then
            Utility.Tween(toggleBg, { BackgroundColor3 = Config.Theme.ToggleOn }, 0.2)
            Utility.Tween(knob, { Position = UDim2.new(1, -18, 0.5, -9) }, 0.2)
        else
            Utility.Tween(toggleBg, { BackgroundColor3 = Config.Theme.ToggleOff }, 0.2)
            Utility.Tween(knob, { Position = UDim2.new(0, 2, 0.5, -9) }, 0.2)
        end
        if fire then pcall(callback, state) end
    end

    local click = Utility.Create("TextButton", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
    })
    click.MouseButton1Click:Connect(function() setState(not state, true) end)

    local element = {
        Instance = frame,
        Set = function(v) setState(v, false) end,
        Get = function() return state end,
        Toggle = function() setState(not state, true) end,
    }
    if flag then NovaUI.Flags[flag] = element end
    if default then pcall(callback, state) end
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

    local frame = CreateElementBase(tab, 52)

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(0.7, 0, 0, 16),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local valLabel = Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 8),
        Size = UDim2.new(0.3, -14, 0, 16),
        Font = Config.FontMedium,
        Text = tostring(default) .. suffix,
        TextColor3 = Config.Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local barBg = Utility.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 1, -22),
        Size = UDim2.new(1, -28, 0, 6),
    })
    Utility.Create("UICorner", { Parent = barBg, CornerRadius = UDim.new(1, 0) })

    local pct = (default - min) / (max - min)
    pct = math.clamp(pct, 0, 1)

    local fill = Utility.Create("Frame", {
        Parent = barBg,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(pct, 0, 1, 0),
    })
    Utility.Create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

    local knob = Utility.Create("Frame", {
        Parent = barBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(pct, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
    })
    Utility.Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local value = default
    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local newVal = Utility.Round(min + (max - min) * rel, options.Decimals or 0)
        if newVal ~= value then
            value = newVal
            valLabel.Text = tostring(value) .. suffix
            Utility.Tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.05)
            Utility.Tween(knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.05)
            pcall(callback, value)
        end
    end

    local hit = Utility.Create("TextButton", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -34),
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
    })
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local element = {
        Instance = frame,
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local p = (v - min) / (max - min)
            valLabel.Text = tostring(v) .. suffix
            Utility.Tween(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.15)
            Utility.Tween(knob, { Position = UDim2.new(p, 0, 0.5, 0) }, 0.15)
        end,
        Get = function() return value end,
    }
    if flag then NovaUI.Flags[flag] = element end
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
        Position = UDim2.new(0, 14, 0, 0),
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
        Position = UDim2.new(0.44, 0, 0.5, -13),
        Size = UDim2.new(0.56, -14, 0, 26),
    })
    Utility.Create("UICorner", { Parent = boxBg, CornerRadius = UDim.new(0, 6) })
    local stroke = Utility.Create("UIStroke", { Parent = boxBg, Color = Config.Theme.Border, Thickness = 1 })

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

    box.Focused:Connect(function() Utility.Tween(stroke, { Color = Config.Theme.Accent }, 0.15) end)
    box.FocusLost:Connect(function(enter)
        Utility.Tween(stroke, { Color = Config.Theme.Border }, 0.15)
        if enter then pcall(callback, box.Text) end
    end)
    box:GetPropertyChangedSignal("Text"):Connect(function() pcall(callback, box.Text) end)

    local element = {
        Instance = frame,
        Set = function(v) box.Text = v end,
        Get = function() return box.Text end,
    }
    if flag then NovaUI.Flags[flag] = element end
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
        Position = UDim2.new(0, 14, 0, 0),
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
        Position = UDim2.new(1, -96, 0.5, -13),
        Size = UDim2.new(0, 82, 0, 26),
        Text = "",
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", { Parent = keyBtn, CornerRadius = UDim.new(0, 6) })

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

    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyLabel.Text = currentKey.Name
                listening = false
                Utility.Tween(keyBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15)
            end
            return
        end
        if not gpe and input.KeyCode == currentKey then pcall(callback) end
    end)

    local element = {
        Instance = frame,
        Set = function(k) currentKey = k; keyLabel.Text = k.Name end,
        Get = function() return currentKey end,
        Destroy = function() conn:Disconnect() end,
    }
    if flag then NovaUI.Flags[flag] = element end
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

    local frame = CreateElementBase(tab, 44)
    frame.ClipsDescendants = false

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0.5, -9),
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
        Position = UDim2.new(0.44, 0, 0.5, -13),
        Size = UDim2.new(0.56, -14, 0, 26),
        Text = "",
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", { Parent = dropBtn, CornerRadius = UDim.new(0, 6) })

    local selLabel = Utility.Create("TextLabel", {
        Parent = dropBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Config.Font,
        Text = default or "Select...",
        TextColor3 = Config.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Utility.Create("ImageLabel", {
        Parent = dropBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        Image = GetIcon("ChevronDown"),
        ImageColor3 = Config.Theme.SubText,
    })

    local list = Utility.Create("Frame", {
        Parent = self.ScreenGui,
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 220, 0, 0),
        Visible = false,
        ZIndex = 60,
    })
    Utility.Create("UICorner", { Parent = list, CornerRadius = UDim.new(0, 7) })
    Utility.Create("UIStroke", { Parent = list, Color = Config.Theme.Border, Thickness = 1 })

    local scroll = Utility.Create("ScrollingFrame", {
        Parent = list,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    Utility.Create("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

    local current = default
    local open = false

    local function updatePos()
        list.Position = UDim2.new(0, dropBtn.AbsolutePosition.X, 0, dropBtn.AbsolutePosition.Y + 30)
        list.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, math.min(#items * 28 + 10, 160))
    end

    local function rebuild()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, item in ipairs(items) do
            local ib = Utility.Create("TextButton", {
                Parent = scroll,
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 26),
                Text = "",
                AutoButtonColor = false,
            })
            Utility.Create("UICorner", { Parent = ib, CornerRadius = UDim.new(0, 5) })
            Utility.Create("TextLabel", {
                Parent = ib,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Font = Config.Font,
                Text = tostring(item),
                TextColor3 = Config.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            ib.MouseEnter:Connect(function() Utility.Tween(ib, { BackgroundColor3 = Config.Theme.Tertiary }, 0.1) end)
            ib.MouseLeave:Connect(function() Utility.Tween(ib, { BackgroundColor3 = Config.Theme.Secondary }, 0.1) end)
            ib.MouseButton1Click:Connect(function()
                current = item
                selLabel.Text = tostring(item)
                list.Visible = false
                open = false
                pcall(callback, item)
            end)
        end
    end
    rebuild()

    dropBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then updatePos(); list.Visible = true else list.Visible = false end
    end)
    dropBtn.MouseEnter:Connect(function() Utility.Tween(dropBtn, { BackgroundColor3 = Config.Theme.Accent }, 0.15) end)
    dropBtn.MouseLeave:Connect(function()
        if not open then Utility.Tween(dropBtn, { BackgroundColor3 = Config.Theme.Tertiary }, 0.15) end
    end)

    local element = {
        Instance = frame,
        Set = function(v) current = v; selLabel.Text = tostring(v) end,
        Get = function() return current end,
        Refresh = function(newItems) items = newItems; rebuild() end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- LABEL ELEMENT
--==============================================================
function NovaUI:AddLabel(tab, text)
    local frame = Utility.Create("Frame", {
        Parent = tab.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
    })
    local lbl = Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        Font = Config.FontMedium,
        Text = text,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return { Instance = frame, Set = function(v) lbl.Text = v end, Get = function() return lbl.Text end }
end

--==============================================================
-- DIVIDER ELEMENT
--==============================================================
function NovaUI:AddDivider(tab)
    local div = Utility.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
    })
    return { Instance = div }
end

--==============================================================
-- COLORPICKER ELEMENT
--==============================================================
function NovaUI:AddColorPicker(tab, options)
    options = options or {}
    local name = options.Name or "Color"
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local callback = options.Callback or function() end
    local flag = options.Flag

    local frame = CreateElementBase(tab)

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
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
        Position = UDim2.new(1, -70, 0.5, -11),
        Size = UDim2.new(0, 56, 0, 22),
        Text = "",
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", { Parent = colorBtn, CornerRadius = UDim.new(0, 5) })

    local currentColor = default

    colorBtn.MouseButton1Click:Connect(function()
        local pickerGui = Utility.Create("ScreenGui", { Parent = CoreGui, ResetOnSpawn = false })
        local bg = Utility.Create("Frame", {
            Parent = pickerGui,
            BackgroundColor3 = Config.Theme.Background,
            Size = UDim2.new(0, 220, 0, 180),
            Position = UDim2.new(0, Mouse.X, 0, Mouse.Y),
        })
        Utility.Create("UICorner", { Parent = bg, CornerRadius = UDim.new(0, 8) })
        Utility.Create("UIStroke", { Parent = bg, Color = Config.Theme.Border, Thickness = 1 })

        local preview = Utility.Create("Frame", {
            Parent = bg,
            BackgroundColor3 = currentColor,
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(1, -24, 0, 30),
        })
        Utility.Create("UICorner", { Parent = preview, CornerRadius = UDim.new(0, 6) })

        local function makeSlider(y, color, label)
            Utility.Create("TextLabel", {
                Parent = bg,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, y),
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
                Position = UDim2.new(0, 34, 0, y + 4),
                Size = UDim2.new(1, -46, 0, 8),
            })
            Utility.Create("UICorner", { Parent = bar, CornerRadius = UDim.new(1, 0) })

            local val = currentColor[color == "R" and "R" or color == "G" and "G" or "B"]
            local fill = Utility.Create("Frame", {
                Parent = bar,
                BackgroundColor3 = color == "R" and Color3.fromRGB(255, 80, 80) or color == "G" and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(80, 80, 255),
                BorderSizePixel = 0,
                Size = UDim2.new(val, 0, 1, 0),
            })
            Utility.Create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

            local knob = Utility.Create("Frame", {
                Parent = bar,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(val, 0, 0.5, 0),
                Size = UDim2.new(0, 12, 0, 12),
            })
            Utility.Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

            local dragging = false
            local function update(input)
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                currentColor = Color3.new(color == "R" and p or currentColor.R, color == "G" and p or currentColor.G, color == "B" and p or currentColor.B)
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                preview.BackgroundColor3 = currentColor
                colorBtn.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
            end

            local hit = Utility.Create("TextButton", {
                Parent = bg,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 34, 0, y - 6),
                Size = UDim2.new(1, -46, 0, 20),
                Text = "",
            })
            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end

        makeSlider(52, "R", "R")
        makeSlider(80, "G", "G")
        makeSlider(108, "B", "B")

        local close = Utility.Create("TextButton", {
            Parent = bg,
            BackgroundColor3 = Config.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 12, 1, -42),
            Size = UDim2.new(1, -24, 0, 30),
            Text = "",
            AutoButtonColor = false,
        })
        Utility.Create("UICorner", { Parent = close, CornerRadius = UDim.new(0, 6) })
        Utility.Create("TextLabel", {
            Parent = close,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Config.FontBold,
            Text = "Apply",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
        })
        close.MouseButton1Click:Connect(function() pickerGui:Destroy() end)
        MakeDraggable(bg)
    end)

    local element = {
        Instance = frame,
        Set = function(c) currentColor = c; colorBtn.BackgroundColor3 = c end,
        Get = function() return currentColor end,
    }
    if flag then NovaUI.Flags[flag] = element end
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
        Size = UDim2.new(1, 0, 0, 64),
    })
    Utility.Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 7) })

    Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -28, 0, 18),
        Font = Config.FontBold,
        Text = title,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local contentLbl = Utility.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -28, 0, 28),
        Font = Config.Font,
        Text = content,
        TextColor3 = Config.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })
    return { Instance = frame, Set = function(v) contentLbl.Text = v end, Get = function() return contentLbl.Text end }
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
        Size = UDim2.new(1, 0, 0, 34),
    })
    Utility.Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 7) })
    local stroke = Utility.Create("UIStroke", { Parent = frame, Color = Config.Theme.Border, Thickness = 1 })

    Utility.Create("ImageLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = GetIcon("Search"),
        ImageColor3 = Config.Theme.SubText,
    })

    local box = Utility.Create("TextBox", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Config.Font,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Config.Theme.SubText,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    box:GetPropertyChangedSignal("Text"):Connect(function() pcall(callback, box.Text) end)
    box.Focused:Connect(function() Utility.Tween(stroke, { Color = Config.Theme.Accent }, 0.15) end)
    box.FocusLost:Connect(function() Utility.Tween(stroke, { Color = Config.Theme.Border }, 0.15) end)

    return { Instance = frame, Set = function(v) box.Text = v end, Get = function() return box.Text end }
end

--==============================================================
-- FLAG MANAGEMENT
--==============================================================
function NovaUI:GetFlag(name) return NovaUI.Flags[name] end
function NovaUI:GetFlags() return NovaUI.Flags end

--==============================================================
-- INITIALIZATION
--==============================================================
print("[NovaUI v2.0] Loaded with icons.rest support.")

return NovaUI
