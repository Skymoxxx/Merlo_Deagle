-- merlo | V2 (Final Fix: No Giant Hands + Working Configs)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Config = {
    ESP = true, Skeleton = true, Box = true, Tracers = true, Name = true, Distance = true, HealthBar = true, Chams = false,
    Color = Color3.fromRGB(255, 120, 0),
    AimbotEnabled = false, FOV = 150,
    TargetParts = {Head = true, Torso = false, Arms = false, Legs = false},
    Smoothness = 1.0, Humanize = false, VisibleCheck = false,
    
    AimKeyMode = "HOLD", 
    AimKey = Enum.UserInputType.MouseButton2,
    MenuKey = Enum.KeyCode.RightShift,
    
    Speedhack = false, SpeedVal = 50, Fly = false, FlyVal = 80,
    InfJump = false, Bhop = false, Noclip = false,
    Spinbot = false, Invisible = false,
    
    Lang = "RU"
}

local Lang = {
    RU = {
        tabESP = "ESP", tabAim = "Аим", tabMisc = "Миск", tabSettings = "Настройки", tabInfo = "Инфо",
        espEnable = "Включить ESP", espChams = "Подсветка (Chams)", espSkel = "Скелетон", espBox = "Бокс", espTracers = "Трассеры", espName = "Никнейм", espDist = "Дистанция", espHP = "Полоска HP", espColor = "Цвет ESP:",
        aimEnable = "Включить Аимбот", aimFOV = "Радиус FOV", aimSmooth = "Плавность", aimHuman = "Humanize", aimVis = "Visible Check",
        aimKeyMode = "Режим: ", aimKeyHold = "УДЕРЖИВАТЬ", aimKeyToggle = "ПЕРЕКЛЮЧАТЬ", aimBind = "Бинд: ",
        miscSpeed = "Speedhack", miscSpeedV = "Скорость", miscFly = "Полет", miscFlyV = "Скор. Полета",
        miscJump = "Беск. Прыжок", miscBhop = "Auto Bhop", miscNoclip = "NoClip",
        miscSpin = "Спинбот", miscInv = "Невидимость",
        setMenuKey = "Кнопка меню: ", setLang = "Язык:", setSave = "Сохранить", setLoad = "Загрузить",
        infoDiscord = "Discord канал: https://discord.gg/7ZAEnux2h", infoDev = "Разработчик: Skymoxx", infoThanks = "Спасибо за использование скрипта❣️"
    },
    EN = {
        tabESP = "ESP", tabAim = "Aim", tabMisc = "Misc", tabSettings = "Settings", tabInfo = "Info",
        espEnable = "Enable ESP", espChams = "Chams (Glow)", espSkel = "Skeleton", espBox = "Box", espTracers = "Tracers", espName = "Name", espDist = "Distance", espHP = "Health Bar", espColor = "ESP Color:",
        aimEnable = "Enable Aimbot", aimFOV = "FOV Radius", aimSmooth = "Smoothness", aimHuman = "Humanize", aimVis = "Visible Check",
        aimKeyMode = "Mode: ", aimKeyHold = "HOLD", aimKeyToggle = "TOGGLE", aimBind = "Bind: ",
        miscSpeed = "Speedhack", miscSpeedV = "Speed", miscFly = "Fly", miscFlyV = "Fly Speed",
        miscJump = "Infinite Jump", miscBhop = "Auto Bhop", miscNoclip = "NoClip",
        miscSpin = "Spinbot", miscInv = "Invisible",
        setMenuKey = "Menu Key: ", setLang = "Language:", setSave = "Save", setLoad = "Load",
        infoDiscord = "Discord channel: https://discord.gg/7ZAEnux2h", infoDev = "Dev by: Skymoxx", infoThanks = "Thank you for using this script❣️"
    }
}

local Style = {
    mainBg = Color3.fromRGB(15, 15, 15),
    titleBg = Color3.fromRGB(22, 22, 22),
    sideBg = Color3.fromRGB(15, 15, 15),
    bgElement = Color3.fromRGB(28, 28, 28),
    acc = Color3.fromRGB(255, 120, 0),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150),
    toggOff = Color3.fromRGB(50, 50, 50)
}

local Drawings = {}
local Highlights = {}
local RenderConn = nil
local isRunning = true
local currentTargetPlr = nil
local currentTargetPart = nil
local flyBV = nil
local speedBV = nil
local aimToggled = false
local isAimHeld = false
local isBindingKey = false
local isBindingMenu = false
local uiElements = {}

local function formatKey(key)
    local str = tostring(key)
    str = string.gsub(str, "Enum%.KeyCode%.", "")
    str = string.gsub(str, "Enum%.UserInputType%.", "")
    return str
end

local function getLang(key)
    return Lang[Config.Lang][key] or key
end

local function serialize(val)
    if typeof(val) == "Color3" then return {__type = "Color3", r = val.R, g = val.G, b = val.B}
    elseif typeof(val) == "EnumItem" then return {__type = "EnumItem", enum = tostring(val)}
    elseif typeof(val) == "table" then
        local t = {}; for k, v in pairs(val) do t[k] = serialize(v) end; return t
    else return val end
end

local function deserialize(val)
    if type(val) == "table" then
        if val.__type == "Color3" then return Color3.new(val.r, val.g, val.b)
        elseif val.__type == "EnumItem" then
            local enumType, enumName = string.match(val.enum, "Enum%.(%w+)%.(%w+)")
            if enumType and enumName then return Enum[enumType][enumName] end
        else
            local t = {}; for k, v in pairs(val) do t[k] = deserialize(v) end; return t
        end
    end
    return val
end

local function loadMainScript()
    pcall(function() game:GetService("CoreGui").MerloMain:Destroy() end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "MerloMain"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 620, 0, 420)
    main.Position = UDim2.new(0.5, -310, 0.5, -210)
    main.BackgroundColor3 = Style.mainBg
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = Color3.fromRGB(50, 50, 50)
    mainStroke.Thickness = 1

    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Style.titleBg
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "V2"
    title.TextColor3 = Style.acc
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Style.bgElement
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Style.text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

    closeBtn.MouseButton1Click:Connect(function()
        isRunning = false
        if RenderConn then RenderConn:Disconnect() end
        pcall(function() RunService:UnbindFromRenderStep("MerloAim") end)
        for _, v in pairs(Drawings) do pcall(function() v:Remove() end) end
        Drawings = {}
        for _, h in pairs(Highlights) do pcall(function() h:Destroy() end) end
        Highlights = {}
        if flyBV then flyBV:Destroy() end
        if speedBV then speedBV:Destroy() end
        gui:Destroy()
    end)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 120, 1, -35)
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.BackgroundColor3 = Style.sideBg
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    
    local sideStroke = Instance.new("UIStroke", sidebar)
    sideStroke.Color = Color3.fromRGB(40, 40, 40)
    sideStroke.Thickness = 1

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -120, 1, -35)
    contentArea.Position = UDim2.new(0, 120, 0, 35)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    local pages = {}
    for i = 1, 5 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(1, -20, 1, -20)
        p.Position = UDim2.new(0, 10, 0, 10)
        p.BackgroundTransparency = 1
        p.Visible = (i == 1)
        p.Parent = contentArea
        pages[i] = p
    end

    local tabBtns = {}
    local tabIcons = {
        [1] = "rbxassetid://6031075931",
        [2] = "rbxassetid://6031094667",
        [3] = "rbxassetid://6031094678",
        [4] = "rbxassetid://6031091004",
        [5] = "rbxassetid://6031090990"
    }
    local tabKeys = {"tabESP", "tabAim", "tabMisc", "tabSettings", "tabInfo"}

    local function switchTab(idx)
        for i, p in ipairs(pages) do p.Visible = (i == idx) end
        for i, btn in ipairs(tabBtns) do
            if i == idx then
                btn.BackgroundColor3 = Style.bgElement
                btn.TextColor3 = Style.text
                btn:FindFirstChild("Line").Visible = true
            else
                btn.BackgroundColor3 = Style.titleBg
                btn.TextColor3 = Style.textDim
                btn:FindFirstChild("Line").Visible = false
            end
        end
    end

    for i = 1, 5 do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, (i-1)*40 + 5)
        btn.BackgroundColor3 = Style.titleBg
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        tabBtns[i] = btn

        local line = Instance.new("Frame")
        line.Name = "Line"
        line.Size = UDim2.new(0, 3, 0, 16)
        line.Position = UDim2.new(0, 0, 0.5, -8)
        line.BackgroundColor3 = Style.acc
        line.BorderSizePixel = 0
        line.Visible = false
        line.Parent = btn

        local ico = Instance.new("ImageLabel")
        ico.Size = UDim2.new(0, 20, 0, 20)
        ico.Position = UDim2.new(0, 8, 0.5, -10)
        ico.BackgroundTransparency = 1
        ico.Image = tabIcons[i]
        ico.ImageColor3 = Style.text
        ico.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -35, 1, 0)
        lbl.Position = UDim2.new(0, 32, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = getLang(tabKeys[i])
        lbl.TextColor3 = Style.text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = btn
        
        table.insert(uiElements, {obj = lbl, key = tabKeys[i], type = "TAB"})

        btn.MouseButton1Click:Connect(function() switchTab(i) end)
    end

    local function createToggle(parent, textKey, yPos, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 28)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundColor3 = Style.bgElement
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -50, 1, 0)
        text.Position = UDim2.new(0, 10, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = getLang(textKey)
        text.TextColor3 = Style.text
        text.Font = Enum.Font.GothamBold
        text.TextSize = 11
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Parent = frame
        table.insert(uiElements, {obj = text, key = textKey, type = "LABEL"})

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = frame

        local switchBg = Instance.new("Frame")
        switchBg.Size = UDim2.new(0, 30, 0, 16)
        switchBg.Position = UDim2.new(1, -40, 0.5, -8)
        switchBg.BackgroundColor3 = default and Style.acc or Style.toggOff
        switchBg.Parent = frame
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = switchBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Style.acc or Style.toggOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
            callback(state)
        end)
    end

    local function createSlider(parent, textKey, yPos, defaultVal, minVal, maxVal, callback)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 15)
        lbl.Position = UDim2.new(0, 0, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = getLang(textKey) .. ": " .. string.format("%.2f", defaultVal)
        lbl.TextColor3 = Style.text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        table.insert(uiElements, {obj = lbl, key = textKey, type = "SLIDER"})

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 0, 6)
        bg.Position = UDim2.new(0, 0, 0, yPos + 18)
        bg.BackgroundColor3 = Style.bgElement
        bg.Parent = parent
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = Style.acc
        fill.Parent = bg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = bg

        btn.MouseButton1Down:Connect(function()
            local dragging = true
            local conn = UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local mouse = UIS:GetMouseLocation()
                    local relX = math.clamp((mouse.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    local val = minVal + relX * (maxVal - minVal)
                    lbl.Text = getLang(textKey) .. ": " .. string.format("%.2f", val)
                    callback(val)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end)
    end

    -- === PAGE 1: ESP ===
    createToggle(pages[1], "espEnable", 5, Config.ESP, function(s) Config.ESP = s end)
    createToggle(pages[1], "espChams", 40, Config.Chams, function(s) Config.Chams = s end)
    createToggle(pages[1], "espSkel", 75, Config.Skeleton, function(s) Config.Skeleton = s end)
    createToggle(pages[1], "espBox", 110, Config.Box, function(s) Config.Box = s end)
    createToggle(pages[1], "espTracers", 145, Config.Tracers, function(s) Config.Tracers = s end)
    createToggle(pages[1], "espName", 180, Config.Name, function(s) Config.Name = s end)
    createToggle(pages[1], "espDist", 215, Config.Distance, function(s) Config.Distance = s end)
    createToggle(pages[1], "espHP", 250, Config.HealthBar, function(s) Config.HealthBar = s end)

    local paletteLbl = Instance.new("TextLabel")
    paletteLbl.Size = UDim2.new(1, 0, 0, 15)
    paletteLbl.Position = UDim2.new(0, 0, 0, 290)
    paletteLbl.BackgroundTransparency = 1
    paletteLbl.Text = getLang("espColor")
    paletteLbl.TextColor3 = Style.text
    paletteLbl.Font = Enum.Font.GothamBold
    paletteLbl.TextSize = 11
    paletteLbl.TextXAlignment = Enum.TextXAlignment.Left
    paletteLbl.Parent = pages[1]
    table.insert(uiElements, {obj = paletteLbl, key = "espColor", type = "LABEL"})

    local colors = {Color3.fromRGB(255,50,50), Color3.fromRGB(50,255,50), Color3.fromRGB(50,150,255), Color3.fromRGB(255,255,50), Color3.fromRGB(255,50,255), Color3.fromRGB(255,255,255)}
    for i, c in ipairs(colors) do
        local cBtn = Instance.new("TextButton")
        cBtn.Size = UDim2.new(0.12, 0, 0, 25)
        cBtn.Position = UDim2.new((i-1) * 0.14, 0, 0, 310)
        cBtn.BackgroundColor3 = c
        cBtn.Text = ""
        cBtn.Parent = pages[1]
        Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 4)
        local cStroke = Instance.new("UIStroke", cBtn)
        cStroke.Color = Style.bgElement
        cStroke.Transparency = 0.5
        cBtn.MouseButton1Click:Connect(function() Config.Color = c end)
    end

    -- === PAGE 2: AIMBOT ===
    local aimPage = pages[2]
    local col1 = Instance.new("Frame")
    col1.Size = UDim2.new(0.31, 0, 1, 0)
    col1.BackgroundTransparency = 1
    col1.Parent = aimPage

    createToggle(col1, "aimEnable", 5, Config.AimbotEnabled, function(s) Config.AimbotEnabled = s end)
    createSlider(col1, "aimFOV", 40, Config.FOV, 10, 500, function(v) Config.FOV = v end)
    
    local hitboxFrame = Instance.new("Frame")
    hitboxFrame.Size = UDim2.new(1, 0, 0, 160)
    hitboxFrame.Position = UDim2.new(0, 0, 0, 100)
    hitboxFrame.BackgroundTransparency = 1
    hitboxFrame.Parent = col1

    local partButtons = {}
    local function createPartBtn(name, size, pos, isSelected)
        local b = Instance.new("TextButton")
        b.Size = size; b.Position = pos
        b.BackgroundColor3 = isSelected and Style.acc or Style.toggOff
        b.Text = ""; b.Parent = hitboxFrame
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
        
        if not partButtons[name] then partButtons[name] = {} end
        table.insert(partButtons[name], b)
        
        b.MouseButton1Click:Connect(function()
            Config.TargetParts[name] = not Config.TargetParts[name]
            local active = Config.TargetParts[name]
            for _, btn in ipairs(partButtons[name]) do 
                btn.BackgroundColor3 = active and Style.acc or Style.toggOff
            end
        end)
    end

    createPartBtn("Head", UDim2.new(0, 30, 0, 30), UDim2.new(0.5, -15, 0, 0), Config.TargetParts.Head)
    createPartBtn("Torso", UDim2.new(0, 40, 0, 50), UDim2.new(0.5, -20, 0, 35), Config.TargetParts.Torso)
    createPartBtn("Arms", UDim2.new(0, 15, 0, 50), UDim2.new(0.5, -37, 0, 35), Config.TargetParts.Arms)
    createPartBtn("Arms", UDim2.new(0, 15, 0, 50), UDim2.new(0.5, 22, 0, 35), Config.TargetParts.Arms)
    createPartBtn("Legs", UDim2.new(0, 17, 0, 50), UDim2.new(0.5, -18, 0, 90), Config.TargetParts.Legs)
    createPartBtn("Legs", UDim2.new(0, 17, 0, 50), UDim2.new(0.5, 1, 0, 90), Config.TargetParts.Legs)

    local col2 = Instance.new("Frame")
    col2.Size = UDim2.new(0.31, 0, 1, 0)
    col2.Position = UDim2.new(0.345, 0, 0, 0)
    col2.BackgroundTransparency = 1
    col2.Parent = aimPage

    createSlider(col2, "aimSmooth", 5, Config.Smoothness, 0.1, 5.0, function(v) Config.Smoothness = v end)
    createToggle(col2, "aimHuman", 55, Config.Humanize, function(s) Config.Humanize = s end)
    createToggle(col2, "aimVis", 90, Config.VisibleCheck, function(s) Config.VisibleCheck = s end)

    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(1, 0, 0, 28)
    modeBtn.Position = UDim2.new(0, 0, 0, 125)
    modeBtn.BackgroundColor3 = Style.bgElement
    modeBtn.TextColor3 = Style.text
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 11
    modeBtn.TextXAlignment = Enum.TextXAlignment.Left
    modeBtn.Parent = col2
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 4)
    
    local function updateModeBtn()
        modeBtn.Text = "  " .. getLang("aimKeyMode") .. (Config.AimKeyMode == "HOLD" and getLang("aimKeyHold") or getLang("aimKeyToggle"))
    end
    table.insert(uiElements, {obj = modeBtn, key = "aimKeyMode", type = "MODE_BTN"})
    updateModeBtn()
    
    modeBtn.MouseButton1Click:Connect(function()
        if Config.AimKeyMode == "HOLD" then
            Config.AimKeyMode = "TOGGLE"
            aimToggled = false
        else
            Config.AimKeyMode = "HOLD"
        end
        updateModeBtn()
    end)

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(1, 0, 0, 28)
    bindBtn.Position = UDim2.new(0, 0, 0, 160)
    bindBtn.BackgroundColor3 = Style.bgElement
    bindBtn.TextColor3 = Style.text
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 11
    bindBtn.TextXAlignment = Enum.TextXAlignment.Left
    bindBtn.Parent = col2
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)
    
    local function updateBindBtn()
        bindBtn.Text = "  " .. getLang("aimBind") .. formatKey(Config.AimKey)
    end
    table.insert(uiElements, {obj = bindBtn, key = "aimBind", type = "BIND_BTN"})
    updateBindBtn()
    
    bindBtn.MouseButton1Click:Connect(function()
        isBindingKey = true
        bindBtn.Text = "  ..."
    end)

    local col3 = Instance.new("Frame")
    col3.Size = UDim2.new(0.31, 0, 1, 0)
    col3.Position = UDim2.new(0.69, 0, 0, 0)
    col3.BackgroundTransparency = 1
    col3.Parent = aimPage

    local rageTitle = Instance.new("TextLabel")
    rageTitle.Size = UDim2.new(1, 0, 0, 20)
    rageTitle.BackgroundTransparency = 1
    rageTitle.Text = "Rage"
    rageTitle.TextColor3 = Style.text
    rageTitle.Font = Enum.Font.GothamBold
    rageTitle.TextSize = 12
    rageTitle.Parent = col3

    local soonLbl = Instance.new("TextLabel")
    soonLbl.Size = UDim2.new(1, 0, 0, 30)
    soonLbl.Position = UDim2.new(0, 0, 0, 40)
    soonLbl.BackgroundTransparency = 1
    soonLbl.Text = "soon..."
    soonLbl.TextColor3 = Style.textDim
    soonLbl.Font = Enum.Font.GothamBold
    soonLbl.TextSize = 14
    soonLbl.Parent = col3

    -- === PAGE 3: MISC ===
    local miscPage = pages[3]
    
    local mCol = Instance.new("Frame")
    mCol.Size = UDim2.new(0.31, 0, 1, 0)
    mCol.BackgroundTransparency = 1
    mCol.Parent = miscPage

    createToggle(mCol, "miscSpeed", 5, Config.Speedhack, function(s) Config.Speedhack = s end)
    createSlider(mCol, "miscSpeedV", 45, Config.SpeedVal, 16, 300, function(v) Config.SpeedVal = v end)

    createToggle(mCol, "miscFly", 95, Config.Fly, function(s) 
        Config.Fly = s
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if s and hrp then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity", hrp)
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Velocity = Vector3.new(0,0,0)
            end
        else
            if flyBV then flyBV:Destroy() flyBV = nil end
        end
    end)
    createSlider(mCol, "miscFlyV", 135, Config.FlyVal, 10, 300, function(v) Config.FlyVal = v end)

    createToggle(mCol, "miscJump", 185, Config.InfJump, function(s) Config.InfJump = s end)
    createToggle(mCol, "miscBhop", 225, Config.Bhop, function(s) Config.Bhop = s end)
    createToggle(mCol, "miscNoclip", 265, Config.Noclip, function(s) 
        Config.Noclip = s
        local char = LP.Character
        if not s and char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end)

    local cCol = Instance.new("Frame")
    cCol.Size = UDim2.new(0.31, 0, 1, 0)
    cCol.Position = UDim2.new(0.345, 0, 0, 0)
    cCol.BackgroundTransparency = 1
    cCol.Parent = miscPage

    createToggle(cCol, "miscSpin", 5, Config.Spinbot, function(s) Config.Spinbot = s end)

    local oCol = Instance.new("Frame")
    oCol.Size = UDim2.new(0.31, 0, 1, 0)
    oCol.Position = UDim2.new(0.69, 0, 0, 0)
    oCol.BackgroundTransparency = 1
    oCol.Parent = miscPage

    createToggle(oCol, "miscInv", 5, Config.Invisible, function(s) Config.Invisible = s end)

    -- === PAGE 4: SETTINGS ===
    local settingsPage = pages[4]

    local menuBindBtn = Instance.new("TextButton")
    menuBindBtn.Size = UDim2.new(0.6, 0, 0, 35)
    menuBindBtn.Position = UDim2.new(0.05, 0, 0, 20)
    menuBindBtn.BackgroundColor3 = Style.bgElement
    menuBindBtn.TextColor3 = Style.text
    menuBindBtn.Font = Enum.Font.GothamBold
    menuBindBtn.TextSize = 12
    menuBindBtn.Parent = settingsPage
    Instance.new("UICorner", menuBindBtn).CornerRadius = UDim.new(0, 4)
    
    local function updateMenuBindBtn()
        menuBindBtn.Text = getLang("setMenuKey") .. formatKey(Config.MenuKey)
    end
    table.insert(uiElements, {obj = menuBindBtn, key = "setMenuKey", type = "MENU_BIND"})
    updateMenuBindBtn()

    menuBindBtn.MouseButton1Click:Connect(function()
        isBindingMenu = true
        menuBindBtn.Text = "..."
    end)

    local langLbl = Instance.new("TextLabel")
    langLbl.Size = UDim2.new(0.6, 0, 0, 20)
    langLbl.Position = UDim2.new(0.05, 0, 0, 70)
    langLbl.BackgroundTransparency = 1
    langLbl.Text = getLang("setLang")
    langLbl.TextColor3 = Style.text
    langLbl.Font = Enum.Font.GothamBold
    langLbl.TextSize = 12
    langLbl.TextXAlignment = Enum.TextXAlignment.Left
    langLbl.Parent = settingsPage
    table.insert(uiElements, {obj = langLbl, key = "setLang", type = "LABEL"})

    local langBtns = {}
    for i, lang in ipairs({"RU", "EN"}) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, 0, 0, 30)
        btn.Position = UDim2.new(0.05 + (i-1)*0.3, 0, 0, 95)
        btn.BackgroundColor3 = (Config.Lang == lang) and Style.acc or Style.toggOff
        btn.TextColor3 = Style.text
        btn.Text = (lang == "RU") and "🇷🇺 RU" or "🇬🇧 EN"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = settingsPage
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        langBtns[lang] = btn
        
        btn.MouseButton1Click:Connect(function()
            Config.Lang = lang
            for l, b in pairs(langBtns) do 
                b.BackgroundColor3 = (l == lang) and Style.acc or Style.toggOff
            end
            -- Обновляем текст
            for _, item in ipairs(uiElements) do
                if item.type == "MODE_BTN" then updateModeBtn()
                elseif item.type == "BIND_BTN" then updateBindBtn()
                elseif item.type == "MENU_BIND" then updateMenuBindBtn()
                elseif item.type == "SLIDER" then item.obj.Text = getLang(item.key) .. ": " .. item.obj.Text:match("[%d%.]+")
                else item.obj.Text = getLang(item.key) end
            end
        end)
    end

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.4, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.05, 0, 0, 150)
    saveBtn.BackgroundColor3 = Style.acc
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.Parent = settingsPage
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 4)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.4, 0, 0, 35)
    loadBtn.Position = UDim2.new(0.5, 0, 0, 150)
    loadBtn.BackgroundColor3 = Style.bgElement
    loadBtn.TextColor3 = Style.text
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.TextSize = 12
    loadBtn.Parent = settingsPage
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 4)

    local function updateConfigBtns()
        saveBtn.Text = getLang("setSave")
        loadBtn.Text = getLang("setLoad")
    end
    table.insert(uiElements, {obj = saveBtn, key = "setSave", type = "BTN"})
    table.insert(uiElements, {obj = loadBtn, key = "setLoad", type = "BTN"})
    updateConfigBtns()

    saveBtn.MouseButton1Click:Connect(function()
        if writefile then
            local saveData = serialize(Config)
            pcall(writefile, "merlo_v2_config.json", HttpService:JSONEncode(saveData))
            saveBtn.Text = "Saved!"
            task.delay(2, updateConfigBtns)
        end
    end)

    loadBtn.MouseButton1Click:Connect(function()
        if isfile and readfile and isfile("merlo_v2_config.json") then
            local succ, data = pcall(readfile, "merlo_v2_config.json")
            if succ and data then
                local succ2, tbl = pcall(function() return HttpService:JSONDecode(data) end)
                if succ2 and tbl then
                    local newCfg = deserialize(tbl)
                    for k, v in pairs(newCfg) do Config[k] = v end
                    
                    -- Обновляем UI
                    for _, item in ipairs(uiElements) do
                        if item.type == "MODE_BTN" then updateModeBtn()
                        elseif item.type == "BIND_BTN" then updateBindBtn()
                        elseif item.type == "MENU_BIND" then updateMenuBindBtn()
                        end
                    end
                    loadBtn.Text = "Loaded!"
                    task.delay(2, updateConfigBtns)
                end
            end
        end
    end)

    -- === PAGE 5: INFORMATION ===
    local infoPage = pages[5]

    local infoImg = Instance.new("ImageLabel")
    infoImg.Size = UDim2.new(0, 100, 0, 100)
    infoImg.Position = UDim2.new(0.5, -50, 0, 20)
    infoImg.BackgroundTransparency = 1
    infoImg.Image = "rbxassetid://6031090990"
    infoImg.ImageColor3 = Style.acc
    infoImg.Parent = infoPage

    local discordLbl = Instance.new("TextLabel")
    discordLbl.Size = UDim2.new(1, 0, 0, 20)
    discordLbl.Position = UDim2.new(0, 0, 0, 140)
    discordLbl.BackgroundTransparency = 1
    discordLbl.Text = getLang("infoDiscord")
    discordLbl.TextColor3 = Style.text
    discordLbl.Font = Enum.Font.GothamBold
    discordLbl.TextSize = 14
    discordLbl.Parent = infoPage
    table.insert(uiElements, {obj = discordLbl, key = "infoDiscord", type = "LABEL"})

    local devLbl = Instance.new("TextLabel")
    devLbl.Size = UDim2.new(1, 0, 0, 20)
    devLbl.Position = UDim2.new(0, 0, 0, 170)
    devLbl.BackgroundTransparency = 1
    devLbl.Text = getLang("infoDev")
    devLbl.TextColor3 = Style.text
    devLbl.Font = Enum.Font.GothamBold
    devLbl.TextSize = 14
    devLbl.Parent = infoPage
    table.insert(uiElements, {obj = devLbl, key = "infoDev", type = "LABEL"})

    local thanksLbl = Instance.new("TextLabel")
    thanksLbl.Size = UDim2.new(1, 0, 0, 20)
    thanksLbl.Position = UDim2.new(0, 0, 0, 210)
    thanksLbl.BackgroundTransparency = 1
    thanksLbl.Text = getLang("infoThanks")
    thanksLbl.TextColor3 = Style.acc
    thanksLbl.Font = Enum.Font.GothamBold
    thanksLbl.TextSize = 12
    thanksLbl.Parent = infoPage
    table.insert(uiElements, {obj = thanksLbl, key = "infoThanks", type = "LABEL"})

    -- === ЛОГИКА ===
    local function createDrawing(class, props)
        local obj = Drawing.new(class)
        for k, v in pairs(props) do obj[k] = v end
        table.insert(Drawings, obj)
        return obj
    end

    local function clearDrawings()
        for _, obj in ipairs(Drawings) do pcall(function() obj:Remove() end) end
        Drawings = {}
    end

    local function clearHighlights()
        for plr, hl in pairs(Highlights) do
            if hl then hl:Destroy() end
            Highlights[plr] = nil
        end
    end

    local function getRandomPart(char)
        local parts = {}
        if Config.TargetParts.Head then
            local h = char:FindFirstChild("Head")
            if h then table.insert(parts, h) end
        end
        if Config.TargetParts.Torso then
            local t = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if t then table.insert(parts, t) end
        end
        if Config.TargetParts.Arms then
            local r = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
            local l = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
            if r then table.insert(parts, r) end
            if l then table.insert(parts, l) end
        end
        if Config.TargetParts.Legs then
            local r = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
            local l = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
            if r then table.insert(parts, r) end
            if l then table.insert(parts, l) end
        end
        if #parts > 0 then return parts[math.random(1, #parts)] end
        return nil
    end

    local skeletonConns = {
        R15 = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}},
        R6 = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}
    }

    UIS.JumpRequest:Connect(function()
        if Config.InfJump and LP.Character then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if isBindingKey then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then return end
            isBindingKey = false
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Unknown then Config.AimKey = input.KeyCode end
            else
                Config.AimKey = input.UserInputType
            end
            updateBindBtn()
            return
        end
        
        if isBindingMenu then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    Config.MenuKey = input.KeyCode
                    isBindingMenu = false
                    updateMenuBindBtn()
                end
            end
            return
        end

        if gp then return end
        
        local isKey = false
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Config.AimKey then isKey = true end
        elseif input.UserInputType == Config.AimKey then
            isKey = true
        end

        if isKey then
            if Config.AimKeyMode == "HOLD" then
                isAimHeld = true
            elseif Config.AimKeyMode == "TOGGLE" then
                aimToggled = not aimToggled
            end
        end

        if input.KeyCode == Config.MenuKey then
            main.Visible = not main.Visible
        end
    end)
    
    UIS.InputEnded:Connect(function(input, gp)
        local isKey = false
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Config.AimKey then isKey = true end
        elseif input.UserInputType == Config.AimKey then
            isKey = true
        end

        if isKey and Config.AimKeyMode == "HOLD" then
            isAimHeld = false
        end
    end)

    pcall(function() RunService:UnbindFromRenderStep("MerloAim") end)
    RunService:BindToRenderStep("MerloAim", Enum.RenderPriority.Camera.Value + 2, function()
        if not isRunning then return end
        if not Config.AimbotEnabled then 
            currentTargetPlr = nil
            currentTargetPart = nil
            return 
        end

        local isAiming = (Config.AimKeyMode == "HOLD" and isAimHeld) or (Config.AimKeyMode == "TOGGLE" and aimToggled)
        
        if not isAiming then 
            currentTargetPlr = nil
            currentTargetPart = nil
            return 
        end
        
        local valid = currentTargetPlr and currentTargetPlr.Parent and currentTargetPlr.Character 
            and currentTargetPlr.Character:FindFirstChild("Humanoid") and currentTargetPlr.Character.Humanoid.Health > 0
            and currentTargetPart and currentTargetPart.Parent and currentTargetPart:IsDescendantOf(currentTargetPlr.Character)
        
        if not valid then
            currentTargetPlr = nil
            currentTargetPart = nil
            local center = Camera.ViewportSize / 2
            local bestDist = Config.FOV
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local part = getRandomPart(plr.Character)
                        if part then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                if dist < bestDist then
                                    local visible = true
                                    if Config.VisibleCheck then
                                        local rayParams = RaycastParams.new()
                                        rayParams.FilterDescendantsInstances = {LP.Character, plr.Character}
                                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                        local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
                                        if result then visible = false end
                                    end
                                    if visible then bestDist = dist; currentTargetPlr = plr; currentTargetPart = part end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if currentTargetPlr and currentTargetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, currentTargetPart.Position)
            if Config.Humanize then
                local t = tick()
                local humX = math.sin(t * 8) * 0.015
                local humY = math.cos(t * 6) * 0.015
                targetCFrame = targetCFrame * CFrame.Angles(humX, humY, 0)
            end
            local alpha = math.clamp(0.1 / Config.Smoothness, 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
        end
    end)

    RenderConn = RunService.RenderStepped:Connect(function()
        if not isRunning then return end
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and hrp then
            if Config.Speedhack then
                if not speedBV then
                    speedBV = Instance.new("BodyVelocity", hrp)
                    speedBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
                end
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    speedBV.Velocity = moveDir * Config.SpeedVal
                else
                    speedBV.Velocity = Vector3.new(0,0,0)
                end
            else
                if speedBV then speedBV:Destroy() speedBV = nil end
            end
            
            if Config.Bhop and UIS:IsKeyDown(Enum.KeyCode.Space) then
                if hum:GetState() == Enum.HumanoidStateType.Landed or hum:GetState() == Enum.HumanoidStateType.Running then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            
            if Config.Noclip then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
            
            if Config.Fly and flyBV then
                local moveDir = Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                flyBV.Velocity = moveDir * Config.FlyVal
            end
            
            -- Невидимость (ИСПРАВЛЕНО: убран LocalTransparencyModifier = 0 при выключении)
            if Config.Invisible then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                        pcall(function() v.LocalTransparencyModifier = 1 end)
                    end
                end
            else
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if v.Name == "HumanoidRootPart" then 
                            v.Transparency = 1 
                        else 
                            v.Transparency = 0 
                        end
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 0
                    end
                end
            end

            if Config.Spinbot then
                local savedCam = Camera.CFrame
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(15), 0)
                Camera.CFrame = savedCam
            end
        end

        -- ESP
        if not Config.ESP then
            clearDrawings()
            clearHighlights()
        else
            clearDrawings()
            if not Config.Chams then clearHighlights() end

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                    local pChar = plr.Character
                    local pHrp = pChar:FindFirstChild("HumanoidRootPart")
                    local pHead = pChar:FindFirstChild("Head")
                    local pHum = pChar:FindFirstChild("Humanoid")
                    if pHrp and pHead and pHum then
                        if Config.Chams then
                            if not Highlights[plr] then
                                local hl = Instance.new("Highlight")
                                hl.Parent = gui
                                Highlights[plr] = hl
                            end
                            Highlights[plr].Adornee = pChar
                            Highlights[plr].FillColor = Config.Color
                            Highlights[plr].OutlineColor = Color3.fromRGB(255,255,255)
                            Highlights[plr].FillTransparency = 0.5
                            Highlights[plr].DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        local headPos, onScreen = Camera:WorldToViewportPoint(pHead.Position)
                        if onScreen then
                            if Config.Box then
                                local top, _ = Camera:WorldToViewportPoint(pHead.Position + Vector3.new(0,0.5,0))
                                local bot, _ = Camera:WorldToViewportPoint(pHrp.Position - Vector3.new(0,3,0))
                                local h = math.abs(top.Y - bot.Y)
                                local w = h / 2
                                createDrawing("Square", {Size = Vector2.new(w, h), Position = Vector2.new(top.X - w/2, top.Y), Thickness = 1, Color = Config.Color, Filled = false, Visible = true})
                            end
                            if Config.Tracers then
                                createDrawing("Line", {From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), To = Vector2.new(headPos.X, headPos.Y), Thickness = 1, Color = Config.Color, Visible = true})
                            end
                            if Config.Name or Config.Distance then
                                local dist = math.floor((Camera.CFrame.Position - pHead.Position).Magnitude)
                                local text = ""
                                if Config.Name then text = plr.Name end
                                if Config.Distance then 
                                    if Config.Name then text = text .. " [" .. dist .. "m]" else text = "[" .. dist .. "m]" end
                                end
                                createDrawing("Text", {Text = text, Position = Vector2.new(headPos.X, headPos.Y - 40), Size = 13, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Color = Color3.new(1,1,1), Visible = true})
                            end
                            if Config.HealthBar then
                                local hpPercent = math.clamp(pHum.Health / pHum.MaxHealth, 0, 1)
                                local barWidth = 50; local barHeight = 4
                                local barPos = Vector2.new(headPos.X - barWidth/2, headPos.Y - 25)
                                createDrawing("Square", {Size = Vector2.new(barWidth, barHeight), Position = barPos, Color = Color3.new(0,0,0), Thickness = 0, Filled = true, Visible = true})
                                local hpColor = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                                createDrawing("Square", {Size = Vector2.new(barWidth * hpPercent, barHeight), Position = barPos, Color = hpColor, Thickness = 0, Filled = true, Visible = true})
                            end
                            if Config.Skeleton then
                                local rigType = pHum.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"
                                for _, conn in ipairs(skeletonConns[rigType]) do
                                    local p1 = pChar:FindFirstChild(conn[1])
                                    local p2 = pChar:FindFirstChild(conn[2])
                                    if p1 and p2 then
                                        local sp1, v1 = Camera:WorldToViewportPoint(p1.Position)
                                        local sp2, v2 = Camera:WorldToViewportPoint(p2.Position)
                                        if v1 and v2 then
                                            createDrawing("Line", {From = Vector2.new(sp1.X, sp1.Y), To = Vector2.new(sp2.X, sp2.Y), Thickness = 1, Color = Config.Color, Visible = true})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    switchTab(1)
end

loadMainScript()
print("[merlo V2] Loaded. Fixed Invisible Glitch, Configs working.")