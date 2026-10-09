-- ============================================================================
-- SKID LIB (OBSIDIAN ARCHITECTURE - ULTRA-THIN DESIGN)
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Skid = {
    Options = {},
    Toggles = {},
    Flags = {},
    Unloaded = false,
    Theme = {
        Background = Color3.fromRGB(12, 14, 18),
        Sidebar = Color3.fromRGB(18, 20, 26),
        Groupbox = Color3.fromRGB(18, 21, 29),
        Element = Color3.fromRGB(24, 28, 38),
        ElementHover = Color3.fromRGB(32, 38, 52),
        Accent = Color3.fromRGB(99, 102, 241),
        Text = Color3.fromRGB(240, 243, 250),
        Muted = Color3.fromRGB(130, 140, 160),
        Border = Color3.fromRGB(35, 42, 56),
        Red = Color3.fromRGB(242, 68, 68)
    }
}

-- Global Table Exposure (Obsidian Standard)
getgenv().Options = Skid.Options
getgenv().Toggles = Skid.Toggles

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
    Sliders = "rbxassetid://10734975692",
    Boxes = "rbxassetid://10723396107",
    Wrench = "rbxassetid://10734950309"
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

-- Top Bar Quick Bar (Mobile/Desktop Minimize)
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

function Skid:Notify(opts)
    local title = opts.Title or "Notice"
    local desc = opts.Description or opts.Content or ""
    local dur = opts.Time or opts.Duration or 3

    local NotifHolder = ScreenGui:FindFirstChild("NotifContainer") or Create("Frame", {
        Name = "NotifContainer",
        Parent = ScreenGui,
        Size = UDim2.new(0, 200, 1, -20),
        Position = UDim2.new(1, -210, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 200
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 6)
        })
    })

    local Frame = Create("Frame", {
        Parent = NotifHolder,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Skid.Theme.Sidebar,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
        Create("TextLabel", {
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = Skid.Theme.Accent,
            Position = UDim2.new(0, 8, 0, 4),
            Size = UDim2.new(1, -16, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        }),
        Create("TextLabel", {
            Text = desc,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextColor3 = Skid.Theme.Muted,
            Position = UDim2.new(0, 8, 0, 18),
            Size = UDim2.new(1, -16, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })
    })

    task.delay(dur, function()
        TweenService:Create(Frame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
        task.wait(0.2)
        Frame:Destroy()
    end)
end

function Skid:CreateWindow(cfg)
    local titleText = type(cfg) == "table" and (cfg.Title or "SKID ENGINE") or (cfg or "SKID ENGINE")
    local lastPos = UDim2.new(0.5, -280, 0.5, -190)

    TopBar.TopTitle.Text = string.upper(titleText) .. " // ACTIVE"

    local Window = Create("Frame", {
        Name = "SkidMainWindow",
        Parent = ScreenGui,
        Size = UDim2.new(0, 560, 0, 380),
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
            Text = string.upper(titleText),
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
        Size = UDim2.new(0, 42, 1, -28),
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
        Size = UDim2.new(1, -42, 1, -28),
        Position = UDim2.new(0, 42, 0, 28),
        BackgroundTransparency = 1
    })

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, tabContainer in ipairs(ContentHolder:GetChildren()) do
            if tabContainer:IsA("Frame") then
                for _, box in ipairs(tabContainer:GetDescendants()) do
                    if box:IsA("Frame") and box:FindFirstChildOfClass("TextLabel") then
                        local lbl = box:FindFirstChildOfClass("TextLabel")
                        box.Visible = string.find(string.lower(lbl.Text), query) ~= nil or query == ""
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

    local function HelperGroupbox(parentContainer, name)
        local GB = Create("Frame", {
            Parent = parentContainer,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Skid.Theme.Groupbox,
            BorderSizePixel = 0
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
            Create("TextLabel", {
                Text = string.upper(name or "GROUPBOX"),
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                TextColor3 = Skid.Theme.Accent,
                Position = UDim2.new(0, 8, 0, 4),
                Size = UDim2.new(1, -16, 0, 14),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            }),
            Create("Frame", {
                Name = "Container",
                Size = UDim2.new(1, -16, 1, -22),
                Position = UDim2.new(0, 8, 0, 20),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
            })
        })

        local BoxContainer = GB.Container
        BoxContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            GB.Size = UDim2.new(1, 0, 0, BoxContainer.UIListLayout.AbsoluteContentSize.Y + 26)
        end)

        local Elements = {}

        -- AddToggle / AddCheckbox
        function Elements:AddToggle(idx, opts)
            local txt = opts.Text or idx
            local def = opts.Default or false
            local cb = opts.Callback or function() end
            local isRisky = opts.Risky or false

            local TObj = { Value = def, OnChangedFuncs = {} }
            Skid.Toggles[idx] = TObj
            Skid.Flags[idx] = def

            function TObj:OnChanged(fn) table.insert(TObj.OnChangedFuncs, fn) end
            function TObj:SetValue(v)
                TObj.Value = v
                Skid.Flags[idx] = v
                for _, f in ipairs(TObj.OnChangedFuncs) do task.spawn(f, v) end
                if cb then task.spawn(cb, v) end
            end

            local Frame = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = txt,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = isRisky and Skid.Theme.Red or Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.6, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local Switch = Create("Frame", {
                Parent = Frame,
                Size = UDim2.new(0, 22, 0, 12),
                Position = UDim2.new(1, -26, 0.5, -6),
                BackgroundColor3 = def and Skid.Theme.Accent or Skid.Theme.Sidebar
            }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local Knob = Create("Frame", {
                Parent = Switch,
                Size = UDim2.new(0, 8, 0, 8),
                Position = def and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4),
                BackgroundColor3 = Skid.Theme.Text
            }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local Btn = Create("TextButton", { Parent = Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })
            Btn.MouseButton1Click:Connect(function()
                TObj:SetValue(not TObj.Value)
                TweenService:Create(Switch, TweenInfo.new(0.12), { BackgroundColor3 = TObj.Value and Skid.Theme.Accent or Skid.Theme.Sidebar }):Play()
                TweenService:Create(Knob, TweenInfo.new(0.12), { Position = TObj.Value and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4) }):Play()
            end)

            -- Method chaining for ColorPicker/KeyPicker
            function TObj:AddColorPicker(cpIdx, cpOpts)
                Elements:AddColorPicker(cpIdx, cpOpts, Frame)
                return TObj
            end

            return TObj
        end
        Elements.AddCheckbox = Elements.AddToggle

        -- AddSlider
        function Elements:AddSlider(idx, opts)
            local txt = opts.Text or idx
            local min, max = opts.Min or 0, opts.Max or 100
            local def = opts.Default or min
            local cb = opts.Callback or function() end

            local SObj = { Value = def, OnChangedFuncs = {} }
            Skid.Options[idx] = SObj
            Skid.Flags[idx] = def

            function SObj:OnChanged(fn) table.insert(SObj.OnChangedFuncs, fn) end
            function SObj:SetValue(v)
                SObj.Value = v
                Skid.Flags[idx] = v
                for _, f in ipairs(SObj.OnChangedFuncs) do task.spawn(f, v) end
                if cb then task.spawn(cb, v) end
            end

            local Frame = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = txt,
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
                Text = tostring(def),
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
            }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local Fill = Create("Frame", {
                Parent = Track,
                Size = UDim2.new((def - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Skid.Theme.Accent
            }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local dragging = false
            local function Update(input)
                local p = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * p)
                SObj:SetValue(val)
                ValLabel.Text = tostring(val)
                Fill.Size = UDim2.new(p, 0, 1, 0)
            end

            Track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true Update(inp)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then Update(inp) end
            end)

            return SObj
        end

        -- AddButton (With SubButton Chaining)
        function Elements:AddButton(opts)
            local txt = type(opts) == "table" and opts.Text or opts
            local fn = type(opts) == "table" and (opts.Func or opts.Callback) or function() end

            local Frame = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = txt,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -16, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BackgroundTransparency = 1
                })
            })

            local Btn = Create("TextButton", { Parent = Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })
            Btn.MouseButton1Click:Connect(function() task.spawn(fn) end)

            local BObj = {}
            function BObj:AddButton(subOpts)
                -- Multi button container side-by-side
                Frame.Size = UDim2.new(0.48, 0, 0, 24)
                subOpts.Text = subOpts.Text or "Sub"
                local subFrame = Create("Frame", {
                    Parent = BoxContainer,
                    Size = UDim2.new(0.48, 0, 0, 24),
                    Position = UDim2.new(0.52, 0, 0, 0),
                    BackgroundColor3 = Skid.Theme.Element,
                    BorderSizePixel = 0
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                    Create("TextLabel", {
                        Text = subOpts.Text,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 10,
                        TextColor3 = Skid.Theme.Text,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BackgroundTransparency = 1
                    })
                })
                local SubBtn = Create("TextButton", { Parent = subFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })
                SubBtn.MouseButton1Click:Connect(function() if subOpts.Func then subOpts.Func() end end)
                return BObj
            end

            return BObj
        end

        -- AddDropdown
        function Elements:AddDropdown(idx, opts)
            local txt = opts.Text or idx
            local vals = opts.Values or {}
            local def = opts.Default or vals[1] or ""
            local cb = opts.Callback or function() end

            local DObj = { Value = def, OnChangedFuncs = {} }
            Skid.Options[idx] = DObj
            Skid.Flags[idx] = def

            function DObj:OnChanged(fn) table.insert(DObj.OnChangedFuncs, fn) end
            function DObj:SetValue(v)
                DObj.Value = v
                Skid.Flags[idx] = v
                for _, f in ipairs(DObj.OnChangedFuncs) do task.spawn(f, v) end
                if cb then task.spawn(cb, v) end
            end

            local expanded = false
            local DropFrame = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0,
                ClipsDescendants = true
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = txt,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.5, 0, 0, 24),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local SelectLbl = Create("TextLabel", {
                Parent = DropFrame,
                Text = tostring(def) .. " v",
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                TextColor3 = Skid.Theme.Accent,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -8, 0, 24),
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1
            })

            local ListHolder = Create("Frame", {
                Parent = DropFrame,
                Position = UDim2.new(0, 0, 0, 24),
                Size = UDim2.new(1, 0, 0, #vals * 20),
                BackgroundTransparency = 1
            }, { Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })

            for _, opt in ipairs(vals) do
                local OptBtn = Create("TextButton", {
                    Parent = ListHolder,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = Skid.Theme.Sidebar,
                    BackgroundTransparency = 0.5,
                    Text = tostring(opt),
                    Font = Enum.Font.Gotham,
                    TextSize = 9,
                    TextColor3 = Skid.Theme.Muted,
                    BorderSizePixel = 0
                })
                OptBtn.MouseButton1Click:Connect(function()
                    expanded = false
                    DObj:SetValue(opt)
                    SelectLbl.Text = tostring(opt) .. " v"
                    TweenService:Create(DropFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 24) }):Play()
                end)
            end

            local ToggleBtn = Create("TextButton", { Parent = DropFrame, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "" })
            ToggleBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                SelectLbl.Text = tostring(DObj.Value) .. (expanded and " ^" or " v")
                TweenService:Create(DropFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, expanded and (24 + #vals * 20) or 24) }):Play()
            end)

            return DObj
        end

        -- AddInput
        function Elements:AddInput(idx, opts)
            local txt = opts.Text or idx
            local def = opts.Default or ""
            local cb = opts.Callback or function() end

            local IObj = { Value = def, OnChangedFuncs = {} }
            Skid.Options[idx] = IObj

            function IObj:OnChanged(fn) table.insert(IObj.OnChangedFuncs, fn) end

            local Frame = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Skid.Theme.Element,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = txt,
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
                Size = UDim2.new(0.55, -8, 0, 16),
                Position = UDim2.new(0.45, 0, 0.5, -8),
                BackgroundColor3 = Skid.Theme.Sidebar,
                Font = Enum.Font.Gotham,
                TextSize = 9,
                TextColor3 = Skid.Theme.Text,
                PlaceholderText = opts.Placeholder or "Type...",
                Text = def,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
            })

            TextBox.FocusLost:Connect(function()
                IObj.Value = TextBox.Text
                for _, f in ipairs(IObj.OnChangedFuncs) do task.spawn(f, TextBox.Text) end
                if cb then task.spawn(cb, TextBox.Text) end
            end)

            return IObj
        end

        -- AddLabel
        function Elements:AddLabel(txt, wrap, idx)
            local Frame = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1
            })

            local Label = Create("TextLabel", {
                Parent = Frame,
                Text = txt,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = Skid.Theme.Muted,
                TextWrapped = wrap or false,
                Size = UDim2.new(1, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })

            local LObj = {}
            function LObj:SetText(t) Label.Text = t end

            if idx then Skid.Options[idx] = LObj end

            function LObj:AddColorPicker(cpIdx, cpOpts)
                Elements:AddColorPicker(cpIdx, cpOpts, Frame)
                return LObj
            end
            function LObj:AddKeyPicker(kpIdx, kpOpts)
                Elements:AddKeyPicker(kpIdx, kpOpts, Frame)
                return LObj
            end

            return LObj
        end

        -- AddDivider
        function Elements:AddDivider()
            Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Skid.Theme.Border,
                BorderSizePixel = 0
            })
        end

        -- AddColorPicker
        function Elements:AddColorPicker(idx, opts, parentOverride)
            local targetParent = parentOverride or BoxContainer
            local def = opts.Default or Color3.fromRGB(255, 255, 255)
            local cb = opts.Callback or function() end

            local CPObj = { Value = def, Transparency = opts.Transparency or 0, OnChangedFuncs = {} }
            Skid.Options[idx] = CPObj

            function CPObj:OnChanged(fn) table.insert(CPObj.OnChangedFuncs, fn) end
            function CPObj:SetValueRGB(c)
                CPObj.Value = c
                for _, f in ipairs(CPObj.OnChangedFuncs) do task.spawn(f, c) end
                if cb then task.spawn(cb, c) end
            end

            local Preview = Create("Frame", {
                Parent = targetParent,
                Size = UDim2.new(0, 18, 0, 12),
                Position = UDim2.new(1, -24, 0.5, -6),
                BackgroundColor3 = def,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
            })

            return CPObj
        end

        -- AddKeyPicker
        function Elements:AddKeyPicker(idx, opts, parentOverride)
            local targetParent = parentOverride or BoxContainer
            local def = opts.Default or "MB2"
            local cb = opts.Callback or function() end

            local KPObj = { Value = def, State = false, OnChangedFuncs = {}, OnClickFuncs = {} }
            Skid.Options[idx] = KPObj

            function KPObj:OnChanged(fn) table.insert(KPObj.OnChangedFuncs, fn) end
            function KPObj:OnClick(fn) table.insert(KPObj.OnClickFuncs, fn) end
            function KPObj:GetState() return KPObj.State end
            function KPObj:SetValue(v) KPObj.Value = v[1] or v end

            local BindBtn = Create("TextButton", {
                Parent = targetParent,
                Size = UDim2.new(0, 48, 0, 14),
                Position = UDim2.new(1, -54, 0.5, -7),
                BackgroundColor3 = Skid.Theme.Sidebar,
                Text = tostring(def),
                Font = Enum.Font.GothamBold,
                TextSize = 8,
                TextColor3 = Skid.Theme.Accent,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
            })

            return KPObj
        end

        return Elements
    end

    function TabSystem:AddTab(tabName, iconName)
        local TabBtn = Create("ImageButton", {
            Parent = Sidebar,
            Size = UDim2.new(0, 26, 0, 26),
            BackgroundColor3 = Skid.Theme.Element,
            BackgroundTransparency = 1,
            Image = Skid.Icons[iconName] or Skid.Icons[string.lower(iconName or "")] or "",
            ImageColor3 = Skid.Theme.Muted
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = string.sub(tabName or "T", 1, 1),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Skid.Theme.Muted,
                Visible = (Skid.Icons[iconName] == nil)
            })
        })

        local TabContainer = Create("Frame", {
            Parent = ContentHolder,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        })

        local LeftScroll = Create("ScrollingFrame", {
            Parent = TabContainer,
            Size = UDim2.new(0.49, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Skid.Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, {
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 4) })
        })

        local RightScroll = Create("ScrollingFrame", {
            Parent = TabContainer,
            Size = UDim2.new(0.49, 0, 1, 0),
            Position = UDim2.new(0.51, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Skid.Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, {
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 6) })
        })

        LeftScroll.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftScroll.CanvasSize = UDim2.new(0, 0, 0, LeftScroll.UIListLayout.AbsoluteContentSize.Y + 12)
        end)
        RightScroll.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightScroll.CanvasSize = UDim2.new(0, 0, 0, RightScroll.UIListLayout.AbsoluteContentSize.Y + 12)
        end)

        local function Select()
            for _, c in ipairs(ContentHolder:GetChildren()) do c.Visible = false end
            for _, b in ipairs(Sidebar:GetChildren()) do
                if b:IsA("ImageButton") then
                    TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 1, ImageColor3 = Skid.Theme.Muted }):Play()
                end
            end
            TabContainer.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0, ImageColor3 = Skid.Theme.Accent }):Play()
        end

        TabBtn.MouseButton1Click:Connect(Select)
        if not TabSystem.Active then Select() TabSystem.Active = TabContainer end

        local TabObj = {}

        function TabObj:AddGroupbox(opts)
            local side = opts.Side or "Left"
            local name = opts.Name or "Groupbox"
            local targetScroll = (string.lower(side) == "right") and RightScroll or LeftScroll
            return HelperGroupbox(targetScroll, name)
        end

        function TabObj:AddLeftGroupbox(name) return TabObj:AddGroupbox({ Side = "Left", Name = name }) end
        function TabObj:AddRightGroupbox(name) return TabObj:AddGroupbox({ Side = "Right", Name = name }) end

        function TabObj:AddRightTabbox()
            local TabboxFrame = Create("Frame", {
                Parent = RightScroll,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Skid.Theme.Groupbox,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
            })

            local TabboxObj = {}
            function TabboxObj:AddTab(name)
                return HelperGroupbox(TabboxFrame, name)
            end
            return TabboxObj
        end

        function TabObj:UpdateWarningBox(opts)
            if opts.Visible then
                Skid:Notify({ Title = opts.Title or "Warning", Description = opts.Text or "", Time = 5 })
            end
        end

        return TabObj
    end

    function TabSystem:AddKeyTab(name)
        local KeyTab = TabSystem:AddTab(name, "Lock")
        local KeyGroup = KeyTab:AddLeftGroupbox("Key System")

        function KeyGroup:AddKeyBox(cb)
            local Input = KeyGroup:AddInput("KeyBoxInput", { Text = "Enter Key", Placeholder = "Key..." })
            KeyGroup:AddButton({
                Text = "Submit Key",
                Func = function()
                    if cb then cb(Input.Value) end
                end
            })
        end

        return KeyGroup
    end

    function Skid:Unload()
        Skid.Unloaded = true
        ScreenGui:Destroy()
    end

    function Skid:OnUnload(fn)
        ScreenGui.Destroying:Connect(fn)
    end

    return TabSystem
end

return Skid
