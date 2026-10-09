-- ============================================================================
-- SKID UI ENGINE (REUSABLE STANDALONE LIBRARY)
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Skid = {
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(12, 14, 18),
        Sidebar = Color3.fromRGB(18, 20, 26),
        Element = Color3.fromRGB(24, 28, 38),
        ElementHover = Color3.fromRGB(32, 38, 52),
        Accent = Color3.fromRGB(99, 102, 241),
        Text = Color3.fromRGB(240, 243, 250),
        Muted = Color3.fromRGB(130, 140, 160),
        Border = Color3.fromRGB(35, 42, 56)
    }
}

Skid.Icons = {
    Zap = "rbxassetid://10747384394",
    Eye = "rbxassetid://10723346959",
    Shield = "rbxassetid://10747361219",
    Settings = "rbxassetid://10734950309",
    Search = "rbxassetid://10734943674",
    Home = "rbxassetid://10723407389",
    User = "rbxassetid://10747373176",
    Code = "rbxassetid://10723353403",
    Crosshair = "rbxassetid://10723374641",
    Database = "rbxassetid://10723380231",
    Globe = "rbxassetid://10723404336",
    Lock = "rbxassetid://10723423126",
    Terminal = "rbxassetid://10734982146",
    Sliders = "rbxassetid://10734975692"
}

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function MakeDraggable(dragHandle, targetFrame)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function Skid:GetFlag(flag)
    return self.Flags[flag]
end

local ParentContainer = CoreGui
if gethui then
    ParentContainer = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(CoreGui)
end

local ScreenGui = Create("ScreenGui", {
    Name = "SkidEngineUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = ParentContainer
})

-- Top Bar Quick Bar
local TopBar = Create("Frame", {
    Name = "SkidTopBar",
    Parent = ScreenGui,
    Size = UDim2.new(0, 180, 0, 26),
    Position = UDim2.new(0.5, -90, 0, -40),
    BackgroundColor3 = Skid.Theme.Sidebar,
    BorderSizePixel = 0,
    ZIndex = 100
}, {
    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
    Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
    Create("TextLabel", {
        Name = "TopTitle",
        Text = "SKID // ACTIVE",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Skid.Theme.Accent,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })
})

local RestoreBtn = Create("TextButton", {
    Parent = TopBar,
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(1, -22, 0.5, -10),
    BackgroundTransparency = 1,
    Text = "O",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = Skid.Theme.Text
})

function Skid:CreateWindow(titleText)
    local customTitle = titleText or "SKID ENGINE"
    local lastPos = UDim2.new(0.5, -230, 0.5, -160)

    TopBar.TopTitle.Text = string.upper(customTitle) .. " // ACTIVE"

    local Window = Create("Frame", {
        Name = "SkidMainWindow",
        Parent = ScreenGui,
        Size = UDim2.new(0, 460, 0, 320),
        Position = lastPos,
        BackgroundColor3 = Skid.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 10
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
    })

    local Header = Create("Frame", {
        Parent = Window,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Skid.Theme.Sidebar,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
        Create("TextLabel", {
            Text = string.upper(customTitle),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Skid.Theme.Text,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(0.4, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })
    })

    local SearchBox = Create("TextBox", {
        Parent = Header,
        Size = UDim2.new(0, 120, 0, 18),
        Position = UDim2.new(1, -180, 0.5, -9),
        BackgroundColor3 = Skid.Theme.Element,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Skid.Theme.Text,
        PlaceholderText = "Search...",
        PlaceholderColor3 = Skid.Theme.Muted,
        Text = "",
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
    })

    local CloseBtn = Create("TextButton", {
        Parent = Header,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Skid.Theme.Muted,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1
    })

    local MinimizeBtn = Create("TextButton", {
        Parent = Header,
        Text = "-",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Skid.Theme.Muted,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -52, 0, 0),
        BackgroundTransparency = 1
    })

    MakeDraggable(Header, Window)

    local Sidebar = Create("Frame", {
        Parent = Window,
        Size = UDim2.new(0, 38, 1, -28),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Skid.Theme.Sidebar,
        BorderSizePixel = 0
    }, {
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 6) })
    })

    local ContentHolder = Create("Frame", {
        Parent = Window,
        Size = UDim2.new(1, -38, 1, -28),
        Position = UDim2.new(0, 38, 0, 28),
        BackgroundTransparency = 1
    })

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, tabContainer in ipairs(ContentHolder:GetChildren()) do
            if tabContainer:IsA("ScrollingFrame") then
                for _, elem in ipairs(tabContainer:GetChildren()) do
                    if elem:IsA("Frame") and elem:FindFirstChildOfClass("TextLabel") then
                        local lbl = elem:FindFirstChildOfClass("TextLabel")
                        elem.Visible = string.find(string.lower(lbl.Text), query) ~= nil or query == ""
                    end
                end
            end
        end
    end)

    local function ToggleMinimize(state)
        if state then
            lastPos = Window.Position
            Window.Visible = false
            TweenService:Create(TopBar, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -90, 0, 6)
            }):Play()
        else
            Window.Visible = true
            Window.Position = lastPos
            TweenService:Create(TopBar, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -90, 0, -40)
            }):Play()
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(function() ToggleMinimize(true) end)
    RestoreBtn.MouseButton1Click:Connect(function() ToggleMinimize(false) end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local TabSystem = { Active = nil }

    function TabSystem:CreateTab(iconAsset, tabLabelText)
        local TabBtn = Create("ImageButton", {
            Parent = Sidebar,
            Size = UDim2.new(0, 26, 0, 26),
            BackgroundColor3 = Skid.Theme.Element,
            BackgroundTransparency = 1,
            Image = iconAsset or "",
            ImageColor3 = Skid.Theme.Muted
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = string.sub(tabLabelText or "T", 1, 1),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Skid.Theme.Muted,
                Visible = (iconAsset == nil or iconAsset == "")
            })
        })

        local Container = Create("ScrollingFrame", {
            Parent = ContentHolder,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Skid.Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6)
            })
        })

        Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 12)
        end)

        local function Select()
            for _, c in ipairs(ContentHolder:GetChildren()) do c.Visible = false end
            for _, b in ipairs(Sidebar:GetChildren()) do
                if b:IsA("ImageButton") then
                    TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 1, ImageColor3 = Skid.Theme.Muted }):Play()
                end
            end
            Container.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0, ImageColor3 = Skid.Theme.Accent }):Play()
        end

        TabBtn.MouseButton1Click:Connect(Select)
        if not TabSystem.Active then Select() TabSystem.Active = Container end

        local Elements = {}

        function Elements:CreateSection(sectionText)
            Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1
            }, {
                Create("TextLabel", {
                    Text = string.upper(sectionText),
                    Font = Enum.Font.GothamBold,
                    TextSize = 9,
                    TextColor3 = Skid.Theme.Accent,
                    Position = UDim2.new(0, 2, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })
        end

        function Elements:CreateToggle(opts)
            local name = opts.Name or "Toggle"
            local flag = opts.Flag or name
            local default = opts.Default or false
            local callback = opts.Callback or function() end

            Skid.Flags[flag] = default

            local Frame = Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.7, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local Switch = Create("Frame", {
                Parent = Frame,
                Size = UDim2.new(0, 22, 0, 12),
                Position = UDim2.new(1, -28, 0.5, -6),
                BackgroundColor3 = default and Skid.Theme.Accent or Skid.Theme.Sidebar
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })

            local Knob = Create("Frame", {
                Parent = Switch,
                Size = UDim2.new(0, 8, 0, 8),
                Position = default and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4),
                BackgroundColor3 = Skid.Theme.Text
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })

            local Btn = Create("TextButton", { Parent = Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })

            Btn.MouseButton1Click:Connect(function()
                Skid.Flags[flag] = not Skid.Flags[flag]
                local active = Skid.Flags[flag]
                TweenService:Create(Switch, TweenInfo.new(0.12), { BackgroundColor3 = active and Skid.Theme.Accent or Skid.Theme.Sidebar }):Play()
                TweenService:Create(Knob, TweenInfo.new(0.12), { Position = active and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4) }):Play()
                task.spawn(callback, active)
            end)
        end

        function Elements:CreateSlider(opts)
            local name = opts.Name or "Slider"
            local min, max = opts.Range[1] or 0, opts.Range[2] or 100
            local default = opts.Default or min
            local flag = opts.Flag or name
            local callback = opts.Callback or function() end

            Skid.Flags[flag] = default

            local Frame = Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 2),
                    Size = UDim2.new(0.5, 0, 0, 12),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local ValLabel = Create("TextLabel", {
                Parent = Frame,
                Text = tostring(default),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Skid.Theme.Muted,
                Position = UDim2.new(0.5, 0, 0, 2),
                Size = UDim2.new(0.5, -8, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1
            })

            local Track = Create("Frame", {
                Parent = Frame,
                Size = UDim2.new(1, -16, 0, 4),
                Position = UDim2.new(0, 8, 0, 18),
                BackgroundColor3 = Skid.Theme.Sidebar
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })

            local Fill = Create("Frame", {
                Parent = Track,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Skid.Theme.Accent
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })

            local dragging = false
            local function Update(input)
                local p = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * p)
                Skid.Flags[flag] = val
                ValLabel.Text = tostring(val)
                Fill.Size = UDim2.new(p, 0, 1, 0)
                task.spawn(callback, val)
            end

            Track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true Update(inp)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    Update(inp)
                end
            end)
        end

        function Elements:CreateDropdown(opts)
            local name = opts.Name or "Dropdown"
            local options = opts.Options or {}
            local default = opts.Default or options[1] or ""
            local flag = opts.Flag or name
            local callback = opts.Callback or function() end

            Skid.Flags[flag] = default
            local expanded = false

            local DropFrame = Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0,
                ClipsDescendants = true
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.5, 0, 0, 26),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local SelectLbl = Create("TextLabel", {
                Parent = DropFrame,
                Text = default .. " v",
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Skid.Theme.Accent,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -8, 0, 26),
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1
            })

            local ListHolder = Create("Frame", {
                Parent = DropFrame,
                Position = UDim2.new(0, 0, 0, 26),
                Size = UDim2.new(1, 0, 0, #options * 22),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
            })

            for _, opt in ipairs(options) do
                local OptBtn = Create("TextButton", {
                    Parent = ListHolder,
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = Skid.Theme.Sidebar,
                    BackgroundTransparency = 0.5,
                    Text = opt,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Muted,
                    BorderSizePixel = 0
                })
                OptBtn.MouseButton1Click:Connect(function()
                    expanded = false
                    Skid.Flags[flag] = opt
                    SelectLbl.Text = opt .. " v"
                    TweenService:Create(DropFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 26) }):Play()
                    task.spawn(callback, opt)
                end)
            end

            local ToggleBtn = Create("TextButton", { Parent = DropFrame, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "" })
            ToggleBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                SelectLbl.Text = default .. (expanded and " ^" or " v")
                TweenService:Create(DropFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, expanded and (26 + #options * 22) or 26) }):Play()
            end)
        end

        function Elements:CreateInput(opts)
            local name = opts.Name or "Input"
            local placeholder = opts.Placeholder or "Type..."
            local callback = opts.Callback or function() end

            local Frame = Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local TextBox = Create("TextBox", {
                Parent = Frame,
                Size = UDim2.new(0.55, -8, 0, 18),
                Position = UDim2.new(0.45, 0, 0.5, -9),
                BackgroundColor3 = Skid.Theme.Sidebar,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = Skid.Theme.Text,
                PlaceholderText = placeholder,
                PlaceholderColor3 = Skid.Theme.Muted,
                Text = "",
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
            })

            TextBox.FocusLost:Connect(function(enter)
                task.spawn(callback, TextBox.Text, enter)
            end)
        end

        function Elements:CreateKeybind(opts)
            local name = opts.Name or "Keybind"
            local default = opts.Default or Enum.KeyCode.E
            local callback = opts.Callback or function() end

            local currentKey = default

            local Frame = Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = name,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.6, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local BindBtn = Create("TextButton", {
                Parent = Frame,
                Size = UDim2.new(0, 60, 0, 18),
                Position = UDim2.new(1, -68, 0.5, -9),
                BackgroundColor3 = Skid.Theme.Sidebar,
                Text = currentKey.Name,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                TextColor3 = Skid.Theme.Accent,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
            })

            BindBtn.MouseButton1Click:Connect(function()
                BindBtn.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        conn:Disconnect()
                        task.spawn(callback, currentKey)
                    end
                end)
            end)
        end

        return Elements
    end

    return TabSystem
end

return Skid
