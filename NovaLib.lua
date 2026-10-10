--[[
    NovaUI v4.0 - Part 1/4: Core Engine
    ====================================
    DO NOT run this file until Part 2, 3, and 4 are appended.
    Each part continues directly from the previous.
]]

--==============================================================
-- SERVICES
--==============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--==============================================================
-- CONFIG
--==============================================================
local Config = {
    Theme = {
        Bg          = Color3.fromRGB(14, 14, 17),
        Panel       = Color3.fromRGB(20, 20, 24),
        Card        = Color3.fromRGB(26, 26, 31),
        Hover       = Color3.fromRGB(34, 34, 40),
        Line        = Color3.fromRGB(42, 42, 48),
        Text        = Color3.fromRGB(235, 235, 240),
        Dim         = Color3.fromRGB(125, 125, 140),
        Accent      = Color3.fromRGB(124, 92, 255),
        AccentSoft  = Color3.fromRGB(160, 130, 255),
        Green       = Color3.fromRGB(80, 220, 120),
        Red         = Color3.fromRGB(255, 85, 85),
        Yellow      = Color3.fromRGB(255, 190, 80),
    },
    Font        = Enum.Font.Gotham,
    FontMedium  = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold,
    Speed       = 0.18,
    Radius      = 6,
    ElemHeight  = 26,
    Spacing     = 4,
    Size        = Vector2.new(440, 340),
    MinSize     = Vector2.new(360, 260),

    -- Loading screen defaults (overridable per-window)
    Loading = {
        Enabled       = true,
        Duration      = 1.6,
        LineColor     = Color3.fromRGB(80, 220, 120),
        Rainbow       = false,
        RainbowSpeed  = 0.6,
        BoxSize       = Vector2.new(200, 76),
        Title         = "NovaUI",
        Subtitle      = "loading modules...",
        ShowBackdrop  = false,   -- if false, no black screen around box
        BackdropColor = Color3.fromRGB(0, 0, 0),
        BackdropAlpha = 0,
        LineThickness = 2,
        FadeOutTime   = 0.35,
    },
}

--==============================================================
-- ICONS (icons.rest / Lucide) — 40+ icons
--==============================================================
local Icons = {
    -- Navigation
    Home        = "rbxassetid://10723407383",
    Settings    = "rbxassetid://10734898355",
    Info        = "rbxassetid://10734904191",
    List        = "rbxassetid://10734911770",
    Palette     = "rbxassetid://10734922069",
    Wrench      = "rbxassetid://10734936564",
    User        = "rbxassetid://10734948940",
    Users       = "rbxassetid://10734948940",
    Shield      = "rbxassetid://10734948940",
    Folder      = "rbxassetid://10734911770",
    File        = "rbxassetid://10734898475",
    Bookmark    = "rbxassetid://10734945940",
    -- Actions
    Close       = "rbxassetid://10734897593",
    Minus       = "rbxassetid://10734897593",
    Plus        = "rbxassetid://10734905351",
    Check       = "rbxassetid://10734897983",
    Search      = "rbxassetid://10734940165",
    Refresh     = "rbxassetid://10734935063",
    Copy        = "rbxassetid://10734898475",
    Save        = "rbxassetid://10734934677",
    Trash       = "rbxassetid://10734948940",
    Edit        = "rbxassetid://10734903172",
    Download    = "rbxassetid://10734934677",
    Upload      = "rbxassetid://10734935063",
    Link        = "rbxassetid://10734898475",
    External    = "rbxassetid://10734898475",
    Lock        = "rbxassetid://10734948940",
    Unlock      = "rbxassetid://10734948940",
    Filter      = "rbxassetid://10734940165",
    -- Status
    Success     = "rbxassetid://10734897983",
    Warning     = "rbxassetid://10734936967",
    Error       = "rbxassetid://10734897983",
    Bell        = "rbxassetid://10734895955",
    Star        = "rbxassetid://10734945940",
    Heart       = "rbxassetid://10734905351",
    Clock       = "rbxassetid://10734922069",
    Activity    = "rbxassetid://10734922069",
    -- Misc
    ChevronDown = "rbxassetid://10734895495",
    ChevronUp   = "rbxassetid://10734895495",
    ChevronRight= "rbxassetid://10734895955",
    ChevronLeft = "rbxassetid://10734895955",
    Play        = "rbxassetid://10734934538",
    Pause       = "rbxassetid://10734922069",
    Zap         = "rbxassetid://10734922069",
    Eye         = "rbxassetid://10734903172",
    EyeOff      = "rbxassetid://10734903172",
    Crosshair   = "rbxassetid://10734911770",
    Target      = "rbxassetid://10734911770",
    Sparkles    = "rbxassetid://10734945940",
    Rocket      = "rbxassetid://10734934538",
    Box         = "rbxassetid://10734911770",
    Boxes       = "rbxassetid://10734911770",
    Layers      = "rbxassetid://10734911770",
    Grid        = "rbxassetid://10734911770",
    Code        = "rbxassetid://10734898475",
    Terminal    = "rbxassetid://10734898475",
    Power       = "rbxassetid://10734934538",
    Globe       = "rbxassetid://10734922069",
    Map         = "rbxassetid://10734922069",
    Compass     = "rbxassetid://10734922069",
    Navigation  = "rbxassetid://10734922069",
    Flag        = "rbxassetid://10734945940",
    Award       = "rbxassetid://10734945940",
    Gift        = "rbxassetid://10734905351",
    Package     = "rbxassetid://10734911770",
}
local function Icon(name) return Icons[name] or Icons.Info end

--==============================================================
-- UTILITIES
--==============================================================
local U = {}
function U.Create(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do if k ~= "Parent" then i[k] = v end end
    if props and props.Parent then i.Parent = props.Parent end
    return i
end
function U.Tween(i, p, d, s, dir)
    local t = TweenService:Create(i, TweenInfo.new(d or Config.Speed, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
    t:Play(); return t
end
function U.Corner(parent, r)
    return U.Create("UICorner", { Parent = parent, CornerRadius = UDim.new(0, r or Config.Radius) })
end
function U.Stroke(parent, color, thickness)
    return U.Create("UIStroke", { Parent = parent, Color = color or Config.Theme.Line, Thickness = thickness or 1 })
end
function U.Round(n, d)
    local m = 10 ^ (d or 0); return math.floor(n * m + 0.5) / m
end
function U.LerpColor(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end
function U.HSVColor(h)
    local c = Color3.fromHSV(h % 1, 0.75, 1)
    return c
end
function U.DisconnectAll(tbl)
    for _, c in ipairs(tbl or {}) do
        pcall(function() c:Disconnect() end)
    end
end

--==============================================================
-- CORE TABLE
--==============================================================
local NovaUI = {}
NovaUI.__index = NovaUI
NovaUI.Flags = {}
NovaUI.Windows = {}
NovaUI.Theme = Config.Theme
NovaUI.Config = Config
NovaUI.Utility = U
NovaUI.Icons = Icons
NovaUI._Icon = Icon

--==============================================================
-- DRAGGING
--==============================================================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--==============================================================
-- RESIZING
--==============================================================
local function MakeResizable(frame, minW, minH)
    minW, minH = minW or 320, minH or 220
    local handle = U.Create("TextButton", {
        Parent = frame, BackgroundTransparency = 1,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -14, 1, -14), Text = "", ZIndex = 5,
    })
    local resizing, startSize, startMouse
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true; startSize = frame.AbsoluteSize; startMouse = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - startMouse
            frame.Size = UDim2.new(0, math.max(minW, startSize.X + d.X), 0, math.max(minH, startSize.Y + d.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)
end

--==============================================================
-- LOADING SCREEN
--==============================================================
local ActiveLoadings = {}

local function PlayLoadingScreen(userOpts)
    local opts = {}
    for k, v in pairs(Config.Loading) do opts[k] = v end
    for k, v in pairs(userOpts or {}) do opts[k] = v end

    if not opts.Enabled then return end

    local screen = U.Create("ScreenGui", {
        Name = "NovaUI_Loading",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999,
        Parent = CoreGui,
    })
    table.insert(ActiveLoadings, screen)

    -- Optional backdrop (default fully transparent)
    if opts.ShowBackdrop then
        U.Create("Frame", {
            Parent = screen,
            BackgroundColor3 = opts.BackdropColor,
            BackgroundTransparency = opts.BackdropAlpha,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
        })
    end

    -- Sharp centered rectangle (no UICorner)
    local sizeX = opts.BoxSize.X
    local sizeY = opts.BoxSize.Y
    local box = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(12, 12, 14),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, sizeX, 0, sizeY),
    })
    U.Create("UIStroke", {
        Parent = box,
        Color = Color3.fromRGB(28, 28, 32),
        Thickness = 1,
        Transparency = 0.2,
    })

    -- Title / subtitle
    U.Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -14),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Config.FontBold,
        Text = opts.Title,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    U.Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 6),
        Size = UDim2.new(1, 0, 0, 13),
        Font = Config.Font,
        Text = opts.Subtitle,
        TextColor3 = Color3.fromRGB(120, 120, 135),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    -- Perimeter line (4 segments)
    local color0 = opts.LineColor
    local segColor = color0
    local thickness = opts.LineThickness
    local inset = 1

    local top = U.Create("Frame", {
        Parent = screen, BackgroundColor3 = segColor, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -sizeY / 2 - inset),
        Size = UDim2.new(0, 0, 0, thickness),
    })
    local right = U.Create("Frame", {
        Parent = screen, BackgroundColor3 = segColor, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, sizeX / 2 + inset, 0.5, 0),
        Size = UDim2.new(0, thickness, 0, 0),
    })
    local bottom = U.Create("Frame", {
        Parent = screen, BackgroundColor3 = segColor, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, sizeX / 2 + inset, 0.5, sizeY / 2 + inset),
        Size = UDim2.new(0, 0, 0, thickness),
    })
    local left = U.Create("Frame", {
        Parent = screen, BackgroundColor3 = segColor, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0.5, -sizeX / 2 - inset, 0.5, sizeY / 2 + inset),
        Size = UDim2.new(0, thickness, 0, 0),
    })

    -- Rainbow animation runner
    local rainbowThread
    if opts.Rainbow then
        local hue = 0
        rainbowThread = task.spawn(function()
            while screen.Parent do
                hue = hue + 0.015
                local c = U.HSVColor(hue)
                top.BackgroundColor3 = c
                right.BackgroundColor3 = c
                bottom.BackgroundColor3 = c
                left.BackgroundColor3 = c
                RunService.Heartbeat:Wait()
            end
        end)
    end

    -- Trace the perimeter
    local per = opts.Duration / 4
    local ease = Enum.EasingStyle.Quad
    U.Tween(top,    { Size = UDim2.new(0, sizeX + inset * 2, 0, thickness) }, per, ease)
    task.wait(per)
    U.Tween(right,  { Size = UDim2.new(0, thickness, 0, sizeY + inset * 2) }, per, ease)
    task.wait(per)
    U.Tween(bottom, { Size = UDim2.new(0, sizeX + inset * 2, 0, thickness) }, per, ease)
    task.wait(per)
    U.Tween(left,   { Size = UDim2.new(0, thickness, 0, sizeY + inset * 2) }, per, ease)
    task.wait(per)

    task.wait(0.08)

    -- Fade everything
    local fade = opts.FadeOutTime
    for _, seg in ipairs({ top, right, bottom, left }) do
        U.Tween(seg, { BackgroundTransparency = 1 }, fade, Enum.EasingStyle.Sine)
    end
    U.Tween(box, { BackgroundTransparency = 1 }, fade, Enum.EasingStyle.Sine)
    for _, child in ipairs(box:GetChildren()) do
        if child:IsA("TextLabel") then
            U.Tween(child, { TextTransparency = 1 }, fade * 0.85)
        elseif child:IsA("UIStroke") then
            U.Tween(child, { Transparency = 1 }, fade * 0.85)
        end
    end
    task.wait(fade + 0.02)
    if rainbowThread then task.cancel(rainbowThread) end
    screen:Destroy()
    for i, s in ipairs(ActiveLoadings) do
        if s == screen then table.remove(ActiveLoadings, i); break end
    end
end

NovaUI.PlayLoadingScreen = PlayLoadingScreen
NovaUI.ActiveLoadings = ActiveLoadings

--==============================================================
-- NOTIFICATIONS
--==============================================================
local function CreateNotification(title, content, accent, duration)
    duration = duration or 3
    accent = accent or Config.Theme.Accent

    local screen = NovaUI.NotificationGui
    if not screen then
        screen = U.Create("ScreenGui", {
            Name = "NovaUI_Notifications",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui,
        })
        NovaUI.NotificationGui = screen
    end

    local holder = U.Create("Frame", {
        Name = "Notif",
        Parent = screen,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 260, 0, 0),
        Position = UDim2.new(1, -280, 1, -18),
        AnchorPoint = Vector2.new(0, 1),
    })

    for _, c in ipairs(screen:GetChildren()) do
        if c:IsA("Frame") and c ~= holder and c.Name == "Notif" then
            local y = c.Position.Y.Offset
            U.Tween(c, { Position = UDim2.new(1, -280, 1, y - 56) }, 0.22)
        end
    end

    local main = U.Create("Frame", {
        Parent = holder,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        ClipsDescendants = true,
    })
    U.Corner(main, 5)
    U.Stroke(main, Config.Theme.Line, 1)

    local bar = U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
    })

    U.Create("TextLabel", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -20, 0, 14),
        Font = Config.FontBold,
        Text = title,
        TextColor3 = Config.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    U.Create("TextLabel", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 23),
        Size = UDim2.new(1, -20, 0, 18),
        Font = Config.Font,
        Text = content,
        TextColor3 = Config.Theme.Dim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    local pb = U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Line,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
    })
    local p = U.Create("Frame", {
        Parent = pb,
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
    })
    U.Tween(p, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

    main.Position = UDim2.new(0, 12, 0, 0)
    U.Tween(main, { Position = UDim2.new(0, 0, 0, 0) }, 0.25)

    task.delay(duration, function()
        U.Tween(main, { BackgroundTransparency = 1 }, 0.25)
        U.Tween(bar,  { BackgroundTransparency = 1 }, 0.25)
        for _, c in ipairs(main:GetChildren()) do
            if c:IsA("TextLabel") then U.Tween(c, { TextTransparency = 1 }, 0.2) end
            if c:IsA("UIStroke") then U.Tween(c, { Transparency = 1 }, 0.25) end
        end
        U.Tween(holder, { Position = UDim2.new(1, -280, 1, holder.Position.Y.Offset - 56) }, 0.25)
        task.wait(0.28)
        holder:Destroy()
    end)

    return holder
end

NovaUI.Notify = CreateNotification

--==============================================================
-- WINDOW
--==============================================================
function NovaUI:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "NovaUI"
    local windowSize = options.Size or Config.Size
    local toggleKey  = options.ToggleKey or Enum.KeyCode.RightShift
    local loading    = options.Loading

    if loading == nil then loading = Config.Loading.Enabled end
    if loading ~= false then
        PlayLoadingScreen(type(loading) == "table" and loading or nil)
    end

    local self = setmetatable({}, NovaUI)
    self.Name = windowName
    self.Tabs = {}
    self.ActiveTab = nil
    self.Flags = {}
    self.Minimized = false
    self.Options = {}
    self.Toggles = {}
    self.UnloadCallbacks = {}
    self._connections = {}

    local screen = U.Create("ScreenGui", {
        Name = "NovaUI_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    self.ScreenGui = screen

    local blur = U.Create("BlurEffect", {
        Parent = Lighting,
        Size = 0,
        Name = "NovaUI_Blur_" .. HttpService:GenerateGUID(false),
    })
    self.Blur = blur

    local main = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        Position = UDim2.new(0.5, -windowSize.X / 2, 0.5, -windowSize.Y / 2),
        ClipsDescendants = true,
    })
    self.Main = main
    U.Corner(main, Config.Radius)
    U.Stroke(main, Config.Theme.Line, 1)

    -- Header
    local header = U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
    })
    self.Header = header
    U.Corner(header, Config.Radius)
    U.Create("Frame", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -Config.Radius),
        Size = UDim2.new(1, 0, 0, Config.Radius),
    })

    local dot = U.Create("Frame", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -4),
        Size = UDim2.new(0, 8, 0, 8),
    })
    U.Corner(dot, 4)

    U.Create("TextLabel", {
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Config.FontBold,
        Text = windowName,
        TextColor3 = Config.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Close
    local closeBtn = U.Create("TextButton", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -26, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(closeBtn, 4)
    U.Create("ImageLabel", {
        Parent = closeBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(0, 8, 0, 8),
        Image = Icon("Close"),
        ImageColor3 = Config.Theme.Dim,
    })
    closeBtn.MouseEnter:Connect(function() U.Tween(closeBtn, { BackgroundColor3 = Config.Theme.Red }, 0.12) end)
    closeBtn.MouseLeave:Connect(function() U.Tween(closeBtn, { BackgroundColor3 = Config.Theme.Card }, 0.12) end)
    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    -- Minimize
    local minBtn = U.Create("TextButton", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -48, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(minBtn, 4)
    U.Create("Frame", {
        Parent = minBtn,
        BackgroundColor3 = Config.Theme.Dim,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -4, 0.5, -0.5),
        Size = UDim2.new(0, 8, 0, 1),
    })
    minBtn.MouseEnter:Connect(function() U.Tween(minBtn, { BackgroundColor3 = Config.Theme.Accent }, 0.12) end)
    minBtn.MouseLeave:Connect(function() U.Tween(minBtn, { BackgroundColor3 = Config.Theme.Card }, 0.12) end)
    minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)

    -- Sidebar
    local sidebar = U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(0, 116, 1, -32),
    })
    self.Sidebar = sidebar

    local sbScroll = U.Create("ScrollingFrame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Line,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    self.SidebarScroll = sbScroll
    U.Create("UIListLayout", { Parent = sbScroll, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

    -- Content
    local content = U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 116, 0, 32),
        Size = UDim2.new(1, -116, 1, -32),
    })
    self.Content = content

    U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Line,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 116, 0, 32),
        Size = UDim2.new(0, 1, 1, -32),
        ZIndex = 2,
    })

    MakeDraggable(main, header)
    MakeResizable(main, Config.MinSize.X, Config.MinSize.Y)

    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
            if blur then U.Tween(blur, { Size = main.Visible and 10 or 0 }, 0.25) end
        end
    end))

    main.BackgroundTransparency = 1
    main.Size = UDim2.new(0, windowSize.X * 0.95, 0, windowSize.Y * 0.95)
    U.Tween(main, {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
    }, 0.35, Enum.EasingStyle.Quint)
    U.Tween(blur, { Size = 10 }, 0.35)

    table.insert(NovaUI.Windows, self)
    return self
end

function NovaUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        U.Tween(self.Main, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 32) }, 0.25)
        task.delay(0.12, function()
            self.Sidebar.Visible = false
            self.Content.Visible = false
        end)
    else
        U.Tween(self.Main, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 340) }, 0.25)
        task.wait(0.05)
        self.Sidebar.Visible = true
        self.Content.Visible = true
    end
end

function NovaUI:OnUnload(fn)
    table.insert(self.UnloadCallbacks, fn)
end

function NovaUI:Destroy()
    for _, fn in ipairs(self.UnloadCallbacks) do pcall(fn) end
    U.DisconnectAll(self._connections)
    if self.Blur then
        U.Tween(self.Blur, { Size = 0 }, 0.25)
        task.delay(0.28, function() if self.Blur then self.Blur:Destroy() end end)
    end
    U.Tween(self.Main, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.3, function() if self.ScreenGui then self.ScreenGui:Destroy() end end)
    for i, w in ipairs(NovaUI.Windows) do
        if w == self then table.remove(NovaUI.Windows, i); break end
    end
end

--==============================================================
-- TAB
--==============================================================
function NovaUI:CreateTab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or "List"

    local tab = { Name = tabName, Window = self, Elements = {}, Groups = {} }

    local btn = U.Create("TextButton", {
        Name = tabName .. "Tab",
        Parent = self.SidebarScroll,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26),
        Text = "", AutoButtonColor = false,
    })
    tab.Button = btn
    U.Corner(btn, 5)

    local icon = U.Create("ImageLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Image = Icon(tabIcon),
        ImageColor3 = Config.Theme.Dim,
    })
    tab.Icon = icon

    local lbl = U.Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Config.FontMedium,
        Text = tabName,
        TextColor3 = Config.Theme.Dim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    tab.Label = lbl

    local indicator = U.Create("Frame", {
        Parent = btn,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -6),
        Size = UDim2.new(0, 2, 0, 12),
        Visible = false,
    })
    U.Corner(indicator, 2)
    tab.Indicator = indicator

    local container = U.Create("ScrollingFrame", {
        Parent = self.Content,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Line,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    tab.Container = container
    U.Create("UIListLayout", { Parent = container, Padding = UDim.new(0, Config.Spacing), SortOrder = Enum.SortOrder.LayoutOrder })

    btn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then U.Tween(btn, { BackgroundColor3 = Config.Theme.Card }, 0.12) end
    end)
    btn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then U.Tween(btn, { BackgroundColor3 = Config.Theme.Bg }, 0.12) end
    end)
    btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end

function NovaUI:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        local on = (t == tab)
        t.Container.Visible = on
        t.Indicator.Visible = on
        U.Tween(t.Button, { BackgroundColor3 = on and Config.Theme.Card or Config.Theme.Bg }, 0.12)
        U.Tween(t.Label, { TextColor3 = on and Config.Theme.Text or Config.Theme.Dim }, 0.12)
        U.Tween(t.Icon,  { ImageColor3 = on and Config.Theme.Accent or Config.Theme.Dim }, 0.12)
    end
    self.ActiveTab = tab
end

--==============================================================
-- GROUPBOX (Obsidian-style side panels)
--==============================================================
function NovaUI:AddGroupbox(tab, options)
    options = options or {}
    local name = options.Name or "Group"
    local side = options.Side or "Left"
    local iconName = options.Icon or "Boxes"
    local desc = options.Description

    -- Container per side
    tab._leftCol = tab._leftCol or U.Create("Frame", {
        Parent = tab.Container, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.5, -2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    tab._rightCol = tab._rightCol or U.Create("Frame", {
        Parent = tab.Container, BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 2, 0, 0),
        Size = UDim2.new(0.5, -2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    if not tab._leftLayout then
        tab._leftLayout = U.Create("UIListLayout", {
            Parent = tab._leftCol, Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    end
    if not tab._rightLayout then
        tab._rightLayout = U.Create("UIListLayout", {
            Parent = tab._rightCol, Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    end

    local parentCol = (side:lower() == "right") and tab._rightCol or tab._leftCol

    local group = {}
    group.Name = name
    group.Elements = {}
    group._window = self

    local outer = U.Create("Frame", {
        Parent = parentCol,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Corner(outer, 6)
    U.Stroke(outer, Config.Theme.Line, 1)
    group.Frame = outer

    -- Header
    local head = U.Create("Frame", {
        Parent = outer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
    })
    U.Create("ImageLabel", {
        Parent = head,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Image = Icon(iconName),
        ImageColor3 = Config.Theme.Accent,
    })
    U.Create("TextLabel", {
        Parent = head,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 28, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        Font = Config.FontBold,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Body
    local body = U.Create("Frame", {
        Parent = outer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 28),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", {
        Parent = body,
        Padding = UDim.new(0, Config.Spacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    U.Create("UIPadding", {
        Parent = body,
        PaddingBottom = UDim.new(0, 8),
    })
    group.Container = body

    table.insert(tab.Groups, group)
    return group
end

--==============================================================
-- PART 1 END
--==============================================================
-- NovaUI is passed to Part 2 via a temporary global `_NovaUIPartial`
_NovaUIPartial = NovaUI

--==============================================================
-- PART 2/4: ELEMENT API
--==============================================================
local NovaUI = _NovaUIPartial  -- pick up from Part 1

--==============================================================
-- ELEMENT BASE
--==============================================================
local function CreateBase(tab, height)
    local f = U.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or Config.ElemHeight),
    })
    U.Corner(f, 5)
    return f
end

local function CreateGroupRow(group, height)
    local f = U.Create("Frame", {
        Parent = group.Container,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or Config.ElemHeight),
    })
    U.Corner(f, 5)
    return f
end

-- Resolve parent (tab or groupbox)
local function GetContainer(parent)
    return parent.Container
end

--==============================================================
-- SECTION (tab only)
--==============================================================
function NovaUI:AddSection(tab, name)
    local frame = U.Create("Frame", {
        Parent = tab.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
    })
    U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -6),
        Size = UDim2.new(0, 2, 0, 12),
    })
    U.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Font = Config.FontBold,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return { Frame = frame }
end

--==============================================================
-- BUTTON
--==============================================================
function NovaUI:AddButton(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Button"
    local icon = opts.Icon or "Play"
    local cb   = opts.Callback or opts.Func or function() end
    local doubleClick = opts.DoubleClick or false
    local disabled = opts.Disabled or false
    local risky = opts.Risky or false

    local btn = U.Create("TextButton", {
        Parent = parent.Container,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Config.ElemHeight),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(btn, 5)

    local iconImg = U.Create("ImageLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Image = Icon(icon),
        ImageColor3 = Config.Theme.Dim,
    })

    U.Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 28, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = risky and Config.Theme.Red or Config.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    if disabled then
        btn.BackgroundTransparency = 0.5
        return { Instance = btn, _disabled = true }
    end

    local lastClick = 0
    btn.MouseEnter:Connect(function()
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12)
        U.Tween(iconImg, { ImageColor3 = Config.Theme.Accent }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Card }, 0.12)
        U.Tween(iconImg, { ImageColor3 = Config.Theme.Dim }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        if doubleClick then
            local now = tick()
            if now - lastClick > 0.4 then
                lastClick = now
                return
            end
            lastClick = 0
        end
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.08)
        task.delay(0.08, function() U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12) end)
        pcall(cb)
    end)

    local element = { Instance = btn }

    -- Sub-buttons
    function element:AddButton(subOpts)
        subOpts = subOpts or {}
        return NovaUI:AddButton(parent, subOpts)
    end

    return element
end

--==============================================================
-- TOGGLE
--==============================================================
function NovaUI:AddToggle(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Toggle"
    local default = opts.Default or false
    local cb = opts.Callback or function() end
    local flag = opts.Flag or opts.Index
    local disabled = opts.Disabled or false
    local risky = opts.Risky or false

    local frame = CreateBase(parent, Config.ElemHeight)
    frame.Parent = parent.Container

    U.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = risky and Config.Theme.Red or Config.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local track = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default and Config.Theme.Accent or Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -40, 0.5, -7),
        Size = UDim2.new(0, 30, 0, 14),
    })
    U.Corner(track, 7)

    local knob = U.Create("Frame", {
        Parent = track,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -12, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
    })
    U.Corner(knob, 6)

    local state = default
    local callbacks = {}

    local function set(v, fire)
        state = v
        if state then
            U.Tween(track, { BackgroundColor3 = Config.Theme.Accent }, 0.18)
            U.Tween(knob, { Position = UDim2.new(1, -12, 0.5, -6) }, 0.18)
        else
            U.Tween(track, { BackgroundColor3 = Config.Theme.Hover }, 0.18)
            U.Tween(knob, { Position = UDim2.new(0, 2, 0.5, -6) }, 0.18)
        end
        if fire then
            pcall(cb, state)
            for _, fn in ipairs(callbacks) do pcall(fn, state) end
        end
    end

    if not disabled then
        local click = U.Create("TextButton", {
            Parent = frame, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Text = "",
        })
        click.MouseButton1Click:Connect(function() set(not state, true) end)
    end

    local element = {
        Instance = frame,
        Value = state,
        Set = function(v) element.Value = v; set(v, false) end,
        Get = function() return element.Value end,
        Toggle = function() element.Value = not state; set(element.Value, true) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
        SetValue = function(_, v) element.Set(v) end,
        SetValueNoCallback = function(_, v) element.Set(v) end,
    }
    -- Obsidian-style call
    element.OnChanged = function(self, fn) table.insert(callbacks, fn) end

    if flag then NovaUI.Flags[flag] = element end
    NovaUI.Toggles = NovaUI.Toggles or {}
    if flag then NovaUI.Toggles[flag] = element end

    if default then pcall(cb, state) end
    return element
end

--==============================================================
-- CHECKBOX
--==============================================================
function NovaUI:AddCheckbox(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Checkbox"
    local default = opts.Default or false
    local cb = opts.Callback or function() end
    local flag = opts.Flag or opts.Index

    local frame = CreateBase(parent, Config.ElemHeight)

    local box = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default and Config.Theme.Accent or Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
    })
    U.Corner(box, 3)

    local check = U.Create("ImageLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(0, 12, 0, 12),
        Image = Icon("Check"),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = default and 0 or 1,
    })

    U.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local state = default
    local callbacks = {}

    local function set(v, fire)
        state = v
        U.Tween(box, { BackgroundColor3 = state and Config.Theme.Accent or Config.Theme.Hover }, 0.18)
        U.Tween(check, { ImageTransparency = state and 0 or 1 }, 0.18)
        if fire then
            pcall(cb, state)
            for _, fn in ipairs(callbacks) do pcall(fn, state) end
        end
    end

    local click = U.Create("TextButton", {
        Parent = frame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "",
    })
    click.MouseButton1Click:Connect(function() set(not state, true) end)

    local element = {
        Instance = frame,
        Value = state,
        Set = function(v) element.Value = v; set(v, false) end,
        Get = function() return element.Value end,
        SetValue = function(_, v) element.Set(v) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- SLIDER
--==============================================================
function NovaUI:AddSlider(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Slider"
    local min, max = opts.Min or 0, opts.Max or 100
    local default = opts.Default or min
    local suffix = opts.Suffix or ""
    local rounding = opts.Rounding or opts.Decimals or 0
    local cb = opts.Callback or function() end
    local flag = opts.Flag or opts.Index
    local compact = opts.Compact or false
    local hideMax = opts.HideMax or false

    local frame = CreateBase(parent, compact and 22 or 40)

    if not compact then
        U.Create("TextLabel", {
            Parent = frame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 6),
            Size = UDim2.new(0.7, 0, 0, 14),
            Font = Config.FontMedium,
            Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    end

    local valLbl = U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = compact and UDim2.new(0, 10, 0, 4) or UDim2.new(0.7, 0, 0, 6),
        Size = compact and UDim2.new(0.4, -10, 0, 14) or UDim2.new(0.3, -10, 0, 14),
        Font = Config.FontMedium,
        Text = tostring(default) .. suffix,
        TextColor3 = Config.Theme.Accent, TextSize = 11,
        TextXAlignment = compact and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,
    })

    local barY = compact and UDim2.new(1, -16) or UDim2.new(1, -16)
    local barBg = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = compact and UDim2.new(0.4, 0, 0.5, -2) or UDim2.new(0, 10, 1, -16),
        Size = compact and UDim2.new(0.6, -10, 0, 4) or UDim2.new(1, -20, 0, 4),
    })
    U.Corner(barBg, 2)

    local pct = math.clamp((default - min) / (max - min), 0, 1)
    local fill = U.Create("Frame", {
        Parent = barBg,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(pct, 0, 1, 0),
    })
    U.Corner(fill, 2)

    local knob = U.Create("Frame", {
        Parent = barBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(pct, 0, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
    })
    U.Corner(knob, 5)

    local value = default
    local dragging = false
    local callbacks = {}

    local function formatValue(v)
        if opts.FormatDisplayValue then
            local r = opts.FormatDisplayValue(element, v)
            if r then return r end
        end
        if hideMax then return tostring(v) .. suffix end
        return tostring(v) .. suffix
    end

    local function update(input)
        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local nv = U.Round(min + (max - min) * rel, rounding)
        if nv ~= value then
            value = nv
            element.Value = nv
            valLbl.Text = formatValue(nv)
            U.Tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.04)
            U.Tween(knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.04)
            pcall(cb, value)
            for _, fn in ipairs(callbacks) do pcall(fn, value) end
        end
    end

    local hit = U.Create("TextButton", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -26),
        Size = UDim2.new(1, 0, 0, 22), Text = "",
    })
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local element = {
        Instance = frame,
        Value = default,
        Min = min,
        Max = max,
        Set = function(v)
            v = math.clamp(v, min, max); value = v; element.Value = v
            local p = (v - min) / (max - min)
            valLbl.Text = formatValue(v)
            U.Tween(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.12)
            U.Tween(knob, { Position = UDim2.new(p, 0, 0.5, 0) }, 0.12)
        end,
        Get = function() return element.Value end,
        SetValue = function(_, v) element.Set(v) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- TEXTBOX / INPUT
--==============================================================
function NovaUI:AddTextbox(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Input"
    local default = opts.Default or ""
    local ph = opts.Placeholder or "Type..."
    local cb = opts.Callback or function() end
    local flag = opts.Flag or opts.Index
    local finished = opts.Finished or false
    local numeric = opts.Numeric or false
    local clearOnFocus = opts.ClearTextOnFocus ~= false
    local maxLength = opts.MaxLength or 200

    local frame = CreateBase(parent, Config.ElemHeight)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local boxBg = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0.44, 0, 0.5, -9),
        Size = UDim2.new(0.56, -10, 0, 18),
    })
    U.Corner(boxBg, 4)
    local stroke = U.Stroke(boxBg, Config.Theme.Line, 1)

    local box = U.Create("TextBox", {
        Parent = boxBg, BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Font = Config.Font,
        Text = default, PlaceholderText = ph,
        PlaceholderColor3 = Config.Theme.Dim,
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = clearOnFocus,
    })
    box.Focused:Connect(function() U.Tween(stroke, { Color = Config.Theme.Accent }, 0.12) end)
    box.FocusLost:Connect(function(enter)
        U.Tween(stroke, { Color = Config.Theme.Line }, 0.12)
        if enter then pcall(cb, box.Text) end
    end)
    if not finished then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            if numeric then
                local filtered = box.Text:gsub("[^%d%.%-]", "")
                if filtered ~= box.Text then box.Text = filtered end
            end
            pcall(cb, box.Text)
        end)
    end

    local element = {
        Instance = frame,
        Value = default,
        Set = function(v) box.Text = v; element.Value = v end,
        Get = function() return box.Text end,
        SetValue = function(_, v) element.Set(v) end,
        OnChanged = function(_, fn)
            box:GetPropertyChangedSignal("Text"):Connect(function() pcall(fn, box.Text) end)
        end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- KEYBIND / KEYPICKER
--==============================================================
function NovaUI:AddKeybind(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Keybind"
    local default = opts.Default or "E"
    local cb = opts.Callback or function() end
    local changedCb = opts.ChangedCallback
    local flag = opts.Flag or opts.Index
    local mode = opts.Mode or "Toggle" -- Toggle / Hold / Always / Press
    local syncToggleState = opts.SyncToggleState or false
    local noUI = opts.NoUI or false

    local frame = CreateBase(parent, Config.ElemHeight)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local btn = U.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -70, 0.5, -9),
        Size = UDim2.new(0, 60, 0, 18),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(btn, 4)

    local lbl = U.Create("TextLabel", {
        Parent = btn, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.FontMedium,
        Text = tostring(default),
        TextColor3 = Config.Theme.Text, TextSize = 11,
    })

    local current = default
    local currentModifiers = {}
    local listening = false
    local state = false
    local callbacks = {}

    local function setState(v, fire)
        state = v
        element.State = v
        if fire then
            pcall(cb, v)
            for _, fn in ipairs(callbacks) do pcall(fn, v) end
        end
    end

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true; lbl.Text = "..."
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.12)
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode.Name
                lbl.Text = current
                listening = false
                U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12)
                if changedCb then pcall(changedCb, current, currentModifiers) end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2 then
                current = (input.UserInputType == Enum.UserInputType.MouseButton1) and "MB1" or "MB2"
                lbl.Text = current
                listening = false
                U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12)
                if changedCb then pcall(changedCb, current, currentModifiers) end
            end
            return
        end
        if gpe then return end
        local keyName
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keyName = input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            keyName = "MB1"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            keyName = "MB2"
        end
        if keyName == current then
            if mode == "Toggle" then
                setState(not state, true)
            elseif mode == "Hold" then
                setState(true, true)
            elseif mode == "Press" then
                pcall(cb, true)
                for _, fn in ipairs(callbacks) do pcall(fn, true) end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if mode == "Hold" then
            local keyName
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyName = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyName = "MB1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyName = "MB2"
            end
            if keyName == current then setState(false, true) end
        end
    end)

    local element = {
        Instance = frame,
        Value = current,
        State = false,
        Modes = mode,
        SetValue = function(_, val)
            if type(val) == "table" then
                current = val[1] or current
                mode = val[2] or mode
            else
                current = val
            end
            lbl.Text = tostring(current)
        end,
        GetState = function() return state end,
        OnClick = function(_, fn) table.insert(callbacks, fn) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- DROPDOWN
--==============================================================
function NovaUI:AddDropdown(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Dropdown"
    local values = opts.Values or {}
    local default = opts.Default
    local cb = opts.Callback or function() end
    local flag = opts.Flag or opts.Index
    local multi = opts.Multi or false
    local searchable = opts.Searchable or false
    local maxVisible = opts.MaxVisibleDropdownItems or 8
    local disabled = opts.Disabled or false
    local formatDisplay = opts.FormatDisplayValue

    local frame = CreateBase(parent, 34)
    frame.ClipsDescendants = false

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -7),
        Size = UDim2.new(0.4, 0, 0, 14),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local dbtn = U.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0.44, 0, 0.5, -9),
        Size = UDim2.new(0.56, -10, 0, 18),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(dbtn, 4)

    local selLbl = U.Create("TextLabel", {
        Parent = dbtn, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Config.Font,
        Text = "Select",
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    U.Create("ImageLabel", {
        Parent = dbtn, BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        Image = Icon("ChevronDown"),
        ImageColor3 = Config.Theme.Dim,
    })

    -- List frame
    local list = U.Create("Frame", {
        Parent = parent._window.ScreenGui,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 0, 0),
        Visible = false, ZIndex = 60,
    })
    U.Corner(list, 5)
    U.Stroke(list, Config.Theme.Line, 1)

    local searchBox
    if searchable then
        searchBox = U.Create("TextBox", {
            Parent = list,
            BackgroundColor3 = Config.Theme.Card,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(1, -8, 0, 18),
            Font = Config.Font,
            Text = "",
            PlaceholderText = "Search...",
            PlaceholderColor3 = Config.Theme.Dim,
            TextColor3 = Config.Theme.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
        })
        U.Corner(searchBox, 3)
        U.Create("UIPadding", { Parent = searchBox, PaddingLeft = UDim.new(0, 6) })
    end

    local scroll = U.Create("ScrollingFrame", {
        Parent = list, BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, searchable and 26 or 4),
        Size = searchable and UDim2.new(1, -8, 1, -30) or UDim2.new(1, -8, 1, -8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Line,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })

    local current = default
    local multiState = {}
    local open = false
    local callbacks = {}
    local itemButtons = {}

    local function isDictionary()
        return type(values) == "table" and next(values) and type(next(values)) == "string"
    end

    local function getDisplay(key)
        if isDictionary() then
            local label = values[key] or key
            if formatDisplay then
                local r = formatDisplay(label)
                if r then return r end
            end
            return label
        end
        if formatDisplay then
            local r = formatDisplay(key)
            if r then return r end
        end
        return key
    end

    local function updateSelText()
        if multi then
            local count = 0
            for _ in pairs(multiState) do count = count + 1 end
            if count == 0 then selLbl.Text = "None"
            elseif count == 1 then
                for k in pairs(multiState) do selLbl.Text = getDisplay(k); break end
            else selLbl.Text = count .. " selected" end
        else
            selLbl.Text = current and tostring(getDisplay(current)) or "Select"
        end
    end

    local function updatePos()
        list.Position = UDim2.new(0, dbtn.AbsolutePosition.X, 0, dbtn.AbsolutePosition.Y + 22)
        local visibleCount = math.min(#itemButtons, maxVisible)
        list.Size = UDim2.new(0, math.max(140, dbtn.AbsoluteSize.X), 0, visibleCount * 22 + (searchable and 30 or 10))
    end

    local function rebuild(filter)
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        itemButtons = {}

        local items = {}
        if isDictionary() then
            for k, v in pairs(values) do
                table.insert(items, { key = k, label = v })
            end
        else
            for _, v in ipairs(values) do
                table.insert(items, { key = v, label = v })
            end
        end

        for _, item in ipairs(items) do
            local label = tostring(item.label)
            if filter and filter ~= "" then
                if not label:lower():find(filter:lower(), 1, true) then
                    continue
                end
            end

            local isSelected = false
            if multi then
                isSelected = multiState[item.key] == true
            else
                isSelected = current == item.key
            end

            local ib = U.Create("TextButton", {
                Parent = scroll,
                BackgroundColor3 = isSelected and Config.Theme.Accent or Config.Theme.Panel,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20),
                Text = "", AutoButtonColor = false,
            })
            U.Corner(ib, 3)

            U.Create("TextLabel", {
                Parent = ib, BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -12, 1, 0),
                Font = Config.Font,
                Text = label,
                TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Config.Theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            ib.MouseEnter:Connect(function()
                if not isSelected then U.Tween(ib, { BackgroundColor3 = Config.Theme.Card }, 0.1) end
            end)
            ib.MouseLeave:Connect(function()
                if not isSelected then U.Tween(ib, { BackgroundColor3 = Config.Theme.Panel }, 0.1) end
            end)
            ib.MouseButton1Click:Connect(function()
                if multi then
                    multiState[item.key] = not multiState[item.key]
                    if multiState[item.key] == false then multiState[item.key] = nil end
                    updateSelText()
                    pcall(cb, multiState)
                    for _, fn in ipairs(callbacks) do pcall(fn, multiState) end
                    rebuild(searchBox and searchBox.Text or "")
                else
                    current = item.key
                    updateSelText()
                    pcall(cb, item.key)
                    for _, fn in ipairs(callbacks) do pcall(fn, item.key) end
                    list.Visible = false
                    open = false
                end
            end)

            table.insert(itemButtons, ib)
        end
    end

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuild(searchBox.Text) end)
    end

    rebuild()
    updateSelText()

    dbtn.MouseButton1Click:Connect(function()
        open = not open
        if open then updatePos(); list.Visible = true else list.Visible = false end
    end)
    dbtn.MouseEnter:Connect(function() U.Tween(dbtn, { BackgroundColor3 = Config.Theme.Accent }, 0.12) end)
    dbtn.MouseLeave:Connect(function()
        if not open then U.Tween(dbtn, { BackgroundColor3 = Config.Theme.Hover }, 0.12) end
    end)

    local element = {
        Instance = frame,
        Value = current,
        Values = values,
        Set = function(v)
            if multi and type(v) == "table" then
                multiState = {}
                for k, on in pairs(v) do if on then multiState[k] = true end end
                element.Value = multiState
                updateSelText()
                rebuild(searchBox and searchBox.Text or "")
            else
                current = v
                element.Value = v
                updateSelText()
                rebuild(searchBox and searchBox.Text or "")
            end
        end,
        Get = function() return element.Value end,
        SetValue = function(_, v) element.Set(v) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
        Refresh = function(_, newValues)
            values = newValues
            rebuild(searchBox and searchBox.Text or "")
        end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- LABEL / DIVIDER / PARAGRAPH
--==============================================================
function NovaUI:AddLabel(parent, text, wrap, idx)
    local lbl
    if type(text) == "table" then
        local opts = text
        text = opts.Text or ""
        wrap = opts.DoesWrap or false
        idx = opts.Idx or opts.Index
    end
    local f = U.Create("Frame", {
        Parent = parent.Container, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, wrap and 30 or 18),
        AutomaticSize = wrap and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
    })
    lbl = U.Create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        Font = Config.FontMedium,
        Text = text, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = wrap or false,
    })
    local element = {
        Instance = f,
        Set = function(v) lbl.Text = v end,
        Get = function() return lbl.Text end,
        SetText = function(_, v) lbl.Text = v end,
        AddColorPicker = function(_, pickerIdx, pickerOpts)
            return NovaUI:AddColorPicker(parent, pickerOpts or { Flag = pickerIdx })
        end,
        AddKeyPicker = function(_, pickerIdx, pickerOpts)
            return NovaUI:AddKeybind(parent, pickerOpts or { Flag = pickerIdx })
        end,
    }
    if idx then NovaUI.Flags[idx] = element end
    return element
end

function NovaUI:AddDivider(parent)
    local d = U.Create("Frame", {
        Parent = parent.Container,
        BackgroundColor3 = Config.Theme.Line,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
    })
    return { Instance = d }
end

function NovaUI:AddParagraph(parent, opts)
    opts = opts or {}
    local f = U.Create("Frame", {
        Parent = parent.Container,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
    })
    U.Corner(f, 5)
    U.Create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 14),
        Font = Config.FontBold,
        Text = opts.Title or "",
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local c = U.Create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 22),
        Size = UDim2.new(1, -20, 0, 22),
        Font = Config.Font,
        Text = opts.Content or "",
        TextColor3 = Config.Theme.Dim, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })
    return { Instance = f, Set = function(v) c.Text = v end, Get = function() return c.Text end }
end

--==============================================================
-- SEARCH BAR
--==============================================================
function NovaUI:AddSearchBar(parent, opts)
    opts = opts or {}
    local f = U.Create("Frame", {
        Parent = parent.Container,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26),
    })
    U.Corner(f, 5)
    U.Stroke(f, Config.Theme.Line, 1)

    U.Create("ImageLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Image = Icon("Search"),
        ImageColor3 = Config.Theme.Dim,
    })

    local box = U.Create("TextBox", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(1, -34, 1, 0),
        Font = Config.Font,
        Text = "", PlaceholderText = opts.Placeholder or "Search...",
        PlaceholderColor3 = Config.Theme.Dim,
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    box:GetPropertyChangedSignal("Text"):Connect(function() pcall(opts.Callback or function() end, box.Text) end)
    return { Instance = f, Set = function(v) box.Text = v end, Get = function() return box.Text end }
end

--==============================================================
-- COLORPICKER
--==============================================================
function NovaUI:AddColorPicker(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Color"
    local default = opts.Default or Color3.fromRGB(255, 255, 255)
    local cb = opts.Callback or function() end
    local flag = opts.Flag or opts.Index
    local title = opts.Title
    local allowTransparency = opts.Transparency ~= nil

    local frame = CreateBase(parent, Config.ElemHeight)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local colorBtn = U.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -60, 0.5, -9),
        Size = UDim2.new(0, 50, 0, 18),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(colorBtn, 4)

    local currentColor = default
    local currentTransparency = 0
    local callbacks = {}

    colorBtn.MouseButton1Click:Connect(function()
        local pickerGui = U.Create("ScreenGui", { Parent = CoreGui, ResetOnSpawn = false })
        local bg = U.Create("Frame", {
            Parent = pickerGui,
            BackgroundColor3 = Config.Theme.Bg,
            Size = UDim2.new(0, 220, 0, allowTransparency and 200 or 180),
            Position = UDim2.new(0, Mouse.X, 0, Mouse.Y),
        })
        U.Corner(bg, 8)
        U.Stroke(bg, Config.Theme.Line, 1)

        if title then
            U.Create("TextLabel", {
                Parent = bg, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 14),
                Font = Config.FontBold,
                Text = title,
                TextColor3 = Config.Theme.Text, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
        end

        local preview = U.Create("Frame", {
            Parent = bg,
            BackgroundColor3 = currentColor,
            Position = UDim2.new(0, 12, 0, title and 26 or 12),
            Size = UDim2.new(1, -24, 0, 30),
        })
        U.Corner(preview, 6)

        local baseY = (title and 26 or 12) + 40

        local function makeSlider(y, color, label)
            U.Create("TextLabel", {
                Parent = bg, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, y),
                Size = UDim2.new(0, 16, 0, 14),
                Font = Config.FontBold,
                Text = label,
                TextColor3 = Config.Theme.Text, TextSize = 11,
            })
            local bar = U.Create("Frame", {
                Parent = bg,
                BackgroundColor3 = Config.Theme.Hover,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 32, 0, y + 4),
                Size = UDim2.new(1, -44, 0, 6),
            })
            U.Corner(bar, 3)

            local val = currentColor[color == "R" and "R" or color == "G" and "G" or "B"]
            local fill = U.Create("Frame", {
                Parent = bar,
                BackgroundColor3 = color == "R" and Color3.fromRGB(255, 80, 80)
                    or color == "G" and Color3.fromRGB(80, 255, 80)
                    or Color3.fromRGB(80, 80, 255),
                BorderSizePixel = 0,
                Size = UDim2.new(val, 0, 1, 0),
            })
            U.Corner(fill, 3)

            local knob = U.Create("Frame", {
                Parent = bar,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(val, 0, 0.5, 0),
                Size = UDim2.new(0, 12, 0, 12),
            })
            U.Corner(knob, 6)

            local dragging = false
            local function update(input)
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
                pcall(cb, currentColor)
                for _, fn in ipairs(callbacks) do pcall(fn, currentColor) end
            end

            local hit = U.Create("TextButton", {
                Parent = bg, BackgroundTransparency = 1,
                Position = UDim2.new(0, 32, 0, y - 4),
                Size = UDim2.new(1, -44, 0, 18), Text = "",
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

        makeSlider(baseY, "R", "R")
        makeSlider(baseY + 24, "G", "G")
        makeSlider(baseY + 48, "B", "B")

        local close = U.Create("TextButton", {
            Parent = bg,
            BackgroundColor3 = Config.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 12, 1, -36),
            Size = UDim2.new(1, -24, 0, 24),
            Text = "", AutoButtonColor = false,
        })
        U.Corner(close, 5)
        U.Create("TextLabel", {
            Parent = close, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Config.FontBold,
            Text = "Apply",
            TextColor3 = Color3.new(1, 1, 1), TextSize = 11,
        })
        close.MouseButton1Click:Connect(function() pickerGui:Destroy() end)
        MakeDraggable(bg)
    end)

    local element = {
        Instance = frame,
        Value = currentColor,
        Transparency = currentTransparency,
        Set = function(c) currentColor = c; colorBtn.BackgroundColor3 = c; element.Value = c end,
        Get = function() return element.Value end,
        SetValue = function(_, c) element.Set(c) end,
        SetValueRGB = function(_, c) element.Set(c) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- PART 2 END
--==============================================================

--==============================================================
-- PART 3/4: ADVANCED FEATURES
--==============================================================
-- NovaUI is already local from Part 2

--==============================================================
-- TABBOX (Obsidian-style tabbed groupbox)
--==============================================================
function NovaUI:AddTabbox(parent, options)
    options = options or {}
    local side = options.Side or "Right"

    local tabbox = { Tabs = {}, ActiveTab = nil, _window = parent._window }

    -- Build outer container inside parent container
    local outer = U.Create("Frame", {
        Parent = parent.Container,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Corner(outer, 6)
    U.Stroke(outer, Config.Theme.Line, 1)
    tabbox.Frame = outer

    -- Tab strip
    local strip = U.Create("Frame", {
        Parent = outer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 6),
        Size = UDim2.new(1, -16, 0, 22),
    })
    U.Create("UIListLayout", {
        Parent = strip,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    tabbox.Strip = strip

    -- Body
    local body = U.Create("Frame", {
        Parent = outer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 32),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", {
        Parent = body,
        Padding = UDim.new(0, Config.Spacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    U.Create("UIPadding", {
        Parent = body,
        PaddingBottom = UDim.new(0, 8),
    })
    tabbox.Body = body

    function tabbox:AddTab(tabName)
        local t = { Name = tabName, Elements = {} }

        local btn = U.Create("TextButton", {
            Parent = strip,
            BackgroundColor3 = Config.Theme.Card,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 70, 1, 0),
            Text = "", AutoButtonColor = false,
        })
        U.Corner(btn, 4)
        t.Button = btn

        U.Create("TextLabel", {
            Parent = btn, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Config.FontMedium,
            Text = tabName,
            TextColor3 = Config.Theme.Dim,
            TextSize = 11,
        })
        t.Label = btn:FindFirstChildOfClass("TextLabel")

        local container = U.Create("Frame", {
            Parent = body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        U.Create("UIListLayout", {
            Parent = container,
            Padding = UDim.new(0, Config.Spacing),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        t.Container = container

        btn.MouseEnter:Connect(function()
            if tabbox.ActiveTab ~= t then
                U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12)
            end
        end)
        btn.MouseLeave:Connect(function()
            if tabbox.ActiveTab ~= t then
                U.Tween(btn, { BackgroundColor3 = Config.Theme.Card }, 0.12)
            end
        end)
        btn.MouseButton1Click:Connect(function()
            for _, tt in ipairs(tabbox.Tabs) do
                local on = (tt == t)
                tt.Container.Visible = on
                U.Tween(tt.Button, { BackgroundColor3 = on and Config.Theme.Accent or Config.Theme.Card }, 0.12)
                U.Tween(tt.Label, { TextColor3 = on and Color3.fromRGB(255, 255, 255) or Config.Theme.Dim }, 0.12)
            end
            tabbox.ActiveTab = t
        end)

        table.insert(tabbox.Tabs, t)
        if #tabbox.Tabs == 1 then
            container.Visible = true
            U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.12)
            U.Tween(t.Label, { TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.12)
            tabbox.ActiveTab = t
        end

        return t
    end

    return tabbox
end

--==============================================================
-- PLAYER DROPDOWN
--==============================================================
function NovaUI:AddPlayerDropdown(parent, opts)
    opts = opts or {}
    local excludeLocal = opts.ExcludeLocalPlayer or false

    local function getPlayers()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if not (excludeLocal and p == LocalPlayer) then
                table.insert(list, p.Name)
            end
        end
        return list
    end

    local dd = NovaUI:AddDropdown(parent, {
        Name = opts.Name or opts.Text or "Player",
        Values = getPlayers(),
        Default = opts.Default,
        Callback = opts.Callback,
        Flag = opts.Flag,
        Searchable = true,
    })

    local conn = Players.PlayerAdded:Connect(function()
        dd.Refresh(nil, getPlayers())
    end)
    local conn2 = Players.PlayerRemoving:Connect(function()
        dd.Refresh(nil, getPlayers())
    end)
    dd._playerConns = { conn, conn2 }

    return dd
end

--==============================================================
-- TEAM DROPDOWN
--==============================================================
function NovaUI:AddTeamDropdown(parent, opts)
    opts = opts or {}

    local function getTeams()
        local list = {}
        for _, t in ipairs(game:GetService("Teams"):GetTeams()) do
            table.insert(list, t.Name)
        end
        return list
    end

    local dd = NovaUI:AddDropdown(parent, {
        Name = opts.Name or opts.Text or "Team",
        Values = getTeams(),
        Default = opts.Default,
        Callback = opts.Callback,
        Flag = opts.Flag,
        Searchable = true,
    })
    return dd
end

--==============================================================
-- KEYBOX (key system input)
--==============================================================
function NovaUI:AddKeyBox(parent, callback)
    local frame = CreateBase(parent, 34)

    local boxBg = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(1, -90, 0, 20),
    })
    U.Corner(boxBg, 4)
    local stroke = U.Stroke(boxBg, Config.Theme.Line, 1)

    local box = U.Create("TextBox", {
        Parent = boxBg, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Config.Font,
        Text = "",
        PlaceholderText = "Enter key...",
        PlaceholderColor3 = Config.Theme.Dim,
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    box.Focused:Connect(function() U.Tween(stroke, { Color = Config.Theme.Accent }, 0.12) end)
    box.FocusLost:Connect(function() U.Tween(stroke, { Color = Config.Theme.Line }, 0.12) end)

    local submitBtn = U.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -70, 0.5, -10),
        Size = UDim2.new(0, 60, 0, 20),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(submitBtn, 4)
    U.Create("TextLabel", {
        Parent = submitBtn, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.FontBold,
        Text = "Submit",
        TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11,
    })
    submitBtn.MouseButton1Click:Connect(function()
        if callback then pcall(callback, box.Text) end
    end)

    return { Instance = frame, Get = function() return box.Text end }
end

--==============================================================
-- WARNING BOX (tab-level)
--==============================================================
function NovaUI:AddWarningBox(tab, opts)
    opts = opts or {}
    local frame = U.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Color3.fromRGB(60, 40, 20),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = opts.Visible ~= false,
    })
    U.Corner(frame, 5)
    U.Stroke(frame, Config.Theme.Yellow, 1)

    U.Create("ImageLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 14, 0, 14),
        Image = Icon("Warning"),
        ImageColor3 = Config.Theme.Yellow,
    })
    U.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 10),
        Size = UDim2.new(1, -44, 0, 14),
        Font = Config.FontBold,
        Text = opts.Title or "Warning",
        TextColor3 = Config.Theme.Yellow, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local body = U.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Config.Font,
        Text = opts.Text or "",
        TextColor3 = Config.Theme.Text, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })
    U.Create("UIPadding", { Parent = frame, PaddingBottom = UDim.new(0, 10) })

    return {
        Instance = frame,
        SetVisible = function(_, v) frame.Visible = v end,
        SetTitle = function(_, t)
            frame:FindFirstChildOfClass("TextLabel").Text = t
        end,
        SetText = function(_, t) body.Text = t end,
    }
end

--==============================================================
-- DEPENDENCY BOX (attach to any element, show/hide based on toggle)
--==============================================================
function NovaUI:CreateDependencyBox()
    local dep = {}
    dep.Container = U.Create("Frame", {
        Parent = nil,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", {
        Parent = dep.Container,
        Padding = UDim.new(0, Config.Spacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    function dep:SetParent(parent)
        dep.Container.Parent = parent.Container
    end

    function dep:BindToToggle(toggle)
        local function update(v)
            dep.Container.Visible = v
        end
        update(toggle.Get and toggle:Get() or toggle.Value or false)
        local orig = toggle.OnChanged
        toggle.OnChanged = function(self, fn)
            orig(self, function(v) fn(v); update(v) end)
        end
    end

    function dep:BindToDropdown(dd, expectedValue)
        local function update(v)
            if type(v) == "table" then
                for k, on in pairs(v) do
                    if on and (k == expectedValue) then dep.Container.Visible = true; return end
                end
                dep.Container.Visible = false
            else
                dep.Container.Visible = (v == expectedValue)
            end
        end
        update(dd.Value)
        dd.OnChanged = function(self, fn)
            local orig = self.OnChanged
            -- chain
        end
    end

    return dep
end

--==============================================================
-- THEME MANAGER
--==============================================================
local ThemeManager = {}
ThemeManager.__index = ThemeManager

local BuiltinThemes = {
    Dark = {
        Bg = Color3.fromRGB(14, 14, 17),
        Panel = Color3.fromRGB(20, 20, 24),
        Card = Color3.fromRGB(26, 26, 31),
        Hover = Color3.fromRGB(34, 34, 40),
        Line = Color3.fromRGB(42, 42, 48),
        Text = Color3.fromRGB(235, 235, 240),
        Dim = Color3.fromRGB(125, 125, 140),
        Accent = Color3.fromRGB(124, 92, 255),
    },
    Midnight = {
        Bg = Color3.fromRGB(10, 12, 22),
        Panel = Color3.fromRGB(16, 20, 36),
        Card = Color3.fromRGB(22, 28, 48),
        Hover = Color3.fromRGB(30, 38, 60),
        Line = Color3.fromRGB(40, 50, 78),
        Text = Color3.fromRGB(220, 228, 255),
        Dim = Color3.fromRGB(120, 132, 165),
        Accent = Color3.fromRGB(80, 140, 255),
    },
    Ocean = {
        Bg = Color3.fromRGB(10, 20, 24),
        Panel = Color3.fromRGB(14, 28, 34),
        Card = Color3.fromRGB(20, 38, 46),
        Hover = Color3.fromRGB(28, 50, 60),
        Line = Color3.fromRGB(36, 62, 74),
        Text = Color3.fromRGB(220, 240, 245),
        Dim = Color3.fromRGB(120, 145, 155),
        Accent = Color3.fromRGB(40, 200, 200),
    },
    Rose = {
        Bg = Color3.fromRGB(20, 12, 18),
        Panel = Color3.fromRGB(28, 16, 24),
        Card = Color3.fromRGB(36, 20, 32),
        Hover = Color3.fromRGB(46, 28, 40),
        Line = Color3.fromRGB(60, 36, 54),
        Text = Color3.fromRGB(245, 225, 235),
        Dim = Color3.fromRGB(155, 125, 140),
        Accent = Color3.fromRGB(255, 80, 160),
    },
    Monochrome = {
        Bg = Color3.fromRGB(12, 12, 12),
        Panel = Color3.fromRGB(20, 20, 20),
        Card = Color3.fromRGB(28, 28, 28),
        Hover = Color3.fromRGB(38, 38, 38),
        Line = Color3.fromRGB(50, 50, 50),
        Text = Color3.fromRGB(240, 240, 240),
        Dim = Color3.fromRGB(140, 140, 140),
        Accent = Color3.fromRGB(200, 200, 200),
    },
    Blood = {
        Bg = Color3.fromRGB(16, 10, 10),
        Panel = Color3.fromRGB(24, 14, 14),
        Card = Color3.fromRGB(32, 18, 18),
        Hover = Color3.fromRGB(44, 24, 24),
        Line = Color3.fromRGB(58, 30, 30),
        Text = Color3.fromRGB(245, 225, 225),
        Dim = Color3.fromRGB(160, 120, 120),
        Accent = Color3.fromRGB(220, 40, 60),
    },
}

function ThemeManager.new()
    local self = setmetatable({}, ThemeManager)
    self._windows = {}
    return self
end

function ThemeManager:ApplyTheme(name)
    local theme = BuiltinThemes[name]
    if not theme then return end
    for k, v in pairs(theme) do
        Config.Theme[k] = v
    end
    for _, w in ipairs(NovaUI.Windows) do
        if w.Main then w.Main.BackgroundColor3 = Config.Theme.Bg end
        if w.Header then w.Header.BackgroundColor3 = Config.Theme.Panel end
    end
    NovaUI.Notify("Theme", "Applied: " .. name, Config.Theme.Accent, 2)
end

function ThemeManager:GetThemeNames()
    local names = {}
    for k in pairs(BuiltinThemes) do table.insert(names, k) end
    table.sort(names)
    return names
end

function ThemeManager:BuildUI(tab, side)
    local group = NovaUI:AddGroupbox(tab, {
        Name = "Themes",
        Side = side or "Left",
        Icon = "Palette",
    })

    local names = self:GetThemeNames()
    NovaUI:AddDropdown(group, {
        Name = "Select Theme",
        Values = names,
        Default = "Dark",
        Searchable = false,
        Callback = function(v) self:ApplyTheme(v) end,
    })

    for _, name in ipairs(names) do
        local t = BuiltinThemes[name]
        NovaUI:AddButton(group, {
            Name = name,
            Icon = "Palette",
            Callback = function() self:ApplyTheme(name) end,
        })
    end

    return group
end

NovaUI.ThemeManager = ThemeManager.new()

--==============================================================
-- SAVE MANAGER
--==============================================================
local SaveManager = {}
SaveManager.__index = SaveManager

function SaveManager.new()
    local self = setmetatable({}, SaveManager)
    self.Folder = "NovaUI"
    self.SubFolder = ""
    self.IgnoreIndexes = {}
    self.LoadedConfig = nil
    return self
end

function SaveManager:SetFolder(f) self.Folder = f end
function SaveManager:SetSubFolder(f) self.SubFolder = f end
function SaveManager:SetIgnoreIndexes(t) self.IgnoreIndexes = t or {} end
function SaveManager:IgnoreThemeSettings() end

function SaveManager:_isIgnored(idx)
    for _, ig in ipairs(self.IgnoreIndexes) do
        if ig == idx then return true end
    end
    return false
end

function SaveManager:_filePath(name)
    local parts = { self.Folder }
    if self.SubFolder and self.SubFolder ~= "" then table.insert(parts, self.SubFolder) end
    table.insert(parts, name .. ".json")
    return table.concat(parts, "/")
end

function SaveManager:Save(name)
    if not writefile then
        NovaUI.Notify("Save Manager", "writefile not available (executor required).", Config.Theme.Red, 3)
        return
    end
    name = name or "default"
    local data = {}
    for idx, el in pairs(NovaUI.Flags) do
        if not self:_isIgnored(idx) then
            if type(el.Get) == "function" then
                local v = el:Get()
                if typeof(v) == "Color3" then
                    data[idx] = { __type = "Color3", R = v.R, G = v.G, B = v.B }
                else
                    data[idx] = v
                end
            end
        end
    end
    local ok, err = pcall(function()
        if makefolder then
            pcall(makefolder, self.Folder)
            if self.SubFolder ~= "" then pcall(makefolder, self.Folder .. "/" .. self.SubFolder) end
        end
        writefile(self:_filePath(name), HttpService:JSONEncode(data))
    end)
    if ok then
        NovaUI.Notify("Save Manager", "Saved: " .. name, Config.Theme.Green, 2)
    else
        NovaUI.Notify("Save Manager", "Save failed: " .. tostring(err), Config.Theme.Red, 3)
    end
end

function SaveManager:Load(name)
    if not (readfile and isfile) then
        NovaUI.Notify("Save Manager", "readfile not available (executor required).", Config.Theme.Red, 3)
        return
    end
    name = name or "default"
    local path = self:_filePath(name)
    if not isfile(path) then
        NovaUI.Notify("Save Manager", "Config not found: " .. name, Config.Theme.Yellow, 2)
        return
    end
    local ok, raw = pcall(readfile, path)
    if not ok then
        NovaUI.Notify("Save Manager", "Read failed.", Config.Theme.Red, 3)
        return
    end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 then
        NovaUI.Notify("Save Manager", "Invalid JSON.", Config.Theme.Red, 3)
        return
    end
    for idx, v in pairs(data) do
        local el = NovaUI.Flags[idx]
        if el and not self:_isIgnored(idx) then
            if type(v) == "table" and v.__type == "Color3" then
                pcall(function() el:Set(Color3.new(v.R, v.G, v.B)) end)
            else
                pcall(function() el:Set(v) end)
            end
        end
    end
    self.LoadedConfig = name
    NovaUI.Notify("Save Manager", "Loaded: " .. name, Config.Theme.Green, 2)
end

function SaveManager:Delete(name)
    if not (delfile and isfile) then return end
    name = name or "default"
    local path = self:_filePath(name)
    if isfile(path) then pcall(delfile, path) end
end

function SaveManager:ListConfigs()
    if not listfiles then return {} end
    local path = self.Folder
    if self.SubFolder ~= "" then path = path .. "/" .. self.SubFolder end
    local ok, files = pcall(listfiles, path)
    if not ok then return {} end
    local out = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(out, n) end
    end
    return out
end

function SaveManager:BuildConfigSection(tab, side)
    local group = NovaUI:AddGroupbox(tab, {
        Name = "Configs",
        Side = side or "Right",
        Icon = "Save",
    })

    NovaUI:AddTextbox(group, {
        Name = "Config Name",
        Default = "default",
        Placeholder = "config name",
        Flag = "_cfgName",
    })

    NovaUI:AddButton(group, {
        Name = "Save",
        Icon = "Save",
        Callback = function()
            local n = NovaUI.Flags._cfgName and NovaUI.Flags._cfgName:Get() or "default"
            self:Save(n)
        end,
    })
    NovaUI:AddButton(group, {
        Name = "Load",
        Icon = "Download",
        Callback = function()
            local n = NovaUI.Flags._cfgName and NovaUI.Flags._cfgName:Get() or "default"
            self:Load(n)
        end,
    })
    NovaUI:AddButton(group, {
        Name = "Delete",
        Icon = "Trash",
        Risky = true,
        Callback = function()
            local n = NovaUI.Flags._cfgName and NovaUI.Flags._cfgName:Get() or "default"
            self:Delete(n)
        end,
    })
    NovaUI:AddDropdown(group, {
        Name = "Saved Configs",
        Values = self:ListConfigs(),
        Searchable = true,
        Callback = function(v)
            local tb = NovaUI.Flags._cfgName
            if tb then tb:Set(v) end
        end,
    })

    return group
end

function SaveManager:LoadAutoloadConfig()
    -- noop for parity; user can call :Load explicitly
end

NovaUI.SaveManager = SaveManager.new()

--==============================================================
-- KEYBIND MENU (floating frame showing all keybinds)
--==============================================================
local KeybindMenu = {}
KeybindMenu.__index = KeybindMenu

function KeybindMenu.new(window)
    local self = setmetatable({}, KeybindMenu)
    self.Window = window
    self.Frame = U.Create("Frame", {
        Parent = window.ScreenGui,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 12),
        Size = UDim2.new(0, 180, 0, 40),
        Visible = false,
        ZIndex = 40,
    })
    U.Corner(self.Frame, 6)
    U.Stroke(self.Frame, Config.Theme.Line, 1)

    local header = U.Create("Frame", {
        Parent = self.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
    })
    U.Create("TextLabel", {
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Config.FontBold,
        Text = "Keybinds",
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    self.List = U.Create("Frame", {
        Parent = self.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 26),
        Size = UDim2.new(1, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", {
        Parent = self.List,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    MakeDraggable(self.Frame, header)
    return self
end

function KeybindMenu:SetVisibilityControl(v)
    self.Frame.Visible = v
end

--==============================================================
-- DRAGGABLE LABEL
--==============================================================
function NovaUI:AddDraggableLabel(text, opts)
    opts = opts or {}
    local screen = NovaUI.DraggableGui
    if not screen then
        screen = U.Create("ScreenGui", {
            Name = "NovaUI_Draggables",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui,
        })
        NovaUI.DraggableGui = screen
    end
    local lbl = U.Create("TextLabel", {
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 20, 0, 100),
        Size = UDim2.new(0, 0, 0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Config.FontBold,
        Text = "  " .. text .. "  ",
        TextColor3 = Config.Theme.Text,
        TextSize = 12,
    })
    U.Corner(lbl, 4)
    U.Stroke(lbl, Config.Theme.Line, 1)
    MakeDraggable(lbl, lbl)
    return lbl
end

--==============================================================
-- PART 3 END
--==============================================================

--==============================================================
-- PART 4/4: FINAL WIRING + PUBLIC API
--==============================================================
-- NovaUI local from Part 2/3

--==============================================================
-- KEYBIND MENU WIRING (auto-build on each window)
--==============================================================
-- Hook into window creation to add a KeybindMenu automatically
local _origCreateWindow = NovaUI.CreateWindow
function NovaUI:CreateWindow(options)
    local win = _origCreateWindow(self, options)
    -- Attach a keybind menu
    local kbMenu = KeybindMenu.new(win)
    win.KeybindFrame = kbMenu.Frame
    win.KeybindMenu = kbMenu
    -- Populate keybinds (scan Flags for any keybind instances)
    task.spawn(function()
        task.wait(0.5)
        for flag, el in pairs(NovaUI.Flags) do
            if el.Instance and el.GetState and el.Value ~= nil and type(el.Value) == "string" then
                local row = U.Create("Frame", {
                    Parent = kbMenu.List,
                    BackgroundColor3 = Config.Theme.Card,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 20),
                })
                U.Corner(row, 4)
                U.Create("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Config.FontMedium,
                    Text = tostring(flag),
                    TextColor3 = Config.Theme.Text,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                U.Create("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.6, 0, 0, 0),
                    Size = UDim2.new(0.4, -8, 1, 0),
                    Font = Config.FontBold,
                    Text = tostring(el.Value),
                    TextColor3 = Config.Theme.Accent,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
            end
        end
        -- Resize menu
        local layout = kbMenu.List:FindFirstChildOfClass("UIListLayout")
        if layout then
            kbMenu.Frame.Size = UDim2.new(0, 180, 0, 40 + layout.AbsoluteContentSize.Y)
        end
    end)
    return win
end

--==============================================================
-- TABBOX ALIAS (Side-based Tabbox, Obsidian-compatible naming)
--==============================================================
function NovaUI:AddLeftTabbox(parent)
    return self:AddTabbox(parent, { Side = "Left" })
end

function NovaUI:AddRightTabbox(parent)
    return self:AddTabbox(parent, { Side = "Right" })
end

function NovaUI:AddLeftGroupbox(tab, name, icon)
    return self:AddGroupbox(tab, {
        Side = "Left",
        Name = name or "Group",
        Icon = icon or "Boxes",
    })
end

function NovaUI:AddRightGroupbox(tab, name, icon)
    return self:AddGroupbox(tab, {
        Side = "Right",
        Name = name or "Group",
        Icon = icon or "Boxes",
    })
end

--==============================================================
-- BULK REGISTER ELEMENTS ON WINDOW (so users can call Window:AddToggle)
--==============================================================
-- Provide tab-level and group-level method aliases so both call styles work:
--   Window:AddButton(tab, opts)          -- NovaUI style
--   tab:AddButton(opts)                  -- Obsidian style
--   group:AddButton(opts)                -- Obsidian style

function NovaUI:_RegisterTabMethods(tab)
    tab.AddButton = function(_, opts) return NovaUI:AddButton(tab, opts) end
    tab.AddToggle = function(_, opts) return NovaUI:AddToggle(tab, opts) end
    tab.AddCheckbox = function(_, opts) return NovaUI:AddCheckbox(tab, opts) end
    tab.AddSlider = function(_, opts) return NovaUI:AddSlider(tab, opts) end
    tab.AddTextbox = function(_, opts) return NovaUI:AddTextbox(tab, opts) end
    tab.AddInput = function(_, opts) return NovaUI:AddTextbox(tab, opts) end
    tab.AddKeybind = function(_, opts) return NovaUI:AddKeybind(tab, opts) end
    tab.AddDropdown = function(_, opts) return NovaUI:AddDropdown(tab, opts) end
    tab.AddLabel = function(_, text, wrap, idx) return NovaUI:AddLabel(tab, text, wrap, idx) end
    tab.AddDivider = function(_) return NovaUI:AddDivider(tab) end
    tab.AddParagraph = function(_, opts) return NovaUI:AddParagraph(tab, opts) end
    tab.AddColorPicker = function(_, opts) return NovaUI:AddColorPicker(tab, opts) end
    tab.AddSearchBar = function(_, opts) return NovaUI:AddSearchBar(tab, opts) end
    tab.AddSection = function(_, name) return NovaUI:AddSection(tab, name) end
    tab.AddGroupbox = function(_, opts) return NovaUI:AddGroupbox(tab, opts) end
    tab.AddTabbox = function(_, opts) return NovaUI:AddTabbox(tab, opts) end
    tab.AddLeftTabbox = function(_) return NovaUI:AddLeftTabbox(tab) end
    tab.AddRightTabbox = function(_) return NovaUI:AddRightTabbox(tab) end
    tab.AddLeftGroupbox = function(_, n, i) return NovaUI:AddLeftGroupbox(tab, n, i) end
    tab.AddRightGroupbox = function(_, n, i) return NovaUI:AddRightGroupbox(tab, n, i) end
    tab.AddWarningBox = function(_, opts) return NovaUI:AddWarningBox(tab, opts) end
    tab.AddKeyBox = function(_, cb) return NovaUI:AddKeyBox(tab, cb) end
    tab.AddPlayerDropdown = function(_, opts) return NovaUI:AddPlayerDropdown(tab, opts) end
    tab.AddTeamDropdown = function(_, opts) return NovaUI:AddTeamDropdown(tab, opts) end
    tab.UpdateWarningBox = function(self, opts)
        local wb = NovaUI.Flags["__warnbox_" .. tostring(tab.Name)]
        if wb then
            wb:SetVisible(opts.Visible)
            if opts.Title then wb:SetTitle(opts.Title) end
            if opts.Text then wb:SetText(opts.Text) end
        end
    end
    return tab
end

function NovaUI:_RegisterGroupMethods(group)
    group.AddButton = function(_, opts) return NovaUI:AddButton(group, opts) end
    group.AddToggle = function(_, opts) return NovaUI:AddToggle(group, opts) end
    group.AddCheckbox = function(_, opts) return NovaUI:AddCheckbox(group, opts) end
    group.AddSlider = function(_, opts) return NovaUI:AddSlider(group, opts) end
    group.AddTextbox = function(_, opts) return NovaUI:AddTextbox(group, opts) end
    group.AddInput = function(_, opts) return NovaUI:AddTextbox(group, opts) end
    group.AddKeybind = function(_, opts) return NovaUI:AddKeybind(group, opts) end
    group.AddKeyPicker = function(_, opts) return NovaUI:AddKeybind(group, opts) end
    group.AddDropdown = function(_, opts) return NovaUI:AddDropdown(group, opts) end
    group.AddLabel = function(_, text, wrap, idx) return NovaUI:AddLabel(group, text, wrap, idx) end
    group.AddDivider = function(_) return NovaUI:AddDivider(group) end
    group.AddParagraph = function(_, opts) return NovaUI:AddParagraph(group, opts) end
    group.AddColorPicker = function(_, opts) return NovaUI:AddColorPicker(group, opts) end
    group.AddSearchBar = function(_, opts) return NovaUI:AddSearchBar(group, opts) end
    group.AddPlayerDropdown = function(_, opts) return NovaUI:AddPlayerDropdown(group, opts) end
    group.AddTeamDropdown = function(_, opts) return NovaUI:AddTeamDropdown(group, opts) end
    group.AddDependencyBox = function(_) return NovaUI:CreateDependencyBox() end
    return group
end

--==============================================================
-- HOOK: CreateTab now registers methods
--==============================================================
local _origCreateTab = NovaUI.CreateTab
function NovaUI:CreateTab(options)
    local tab = _origCreateTab(self, options)
    return self:_RegisterTabMethods(tab)
end

--==============================================================
-- HOOK: AddGroupbox registers methods
--==============================================================
local _origAddGroupbox = NovaUI.AddGroupbox
function NovaUI:AddGroupbox(tab, options)
    local g = _origAddGroupbox(self, tab, options)
    return self:_RegisterGroupMethods(g)
end

--==============================================================
-- HOOK: Tabbox tabs get group-style methods
--==============================================================
local _origAddTabbox = NovaUI.AddTabbox
function NovaUI:AddTabbox(parent, options)
    local tb = _origAddTabbox(self, parent, options)
    local origAddTab = tb.AddTab
    tb.AddTab = function(self2, tabName)
        local t = origAddTab(self2, tabName)
        return NovaUI:_RegisterGroupMethods(t)
    end
    return tb
end

--==============================================================
-- KEYBIND MENU TOGGLE + MENU BINDING (per-window)
--==============================================================
function NovaUI:SetupMenuKeybind(menuKey, keybindFrameToggleFn)
    menuKey = menuKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == menuKey then
            if keybindFrameToggleFn then keybindFrameToggleFn() end
        end
    end)
end

--==============================================================
-- THEME MANAGER + SAVE MANAGER: attach to a window
--==============================================================
function NovaUI:AttachManagers(window, uiSettingsTab)
    if uiSettingsTab then
        NovaUI.ThemeManager:BuildUI(uiSettingsTab, "Left")
        NovaUI.SaveManager:BuildConfigSection(uiSettingsTab, "Right")
    end
    window.ThemeManager = NovaUI.ThemeManager
    window.SaveManager = NovaUI.SaveManager
end

--==============================================================
-- PUBLIC API SURFACE
--==============================================================
NovaUI.Version = "4.0.0"
NovaUI.BuiltinThemes = BuiltinThemes
NovaUI._IconInternal = Icon
NovaUI._CreateBase = CreateBase
NovaUI._CreateGroupRow = CreateGroupRow
NovaUI._GetContainer = GetContainer
NovaUI._MakeDraggable = MakeDraggable
NovaUI._MakeResizable = MakeResizable
NovaUI.KeybindMenuClass = KeybindMenu

--==============================================================
-- GLOBAL EXPORTS (Obsidian-parity helpers)
--==============================================================
pcall(function()
    getgenv().NovaUI = NovaUI
end)

--==============================================================
-- INITIALIZATION
--==============================================================
print(("[NovaUI v%s] Loaded successfully | %d icons | %d built-in themes"):format(
    NovaUI.Version,
    (function() local n = 0; for _ in pairs(Icons) do n = n + 1 end; return n end)(),
    (function() local n = 0; for _ in pairs(BuiltinThemes) do n = n + 1 end; return n end)()
))

-- Clear the temporary global
_NovaUIPartial = nil

return NovaUI
--==============================================================
-- END OF NOVAUI v4.0
--==============================================================
