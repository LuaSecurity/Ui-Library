local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

local Username = "anonymous_800"
if LocalPlayer then
    if LocalPlayer.DisplayName and LocalPlayer.DisplayName ~= LocalPlayer.Name then
        Username = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
    else
        Username = LocalPlayer.Name
    end
end

local Ui = {}

local IconsURL = "https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/refs/heads/main/Src/Modules/Icons.luau"
local Icons = {}
local success, result = pcall(function()
    return loadstring(game:HttpGet(IconsURL))()
end)
if success and result then
    Icons = result
end

local ConfigFolder = "dihware_configs"
local CoreSettingsFile = ConfigFolder .. "/dihware_core_settings.json"

local function SaveFile(name, data)
    pcall(function()
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        writefile(ConfigFolder .. "/" .. name .. ".cfg", data)
    end)
end

local function LoadFile(name)
    local data = nil
    pcall(function()
        if isfile(ConfigFolder .. "/" .. name .. ".cfg") then
            data = readfile(ConfigFolder .. "/" .. name .. ".cfg")
        end
    end)
    return data
end

local function DeleteFile(name)
    pcall(function()
        if isfile(ConfigFolder .. "/" .. name .. ".cfg") then
            delfile(ConfigFolder .. "/" .. name .. ".cfg")
        end
    end)
end

local function ListFiles()
    local files = {}
    pcall(function()
        if isfolder(ConfigFolder) then
            for _, file in ipairs(listfiles(ConfigFolder)) do
                if file:match("%.cfg$") then
                    local fileName = file:match("([^/\\]+)%.cfg$")
                    if fileName then table.insert(files, fileName) end
                end
            end
        end
    end)
    return files
end

local Theme = {
    Background = Color3.fromRGB(13, 14, 18),
    Panel = Color3.fromRGB(18, 19, 25),
    Element = Color3.fromRGB(24, 25, 33),
    ElementHover = Color3.fromRGB(20, 21, 28),
    Accent = Color3.fromRGB(0, 110, 255),
    Text = Color3.fromRGB(80, 75, 85),
    TextMuted = Color3.fromRGB(90, 95, 105),
    TextDark = Color3.fromRGB(90, 95, 105),
    Divider = Color3.fromRGB(28, 29, 38),
    Danger = Color3.fromRGB(255, 75, 75)
}

local NotificationGradients = {
    white = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))}),
    red = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 75, 75)), ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))}),
    blue = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 110, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 60, 180))}),
    green = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 200, 80)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 140, 50))}),
    yellow = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 210, 50)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 150, 20))})
}

local CurrentFont = Enum.Font.GothamBold

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then inst[k] = v end
    end
    if properties.Parent then inst.Parent = properties.Parent end
    return inst
end

local function MakeDraggable(topbarobject, object)
    local dragging, dragInput, dragStart, startPos
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function AnimateSeamlessGradient(gradient)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.4, 0.45, 0.55)),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    })
    gradient.Offset = Vector2.new(-1, 0)
    local tween = TweenService:Create(gradient, TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), {Offset = Vector2.new(1, 0)})
    tween:Play()
    return tween
end

local function Capitalize(str)
    if type(str) ~= "string" then return tostring(str) end
    return string.gsub(str, "(%a)([%w_']*)", function(f, r)
        return string.upper(f) .. r
    end)
end

function Ui:Unload()
    if CoreGui:FindFirstChild("dihwareUI") then CoreGui.dihwareUI:Destroy() end
end

function Ui:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Title or "dihware"

    Ui:Unload()

    local ScreenGui = Create("ScreenGui", { 
        Name = "dihwareUI", 
        Parent = CoreGui, 
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, 
        IgnoreGuiInset = true 
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = ScreenGui,
        Size = UDim2.new(0, 750, 0, 600), Position = UDim2.new(0.5, -375, 0.5, -300),
        BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Active = true,
        ClipsDescendants = true, ZIndex = 1
    })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 10) })
    
    local ResizeHandle = Create("TextButton", {
        Name = "ResizeHandle", Parent = MainFrame,
        Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 100
    })
    
    for i = 1, 3 do
        Create("Frame", {
            Parent = ResizeHandle, Size = UDim2.new(0, 4 + (i * 3), 0, 2),
            Position = UDim2.new(1, -6, 1, -4 - (i * 4)), AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Theme.TextMuted, BorderSizePixel = 0, ZIndex = 101
        })
    end

    local draggingResize = false
    local resizeStartPos, resizeStartSize

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingResize = true
            resizeStartPos = input.Position
            resizeStartSize = MainFrame.AbsoluteSize
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingResize and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStartPos
            local newWidth = math.clamp(resizeStartSize.X + delta.X, 450, 1200)
            local newHeight = math.clamp(resizeStartSize.Y + delta.Y, 350, 900)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingResize = false
        end
    end)

    local LoadingOverlay = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background, ZIndex = 9999
    })
    Create("UICorner", { Parent = LoadingOverlay, CornerRadius = UDim.new(0, 10) })
    
    local LoadingTitle = Create("TextLabel", {
        Parent = LoadingOverlay, Size = UDim2.new(1, 0, 0, 40), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -15), BackgroundTransparency = 1,
        Font = CurrentFont, TextSize = 28, TextColor3 = Color3.new(1, 1, 1), Text = Capitalize(Title),
        ZIndex = 10000, TextTransparency = 1
    })
    
    local LoadTitleGradient = Create("UIGradient", { Parent = LoadingTitle })
    AnimateSeamlessGradient(LoadTitleGradient)

    local LoadingSubtitle = Create("TextLabel", {
        Parent = LoadingOverlay, Size = UDim2.new(1, 0, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 10), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.TextMuted, Text = Capitalize("Initializing environment..."),
        ZIndex = 10000, TextTransparency = 1
    })

    local LoadingBarBg = Create("Frame", {
        Parent = LoadingOverlay, Size = UDim2.new(0, 220, 0, 3), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 35), BackgroundColor3 = Theme.Element, ZIndex = 10000, BackgroundTransparency = 1
    })
    Create("UICorner", { Parent = LoadingBarBg, CornerRadius = UDim.new(1, 0) })

    local LoadingBarFill = Create("Frame", {
        Parent = LoadingBarBg, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, ZIndex = 10001, BackgroundTransparency = 1
    })
    Create("UICorner", { Parent = LoadingBarFill, CornerRadius = UDim.new(1, 0) })

    task.spawn(function()
        TweenService:Create(LoadingTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, -25)}):Play()
        task.wait(0.2)
        TweenService:Create(LoadingSubtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, -2)}):Play()
        TweenService:Create(LoadingBarBg, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
        TweenService:Create(LoadingBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
        
        task.wait(0.3)
        TweenService:Create(LoadingBarFill, TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(1.4)
        
        TweenService:Create(LoadingOverlay, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        TweenService:Create(LoadingTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        TweenService:Create(LoadingSubtitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        TweenService:Create(LoadingBarBg, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        TweenService:Create(LoadingBarFill, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.4)
        LoadingOverlay:Destroy()
        
        pcall(function()
            local url = "https://cdn.discordapp.com/attachments/1455351271740539145/1476690209805570261/gta_noti_sound.mp3?ex=69a4ad6d&is=69a35bed&hm=0b9c51dccbc8abf7a5c486f7d73d7e2964809ae66c781bbd4f2932750b927c10&"
            local file = "dihware_startup.mp3"
            if not isfile(file) then writefile(file, game:HttpGet(url)) end
            local snd = Instance.new("Sound")
            snd.SoundId = getcustomasset(file)
            snd.Volume = 1
            snd.Parent = CoreGui
            snd:Play()
            snd.Ended:Connect(function() snd:Destroy() end)
        end)
    end)

    local Header = Create("Frame", {
        Name = "Header", Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, ZIndex = 10
    })
    MakeDraggable(Header, MainFrame)

    local TitleLabel = Create("TextLabel", {
        Parent = Header, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
        Font = CurrentFont, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), Text = Capitalize(Title),
        AutomaticSize = Enum.AutomaticSize.X
    })
    
    local MainTitleGradient = Create("UIGradient", { Parent = TitleLabel })
    AnimateSeamlessGradient(MainTitleGradient)

    Create("TextLabel", {
        Parent = Header, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(1, -165, 0, 0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11,
        Font = CurrentFont, TextSize = 12, TextColor3 = Theme.TextDark, Text = Username
    })

    Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 60), BackgroundColor3 = Theme.Divider, BorderSizePixel = 0, ZIndex = 10 })

    local TabBar = Create("Frame", {
        Name = "TabBar", Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 61),
        BackgroundColor3 = Theme.Background, BorderSizePixel = 0, ZIndex = 10
    })

    local TabContainer = Create("Frame", {
        Name = "TabContainer", Parent = TabBar,
        Size = UDim2.new(0, 0, 0, 44), Position = UDim2.new(0, 20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0, ZIndex = 12,
        AutomaticSize = Enum.AutomaticSize.X
    })
    Create("UICorner", { Parent = TabContainer, CornerRadius = UDim.new(0, 8) })

    local ActiveIndicator = Create("Frame", {
        Parent = TabContainer, BackgroundColor3 = Theme.Element,
        Size = UDim2.new(0, 44, 1, -10), Position = UDim2.new(0, 5, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 1
    })
    Create("UICorner", { Parent = ActiveIndicator, CornerRadius = UDim.new(0, 6) })

    local TabList = Create("Frame", {
        Name = "TabList", Parent = TabContainer,
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 2
    })
    Create("UIPadding", { Parent = TabList, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) })
    Create("UIListLayout", { Parent = TabList, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = 2 })

    local ContentContainer = Create("Frame", {
        Name = "Content", Parent = MainFrame,
        Size = UDim2.new(1, -40, 1, -145), Position = UDim2.new(0, 20, 0, 130), BackgroundTransparency = 1, ZIndex = 5
    })

    local NotificationContainer = Create("Frame", {
        Name = "NotificationContainer", Parent = ScreenGui, Size = UDim2.new(0, 400, 1, -40),
        Position = UDim2.new(0, 15, 0, 20), AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1, ZIndex = 5000
    })
    Create("UIListLayout", {
        Parent = NotificationContainer, SortOrder = 2,
        VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 10)
    })

    local TooltipGui = Create("Frame", { Parent = ScreenGui, Size = UDim2.new(0, 200, 0, 30), BackgroundColor3 = Theme.Element, ZIndex = 2000, Visible = false, AutomaticSize = Enum.AutomaticSize.XY })
    Create("UICorner", { Parent = TooltipGui, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = TooltipGui, Color = Theme.Divider, Thickness = 1 })
    Create("UIPadding", { Parent = TooltipGui, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
    local TooltipText = Create("TextLabel", { Parent = TooltipGui, Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, ZIndex = 2001, Font = CurrentFont, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY })

    RunService.RenderStepped:Connect(function()
        if TooltipGui.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            TooltipGui.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 15)
        end
    end)

    local function ShowTooltip(text)
        TooltipText.Text = Capitalize(text)
        TooltipGui.Visible = true
        TooltipGui.BackgroundTransparency = 1
        TooltipText.TextTransparency = 1
        TweenService:Create(TooltipGui, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(TooltipText, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    end
    local function HideTooltip() TooltipGui.Visible = false end

    local CloseOverlay = Create("TextButton", { Parent = ScreenGui, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 1500, Visible = false })

    local ModalOverlay = Create("TextButton", {
        Parent = ScreenGui, Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.5,
        Text = "", ZIndex = 3000, Visible = false, AutoButtonColor = false
    })

    local ContextMenu = Create("Frame", {
        Parent = ModalOverlay, Size = UDim2.new(0, 180, 0, 85),
        BackgroundColor3 = Theme.Panel, ZIndex = 3001
    })
    Create("UICorner", { Parent = ContextMenu, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = ContextMenu, Color = Theme.Divider, Thickness = 1 })
    Create("UIListLayout", { Parent = ContextMenu, SortOrder = 2, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })

    local CtxKeybindBtn = Create("TextButton", {
        Parent = ContextMenu, Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Theme.Element, ZIndex = 3002, Font = CurrentFont, TextSize = 12, TextColor3 = Theme.Text, Text = Capitalize("None"), AutoButtonColor = false
    })
    Create("UICorner", { Parent = CtxKeybindBtn, CornerRadius = UDim.new(0, 6) })

    local CtxModeBtn = Create("TextButton", {
        Parent = ContextMenu, Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Theme.Element, ZIndex = 3002, Font = CurrentFont, TextSize = 12, TextColor3 = Theme.Text, Text = Capitalize("Toggle"), AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("UICorner", { Parent = CtxModeBtn, CornerRadius = UDim.new(0, 6) })
    Create("UIPadding", { Parent = CtxModeBtn, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
    
    local CtxChevron = Create("TextLabel", {
        Parent = CtxModeBtn, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1, ZIndex = 3003, Font = CurrentFont, TextSize = 12, TextColor3 = Theme.TextMuted, Text = "v", TextXAlignment = Enum.TextXAlignment.Right
    })

    local CtxModeList = Create("Frame", {
        Parent = ModalOverlay, Size = UDim2.new(0, 170, 0, 0),
        BackgroundColor3 = Theme.Element, ZIndex = 3010, Visible = false, ClipsDescendants = true
    })
    Create("UICorner", { Parent = CtxModeList, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = CtxModeList, Color = Theme.Divider, Thickness = 1 })
    local CtxModeListLayout = Create("UIListLayout", { Parent = CtxModeList, SortOrder = 2 })

    local ActiveContextConfig = nil
    local Modes = {"Always", "Toggle", "Hold", "Click"}

    for _, mode in ipairs(Modes) do
        local btn = Create("TextButton", {
            Parent = CtxModeList, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1,
            Font = CurrentFont, TextSize = 12, TextColor3 = Theme.TextMuted, Text = Capitalize(mode), ZIndex = 3011
        })
        btn.MouseButton1Click:Connect(function()
            if ActiveContextConfig then
                ActiveContextConfig.Mode = mode
                CtxModeBtn.Text = Capitalize(mode)
                ActiveContextConfig.UpdateSave()
                CtxModeList.Visible = false
                CtxChevron.Rotation = 0
            end
        end)
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Theme.TextMuted}):Play() end)
    end

    CtxModeListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if CtxModeList.Visible then
            CtxModeList.Size = UDim2.new(0, 170, 0, CtxModeListLayout.AbsoluteContentSize.Y)
        end
    end)

    CtxModeBtn.MouseButton1Click:Connect(function()
        local open = not CtxModeList.Visible
        if open then
            CtxModeList.Position = UDim2.new(0, CtxModeBtn.AbsolutePosition.X - ModalOverlay.AbsolutePosition.X, 0, CtxModeBtn.AbsolutePosition.Y - ModalOverlay.AbsolutePosition.Y + CtxModeBtn.AbsoluteSize.Y + 4)
            CtxModeList.Size = UDim2.new(0, CtxModeBtn.AbsoluteSize.X, 0, CtxModeListLayout.AbsoluteContentSize.Y)
            CtxModeList.Visible = true
            CtxChevron.Rotation = 180
        else
            CtxModeList.Visible = false
            CtxChevron.Rotation = 0
        end
    end)

    local isBinding = false
    CtxKeybindBtn.MouseButton1Click:Connect(function()
        isBinding = true
        CtxKeybindBtn.Text = "..."
        TweenService:Create(CtxKeybindBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextMuted}):Play()
    end)

    UserInputService.InputBegan:Connect(function(input)
        if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
            isBinding = false
            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                ActiveContextConfig.Key = Enum.KeyCode.Unknown
            else
                ActiveContextConfig.Key = input.KeyCode
            end
            CtxKeybindBtn.Text = Capitalize(ActiveContextConfig.Key == Enum.KeyCode.Unknown and "None" or ActiveContextConfig.Key.Name)
            TweenService:Create(CtxKeybindBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            ActiveContextConfig.UpdateSave()
        end
    end)

    ModalOverlay.MouseButton1Click:Connect(function()
        if CtxModeList.Visible then
            CtxModeList.Visible = false
            CtxChevron.Rotation = 0
        else
            ModalOverlay.Visible = false
            isBinding = false
            CtxKeybindBtn.Text = Capitalize(ActiveContextConfig.Key == Enum.KeyCode.Unknown and "None" or ActiveContextConfig.Key.Name)
            TweenService:Create(CtxKeybindBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        end
    end)

    local function OpenContextMenu(config, mousePos)
        ActiveContextConfig = config
        isBinding = false
        CtxKeybindBtn.TextColor3 = Theme.Text
        CtxKeybindBtn.Text = Capitalize(config.Key == Enum.KeyCode.Unknown and "None" or config.Key.Name)
        CtxModeBtn.Text = Capitalize(config.Mode)
        CtxModeList.Visible = false
        CtxChevron.Rotation = 0

        ContextMenu.AnchorPoint = Vector2.new(0, 0)
        local cSize = ContextMenu.AbsoluteSize
        local sSize = ScreenGui.AbsoluteSize
        local safeX = math.clamp(mousePos.X, 0, sSize.X - cSize.X - 10)
        local safeY = math.clamp(mousePos.Y - 36, 0, sSize.Y - cSize.Y - 10)
        
        ContextMenu.Position = UDim2.new(0, safeX, 0, safeY)
        ModalOverlay.Visible = true
    end

    local WindowObj = { 
        Tabs = {}, 
        CurrentTab = nil, 
        Flags = {}, 
        Elements = {},
        ToggleKey = Enum.KeyCode.RightShift,
        DropdownContainers = {},
        TabCount = 0
    }

    local oldClose = CloseMenus
    local function CloseMenus()
        if oldClose then oldClose() end
        CloseOverlay.Visible = false
        for _, obj in pairs(WindowObj.DropdownContainers) do
            if obj.Container.Visible then
                TweenService:Create(obj.Container, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                TweenService:Create(obj.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 60)}):Play()
                obj.Chevron.Rotation = 0
                task.delay(0.2, function() obj.Container.Visible = false end)
            end
        end
    end
    CloseOverlay.MouseButton1Click:Connect(CloseMenus)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == WindowObj.ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    RunService.RenderStepped:Connect(function()
        if WindowObj.CurrentTab and WindowObj.Tabs[WindowObj.CurrentTab] then
            local activeBtn = WindowObj.Tabs[WindowObj.CurrentTab].Button
            if activeBtn then
                local targetX = activeBtn.AbsolutePosition.X - TabContainer.AbsolutePosition.X
                local targetWidth = activeBtn.AbsoluteSize.X
                ActiveIndicator.Position = ActiveIndicator.Position:Lerp(UDim2.new(0, targetX, 0.5, 0), 0.35)
                ActiveIndicator.Size = ActiveIndicator.Size:Lerp(UDim2.new(0, targetWidth, 1, -10), 0.35)
            end
        end
    end)

    function WindowObj:Notify(Config)
        local Content = Config.Content or Config.Title or "Notification"
        local Duration = Config.Duration or 3
        local NotifType = Config.Type and string.lower(Config.Type) or "blue"
        local CurrentGradient = NotificationGradients[NotifType] or NotificationGradients.blue
        
        local textSize = TextService:GetTextSize(Content, 12, CurrentFont, Vector2.new(9999, 20))
        local notifWidth = math.max(200, textSize.X + 30)
        local targetHeight = 45

        local NotifFrame = Create("Frame", {
            Parent = NotificationContainer, Size = UDim2.new(0, 0, 0, targetHeight),
            BackgroundColor3 = Theme.Panel, ClipsDescendants = true, ZIndex = 5001
        })
        Create("UICorner", { Parent = NotifFrame, CornerRadius = UDim.new(0, 6) })
        Create("UIStroke", { Parent = NotifFrame, Color = Theme.Divider, Thickness = 1 })

        local ContentWrapper = Create("Frame", { Parent = NotifFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })

        local DescLbl = Create("TextLabel", {
            Parent = ContentWrapper, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1, Font = CurrentFont, TextSize = 12,
            TextColor3 = Theme.Text, Text = Capitalize(Content), TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5002
        })

        local ProgressBg = Create("Frame", {
            Parent = ContentWrapper, Size = UDim2.new(1, -24, 0, 5), Position = UDim2.new(0, 12, 0, 30),
            BackgroundColor3 = Theme.Element, BorderSizePixel = 0, ZIndex = 5002
        })
        Create("UICorner", { Parent = ProgressBg, CornerRadius = UDim.new(1, 0) })
        Create("UIStroke", { Parent = ProgressBg, Color = Theme.Divider, Thickness = 1 })

        local ProgressFill = Create("Frame", {
            Parent = ProgressBg, Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 5003
        })
        Create("UICorner", { Parent = ProgressFill, CornerRadius = UDim.new(1, 0) })
        Create("UIGradient", { Parent = ProgressFill, Color = CurrentGradient })

        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, notifWidth, 0, targetHeight)}):Play()

        local progressTween = TweenService:Create(ProgressFill, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
        progressTween:Play()

        task.delay(Duration, function()
            local fadeOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 0, 0, targetHeight)})
            fadeOut:Play()
            fadeOut.Completed:Connect(function() NotifFrame:Destroy() end)
        end)
    end

    function WindowObj:SaveConfig(Name, Silent)
        if not Name or Name == "" then return end
        local success, json = pcall(function() return HttpService:JSONEncode(self.Flags) end)
        if not success then
            if not Silent then self:Notify({Title = "Error", Content = "Failed to encode config.", Duration = 3, Type = "red"}) end
            return
        end
        local saveSuccess = pcall(function()
            if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
            writefile(ConfigFolder .. "/" .. Name .. ".cfg", json)
        end)
        if saveSuccess then
            if not Silent then self:Notify({Title = "Success", Content = "Config saved: " .. Name, Duration = 3, Type = "green"}) end
        else
            if not Silent then self:Notify({Title = "Error", Content = "Failed to write config file.", Duration = 3, Type = "red"}) end
        end
    end

    function WindowObj:LoadConfig(Name)
        if not Name or Name == "" then return end
        local path = ConfigFolder .. "/" .. Name .. ".cfg"
        local readSuccess, data = pcall(function()
            if isfolder(ConfigFolder) and isfile(path) then
                return readfile(path)
            end
            return nil
        end)
        if not readSuccess or not data then
            self:Notify({Title = "Error", Content = "Config file not found or unreadable.", Duration = 3, Type = "red"})
            return
        end
        local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if not decodeSuccess or type(decoded) ~= "table" then
            self:Notify({Title = "Error", Content = "Config file is corrupted.", Duration = 3, Type = "red"})
            return
        end
        for flag, value in pairs(decoded) do
            if self.Elements[flag] then
                pcall(function() self.Elements[flag].SetValue(value) end)
            end
        end
        self:Notify({Title = "Success", Content = "Config loaded: " .. Name, Duration = 3, Type = "blue"})
    end

    function WindowObj:DeleteConfig(Name)
        if not Name or Name == "" then return end
        local path = ConfigFolder .. "/" .. Name .. ".cfg"
        local delSuccess = pcall(function()
            if isfolder(ConfigFolder) and isfile(path) then
                delfile(path)
            end
        end)
        if delSuccess then
            self:Notify({Title = "Success", Content = "Config deleted: " .. Name, Duration = 3, Type = "yellow"})
        else
            self:Notify({Title = "Error", Content = "Failed to delete config.", Duration = 3, Type = "red"})
        end
    end

    function WindowObj:GetConfigs() return ListFiles() end

    function WindowObj:CreateTab(IconId, Name)
        self.TabCount = self.TabCount + 1
        local Tab = { Name = Name }
        
        local Page = Create("ScrollingFrame", { 
            Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ZIndex = 1,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        
        local LeftCol = Create("Frame", { Parent = Page, Size = UDim2.new(0.49, 0, 0, 0), BackgroundTransparency = 1, ZIndex = 2 })
        local LeftLayout = Create("UIListLayout", { Parent = LeftCol, Padding = UDim.new(0, 10), SortOrder = 2 })
        
        local RightCol = Create("Frame", { Parent = Page, Size = UDim2.new(0.49, 0, 0, 0), Position = UDim2.new(0.51, 0, 0, 0), BackgroundTransparency = 1, ZIndex = 2 })
        local RightLayout = Create("UIListLayout", { Parent = RightCol, Padding = UDim.new(0, 10), SortOrder = 2 })

        local function UpdateCanvas()
            LeftCol.Size = UDim2.new(0.49, 0, 0, LeftLayout.AbsoluteContentSize.Y)
            RightCol.Size = UDim2.new(0.49, 0, 0, RightLayout.AbsoluteContentSize.Y)
            Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y) + 20)
        end

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        local TabBtn = Create("TextButton", {
            Parent = TabList, Size = UDim2.new(0, 44, 1, -10), ZIndex = 1, LayoutOrder = self.TabCount,
            BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ClipsDescendants = true
        })
        
        Tab.Button = TabBtn 

        local TabIcon = Create("ImageLabel", {
            Parent = TabBtn, Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, ZIndex = 2, ImageColor3 = Theme.TextMuted
        })

        local IconData = Icons[IconId]
        if IconData then
            TabIcon.Image = IconData.Image
            TabIcon.ImageRectOffset = IconData.ImageRectOffset
            TabIcon.ImageRectSize = IconData.ImageRectSize
        else
            local formattedIcon = tostring(IconId)
            if formattedIcon ~= "" and not string.match(formattedIcon, "^rbxasset") then
                formattedIcon = "rbxassetid://" .. formattedIcon
            end
            TabIcon.Image = formattedIcon
        end
        
        local BtnText = Create("TextLabel", {
            Parent = TabBtn, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 34, 0, 0), BackgroundTransparency = 1, ZIndex = 2,
            Font = CurrentFont, TextSize = 13, TextColor3 = Theme.TextMuted, Text = Capitalize(Name), TextTransparency = 1
        })

        TabBtn.MouseButton1Click:Connect(function() WindowObj:SelectTab(Name) end)

        self.Tabs[Name] = { Page = Page, Left = LeftCol, Right = RightCol, Button = TabBtn, Text = BtnText, Icon = TabIcon }
        if not self.CurrentTab then self:SelectTab(Name) end

        function Tab:CreateSection(Title, Side)
            local ParentCol = Side == "Right" and RightCol or LeftCol
            
            local Section = Create("ScrollingFrame", { 
                Parent = ParentCol, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, ZIndex = 3,
                ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0)
            })
            Create("UICorner", { Parent = Section, CornerRadius = UDim.new(0, 8) })
            
            local SectionLayout = Create("UIListLayout", { Parent = Section, Padding = UDim.new(0, 0), SortOrder = 2 })
            Create("UIPadding", { Parent = Section, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })

            local elementCount = 0

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local contentHeight = SectionLayout.AbsoluteContentSize.Y + 20
                if elementCount > 6 then
                    Section.Size = UDim2.new(1, 0, 0, 320)
                    Section.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
                else
                    Section.Size = UDim2.new(1, 0, 0, contentHeight)
                    Section.CanvasSize = UDim2.new(0, 0, 0, 0)
                end
            end)

            local Elements = {}

            function Elements:Clear()
                for _, child in ipairs(Section:GetChildren()) do
                    if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UICorner") then
                        child:Destroy()
                    end
                end
                elementCount = 0
            end

            function Elements:AddLabel(Config)
                elementCount = elementCount + 1
                local Text = Config.Text or "Label"
                local LabelFrame = Create("Frame", { Parent = Section, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, ZIndex = 4 })
                Create("UIPadding", { Parent = LabelFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) })

                Create("TextLabel", {
                    Parent = LabelFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5,
                    Font = CurrentFont, TextSize = 13, TextColor3 = Theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = Capitalize(Text),
                    TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y
                })
            end

            function Elements:AddToggle(Config)
                elementCount = elementCount + 1
                local TglName = Config.Name or "Toggle"
                local Flag = Config.Flag or TglName
                local ManualState = Config.Default or false
                local KeybindState = false
                local State = ManualState or KeybindState
                local Tooltip = Config.Tooltip
                local Callback = Config.Callback or function() end

                local ToggleData = { Key = Enum.KeyCode.Unknown, Mode = "Toggle" }
                ToggleData.UpdateSave = function()
                    WindowObj.Flags[Flag.."_Key"] = ToggleData.Key.Name
                    WindowObj.Flags[Flag.."_Mode"] = ToggleData.Mode
                end

                WindowObj.Flags[Flag] = ManualState 
                ToggleData.UpdateSave()

                local ToggleFrame = Create("Frame", { Parent = Section, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, ZIndex = 4 })
                Create("UIPadding", { Parent = ToggleFrame, PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) })

                local LabelContainer = Create("Frame", { Parent = ToggleFrame, Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, ZIndex = 5 })
                Create("UIListLayout", { Parent = LabelContainer, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
                
                Create("TextLabel", {
                    Parent = LabelContainer, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5, LayoutOrder = 1,
                    Font = CurrentFont, TextSize = 13, TextColor3 = Theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = Capitalize(TglName), AutomaticSize = Enum.AutomaticSize.X
                })

                local KeyIcon = Create("ImageLabel", {
                    Parent = LabelContainer, Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, ZIndex = 6, LayoutOrder = 2,
                    ImageColor3 = Theme.Accent, Visible = false
                })
                local kIconData = Icons["keyboard"]
                if kIconData then
                    KeyIcon.Image = kIconData.Image
                    KeyIcon.ImageRectOffset = kIconData.ImageRectOffset
                    KeyIcon.ImageRectSize = kIconData.ImageRectSize
                else
                    KeyIcon.Image = "rbxassetid://14264620023"
                end

                if Tooltip then
                    local TipIcon = Create("ImageLabel", {
                        Parent = LabelContainer, Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, ZIndex = 6, LayoutOrder = 3,
                        ImageColor3 = Theme.TextMuted, Active = true
                    })
                    local infoData = Icons["info"]
                    if infoData then
                        TipIcon.Image = infoData.Image
                        TipIcon.ImageRectOffset = infoData.ImageRectOffset
                        TipIcon.ImageRectSize = infoData.ImageRectSize
                    end
                    TipIcon.MouseEnter:Connect(function() ShowTooltip(Tooltip) end)
                    TipIcon.MouseLeave:Connect(function() HideTooltip() end)
                end

                local Switch = Create("Frame", {
                    Parent = ToggleFrame, Size = UDim2.new(0, 36, 0, 20), AnchorPoint = Vector2.new(1, 0.5), ZIndex = 5,
                    Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = ManualState and Theme.Accent or Theme.Element
                })
                Create("UICorner", { Parent = Switch, CornerRadius = UDim.new(1, 0) })
                
                local Knob = Create("Frame", {
                    Parent = Switch, Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 6,
                    Position = ManualState and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    BackgroundColor3 = ManualState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
                })
                Create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })

                local Button = Create("TextButton", { Parent = ToggleFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 10 })

                local function UpdateToggle()
                    local newState = ManualState or KeybindState
                    
                    TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = ManualState and Theme.Accent or Theme.Element}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        Position = ManualState and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                        BackgroundColor3 = ManualState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
                    }):Play()

                    KeyIcon.Visible = KeybindState

                    WindowObj.Flags[Flag] = ManualState

                    if State ~= newState then
                        State = newState
                        Callback(State)
                    end
                end

                local function SetManualValue(val)
                    ManualState = val
                    UpdateToggle()
                end

                local function SetKeybindValue(val)
                    KeybindState = val
                    UpdateToggle()
                end

                Button.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SetManualValue(not ManualState)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                        local mousePos = UserInputService:GetMouseLocation()
                        OpenContextMenu(ToggleData, mousePos)
                    end
                end)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if not gp and input.KeyCode == ToggleData.Key and ToggleData.Key ~= Enum.KeyCode.Unknown then
                        if ToggleData.Mode == "Toggle" or ToggleData.Mode == "Click" then
                            SetKeybindValue(not KeybindState)
                        elseif ToggleData.Mode == "Hold" then
                            SetKeybindValue(true)
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input, gp)
                    if not gp and input.KeyCode == ToggleData.Key and ToggleData.Key ~= Enum.KeyCode.Unknown then
                        if ToggleData.Mode == "Hold" then
                            SetKeybindValue(false)
                        end
                    end
                end)

                WindowObj.Elements[Flag] = { 
                    SetValue = function(val) SetManualValue(val) end,
                    SetKey = function(keyName) ToggleData.Key = Enum.KeyCode[keyName] or Enum.KeyCode.Unknown end,
                    SetMode = function(modeStr) ToggleData.Mode = modeStr end
                }
                WindowObj.Elements[Flag.."_Key"] = { SetValue = function(val) ToggleData.Key = Enum.KeyCode[val] or Enum.KeyCode.Unknown end }
                WindowObj.Elements[Flag.."_Mode"] = { SetValue = function(val) ToggleData.Mode = val end }
            end

            function Elements:AddDropdown(Config)
                elementCount = elementCount + 1
                local DropName = Config.Name or "Dropdown"
                local Flag = Config.Flag or DropName
                local Options = Config.Options or {}
                local Default = Config.Default or Options[1] or ""
                local Tooltip = Config.Tooltip
                local Callback = Config.Callback or function() end

                local CurrentValue = Default
                WindowObj.Flags[Flag] = CurrentValue

                local DropFrame = Create("Frame", { Parent = Section, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, ZIndex = 4 })
                Create("UIPadding", { Parent = DropFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) })

                local LabelContainer = Create("Frame", { Parent = DropFrame, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, ZIndex = 5 })
                Create("UIListLayout", { Parent = LabelContainer, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
                
                Create("TextLabel", {
                    Parent = LabelContainer, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5, LayoutOrder = 1,
                    Font = CurrentFont, TextSize = 13, TextColor3 = Theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = Capitalize(DropName), AutomaticSize = Enum.AutomaticSize.X
                })

                if Tooltip then
                    local TipIcon = Create("ImageLabel", {
                        Parent = LabelContainer, Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, ZIndex = 6, LayoutOrder = 2,
                        ImageColor3 = Theme.TextMuted, Active = true
                    })
                    local infoData = Icons["info"]
                    if infoData then
                        TipIcon.Image = infoData.Image
                        TipIcon.ImageRectOffset = infoData.ImageRectOffset
                        TipIcon.ImageRectSize = infoData.ImageRectSize
                    end
                    TipIcon.MouseEnter:Connect(function() ShowTooltip(Tooltip) end)
                    TipIcon.MouseLeave:Connect(function() HideTooltip() end)
                end

                local MainBtn = Create("TextButton", {
                    Parent = DropFrame, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Theme.Element, ZIndex = 5,
                    Font = CurrentFont, TextSize = 12, TextColor3 = Theme.Text, Text = Capitalize(CurrentValue), AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left
                })
                Create("UICorner", { Parent = MainBtn, CornerRadius = UDim.new(0, 6) })
                Create("UIPadding", { Parent = MainBtn, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
                
                local Chevron = Create("TextLabel", {
                    Parent = MainBtn, Size = UDim2.new(0, 20, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -15, 0.5, 0), BackgroundTransparency = 1, ZIndex = 6,
                    Font = CurrentFont, TextSize = 14, TextColor3 = Theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Center, Text = "v"
                })

                local ListContainer = Create("ScrollingFrame", {
                    Parent = DropFrame, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 55), BackgroundColor3 = Theme.Element, ZIndex = 6, Visible = false,
                    ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0), ClipsDescendants = true
                })
                Create("UICorner", { Parent = ListContainer, CornerRadius = UDim.new(0, 6) })
                Create("UIStroke", { Parent = ListContainer, Color = Theme.Divider, Thickness = 1 })
                local ListLayout = Create("UIListLayout", { Parent = ListContainer, SortOrder = 2 })
                
                table.insert(WindowObj.DropdownContainers, {Container = ListContainer, Frame = DropFrame, Btn = MainBtn, Chevron = Chevron})

                local function BuildOptions(optTable)
                    for _, child in ipairs(ListContainer:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, option in ipairs(optTable) do
                        local isSelected = (option == CurrentValue)
                        local OptBtn = Create("TextButton", {
                            Parent = ListContainer, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, ZIndex = 7,
                            Font = CurrentFont, TextSize = 12, TextColor3 = isSelected and Theme.Accent or Theme.TextMuted, Text = Capitalize(option)
                        })
                        OptBtn.MouseEnter:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.15), {TextColor3 = Theme.Accent}):Play() end)
                        OptBtn.MouseLeave:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.15), {TextColor3 = (option == CurrentValue) and Theme.Accent or Theme.TextMuted}):Play() end)
                        OptBtn.MouseButton1Click:Connect(function()
                            WindowObj.Elements[Flag].SetValue(option)
                            CloseMenus()
                        end)
                    end
                end

                local function SetValue(val)
                    CurrentValue = val
                    MainBtn.Text = Capitalize(val)
                    WindowObj.Flags[Flag] = val
                    BuildOptions(Options)
                    Callback(val)
                end

                BuildOptions(Options)

                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
                end)

                MainBtn.MouseButton1Click:Connect(function()
                    local open = not ListContainer.Visible
                    CloseMenus()
                    if open then
                        local count = 0
                        for _,v in ipairs(ListContainer:GetChildren()) do if v:IsA("TextButton") then count = count + 1 end end
                        local calcHeight = math.clamp(count * 25, 0, 4 * 25)
                        
                        ListContainer.Size = UDim2.new(1, 0, 0, 0)
                        ListContainer.Visible = true
                        
                        TweenService:Create(ListContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, calcHeight)}):Play()
                        TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 60 + calcHeight + 5)}):Play()
                        Chevron.Rotation = 180
                    end
                end)

                WindowObj.Elements[Flag] = { 
                    Type = "Dropdown", 
                    SetValue = SetValue,
                    UpdateOptions = function(newOpts)
                        Options = newOpts
                        BuildOptions(newOpts)
                    end
                }
                return WindowObj.Elements[Flag]
            end

            function Elements:AddSlider(Config)
                elementCount = elementCount + 1
                local SldName = Config.Name or "Slider"
                local Flag = Config.Flag or SldName
                local Min = Config.Min or 0
                local Max = Config.Max or 100
                local Step = Config.Step or Config.Increment or 0.1
                local Value = Config.Default or Min
                local Decimals = Config.Decimals or 1
                local Tooltip = Config.Tooltip
                local Callback = Config.Callback or function() end

                WindowObj.Flags[Flag] = Value 

                local SliderFrame = Create("Frame", { Parent = Section, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, ZIndex = 4 })
                Create("UIPadding", { Parent = SliderFrame, PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) })

                local LabelContainer = Create("Frame", { Parent = SliderFrame, Size = UDim2.new(0.5, 0, 0, 20), Position = UDim2.new(0, 0, 0, 5), BackgroundTransparency = 1, ZIndex = 5 })
                Create("UIListLayout", { Parent = LabelContainer, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
                
                Create("TextLabel", {
                    Parent = LabelContainer, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5, LayoutOrder = 1,
                    Font = CurrentFont, TextSize = 13, TextColor3 = Theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = Capitalize(SldName), AutomaticSize = Enum.AutomaticSize.X
                })

                if Tooltip then
                    local TipIcon = Create("ImageLabel", {
                        Parent = LabelContainer, Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, ZIndex = 6, LayoutOrder = 2,
                        ImageColor3 = Theme.TextMuted, Active = true
                    })
                    local infoData = Icons["info"]
                    if infoData then
                        TipIcon.Image = infoData.Image
                        TipIcon.ImageRectOffset = infoData.ImageRectOffset
                        TipIcon.ImageRectSize = infoData.ImageRectSize
                    end
                    TipIcon.MouseEnter:Connect(function() ShowTooltip(Tooltip) end)
                    TipIcon.MouseLeave:Connect(function() HideTooltip() end)
                end

                local ValueDisplay = Create("TextLabel", {
                    Parent = SliderFrame, Size = UDim2.new(0.5, 0, 0, 20), Position = UDim2.new(0.5, 0, 0, 5), ZIndex = 5,
                    BackgroundTransparency = 1, Font = CurrentFont, TextSize = 12, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Right, Text = string.format("%."..Decimals.."f", Value)
                })

                local TrackBox = Create("Frame", {
                    Parent = SliderFrame, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 1, -12), ZIndex = 5,
                    BackgroundColor3 = Theme.Element, BorderSizePixel = 0
                })
                Create("UICorner", { Parent = TrackBox, CornerRadius = UDim.new(1, 0) })

                local Fill = Create("Frame", { Parent = TrackBox, Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0), BackgroundColor3 = Theme.Accent, ZIndex = 6 })
                Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })

                local Knob = Create("Frame", {
                    Parent = Fill, Size = UDim2.new(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0), ZIndex = 7,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                })
                Create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })

                local DragBtn = Create("TextButton", { Parent = TrackBox, Size = UDim2.new(1, 0, 1, 20), Position = UDim2.new(0, 0, 0, -10), BackgroundTransparency = 1, Text = "", ZIndex = 10 })

                local function SetValue(newValue)
                    newValue = math.clamp(newValue, Min, Max)
                    newValue = math.floor((newValue / Step) + 0.5) * Step
                    Value = tonumber(string.format("%."..Decimals.."f", newValue))
                    
                    WindowObj.Flags[Flag] = Value
                    local Percent = (Value - Min) / (Max - Min)
                    TweenService:Create(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(Percent, 0, 1, 0)}):Play()
                    ValueDisplay.Text = string.format("%."..Decimals.."f", Value)
                    Callback(Value)
                end

                local Connection
                local function UpdateSlider(Input)
                    local Percent = math.clamp((Input.Position.X - TrackBox.AbsolutePosition.X) / TrackBox.AbsoluteSize.X, 0, 1)
                    SetValue(Min + ((Max - Min) * Percent))
                end

                DragBtn.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        UpdateSlider(Input)
                        TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 16, 0, 16)}):Play()
                        Connection = UserInputService.InputChanged:Connect(function(MoveInput)
                            if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(MoveInput) end
                        end)
                    end
                end)
                DragBtn.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if Connection then Connection:Disconnect() end
                        TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 12, 0, 12)}):Play()
                    end
                end)

                WindowObj.Elements[Flag] = { Type = "Slider", SetValue = SetValue }
            end

            function Elements:AddButton(Config)
                elementCount = elementCount + 1
                local BtnName = Config.Name or "Button"
                local Danger = Config.Danger or false
                local Selected = Config.Selected or false
                local Callback = Config.Callback or function() end

                local ButtonFrame = Create("Frame", { Parent = Section, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, ZIndex = 4 })
                Create("UIPadding", { Parent = ButtonFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) })

                local Btn = Create("TextButton", {
                    Parent = ButtonFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Element, ZIndex = 5,
                    Font = CurrentFont, TextSize = 13, TextColor3 = Selected and Theme.Accent or (Danger and Theme.Danger or Theme.Text), Text = Capitalize(BtnName), AutoButtonColor = false
                })
                Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 6) })

                if Selected then
                    local Indicator = Create("Frame", {
                        Parent = Btn, Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(1, -6, 0.5, 0),
                        AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme.Accent, ZIndex = 6
                    })
                    Create("UICorner", { Parent = Indicator, CornerRadius = UDim.new(0, 4) })
                end

                Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play() end)
                Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play() end)
                Btn.MouseButton1Click:Connect(function()
                    local clickTween = TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0.9, 0), Position = UDim2.new(0.01, 0, 0.05, 0)})
                    clickTween:Play()
                    clickTween.Completed:Wait()
                    TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
                    Callback()
                end)
            end

            function Elements:AddKeybind(Config)
                elementCount = elementCount + 1
                local KeyName = Config.Name or "Keybind"
                local DefaultKey = Config.Default or Enum.KeyCode.RightShift
                local Callback = Config.Callback or function() end
                local CurrentKey = DefaultKey

                local KeybindFrame = Create("Frame", { Parent = Section, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, ZIndex = 4 })
                Create("UIPadding", { Parent = KeybindFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) })

                local BtnBg = Create("Frame", {
                    Parent = KeybindFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Element, ZIndex = 5
                })
                Create("UICorner", { Parent = BtnBg, CornerRadius = UDim.new(0, 6) })

                local KeyNameLabel = Create("TextLabel", {
                    Parent = BtnBg, Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, ZIndex = 6,
                    Font = CurrentFont, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = Capitalize(KeyName)
                })
                
                local KeyIndicatorBg = Create("Frame", {
                    Parent = BtnBg, Size = UDim2.new(0, 60, 0, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
                    BackgroundColor3 = Theme.Panel, ZIndex = 6
                })
                Create("UICorner", { Parent = KeyIndicatorBg, CornerRadius = UDim.new(0, 6) })
                Create("UIStroke", { Parent = KeyIndicatorBg, Color = Theme.Divider, Thickness = 1 })

                local KeyIndicatorText = Create("TextLabel", {
                    Parent = KeyIndicatorBg, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 7,
                    Font = CurrentFont, TextSize = 11, TextColor3 = Theme.TextMuted, Text = Capitalize(CurrentKey.Name)
                })

                local Hitbox = Create("TextButton", { Parent = BtnBg, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 10 })

                local Binding = false
                Hitbox.MouseButton1Click:Connect(function()
                    Binding = true
                    KeyIndicatorText.Text = "..."
                    TweenService:Create(KeyIndicatorBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TextMuted}):Play()
                    TweenService:Create(KeyIndicatorText, TweenInfo.new(0.2), {TextColor3 = Theme.Background}):Play()
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        Binding = false
                        CurrentKey = input.KeyCode
                        KeyIndicatorText.Text = Capitalize(CurrentKey.Name)
                        TweenService:Create(KeyIndicatorBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Panel}):Play()
                        TweenService:Create(KeyIndicatorText, TweenInfo.new(0.2), {TextColor3 = Theme.TextMuted}):Play()
                        Callback(CurrentKey)
                    end
                end)
            end

            function Elements:AddTextBox(Config)
                elementCount = elementCount + 1
                local TxtName = Config.Name or "Enter text..."
                local Callback = Config.Callback or function() end

                local TextBoxFrame = Create("Frame", { Parent = Section, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, ZIndex = 4 })
                Create("UIPadding", { Parent = TextBoxFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) })

                local Box = Create("TextBox", {
                    Parent = TextBoxFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Background, ZIndex = 5,
                    Font = CurrentFont, TextSize = 13, TextColor3 = Theme.Text, Text = "", PlaceholderText = Capitalize(TxtName),
                    PlaceholderColor3 = Theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = false
                })
                Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 6) })
                Create("UIStroke", { Parent = Box, Color = Theme.Element, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

                Box.FocusLost:Connect(function() Callback(Box.Text) end)
            end

            return Elements
        end
        return Tab
    end

    function WindowObj:SelectTab(TabName)
        for name, tab in pairs(self.Tabs) do
            if name == TabName then
                tab.Page.Visible = true
                TweenService:Create(tab.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 130, 1, -12)}):Play()
                TweenService:Create(tab.Text, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 0, TextColor3 = Theme.Text}):Play()
                TweenService:Create(tab.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageColor3 = Theme.Accent, Position = UDim2.new(0, 20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            else
                tab.Page.Visible = false
                TweenService:Create(tab.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 44, 1, -12)}):Play()
                TweenService:Create(tab.Text, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
                TweenService:Create(tab.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageColor3 = Theme.TextMuted, Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)}):Play()
            end
        end
        self.CurrentTab = TabName
    end

    local SettingsTab = WindowObj:CreateTab("settings", "Settings")
    SettingsTab.Button.LayoutOrder = 9999 

    local CfgLeft = SettingsTab:CreateSection("Saved Configs", "Left")
    local UiSettings = SettingsTab:CreateSection("UI Settings", "Left")
    local CfgRight = SettingsTab:CreateSection("Config Manager", "Right")

    local CurrentConfigName = ""
    local AutoSaveConfig = false

    local CoreSettings = { AutoLoad = "None" }
    pcall(function()
        if isfile(CoreSettingsFile) then
            CoreSettings = HttpService:JSONDecode(readfile(CoreSettingsFile))
        end
    end)
    local function SaveCore()
        pcall(function() writefile(CoreSettingsFile, HttpService:JSONEncode(CoreSettings)) end)
    end

    UiSettings:AddKeybind({
        Name = "Toggle Menu", 
        Default = Enum.KeyCode.RightShift,
        Callback = function(Key)
            WindowObj.ToggleKey = Key
        end
    })

    UiSettings:AddButton({ 
        Name = "Eject", 
        Danger = true, 
        Callback = function() Ui:Unload() end 
    })

    local AutoLoadDrop = CfgRight:AddDropdown({
        Name = "Auto Load Config", 
        Options = {"None"}, 
        Default = CoreSettings.AutoLoad,
        Flag = "AutoLoadDropdown",
        Callback = function(val)
            CoreSettings.AutoLoad = val
            SaveCore()
        end
    })

    local function RefreshConfigs()
        CfgLeft:Clear()
        local configs = WindowObj:GetConfigs()
        local dropOptions = {"None"}
        for _, cfg in ipairs(configs) do
            table.insert(dropOptions, cfg)
            local isSelected = (CurrentConfigName == cfg)
            local btnText = isSelected and ("✓  " .. cfg) or ("     " .. cfg)
            CfgLeft:AddButton({ 
                Name = Capitalize(btnText), 
                Selected = isSelected,
                Callback = function() 
                    CurrentConfigName = cfg 
                    RefreshConfigs() 
                end 
            })
        end
        if AutoLoadDrop.UpdateOptions then
            AutoLoadDrop.UpdateOptions(dropOptions)
        end
    end

    CfgRight:AddTextBox({ 
        Name = "Enter config name...", 
        Callback = function(text) CurrentConfigName = text end 
    })

    CfgRight:AddButton({ 
        Name = "Save config", 
        Callback = function() 
            if CurrentConfigName ~= "" then 
                WindowObj:SaveConfig(CurrentConfigName)
                RefreshConfigs() 
            end 
        end 
    })

    CfgRight:AddButton({ 
        Name = "Load config", 
        Callback = function() 
            if CurrentConfigName ~= "" then 
                WindowObj:LoadConfig(CurrentConfigName)
                RefreshConfigs() 
            end 
        end 
    })

    CfgRight:AddButton({ 
        Name = "Delete config", 
        Danger = true, 
        Callback = function() 
            if CurrentConfigName ~= "" then 
                WindowObj:DeleteConfig(CurrentConfigName)
                CurrentConfigName = ""
                RefreshConfigs() 
            end 
        end 
    })

    CfgRight:AddToggle({
        Name = "Auto Save Config", 
        Default = false, 
        Flag = "AutoSaveConfig",
        Callback = function(state) AutoSaveConfig = state end
    })

    task.spawn(function()
        while task.wait(5) do
            if AutoSaveConfig and CurrentConfigName ~= "" then
                WindowObj:SaveConfig(CurrentConfigName, true)
            end
        end
    end)

    RefreshConfigs()

    local files = WindowObj:GetConfigs()
    if #files > 0 and CoreSettings.AutoLoad ~= "None" then
        local found = false
        for _, f in ipairs(files) do
            if f == CoreSettings.AutoLoad then found = true break end
        end
        if found then
            CurrentConfigName = CoreSettings.AutoLoad
            RefreshConfigs()
            WindowObj:LoadConfig(CurrentConfigName)
        end
    end

    return WindowObj
end

return Ui
