--[[
    AetherUI Framework
    Theme: Premium Baby Blue + White Gradient (Glassmorphism)
    Architecture: Modular Single-File Build
]]

local AetherUI = {}
AetherUI.__index = AetherUI

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--// Environment Check
local ParentGui = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui

--// Globals & Garbage Collection
local Connections = {}
local AetherInstances = {}

--// Engines
local ThemeEngine = {
    BabyBlue = {
        MainBG = Color3.fromRGB(248, 251, 255),
        SidebarBG = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(137, 207, 240), -- Baby Blue
        PrimaryDark = Color3.fromRGB(100, 180, 220),
        Text = Color3.fromRGB(45, 55, 65),
        SubText = Color3.fromRGB(120, 130, 140),
        ElementBG = Color3.fromRGB(255, 255, 255),
        ElementHover = Color3.fromRGB(240, 248, 255),
        Stroke = Color3.fromRGB(220, 235, 250),
        Shadow = Color3.fromRGB(137, 207, 240)
    }
}
local CurrentTheme = ThemeEngine.BabyBlue

local AnimEngine = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Standard = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
}

--// Utility Functions
local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function Tween(instance, properties, tweenInfo)
    local tween = TweenService:Create(instance, tweenInfo or AnimEngine.Standard, properties)
    tween:Play()
    return tween
end

local function AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function CreateShadow(parent)
    return Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.8,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ScaleType = Enum.ScaleType.Slice,
        Parent = parent
    })
end

--// Notification System
local NotificationGui = Create("ScreenGui", {Name = "AetherNotifications", Parent = ParentGui})
local NotificationLayout = Create("Frame", {
    Name = "Container",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -320, 1, -20),
    Size = UDim2.new(0, 300, 1, 0),
    AnchorPoint = Vector2.new(0, 1),
    Parent = NotificationGui
}, {
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10)
    })
})

function AetherUI:Notify(config)
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 5

    local notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = CurrentTheme.ElementBG,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = NotificationLayout
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = CurrentTheme.Stroke, Thickness = 1, Transparency = 1}),
        Create("TextLabel", {
            Text = title, Font = Enum.Font.GothamBold, TextSize = 14,
            TextColor3 = CurrentTheme.Primary, BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(1, -30, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
        }),
        Create("TextLabel", {
            Text = content, Font = Enum.Font.Gotham, TextSize = 13,
            TextColor3 = CurrentTheme.SubText, BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 35), Size = UDim2.new(1, -30, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1
        }),
        Create("Frame", {
            Name = "ProgressBar", BackgroundColor3 = CurrentTheme.Primary,
            BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(0, 0, 0, 3), BackgroundTransparency = 1
        })
    })

    -- Entrance Animation
    Tween(notif, {BackgroundTransparency = 0})
    Tween(notif.UIStroke, {Transparency = 0})
    for _, child in ipairs(notif:GetChildren()) do
        if child:IsA("TextLabel") or child.Name == "ProgressBar" then
            Tween(child, {TextTransparency = 0, BackgroundTransparency = 0})
        end
    end

    -- Progress Bar
    local progressTween = Tween(notif.ProgressBar, {Size = UDim2.new(1, 0, 0, 3)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))
    
    task.delay(duration, function()
        -- Exit Animation
        local exit = Tween(notif, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)})
        Tween(notif.UIStroke, {Transparency = 1})
        for _, child in ipairs(notif:GetChildren()) do
            if child:IsA("TextLabel") or child.Name == "ProgressBar" then
                Tween(child, {TextTransparency = 1, BackgroundTransparency = 1})
            end
        end
        exit.Completed:Wait()
        notif:Destroy()
    end)
end

--// Window System
function AetherUI:CreateWindow(config)
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        ToggleKey = Enum.KeyCode.RightControl,
        IsVisible = true
    }
    
    local name = config.Name or "AetherUI"
    local subtitle = config.Subtitle or "Premium Framework"
    local size = config.Size or UDim2.new(0, 700, 0, 500)

    -- Core GUI
    local Gui = Create("ScreenGui", {Name = "AetherHub", ResetOnSpawn = false, Parent = ParentGui})
    table.insert(AetherInstances, Gui)

    local Main = Create("CanvasGroup", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.MainBG,
        Parent = Gui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("UIStroke", {Color = CurrentTheme.Stroke, Thickness = 1}),
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, CurrentTheme.MainBG)
            }),
            Rotation = 45
        })
    })
    
    CreateShadow(Main)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = CurrentTheme.SidebarBG,
        BorderSizePixel = 0,
        Parent = Main
    }, {
        Create("Frame", {
            Name = "Divider",
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = CurrentTheme.Stroke,
            BorderSizePixel = 0
        }),
        Create("TextLabel", {
            Name = "Title",
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            TextColor3 = CurrentTheme.Primary,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 20),
            Size = UDim2.new(1, -40, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Create("TextLabel", {
            Name = "Subtitle",
            Text = subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = CurrentTheme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 45),
            Size = UDim2.new(1, -40, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -20, 1, -90),
        Position = UDim2.new(0, 10, 0, 80),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    }, {
        Create("UIListLayout", {Padding = UDim.new(0, 5)})
    })

    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    AddConnection(Sidebar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    AddConnection(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            Tween(Main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, AnimEngine.Fast)
        end
    end)
    AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- UI Toggle Key
    AddConnection(UserInputService.InputBegan, function(input, gp)
        if not gp and input.KeyCode == Window.ToggleKey then
            Window.IsVisible = not Window.IsVisible
            Tween(Main, {
                GroupTransparency = Window.IsVisible and 0 or 1,
                Size = Window.IsVisible and size or UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9)
            }, AnimEngine.Smooth)
        end
    end)

    function Window:SetToggleKey(key)
        self.ToggleKey = key
    end

    --// Tab System
    function Window:CreateTab(tabConfig)
        local Tab = {Elements = {}}
        local tabName = tabConfig.Name or "Tab"
        local icon = tabConfig.Icon or ""

        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = CurrentTheme.ElementBG,
            BackgroundTransparency = 1,
            Text = "  " .. tabName,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = CurrentTheme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabContainer
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Create("Frame", {
                Name = "Indicator",
                Size = UDim2.new(0, 3, 0, 0),
                Position = UDim2.new(0, 5, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = CurrentTheme.Primary,
                Parent = TabBtn
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        })

        local TabContent = Create("ScrollingFrame", {
            Size = UDim2.new(1, -40, 1, -40),
            Position = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Primary,
            Visible = false,
            Parent = ContentArea
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 8)})
        })

        AddConnection(TabBtn.MouseEnter, function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = CurrentTheme.Text}, AnimEngine.Fast)
            end
        end)
        AddConnection(TabBtn.MouseLeave, function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 1, TextColor3 = CurrentTheme.SubText}, AnimEngine.Fast)
            end
        end)

        AddConnection(TabBtn.MouseButton1Click, function()
            -- Switch Tabs
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                Tween(t.Btn.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, AnimEngine.Fast)
                Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = CurrentTheme.SubText}, AnimEngine.Fast)
            end
            Window.CurrentTab = Tab
            TabContent.Visible = true
            Tween(TabBtn.Indicator, {Size = UDim2.new(0, 3, 0, 20)}, AnimEngine.Standard)
            Tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = CurrentTheme.Primary}, AnimEngine.Standard)
            
            -- Entrance Animation for content
            for _, element in ipairs(TabContent:GetChildren()) do
                if element:IsA("Frame") or element:IsA("TextButton") then
                    element.BackgroundTransparency = 1
                    Tween(element, {BackgroundTransparency = 0}, AnimEngine.Standard)
                end
            end
        end)

        Tab.Btn = TabBtn
        Tab.Content = TabContent
        table.insert(Window.Tabs, Tab)

        -- Default to first tab
        if #Window.Tabs == 1 then
            TabBtn.Indicator.Size = UDim2.new(0, 3, 0, 20)
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = CurrentTheme.Primary
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end

        --// Section System
        function Tab:CreateSection(sectionName)
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = sectionName,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = CurrentTheme.Primary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContent
            })
            Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = CurrentTheme.Stroke,
                BorderSizePixel = 0,
                Parent = TabContent
            })
        end

        --// Button System
        function Tab:CreateButton(btnConfig)
            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.ElementBG,
                Text = "",
                AutoButtonColor = false,
                ClipsDescendants = true,
                Parent = TabContent
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = CurrentTheme.Stroke, Thickness = 1}),
                Create("TextLabel", {
                    Text = btnConfig.Name or "Button",
                    Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = CurrentTheme.Text,
                    Position = UDim2.new(0, 15, 0, 10), Size = UDim2.new(1, -30, 0, 15),
                    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                }),
                Create("TextLabel", {
                    Text = btnConfig.Description or "",
                    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = CurrentTheme.SubText,
                    Position = UDim2.new(0, 15, 0, 25), Size = UDim2.new(1, -30, 0, 15),
                    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            AddConnection(Button.MouseEnter, function() Tween(Button, {BackgroundColor3 = CurrentTheme.ElementHover}, AnimEngine.Fast) end)
            AddConnection(Button.MouseLeave, function() Tween(Button, {BackgroundColor3 = CurrentTheme.ElementBG}, AnimEngine.Fast) end)
            
            AddConnection(Button.MouseButton1Click, function()
                -- Ripple Effect
                local mouse = Players.LocalPlayer:GetMouse()
                local ripple = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary, BackgroundTransparency = 0.6,
                    Position = UDim2.new(0, mouse.X - Button.AbsolutePosition.X, 0, mouse.Y - Button.AbsolutePosition.Y),
                    Size = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0.5), Parent = Button
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local tween = Tween(ripple, {Size = UDim2.new(0, 200, 0, 200), BackgroundTransparency = 1}, AnimEngine.Smooth)
                tween.Completed:Connect(function() ripple:Destroy() end)

                if btnConfig.Callback then task.spawn(btnConfig.Callback) end
            end)
        end

        --// Toggle System
        function Tab:CreateToggle(tglConfig)
            local state = tglConfig.Default or false
            local Toggle = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = CurrentTheme.ElementBG,
                Text = "", AutoButtonColor = false, Parent = TabContent
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = CurrentTheme.Stroke, Thickness = 1}),
                Create("TextLabel", {
                    Text = tglConfig.Name, Font = Enum.Font.GothamMedium, TextSize = 14,
                    TextColor3 = CurrentTheme.Text, Position = UDim2.new(0, 15, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local SwitchBG = Create("Frame", {
                Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -55, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = state and CurrentTheme.Primary or CurrentTheme.Stroke,
                Parent = Toggle
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local Indicator = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, state and 22 or 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SwitchBG
            }, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIStroke", {Color = Color3.fromRGB(0,0,0), Transparency = 0.9})
            })

            local function FireToggle()
                state = not state
                Tween(SwitchBG, {BackgroundColor3 = state and CurrentTheme.Primary or CurrentTheme.Stroke}, AnimEngine.Fast)
                Tween(Indicator, {Position = UDim2.new(0, state and 22 or 2, 0.5, 0)}, AnimEngine.Standard)
                if tglConfig.Callback then task.spawn(tglConfig.Callback, state) end
            end

            AddConnection(Toggle.MouseButton1Click, FireToggle)
        end

        --// Slider System
        function Tab:CreateSlider(slConfig)
            local value = slConfig.Default or slConfig.Min
            local SliderFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = CurrentTheme.ElementBG, Parent = TabContent
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = CurrentTheme.Stroke, Thickness = 1}),
                Create("TextLabel", {
                    Text = slConfig.Name, Font = Enum.Font.GothamMedium, TextSize = 14,
                    TextColor3 = CurrentTheme.Text, Position = UDim2.new(0, 15, 0, 10), BackgroundTransparency = 1
                }),
                Create("TextLabel", {
                    Name = "ValueDisplay", Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 14,
                    TextColor3 = CurrentTheme.Primary, Position = UDim2.new(1, -45, 0, 10), BackgroundTransparency = 1
                })
            })

            local Track = Create("TextButton", {
                Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 35),
                BackgroundColor3 = CurrentTheme.Stroke, Text = "", AutoButtonColor = false, Parent = SliderFrame
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local Fill = Create("Frame", {
                Size = UDim2.new(math.clamp((value - slConfig.Min) / (slConfig.Max - slConfig.Min), 0, 1), 0, 1, 0),
                BackgroundColor3 = CurrentTheme.Primary, Parent = Track
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

            local sliding = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                value = math.floor(slConfig.Min + ((slConfig.Max - slConfig.Min) * pos))
                Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, AnimEngine.Fast)
                SliderFrame.ValueDisplay.Text = tostring(value)
                if slConfig.Callback then task.spawn(slConfig.Callback, value) end
            end

            AddConnection(Track.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    UpdateSlider(input)
                end
            end)
            AddConnection(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            AddConnection(UserInputService.InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then UpdateSlider(input) end
            end)
        end
        
        return Tab
    end

    return Window
end

return AetherUI
