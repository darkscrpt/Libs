--[[
    NovaUI v5.0 — Part 1/3
    Compact rewrite. No transparency artifacts. Pill minimize.
]]

--==============================================================
-- SERVICES
--==============================================================
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

--==============================================================
-- CONFIG
--==============================================================
local Config = {
    Theme = {
        Bg      = Color3.fromRGB(15, 15, 18),
        Panel   = Color3.fromRGB(22, 22, 27),
        Card    = Color3.fromRGB(30, 30, 36),
        Hover   = Color3.fromRGB(38, 38, 46),
        Line    = Color3.fromRGB(48, 48, 58),
        Text    = Color3.fromRGB(235, 235, 240),
        Dim     = Color3.fromRGB(120, 120, 138),
        Accent  = Color3.fromRGB(140, 100, 255),
        Green   = Color3.fromRGB(80, 220, 120),
        Red     = Color3.fromRGB(255, 85, 85),
        Yellow  = Color3.fromRGB(255, 190, 80),
    },
    Font       = Enum.Font.Gotham,
    FontMedium = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold,
    Speed      = 0.16,
    Radius     = 6,
    ElemHeight = 24,
    Spacing    = 3,
    Size       = Vector2.new(380, 280),   -- SMALLER
    MinSize    = Vector2.new(320, 220),
    HeaderH    = 28,
    SidebarW   = 96,
    Loading = {
        Enabled      = true,
        Duration     = 1.4,
        LineColor    = Color3.fromRGB(80, 220, 120),
        Rainbow      = false,
        BoxSize      = Vector2.new(180, 68),
        Title        = "NovaUI",
        Subtitle     = "loading modules...",
        LineThickness= 2,
        FadeOutTime  = 0.3,
    },
}

--==============================================================
-- ICONS
--==============================================================
local Icons = {
    Home     = "rbxassetid://10723407383",
    Settings = "rbxassetid://10734898355",
    Info     = "rbxassetid://10734904191",
    List     = "rbxassetid://10734911770",
    Palette  = "rbxassetid://10734922069",
    Wrench   = "rbxassetid://10734936564",
    User     = "rbxassetid://10734948940",
    Close    = "rbxassetid://10734897593",
    Minus    = "rbxassetid://10734897593",
    Check    = "rbxassetid://10734897983",
    Plus     = "rbxassetid://10734905351",
    Search   = "rbxassetid://10734940165",
    Refresh  = "rbxassetid://10734935063",
    Copy     = "rbxassetid://10734898475",
    Save     = "rbxassetid://10734934677",
    Trash    = "rbxassetid://10734948940",
    Download = "rbxassetid://10734934677",
    Upload   = "rbxassetid://10734935063",
    Warning  = "rbxassetid://10734936967",
    Bell     = "rbxassetid://10734895955",
    Star     = "rbxassetid://10734945940",
    ChevronD = "rbxassetid://10734895495",
    Play     = "rbxassetid://10734934538",
    Pause    = "rbxassetid://10734922069",
    Zap      = "rbxassetid://10734922069",
    Eye      = "rbxassetid://10734903172",
    Target   = "rbxassetid://10734911770",
    Box      = "rbxassetid://10734911770",
    Boxes    = "rbxassetid://10734911770",
    Layers   = "rbxassetid://10734911770",
    Code     = "rbxassetid://10734898475",
    Globe    = "rbxassetid://10734922069",
    Gift     = "rbxassetid://10734905351",
    Lock     = "rbxassetid://10734948940",
    Shield   = "rbxassetid://10734948940",
}
local function Icon(n) return Icons[n] or Icons.Info end

--==============================================================
-- UTIL
--==============================================================
local U = {}
function U.Create(c, p)
    local i = Instance.new(c)
    for k, v in pairs(p or {}) do if k ~= "Parent" then i[k] = v end end
    if p and p.Parent then i.Parent = p.Parent end
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
function U.HSV(h) return Color3.fromHSV(h % 1, 0.75, 1) end

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
-- DRAG / RESIZE
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
-- LOADING SCREEN
--==============================================================
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

    local sizeX, sizeY = opts.BoxSize.X, opts.BoxSize.Y
    local box = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(12, 12, 14),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, sizeX, 0, sizeY),
    })

    U.Create("TextLabel", {
        Parent = box, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -13),
        Size = UDim2.new(1, 0, 0, 18),
        Font = Config.FontBold, Text = opts.Title,
        TextColor3 = Color3.fromRGB(235, 235, 240), TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    U.Create("TextLabel", {
        Parent = box, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 6),
        Size = UDim2.new(1, 0, 0, 12),
        Font = Config.Font, Text = opts.Subtitle,
        TextColor3 = Color3.fromRGB(120, 120, 135), TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local c = opts.LineColor
    local th = opts.LineThickness
    local top = U.Create("Frame", { Parent=screen, BackgroundColor3=c, BorderSizePixel=0,
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,-sizeY/2), Size=UDim2.new(0,0,0,th) })
    local right = U.Create("Frame", { Parent=screen, BackgroundColor3=c, BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(0.5,sizeX/2,0.5,0), Size=UDim2.new(0,th,0,0) })
    local bottom = U.Create("Frame", { Parent=screen, BackgroundColor3=c, BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(0.5,sizeX/2,0.5,sizeY/2), Size=UDim2.new(0,0,0,th) })
    local left = U.Create("Frame", { Parent=screen, BackgroundColor3=c, BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0.5,-sizeX/2,0.5,sizeY/2), Size=UDim2.new(0,th,0,0) })

    local rainbowThread
    if opts.Rainbow then
        local hue = 0
        rainbowThread = task.spawn(function()
            while screen.Parent do
                hue = hue + 0.015
                local col = U.HSV(hue)
                top.BackgroundColor3 = col
                right.BackgroundColor3 = col
                bottom.BackgroundColor3 = col
                left.BackgroundColor3 = col
                RunService.Heartbeat:Wait()
            end
        end)
    end

    local per = opts.Duration / 4
    local ease = Enum.EasingStyle.Quad
    U.Tween(top,    { Size = UDim2.new(0, sizeX, 0, th) }, per, ease); task.wait(per)
    U.Tween(right,  { Size = UDim2.new(0, th, 0, sizeY) }, per, ease); task.wait(per)
    U.Tween(bottom, { Size = UDim2.new(0, sizeX, 0, th) }, per, ease); task.wait(per)
    U.Tween(left,   { Size = UDim2.new(0, th, 0, sizeY) }, per, ease); task.wait(per)
    task.wait(0.05)

    local fade = opts.FadeOutTime
    for _, s in ipairs({ top, right, bottom, left }) do
        U.Tween(s, { BackgroundTransparency = 1 }, fade, Enum.EasingStyle.Sine)
    end
    U.Tween(box, { BackgroundTransparency = 1 }, fade, Enum.EasingStyle.Sine)
    for _, ch in ipairs(box:GetChildren()) do
        if ch:IsA("TextLabel") then U.Tween(ch, { TextTransparency = 1 }, fade) end
    end
    task.wait(fade + 0.02)
    if rainbowThread then task.cancel(rainbowThread) end
    screen:Destroy()
end

NovaUI.PlayLoadingScreen = PlayLoadingScreen

--==============================================================
-- NOTIFICATION
--==============================================================
local function Notify(title, content, accent, duration)
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
        Name = "Notif", Parent = screen, BackgroundTransparency = 1,
        Size = UDim2.new(0, 240, 0, 0),
        Position = UDim2.new(1, -256, 1, -16),
        AnchorPoint = Vector2.new(0, 1),
    })

    for _, c in ipairs(screen:GetChildren()) do
        if c:IsA("Frame") and c ~= holder and c.Name == "Notif" then
            U.Tween(c, { Position = UDim2.new(1, -256, 1, c.Position.Y.Offset - 52) }, 0.2)
        end
    end

    local main = U.Create("Frame", {
        Parent = holder, BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 46),
        ClipsDescendants = true,
    })
    U.Corner(main, 5)
    U.Stroke(main, Config.Theme.Line, 1)

    U.Create("Frame", {
        Parent = main, BackgroundColor3 = accent,
        BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0),
    })

    U.Create("TextLabel", {
        Parent = main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -20, 0, 13),
        Font = Config.FontBold, Text = title,
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    U.Create("TextLabel", {
        Parent = main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 22),
        Size = UDim2.new(1, -20, 0, 18),
        Font = Config.Font, Text = content,
        TextColor3 = Config.Theme.Dim, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    local pb = U.Create("Frame", {
        Parent = main, BackgroundColor3 = Config.Theme.Line,
        BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
    })
    local p = U.Create("Frame", {
        Parent = pb, BackgroundColor3 = accent,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0),
    })
    U.Tween(p, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

    main.Position = UDim2.new(0, 12, 0, 0)
    U.Tween(main, { Position = UDim2.new(0, 0, 0, 0) }, 0.22)

    task.delay(duration, function()
        U.Tween(main, { BackgroundTransparency = 1 }, 0.25)
        for _, c in ipairs(main:GetChildren()) do
            if c:IsA("TextLabel") then U.Tween(c, { TextTransparency = 1 }, 0.2) end
            if c:IsA("UIStroke") then U.Tween(c, { Transparency = 1 }, 0.25) end
        end
        U.Tween(holder, { Position = UDim2.new(1, -256, 1, holder.Position.Y.Offset - 52) }, 0.25)
        task.wait(0.28); holder:Destroy()
    end)
end

NovaUI.Notify = Notify

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
    self.Minimized = false
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
        Parent = Lighting, Size = 0,
        Name = "NovaUI_Blur_" .. HttpService:GenerateGUID(false),
    })
    self.Blur = blur

    -- ============ MAIN ============
    -- NOTE: no ClipsDescendants, no stroke transparency artifacts
    local main = U.Create("Frame", {
        Parent = screen,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        Position = UDim2.new(0.5, -windowSize.X/2, 0.5, -windowSize.Y/2),
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
        Size = UDim2.new(1, 0, 0, Config.HeaderH),
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

    -- Accent dot
    U.Create("Frame", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -3),
        Size = UDim2.new(0, 6, 0, 6),
    }) -- no corner = square dot; small & clean

    U.Create("TextLabel", {
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Config.FontBold,
        Text = windowName,
        TextColor3 = Config.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Only MINIMIZE button on header (close moved to Settings)
    local minBtn = U.Create("TextButton", {
        Parent = header,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -24, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(minBtn, 4)
    U.Create("Frame", {
        Parent = minBtn,
        BackgroundColor3 = Config.Theme.Dim,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -3.5, 0.5, -0.5),
        Size = UDim2.new(0, 7, 0, 1),
    })
    minBtn.MouseEnter:Connect(function() U.Tween(minBtn, { BackgroundColor3 = Config.Theme.Accent }, 0.12) end)
    minBtn.MouseLeave:Connect(function() U.Tween(minBtn, { BackgroundColor3 = Config.Theme.Card }, 0.12) end)
    minBtn.MouseButton1Click:Connect(function() self:Minimize() end)

    -- ============ SIDEBAR ============
    local sidebar = U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, Config.HeaderH),
        Size = UDim2.new(0, Config.SidebarW, 1, -Config.HeaderH),
    })
    self.Sidebar = sidebar

    local sbScroll = U.Create("ScrollingFrame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 1, -10),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Line,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    self.SidebarScroll = sbScroll
    U.Create("UIListLayout", { Parent = sbScroll, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })

    -- ============ CONTENT ============
    local content = U.Create("Frame", {
        Parent = main,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, Config.SidebarW, 0, Config.HeaderH),
        Size = UDim2.new(1, -Config.SidebarW, 1, -Config.HeaderH),
    })
    self.Content = content

    MakeDraggable(main, header)

    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            main.Visible = not main.Visible
            if blur then U.Tween(blur, { Size = main.Visible and 8 or 0 }, 0.25) end
        end
    end))

    -- Open anim (no transparency flicker)
    main.Size = UDim2.new(0, windowSize.X * 0.94, 0, windowSize.Y * 0.94)
    main.Position = UDim2.new(0.5, -(windowSize.X * 0.94)/2, 0.5, -(windowSize.Y * 0.94)/2)
    U.Tween(main, {
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        Position = UDim2.new(0.5, -windowSize.X/2, 0.5, -windowSize.Y/2),
    }, 0.3)
    U.Tween(blur, { Size = 8 }, 0.3)

    table.insert(NovaUI.Windows, self)
    return self
end

--==============================================================
-- MINIMIZE → PILL AT TOP OF SCREEN
--==============================================================
function NovaUI:Minimize()
    if self.Minimized then return end
    self.Minimized = true

    -- Hide main (kept alive)
    U.Tween(self.Main, { BackgroundTransparency = 1 }, 0.15)

    -- Build pill if not already
    if not self._pill then
        local pill = U.Create("TextButton", {
            Parent = self.ScreenGui,
            BackgroundColor3 = Config.Theme.Panel,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 8),
            Size = UDim2.new(0, 100, 0, 22),
            Text = "", AutoButtonColor = false,
            ZIndex = 10,
        })
        U.Corner(pill, 11)   -- super rounded pill
        U.Stroke(pill, Config.Theme.Line, 1)
        self._pill = pill

        U.Create("Frame", {
            Parent = pill,
            BackgroundColor3 = Config.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0.5, -3),
            Size = UDim2.new(0, 6, 0, 6),
        })
        U.Create("TextLabel", {
            Parent = pill,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 22, 0, 0),
            Size = UDim2.new(1, -32, 1, 0),
            Font = Config.FontBold,
            Text = self.Name,
            TextColor3 = Config.Theme.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        pill.MouseButton1Click:Connect(function() self:Restore() end)
        pill.MouseEnter:Connect(function() U.Tween(pill, { BackgroundColor3 = Config.Theme.Card }, 0.12) end)
        pill.MouseLeave:Connect(function() U.Tween(pill, { BackgroundColor3 = Config.Theme.Panel }, 0.12) end)
    end

    self._pill.Visible = true
    self._pill.Size = UDim2.new(0, 100, 0, 22)
    self.Main.Visible = false
end

function NovaUI:Restore()
    if not self.Minimized then return end
    self.Minimized = false
    if self._pill then self._pill.Visible = false end
    self.Main.Visible = true
    U.Tween(self.Main, { BackgroundTransparency = 0 }, 0.18)
end

--==============================================================
-- ON UNLOAD + DESTROY
--==============================================================
function NovaUI:OnUnload(fn) table.insert(self.UnloadCallbacks, fn) end

function NovaUI:Destroy()
    for _, fn in ipairs(self.UnloadCallbacks) do pcall(fn) end
    for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    if self.Blur then
        U.Tween(self.Blur, { Size = 0 }, 0.25)
        task.delay(0.28, function() if self.Blur then self.Blur:Destroy() end end)
    end
    if self._pill then self._pill:Destroy() end
    if self.ScreenGui then self.ScreenGui:Destroy() end
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
        Parent = self.SidebarScroll,
        BackgroundColor3 = Config.Theme.Bg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 24),
        Text = "", AutoButtonColor = false,
    })
    tab.Button = btn
    U.Corner(btn, 5)

    local icon = U.Create("ImageLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 7, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        Image = Icon(tabIcon),
        ImageColor3 = Config.Theme.Dim,
    })
    tab.Icon = icon

    local lbl = U.Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Config.FontMedium,
        Text = tabName,
        TextColor3 = Config.Theme.Dim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    tab.Label = lbl

    local container = U.Create("ScrollingFrame", {
        Parent = self.Content,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Line,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    tab.Container = container
    U.Create("UIListLayout", { Parent = container, Padding = UDim.new(0, Config.Spacing), SortOrder = Enum.SortOrder.LayoutOrder })

    btn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then U.Tween(btn, { BackgroundColor3 = Config.Theme.Card }, 0.1) end
    end)
    btn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then U.Tween(btn, { BackgroundColor3 = Config.Theme.Bg }, 0.1) end
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
        U.Tween(t.Button, { BackgroundColor3 = on and Config.Theme.Card or Config.Theme.Bg }, 0.12)
        U.Tween(t.Label, { TextColor3 = on and Config.Theme.Text or Config.Theme.Dim }, 0.12)
        U.Tween(t.Icon,  { ImageColor3 = on and Config.Theme.Accent or Config.Theme.Dim }, 0.12)
    end
    self.ActiveTab = tab
end

--==============================================================
-- GROUPBOX — no transparent edges
--==============================================================
function NovaUI:AddGroupbox(tab, options)
    options = options or {}
    local name = options.Name or "Group"
    local side = options.Side or "Left"
    local iconName = options.Icon or "Boxes"

    -- Side columns, no gaps that cause stroke overlap
    if not tab._leftCol then
        tab._leftCol = U.Create("Frame", {
            Parent = tab.Container, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -2, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        tab._rightCol = U.Create("Frame", {
            Parent = tab.Container, BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 2, 0, 0),
            Size = UDim2.new(0.5, -2, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        U.Create("UIListLayout", { Parent = tab._leftCol,  Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
        U.Create("UIListLayout", { Parent = tab._rightCol, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
    end

    local parentCol = (side:lower() == "right") and tab._rightCol or tab._leftCol

    local group = { Name = name, Elements = {}, _window = self }

    local outer = U.Create("Frame", {
        Parent = parentCol,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,   -- fixes transparent edge bleed
    })
    U.Corner(outer, 6)
    U.Stroke(outer, Config.Theme.Line, 1)
    group.Frame = outer

    -- Header
    local head = U.Create("Frame", {
        Parent = outer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
    })
    U.Create("ImageLabel", {
        Parent = head,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 9, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        Image = Icon(iconName),
        ImageColor3 = Config.Theme.Accent,
    })
    U.Create("TextLabel", {
        Parent = head,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
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
        Position = UDim2.new(0, 6, 0, 24),
        Size = UDim2.new(1, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", {
        Parent = body,
        Padding = UDim.new(0, Config.Spacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    U.Create("UIPadding", { Parent = body, PaddingBottom = UDim.new(0, 6) })
    group.Container = body

    table.insert(tab.Groups, group)
    return group
end

--==============================================================
-- PART 1 END — handoff to Part 2
--==============================================================
NovaUI._Config           = Config
NovaUI._U                = U
NovaUI._IconFn           = Icon
NovaUI._Icons            = Icons
NovaUI._Players          = Players
NovaUI._LocalPlayer      = LocalPlayer
NovaUI._Mouse            = Mouse
NovaUI._CoreGui          = CoreGui
NovaUI._UserInputService = UserInputService
NovaUI._TweenService     = TweenService
NovaUI._HttpService      = HttpService
NovaUI._Lighting         = Lighting
NovaUI._MakeDraggable    = MakeDraggable

_NovaUIPartial = NovaUI

--==============================================================
-- PART 2/3 — ELEMENTS
--==============================================================
local NovaUI = _NovaUIPartial

-- Re-import Part 1 locals
local Config           = NovaUI._Config
local U                = NovaUI._U
local Icon             = NovaUI._IconFn
local Icons            = NovaUI._Icons
local Players          = NovaUI._Players
local LocalPlayer      = NovaUI._LocalPlayer
local Mouse            = NovaUI._Mouse
local CoreGui          = NovaUI._CoreGui
local UserInputService = NovaUI._UserInputService
local TweenService     = NovaUI._TweenService
local HttpService      = NovaUI._HttpService

--==============================================================
-- ELEMENT BASE
--==============================================================
local function CreateBase(parent, height)
    local f = U.Create("Frame", {
        Parent = parent.Container,
        BackgroundColor3 = Config.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or Config.ElemHeight),
        ClipsDescendants = true,
    })
    U.Corner(f, 5)
    return f
end

--==============================================================
-- SECTION
--==============================================================
function NovaUI:AddSection(parent, name)
    local frame = U.Create("Frame", {
        Parent = parent.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
    })
    U.Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        Font = Config.FontBold,
        Text = name,
        TextColor3 = Config.Theme.Dim,
        TextSize = 10,
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
        Position = UDim2.new(0, 8, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        Image = Icon(icon),
        ImageColor3 = Config.Theme.Dim,
    })

    U.Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
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
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.1)
        U.Tween(iconImg, { ImageColor3 = Config.Theme.Accent }, 0.1)
    end)
    btn.MouseLeave:Connect(function()
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Card }, 0.1)
        U.Tween(iconImg, { ImageColor3 = Config.Theme.Dim }, 0.1)
    end)
    btn.MouseButton1Click:Connect(function()
        if doubleClick then
            local now = tick()
            if now - lastClick > 0.4 then lastClick = now; return end
            lastClick = 0
        end
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.06)
        task.delay(0.06, function() U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.1) end)
        pcall(cb)
    end)

    return { Instance = btn }
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

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
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
        Position = UDim2.new(1, -34, 0.5, -6),
        Size = UDim2.new(0, 26, 0, 12),
    })
    U.Corner(track, 6)

    local knob = U.Create("Frame", {
        Parent = track,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -11, 0.5, -5) or UDim2.new(0, 1, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
    })
    U.Corner(knob, 5)

    local state = default
    local callbacks = {}

    local function set(v, fire)
        state = v; element.Value = v
        if state then
            U.Tween(track, { BackgroundColor3 = Config.Theme.Accent }, 0.16)
            U.Tween(knob, { Position = UDim2.new(1, -11, 0.5, -5) }, 0.16)
        else
            U.Tween(track, { BackgroundColor3 = Config.Theme.Hover }, 0.16)
            U.Tween(knob, { Position = UDim2.new(0, 1, 0.5, -5) }, 0.16)
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
        Set      = function(v) set(v, false) end,
        Get      = function() return state end,
        Toggle   = function() set(not state, true) end,
        SetValue = function(_, v) set(v, false) end,
        OnChanged= function(_, fn) table.insert(callbacks, fn) end,
    }
    if flag then NovaUI.Flags[flag] = element end
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
        Position = UDim2.new(0, 8, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
    })
    U.Corner(box, 3)

    local check = U.Create("ImageLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(0, 10, 0, 10),
        Image = Icon("Check"),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = default and 0 or 1,
    })

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(1, -34, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local state = default
    local callbacks = {}
    local function set(v, fire)
        state = v; element.Value = v
        U.Tween(box, { BackgroundColor3 = state and Config.Theme.Accent or Config.Theme.Hover }, 0.16)
        U.Tween(check, { ImageTransparency = state and 0 or 1 }, 0.16)
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
        Set = function(v) set(v, false) end,
        Get = function() return state end,
        SetValue = function(_, v) set(v, false) end,
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

    local frame = CreateBase(parent, compact and 20 or 34)

    if not compact then
        U.Create("TextLabel", {
            Parent = frame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 5),
            Size = UDim2.new(0.7, 0, 0, 12),
            Font = Config.FontMedium,
            Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    end

    local valLbl = U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = compact and UDim2.new(0, 8, 0, 4) or UDim2.new(0.7, 0, 0, 5),
        Size = compact and UDim2.new(0.4, -8, 0, 12) or UDim2.new(0.3, -8, 0, 12),
        Font = Config.FontMedium,
        Text = tostring(default) .. suffix,
        TextColor3 = Config.Theme.Accent, TextSize = 11,
        TextXAlignment = compact and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,
    })

    local barBg = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = compact and UDim2.new(0.4, 0, 0.5, -2) or UDim2.new(0, 8, 1, -14),
        Size = compact and UDim2.new(0.6, -8, 0, 4) or UDim2.new(1, -16, 0, 4),
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
        Size = UDim2.new(0, 9, 0, 9),
    })
    U.Corner(knob, 4)

    local value = default
    local dragging = false
    local callbacks = {}

    local function update(input)
        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local nv = U.Round(min + (max - min) * rel, rounding)
        if nv ~= value then
            value = nv; element.Value = nv
            valLbl.Text = tostring(value) .. suffix
            U.Tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.03)
            U.Tween(knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.03)
            pcall(cb, value)
            for _, fn in ipairs(callbacks) do pcall(fn, value) end
        end
    end

    local hit = U.Create("TextButton", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -22),
        Size = UDim2.new(1, 0, 0, 20), Text = "",
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
        Value = default, Min = min, Max = max,
        Set = function(v)
            v = math.clamp(v, min, max); value = v; element.Value = v
            local p = (v - min) / (max - min)
            valLbl.Text = tostring(v) .. suffix
            U.Tween(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.1)
            U.Tween(knob, { Position = UDim2.new(p, 0, 0.5, 0) }, 0.1)
        end,
        Get = function() return value end,
        SetValue = function(_, v) element.Set(v) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- TEXTBOX
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

    local frame = CreateBase(parent, Config.ElemHeight)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local boxBg = U.Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0.44, 0, 0.5, -8),
        Size = UDim2.new(0.56, -8, 0, 16),
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
    box.Focused:Connect(function() U.Tween(stroke, { Color = Config.Theme.Accent }, 0.1) end)
    box.FocusLost:Connect(function(enter)
        U.Tween(stroke, { Color = Config.Theme.Line }, 0.1)
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
-- KEYBIND
--==============================================================
function NovaUI:AddKeybind(parent, opts)
    opts = opts or {}
    local name = opts.Name or opts.Text or "Keybind"
    local default = opts.Default or "E"
    local cb = opts.Callback or function() end
    local changedCb = opts.ChangedCallback
    local flag = opts.Flag or opts.Index
    local mode = opts.Mode or "Toggle"

    local frame = CreateBase(parent, Config.ElemHeight)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local btn = U.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -64, 0.5, -8),
        Size = UDim2.new(0, 56, 0, 16),
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
    local listening = false
    local state = false
    local callbacks = {}

    local function setState(v, fire)
        state = v; element.State = v
        if fire then
            pcall(cb, v)
            for _, fn in ipairs(callbacks) do pcall(fn, v) end
        end
    end

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true; lbl.Text = "..."
        U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.1)
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode.Name
                lbl.Text = current
                listening = false
                U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.1)
                if changedCb then pcall(changedCb, current) end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2 then
                current = (input.UserInputType == Enum.UserInputType.MouseButton1) and "MB1" or "MB2"
                lbl.Text = current
                listening = false
                U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.1)
                if changedCb then pcall(changedCb, current) end
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
            if input.UserInputType == Enum.UserInputType.Keyboard then keyName = input.KeyCode.Name end
            if keyName == current then setState(false, true) end
        end
    end)

    local element = {
        Instance = frame,
        Value = current,
        State = false,
        SetValue = function(_, val)
            if type(val) == "table" then
                current = val[1] or current; mode = val[2] or mode
            else current = val end
            lbl.Text = tostring(current)
        end,
        GetState = function() return state end,
        OnClick  = function(_, fn) table.insert(callbacks, fn) end,
        OnChanged= function(_, fn) table.insert(callbacks, fn) end,
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

    local frame = CreateBase(parent, 30)
    frame.ClipsDescendants = false

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -6),
        Size = UDim2.new(0.4, 0, 0, 12),
        Font = Config.FontMedium,
        Text = name, TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local dbtn = U.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0.44, 0, 0.5, -8),
        Size = UDim2.new(0.56, -8, 0, 16),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(dbtn, 4)

    local selLbl = U.Create("TextLabel", {
        Parent = dbtn, BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Config.Font,
        Text = default and tostring(default) or "Select",
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    U.Create("ImageLabel", {
        Parent = dbtn, BackgroundTransparency = 1,
        Position = UDim2.new(1, -14, 0.5, -4),
        Size = UDim2.new(0, 8, 0, 8),
        Image = Icon("ChevronD"),
        ImageColor3 = Config.Theme.Dim,
    })

    -- List frame — attach to ScreenGui
    local list = U.Create("Frame", {
        Parent = parent._window.ScreenGui,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 150, 0, 0),
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
            Size = UDim2.new(1, -8, 0, 16),
            Font = Config.Font, Text = "",
            PlaceholderText = "Search...",
            PlaceholderColor3 = Config.Theme.Dim,
            TextColor3 = Config.Theme.Text, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
        })
        U.Corner(searchBox, 3)
        U.Create("UIPadding", { Parent = searchBox, PaddingLeft = UDim.new(0, 6) })
    end

    local scroll = U.Create("ScrollingFrame", {
        Parent = list, BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, searchable and 24 or 4),
        Size = searchable and UDim2.new(1, -8, 1, -28) or UDim2.new(1, -8, 1, -8),
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

    local function isDict()
        return type(values) == "table" and next(values) and type(next(values)) == "string"
    end

    local function getDisplay(key)
        if isDict() then return values[key] or key end
        return key
    end

    local function updateSel()
        if multi then
            local count = 0
            for _ in pairs(multiState) do count = count + 1 end
            if count == 0 then selLbl.Text = "None"
            elseif count == 1 then for k in pairs(multiState) do selLbl.Text = getDisplay(k); break end
            else selLbl.Text = count .. " selected" end
        else
            selLbl.Text = current and tostring(getDisplay(current)) or "Select"
        end
    end

    local function updatePos()
        list.Position = UDim2.new(0, dbtn.AbsolutePosition.X, 0, dbtn.AbsolutePosition.Y + 20)
        local vis = math.min(#itemButtons, maxVisible)
        list.Size = UDim2.new(0, math.max(130, dbtn.AbsoluteSize.X), 0, vis * 20 + (searchable and 28 or 10))
    end

    local function rebuild(filter)
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        itemButtons = {}

        local items = {}
        if isDict() then
            for k, v in pairs(values) do table.insert(items, { key = k, label = v }) end
        else
            for _, v in ipairs(values) do table.insert(items, { key = v, label = v }) end
        end

        for _, item in ipairs(items) do
            local label = tostring(item.label)
            if filter and filter ~= "" then
                if not label:lower():find(filter:lower(), 1, true) then continue end
            end
            local isSel = multi and multiState[item.key] == true or (not multi and current == item.key)

            local ib = U.Create("TextButton", {
                Parent = scroll,
                BackgroundColor3 = isSel and Config.Theme.Accent or Config.Theme.Panel,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 18),
                Text = "", AutoButtonColor = false,
            })
            U.Corner(ib, 3)

            U.Create("TextLabel", {
                Parent = ib, BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 0),
                Size = UDim2.new(1, -12, 1, 0),
                Font = Config.Font, Text = label,
                TextColor3 = isSel and Color3.new(1,1,1) or Config.Theme.Text,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            ib.MouseEnter:Connect(function()
                if not isSel then U.Tween(ib, { BackgroundColor3 = Config.Theme.Card }, 0.1) end
            end)
            ib.MouseLeave:Connect(function()
                if not isSel then U.Tween(ib, { BackgroundColor3 = Config.Theme.Panel }, 0.1) end
            end)
            ib.MouseButton1Click:Connect(function()
                if multi then
                    multiState[item.key] = not multiState[item.key]
                    if multiState[item.key] == false then multiState[item.key] = nil end
                    updateSel()
                    pcall(cb, multiState)
                    for _, fn in ipairs(callbacks) do pcall(fn, multiState) end
                    rebuild(searchBox and searchBox.Text or "")
                else
                    current = item.key
                    updateSel()
                    pcall(cb, item.key)
                    for _, fn in ipairs(callbacks) do pcall(fn, item.key) end
                    list.Visible = false; open = false
                end
            end)

            table.insert(itemButtons, ib)
        end
    end

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuild(searchBox.Text) end)
    end
    rebuild(); updateSel()

    dbtn.MouseButton1Click:Connect(function()
        open = not open
        if open then updatePos(); list.Visible = true else list.Visible = false end
    end)
    dbtn.MouseEnter:Connect(function() U.Tween(dbtn, { BackgroundColor3 = Config.Theme.Accent }, 0.1) end)
    dbtn.MouseLeave:Connect(function()
        if not open then U.Tween(dbtn, { BackgroundColor3 = Config.Theme.Hover }, 0.1) end
    end)

    local element = {
        Instance = frame,
        Value = current, Values = values,
        Set = function(v)
            if multi and type(v) == "table" then
                multiState = {}
                for k, on in pairs(v) do if on then multiState[k] = true end end
                element.Value = multiState
            else
                current = v; element.Value = v
            end
            updateSel(); rebuild(searchBox and searchBox.Text or "")
        end,
        Get = function() return element.Value end,
        SetValue = function(_, v) element.Set(v) end,
        OnChanged = function(_, fn) table.insert(callbacks, fn) end,
        Refresh = function(_, newValues) values = newValues; rebuild(searchBox and searchBox.Text or "") end,
    }
    if flag then NovaUI.Flags[flag] = element end
    return element
end

--==============================================================
-- LABEL / DIVIDER / PARAGRAPH
--==============================================================
function NovaUI:AddLabel(parent, text, wrap, idx)
    if type(text) == "table" then
        local o = text
        text = o.Text or ""; wrap = o.DoesWrap or false; idx = o.Idx or o.Index
    end
    local f = U.Create("Frame", {
        Parent = parent.Container, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, wrap and 26 or 16),
        AutomaticSize = wrap and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
    })
    local lbl = U.Create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        Font = Config.FontMedium, Text = text,
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = wrap or false,
    })
    local element = {
        Instance = f,
        Set = function(v) lbl.Text = v end,
        Get = function() return lbl.Text end,
        SetText = function(_, v) lbl.Text = v end,
        AddColorPicker = function(_, pickerIdx, o)
            return NovaUI:AddColorPicker(parent, o or { Flag = pickerIdx })
        end,
        AddKeyPicker = function(_, pickerIdx, o)
            return NovaUI:AddKeybind(parent, o or { Flag = pickerIdx })
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
        Size = UDim2.new(1, 0, 0, 42),
    })
    U.Corner(f, 5)
    U.Create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 7),
        Size = UDim2.new(1, -16, 0, 12),
        Font = Config.FontBold, Text = opts.Title or "",
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local c = U.Create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 20),
        Size = UDim2.new(1, -16, 0, 18),
        Font = Config.Font, Text = opts.Content or "",
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
        Size = UDim2.new(1, 0, 0, 24),
    })
    U.Corner(f, 5)
    U.Stroke(f, Config.Theme.Line, 1)

    U.Create("ImageLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 7, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        Image = Icon("Search"),
        ImageColor3 = Config.Theme.Dim,
    })

    local box = U.Create("TextBox", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Config.Font, Text = "",
        PlaceholderText = opts.Placeholder or "Search...",
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

    local frame = CreateBase(parent, Config.ElemHeight)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Config.FontMedium, Text = name,
        TextColor3 = Config.Theme.Text, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local colorBtn = U.Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -54, 0.5, -8),
        Size = UDim2.new(0, 46, 0, 16),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(colorBtn, 4)

    local currentColor = default
    local callbacks = {}

    colorBtn.MouseButton1Click:Connect(function()
        local pg = U.Create("ScreenGui", { Parent = CoreGui, ResetOnSpawn = false })
        local bg = U.Create("Frame", {
            Parent = pg,
            BackgroundColor3 = Config.Theme.Bg,
            Size = UDim2.new(0, 200, 0, 160),
            Position = UDim2.new(0, Mouse.X, 0, Mouse.Y),
        })
        U.Corner(bg, 7)
        U.Stroke(bg, Config.Theme.Line, 1)

        local preview = U.Create("Frame", {
            Parent = bg, BackgroundColor3 = currentColor,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 26),
        })
        U.Corner(preview, 5)

        local function mkSlider(y, color, label)
            U.Create("TextLabel", {
                Parent = bg, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, y),
                Size = UDim2.new(0, 14, 0, 12),
                Font = Config.FontBold, Text = label,
                TextColor3 = Config.Theme.Text, TextSize = 10,
            })
            local bar = U.Create("Frame", {
                Parent = bg, BackgroundColor3 = Config.Theme.Hover,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 28, 0, y + 4),
                Size = UDim2.new(1, -38, 0, 5),
            })
            U.Corner(bar, 3)

            local val = currentColor[color == "R" and "R" or color == "G" and "G" or "B"]
            local fillCol = color == "R" and Color3.fromRGB(255, 80, 80)
                or color == "G" and Color3.fromRGB(80, 255, 80)
                or Color3.fromRGB(80, 80, 255)

            local fill = U.Create("Frame", {
                Parent = bar, BackgroundColor3 = fillCol,
                BorderSizePixel = 0, Size = UDim2.new(val, 0, 1, 0),
            })
            U.Corner(fill, 3)

            local knob = U.Create("Frame", {
                Parent = bar, BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(val, 0, 0.5, 0),
                Size = UDim2.new(0, 10, 0, 10),
            })
            U.Corner(knob, 5)

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
                Position = UDim2.new(0, 28, 0, y - 4),
                Size = UDim2.new(1, -38, 0, 16), Text = "",
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

        mkSlider(46, "R", "R")
        mkSlider(68, "G", "G")
        mkSlider(90, "B", "B")

        local close = U.Create("TextButton", {
            Parent = bg, BackgroundColor3 = Config.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 1, -34),
            Size = UDim2.new(1, -20, 0, 24),
            Text = "", AutoButtonColor = false,
        })
        U.Corner(close, 5)
        U.Create("TextLabel", {
            Parent = close, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Config.FontBold, Text = "Apply",
            TextColor3 = Color3.new(1, 1, 1), TextSize = 11,
        })
        close.MouseButton1Click:Connect(function() pg:Destroy() end)
        NovaUI._MakeDraggable(bg)
    end)

    local element = {
        Instance = frame,
        Value = currentColor,
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
-- PART 2 END — expose locals for Part 3
--==============================================================
NovaUI._CreateBase = CreateBase

--==============================================================
-- PART 3/3 — ADVANCED: TABBOX, THEME, SAVE, PLAYER/TEAM DROPDOWNS,
--             KEYBOX, WARNING BOX, PUBLIC API, SETTINGS CLOSE BUTTON
--==============================================================
local NovaUI = NovaUI  -- same reference

local Config           = NovaUI._Config
local U                = NovaUI._U
local Icon             = NovaUI._IconFn
local Icons            = NovaUI._Icons
local Players          = NovaUI._Players
local LocalPlayer      = NovaUI._LocalPlayer
local CoreGui          = NovaUI._CoreGui
local UserInputService = NovaUI._UserInputService
local HttpService      = NovaUI._HttpService
local MakeDraggable    = NovaUI._MakeDraggable
local CreateBase       = NovaUI._CreateBase
local TweenService     = NovaUI._TweenService

--==============================================================
-- TABBOX
--==============================================================
function NovaUI:AddTabbox(parent, options)
    options = options or {}
    local tabbox = { Tabs = {}, ActiveTab = nil, _window = parent._window }

    local outer = U.Create("Frame", {
        Parent = parent.Container,
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
    })
    U.Corner(outer, 6)
    U.Stroke(outer, Config.Theme.Line, 1)
    tabbox.Frame = outer

    local strip = U.Create("Frame", {
        Parent = outer, BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 5),
        Size = UDim2.new(1, -12, 0, 20),
    })
    U.Create("UIListLayout", {
        Parent = strip, FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local body = U.Create("Frame", {
        Parent = outer, BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 28),
        Size = UDim2.new(1, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    U.Create("UIListLayout", {
        Parent = body, Padding = UDim.new(0, Config.Spacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    U.Create("UIPadding", { Parent = body, PaddingBottom = UDim.new(0, 6) })

    function tabbox:AddTab(tabName)
        local t = { Name = tabName, Elements = {} }
        local btn = U.Create("TextButton", {
            Parent = strip,
            BackgroundColor3 = Config.Theme.Card,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 60, 1, 0),
            Text = "", AutoButtonColor = false,
        })
        U.Corner(btn, 4)
        t.Button = btn
        U.Create("TextLabel", {
            Parent = btn, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Config.FontMedium, Text = tabName,
            TextColor3 = Config.Theme.Dim, TextSize = 10,
        })
        t.Label = btn:FindFirstChildOfClass("TextLabel")

        local container = U.Create("Frame", {
            Parent = body, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        U.Create("UIListLayout", {
            Parent = container, Padding = UDim.new(0, Config.Spacing),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        t.Container = container

        btn.MouseEnter:Connect(function()
            if tabbox.ActiveTab ~= t then U.Tween(btn, { BackgroundColor3 = Config.Theme.Hover }, 0.1) end
        end)
        btn.MouseLeave:Connect(function()
            if tabbox.ActiveTab ~= t then U.Tween(btn, { BackgroundColor3 = Config.Theme.Card }, 0.1) end
        end)
        btn.MouseButton1Click:Connect(function()
            for _, tt in ipairs(tabbox.Tabs) do
                local on = (tt == t)
                tt.Container.Visible = on
                U.Tween(tt.Button, { BackgroundColor3 = on and Config.Theme.Accent or Config.Theme.Card }, 0.1)
                U.Tween(tt.Label, { TextColor3 = on and Color3.new(1,1,1) or Config.Theme.Dim }, 0.1)
            end
            tabbox.ActiveTab = t
        end)

        table.insert(tabbox.Tabs, t)
        if #tabbox.Tabs == 1 then
            container.Visible = true
            U.Tween(btn, { BackgroundColor3 = Config.Theme.Accent }, 0.1)
            U.Tween(t.Label, { TextColor3 = Color3.new(1,1,1) }, 0.1)
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
            if not (excludeLocal and p == LocalPlayer) then table.insert(list, p.Name) end
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
    Players.PlayerAdded:Connect(function() dd.Refresh(nil, getPlayers()) end)
    Players.PlayerRemoving:Connect(function() dd.Refresh(nil, getPlayers()) end)
    return dd
end

--==============================================================
-- TEAM DROPDOWN
--==============================================================
function NovaUI:AddTeamDropdown(parent, opts)
    opts = opts or {}
    local function getTeams()
        local list = {}
        for _, t in ipairs(game:GetService("Teams"):GetTeams()) do table.insert(list, t.Name) end
        return list
    end
    return NovaUI:AddDropdown(parent, {
        Name = opts.Name or opts.Text or "Team",
        Values = getTeams(),
        Default = opts.Default,
        Callback = opts.Callback,
        Flag = opts.Flag,
        Searchable = true,
    })
end

--==============================================================
-- KEYBOX
--==============================================================
function NovaUI:AddKeyBox(parent, callback)
    local frame = CreateBase(parent, 28)

    local boxBg = U.Create("Frame", {
        Parent = frame, BackgroundColor3 = Config.Theme.Hover,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0.5, -8),
        Size = UDim2.new(1, -80, 0, 16),
    })
    U.Corner(boxBg, 4)
    local stroke = U.Stroke(boxBg, Config.Theme.Line, 1)

    local box = U.Create("TextBox", {
        Parent = boxBg, BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Font = Config.Font, Text = "",
        PlaceholderText = "Enter key...",
        PlaceholderColor3 = Config.Theme.Dim,
        TextColor3 = Config.Theme.Text, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    box.Focused:Connect(function() U.Tween(stroke, { Color = Config.Theme.Accent }, 0.1) end)
    box.FocusLost:Connect(function() U.Tween(stroke, { Color = Config.Theme.Line }, 0.1) end)

    local submit = U.Create("TextButton", {
        Parent = frame, BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -64, 0.5, -8),
        Size = UDim2.new(0, 56, 0, 16),
        Text = "", AutoButtonColor = false,
    })
    U.Corner(submit, 4)
    U.Create("TextLabel", {
        Parent = submit, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.FontBold, Text = "Submit",
        TextColor3 = Color3.new(1,1,1), TextSize = 10,
    })
    submit.MouseButton1Click:Connect(function()
        if callback then pcall(callback, box.Text) end
    end)
    return { Instance = frame, Get = function() return box.Text end }
end

--==============================================================
-- WARNING BOX
--==============================================================
function NovaUI:AddWarningBox(tab, opts)
    opts = opts or {}
    local frame = U.Create("Frame", {
        Parent = tab.Container,
        BackgroundColor3 = Color3.fromRGB(46, 34, 20),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = opts.Visible ~= false,
        ClipsDescendants = true,
    })
    U.Corner(frame, 5)

    U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 6),
        Size = UDim2.new(1, -16, 0, 12),
        Font = Config.FontBold, Text = opts.Title or "Warning",
        TextColor3 = Config.Theme.Yellow, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local body = U.Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 20),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Config.Font, Text = opts.Text or "",
        TextColor3 = Config.Theme.Text, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })
    U.Create("UIPadding", { Parent = frame, PaddingBottom = UDim.new(0, 6) })

    return {
        Instance = frame,
        SetVisible = function(_, v) frame.Visible = v end,
        SetTitle = function(_, t) frame:FindFirstChildOfClass("TextLabel").Text = t end,
        SetText = function(_, t) body.Text = t end,
    }
end

--==============================================================
-- THEME MANAGER
--==============================================================
local ThemeManager = {}
ThemeManager.__index = ThemeManager

local Themes = {
    Dark = {
        Bg=Color3.fromRGB(15,15,18), Panel=Color3.fromRGB(22,22,27),
        Card=Color3.fromRGB(30,30,36), Hover=Color3.fromRGB(38,38,46),
        Line=Color3.fromRGB(48,48,58), Text=Color3.fromRGB(235,235,240),
        Dim=Color3.fromRGB(120,120,138), Accent=Color3.fromRGB(140,100,255),
    },
    Midnight = {
        Bg=Color3.fromRGB(10,12,22), Panel=Color3.fromRGB(16,20,36),
        Card=Color3.fromRGB(22,28,48), Hover=Color3.fromRGB(30,38,60),
        Line=Color3.fromRGB(40,50,78), Text=Color3.fromRGB(220,228,255),
        Dim=Color3.fromRGB(120,132,165), Accent=Color3.fromRGB(80,140,255),
    },
    Ocean = {
        Bg=Color3.fromRGB(10,20,24), Panel=Color3.fromRGB(14,28,34),
        Card=Color3.fromRGB(20,38,46), Hover=Color3.fromRGB(28,50,60),
        Line=Color3.fromRGB(36,62,74), Text=Color3.fromRGB(220,240,245),
        Dim=Color3.fromRGB(120,145,155), Accent=Color3.fromRGB(40,200,200),
    },
    Rose = {
        Bg=Color3.fromRGB(20,12,18), Panel=Color3.fromRGB(28,16,24),
        Card=Color3.fromRGB(36,20,32), Hover=Color3.fromRGB(46,28,40),
        Line=Color3.fromRGB(60,36,54), Text=Color3.fromRGB(245,225,235),
        Dim=Color3.fromRGB(155,125,140), Accent=Color3.fromRGB(255,80,160),
    },
    Monochrome = {
        Bg=Color3.fromRGB(12,12,12), Panel=Color3.fromRGB(20,20,20),
        Card=Color3.fromRGB(28,28,28), Hover=Color3.fromRGB(38,38,38),
        Line=Color3.fromRGB(50,50,50), Text=Color3.fromRGB(240,240,240),
        Dim=Color3.fromRGB(140,140,140), Accent=Color3.fromRGB(200,200,200),
    },
    Blood = {
        Bg=Color3.fromRGB(16,10,10), Panel=Color3.fromRGB(24,14,14),
        Card=Color3.fromRGB(32,18,18), Hover=Color3.fromRGB(44,24,24),
        Line=Color3.fromRGB(58,30,30), Text=Color3.fromRGB(245,225,225),
        Dim=Color3.fromRGB(160,120,120), Accent=Color3.fromRGB(220,40,60),
    },
}

function ThemeManager.new()
    return setmetatable({}, ThemeManager)
end

function ThemeManager:ApplyTheme(name)
    local t = Themes[name]; if not t then return end
    for k, v in pairs(t) do Config.Theme[k] = v end
    for _, w in ipairs(NovaUI.Windows) do
        if w.Main then w.Main.BackgroundColor3 = Config.Theme.Bg end
        if w.Header then w.Header.BackgroundColor3 = Config.Theme.Panel end
    end
    NovaUI.Notify("Theme", "Applied: " .. name, Config.Theme.Accent, 2)
end

function ThemeManager:GetThemeNames()
    local names = {}
    for k in pairs(Themes) do table.insert(names, k) end
    table.sort(names)
    return names
end

function ThemeManager:BuildUI(tab, side)
    local group = NovaUI:AddGroupbox(tab, {
        Name = "Themes", Side = side or "Left", Icon = "Palette",
    })
    local names = self:GetThemeNames()
    NovaUI:AddDropdown(group, {
        Name = "Select", Values = names, Default = "Dark",
        Callback = function(v) self:ApplyTheme(v) end,
    })
    return group
end

NovaUI.ThemeManager = ThemeManager.new()
NovaUI.BuiltinThemes = Themes

--==============================================================
-- SAVE MANAGER
--==============================================================
local SaveManager = {}
SaveManager.__index = SaveManager

function SaveManager.new()
    local s = setmetatable({}, SaveManager)
    s.Folder = "NovaUI"; s.SubFolder = ""; s.IgnoreIndexes = {}
    return s
end

function SaveManager:SetFolder(f) self.Folder = f end
function SaveManager:SetSubFolder(f) self.SubFolder = f end
function SaveManager:SetIgnoreIndexes(t) self.IgnoreIndexes = t or {} end
function SaveManager:IgnoreThemeSettings() end

function SaveManager:_filePath(name)
    local parts = { self.Folder }
    if self.SubFolder ~= "" then table.insert(parts, self.SubFolder) end
    table.insert(parts, name .. ".json")
    return table.concat(parts, "/")
end

function SaveManager:_ignored(idx)
    for _, ig in ipairs(self.IgnoreIndexes) do if ig == idx then return true end end
    return false
end

function SaveManager:Save(name)
    if not writefile then
        NovaUI.Notify("Save", "writefile unavailable (executor required)", Config.Theme.Red, 3); return
    end
    name = name or "default"
    local data = {}
    for idx, el in pairs(NovaUI.Flags) do
        if not self:_ignored(idx) and type(el.Get) == "function" then
            local v = el:Get()
            if typeof(v) == "Color3" then
                data[idx] = { __t="Color3", R=v.R, G=v.G, B=v.B }
            else data[idx] = v end
        end
    end
    pcall(function()
        if makefolder then
            pcall(makefolder, self.Folder)
            if self.SubFolder ~= "" then pcall(makefolder, self.Folder .. "/" .. self.SubFolder) end
        end
        writefile(self:_filePath(name), HttpService:JSONEncode(data))
    end)
    NovaUI.Notify("Save", "Saved: " .. name, Config.Theme.Green, 2)
end

function SaveManager:Load(name)
    if not (readfile and isfile) then
        NovaUI.Notify("Save", "readfile unavailable (executor required)", Config.Theme.Red, 3); return
    end
    name = name or "default"
    local path = self:_filePath(name)
    if not isfile(path) then
        NovaUI.Notify("Save", "Not found: " .. name, Config.Theme.Yellow, 2); return
    end
    local ok, raw = pcall(readfile, path); if not ok then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw); if not ok2 then return end
    for idx, v in pairs(data) do
        local el = NovaUI.Flags[idx]
        if el and not self:_ignored(idx) then
            if type(v) == "table" and v.__t == "Color3" then
                pcall(function() el:Set(Color3.new(v.R, v.G, v.B)) end)
            else
                pcall(function() el:Set(v) end)
            end
        end
    end
    NovaUI.Notify("Save", "Loaded: " .. name, Config.Theme.Green, 2)
end

function SaveManager:Delete(name)
    if not (delfile and isfile) then return end
    local p = self:_filePath(name or "default")
    if isfile(p) then pcall(delfile, p) end
end

function SaveManager:BuildConfigSection(tab, side)
    local group = NovaUI:AddGroupbox(tab, {
        Name = "Configs", Side = side or "Right", Icon = "Save",
    })
    NovaUI:AddTextbox(group, {
        Name = "Name", Default = "default", Placeholder = "config name",
        Flag = "_cfgName",
    })
    NovaUI:AddButton(group, { Name = "Save", Icon = "Save", Callback = function()
        local n = NovaUI.Flags._cfgName and NovaUI.Flags._cfgName:Get() or "default"
        self:Save(n)
    end })
    NovaUI:AddButton(group, { Name = "Load", Icon = "Download", Callback = function()
        local n = NovaUI.Flags._cfgName and NovaUI.Flags._cfgName:Get() or "default"
        self:Load(n)
    end })
    NovaUI:AddButton(group, { Name = "Delete", Icon = "Trash", Risky = true, Callback = function()
        local n = NovaUI.Flags._cfgName and NovaUI.Flags._cfgName:Get() or "default"
        self:Delete(n)
    end })
    return group
end

function SaveManager:LoadAutoloadConfig() end

NovaUI.SaveManager = SaveManager.new()

--==============================================================
-- PUBLIC API + SCOPE HOOKS
--==============================================================
NovaUI.Version = "5.0.0"

-- Register per-tab / per-group element methods
function NovaUI:_RegisterTabMethods(tab)
    tab.AddButton         = function(_, o) return NovaUI:AddButton(tab, o) end
    tab.AddToggle         = function(_, o) return NovaUI:AddToggle(tab, o) end
    tab.AddCheckbox       = function(_, o) return NovaUI:AddCheckbox(tab, o) end
    tab.AddSlider         = function(_, o) return NovaUI:AddSlider(tab, o) end
    tab.AddTextbox        = function(_, o) return NovaUI:AddTextbox(tab, o) end
    tab.AddInput          = function(_, o) return NovaUI:AddTextbox(tab, o) end
    tab.AddKeybind        = function(_, o) return NovaUI:AddKeybind(tab, o) end
    tab.AddKeyPicker      = function(_, o) return NovaUI:AddKeybind(tab, o) end
    tab.AddDropdown       = function(_, o) return NovaUI:AddDropdown(tab, o) end
    tab.AddLabel          = function(_, t, w, i) return NovaUI:AddLabel(tab, t, w, i) end
    tab.AddDivider        = function(_) return NovaUI:AddDivider(tab) end
    tab.AddParagraph      = function(_, o) return NovaUI:AddParagraph(tab, o) end
    tab.AddColorPicker    = function(_, o) return NovaUI:AddColorPicker(tab, o) end
    tab.AddSearchBar      = function(_, o) return NovaUI:AddSearchBar(tab, o) end
    tab.AddSection        = function(_, n) return NovaUI:AddSection(tab, n) end
    tab.AddGroupbox       = function(_, o) return NovaUI:AddGroupbox(tab, o) end
    tab.AddTabbox         = function(_, o) return NovaUI:AddTabbox(tab, o) end
    tab.AddLeftTabbox     = function(_) return NovaUI:AddTabbox(tab) end
    tab.AddRightTabbox    = function(_) return NovaUI:AddTabbox(tab) end
    tab.AddLeftGroupbox   = function(_, n, i) return NovaUI:AddGroupbox(tab, { Side="Left",  Name=n or "Group", Icon=i or "Boxes" }) end
    tab.AddRightGroupbox  = function(_, n, i) return NovaUI:AddGroupbox(tab, { Side="Right", Name=n or "Group", Icon=i or "Boxes" }) end
    tab.AddWarningBox     = function(_, o) return NovaUI:AddWarningBox(tab, o) end
    tab.AddKeyBox         = function(_, cb) return NovaUI:AddKeyBox(tab, cb) end
    tab.AddPlayerDropdown = function(_, o) return NovaUI:AddPlayerDropdown(tab, o) end
    tab.AddTeamDropdown   = function(_, o) return NovaUI:AddTeamDropdown(tab, o) end
    tab.AddDraggableLabel = function(_, txt) return NovaUI:AddDraggableLabel(txt) end
    return tab
end

function NovaUI:_RegisterGroupMethods(group)
    group.AddButton         = function(_, o) return NovaUI:AddButton(group, o) end
    group.AddToggle         = function(_, o) return NovaUI:AddToggle(group, o) end
    group.AddCheckbox       = function(_, o) return NovaUI:AddCheckbox(group, o) end
    group.AddSlider         = function(_, o) return NovaUI:AddSlider(group, o) end
    group.AddTextbox        = function(_, o) return NovaUI:AddTextbox(group, o) end
    group.AddInput          = function(_, o) return NovaUI:AddTextbox(group, o) end
    group.AddKeybind        = function(_, o) return NovaUI:AddKeybind(group, o) end
    group.AddKeyPicker      = function(_, o) return NovaUI:AddKeybind(group, o) end
    group.AddDropdown       = function(_, o) return NovaUI:AddDropdown(group, o) end
    group.AddLabel          = function(_, t, w, i) return NovaUI:AddLabel(group, t, w, i) end
    group.AddDivider        = function(_) return NovaUI:AddDivider(group) end
    group.AddParagraph      = function(_, o) return NovaUI:AddParagraph(group, o) end
    group.AddColorPicker    = function(_, o) return NovaUI:AddColorPicker(group, o) end
    group.AddSearchBar      = function(_, o) return NovaUI:AddSearchBar(group, o) end
    group.AddPlayerDropdown = function(_, o) return NovaUI:AddPlayerDropdown(group, o) end
    group.AddTeamDropdown   = function(_, o) return NovaUI:AddTeamDropdown(group, o) end
    return group
end

-- Hook CreateTab
local _origCreateTab = NovaUI.CreateTab
function NovaUI:CreateTab(options)
    return self:_RegisterTabMethods(_origCreateTab(self, options))
end

-- Hook AddGroupbox
local _origAddGroupbox = NovaUI.AddGroupbox
function NovaUI:AddGroupbox(tab, options)
    return self:_RegisterGroupMethods(_origAddGroupbox(self, tab, options))
end

-- Hook Tabbox:AddTab
local _origAddTabbox = NovaUI.AddTabbox
function NovaUI:AddTabbox(parent, options)
    local tb = _origAddTabbox(self, parent, options)
    local orig = tb.AddTab
    tb.AddTab = function(self2, n)
        return NovaUI:_RegisterGroupMethods(orig(self2, n))
    end
    return tb
end

--==============================================================
-- SETTINGS HELPERS (close button + unload in Settings tab)
--==============================================================
function NovaUI:AddUnloadButton(parent, opts)
    opts = opts or {}
    NovaUI:AddButton(parent, {
        Name = opts.Name or "Unload UI",
        Icon = opts.Icon or "Power",
        Risky = opts.Risky ~= false,
        Callback = function()
            local wins = NovaUI.Windows
            for _, w in ipairs(wins) do
                if w.Destroy then pcall(function() w:Destroy() end) end
            end
        end,
    })
end

function NovaUI:AddCloseButton(parent, opts)
    opts = opts or {}
    NovaUI:AddButton(parent, {
        Name = opts.Name or "Close UI",
        Icon = opts.Icon or "Close",
        Risky = true,
        Callback = function()
            for _, w in ipairs(NovaUI.Windows) do
                if w.Destroy then pcall(function() w:Destroy() end) end
            end
        end,
    })
end

--==============================================================
-- MANAGERS ATTACH HELPER
--==============================================================
function NovaUI:AttachManagers(uiSettingsTab)
    if uiSettingsTab then
        NovaUI.ThemeManager:BuildUI(uiSettingsTab, "Left")
        NovaUI.SaveManager:BuildConfigSection(uiSettingsTab, "Right")
    end
end

--==============================================================
-- GLOBAL EXPORT + INIT
--==============================================================
pcall(function() getgenv().NovaUI = NovaUI end)

print(("[NovaUI v%s] Loaded | %d icons | %d themes"):format(
    NovaUI.Version,
    (function() local n = 0; for _ in pairs(Icons) do n = n + 1 end; return n end)(),
    (function() local n = 0; for _ in pairs(Themes) do n = n + 1 end; return n end)()
))

_NovaUIPartial = nil

return NovaUI
--==============================================================
-- END OF NOVAUI v5.0
--==============================================================
