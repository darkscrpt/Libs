--[[
    NovaUI v3.0 - Compact Modern Roblox UI Library
    Uses icons from icons.rest (Lucide icon set)
    License: MIT
]]

--==============================================================
-- SERVICES
--==============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

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
}

--==============================================================
-- ICONS (icons.rest / Lucide)
--==============================================================
local Icons = {
    Home      = "rbxassetid://10723407383",
    Settings  = "rbxassetid://10734898355",
    Info      = "rbxassetid://10734904191",
    List      = "rbxassetid://10734911770",
    Palette   = "rbxassetid://10734922069",
    Wrench    = "rbxassetid://10734936564",
    User      = "rbxassetid://10734948940",
    Close     = "rbxassetid://10734897593",
    Minus     = "rbxassetid://10734897593",
    Check     = "rbxassetid://10734897983",
    Plus      = "rbxassetid://10734905351",
    Search    = "rbxassetid://10734940165",
    Refresh   = "rbxassetid://10734935063",
    Copy      = "rbxassetid://10734898475",
    Bell      = "rbxassetid://10734895955",
    Star      = "rbxassetid://10734945940",
    Chevron   = "rbxassetid://10734895495",
    Play      = "rbxassetid://10734934538",
    Trash     = "rbxassetid://10734948940",
    Save      = "rbxassetid://10734934677",
    Warning   = "rbxassetid://10734936967",
    Shield    = "rbxassetid://10734948940",
    Zap       = "rbxassetid://10734922069",
    Eye       = "rbxassetid://10734903172",
    Crosshair = "rbxassetid://10734911770",
}
local function Icon(name) return Icons[name] or Icons.Info end

--==============================================================
-- UTIL
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

--==============================================================
-- CORE
--==============================================================
local NovaUI = {}
NovaUI.__index = NovaUI
NovaUI.Flags = {}
NovaUI.Windows = {}
NovaUI.Theme = Config.Theme
NovaUI.Config = Config
NovaUI.Utility = U
NovaUI.Icons = Icons

--==============================================================
-- DRAG
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
-- RESIZE
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
local function PlayLoadingScreen(duration)
    duration = duration or 1.6
    local screen = U.Create("ScreenGui", {
        Name = "NovaUI_Loading",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = CoreGui,
    })

    -- Full black backdrop
    local backdrop = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
    })

    -- Sharp rectangle in center (NO corner radius)
    local sizeX, sizeY = 240, 90
    local box = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(12, 12, 14),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, sizeX, 0, sizeY),
    })

    -- Thin border outline (subtle)
    U.Create("UIStroke", {
        Parent = box,
        Color = Color3.fromRGB(28, 28, 32),
        Thickness = 1,
        Transparency = 0.2,
    })

    -- Title text
    U.Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -16),
        Size = UDim2.new(1, 0, 0, 22),
        Font = Config.FontBold,
        Text = "NovaUI",
        TextColor3 = Color3.fromRGB(235, 235, 240),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    -- Subtitle
    U.Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 6),
        Size = UDim2.new(1, 0, 0, 14),
        Font = Config.Font,
        Text = "loading modules...",
        TextColor3 = Color3.fromRGB(120, 120, 135),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    -- ==============================================
    -- Animated green perimeter line
    -- Built from 4 segments (top, right, bottom, left)
    -- Each segment grows in sequence to form a loop
    -- ==============================================
    local lineColor = Config.Theme.Green
    local thickness = 2

    -- The perimeter line container (just above box border, outside)
    local inset = 1 -- how far outside the box the line sits

    local top = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = lineColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -sizeY / 2 - inset),
        Size = UDim2.new(0, 0, 0, thickness),
    })
    local right = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = lineColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, sizeX / 2 + inset, 0.5, 0),
        Size = UDim2.new(0, thickness, 0, 0),
    })
    local bottom = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = lineColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, sizeX / 2 + inset, 0.5, sizeY / 2 + inset),
        Size = UDim2.new(0, 0, 0, thickness),
    })
    local left = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = lineColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0.5, -sizeX / 2 - inset, 0.5, sizeY / 2 + inset),
        Size = UDim2.new(0, thickness, 0, 0),
    })

    -- Animate: top → right → bottom → left
    local per = duration / 4
    local ease = Enum.EasingStyle.Quad

    U.Tween(top,    { Size = UDim2.new(0, sizeX + inset * 2, 0, thickness) }, per, ease)
    task.wait(per)
    U.Tween(right,  { Size = UDim2.new(0, thickness, 0, sizeY + inset * 2) }, per, ease)
    task.wait(per)
    U.Tween(bottom, { Size = UDim2.new(0, sizeX + inset * 2, 0, thickness) }, per, ease)
    task.wait(per)
    U.Tween(left,   { Size = UDim2.new(0, thickness, 0, sizeY + inset * 2) }, per, ease)
    task.wait(per)

    -- ==============================================
    -- Line complete → fade everything out
    -- ==============================================
    task.wait(0.08)

    local fadeList = { top, right, bottom, left }
    for _, seg in ipairs(fadeList) do
        U.Tween(seg, { BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Sine)
    end
    U.Tween(box, { BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Sine)
    for _, child in ipairs(box:GetChildren()) do
        if child:IsA("TextLabel") then
            U.Tween(child, { TextTransparency = 1 }, 0.3)
        elseif child:IsA("UIStroke") then
            U.Tween(child, { Transparency = 1 }, 0.3)
        end
    end

    task.wait(0.35)
    U.Tween(backdrop, { BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Sine)
    task.wait(0.32)
    screen:Destroy()
end

NovaUI.PlayLoadingScreen = PlayLoadingScreen

--==============================================================
-- NOTIFICATIONS (clean, minimal)
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

    -- Push existing up
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

    -- Left accent bar
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

    -- Thin progress bar at bottom
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

    -- Intro slide
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
    local showLoading = options.Loading ~= false

    -- Play the loading screen first
    if showLoading then
        PlayLoadingScreen(1.6)
    end

    local self = setmetatable({}, NovaUI)
    self.Name = windowName
    self.Tabs = {}
    self.ActiveTab = nil
    self.Flags = {}
    self.Minimized = false

    local screen = U.Create("ScreenGui", {
        Name = "NovaUI_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    self.ScreenGui = screen

    local blur = U.Create("BlurEffect", {
        Parent = game:GetService("Lighting"),
        Size = 0,
        Name = "NovaUI_Blur_" .. HttpService:GenerateGUID(false),
    })
    self.Blur = blur

    -- ============ MAIN ============
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

    -- ============ HEADER ============
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

    -- accent dot
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

    -- ============ SIDEBAR ============
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

    -- ============ CONTENT ============
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

    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
            if blur then U.Tween(blur, { Size = main.Visible and 10 or 0 }, 0.25) end
        end
    end)

    -- Intro animation (fades in after loading screen)
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

function NovaUI:Destroy()
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

    local tab = { Name = tabName, Window = self, Elements = {} }

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
-- SECTION
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
-- BASE ELEMENT
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

--==============================================================
-- BUTTON
--==============================================================
function NovaUI:AddButton(tab, opts)
    opts = opts or {}
    local name = opts.Name or "Button"
    local icon = opts.Icon or "Play"
    local cb   = opts.Callback or function() end

    local btn = U.Create("TextButton", {
        Parent = tab.Container,
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
        TextColor3 = Config.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    btn.MouseEnter:Connect(function()
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12)
        U.Tween(iconImg, { ImageColor3 = Config.Theme.Accent }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Card }, 0.12)
        U.Tween(iconImg, { ImageColor3 = Config.Theme.Dim }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.08)
        task.delay(0.08, function() U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12) end)
        pcall(cb)
    end)

    return { Instance = btn }
end

--==============================================================
-- TOGGLE
--==============================================================
function NovaUI:AddToggle(tab, opts)
    opts = opts or {}
    local name = opts.Name or "Toggle"
    local default = opts.Default or false
    local cb = opts.Callback or function() end
    local flag = opts.Flag

    local frame = CreateBase(tab)

    U.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text,
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
    local function set(v, fire)
        state = v
        if state then
            U.Tween(track, { BackgroundColor3 = Config.Theme.Accent }, 0.18)
            U.Tween(knob, { Position = UDim2.new(1, -12, 0.5, -6) }, 0.18)
        else
            U.Tween(track, { BackgroundColor3 = Config.Theme.Hover }, 0.18)
            U.Tween(knob, { Position = UDim2.new(0, 2, 0.5, -6) }, 0.18)
        end
        if fire then pcall(cb, state) end
    end

    local click = U.Create("TextButton", {
        Parent = frame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "",
    })
    click.MouseButton1Click:Connect(function() set(not state, true) end)

    local el = {
        Instance = frame,
        Set = function(v) set(v, false) end,
        Get = function() return state end,
        Toggle = function() set(not state, true) end,
    }
    if flag then NovaUI.Flags[flag] = el end
    if default then pcall(cb, state) end
    return el
end

--==============================================================
-- SLIDER
--==============================================================
function NovaUI:AddSlider(tab, opts)
    opts = opts or {}
    local name = opts.Name or "Slider"
    local min, max = opts.Min or 0, opts.Max or 100
    local default = opts.Default or min
    local suffix = opts.Suffix or ""
    local cb = opts.Callback or function() end
    local flag = opts.Flag

    local frame = CreateBase(tab, 40)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 6),
        Size = UDim2.new(0.7, 0, 0, 14),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local valLbl = U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 6),
        Size = UDim2.new(0.3, -10, 0, 14),
        Font = Config.FontMedium,
        Text = tostring(default) .. suffix,
        TextColor3 = Config.Theme.Accent, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local barBg = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -16),
        Size = UDim2.new(1, -20, 0, 4),
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

    local function update(input)
        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local nv = U.Round(min + (max - min) * rel, opts.Decimals or 0)
        if nv ~= value then
            value = nv
            valLbl.Text = tostring(value) .. suffix
            U.Tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.04)
            U.Tween(knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.04)
            pcall(cb, value)
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

    local el = {
        Instance = frame,
        Set = function(v)
            v = math.clamp(v, min, max); value = v
            local p = (v - min) / (max - min)
            valLbl.Text = tostring(v) .. suffix
            U.Tween(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.12)
            U.Tween(knob, { Position = UDim2.new(p, 0, 0.5, 0) }, 0.12)
        end,
        Get = function() return value end,
    }
    if flag then NovaUI.Flags[flag] = el end
    return el
end

--==============================================================
-- TEXTBOX
--==============================================================
function NovaUI:AddTextbox(tab, opts)
    opts = opts or {}
    local name = opts.Name or "Input"
    local default = opts.Default or ""
    local ph = opts.Placeholder or "Type..."
    local cb = opts.Callback or function() end
    local flag = opts.Flag

    local frame = CreateBase(tab)

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
        ClearTextOnFocus = false,
    })
    box.Focused:Connect(function() U.Tween(stroke, { Color = Config.Theme.Accent }, 0.12) end)
    box.FocusLost:Connect(function(enter)
        U.Tween(stroke, { Color = Config.Theme.Line }, 0.12)
        if enter then pcall(cb, box.Text) end
    end)
    box:GetPropertyChangedSignal("Text"):Connect(function() pcall(cb, box.Text) end)

    local el = {
        Instance = frame,
        Set = function(v) box.Text = v end,
        Get = function() return box.Text end,
    }
    if flag then NovaUI.Flags[flag] = el end
    return el
end

--==============================================================
-- KEYBIND
--==============================================================
function NovaUI:AddKeybind(tab, opts)
    opts = opts or {}
    local name = opts.Name or "Keybind"
    local default = opts.Default or Enum.KeyCode.E
    local cb = opts.Callback or function() end
    local flag = opts.Flag

    local frame = CreateBase(tab)

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
        Text = default.Name,
        TextColor3 = Config.Theme.Text, TextSize = 11,
    })

    local current, listening = default, false
    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true; lbl.Text = "..."
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.12)
    end)

    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode; lbl.Text = current.Name
                listening = false
                U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.12)
            end
            return
        end
        if not gpe and input.KeyCode == current then pcall(cb) end
    end)

    local el = {
        Instance = frame,
        Set = function(k) current = k; lbl.Text = k.Name end,
        Get = function() return current end,
        Destroy = function() conn:Disconnect() end,
    }
    if flag then NovaUI.Flags[flag] = el end
    return el
end

--==============================================================
-- DROPDOWN
--==============================================================
function NovaUI:AddDropdown(tab, opts)
    opts = opts or {}
    local name = opts.Name or "Dropdown"
    local items = opts.Items or {}
    local default = opts.Default
    local cb = opts.Callback or function() end
    local flag = opts.Flag

    local frame = CreateBase(tab, 34)
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

    local sel = U.Create("TextLabel", {
        Parent = dbtn, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Config.Font,
        Text = default or "Select",
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    U.Create("ImageLabel", {
        Parent = dbtn, BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        Image = Icon("Chevron"),
        ImageColor3 = Config.Theme.Dim,
    })

    local list = U.Create("Frame", {
        Parent = self.ScreenGui,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 0, 0),
        Visible = false, ZIndex = 60,
    })
    U.Corner(list, 5)
    U.Stroke(list, Config.Theme.Line, 1)

    local scroll = U.Create("ScrollingFrame", {
        Parent = list, BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 4),
        Size = UDim2.new(1, -8, 1, -8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Line,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })

    local current, open = default, false

    local function updatePos()
        list.Position = UDim2.new(0, dbtn.AbsolutePosition.X, 0, dbtn.AbsolutePosition.Y + 22)
        list.Size = UDim2.new(0, dbtn.AbsoluteSize.X, 0, math.min(#items * 20 + 8, 120))
    end

    local function rebuild()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, item in ipairs(items) do
            local ib = U.Create("TextButton", {
                Parent = scroll,
                BackgroundColor3 = Config.Theme.Panel,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 18),
                Text = "", AutoButtonColor = false,
            })
            U.Corner(ib, 3)
            U.Create("TextLabel", {
                Parent = ib, BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -12, 1, 0),
                Font = Config.Font,
                Text = tostring(item),
                TextColor3 = Config.Theme.Text, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            ib.MouseEnter:Connect(function() U.Tween(ib, { BackgroundColor3 = Config.Theme.Card }, 0.1) end)
            ib.MouseLeave:Connect(function() U.Tween(ib, { BackgroundColor3 = Config.Theme.Panel }, 0.1) end)
            ib.MouseButton1Click:Connect(function()
                current = item; sel.Text = tostring(item)
                list.Visible = false; open = false
                pcall(cb, item)
            end)
        end
    end
    rebuild()

    dbtn.MouseButton1Click:Connect(function()
        open = not open
        if open then updatePos(); list.Visible = true else list.Visible = false end
    end)
    dbtn.MouseEnter:Connect(function() U.Tween(dbtn, { BackgroundColor3 = Config.Theme.Accent }, 0.12) end)
    dbtn.MouseLeave:Connect(function()
        if not open then U.Tween(dbtn, { BackgroundColor3 = Config.Theme.Hover }, 0.12) end
    end)

    local el = {
        Instance = frame,
        Set = function(v) current = v; sel.Text = tostring(v) end,
        Get = function() return current end,
        Refresh = function(newItems) items = newItems; rebuild() end,
    }
    if flag then NovaUI.Flags[flag] = el end
    return el
end

--==============================================================
-- LABEL / DIVIDER / PARAGRAPH
--==============================================================
function NovaUI:AddLabel(tab, text)
    local f = U.Create("Frame", {
        Parent = tab.Container, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
    })
    local l = U.Create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        Font = Config.FontMedium,
        Text = text, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return { Instance = f, Set = function(v) l.Text = v end, Get = function() return l.Text end }
end

function NovaUI:AddDivider(tab)
    local d = U.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Config.Theme.Line,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
    })
    return { Instance = d }
end

function NovaUI:AddParagraph(tab, opts)
    opts = opts or {}
    local f = U.Create("Frame", {
        Parent = tab.Container,
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
-- SEARCH
--==============================================================
function NovaUI:AddSearchBar(tab, opts)
    opts = opts or {}
    local f = U.Create("Frame", {
        Parent = tab.Container,
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
-- FLAGS
--==============================================================
function NovaUI:GetFlag(n) return NovaUI.Flags[n] end
function NovaUI:GetFlags() return NovaUI.Flags end

print("[NovaUI v3.0] Loaded")
return NovaUI
