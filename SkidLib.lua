-- ============================================================================
-- SKID LIB (STABLE LOADING SCREEN & UI ENGINE)
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
        Accent = Color3.fromRGB(99, 102, 241),
        GreenLoading = Color3.fromRGB(59, 214, 148),
        Text = Color3.fromRGB(240, 243, 250),
        Muted = Color3.fromRGB(130, 140, 160),
        Border = Color3.fromRGB(35, 42, 56)
    }
}

getgenv().Options = Skid.Options
getgenv().Toggles = Skid.Toggles

Skid.Icons = {
    Zap = "rbxassetid://10747384394",
    Eye = "rbxassetid://10723346959",
    Shield = "rbxassetid://10747361219",
    Settings = "rbxassetid://10734950309",
    Search = "rbxassetid://10734943674",
    User = "rbxassetid://10747373176",
    Crosshair = "rbxassetid://10723374641",
    Terminal = "rbxassetid://10734982146",
    Lock = "rbxassetid://10723423126"
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
            dragging = true dragStart = input.Position startPos = targetFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
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

function Skid:CreateWindow(cfg)
    local titleText = type(cfg) == "table" and (cfg.Title or "SKID ENGINE") or (cfg or "SKID ENGINE")

    -- Main Window (Created hidden)
    local Window = Create("Frame", {
        Name = "SkidMainWindow",
        Parent = ScreenGui,
        Size = UDim2.new(0, 540, 0, 360),
        Position = UDim2.new(0.5, -270, 0.5, -180),
        BackgroundColor3 = Skid.Theme.Background,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 })
    })

    -- Loading Screen Overlay
    local Overlay = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(8, 9, 12),
        ZIndex = 2000
    })

    local Loader = Create("Frame", {
        Parent = Overlay,
        Size = UDim2.new(0, 280, 0, 80),
        Position = UDim2.new(0.5, -140, 0.5, -40),
        BackgroundColor3 = Skid.Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 2001
    }, {
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
        Create("TextLabel", {
            Text = string.upper(titleText),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Skid.Theme.Text,
            Size = UDim2.new(1, 0, 0.4, 0),
            Position = UDim2.new(0, 0, 0.15, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            ZIndex = 2002
        }),
        Create("TextLabel", {
            Text = "INITIALIZING...",
            Font = Enum.Font.GothamMedium,
            TextSize = 9,
            TextColor3 = Skid.Theme.GreenLoading,
            Size = UDim2.new(1, 0, 0.3, 0),
            Position = UDim2.new(0, 0, 0.55, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            ZIndex = 2002
        })
    })

    -- Curveless Border Trail Lines
    local TopLine = Create("Frame", { Parent = Loader, Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Skid.Theme.GreenLoading, BorderSizePixel = 0, ZIndex = 2003 })
    local RightLine = Create("Frame", { Parent = Loader, Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(1, -2, 0, 0), BackgroundColor3 = Skid.Theme.GreenLoading, BorderSizePixel = 0, ZIndex = 2003 })
    local BottomLine = Create("Frame", { Parent = Loader, Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(1, 0, 1, -2), BackgroundColor3 = Skid.Theme.GreenLoading, BorderSizePixel = 0, ZIndex = 2003 })
    local LeftLine = Create("Frame", { Parent = Loader, Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Skid.Theme.GreenLoading, BorderSizePixel = 0, ZIndex = 2003 })

    -- Run Loading Sequence non-blocking
    task.spawn(function()
        pcall(function()
            TopLine.Size = UDim2.new(1, 0, 0, 2)
            task.wait(0.2)
            RightLine.Size = UDim2.new(0, 2, 1, 0)
            task.wait(0.2)
            BottomLine.Size = UDim2.new(1, 0, 0, 2)
            BottomLine.Position = UDim2.new(0, 0, 1, -2)
            task.wait(0.2)
            LeftLine.Size = UDim2.new(0, 2, 1, 0)
            LeftLine.Position = UDim2.new(0, 0, 0, 0)
            task.wait(0.3)
        end)

        -- Remove loading screen and display main UI
        Overlay:Destroy()
        Window.Visible = true
    end)

    local Header = Create("Frame", {
        Parent = Window,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Skid.Theme.Sidebar,
        BorderSizePixel = 0
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
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
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    MakeDraggable(Header, Window)

    local Sidebar = Create("Frame", {
        Parent = Window,
        Size = UDim2.new(0, 38, 1, -28),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Skid.Theme.Sidebar,
        BorderSizePixel = 0
    }, {
        Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 6) })
    })

    local ContentHolder = Create("Frame", {
        Parent = Window,
        Size = UDim2.new(1, -38, 1, -28),
        Position = UDim2.new(0, 38, 0, 28),
        BackgroundTransparency = 1
    })

    local TabSystem = { Active = nil }

    local function HelperGroupbox(parentContainer, name)
        local GB = Create("Frame", {
            Parent = parentContainer,
            Size = UDim2.new(1, 0, 0, 26),
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
                Size = UDim2.new(1, -16, 1, -20),
                Position = UDim2.new(0, 8, 0, 18),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })
            })
        })

        local BoxContainer = GB.Container
        BoxContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            GB.Size = UDim2.new(1, 0, 0, BoxContainer.UIListLayout.AbsoluteContentSize.Y + 24)
        end)

        local Elements = {}

        function Elements:AddToggle(idx, opts)
            local txt = opts.Text or idx
            local def = opts.Default or false
            local cb = opts.Callback or function() end

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

            local Row = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1
            }, {
                Create("TextLabel", {
                    Text = txt,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local Switch = Create("Frame", {
                Parent = Row,
                Size = UDim2.new(0, 22, 0, 12),
                Position = UDim2.new(1, -22, 0.5, -6),
                BackgroundColor3 = def and Skid.Theme.Accent or Skid.Theme.Sidebar
            }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local Knob = Create("Frame", {
                Parent = Switch,
                Size = UDim2.new(0, 8, 0, 8),
                Position = def and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4),
                BackgroundColor3 = Skid.Theme.Text
            }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            local Btn = Create("TextButton", { Parent = Row, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })
            Btn.MouseButton1Click:Connect(function()
                TObj:SetValue(not TObj.Value)
                Switch.BackgroundColor3 = TObj.Value and Skid.Theme.Accent or Skid.Theme.Sidebar
                Knob.Position = TObj.Value and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
            end)

            return TObj
        end
        Elements.AddCheckbox = Elements.AddToggle

        function Elements:AddButton(opts)
            local txt = type(opts) == "table" and opts.Text or opts
            local fn = type(opts) == "table" and (opts.Func or opts.Callback) or function() end

            local Frame = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = Skid.Theme.Sidebar,
                BorderSizePixel = 0
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                Create("TextLabel", {
                    Text = txt,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BackgroundTransparency = 1
                })
            })

            local Btn = Create("TextButton", { Parent = Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })
            Btn.MouseButton1Click:Connect(function() task.spawn(fn) end)

            local BObj = {}
            function BObj:AddButton(subOpts)
                Frame.Size = UDim2.new(0.48, 0, 0, 20)
                subOpts.Text = subOpts.Text or "Sub"
                local subFrame = Create("Frame", {
                    Parent = BoxContainer,
                    Size = UDim2.new(0.48, 0, 0, 20),
                    Position = UDim2.new(0.52, 0, 0, 0),
                    BackgroundColor3 = Skid.Theme.Sidebar,
                    BorderSizePixel = 0
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", { Color = Skid.Theme.Border, Thickness = 1 }),
                    Create("TextLabel", {
                        Text = subOpts.Text,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 10,
                        TextColor3 = Skid.Theme.Text,
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

            local Container = Create("Frame", {
                Parent = BoxContainer,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1
            }, {
                Create("TextLabel", {
                    Text = txt,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Skid.Theme.Text,
                    Size = UDim2.new(0.5, 0, 0, 12),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })

            local ValLabel = Create("TextLabel", {
                Parent = Container,
                Text = tostring(def),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Skid.Theme.Muted,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, 0, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1
            })

            local Track = Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 4),
                Position = UDim2.new(0, 0, 0, 16),
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
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true Update(inp) end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then Update(inp) end
            end)

            return SObj
        end

        function Elements:AddLabel(txt)
            local Label = Create("TextLabel", {
                Parent = BoxContainer,
                Text = txt,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = Skid.Theme.Muted,
                Size = UDim2.new(1, 0, 0, 14),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })
            local LObj = {}
            function LObj:SetText(t) Label.Text = t end
            return LObj
        end

        function Elements:AddDivider()
            Create("Frame", { Parent = BoxContainer, Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Skid.Theme.Border, BorderSizePixel = 0 })
        end

        return Elements
    end

    function TabSystem:AddTab(tabName, iconName)
        local TabBtn = Create("ImageButton", {
            Parent = Sidebar,
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundColor3 = Skid.Theme.Groupbox,
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
                    b.BackgroundTransparency = 1
                    b.ImageColor3 = Skid.Theme.Muted
                end
            end
            TabContainer.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.ImageColor3 = Skid.Theme.Accent
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
        return TabObj
    end

    function Skid:Unload() ScreenGui:Destroy() end
    return TabSystem
end

return Skid
