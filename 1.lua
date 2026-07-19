local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local ScriptActive = true
local OrionLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        }
    },
    SelectedTheme = "Default",
    Folder = nil,
    SaveCfg = false
}
local Icons = {}
local Success, Response = pcall(function()
    Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)
if not Success then
    warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. tostring(Response) .. "\n")
end
local function GetIcon(IconName)
    if Icons[IconName] ~= nil then return Icons[IconName] else return nil end
end
local gethui = nil
pcall(function()
    gethui = gethui or (getgenv and getgenv().gethui)
    if not gethui then gethui = getrenv and getrenv().gethui end
end)
local function safeGetUI()
    local success, ui = pcall(function()
        if gethui and type(gethui) == "function" then return gethui() end
        return nil
    end)
    if success and ui then return ui end
    if syn and syn.protect_gui then return game:GetService("CoreGui") end
    return game:GetService("CoreGui")
end
local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
local parentUI = safeGetUI()
if syn and syn.protect_gui then pcall(function() syn.protect_gui(Orion) end) end
Orion.Parent = parentUI
pcall(function()
    local container = safeGetUI()
    for _, child in ipairs(container:GetChildren()) do
        if child.Name == "Orion" and child ~= Orion then child:Destroy() end
    end
end)
function OrionLib:IsRunning()
    local parent = Orion.Parent
    return parent and parent:IsDescendantOf(game)
end
local function AddConnection(Signal, Function)
    if not OrionLib:IsRunning() then return end
    local SignalConnect = Signal:Connect(Function)
    table.insert(OrionLib.Connections, SignalConnect)
    return SignalConnect
end
task.spawn(function()
    while OrionLib:IsRunning() do task.wait() end
    for _, Connection in pairs(OrionLib.Connections) do
        pcall(function() Connection:Disconnect() end)
    end
end)
local function MakeDraggable(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        AddConnection(DragPoint.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                MousePos = Input.Position
                FramePos = Main.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)
        AddConnection(DragPoint.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end
        end)
        AddConnection(UserInputService.InputChanged, function(Input)
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                Main.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
            end
        end)
    end)
end
local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do Object[i] = v end
    for i, v in next, Children or {} do v.Parent = Object end
    return Object
end
local function CreateElement(ElementName, ElementFunction)
    OrionLib.Elements[ElementName] = function(...) return ElementFunction(...) end
end
local function MakeElement(ElementName, ...)
    return OrionLib.Elements[ElementName](...)
end
local function SetProps(Element, Props)
    for Property, Value in pairs(Props) do Element[Property] = Value end
    return Element
end
local function SetChildren(Element, Children)
    for _, Child in pairs(Children) do Child.Parent = Element end
    return Element
end
local function Round(Number, Factor)
    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then Result = Result + Factor end
    return Result
end
local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3" end
    if Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
    if Object:IsA("UIStroke") then return "Color" end
    if Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3" end
    if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
end
local function AddThemeObject(Object, Type)
    if not OrionLib.ThemeObjects[Type] then OrionLib.ThemeObjects[Type] = {} end
    table.insert(OrionLib.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
    return Object
end
local function PackColor(Color) return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255} end
local function UnpackColor(Color) return Color3.fromRGB(Color.R, Color.G, Color.B) end
CreateElement("Corner", function(Scale, Offset) return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)}) end)
CreateElement("Stroke", function(Color, Thickness) return Create("UIStroke", {Color = Color or Color3.fromRGB(255, 255, 255), Thickness = Thickness or 1}) end)
CreateElement("List", function(Scale, Offset) return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(Scale or 0, Offset or 0)}) end)
CreateElement("Padding", function(Bottom, Left, Right, Top) return Create("UIPadding", {PaddingBottom = UDim.new(0, Bottom or 4), PaddingLeft = UDim.new(0, Left or 4), PaddingRight = UDim.new(0, Right or 4), PaddingTop = UDim.new(0, Top or 4)}) end)
CreateElement("TFrame", function() return Create("Frame", {BackgroundTransparency = 1}) end)
CreateElement("Frame", function(Color) return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255,255,255), BorderSizePixel = 0}) end)
CreateElement("RoundFrame", function(Color, Scale, Offset) return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255,255,255), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(Scale, Offset)})}) end)
CreateElement("Button", function() return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0}) end)
CreateElement("ScrollFrame", function(Color, Width) return Create("ScrollingFrame", {BackgroundTransparency = 1, MidImage = "rbxassetid://7445543667", BottomImage = "rbxassetid://7445543667", TopImage = "rbxassetid://7445543667", ScrollBarImageColor3 = Color, BorderSizePixel = 0, ScrollBarThickness = Width, CanvasSize = UDim2.new(0,0,0,0)}) end)
CreateElement("Image", function(ImageID)
    local img = Create("ImageLabel", {Image = ImageID, BackgroundTransparency = 1})
    if GetIcon(ImageID) ~= nil then img.Image = GetIcon(ImageID) end
    return img
end)
CreateElement("ImageButton", function(ImageID) return Create("ImageButton", {Image = ImageID, BackgroundTransparency = 1}) end)
CreateElement("Label", function(Text, TextSize, Transparency) return Create("TextLabel", {Text = Text or "", TextColor3 = Color3.fromRGB(240,240,240), TextTransparency = Transparency or 0, TextSize = TextSize or 15, Font = Enum.Font.Gotham, RichText = true, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left}) end)
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {SetProps(MakeElement("List"), {HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0,5)})}), {Position = UDim2.new(1,-25,1,-25), Size = UDim2.new(0,300,1,-25), AnchorPoint = Vector2.new(1,1), Parent = Orion})
function OrionLib:MakeNotification(NotificationConfig)
    spawn(function()
        NotificationConfig.Name = NotificationConfig.Name or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Test"
        NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
        NotificationConfig.Time = NotificationConfig.Time or 15
        local NotificationParent = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = NotificationHolder})
        local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25,25,25), 0,10), {Parent = NotificationParent, Size = UDim2.new(1,0,0,0), Position = UDim2.new(1,-55,0,0), BackgroundTransparency = 0, AutomaticSize = Enum.AutomaticSize.Y}), {
            MakeElement("Stroke", Color3.fromRGB(93,93,93), 1.2), MakeElement("Padding", 12,12,12,12),
            SetProps(MakeElement("Image", NotificationConfig.Image), {Size = UDim2.new(0,20,0,20), ImageColor3 = Color3.fromRGB(240,240,240), Name = "Icon"}),
            SetProps(MakeElement("Label", NotificationConfig.Name, 15), {Size = UDim2.new(1,-30,0,20), Position = UDim2.new(0,30,0,0), Font = Enum.Font.GothamBold, Name = "Title"}),
            SetProps(MakeElement("Label", NotificationConfig.Content, 14), {Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,25), Font = Enum.Font.GothamSemibold, Name = "Content", AutomaticSize = Enum.AutomaticSize.Y, TextColor3 = Color3.fromRGB(200,200,200), TextWrapped = true})
        })
        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()
        task.wait(NotificationConfig.Time - 0.88)
        TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        task.wait(0.3)
        TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        task.wait(0.05)
        NotificationFrame:TweenPosition(UDim2.new(1,20,0,0), "In", "Quint", 0.8, true)
        task.wait(1.35)
        NotificationFrame:Destroy()
    end)
end
function OrionLib:MakeWindow(WindowConfig)
    local FirstTab, Minimized, UIHidden = true, false, false
    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "Orion Library"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
    WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
    WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
    WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
    OrionLib.Folder = WindowConfig.ConfigFolder
    OrionLib.SaveCfg = WindowConfig.SaveConfig
    if WindowConfig.SaveConfig then pcall(function() if not isfolder(WindowConfig.ConfigFolder) then makefolder(WindowConfig.ConfigFolder) end end) end
    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {Size = UDim2.new(1,0,1,-50)}), {MakeElement("List"), MakeElement("Padding", 8,0,0,8)}), "Divider")
    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() TabHolder.CanvasSize = UDim2.new(0,0,0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16) end)
    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0.5,0,0,0), BackgroundTransparency = 1}), {AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {Position = UDim2.new(0,9,0,6), Size = UDim2.new(0,18,0,18)}), "Text")})
    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1}), {AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {Position = UDim2.new(0,9,0,6), Size = UDim2.new(0,18,0,18), Name = "Ico"}), "Text")})
    local DragPoint = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50)})
    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,10), {Size = UDim2.new(0,150,1,-50), Position = UDim2.new(0,0,0,50)}), {
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,0,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0)}), "Stroke"),
        TabHolder,
        SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,1,-50)}), {
            AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1)}), "Stroke"),
            AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,32,0,32), Position = UDim2.new(0,10,0.5,0)}), {
                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"), {Size = UDim2.new(1,0,1,0)}),
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {Size = UDim2.new(1,0,1,0)}), "Second"),
                MakeElement("Corner", 1)
            }), "Divider"),
            SetChildren(SetProps(MakeElement("TFrame"), {AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,32,0,32), Position = UDim2.new(0,10,0.5,0)}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), MakeElement("Corner", 1)}),
            AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {Size = UDim2.new(1,-60,0,13), Position = WindowConfig.HidePremium and UDim2.new(0,50,0,19) or UDim2.new(0,50,0,12), Font = Enum.Font.GothamBold, ClipsDescendants = true}), "Text")
        })
    }), "Second")
    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {Size = UDim2.new(1,-30,2,0), Position = UDim2.new(0,25,0,-24), Font = Enum.Font.GothamBlack, TextSize = 20}), "Text")
    local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1)}), "Stroke")
    local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,10), {Parent = Orion, Position = UDim2.new(0.5,-307,0.5,-172), Size = UDim2.new(0,615,0,344), ClipsDescendants = true, Active = true, Draggable = true}), {
        SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50), Name = "TopBar"}), {
            WindowName, WindowTopBarLine,
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,7), {Size = UDim2.new(0,70,0,30), Position = UDim2.new(1,-90,0,10)}), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(0.5,0,0,0)}), "Stroke"),
                CloseBtn, MinimizeBtn
            }), "Second")
        }), DragPoint, WindowStuff
    }), "Main")
    if WindowConfig.ShowIcon then
        WindowName.Position = UDim2.new(0,50,0,-24)
        local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,25,0,15)})
        WindowIcon.Parent = MainWindow.TopBar
    end
    MakeDraggable(DragPoint, MainWindow)
    AddConnection(CloseBtn.MouseButton1Up, function()
        ScriptActive = false
        AIMBOT_ENABLED = false
        ESP_ENABLED = false
        SHOW_CIRCLE = false
        EXTRACT_ESP_ENABLED = false
        BOT_ESP_ENABLED = false
        NIGHT_VISION_ENABLED = false
        SPEED_BOOST_ENABLED = false
        HIGH_JUMP_ENABLED = false
        GRAVITY_CHANGED = false
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Workspace.Gravity = originalGravity
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
        end
        for _, txt in pairs(extractESPObjects) do pcall(txt.Remove, txt) end
        for _, txt in pairs(botESPObjects) do pcall(txt.Remove, txt) end
        extractESPObjects = {}
        botESPObjects = {}
        OrionLib:MakeNotification({Name = "已退出", Content = "所有功能已禁用，设置已恢复", Time = 2})
        task.wait(0.8)
        if Orion then Orion:Destroy() end
        if FovGui then FovGui:Destroy() end
        if AimLineGui then AimLineGui:Destroy() end
        if ESPGui then ESPGui:Destroy() end
        if LBLG then LBLG:Destroy() end
        WindowConfig.CloseCallback()
    end)
    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0,615,0,344)}):Play()
            MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
            task.wait(0.02)
            MainWindow.ClipsDescendants = false
            WindowStuff.Visible = true
            WindowTopBarLine.Visible = true
        else
            MainWindow.ClipsDescendants = true
            WindowTopBarLine.Visible = false
            MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
            task.wait(0.1)
            WindowStuff.Visible = false
        end
        Minimized = not Minimized
    end)
    local function LoadSequence()
        MainWindow.Visible = false
        local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
            Parent = Orion,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.43, 0),
            Size = UDim2.new(0, 28, 0, 28),
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 1
        })
        local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
            Parent = Orion,
            Size = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 19, 0.43, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.GothamBold,
            TextTransparency = 1
        })
        task.wait()
        local textWidth = LoadSequenceText.TextBounds.X
        if textWidth < 1 then textWidth = 100 end
        TweenService:Create(LoadSequenceLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 0,
            Position = UDim2.new(0.5, 0, 0.43, 0)
        }):Play()
        task.wait(0.8)
        TweenService:Create(LoadSequenceLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -(textWidth / 2), 0.43, 0)
        }):Play()
        task.wait(0.3)
        TweenService:Create(LoadSequenceText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        task.wait(2)
        TweenService:Create(LoadSequenceText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 1
        }):Play()
        MainWindow.Visible = true
        LoadSequenceLogo:Destroy()
        LoadSequenceText:Destroy()
    end
    if WindowConfig.IntroEnabled then LoadSequence() end
    local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
        local TabFrame = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,0,30), Parent = TabHolder}), {
            AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,10,0.5,0), ImageTransparency = 0.4, Name = "Ico"}), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {Size = UDim2.new(1,-35,1,0), Position = UDim2.new(0,35,0,0), Font = Enum.Font.GothamSemibold, TextTransparency = 0.4, Name = "Title"}), "Text")
        })
        if GetIcon(TabConfig.Icon) ~= nil then TabFrame.Ico.Image = GetIcon(TabConfig.Icon) end
        local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {Size = UDim2.new(1,-150,1,-50), Position = UDim2.new(0,150,0,50), Parent = MainWindow, Visible = false, Name = "ItemContainer"}), {MakeElement("List", 0,6), MakeElement("Padding", 15,10,10,15)}), "Divider")
        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() Container.CanvasSize = UDim2.new(0,0,0, Container.UIListLayout.AbsoluteContentSize.Y + 30) end)
        if FirstTab then
            FirstTab = false
            TabFrame.Ico.ImageTransparency = 0
            TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end
        AddConnection(TabFrame.MouseButton1Click, function()
            for _, Tab in pairs(TabHolder:GetChildren()) do
                if Tab:IsA("TextButton") then
                    Tab.Title.Font = Enum.Font.GothamSemibold
                    TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
                end
            end
            for _, ItemContainer in pairs(MainWindow:GetChildren()) do
                if ItemContainer.Name == "ItemContainer" then ItemContainer.Visible = false end
            end
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
            TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end)
        local function GetElements(ItemParent)
            local ElementFunction = {}
            function ElementFunction:AddLabel(Text)
                local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"), AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Second")
                local LabelFunction = {}
                function LabelFunction:Set(ToChange) LabelFrame.Content.Text = ToChange end
                return LabelFunction
            end
            function ElementFunction:AddParagraph(Text, Content)
                Text = Text or "Text"; Content = Content or "Content"
                local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Title"}), "Text"), AddThemeObject(SetProps(MakeElement("Label", "", 13), {Size = UDim2.new(1,-24,0,0), Position = UDim2.new(0,12,0,26), Font = Enum.Font.GothamSemibold, Name = "Content", TextWrapped = true}), "TextDark"), AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Second")
                AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function() ParagraphFrame.Content.Size = UDim2.new(1,-24,0, ParagraphFrame.Content.TextBounds.Y); ParagraphFrame.Size = UDim2.new(1,0,0, ParagraphFrame.Content.TextBounds.Y + 35) end)
                ParagraphFrame.Content.Text = Content
                local ParagraphFunction = {}
                function ParagraphFunction:Set(ToChange) ParagraphFrame.Content.Text = ToChange end
                return ParagraphFunction
            end
            function ElementFunction:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"
                local Button = {}
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,5), {Size = UDim2.new(1,0,0,33), Parent = ItemParent}), {AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"), AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-30,0,7)}), "TextDark"), AddThemeObject(MakeElement("Stroke"), "Stroke"), Click}), "Second")
                AddConnection(Click.MouseEnter, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play() end)
                AddConnection(Click.MouseLeave, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play() end)
                AddConnection(Click.MouseButton1Up, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play(); spawn(function() ButtonConfig.Callback() end) end)
                AddConnection(Click.MouseButton1Down, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+6)}):Play() end)
                function Button:Set(Text) ButtonFrame.Content.Text = Text end
                return Button
            end
            function ElementFunction:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9,99,195)
                ToggleConfig.Flag = ToggleConfig.Flag or nil
                ToggleConfig.Save = ToggleConfig.Save or false
                local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0,4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-24,0.5,0), AnchorPoint = Vector2.new(0.5,0.5)}), {SetProps(MakeElement("Stroke"), {Color = ToggleConfig.Color, Name = "Stroke", Transparency = 0.5}), SetProps(MakeElement("Image", "rbxassetid://3944680095"), {Size = UDim2.new(0,20,0,20), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), ImageColor3 = Color3.fromRGB(255,255,255), Name = "Ico"})})
                local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"), AddThemeObject(MakeElement("Stroke"), "Stroke"), ToggleBox, Click}), "Second")
                function Toggle:Set(Value)
                    Toggle.Value = Value
                    TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
                    TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
                    TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0,20,0,20) or UDim2.new(0,8,0,8)}):Play()
                    ToggleConfig.Callback(Toggle.Value)
                end
                Toggle:Set(Toggle.Value)
                AddConnection(Click.MouseEnter, function() TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play() end)
                AddConnection(Click.MouseLeave, function() TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play() end)
                AddConnection(Click.MouseButton1Up, function() TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play(); Toggle:Set(not Toggle.Value) end)
                AddConnection(Click.MouseButton1Down, function() TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+6)}):Play() end)
                if ToggleConfig.Flag then OrionLib.Flags[ToggleConfig.Flag] = Toggle end
                return Toggle
            end
            function ElementFunction:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end
                SliderConfig.ValueName = SliderConfig.ValueName or ""
                SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9,149,98)
                SliderConfig.Flag = SliderConfig.Flag or nil
                SliderConfig.Save = SliderConfig.Save or false
                local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
                local Dragging = false
                local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0,5), {Size = UDim2.new(0,0,1,0), BackgroundTransparency = 0.3, ClipsDescendants = true}), {AddThemeObject(SetProps(MakeElement("Label", "value", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0}), "Text")})
                local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0,5), {Size = UDim2.new(1,-24,0,26), Position = UDim2.new(0,12,0,30), BackgroundTransparency = 0.9}), {SetProps(MakeElement("Stroke"), {Color = SliderConfig.Color}), AddThemeObject(SetProps(MakeElement("Label", "value", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0.8}), "Text"), SliderDrag})
                local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0,4), {Size = UDim2.new(1,0,0,65), Parent = ItemParent}), {AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"), AddThemeObject(MakeElement("Stroke"), "Stroke"), SliderBar}), "Second")
                SliderBar.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
                SliderBar.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)
                function Slider:Set(Value)
                    self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    TweenService:Create(SliderDrag, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
                    SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                    SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                    SliderConfig.Callback(self.Value)
                end
                Slider:Set(Slider.Value)
                if SliderConfig.Flag then OrionLib.Flags[SliderConfig.Flag] = Slider end
                return Slider
            end
            return ElementFunction
        end
        local ElementFunction = {}
        function ElementFunction:AddSection(SectionConfig)
            SectionConfig.Name = SectionConfig.Name or "Section"
            local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,26), Parent = Container}), {AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {Size = UDim2.new(1,-12,0,16), Position = UDim2.new(0,0,0,3), Font = Enum.Font.GothamSemibold}), "TextDark"), SetChildren(SetProps(MakeElement("TFrame"), {AnchorPoint = Vector2.new(0,0), Size = UDim2.new(1,0,1,-24), Position = UDim2.new(0,0,0,23), Name = "Holder"}), {MakeElement("List", 0,6)})})
            AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() SectionFrame.Size = UDim2.new(1,0,0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31); SectionFrame.Holder.Size = UDim2.new(1,0,0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y) end)
            local SectionFunction = {}
            for i, v in pairs(GetElements(SectionFrame.Holder)) do SectionFunction[i] = v end
            return SectionFunction
        end
        for i, v in pairs(GetElements(Container)) do ElementFunction[i] = v end
        return ElementFunction
    end
    return TabFunction
end
function OrionLib:Destroy() Orion:Destroy() end
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local AIMBOT_ENABLED = false
local FOV_ANGLE = 15
local CIRCLE_RADIUS = 150
local SHOW_CIRCLE = true
local SEGMENTS = 360
local ESP_ENABLED = false
local ESP_SETTINGS = {
    Box = true,
    Name = true,
    Distance = true,
    Health = true,
}
local currentAimTarget = nil
local EXTRACT_ESP_ENABLED = false
local BOT_ESP_ENABLED = false
local NIGHT_VISION_ENABLED = false
local SPEED_BOOST_ENABLED = false
local HIGH_JUMP_ENABLED = false
local GRAVITY_CHANGED = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalGravity = Workspace.Gravity
local extractESPObjects = {}
local botESPObjects = {}
local function applyNightVision()
    if NIGHT_VISION_ENABLED then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.new(0.6, 0.8, 1.0)
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
    end
end
local function applySpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SPEED_BOOST_ENABLED and 22 or 16
        end
    end
end
local function applyJump()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = HIGH_JUMP_ENABLED and 75 or 50
        end
    end
end
local function applyGravity()
    Workspace.Gravity = GRAVITY_CHANGED and 150 or originalGravity
end
local function getTopScreenPos(part)
    local cf = part.CFrame
    local size = part.Size
    local half = size / 2
    local corners = {
        cf:PointToWorldSpace(Vector3.new(-half.X,  half.Y, -half.Z)),
        cf:PointToWorldSpace(Vector3.new( half.X,  half.Y, -half.Z)),
        cf:PointToWorldSpace(Vector3.new(-half.X,  half.Y,  half.Z)),
        cf:PointToWorldSpace(Vector3.new( half.X,  half.Y,  half.Z)),
    }
    local minX, minY = math.huge, math.huge
    local allBehind = true
    for _, p in ipairs(corners) do
        local vec, onScreen = Camera:WorldToViewportPoint(p)
        if onScreen then allBehind = false end
        if vec.X < minX then minX = vec.X end
        if vec.Y < minY then minY = vec.Y end
    end
    if allBehind then return nil end
    return Vector2.new(minX, minY)
end
local function scanExtractESP()
    for part, txt in pairs(extractESPObjects) do
        if not part.Parent or not string.find(part.Name, "Exit", 1, true) then
            txt:Remove()
            extractESPObjects[part] = nil
        end
    end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Terrain") and string.find(part.Name, "Exit", 1, true) then
            if not extractESPObjects[part] then
                local txt = Drawing.new("Text")
                txt.Size = 12
                txt.Color = Color3.fromRGB(0, 255, 0)
                txt.Center = true
                txt.Outline = true
                txt.OutlineColor = Color3.fromRGB(0,0,0)
                txt.Visible = true
                extractESPObjects[part] = txt
            end
        end
    end
end
local function scanBotESP()
    for part, txt in pairs(botESPObjects) do
        if not part.Parent or not string.find(part.Name, "Handle", 1, true) then
            txt:Remove()
            botESPObjects[part] = nil
        end
    end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Terrain") and string.find(part.Name, "Handle", 1, true) then
            if not botESPObjects[part] then
                local txt = Drawing.new("Text")
                txt.Size = 12
                txt.Color = Color3.fromRGB(0, 150, 255)
                txt.Center = true
                txt.Outline = true
                txt.OutlineColor = Color3.fromRGB(0,0,0)
                txt.Visible = true
                botESPObjects[part] = txt
            end
        end
    end
end
local function updateExtractBotESP()
    if not ScriptActive then return end
    local playerPos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position or Vector3.zero
    if EXTRACT_ESP_ENABLED then
        for part, txt in pairs(extractESPObjects) do
            if part.Parent then
                local topPos = getTopScreenPos(part)
                if topPos then
                    local dist = (part.Position - playerPos).Magnitude
                    txt.Position = Vector2.new(topPos.X, topPos.Y - 8)
                    txt.Text = part.Name .. "  " .. string.format("%.0fm", dist)
                    txt.Visible = true
                else
                    txt.Visible = false
                end
            end
        end
    else
        for _, txt in pairs(extractESPObjects) do txt.Visible = false end
    end
    if BOT_ESP_ENABLED then
        for part, txt in pairs(botESPObjects) do
            if part.Parent then
                local topPos = getTopScreenPos(part)
                if topPos then
                    local dist = (part.Position - playerPos).Magnitude
                    txt.Position = Vector2.new(topPos.X, topPos.Y - 8)
                    txt.Text = part.Name .. "  " .. string.format("%.0fm", dist)
                    txt.Visible = true
                else
                    txt.Visible = false
                end
            end
        end
    else
        for _, txt in pairs(botESPObjects) do txt.Visible = false end
    end
end
local COLORS = {
    Color3.fromRGB(255,0,0),
    Color3.fromRGB(255,127,0),
    Color3.fromRGB(255,255,0),
    Color3.fromRGB(0,255,0),
    Color3.fromRGB(0,255,255),
    Color3.fromRGB(0,0,255),
    Color3.fromRGB(127,0,255)
}
local colorIndex = 1
local FovGui = Instance.new("ScreenGui")
FovGui.Name = "FOVCircle"
FovGui.Parent = game:GetService("CoreGui")
FovGui.IgnoreGuiInset = true
local lines = {}
for i = 1, SEGMENTS do
    local l = Instance.new("Frame")
    l.Size = UDim2.new(0, 1, 0, 1)
    l.BackgroundColor3 = COLORS[1]
    l.BorderSizePixel = 0
    l.Visible = false
    l.Parent = FovGui
    lines[i] = l
end
local function applyFovColor(col)
    for _, l in ipairs(lines) do l.BackgroundColor3 = col end
end
task.spawn(function()
    while true do
        if not ScriptActive then break end
        if AIMBOT_ENABLED then
            colorIndex = colorIndex % #COLORS + 1
            applyFovColor(COLORS[colorIndex])
        end
        task.wait(1)
    end
end)
local function updateCircle()
    if not ScriptActive then return end
    if not SHOW_CIRCLE or not AIMBOT_ENABLED then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end
    local center = Camera.ViewportSize / 2
    for i = 1, SEGMENTS do
        local a = (i - 1) / SEGMENTS * 2 * math.pi
        local px = center.X + math.cos(a) * CIRCLE_RADIUS
        local py = center.Y + math.sin(a) * CIRCLE_RADIUS
        lines[i].Position = UDim2.new(0, px, 0, py)
        lines[i].Visible = true
    end
end
local AimLineGui = Instance.new("ScreenGui")
AimLineGui.Name = "AimLine"
AimLineGui.Parent = game:GetService("CoreGui")
AimLineGui.IgnoreGuiInset = true
local AimLine = Instance.new("Frame")
AimLine.Size = UDim2.new(0, 0, 0, 1)
AimLine.AnchorPoint = Vector2.new(0.5, 0.5)
AimLine.BackgroundColor3 = COLORS[1]
AimLine.BorderSizePixel = 0
AimLine.Visible = false
AimLine.Parent = AimLineGui
local function updateAimLineColor()
    if ScriptActive and AIMBOT_ENABLED then
        AimLine.BackgroundColor3 = COLORS[colorIndex]
    end
end
task.spawn(function()
    while true do
        if not ScriptActive then break end
        updateAimLineColor()
        task.wait(1)
    end
end)
local function updateAimLine()
    if not ScriptActive then return end
    if not AIMBOT_ENABLED then
        AimLine.Visible = false
        return
    end
    if currentAimTarget then
        local screenPos, onScreen = Camera:WorldToViewportPoint(currentAimTarget.Position)
        if not onScreen then
            AimLine.Visible = false
            return
        end
        local center = Camera.ViewportSize / 2
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local delta = targetPos - center
        local length = delta.Magnitude
        if length < 1 then
            AimLine.Visible = false
            return
        end
        AimLine.Size = UDim2.new(0, length, 0, 1)
        AimLine.Position = UDim2.new(0, center.X, 0, center.Y)
        AimLine.Rotation = math.deg(math.atan2(delta.Y, delta.X))
        AimLine.Visible = true
    else
        AimLine.Visible = false
    end
end
local meta = getrawmetatable(game)
local old = meta.__namecall
setreadonly(meta, false)
meta.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if (method == "Raycast" or method == "FindPartOnRay") and not checkcaller() and self == Workspace then
        if not ScriptActive or not AIMBOT_ENABLED then
            currentAimTarget = nil
            return old(self, ...)
        end
        local origin, direction
        if method == "Raycast" then
            origin = args[1]
            direction = args[2]
        else
            local ray = args[1]
            if typeof(ray) == "Ray" then
                origin = ray.Origin
                direction = ray.Direction
            end
        end
        if origin and direction then
            local cameraPos = Camera.CFrame.Position
            local lookVec = Camera.CFrame.LookVector
            local bestTarget = nil
            local bestAngle = math.huge
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local char = plr.Character
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if head and hum and hum.Health > 0 and not char:FindFirstChild("ForceField") then
                        local dir = (head.Position - cameraPos).Unit
                        local dot = lookVec:Dot(dir)
                        if dot > 1 then dot = 1 elseif dot < -1 then dot = -1 end
                        local angle = math.deg(math.acos(dot))
                        if angle <= FOV_ANGLE then
                            if angle < bestAngle then
                                bestAngle = angle
                                bestTarget = head
                            end
                        end
                    end
                end
            end
            if bestTarget then
                currentAimTarget = bestTarget
                local hitPos = bestTarget.Position
                return {
                    Instance = bestTarget,
                    Position = hitPos,
                    Normal = (hitPos - origin).Unit,
                    Material = Enum.Material.Plastic,
                    Distance = (hitPos - origin).Magnitude
                }
            else
                currentAimTarget = nil
            end
        end
    end
    return old(self, ...)
end)
setreadonly(meta, true)
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.Parent = game:GetService("CoreGui")
ESPGui.IgnoreGuiInset = true
local MAX_PLAYERS = 50
local BoxPool = {}
local NamePool = {}
local DistPool = {}
local HealthTextPool = {}
local function createLine(parent)
    local l = Instance.new("Frame")
    l.Size = UDim2.new(0,0,0,0)
    l.BackgroundColor3 = COLORS[1]
    l.BorderSizePixel = 0
    l.Parent = parent
    return l
end
local function createLabel(parent)
    local lb = Instance.new("TextLabel")
    lb.BackgroundTransparency = 1
    lb.Text = ""
    lb.TextColor3 = COLORS[1]
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 13
    lb.Parent = parent
    return lb
end
for i = 1, MAX_PLAYERS do
    local boxLines = {}
    for j = 1, 4 do 
        boxLines[j] = createLine(ESPGui)
    end
    BoxPool[i] = boxLines
    NamePool[i] = createLabel(ESPGui)
    DistPool[i] = createLabel(ESPGui)
    HealthTextPool[i] = createLabel(ESPGui)
end
local function updateESPColors()
    if not ScriptActive then return end
    local col = COLORS[colorIndex]
    for i = 1, MAX_PLAYERS do
        for _, line in ipairs(BoxPool[i]) do
            line.BackgroundColor3 = col
        end
        NamePool[i].TextColor3 = col
        DistPool[i].TextColor3 = col
        HealthTextPool[i].TextColor3 = col
    end
end
task.spawn(function()
    while true do
        if not ScriptActive then break end
        updateESPColors()
        task.wait(1)
    end
end)
local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    if not onScreen then return nil end
    return Vector2.new(screenPos.X, screenPos.Y)
end
local function getPreciseBoundingBox(character)
    local parts = character:GetDescendants()
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    local hasPart = false
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            hasPart = true
            local cf = part.CFrame
            local size = part.Size / 2
            local corners = {
                cf * Vector3.new(-size.X, -size.Y, -size.Z),
                cf * Vector3.new( size.X, -size.Y, -size.Z),
                cf * Vector3.new(-size.X,  size.Y, -size.Z),
                cf * Vector3.new( size.X,  size.Y, -size.Z),
                cf * Vector3.new(-size.X, -size.Y,  size.Z),
                cf * Vector3.new( size.X, -size.Y,  size.Z),
                cf * Vector3.new(-size.X,  size.Y,  size.Z),
                cf * Vector3.new( size.X,  size.Y,  size.Z)
            }
            for _, corner in ipairs(corners) do
                if corner.X < minX then minX = corner.X end
                if corner.Y < minY then minY = corner.Y end
                if corner.Z < minZ then minZ = corner.Z end
                if corner.X > maxX then maxX = corner.X end
                if corner.Y > maxY then maxY = corner.Y end
                if corner.Z > maxZ then maxZ = corner.Z end
            end
        end
    end
    if not hasPart then return nil end
    local center = Vector3.new((minX+maxX)/2, (minY+maxY)/2, (minZ+maxZ)/2)
    local size = Vector3.new(maxX-minX, maxY-minY, maxZ-minZ)
    local screenCorners = {}
    local corners = {
        center + Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
        center + Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
        center + Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
        center + Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
        center + Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
        center + Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
        center + Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
        center + Vector3.new( size.X/2,  size.Y/2,  size.Z/2)
    }
    for _, corner in ipairs(corners) do
        local screen = worldToScreen(corner)
        if not screen then return nil end
        table.insert(screenCorners, screen)
    end
    local minX2, minY2 = math.huge, math.huge
    local maxX2, maxY2 = -math.huge, -math.huge
    for _, sp in ipairs(screenCorners) do
        if sp.X < minX2 then minX2 = sp.X end
        if sp.Y < minY2 then minY2 = sp.Y end
        if sp.X > maxX2 then maxX2 = sp.X end
        if sp.Y > maxY2 then maxY2 = sp.Y end
    end
    return {topLeft = Vector2.new(minX2, minY2), bottomRight = Vector2.new(maxX2, maxY2)}
end
local function updateESP()
    if not ScriptActive then return end
    for i = 1, MAX_PLAYERS do
        for _, line in ipairs(BoxPool[i]) do line.Visible = false end
        NamePool[i].Visible = false
        DistPool[i].Visible = false
        HealthTextPool[i].Visible = false
    end
    if not ESP_ENABLED then return end
    local players = Players:GetPlayers()
    local usedIndex = 0
    for _, plr in ipairs(players) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        usedIndex = usedIndex + 1
        if usedIndex > MAX_PLAYERS then break end
        local bbox = getPreciseBoundingBox(char)
        if not bbox then continue end
        local minX = bbox.topLeft.X
        local minY = bbox.topLeft.Y
        local maxX = bbox.bottomRight.X
        local maxY = bbox.bottomRight.Y
        local centerX = (minX + maxX) / 2
        if ESP_SETTINGS.Box then
            local lines = BoxPool[usedIndex]
            local thickness = 1.5
            lines[1].Size = UDim2.new(0, maxX - minX, 0, thickness)
            lines[1].Position = UDim2.new(0, minX, 0, minY)
            lines[2].Size = UDim2.new(0, maxX - minX, 0, thickness)
            lines[2].Position = UDim2.new(0, minX, 0, maxY - thickness)
            lines[3].Size = UDim2.new(0, thickness, 0, maxY - minY)
            lines[3].Position = UDim2.new(0, minX, 0, minY)
            lines[4].Size = UDim2.new(0, thickness, 0, maxY - minY)
            lines[4].Position = UDim2.new(0, maxX - thickness, 0, minY)
            for _, l in ipairs(lines) do l.Visible = true end
        end
        if ESP_SETTINGS.Name then
            local label = NamePool[usedIndex]
            label.Text = plr.Name
            label.AnchorPoint = Vector2.new(0, 1)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Position = UDim2.new(0, centerX + 2, 0, minY - 2)
            label.Visible = true
        end
        if ESP_SETTINGS.Distance then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                local label = DistPool[usedIndex]
                label.Text = string.format("%.1f M", dist)
                label.AnchorPoint = Vector2.new(0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Position = UDim2.new(0, centerX + 2, 0, maxY + 2)
                label.Visible = true
            end
        end
        if ESP_SETTINGS.Health then
            local health = hum.Health
            local maxHealth = hum.MaxHealth
            local label = HealthTextPool[usedIndex]
            label.Text = string.format("%.0f HP", health)
            label.AnchorPoint = Vector2.new(0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Position = UDim2.new(0, centerX + 2, 0, maxY + 16)
            label.Visible = true
        end
    end
end
local LBLG = Instance.new("ScreenGui")
LBLG.Name = "LBLG"; LBLG.Parent = game:GetService("CoreGui"); LBLG.Enabled = true
LBLG.IgnoreGuiInset = true
local LBL = Instance.new("TextLabel")
LBL.Name = "LBL"; LBL.Parent = LBLG
LBL.BackgroundTransparency = 1; LBL.Position = UDim2.new(0.75,0,0.01,0); LBL.Size = UDim2.new(0,180,0,30)
LBL.Font = Enum.Font.GothamSemibold; LBL.Text = ""; LBL.TextColor3 = Color3.new(155,155,155); LBL.TextScaled = true; LBL.TextSize = 14; LBL.Visible = true
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSDisplay"
FPSLabel.Parent = LBLG
FPSLabel.BackgroundTransparency = 1
FPSLabel.Position = UDim2.new(0.75, 0, 0.065, 0)
FPSLabel.Size = UDim2.new(0, 180, 0, 25)
FPSLabel.Font = Enum.Font.GothamSemibold
FPSLabel.TextColor3 = Color3.new(155,155,155)
FPSLabel.TextScaled = true
FPSLabel.TextSize = 14
FPSLabel.Visible = true
local frameCount = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    if not ScriptActive then return end
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        FPSLabel.Text = "FPS: " .. frameCount
        frameCount = 0
        lastTime = now
    end
end)
task.spawn(function()
    while true do
        if not ScriptActive then break end
        LBL.Text = "当前时间:"..os.date("%H").."时"..os.date("%M").."分"..os.date("%S")
        task.wait(1)
    end
end)
RunService.RenderStepped:Connect(function()
    if not ScriptActive then return end
    updateCircle()
    updateAimLine()
    updateESP()
    updateExtractBotESP()
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applySpeed()
    applyJump()
    if EXTRACT_ESP_ENABLED then scanExtractESP() end
    if BOT_ESP_ENABLED then scanBotESP() end
end)
coroutine.wrap(function()
    while ScriptActive do
        task.wait(2)
        if EXTRACT_ESP_ENABLED then scanExtractESP() end
        if BOT_ESP_ENABLED then scanBotESP() end
    end
end)()
local Window = OrionLib:MakeWindow({
    Name = "BN辅助",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "正在加载脚本",
    ConfigFolder = "文件存放名"
})
local Tab = Window:MakeTab({Name = "主页", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Tab:AddParagraph("作者", "张智杰")
Tab:AddParagraph("项目三角洲辅助")
local DrawTab = Window:MakeTab({Name = "主要", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FovSection = DrawTab:AddSection({Name = "子追"})
FovSection:AddToggle({
    Name = "子追初始化",
    Default = false,
    Callback = function(v)
        AIMBOT_ENABLED = v
        OrionLib:MakeNotification({Name = "子追", Content = (v and "已开启" or "已关闭"), Time = 1.5})
    end
})
FovSection:AddToggle({
    Name = "显示圆圈",
    Default = true,
    Callback = function(v)
        SHOW_CIRCLE = v
        OrionLib:MakeNotification({Name = "圆圈", Content = (v and "已显示" or "已隐藏"), Time = 1.5})
    end
})
local FuncSection = DrawTab:AddSection({Name = "功能"})
FuncSection:AddToggle({
    Name = "加速",
    Default = false,
    Callback = function(v)
        SPEED_BOOST_ENABLED = v
        applySpeed()
        OrionLib:MakeNotification({Name = "加速", Content = (v and "已开启" or "已关闭"), Time = 1.5})
    end
})
FuncSection:AddToggle({
    Name = "高跳",
    Default = false,
    Callback = function(v)
        HIGH_JUMP_ENABLED = v
        applyJump()
        OrionLib:MakeNotification({Name = "高跳", Content = (v and "已开启" or "已关闭"), Time = 1.5})
    end
})
FuncSection:AddToggle({
    Name = "夜视",
    Default = false,
    Callback = function(v)
        NIGHT_VISION_ENABLED = v
        applyNightVision()
        OrionLib:MakeNotification({Name = "夜视", Content = (v and "已开启" or "已关闭"), Time = 1.5})
    end
})
FuncSection:AddToggle({
    Name = "重力",
    Default = false,
    Callback = function(v)
        GRAVITY_CHANGED = v
        applyGravity()
        OrionLib:MakeNotification({Name = "重力", Content = (v and "已设为150" or "已恢复默认"), Time = 1.5})
    end
})
local EspSection = DrawTab:AddSection({Name = "绘制"})
EspSection:AddToggle({
    Name = "绘制初始化",
    Default = false,
    Callback = function(v)
        ESP_ENABLED = v
        OrionLib:MakeNotification({Name = "绘制", Content = (v and "已开启" or "已关闭"), Time = 1.5})
    end
})
EspSection:AddToggle({
    Name = "方框",
    Default = true,
    Callback = function(v)
        ESP_SETTINGS.Box = v
        OrionLib:MakeNotification({Name = "方框", Content = (v and "已显示" or "已隐藏"), Time = 1.5})
    end
})
EspSection:AddToggle({
    Name = "名字",
    Default = true,
    Callback = function(v)
        ESP_SETTINGS.Name = v
        OrionLib:MakeNotification({Name = "名字", Content = (v and "已显示" or "已隐藏"), Time = 1.5})
    end
})
EspSection:AddToggle({
    Name = "距离",
    Default = true,
    Callback = function(v)
        ESP_SETTINGS.Distance = v
        OrionLib:MakeNotification({Name = "距离", Content = (v and "已显示" or "已隐藏"), Time = 1.5})
    end
})
EspSection:AddToggle({
    Name = "血量",
    Default = true,
    Callback = function(v)
        ESP_SETTINGS.Health = v
        OrionLib:MakeNotification({Name = "血量", Content = (v and "已显示" or "已隐藏"), Time = 1.5})
    end
})
EspSection:AddToggle({
    Name = "机器人",
    Default = false,
    Callback = function(v)
        BOT_ESP_ENABLED = v
        if v then scanBotESP() end
        OrionLib:MakeNotification({Name = "机器人", Content = (v and "已开启" or "已关闭"), Time = 1.5})
    end
})
EspSection:AddToggle({
    Name = "撤离点",
    Default = false,
    Callback = function(v)
        EXTRACT_ESP_ENABLED = v
        if v then scanExtractESP() end
        OrionLib:MakeNotification({Name = "撤离点", Content = (v and "已开启" or "已关闭"), Time = 1.5})
    end
})
OrionLib:MakeNotification({Name = "正在开启反挂机请稍等...", Content = "反挂机 开启中...", Time = 2})
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
OrionLib:MakeNotification({Name = "开启成功", Content = "反挂机", Time = 1})
OrionLib:MakeNotification({Name = "正在开启反TCP请稍等...", Content = "反TCP 开启中...", Time = 2})
if game:GetService("NetworkClient"):IsConnected() then
    game:GetService("NetworkClient"):Disconnect()
end
OrionLib:MakeNotification({Name = "开启成功", Content = "反TCP", Time = 2})
applySpeed()
applyJump()
applyGravity()
applyNightVision()