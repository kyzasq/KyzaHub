-- ======================================================
-- KyzaHub
-- by Kyza
-- ======================================================

local KyzaUI = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local originalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    FogColor = Lighting.FogColor,
    TimeOfDay = Lighting.TimeOfDay,
}

local savedFog = {
    End = Lighting.FogEnd,
    Start = Lighting.FogStart,
    Color = Lighting.FogColor,
}

local savedAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
local savedAtmoProps = savedAtmo and {
    Color = savedAtmo.Color,
    Decay = savedAtmo.Decay,
    Density = savedAtmo.Density,
    Glare = savedAtmo.Glare,
    Haze = savedAtmo.Haze,
    Offset = savedAtmo.Offset,
} or nil

-- ============================================
-- CLEANUP
-- ============================================
local function cleanupCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj.Name:find("Kyza_") then
            pcall(function() obj:Destroy() end)
        end
    end
end
task.spawn(function()
    task.wait(0.5)
    cleanupCharacter()
end)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    cleanupCharacter()
end)

-- ============================================
-- CONFIG
-- ============================================
local CONFIG_FILE = "kyzahub_config.json"
local AUTO_SAVE_FILE = "kyzahub_autosave.json"

local Config = {
    ESP = false, EspBoxes = false, GunDropESP = false, NameTags = false,
    TimeOfDay = 14, Fullbright = false,
    AutoShoot = false, Aimlock = false, SilentAim = false,
    AutoDodge = false, KillAura = false, KillAuraRange = 25,
    AutoGrab = false, SlideGlitch = false, SlideSpeed = 45,
    Noclip = false, AntiFling = false, GodMode = false,
    AntiHit = false, IgnoreWall = false,
    EmoteSpam = false, ChatAlerts = false,
    AutoJump = false, InfJump = false, MultiJump = false,
    Bhop = false, BhopBoost = 50,
    Speed = 16, JumpPower = 50,
    FOV = 70, FlingAll = false, Fly = false, FlySpeed = 50,
    AutoSave = true,
    ShowBinds = false,
    ShowWatermark = true,
    EnvVisuals = false,
    Spin = false, SpinSpeed = 20,
    FogEnabled = false, FogDensity = 1, FogColor = Color3.fromRGB(100, 100, 120),
    NoFog = false,
    SkyColorEnabled = false, SkyColor = Color3.fromRGB(120, 170, 255),
    PlasmaShader = false, PlasmaIntensity = 1,
    CustomShootSound = false, CustomShootId = "rbxassetid://9125402735",
    CustomKillSound = false, CustomKillId = "rbxassetid://5803122751",
    HitmarkerSound = false, HitmarkerId = "rbxassetid://876939830",
    BindFlingTarget = "", BindFlingMurderer = "", BindFlingSheriff = "",
    BindInfiniteFling = "", BindFlingAll = "", BindReturn = "",
    BindTpLobby = "", BindTpMap = "", BindTpPlayer = "", BindBringPlayer = "",
    BindFly = "", BindBhop = "", BindNoclip = "", BindSlideGlitch = "",
    BindAutoGrab = "", BindShootMurderer = "", BindAutoShoot = "", BindAimlock = "",
    BindSilentAim = "", BindAutoDodge = "", BindKillAura = "", BindKillAll = "",
    BindAntiFling = "", BindEmoteSpam = "", BindMultiJump = "", BindInfJump = "",
    BindAutoJump = "", BindESP = "", BindNameTags = "", BindFullbright = "",
    BindGodMode = "", BindSpin = "", BindEnvVisuals = "",
    BindAntiHit = "", BindIgnoreWall = "",
    BindFog = "", BindPlasma = "", BindSky = "",
}

local function saveConfig(filename)
    filename = filename or CONFIG_FILE
    if not writefile then return false, "writefile не поддерживается" end
    local ok, err = pcall(function() writefile(filename, HttpService:JSONEncode(Config)) end)
    if ok then return true else return false, err end
end
local function loadConfig(filename)
    filename = filename or CONFIG_FILE
    if not (readfile and isfile) then return false, "readfile не поддерживается" end
    if not isfile(filename) then return false, "Файл не найден" end
    local ok, err = pcall(function()
        local data = HttpService:JSONDecode(readfile(filename))
        for k, v in pairs(data) do
            if Config[k] ~= nil then Config[k] = v end
        end
    end)
    if ok then return true else return false, err end
end
local function deleteConfig(filename)
    if delfile and isfile and isfile(filename) then pcall(function() delfile(filename) end) end
end

pcall(function()
    game:BindToClose(function()
        if Config.AutoSave then saveConfig(AUTO_SAVE_FILE) end
    end)
end)

-- ============================================
-- WINDOW
-- ============================================
local Window = KyzaUI:CreateWindow({
    name = "KyzaHub",
    subtitle = "by Kyza",
    sidebarLayout = true,
    configuration = { autoSave = false },
})

local VisualsTab  = Window:CreateTab({ name = "Визуалы", icon = "eye" })
local CombatTab   = Window:CreateTab({ name = "Бойня", icon = "zap" })
local PlayerTab   = Window:CreateTab({ name = "Игроки", icon = "user" })
local TrollTab    = Window:CreateTab({ name = "Троллинг", icon = "alert" })
local UtilityTab  = Window:CreateTab({ name = "Утилиты", icon = "tool" })
local SoundTab    = Window:CreateTab({ name = "Звуки", icon = "music" })
local TpTab       = Window:CreateTab({ name = "Телепорты", icon = "map" })
local BindsTab    = Window:CreateTab({ name = "Бинды", icon = "keyboard" })
local ConfigTab   = Window:CreateTab({ name = "Конфиг", icon = "save" })

-- ============================================
-- HELPERS
-- ============================================
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function notify(t, c) Window:Notify({ title = t, content = c }) end

-- ============================================
-- WATERMARK
-- ============================================
local wmGui = Instance.new("ScreenGui")
wmGui.Name = "KyzaHub_Watermark"
wmGui.ResetOnSpawn = false
wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
wmGui.IgnoreGuiInset = true
wmGui.Parent = game:GetService("CoreGui")

local wmFrame = Instance.new("Frame")
wmFrame.Size = UDim2.new(0, 0, 0, 34)
wmFrame.AutomaticSize = Enum.AutomaticSize.X
wmFrame.Position = UDim2.new(0, 20, 0, 60)
wmFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
wmFrame.BackgroundTransparency = 0.05
wmFrame.BorderSizePixel = 0
wmFrame.Active = true
wmFrame.Parent = wmGui

local wmCorner = Instance.new("UICorner")
wmCorner.CornerRadius = UDim.new(0, 8)
wmCorner.Parent = wmFrame

local wmStroke = Instance.new("UIStroke")
wmStroke.Color = Color3.fromRGB(45, 45, 60)
wmStroke.Thickness = 1
wmStroke.Parent = wmFrame

local wmPad = Instance.new("UIPadding")
wmPad.PaddingLeft = UDim.new(0, 10)
wmPad.PaddingRight = UDim.new(0, 12)
wmPad.PaddingTop = UDim.new(0, 4)
wmPad.PaddingBottom = UDim.new(0, 4)
wmPad.Parent = wmFrame

local wmLayout = Instance.new("UIListLayout")
wmLayout.FillDirection = Enum.FillDirection.Horizontal
wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
wmLayout.SortOrder = Enum.SortOrder.LayoutOrder
wmLayout.Padding = UDim.new(0, 8)
wmLayout.Parent = wmFrame

local wmIcon = Instance.new("ImageLabel")
wmIcon.Size = UDim2.new(0, 18, 0, 18)
wmIcon.BackgroundTransparency = 1
wmIcon.Image = "rbxassetid://10709789417"
wmIcon.ImageColor3 = Color3.fromRGB(65, 130, 255)
wmIcon.LayoutOrder = 1
wmIcon.Parent = wmFrame

local wmFps = Instance.new("TextLabel")
wmFps.Size = UDim2.new(0, 0, 1, 0)
wmFps.AutomaticSize = Enum.AutomaticSize.X
wmFps.BackgroundTransparency = 1
wmFps.Text = "0 fps"
wmFps.TextColor3 = Color3.fromRGB(240, 240, 245)
wmFps.TextSize = 13
wmFps.Font = Enum.Font.GothamBold
wmFps.TextXAlignment = Enum.TextXAlignment.Left
wmFps.LayoutOrder = 2
wmFps.Parent = wmFrame

local wmNet = Instance.new("ImageLabel")
wmNet.Size = UDim2.new(0, 16, 0, 16)
wmNet.BackgroundTransparency = 1
wmNet.Image = "rbxassetid://10709790486"
wmNet.ImageColor3 = Color3.fromRGB(65, 130, 255)
wmNet.LayoutOrder = 3
wmNet.Parent = wmFrame

local wmPing = Instance.new("TextLabel")
wmPing.Size = UDim2.new(0, 0, 1, 0)
wmPing.AutomaticSize = Enum.AutomaticSize.X
wmPing.BackgroundTransparency = 1
wmPing.Text = "0 ms"
wmPing.TextColor3 = Color3.fromRGB(240, 240, 245)
wmPing.TextSize = 13
wmPing.Font = Enum.Font.GothamBold
wmPing.TextXAlignment = Enum.TextXAlignment.Left
wmPing.LayoutOrder = 4
wmPing.Parent = wmFrame

local wmLogo = Instance.new("ImageLabel")
wmLogo.Size = UDim2.new(0, 16, 0, 16)
wmLogo.BackgroundTransparency = 1
wmLogo.Image = "rbxassetid://10709789417"
wmLogo.ImageColor3 = Color3.fromRGB(65, 130, 255)
wmLogo.LayoutOrder = 5
wmLogo.Parent = wmFrame

local wmName = Instance.new("TextLabel")
wmName.Size = UDim2.new(0, 0, 1, 0)
wmName.AutomaticSize = Enum.AutomaticSize.X
wmName.BackgroundTransparency = 1
wmName.Text = "KyzaHub"
wmName.TextColor3 = Color3.fromRGB(65, 130, 255)
wmName.TextSize = 14
wmName.Font = Enum.Font.GothamBold
wmName.TextXAlignment = Enum.TextXAlignment.Left
wmName.LayoutOrder = 6
wmName.Parent = wmFrame

local wmDrag, wmStart, wmPos
wmFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        wmDrag = true; wmStart = input.Position; wmPos = wmFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if wmDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - wmStart
        wmFrame.Position = UDim2.new(wmPos.X.Scale, wmPos.X.Offset + d.X, wmPos.Y.Scale, wmPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        wmDrag = false
    end
end)

local fpsCounter = 0
RunService.RenderStepped:Connect(function() fpsCounter = fpsCounter + 1 end)
task.spawn(function()
    while true do
        task.wait(0.5)
        local fps = math.floor(fpsCounter / 0.5)
        fpsCounter = 0
        if Config.ShowWatermark then
            wmFrame.Visible = true
            wmFps.Text = fps .. " fps"
            local ping = 0
            pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            wmPing.Text = ping .. " ms"
        else
            wmFrame.Visible = false
        end
    end
end)

-- ============================================
-- STATE
-- ============================================
local ROLE_COLORS = {
    murderer = Color3.fromRGB(255, 50, 50),
    sheriff  = Color3.fromRGB(50, 130, 255),
    hero     = Color3.fromRGB(255, 220, 50),
    innocent = Color3.fromRGB(240, 240, 240),
    dead     = Color3.fromRGB(140, 140, 140),
}

local roles = {}
local Murder, Sheriff, Hero = nil, nil, nil
local selectedPlayer = nil
local lastDodgeTime = 0
local lastAuraTime = 0
local gunRemoteCache = nil
local lastMurder, lastSheriff = nil, nil
local autoFlingConn = nil
local infiniteFlingTargetConn = nil
local infiniteFlingTargetEnabled = false
local lastFlingTime = 0
local savedReturnPos = nil

local flyBV, flyBG, flyConn = nil, nil, nil
local flyKeys = {}

local multiJumpEnabled = false
local multiJumpMax = 2
local jumpsUsed = 0
local multiJumpConnection = nil

local infJumpEnabled = false
local infJumpConnection = nil

local bhopEnabled = false
local bhopConn = nil
local bhopBoost = 50

local godModeConn = nil
local guardConn = nil
local spinConn = nil
local envFolder = nil
local customSoundFolder = nil
local antiHitConn = nil
local ignoreWallConn = nil

local plasmaFolder = nil
local plasmaConn = nil
local plasmaHue = 0
local fogRestoreConn = nil

local firefliesFolder = nil
local firefliesConn = nil

local UI = { Visuals = {}, Combat = {}, Player = {}, Troll = {}, Utility = {}, Sounds = {}, Tp = {}, Binds = {} }

local function setToggle(element, value)
    if element and element.Set then pcall(function() element:Set(value) end) end
end
local function setSlider(element, value)
    if element and element.Set then pcall(function() element:Set(value) end) end
end
local function setInput(element, value)
    if element and element.Set then pcall(function() element:Set(value) end) end
end

-- ============================================
-- FULLBRIGHT
-- ============================================
local function enableFullbright()
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
end
local function disableFullbright()
    Lighting.Ambient = originalLighting.Ambient
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Brightness = originalLighting.Brightness
    Lighting.GlobalShadows = originalLighting.GlobalShadows
end

-- ============================================
-- ENV VISUALS
-- ============================================
local function enableEnvVisuals()
    if envFolder then envFolder:Destroy() end
    envFolder = Instance.new("Folder")
    envFolder.Name = "Kyza_EnvVisuals"
    envFolder.Parent = Lighting

    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 1.2
    bloom.Size = 28
    bloom.Threshold = 0.7
    bloom.Parent = envFolder

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Brightness = 0.08
    cc.Contrast = 0.12
    cc.Saturation = 0.35
    cc.TintColor = Color3.fromRGB(255, 250, 240)
    cc.Parent = envFolder

    local sun = Instance.new("SunRaysEffect")
    sun.Intensity = 0.15
    sun.Spread = 0.9
    sun.Parent = envFolder

    local dof = Instance.new("DepthOfFieldEffect")
    dof.FarIntensity = 0.15
    dof.FocusDistance = 30
    dof.InFocusRadius = 25
    dof.NearIntensity = 0.5
    dof.Parent = envFolder

    if firefliesFolder then firefliesFolder:Destroy() end
    firefliesFolder = Instance.new("Folder")
    firefliesFolder.Name = "Kyza_Fireflies"
    firefliesFolder.Parent = workspace

    local FIREFLY_COUNT = 40
    local FIREFLY_RADIUS = 60
    local FIREFLY_COLOR = Color3.fromRGB(255, 240, 120)

    local fireflies = {}
    for i = 1, FIREFLY_COUNT do
        local part = Instance.new("Part")
        part.Name = "Firefly"
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(0.3, 0.3, 0.3)
        part.Material = Enum.Material.Neon
        part.Color = FIREFLY_COLOR
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Transparency = 0.1
        part.Parent = firefliesFolder

        local light = Instance.new("PointLight")
        light.Color = FIREFLY_COLOR
        light.Brightness = 2
        light.Range = 8
        light.Shadows = false
        light.Parent = part

        local angle = math.random() * math.pi * 2
        local radius = math.random(10, FIREFLY_RADIUS)
        local height = math.random(-5, 15)
        part.Position = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)

        table.insert(fireflies, {
            part = part,
            baseAngle = angle,
            baseRadius = radius,
            baseHeight = height,
            speed = 0.3 + math.random() * 0.5,
            bobSpeed = 0.8 + math.random() * 0.7,
            phase = math.random() * math.pi * 2
        })
    end

    if firefliesConn then firefliesConn:Disconnect() end
    firefliesConn = RunService.Heartbeat:Connect(function(dt)
        if not Config.EnvVisuals then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local centerPos = hrp.Position
        for _, f in ipairs(fireflies) do
            if f.part and f.part.Parent then
                f.baseAngle = f.baseAngle + dt * f.speed
                f.phase = f.phase + dt * f.bobSpeed
                local radius = f.baseRadius + math.sin(f.phase) * 5
                local x = centerPos.X + math.cos(f.baseAngle) * radius
                local z = centerPos.Z + math.sin(f.baseAngle) * radius
                local y = centerPos.Y + f.baseHeight + math.sin(f.phase * 1.5) * 2
                f.part.Position = Vector3.new(x, y, z)
                f.part.Transparency = 0.1 + math.sin(f.phase * 2) * 0.15
            end
        end
    end)
end

local function disableEnvVisuals()
    if envFolder then envFolder:Destroy(); envFolder = nil end
    if firefliesFolder then firefliesFolder:Destroy(); firefliesFolder = nil end
    if firefliesConn then firefliesConn:Disconnect(); firefliesConn = nil end
end

-- ============================================
-- FOG
-- ============================================
local function applyFog()
    if fogRestoreConn then fogRestoreConn:Disconnect(); fogRestoreConn = nil end

    if Config.SkyColorEnabled then
        fogRestoreConn = RunService.Heartbeat:Connect(function()
            if not Config.SkyColorEnabled then return end
            Lighting.FogStart = 0
            if Config.FogEnabled then
                Lighting.FogColor = Config.FogColor
                Lighting.FogEnd = 500 / Config.FogDensity
            else
                Lighting.FogColor = Config.SkyColor
                Lighting.FogEnd = 500
            end
        end)
        return
    end

    if not Config.FogEnabled and not Config.NoFog then
        fogRestoreConn = RunService.Heartbeat:Connect(function()
            if Config.FogEnabled or Config.NoFog or Config.SkyColorEnabled then return end
            Lighting.FogEnd = savedFog.End
            Lighting.FogStart = savedFog.Start
            Lighting.FogColor = savedFog.Color
        end)
        return
    end

    if Config.NoFog then
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        return
    end

    Lighting.FogColor = Config.FogColor
    Lighting.FogStart = 0
    Lighting.FogEnd = 500 / Config.FogDensity
end

-- ============================================
-- SKY COLOR
-- ============================================
local skySphereFolder = nil
local skySphereConn = nil
local skyParts = {}

local SKY_RADIUS = 900
local SKY_TOP = 900
local SKY_BOTTOM = 300

local function makeSkyPart(size, offset, name)
    local p = Instance.new("Part")
    p.Name = name or "SkyPiece"
    p.Size = size
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Massless = true
    p.Locked = true
    p.Reflectance = 0
    p.Material = Enum.Material.SmoothPlastic
    p.Color = Config.SkyColor
    p.Transparency = 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = skySphereFolder
    table.insert(skyParts, { part = p, offset = offset })
    return p
end

local function createSkyBox()
    for _, e in ipairs(skyParts) do pcall(function() e.part:Destroy() end) end
    skyParts = {}
    if skySphereFolder then pcall(function() skySphereFolder:Destroy() end) end
    skySphereFolder = Instance.new("Folder")
    skySphereFolder.Name = "Kyza_SkyColor"
    skySphereFolder.Parent = workspace

    local R = SKY_RADIUS
    local H = SKY_TOP + SKY_BOTTOM
    local midY = (SKY_TOP - SKY_BOTTOM) / 2

    makeSkyPart(Vector3.new(R * 2, 2, R * 2), Vector3.new(0, SKY_TOP, 0), "SkyTop")
    makeSkyPart(Vector3.new(R * 2, H, 2), Vector3.new(0, midY, -R), "SkyWallN")
    makeSkyPart(Vector3.new(R * 2, H, 2), Vector3.new(0, midY, R), "SkyWallS")
    makeSkyPart(Vector3.new(2, H, R * 2), Vector3.new(R, midY, 0), "SkyWallE")
    makeSkyPart(Vector3.new(2, H, R * 2), Vector3.new(-R, midY, 0), "SkyWallW")
end

local function updateSkyPositions()
    local base
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        base = hrp.Position
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        base = cam.CFrame.Position
    end
    for _, e in ipairs(skyParts) do
        if e.part and e.part.Parent then
            e.part.CFrame = CFrame.new(base + e.offset)
            e.part.Color = Config.SkyColor
        end
    end
end

local function startSkyFollow()
    if skySphereConn then skySphereConn:Disconnect() end
    skySphereConn = RunService.RenderStepped:Connect(function()
        if not Config.SkyColorEnabled then return end
        if #skyParts == 0 or not (skySphereFolder and skySphereFolder.Parent) then
            createSkyBox()
        end
        updateSkyPositions()
    end)
end

local function applySky()
    local ok, err = pcall(function()
        if Config.SkyColorEnabled then
            createSkyBox()
            updateSkyPositions()
            startSkyFollow()
            applyFog()
            notify("Небо", "ВКЛ — цвет: " .. tostring(Config.SkyColor))
        else
            if skySphereConn then skySphereConn:Disconnect(); skySphereConn = nil end
            if skySphereFolder then pcall(function() skySphereFolder:Destroy() end); skySphereFolder = nil end
            skyParts = {}
            applyFog()
        end
    end)
    if not ok then notify("Небо", "Ошибка: " .. tostring(err)) end
end


-- ============================================
-- PLASMA
-- ============================================
local function startPlasmaShader()
    if plasmaFolder then plasmaFolder:Destroy() end
    plasmaFolder = Instance.new("Folder")
    plasmaFolder.Name = "Kyza_PlasmaShader"
    plasmaFolder.Parent = Lighting

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "Kyza_PlasmaCC"
    cc.Brightness = 0.05
    cc.Contrast = 0.3
    cc.Saturation = 0.7
    cc.Parent = plasmaFolder

    local bloom = Instance.new("BloomEffect")
    bloom.Name = "Kyza_PlasmaBloom"
    bloom.Intensity = 1.2
    bloom.Size = 32
    bloom.Threshold = 0.7
    bloom.Parent = plasmaFolder

    local blur = Instance.new("BlurEffect")
    blur.Name = "Kyza_PlasmaBlur"
    blur.Size = 4
    blur.Parent = plasmaFolder

    plasmaHue = 0
    if plasmaConn then plasmaConn:Disconnect() end
    plasmaConn = RunService.Heartbeat:Connect(function(dt)
        if not Config.PlasmaShader then return end
        plasmaHue = (plasmaHue + dt * 0.15 * Config.PlasmaIntensity) % 1
        local color = Color3.fromHSV(plasmaHue, 0.8, 1)
        cc.TintColor = color
        bloom.Intensity = 1 + math.sin(tick() * 2) * 0.4 * Config.PlasmaIntensity
    end)
end

local function stopPlasmaShader()
    Config.PlasmaShader = false
    if plasmaConn then plasmaConn:Disconnect(); plasmaConn = nil end
    if plasmaFolder then plasmaFolder:Destroy(); plasmaFolder = nil end
end

-- ============================================
-- ROLES
-- ============================================
local function updateRoles()
    local success, serverRoles = pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        return remote and remote:InvokeServer()
    end)
    local tempM, tempS, tempH = nil, nil, nil
    if success and serverRoles then
        roles = serverRoles
        for i, v in pairs(roles) do
            if v.Role == "Murderer" then tempM = i
            elseif v.Role == "Sheriff" then tempS = i
            elseif v.Role == "Hero" then tempH = i end
        end
    end
    Murder, Sheriff, Hero = tempM, tempS, tempH
end
local function getPlayerRole(player)
    if roles and roles[player.Name] then
        local r = roles[player.Name].Role
        if r == "Murderer" then return "murderer" end
        if r == "Sheriff" then return "sheriff" end
        if r == "Hero" then return "hero" end
        if r == "Innocent" then return "innocent" end
    end
    if Murder and player.Name == Murder then return "murderer" end
    if Sheriff and player.Name == Sheriff then return "sheriff" end
    if Hero and player.Name == Hero then return "hero" end
    local char = player.Character
    if char then
        local bp = player:FindFirstChild("Backpack")
        local hasKnife = char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))
        local hasGun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
        if hasKnife then return "murderer" end
        if hasGun then return "sheriff" end
    end
    return "innocent"
end
local function IsAlive(player)
    local data = roles and roles[player.Name]
    if data then return not data.Killed and not data.Dead end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end
local function hasTool(player, name)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end
local function getMurderer()
    if Murder then
        local p = Players:FindFirstChild(Murder)
        if p and p.Character then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and hasTool(p, "Knife") then return p end
    end
    return nil
end
local function getSheriff()
    if Sheriff then
        local p = Players:FindFirstChild(Sheriff)
        if p and p.Character then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (hasTool(p, "Gun") or hasTool(p, "Revolver")) then return p end
    end
    return nil
end

-- ============================================
-- RAYCAST
-- ============================================
local function isVisible(targetPart)
    local char = LocalPlayer.Character
    if not char then return false end
    local origin = char:FindFirstChild("Head") and char.Head.Position or char:GetPivot().Position
    local dir = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

-- ============================================
-- GUN / AIM HELPERS
-- ============================================
local function getHeldGun()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("gun") or n:find("revolver") or n:find("pistol")
                or t:FindFirstChild("Shoot") or t:FindFirstChild("Fire") then
                return t
            end
        end
    end
    return nil
end

local function getGunRemotes(gun)
    local list = {}
    if not gun then return list end
    if gunRemoteCache and gunRemoteCache.Parent and gunRemoteCache:IsDescendantOf(gun) then
        table.insert(list, gunRemoteCache)
    end
    for _, d in ipairs(gun:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            table.insert(list, d)
        end
    end
    for _, nm in ipairs({ "Shoot", "Fire", "ShootGun" }) do
        local c = gun:FindFirstChild(nm, true)
        if c and (c:IsA("RemoteEvent") or c:IsA("RemoteFunction")) then
            table.insert(list, c)
        end
    end
    return list
end

local function fireGunAt(targetHRP)
    if not targetHRP then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local gun = getHeldGun()
    if not gun then return false end
    local targetPos = targetHRP.Position
    local targetCF = CFrame.new(targetPos)
    local aimCF = targetCF
    if (hrp.Position - targetPos).Magnitude > 0.01 then
        aimCF = CFrame.new(hrp.Position, targetPos)
    end
    local fired = false
    local seen = {}
    for _, remote in ipairs(getGunRemotes(gun)) do
        if not seen[remote] then
            seen[remote] = true
            local n = remote.Name:lower()
            if remote == gunRemoteCache or n:find("shoot") or n:find("fire") or n:find("gun") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(aimCF, targetCF)
                    else
                        remote:InvokeServer(aimCF, targetCF)
                    end
                end)
                fired = true
            end
        end
    end
    return fired
end

-- ============================================
-- RETURN
-- ============================================
local function saveReturnPosition()
    local hrp = getHRP()
    if hrp then savedReturnPos = hrp.CFrame; notify("Возвращение", "Позиция сохранена") end
end
local function returnToPosition()
    if not savedReturnPos then notify("Возвращение", "Сначала сохрани позицию"); return end
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = savedReturnPos
        hrp.Velocity = Vector3.new(0, 0, 0)
        notify("Возвращение", "Вернулся")
    end
end

-- ============================================
-- FLY
-- ============================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
    elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
    elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
    elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.Ctrl = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
    elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
    elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
    elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.Ctrl = false end
end)

local function stopFly()
    Config.Fly = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local hum = getHum(); if hum then hum.PlatformStand = false end
end
local function startFly()
    local char = getChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    if flyConn then flyConn:Disconnect() end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 1000; flyBG.D = 50
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
    hum.PlatformStand = true
    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.Fly then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local cam = workspace.CurrentCamera
        local moveVec = Vector3.new(0, 0, 0)
        if flyKeys.W then moveVec = moveVec + cam.CFrame.LookVector end
        if flyKeys.S then moveVec = moveVec - cam.CFrame.LookVector end
        if flyKeys.A then moveVec = moveVec - cam.CFrame.RightVector end
        if flyKeys.D then moveVec = moveVec + cam.CFrame.RightVector end
        if flyKeys.Space then moveVec = moveVec + Vector3.new(0, 1, 0) end
        if flyKeys.Ctrl then moveVec = moveVec - Vector3.new(0, 1, 0) end
        if moveVec.Magnitude > 0 then moveVec = moveVec.Unit * Config.FlySpeed end
        flyBV.Velocity = moveVec
        flyBG.CFrame = cam.CFrame
    end)
end

-- ============================================
-- BHOP
-- ============================================
local function startBhop()
    if bhopConn then bhopConn:Disconnect() end
    bhopConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not bhopEnabled then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Landed then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.Velocity = Vector3.new(moveDir.X * bhopBoost, math.max(hrp.Velocity.Y, 45), moveDir.Z * bhopBoost)
                end
            end
            if state == Enum.HumanoidStateType.Freefall and hum.MoveDirection.Magnitude > 0 then
                local vel = hrp.Velocity
                local horiz = Vector3.new(vel.X, 0, vel.Z)
                if horiz.Magnitude < bhopBoost then
                    local dir = hum.MoveDirection
                    hrp.Velocity = Vector3.new(dir.X * bhopBoost, vel.Y, dir.Z * bhopBoost)
                end
            end
        end)
    end)
end
local function stopBhop()
    bhopEnabled = false
    if bhopConn then bhopConn:Disconnect(); bhopConn = nil end
end

-- ============================================
-- MULTI JUMP / INF JUMP
-- ============================================
local function startMultiJump()
    if multiJumpConnection then multiJumpConnection:Disconnect() end
    jumpsUsed = 0
    multiJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not multiJumpEnabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Landed then
            jumpsUsed = 0; return
        end
        if state == Enum.HumanoidStateType.Freefall and jumpsUsed < multiJumpMax then
            jumpsUsed = jumpsUsed + 1
            hrp.Velocity = Vector3.new(hrp.Velocity.X, hum.JumpPower, hrp.Velocity.Z)
        end
    end)
    RunService.Heartbeat:Connect(function()
        if not multiJumpEnabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Landed then
            jumpsUsed = 0
        end
    end)
end
local function stopMultiJump()
    multiJumpEnabled = false
    if multiJumpConnection then multiJumpConnection:Disconnect(); multiJumpConnection = nil end
end
local function startInfJump()
    if infJumpConnection then infJumpConnection:Disconnect() end
    infJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not infJumpEnabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function stopInfJump()
    infJumpEnabled = false
    if infJumpConnection then infJumpConnection:Disconnect(); infJumpConnection = nil end
end

-- ============================================
-- GOD MODE / DAMAGE GUARD
-- ============================================
local function guardActive()
    return Config.GodMode or Config.AntiHit
end

local function guardHumanoid(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum:GetAttribute("KyzaGuard") then return end
    hum:SetAttribute("KyzaGuard", true)
    local function restore()
        if not guardActive() then return end
        if not hum.Parent then return end
        if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
        if hum.Health ~= hum.MaxHealth then hum.Health = hum.MaxHealth end
    end
    hum.HealthChanged:Connect(restore)
    hum:GetPropertyChangedSignal("Health"):Connect(restore)
    hum:GetPropertyChangedSignal("MaxHealth"):Connect(restore)
end

local function startGuard()
    if guardConn then return end
    guardConn = RunService.Stepped:Connect(function()
        if not guardActive() then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
        if hum.Health ~= hum.MaxHealth then hum.Health = hum.MaxHealth end
        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false
    end)
end

local function godModeCharacter(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    hum.BreakJointsOnDeath = false
    hum.RequiresNeck = false
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanTouch = false end
    end
    guardHumanoid(char)
end
local function startGodMode()
    if godModeConn then godModeConn:Disconnect(); godModeConn = nil end
    startGuard()
    local function hookCharacter(c)
        if not c then return end
        godModeCharacter(c)
        c.ChildAdded:Connect(function()
            if Config.GodMode then godModeCharacter(c) end
        end)
    end
    local char = LocalPlayer.Character
    if char then hookCharacter(char) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.3)
        if Config.GodMode then hookCharacter(c) end
    end)
    godModeConn = RunService.Heartbeat:Connect(function()
        if not Config.GodMode then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") and part.CanTouch then part.CanTouch = false end
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 50) then
            hrp.CFrame = CFrame.new(hrp.Position.X, 500, hrp.Position.Z)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end
local function stopGodMode()
    if godModeConn then godModeConn:Disconnect(); godModeConn = nil end
    local c = LocalPlayer.Character
    if c then
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanTouch = true end
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100
            if hum.Health > 100 then hum.Health = 100 end
            hum.BreakJointsOnDeath = true
            hum.RequiresNeck = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end

-- ============================================
-- ANTI-HIT
-- ============================================
local function startAntiHit()
    if antiHitConn then antiHitConn:Disconnect() end
    local function hookChar(c)
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.BreakJointsOnDeath = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanTouch = false end
        end
        guardHumanoid(c)
    end
    startGuard()
    local char = LocalPlayer.Character
    if char then hookChar(char) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.3)
        if Config.AntiHit then hookChar(c) end
    end)
    antiHitConn = RunService.Heartbeat:Connect(function()
        if not Config.AntiHit then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
            hum.BreakJointsOnDeath = false
            hum.RequiresNeck = false
        end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanTouch = false end
        end
    end)
end
local function stopAntiHit()
    Config.AntiHit = false
    if antiHitConn then antiHitConn:Disconnect(); antiHitConn = nil end
    local c = LocalPlayer.Character
    if c then
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanTouch = true end
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100
            if hum.Health > 100 then hum.Health = 100 end
            hum.BreakJointsOnDeath = true
            hum.RequiresNeck = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end

-- ============================================
-- IGNORE WALL
-- ============================================
local function startIgnoreWall()
    if ignoreWallConn then ignoreWallConn:Disconnect() end
    ignoreWallConn = RunService.Heartbeat:Connect(function()
        if not Config.IgnoreWall then return end
    end)
end
local function stopIgnoreWall()
    Config.IgnoreWall = false
    if ignoreWallConn then ignoreWallConn:Disconnect(); ignoreWallConn = nil end
end

-- ============================================
-- SPIN
-- ============================================
local function startSpin()
    if spinConn then spinConn:Disconnect() end
    spinConn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            if not Config.Spin then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local speed = math.rad((Config.SpinSpeed or 1) * 360 * dt)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, speed, 0)
            end
        end)
    end)
end
local function stopSpin()
    Config.Spin = false
    if spinConn then spinConn:Disconnect(); spinConn = nil end
end

-- ============================================
-- CUSTOM SOUNDS
-- ============================================
local function ensureCustomSoundFolder()
    if not customSoundFolder then
        customSoundFolder = Instance.new("Folder")
        customSoundFolder.Name = "Kyza_Sounds"
        customSoundFolder.Parent = SoundService
    end
end
local function playSound(id, volume, pitch)
    ensureCustomSoundFolder()
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = volume or 1
    s.PlaybackSpeed = pitch or 1
    s.Parent = customSoundFolder
    s:Play()
    game:GetService("Debris"):AddItem(s, 5)
end

-- ============================================
-- NAMETAGS
-- ============================================
local nameTagFolder = Instance.new("Folder")
nameTagFolder.Name = "Kyza_NameTags"
nameTagFolder.Parent = game:GetService("CoreGui")

local function createNameTag(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local existing = nameTagFolder:FindFirstChild(player.Name .. "_Tag")
    if existing then
        local role = getPlayerRole(player)
        local color = ROLE_COLORS[role] or ROLE_COLORS.innocent
        local nameLabel = existing:FindFirstChild("NameLabel")
        local roleLabel = existing:FindFirstChild("RoleLabel")
        if nameLabel then nameLabel.TextColor3 = color end
        if roleLabel then roleLabel.Text = role:upper(); roleLabel.TextColor3 = color end
        if existing.Adornee ~= head then existing.Adornee = head end
        return
    end
    local role = getPlayerRole(player)
    local color = ROLE_COLORS[role] or ROLE_COLORS.innocent
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_Tag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 2000
    billboard.ResetOnSpawn = false
    billboard.Parent = nameTagFolder
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Name = "RoleLabel"
    roleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    roleLabel.Position = UDim2.new(0, 0, 0.6, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = role:upper()
    roleLabel.TextColor3 = color
    roleLabel.TextStrokeTransparency = 0
    roleLabel.TextScaled = true
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.Parent = billboard
end
local function removeNameTag(player)
    local tag = nameTagFolder:FindFirstChild(player.Name .. "_Tag")
    if tag then tag:Destroy() end
end

-- ============================================
-- ESP
-- ============================================
local function applyHighlight(player, color)
    local char = player.Character
    if not char then return end
    local hl = char:FindFirstChild("Kyza_ESP_HL")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "Kyza_ESP_HL"
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end
    hl.FillColor = color
    hl.OutlineColor = color
end
local function removeHighlight(player)
    local char = player.Character
    if char then
        local hl = char:FindFirstChild("Kyza_ESP_HL")
        if hl then hl:Destroy() end
    end
end
local function applyBoxESP(player, color)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local box = hrp:FindFirstChild("Kyza_BoxESP") or Instance.new("BoxHandleAdornment")
    box.Name = "Kyza_BoxESP"
    box.Size = Vector3.new(4, 5.5, 2.5)
    box.Color3 = color
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.65
    box.Adornee = hrp
    box.Parent = hrp
end
local function removeBoxESP(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local box = hrp and hrp:FindFirstChild("Kyza_BoxESP")
    if box then box:Destroy() end
end

local function updateESP()
    updateRoles()
    if Config.ChatAlerts and (Murder ~= lastMurder or Sheriff ~= lastSheriff) then
        lastMurder = Murder; lastSheriff = Sheriff
        local msg = ""
        local mp = Murder and Players:FindFirstChild(Murder)
        local sp = Sheriff and Players:FindFirstChild(Sheriff)
        if mp then msg = msg .. "[KyzaHub] Убийца: " .. mp.DisplayName end
        if sp then
            if msg ~= "" then msg = msg .. " | " end
            msg = msg .. "Шериф: " .. sp.DisplayName
        end
        if msg ~= "" then
            pcall(function()
                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                    Text = msg, Color = Color3.fromRGB(255, 40, 90), Font = Enum.Font.GothamBold, TextSize = 15
                })
            end)
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                if Config.NameTags then createNameTag(player) else removeNameTag(player) end
                if not Config.ESP then
                    removeHighlight(player); removeBoxESP(player)
                else
                    local alive = IsAlive(player)
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local inLobby = false
                    if hrp then
                        local d = (hrp.Position - Vector3.new(6.0, 505.2, -35.0)).Magnitude
                        if d < 150 then inLobby = true end
                    end
                    local role = getPlayerRole(player)
                    local color = ROLE_COLORS[role] or ROLE_COLORS.innocent
                    if not alive or inLobby then color = ROLE_COLORS.dead end
                    applyHighlight(player, color)
                    if Config.EspBoxes then applyBoxESP(player, color) else removeBoxESP(player) end
                end
            end
        end
    end
end

-- ============================================
-- FLING
-- ============================================
local function flingPlayer(targetPlayer)
    if not targetPlayer then notify("Флинг", "Игрок не выбран"); return end
    if targetPlayer == LocalPlayer then return end
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart or (Character and Character:FindFirstChild("HumanoidRootPart"))
    local TCharacter = targetPlayer.Character
    if not TCharacter then return end
    if TCharacter == Character then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
        if THumanoid and THumanoid.Sit then return end
        notify("Флинг", "Флингаем: " .. targetPlayer.DisplayName)
        if THead then workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick()
        end
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new()
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart then SFBasePart(TRootPart) elseif THead then SFBasePart(THead) elseif Handle then SFBasePart(Handle) end
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH or workspace.FallenPartsDestroyHeight
        end
    end
end

local function startFlingAll()
    if autoFlingConn then autoFlingConn:Disconnect(); autoFlingConn = nil end
    autoFlingConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not Config.FlingAll then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    task.spawn(function() flingPlayer(p) end)
                end
            end
        end)
    end)
end

local function startInfiniteFlingTarget()
    if infiniteFlingTargetConn then infiniteFlingTargetConn:Disconnect() end
    infiniteFlingTargetEnabled = true
    lastFlingTime = 0
    infiniteFlingTargetConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not infiniteFlingTargetEnabled then return end
            if not selectedPlayer then return end
            local target = Players:FindFirstChild(selectedPlayer)
            if not target or target == LocalPlayer then return end
            local char = target.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if hum.Health > 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Velocity.Magnitude < 1000 then
                    if tick() - lastFlingTime > 3 then
                        lastFlingTime = tick()
                        task.spawn(function() flingPlayer(target) end)
                    end
                end
            end
        end)
    end)
end
local function stopInfiniteFlingTarget()
    infiniteFlingTargetEnabled = false
    if infiniteFlingTargetConn then infiniteFlingTargetConn:Disconnect(); infiniteFlingTargetConn = nil end
end

-- ============================================
-- ON-SCREEN BINDS
-- ============================================
local bindsGui = Instance.new("ScreenGui")
bindsGui.Name = "KyzaHub_Binds"
bindsGui.ResetOnSpawn = false
bindsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
bindsGui.Parent = game:GetService("CoreGui")

local bindsFrame = Instance.new("Frame")
bindsFrame.Size = UDim2.new(0, 170, 0, 40)
bindsFrame.Position = UDim2.new(0, 10, 0.5, -100)
bindsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
bindsFrame.BorderSizePixel = 0
bindsFrame.Visible = false
bindsFrame.Active = true
bindsFrame.Parent = bindsGui

local bindsCorner = Instance.new("UICorner")
bindsCorner.CornerRadius = UDim.new(0, 6)
bindsCorner.Parent = bindsFrame

local bindsPadding = Instance.new("UIPadding")
bindsPadding.PaddingTop = UDim.new(0, 6)
bindsPadding.PaddingBottom = UDim.new(0, 6)
bindsPadding.PaddingLeft = UDim.new(0, 8)
bindsPadding.PaddingRight = UDim.new(0, 8)
bindsPadding.Parent = bindsFrame

local bindsLayout = Instance.new("UIListLayout")
bindsLayout.SortOrder = Enum.SortOrder.LayoutOrder
bindsLayout.Padding = UDim.new(0, 2)
bindsLayout.Parent = bindsFrame

local bindsTitle = Instance.new("TextLabel")
bindsTitle.Name = "Title"
bindsTitle.Size = UDim2.new(1, 0, 0, 16)
bindsTitle.BackgroundTransparency = 1
bindsTitle.Text = "KyzaHub"
bindsTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
bindsTitle.TextSize = 12
bindsTitle.TextXAlignment = Enum.TextXAlignment.Left
bindsTitle.Font = Enum.Font.GothamBold
bindsTitle.LayoutOrder = 0
bindsTitle.Parent = bindsFrame

local function updateBindsSize()
    local count = 0
    for _, child in ipairs(bindsFrame:GetChildren()) do
        if child:IsA("TextLabel") and child.Name ~= "Title" then count += 1 end
    end
    local totalHeight = 16 + count * 18 + 12
    bindsFrame.Size = UDim2.new(0, 170, 0, math.max(totalHeight, 40))
end

local function updateBindsDisplay()
    for _, child in ipairs(bindsFrame:GetChildren()) do
        if child:IsA("TextLabel") and child.Name ~= "Title" then child:Destroy() end
    end
    local bindNames = {
        {key = "BindFlingTarget", name = "Флинг выбранного"},
        {key = "BindFlingMurderer", name = "Флинг убийцы"},
        {key = "BindFlingSheriff", name = "Флинг шерифа"},
        {key = "BindInfiniteFling", name = "Беск. флинг"},
        {key = "BindTpPlayer", name = "ТП к игроку"},
        {key = "BindBringPlayer", name = "Притянуть"},
        {key = "BindAutoShoot", name = "Авто-выстрел"},
        {key = "BindAimlock", name = "Аимлок"},
        {key = "BindSilentAim", name = "Silent Aim"},
        {key = "BindShootMurderer", name = "Выстрел в убийцу"},
        {key = "BindAutoDodge", name = "Уворот"},
        {key = "BindKillAura", name = "KillAura"},
        {key = "BindKillAll", name = "Kill All"},
        {key = "BindFlingAll", name = "Флинг всех"},
        {key = "BindAntiFling", name = "Анти-флинг"},
        {key = "BindEmoteSpam", name = "Спам эмоций"},
        {key = "BindAutoGrab", name = "Забрать пистолет"},
        {key = "BindReturn", name = "Возвращение"},
        {key = "BindMultiJump", name = "Мульти-прыжок"},
        {key = "BindInfJump", name = "Беск. прыжок"},
        {key = "BindAutoJump", name = "Авто-прыжок"},
        {key = "BindFly", name = "Fly"},
        {key = "BindBhop", name = "Bhop"},
        {key = "BindNoclip", name = "Noclip"},
        {key = "BindGodMode", name = "God Mode"},
        {key = "BindSlideGlitch", name = "Спидглитч"},
        {key = "BindESP", name = "ESP"},
        {key = "BindNameTags", name = "Ники"},
        {key = "BindFullbright", name = "Яркость"},
        {key = "BindSpin", name = "Крутилка"},
        {key = "BindEnvVisuals", name = "Визуалы окружения"},
        {key = "BindAntiHit", name = "Анти-удар"},
        {key = "BindIgnoreWall", name = "Сквозь стены"},
        {key = "BindFog", name = "Туман"},
        {key = "BindSky", name = "Цвет неба"},
        {key = "BindPlasma", name = "Плазма"},
        {key = "BindTpLobby", name = "ТП лобби"},
        {key = "BindTpMap", name = "ТП карта"},
    }
    local count = 0
    for _, bind in ipairs(bindNames) do
        local val = Config[bind.key]
        if val and val ~= "" then
            count += 1
            local label = Instance.new("TextLabel")
            label.Name = "Bind_" .. bind.key
            label.Size = UDim2.new(1, 0, 0, 16)
            label.BackgroundTransparency = 1
            label.Text = "[" .. val .. "] " .. bind.name
            label.TextColor3 = Color3.fromRGB(200, 200, 210)
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.LayoutOrder = count
            label.Parent = bindsFrame
        end
    end
    if count == 0 then
        local label = Instance.new("TextLabel")
        label.Name = "NoBinds"
        label.Size = UDim2.new(1, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = "Нет биндов"
        label.TextColor3 = Color3.fromRGB(150, 150, 160)
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.LayoutOrder = 1
        label.Parent = bindsFrame
    end
    updateBindsSize()
end

local dragging = false
local dragStart, startPos
bindsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = bindsFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        bindsFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.ShowBinds then
            bindsFrame.Visible = true
            updateBindsDisplay()
        else
            bindsFrame.Visible = false
        end
    end
end)

-- ============================================
-- HIDE "TAP TO SHOW"
-- ============================================
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local CoreGui = game:GetService("CoreGui")
            for _, gui in ipairs(CoreGui:GetDescendants()) do
                if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                    local txt = gui.Text
                    if txt and (txt:find("Tap To Show") or txt:find("Rayfield") or txt:find("rayfield")) then
                        gui.Text = "KyzaHub"
                    end
                end
            end
        end)
    end
end)

-- ============================================
-- MAIN NAMECALL HOOK
-- ============================================
pcall(function()
    if hookmetamethod and getnamecallmethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()

            if Config.CustomShootSound and method == "FireServer" and (self.Name == "Shoot" or self.Name == "Fire") then
                playSound(Config.CustomShootId, 0.6, 1)
            end

            if method == "FireServer" or method == "InvokeServer" then
                local heldGun = getHeldGun()
                if heldGun and (self:IsDescendantOf(heldGun) or self == gunRemoteCache) then
                    gunRemoteCache = self
                end
            end

            if Config.AntiHit or Config.GodMode then
                if method == "FireServer" or method == "InvokeServer" then
                    local n = self.Name:lower()
                    local myChar = LocalPlayer.Character
                    local outgoing = (gunRemoteCache and self == gunRemoteCache) or (myChar and self:IsDescendantOf(myChar))
                    if not outgoing and (n:find("knife") or n:find("stab") or n:find("damage") or n:find("hit") or n:find("kill") or n:find("attack") or n:find("slash") or n:find("shot") or n:find("shoot")) then
                        for _, a in ipairs(args) do
                            if a == LocalPlayer or a == LocalPlayer.Character then return nil end
                            if typeof(a) == "Instance" and a.Parent == LocalPlayer.Character then return nil end
                        end
                    end
                end
            end

            if (Config.SilentAim or Config.IgnoreWall) and (method == "FireServer" or method == "InvokeServer") then
                local m = getMurderer()
                if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = m.Character.HumanoidRootPart
                    local shouldAim = Config.IgnoreWall or (Config.SilentAim and isVisible(targetHRP))
                    local gun = getHeldGun()
                    if shouldAim and gun and (self:IsDescendantOf(gun) or self == gunRemoteCache) then
                        gunRemoteCache = self
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetPos = targetHRP.Position
                        local replaced = false
                        for i = 1, #args do
                            local a = args[i]
                            if typeof(a) == "CFrame" then
                                if (a.Position - targetPos).Magnitude > 0.01 then
                                    args[i] = CFrame.new(a.Position, targetPos)
                                else
                                    args[i] = CFrame.new(targetPos)
                                end
                                replaced = true
                            elseif typeof(a) == "Vector3" then
                                args[i] = targetPos - a; replaced = true
                            end
                        end
                        if not replaced then
                            local originPos = hrp and hrp.Position or targetPos
                            if (originPos - targetPos).Magnitude > 0.01 then
                                args[1] = CFrame.new(originPos, targetPos)
                            else
                                args[1] = CFrame.new(targetPos)
                            end
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end
            end

            return oldNamecall(self, ...)
        end)
    end
end)

-- ============================================
-- UI: ВИЗУАЛЫ
-- ============================================
VisualsTab:CreateSection("ESP и Ники")
UI.Visuals.ESP = VisualsTab:CreateToggle({ name = "ESP", currentValue = Config.ESP, callback = function(s) Config.ESP = s end })
UI.Visuals.EspBoxes = VisualsTab:CreateToggle({ name = "3D Коробки", currentValue = Config.EspBoxes, callback = function(s) Config.EspBoxes = s end })
UI.Visuals.NameTags = VisualsTab:CreateToggle({ name = "Ники над головой", currentValue = false, callback = function(s) Config.NameTags = s end })
UI.Visuals.GunDropESP = VisualsTab:CreateToggle({ name = "ESP Пистолет", currentValue = Config.GunDropESP, callback = function(s) Config.GunDropESP = s end })

VisualsTab:CreateSection("Красивое окружение")
UI.Visuals.EnvVisuals = VisualsTab:CreateToggle({ name = "Красивое окружение (светлячки)", currentValue = Config.EnvVisuals, callback = function(s)
    Config.EnvVisuals = s
    if s then enableEnvVisuals(); notify("Окружение", "ВКЛ")
    else disableEnvVisuals(); notify("Окружение", "ВЫКЛ") end
end })
UI.Visuals.TimeOfDay = VisualsTab:CreateSlider({ name = "Время суток", range = {0, 24}, increment = 1, currentValue = Config.TimeOfDay, callback = function(v)
    Config.TimeOfDay = v; Lighting.TimeOfDay = string.format("%02d:00:00", v)
end })
UI.Visuals.Fullbright = VisualsTab:CreateToggle({ name = "Яркость", currentValue = Config.Fullbright, callback = function(s)
    Config.Fullbright = s
    if s then enableFullbright() else disableFullbright() end
end })
UI.Visuals.FOV = VisualsTab:CreateSlider({ name = "FOV", range = {70, 120}, increment = 1, currentValue = Config.FOV, callback = function(v)
    Config.FOV = v
    workspace.CurrentCamera.FieldOfView = v
end })

VisualsTab:CreateSection("Туман")
UI.Visuals.FogEnabled = VisualsTab:CreateToggle({ name = "Включить туман", currentValue = Config.FogEnabled, callback = function(s)
    Config.FogEnabled = s
    applyFog()
end })
UI.Visuals.FogDensity = VisualsTab:CreateSlider({ name = "Плотность тумана", range = {1, 20}, increment = 1, currentValue = Config.FogDensity, callback = function(v)
    Config.FogDensity = v
    applyFog()
end })
UI.Visuals.NoFog = VisualsTab:CreateToggle({ name = "Убрать туман", currentValue = Config.NoFog, callback = function(s)
    Config.NoFog = s
    applyFog()
end })
pcall(function()
    UI.Visuals.FogColor = VisualsTab:CreateColorPicker({ name = "Цвет тумана", color = Config.FogColor, callback = function(c)
        Config.FogColor = c
        applyFog()
    end })
end)

VisualsTab:CreateSection("Шейдеры")
UI.Visuals.PlasmaShader = VisualsTab:CreateToggle({ name = "Плазма (анимированный шейдер)", currentValue = Config.PlasmaShader, callback = function(s)
    Config.PlasmaShader = s
    if s then startPlasmaShader(); notify("Плазма", "ВКЛ")
    else stopPlasmaShader(); notify("Плазма", "ВЫКЛ") end
end })
UI.Visuals.PlasmaIntensity = VisualsTab:CreateSlider({ name = "Сила плазмы", range = {1, 5}, increment = 1, currentValue = Config.PlasmaIntensity, callback = function(v)
    Config.PlasmaIntensity = v
end })

VisualsTab:CreateSection("Небо")
UI.Visuals.SkyColorEnabled = VisualsTab:CreateToggle({ name = "Изменить цвет неба", currentValue = Config.SkyColorEnabled, callback = function(s)
    Config.SkyColorEnabled = s
    applySky()
end })
pcall(function()
    UI.Visuals.SkyColor = VisualsTab:CreateColorPicker({ name = "Цвет неба", color = Config.SkyColor, callback = function(c)
        Config.SkyColor = c
        if Config.SkyColorEnabled then applySky() end
    end })
end)

VisualsTab:CreateSection("Экран")
VisualsTab:CreateToggle({
    name = "Показывать Watermark",
    currentValue = true,
    callback = function(s) Config.ShowWatermark = s end,
})
VisualsTab:CreateToggle({
    name = "Показывать бинды",
    currentValue = false,
    callback = function(s) Config.ShowBinds = s end,
})

-- ============================================
-- UI: БОЙНЯ
-- ============================================
UI.Combat.AutoShoot = CombatTab:CreateToggle({ name = "Авто-выстрел в убийцу", currentValue = Config.AutoShoot, callback = function(s) Config.AutoShoot = s end })
UI.Combat.Aimlock = CombatTab:CreateToggle({ name = "Аимлок на убийцу", currentValue = Config.Aimlock, callback = function(s) Config.Aimlock = s end })
UI.Combat.SilentAim = CombatTab:CreateToggle({ name = "Silent Aim (проверка стен)", currentValue = Config.SilentAim, callback = function(s) Config.SilentAim = s end })
CombatTab:CreateButton({ name = "Выстрел в убийцу", callback = function()
    local m = getMurderer()
    if m and m.Character then
        local tHRP = m.Character:FindFirstChild("HumanoidRootPart")
        if tHRP and not fireGunAt(tHRP) then notify("Выстрел", "Пистолет не найден") end
    end
end })
UI.Combat.AutoDodge = CombatTab:CreateToggle({ name = "Уворот от ножа", currentValue = Config.AutoDodge, callback = function(s) Config.AutoDodge = s end })
UI.Combat.KillAura = CombatTab:CreateToggle({ name = "KillAura", currentValue = Config.KillAura, callback = function(s) Config.KillAura = s end })
UI.Combat.KillAuraRange = CombatTab:CreateSlider({ name = "Радиус KillAura", range = {10, 45}, increment = 5, currentValue = Config.KillAuraRange, callback = function(v) Config.KillAuraRange = v end })
CombatTab:CreateButton({ name = "Kill All", callback = function()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local knife = char and char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))
    if not knife then notify("Kill All", "Нож не найден"); return end
    if not (Murder and LocalPlayer.Name == Murder) then notify("Kill All", "Ты не убийца!"); return end
    if char and char:FindFirstChild("HumanoidRootPart") then
        if knife.Parent == bp then char.Humanoid:EquipTool(knife) end
        local origPos = char.HumanoidRootPart.CFrame
        local wasAnchored = char.HumanoidRootPart.Anchored
        for _, victim in ipairs(Players:GetPlayers()) do
            if victim ~= LocalPlayer and victim.Character and victim.Character:FindFirstChild("HumanoidRootPart") then
                local vHum = victim.Character:FindFirstChildOfClass("Humanoid")
                if vHum and vHum.Health > 0 then
                    char.HumanoidRootPart.Anchored = true
                    local tHRP = victim.Character.HumanoidRootPart
                    char.HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1.5)
                    char:PivotTo(tHRP.CFrame * CFrame.new(0, 0, 1.5))
                    task.wait(0.15)
                    knife:Activate()
                    pcall(function()
                        firetouchinterest(tHRP, knife.Handle, 0)
                        task.wait(0.05)
                        firetouchinterest(tHRP, knife.Handle, 1)
                    end)
                    task.wait(0.1)
                end
            end
        end
        char.HumanoidRootPart.Anchored = wasAnchored
        char.HumanoidRootPart.CFrame = origPos
        char:PivotTo(origPos)
    end
end })

-- ============================================
-- UI: ИГРОКИ
-- ============================================
local PlayerDropdown = PlayerTab:CreateDropdown({
    name = "Выбрать игрока", options = {}, currentOption = {},
    callback = function(o) selectedPlayer = o end,
})
local function updatePlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    PlayerDropdown:Refresh(list, true)
end
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

PlayerTab:CreateButton({ name = "Флинг выбранного", callback = function()
    if not selectedPlayer then notify("Флинг", "Выбери игрока"); return end
    local t = Players:FindFirstChild(selectedPlayer)
    if t and t ~= LocalPlayer then flingPlayer(t) end
end })

PlayerTab:CreateToggle({
    name = "Бесконечный флинг выбранного",
    currentValue = false,
    callback = function(s)
        if s then
            if not selectedPlayer then notify("Флинг", "Сначала выбери игрока"); return end
            startInfiniteFlingTarget()
            notify("Беск. флинг", "ВКЛ")
        else
            stopInfiniteFlingTarget()
            notify("Беск. флинг", "ВЫКЛ")
        end
    end,
})

PlayerTab:CreateButton({ name = "Телепорт к игроку", callback = function()
    if not selectedPlayer then return end
    local t = Players:FindFirstChild(selectedPlayer)
    if t and t.Character then
        local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
        local hrp = getHRP()
        if tHRP and hrp then hrp.CFrame = tHRP.CFrame + Vector3.new(0,3,0) end
    end
end })
PlayerTab:CreateButton({ name = "Притянуть игрока", callback = function()
    if not selectedPlayer then return end
    local t = Players:FindFirstChild(selectedPlayer)
    if t and t.Character then
        local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
        local hrp = getHRP()
        if tHRP and hrp then tHRP.CFrame = hrp.CFrame + Vector3.new(0,3,0) end
    end
end })
PlayerTab:CreateButton({ name = "Флинг убийцы", callback = function() local m = getMurderer() if m then flingPlayer(m) end end })
PlayerTab:CreateButton({ name = "Флинг шерифа", callback = function() local s = getSheriff() if s then flingPlayer(s) end end })

PlayerTab:CreateSection("Троллинг цели")
PlayerTab:CreateToggle({ name = "Крутилка (Spin)", currentValue = false, callback = function(s)
    Config.Spin = s
    if s then startSpin() else stopSpin() end
end })

-- ============================================
-- UI: ТРОЛЛИНГ
-- ============================================
TrollTab:CreateSection("Флинг")
UI.Troll.FlingAll = TrollTab:CreateToggle({ name = "Флинг всех (постоянный)", currentValue = Config.FlingAll, callback = function(s)
    Config.FlingAll = s
    if s then startFlingAll() else if autoFlingConn then autoFlingConn:Disconnect(); autoFlingConn = nil end end
end })

TrollTab:CreateSection("Общее")
UI.Troll.AntiFling = TrollTab:CreateToggle({ name = "Анти-флинг", currentValue = Config.AntiFling, callback = function(s)
    Config.AntiFling = s
    if not s then
        if getgenv().antiFlingConn then getgenv().antiFlingConn:Disconnect(); getgenv().antiFlingConn = nil end
        return
    end
    if not getgenv().antiFlingConn then
        getgenv().antiFlingConn = RunService.Stepped:Connect(function()
            if not Config.AntiFling then return end
            local hrp = getHRP()
            if hrp and hrp.Velocity.Magnitude > 100 then
                hrp.Velocity = Vector3.new(0,0,0); hrp.RotVelocity = Vector3.new(0,0,0)
            end
        end)
    end
end })
UI.Troll.EmoteSpam = TrollTab:CreateToggle({ name = "Спам эмоций", currentValue = Config.EmoteSpam, callback = function(s) Config.EmoteSpam = s end })
UI.Troll.ChatAlerts = TrollTab:CreateToggle({ name = "Оповещения о ролях в чат", currentValue = Config.ChatAlerts, callback = function(s) Config.ChatAlerts = s end })

-- ============================================
-- UI: УТИЛИТЫ
-- ============================================
UtilityTab:CreateSection("Возвращение")
UtilityTab:CreateButton({ name = "Сохранить позицию", callback = function() saveReturnPosition() end })
UtilityTab:CreateButton({ name = "Вернуться на позицию", callback = function() returnToPosition() end })

UtilityTab:CreateSection("Защита")
UI.Utility.GodMode = UtilityTab:CreateToggle({ name = "God Mode", currentValue = Config.GodMode, callback = function(s)
    Config.GodMode = s
    if s then startGodMode(); notify("God Mode", "ВКЛ")
    else stopGodMode(); notify("God Mode", "ВЫКЛ") end
end })
UI.Utility.AntiHit = UtilityTab:CreateToggle({ name = "Анти-удар (нож/пуля не регают)", currentValue = Config.AntiHit, callback = function(s)
    Config.AntiHit = s
    if s then startAntiHit(); notify("Анти-удар", "ВКЛ")
    else stopAntiHit(); notify("Анти-удар", "ВЫКЛ") end
end })
UI.Utility.IgnoreWall = UtilityTab:CreateToggle({ name = "Сквозь стены (убивать/стрелять)", currentValue = Config.IgnoreWall, callback = function(s)
    Config.IgnoreWall = s
    if s then startIgnoreWall(); notify("Сквозь стены", "ВКЛ")
    else stopIgnoreWall(); notify("Сквозь стены", "ВЫКЛ") end
end })

UtilityTab:CreateSection("Прыжки")
UI.Utility.MultiJump = UtilityTab:CreateToggle({
    name = "Мульти-прыжок (2 раза)",
    currentValue = false,
    callback = function(s)
        multiJumpEnabled = s; Config.MultiJump = s
        if s then jumpsUsed = 0; startMultiJump(); notify("Мульти-прыжок", "ВКЛ")
        else stopMultiJump(); notify("Мульти-прыжок", "ВЫКЛ") end
    end,
})
UI.Utility.InfJump = UtilityTab:CreateToggle({
    name = "Бесконечный прыжок",
    currentValue = false,
    callback = function(s)
        infJumpEnabled = s; Config.InfJump = s
        if s then startInfJump(); notify("Беск. прыжок", "ВКЛ")
        else stopInfJump(); notify("Беск. прыжок", "ВЫКЛ") end
    end,
})
UI.Utility.AutoJump = UtilityTab:CreateToggle({ name = "Авто-прыжок", currentValue = Config.AutoJump, callback = function(s)
    Config.AutoJump = s
    if s then task.spawn(function()
        while Config.AutoJump do task.wait(0.3); local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end) end
end })

UtilityTab:CreateSection("Bhop")
UI.Utility.Bhop = UtilityTab:CreateToggle({
    name = "Bhop",
    currentValue = false,
    callback = function(s)
        bhopEnabled = s; Config.Bhop = s
        if s then startBhop(); notify("Bhop", "ВКЛ")
        else stopBhop(); notify("Bhop", "ВЫКЛ") end
    end,
})
UI.Utility.BhopBoost = UtilityTab:CreateSlider({ name = "Сила Bhop", range = {20, 150}, increment = 5, currentValue = 50,
    callback = function(v) bhopBoost = v; Config.BhopBoost = v end })

UtilityTab:CreateSection("Движение")
UI.Utility.Speed = UtilityTab:CreateSlider({ name = "Скорость", range = {16, 200}, increment = 1, currentValue = Config.Speed, callback = function(v)
    Config.Speed = v
    local h = getHum(); if h then h.WalkSpeed = v end
end })
UI.Utility.JumpPower = UtilityTab:CreateSlider({ name = "Сила прыжка", range = {50, 300}, increment = 1, currentValue = Config.JumpPower, callback = function(v)
    Config.JumpPower = v
    local h = getHum(); if h then h.JumpPower = v; h.UseJumpPower = true end
end })

UtilityTab:CreateSection("Прочее")
UI.Utility.Fly = UtilityTab:CreateToggle({
    name = "Fly", currentValue = Config.Fly,
    callback = function(s)
        Config.Fly = s
        if s then startFly(); notify("Fly", "WASD + Space/Ctrl")
        else stopFly(); notify("Fly", "ВЫКЛ") end
    end,
})
UI.Utility.FlySpeed = UtilityTab:CreateSlider({ name = "Скорость полёта", range = {10, 200}, increment = 5, currentValue = Config.FlySpeed,
    callback = function(v) Config.FlySpeed = v end })
UI.Utility.AutoGrab = UtilityTab:CreateToggle({ name = "Забрать пистолет", currentValue = Config.AutoGrab, callback = function(s) Config.AutoGrab = s end })
UI.Utility.SlideGlitch = UtilityTab:CreateToggle({ name = "Спидглитч", currentValue = Config.SlideGlitch, callback = function(s) Config.SlideGlitch = s end })
UI.Utility.SlideGlitchSpeed = UtilityTab:CreateSlider({ name = "Скорость глитча", range = {15, 100}, increment = 5, currentValue = Config.SlideSpeed, callback = function(v) Config.SlideSpeed = v end })
UI.Utility.Noclip = UtilityTab:CreateToggle({ name = "Noclip", currentValue = Config.Noclip, callback = function(s)
    Config.Noclip = s
    if not s then
        local c = getChar()
        if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
    end
end })

-- ============================================
-- UI: ЗВУКИ
-- ============================================
SoundTab:CreateSection("Кастомные звуки")
UI.Sounds.CustomShootSound = SoundTab:CreateToggle({ name = "Кастомный звук выстрела", currentValue = Config.CustomShootSound, callback = function(s) Config.CustomShootSound = s end })
UI.Sounds.CustomShootId = SoundTab:CreateInput({ name = "ID звука выстрела", placeholder = "rbxassetid://...", currentValue = Config.CustomShootId, callback = function(t) Config.CustomShootId = t end })
UI.Sounds.TestShoot = SoundTab:CreateButton({ name = "Тест звука выстрела", callback = function() playSound(Config.CustomShootId, 0.6, 1) end })

UI.Sounds.CustomKillSound = SoundTab:CreateToggle({ name = "Кастомный звук убийства", currentValue = Config.CustomKillSound, callback = function(s) Config.CustomKillSound = s end })
UI.Sounds.CustomKillId = SoundTab:CreateInput({ name = "ID звука убийства", placeholder = "rbxassetid://...", currentValue = Config.CustomKillId, callback = function(t) Config.CustomKillId = t end })
UI.Sounds.TestKill = SoundTab:CreateButton({ name = "Тест звука убийства", callback = function() playSound(Config.CustomKillId, 0.8, 1) end })

UI.Sounds.HitmarkerSound = SoundTab:CreateToggle({ name = "Звук хитмаркера", currentValue = Config.HitmarkerSound, callback = function(s) Config.HitmarkerSound = s end })
UI.Sounds.HitmarkerId = SoundTab:CreateInput({ name = "ID хитмаркера", placeholder = "rbxassetid://...", currentValue = Config.HitmarkerId, callback = function(t) Config.HitmarkerId = t end })
UI.Sounds.TestHitmarker = SoundTab:CreateButton({ name = "Тест хитмаркера", callback = function() playSound(Config.HitmarkerId, 0.7, 1.2) end })

-- ============================================
-- UI: ТЕЛЕПОРТЫ
-- ============================================
TpTab:CreateButton({ name = "ТП в лобби", callback = function()
    local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(6.0, 505.2, -35.0) end
end })
TpTab:CreateButton({ name = "ТП на карту", callback = function()
    local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(12.0, 291.7, 9040.0) end
end })

-- ============================================
-- UI: БИНДЫ
-- ============================================
BindsTab:CreateSection("Игроки")
BindsTab:CreateInput({ name = "Флинг выбранного", placeholder = "Пусто", currentValue = Config.BindFlingTarget, callback = function(t) Config.BindFlingTarget = t:upper() end })
BindsTab:CreateInput({ name = "Флинг убийцы", placeholder = "Пусто", currentValue = Config.BindFlingMurderer, callback = function(t) Config.BindFlingMurderer = t:upper() end })
BindsTab:CreateInput({ name = "Флинг шерифа", placeholder = "Пусто", currentValue = Config.BindFlingSheriff, callback = function(t) Config.BindFlingSheriff = t:upper() end })
BindsTab:CreateInput({ name = "Бесконечный флинг", placeholder = "Пусто", currentValue = Config.BindInfiniteFling, callback = function(t) Config.BindInfiniteFling = t:upper() end })
BindsTab:CreateInput({ name = "ТП к игроку", placeholder = "Пусто", currentValue = Config.BindTpPlayer, callback = function(t) Config.BindTpPlayer = t:upper() end })
BindsTab:CreateInput({ name = "Притянуть игрока", placeholder = "Пусто", currentValue = Config.BindBringPlayer, callback = function(t) Config.BindBringPlayer = t:upper() end })

BindsTab:CreateSection("Бойня")
BindsTab:CreateInput({ name = "Авто-выстрел", placeholder = "Пусто", currentValue = Config.BindAutoShoot, callback = function(t) Config.BindAutoShoot = t:upper() end })
BindsTab:CreateInput({ name = "Аимлок", placeholder = "Пусто", currentValue = Config.BindAimlock, callback = function(t) Config.BindAimlock = t:upper() end })
BindsTab:CreateInput({ name = "Silent Aim", placeholder = "Пусто", currentValue = Config.BindSilentAim, callback = function(t) Config.BindSilentAim = t:upper() end })
BindsTab:CreateInput({ name = "Выстрел в убийцу", placeholder = "Пусто", currentValue = Config.BindShootMurderer, callback = function(t) Config.BindShootMurderer = t:upper() end })
BindsTab:CreateInput({ name = "Уворот", placeholder = "Пусто", currentValue = Config.BindAutoDodge, callback = function(t) Config.BindAutoDodge = t:upper() end })
BindsTab:CreateInput({ name = "KillAura", placeholder = "Пусто", currentValue = Config.BindKillAura, callback = function(t) Config.BindKillAura = t:upper() end })
BindsTab:CreateInput({ name = "Kill All", placeholder = "Пусто", currentValue = Config.BindKillAll, callback = function(t) Config.BindKillAll = t:upper() end })

BindsTab:CreateSection("Троллинг")
BindsTab:CreateInput({ name = "Флинг всех", placeholder = "Пусто", currentValue = Config.BindFlingAll, callback = function(t) Config.BindFlingAll = t:upper() end })
BindsTab:CreateInput({ name = "Анти-флинг", placeholder = "Пусто", currentValue = Config.BindAntiFling, callback = function(t) Config.BindAntiFling = t:upper() end })
BindsTab:CreateInput({ name = "Спам эмоций", placeholder = "Пусто", currentValue = Config.BindEmoteSpam, callback = function(t) Config.BindEmoteSpam = t:upper() end })

BindsTab:CreateSection("Утилиты")
BindsTab:CreateInput({ name = "Забрать пистолет", placeholder = "Пусто", currentValue = Config.BindAutoGrab, callback = function(t) Config.BindAutoGrab = t:upper() end })
BindsTab:CreateInput({ name = "Возвращение", placeholder = "Пусто", currentValue = Config.BindReturn, callback = function(t) Config.BindReturn = t:upper() end })
BindsTab:CreateInput({ name = "Мульти-прыжок", placeholder = "Пусто", currentValue = Config.BindMultiJump, callback = function(t) Config.BindMultiJump = t:upper() end })
BindsTab:CreateInput({ name = "Беск. прыжок", placeholder = "Пусто", currentValue = Config.BindInfJump, callback = function(t) Config.BindInfJump = t:upper() end })
BindsTab:CreateInput({ name = "Авто-прыжок", placeholder = "Пусто", currentValue = Config.BindAutoJump, callback = function(t) Config.BindAutoJump = t:upper() end })
BindsTab:CreateInput({ name = "Fly", placeholder = "Пусто", currentValue = Config.BindFly, callback = function(t) Config.BindFly = t:upper() end })
BindsTab:CreateInput({ name = "Bhop", placeholder = "Пусто", currentValue = Config.BindBhop, callback = function(t) Config.BindBhop = t:upper() end })
BindsTab:CreateInput({ name = "Noclip", placeholder = "Пусто", currentValue = Config.BindNoclip, callback = function(t) Config.BindNoclip = t:upper() end })
BindsTab:CreateInput({ name = "God Mode", placeholder = "Пусто", currentValue = Config.BindGodMode, callback = function(t) Config.BindGodMode = t:upper() end })
BindsTab:CreateInput({ name = "Спидглитч", placeholder = "Пусто", currentValue = Config.BindSlideGlitch, callback = function(t) Config.BindSlideGlitch = t:upper() end })
BindsTab:CreateInput({ name = "Крутилка", placeholder = "Пусто", currentValue = Config.BindSpin, callback = function(t) Config.BindSpin = t:upper() end })
BindsTab:CreateInput({ name = "Визуалы окружения", placeholder = "Пусто", currentValue = Config.BindEnvVisuals, callback = function(t) Config.BindEnvVisuals = t:upper() end })
BindsTab:CreateInput({ name = "Анти-удар", placeholder = "Пусто", currentValue = Config.BindAntiHit, callback = function(t) Config.BindAntiHit = t:upper() end })
BindsTab:CreateInput({ name = "Сквозь стены", placeholder = "Пусто", currentValue = Config.BindIgnoreWall, callback = function(t) Config.BindIgnoreWall = t:upper() end })
BindsTab:CreateInput({ name = "Туман", placeholder = "Пусто", currentValue = Config.BindFog, callback = function(t) Config.BindFog = t:upper() end })
BindsTab:CreateInput({ name = "Плазма", placeholder = "Пусто", currentValue = Config.BindPlasma, callback = function(t) Config.BindPlasma = t:upper() end })
BindsTab:CreateInput({ name = "Цвет неба", placeholder = "Пусто", currentValue = Config.BindSky, callback = function(t) Config.BindSky = t:upper() end })

BindsTab:CreateSection("Визуалы")
BindsTab:CreateInput({ name = "ESP", placeholder = "Пусто", currentValue = Config.BindESP, callback = function(t) Config.BindESP = t:upper() end })
BindsTab:CreateInput({ name = "Ники", placeholder = "Пусто", currentValue = Config.BindNameTags, callback = function(t) Config.BindNameTags = t:upper() end })
BindsTab:CreateInput({ name = "Яркость", placeholder = "Пусто", currentValue = Config.BindFullbright, callback = function(t) Config.BindFullbright = t:upper() end })

BindsTab:CreateSection("Телепорты")
BindsTab:CreateInput({ name = "ТП лобби", placeholder = "Пусто", currentValue = Config.BindTpLobby, callback = function(t) Config.BindTpLobby = t:upper() end })
BindsTab:CreateInput({ name = "ТП карта", placeholder = "Пусто", currentValue = Config.BindTpMap, callback = function(t) Config.BindTpMap = t:upper() end })

-- ============================================
-- APPLY CONFIG
-- ============================================
local function applyConfigToUI()
    setToggle(UI.Visuals.ESP, Config.ESP)
    setToggle(UI.Visuals.EspBoxes, Config.EspBoxes)
    setToggle(UI.Visuals.NameTags, Config.NameTags)
    setToggle(UI.Visuals.GunDropESP, Config.GunDropESP)
    setToggle(UI.Visuals.EnvVisuals, Config.EnvVisuals)
    setSlider(UI.Visuals.TimeOfDay, Config.TimeOfDay)
    setToggle(UI.Visuals.Fullbright, Config.Fullbright)
    setSlider(UI.Visuals.FOV, Config.FOV)
    setToggle(UI.Visuals.FogEnabled, Config.FogEnabled)
    setSlider(UI.Visuals.FogDensity, Config.FogDensity)
    setToggle(UI.Visuals.NoFog, Config.NoFog)
    setToggle(UI.Visuals.PlasmaShader, Config.PlasmaShader)
    setSlider(UI.Visuals.PlasmaIntensity, Config.PlasmaIntensity)

    setToggle(UI.Combat.AutoShoot, Config.AutoShoot)
    setToggle(UI.Combat.Aimlock, Config.Aimlock)
    setToggle(UI.Combat.SilentAim, Config.SilentAim)
    setToggle(UI.Combat.AutoDodge, Config.AutoDodge)
    setToggle(UI.Combat.KillAura, Config.KillAura)
    setSlider(UI.Combat.KillAuraRange, Config.KillAuraRange)

    setToggle(UI.Troll.FlingAll, Config.FlingAll)
    setToggle(UI.Troll.AntiFling, Config.AntiFling)
    setToggle(UI.Troll.EmoteSpam, Config.EmoteSpam)
    setToggle(UI.Troll.ChatAlerts, Config.ChatAlerts)

    setToggle(UI.Utility.MultiJump, Config.MultiJump)
    setToggle(UI.Utility.InfJump, Config.InfJump)
    setToggle(UI.Utility.AutoJump, Config.AutoJump)
    setToggle(UI.Utility.Bhop, Config.Bhop)
    setSlider(UI.Utility.BhopBoost, Config.BhopBoost)
    setSlider(UI.Utility.Speed, Config.Speed)
    setSlider(UI.Utility.JumpPower, Config.JumpPower)
    setToggle(UI.Utility.Fly, Config.Fly)
    setSlider(UI.Utility.FlySpeed, Config.FlySpeed)
    setToggle(UI.Utility.AutoGrab, Config.AutoGrab)
    setToggle(UI.Utility.SlideGlitch, Config.SlideGlitch)
    setSlider(UI.Utility.SlideGlitchSpeed, Config.SlideSpeed)
    setToggle(UI.Utility.Noclip, Config.Noclip)
    setToggle(UI.Utility.GodMode, Config.GodMode)
    setToggle(UI.Utility.AntiHit, Config.AntiHit)
    setToggle(UI.Utility.IgnoreWall, Config.IgnoreWall)

    setToggle(UI.Sounds.CustomShootSound, Config.CustomShootSound)
    setInput(UI.Sounds.CustomShootId, Config.CustomShootId)
    setToggle(UI.Sounds.CustomKillSound, Config.CustomKillSound)
    setInput(UI.Sounds.CustomKillId, Config.CustomKillId)
    setToggle(UI.Sounds.HitmarkerSound, Config.HitmarkerSound)
    setInput(UI.Sounds.HitmarkerId, Config.HitmarkerId)

    if Config.Fullbright then enableFullbright() else disableFullbright() end
    if Config.EnvVisuals then enableEnvVisuals() else disableEnvVisuals() end
    Lighting.TimeOfDay = string.format("%02d:00:00", Config.TimeOfDay)
    workspace.CurrentCamera.FieldOfView = Config.FOV
    local h = getHum()
    if h then
        h.WalkSpeed = Config.Speed
        h.JumpPower = Config.JumpPower
        h.UseJumpPower = true
    end
    if Config.MultiJump then multiJumpEnabled = true; startMultiJump() end
    if Config.InfJump then infJumpEnabled = true; startInfJump() end
    if Config.Bhop then bhopEnabled = true; bhopBoost = Config.BhopBoost; startBhop() end
    if Config.FlingAll then startFlingAll() end
    if Config.GodMode then startGodMode() end
    if Config.Spin then startSpin() end
    if Config.AntiHit then startAntiHit() end
    if Config.IgnoreWall then startIgnoreWall() end
    setToggle(UI.Visuals.SkyColorEnabled, Config.SkyColorEnabled)
    applySky()
    applyFog()
    if Config.PlasmaShader then startPlasmaShader() end
end

ConfigTab:CreateSection("Сохранение")
ConfigTab:CreateButton({ name = "Сохранить конфиг", callback = function()
    local ok, err = saveConfig(CONFIG_FILE)
    if ok then notify("Конфиг", "Сохранено") else notify("Конфиг", "Ошибка: " .. tostring(err)) end
end })
ConfigTab:CreateButton({ name = "Загрузить конфиг", callback = function()
    local ok, err = loadConfig(CONFIG_FILE)
    if ok then applyConfigToUI(); notify("Конфиг", "Загружено")
    else notify("Конфиг", "Ошибка: " .. tostring(err)) end
end })
ConfigTab:CreateButton({ name = "Удалить конфиг", callback = function()
    deleteConfig(CONFIG_FILE)
    notify("Конфиг", "Файл удалён")
end })

ConfigTab:CreateSection("Автосохранение")
ConfigTab:CreateToggle({ name = "Включить автосохранение", currentValue = Config.AutoSave, callback = function(s) Config.AutoSave = s end })
ConfigTab:CreateButton({ name = "Загрузить автосейв", callback = function()
    local ok, err = loadConfig(AUTO_SAVE_FILE)
    if ok then applyConfigToUI(); notify("Автосейв", "Загружено")
    else notify("Автосейв", "Ошибка: " .. tostring(err)) end
end })
ConfigTab:CreateButton({ name = "Удалить автосейв", callback = function()
    deleteConfig(AUTO_SAVE_FILE)
    notify("Автосейв", "Файл удалён")
end })

ConfigTab:CreateSection("Сброс")
ConfigTab:CreateButton({ name = "Сбросить настройки", callback = function()
    for k in pairs(Config) do
        if type(Config[k]) == "boolean" then Config[k] = false end
    end
    Config.Speed = 16; Config.JumpPower = 50; Config.FOV = 70
    Config.FlySpeed = 50; Config.BhopBoost = 50; Config.KillAuraRange = 25
    Config.SlideSpeed = 45; Config.TimeOfDay = 14
    Config.FogDensity = 1
    Config.PlasmaIntensity = 1
    Config.AutoSave = true; Config.ShowBinds = false; Config.ShowWatermark = true
    for k in pairs(Config) do
        if k:sub(1, 4) == "Bind" then Config[k] = "" end
    end
    stopMultiJump(); stopInfJump(); stopBhop(); stopGodMode()
    stopSpin(); stopInfiniteFlingTarget()
    stopAntiHit(); stopIgnoreWall()
    stopPlasmaShader()
    Config.SkyColorEnabled = false
    applySky()
    disableEnvVisuals()
    if autoFlingConn then autoFlingConn:Disconnect(); autoFlingConn = nil end
    applyConfigToUI()
    notify("Конфиг", "Сброшено")
end })

-- ============================================
-- AUTO LOAD
-- ============================================
task.spawn(function()
    task.wait(1)
    if isfile and isfile(AUTO_SAVE_FILE) then
        local ok = loadConfig(AUTO_SAVE_FILE)
        if ok then
            applyConfigToUI()
            notify("Автосейв", "Загружено автоматически")
        end
    end
end)

-- ============================================
-- LOOPS
-- ============================================
task.spawn(function()
    while true do pcall(updateESP); task.wait(0.1) end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Config.AutoGrab then
                local char = LocalPlayer.Character
                local bp = LocalPlayer:FindFirstChild("Backpack")
                local isMurderer = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and not isMurderer then
                    local gunDrop = workspace:FindFirstChild("GunDrop", true)
                    if gunDrop then
                        local handle = gunDrop:FindFirstChild("Handle", true) or gunDrop
                        if handle and handle:IsA("BasePart") then
                            char.HumanoidRootPart.CFrame = handle.CFrame * CFrame.new(0, -1, 0)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Config.EmoteSpam then
                local playEmote = ReplicatedStorage:FindFirstChild("PlayEmote")
                if playEmote and playEmote:IsA("RemoteEvent") then
                    playEmote:FireServer("zen"); task.wait(0.1); playEmote:FireServer("sit")
                end
            end
        end)
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Config.AutoShoot then
                local m = getMurderer()
                if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                    fireGunAt(m.Character.HumanoidRootPart)
                end
            end
        end)
        task.wait(0.1)
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if Config.Aimlock then
            local m = getMurderer()
            if m and m.Character and m.Character:FindFirstChild("Head") then
                local cam = workspace.CurrentCamera
                if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, m.Character.Head.Position) end
            end
        end
    end)
end)

RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hum and Config.SlideGlitch and hum.MoveDirection.Magnitude > 0 then
            local sv = Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z).Unit
            hrp.CFrame = hrp.CFrame + (sv * (Config.SlideSpeed * dt))
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not Config.KillAura then return end
        if tick() - lastAuraTime < 0.1 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local knife = char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))
        if not (knife and hrp and hum) then return end
        if knife.Parent ~= char then hum:EquipTool(knife) end
        local handle = knife:FindFirstChild("Handle")
        if not handle then return end
        local didHit = false
        for _, victim in ipairs(Players:GetPlayers()) do
            if victim ~= LocalPlayer and victim.Character then
                local vHRP = victim.Character:FindFirstChild("HumanoidRootPart")
                local vHum = victim.Character:FindFirstChildOfClass("Humanoid")
                if vHRP and vHum and vHum.Health > 0 then
                    local dist = (hrp.Position - vHRP.Position).Magnitude
                    if dist <= Config.KillAuraRange then
                        didHit = true
                        knife:Activate()
                        if firetouchinterest then
                            for _, part in ipairs(victim.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    pcall(function()
                                        firetouchinterest(part, handle, 0)
                                        firetouchinterest(part, handle, 1)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        if didHit then lastAuraTime = tick() end
    end)
end)

RunService.Stepped:Connect(function()
    pcall(function()
        if not Config.Noclip then return end
        local char = LocalPlayer.Character
        if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end)
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not Config.AutoDodge then return end
        if tick() - lastDodgeTime < 0.3 then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local function tryDodge(part)
            if not (part and part:IsA("BasePart")) then return false end
            local dist = (hrp.Position - part.Position).Magnitude
            if dist > 30 then return false end
            local vel = part.AssemblyLinearVelocity
            if vel.Magnitude > 5 then
                local toMe = (hrp.Position - part.Position).Unit
                if vel.Unit:Dot(toMe) > 0.5 then
                    lastDodgeTime = tick()
                    hrp.CFrame = hrp.CFrame + (hrp.CFrame.RightVector * 25) + Vector3.new(0, 5, 0)
                    return true
                end
            end
            return false
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if n:find("knife") or n:find("dagger") or n:find("blade") then
                            if tryDodge(part) then return end
                        end
                    end
                end
            end
        end

        for _, name in ipairs({ "ThrownKnife", "Thrown", "KnifeDrop" }) do
            local obj = workspace:FindFirstChild(name, true)
            if obj and tryDodge(obj) then return end
            if obj then
                local h = obj:FindFirstChild("Handle", true) or obj:FindFirstChildOfClass("BasePart")
                if tryDodge(h) then return end
            end
        end
    end)
end)

task.spawn(function()
    while true do
        pcall(function()
            local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true)
            local handle = gunDrop and (gunDrop:FindFirstChild("Handle", true) or gunDrop:FindFirstChildOfClass("Part", true) or gunDrop)
            if handle then
                local hl = handle:FindFirstChild("Kyza_GunESP")
                if Config.GunDropESP then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "Kyza_GunESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 100)
                        hl.OutlineColor = Color3.fromRGB(0, 255, 100)
                        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = handle
                    end
                else
                    if hl then hl:Destroy() end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ============================================
-- BIND HANDLING
-- ============================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local ok, key = pcall(function() return input.KeyCode.Name end)
    if not ok or not key then return end
    local k = key:upper()

    if Config.BindFlingTarget ~= "" and k == Config.BindFlingTarget then
        local p = Players:FindFirstChild(selectedPlayer)
        if p and p ~= LocalPlayer then flingPlayer(p) end
    elseif Config.BindFlingMurderer ~= "" and k == Config.BindFlingMurderer then
        local m = getMurderer() if m then flingPlayer(m) end
    elseif Config.BindFlingSheriff ~= "" and k == Config.BindFlingSheriff then
        local s = getSheriff() if s then flingPlayer(s) end
    elseif Config.BindInfiniteFling ~= "" and k == Config.BindInfiniteFling then
        if infiniteFlingTargetEnabled then stopInfiniteFlingTarget() else if selectedPlayer then startInfiniteFlingTarget() end end
    elseif Config.BindTpPlayer ~= "" and k == Config.BindTpPlayer then
        if selectedPlayer then
            local t = Players:FindFirstChild(selectedPlayer)
            if t and t.Character then
                local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                local hrp = getHRP()
                if tHRP and hrp then hrp.CFrame = tHRP.CFrame + Vector3.new(0,3,0) end
            end
        end
    elseif Config.BindBringPlayer ~= "" and k == Config.BindBringPlayer then
        if selectedPlayer then
            local t = Players:FindFirstChild(selectedPlayer)
            if t and t.Character then
                local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                local hrp = getHRP()
                if tHRP and hrp then tHRP.CFrame = hrp.CFrame + Vector3.new(0,3,0) end
            end
        end
    elseif Config.BindAutoShoot ~= "" and k == Config.BindAutoShoot then
        Config.AutoShoot = not Config.AutoShoot; setToggle(UI.Combat.AutoShoot, Config.AutoShoot)
    elseif Config.BindAimlock ~= "" and k == Config.BindAimlock then
        Config.Aimlock = not Config.Aimlock; setToggle(UI.Combat.Aimlock, Config.Aimlock)
    elseif Config.BindSilentAim ~= "" and k == Config.BindSilentAim then
        Config.SilentAim = not Config.SilentAim; setToggle(UI.Combat.SilentAim, Config.SilentAim)
    elseif Config.BindShootMurderer ~= "" and k == Config.BindShootMurderer then
        local m = getMurderer()
        if m and m.Character then
            local tHRP = m.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then fireGunAt(tHRP) end
        end
    elseif Config.BindAutoDodge ~= "" and k == Config.BindAutoDodge then
        Config.AutoDodge = not Config.AutoDodge; setToggle(UI.Combat.AutoDodge, Config.AutoDodge)
    elseif Config.BindKillAura ~= "" and k == Config.BindKillAura then
        Config.KillAura = not Config.KillAura; setToggle(UI.Combat.KillAura, Config.KillAura)
    elseif Config.BindKillAll ~= "" and k == Config.BindKillAll then
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local knife = char and char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))
        if knife and Murder and LocalPlayer.Name == Murder and char and char:FindFirstChild("HumanoidRootPart") then
            if knife.Parent == bp then char.Humanoid:EquipTool(knife) end
            local origPos = char.HumanoidRootPart.CFrame
            local wasAnchored = char.HumanoidRootPart.Anchored
            for _, victim in ipairs(Players:GetPlayers()) do
                if victim ~= LocalPlayer and victim.Character and victim.Character:FindFirstChild("HumanoidRootPart") then
                    local vHum = victim.Character:FindFirstChildOfClass("Humanoid")
                    if vHum and vHum.Health > 0 then
                        char.HumanoidRootPart.Anchored = true
                        local tHRP = victim.Character.HumanoidRootPart
                        char.HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1.5)
                        char:PivotTo(tHRP.CFrame * CFrame.new(0, 0, 1.5))
                        task.wait(0.15)
                        knife:Activate()
                        pcall(function()
                            firetouchinterest(tHRP, knife.Handle, 0)
                            task.wait(0.05)
                            firetouchinterest(tHRP, knife.Handle, 1)
                        end)
                        task.wait(0.1)
                    end
                end
            end
            char.HumanoidRootPart.Anchored = wasAnchored
            char.HumanoidRootPart.CFrame = origPos
            char:PivotTo(origPos)
        end
    elseif Config.BindFlingAll ~= "" and k == Config.BindFlingAll then
        Config.FlingAll = not Config.FlingAll
        if Config.FlingAll then startFlingAll() else if autoFlingConn then autoFlingConn:Disconnect(); autoFlingConn = nil end end
        setToggle(UI.Troll.FlingAll, Config.FlingAll)
    elseif Config.BindAntiFling ~= "" and k == Config.BindAntiFling then
        Config.AntiFling = not Config.AntiFling; setToggle(UI.Troll.AntiFling, Config.AntiFling)
        if not Config.AntiFling then
            if getgenv().antiFlingConn then getgenv().antiFlingConn:Disconnect(); getgenv().antiFlingConn = nil end
        else
            if not getgenv().antiFlingConn then
                getgenv().antiFlingConn = RunService.Stepped:Connect(function()
                    if not Config.AntiFling then return end
                    local hrp = getHRP()
                    if hrp and hrp.Velocity.Magnitude > 100 then
                        hrp.Velocity = Vector3.new(0,0,0); hrp.RotVelocity = Vector3.new(0,0,0)
                    end
                end)
            end
        end
    elseif Config.BindEmoteSpam ~= "" and k == Config.BindEmoteSpam then
        Config.EmoteSpam = not Config.EmoteSpam; setToggle(UI.Troll.EmoteSpam, Config.EmoteSpam)
    elseif Config.BindAutoGrab ~= "" and k == Config.BindAutoGrab then
        Config.AutoGrab = not Config.AutoGrab; setToggle(UI.Utility.AutoGrab, Config.AutoGrab)
    elseif Config.BindReturn ~= "" and k == Config.BindReturn then
        returnToPosition()
    elseif Config.BindMultiJump ~= "" and k == Config.BindMultiJump then
        multiJumpEnabled = not multiJumpEnabled; Config.MultiJump = multiJumpEnabled
        if multiJumpEnabled then jumpsUsed = 0; startMultiJump() else stopMultiJump() end
        setToggle(UI.Utility.MultiJump, multiJumpEnabled)
    elseif Config.BindInfJump ~= "" and k == Config.BindInfJump then
        infJumpEnabled = not infJumpEnabled; Config.InfJump = infJumpEnabled
        if infJumpEnabled then startInfJump() else stopInfJump() end
        setToggle(UI.Utility.InfJump, infJumpEnabled)
    elseif Config.BindAutoJump ~= "" and k == Config.BindAutoJump then
        Config.AutoJump = not Config.AutoJump; setToggle(UI.Utility.AutoJump, Config.AutoJump)
        if Config.AutoJump then task.spawn(function()
            while Config.AutoJump do task.wait(0.3); local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end) end
    elseif Config.BindFly ~= "" and k == Config.BindFly then
        Config.Fly = not Config.Fly
        if Config.Fly then startFly() else stopFly() end
        setToggle(UI.Utility.Fly, Config.Fly)
    elseif Config.BindBhop ~= "" and k == Config.BindBhop then
        bhopEnabled = not bhopEnabled; Config.Bhop = bhopEnabled
        if bhopEnabled then startBhop() else stopBhop() end
        setToggle(UI.Utility.Bhop, bhopEnabled)
    elseif Config.BindNoclip ~= "" and k == Config.BindNoclip then
        Config.Noclip = not Config.Noclip; setToggle(UI.Utility.Noclip, Config.Noclip)
        if not Config.Noclip then
            local c = getChar()
            if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
        end
    elseif Config.BindGodMode ~= "" and k == Config.BindGodMode then
        Config.GodMode = not Config.GodMode
        if Config.GodMode then startGodMode() else stopGodMode() end
        setToggle(UI.Utility.GodMode, Config.GodMode)
    elseif Config.BindSlideGlitch ~= "" and k == Config.BindSlideGlitch then
        Config.SlideGlitch = not Config.SlideGlitch; setToggle(UI.Utility.SlideGlitch, Config.SlideGlitch)
    elseif Config.BindSpin ~= "" and k == Config.BindSpin then
        Config.Spin = not Config.Spin
        if Config.Spin then startSpin() else stopSpin() end
    elseif Config.BindEnvVisuals ~= "" and k == Config.BindEnvVisuals then
        Config.EnvVisuals = not Config.EnvVisuals
        if Config.EnvVisuals then enableEnvVisuals() else disableEnvVisuals() end
        setToggle(UI.Visuals.EnvVisuals, Config.EnvVisuals)
    elseif Config.BindAntiHit ~= "" and k == Config.BindAntiHit then
        Config.AntiHit = not Config.AntiHit
        if Config.AntiHit then startAntiHit() else stopAntiHit() end
        setToggle(UI.Utility.AntiHit, Config.AntiHit)
    elseif Config.BindIgnoreWall ~= "" and k == Config.BindIgnoreWall then
        Config.IgnoreWall = not Config.IgnoreWall
        if Config.IgnoreWall then startIgnoreWall() else stopIgnoreWall() end
        setToggle(UI.Utility.IgnoreWall, Config.IgnoreWall)
    elseif Config.BindFog ~= "" and k == Config.BindFog then
        Config.FogEnabled = not Config.FogEnabled
        applyFog()
        setToggle(UI.Visuals.FogEnabled, Config.FogEnabled)
    elseif Config.BindPlasma ~= "" and k == Config.BindPlasma then
        Config.PlasmaShader = not Config.PlasmaShader
        if Config.PlasmaShader then startPlasmaShader() else stopPlasmaShader() end
        setToggle(UI.Visuals.PlasmaShader, Config.PlasmaShader)
    elseif Config.BindSky ~= "" and k == Config.BindSky then
        Config.SkyColorEnabled = not Config.SkyColorEnabled
        applySky()
        setToggle(UI.Visuals.SkyColorEnabled, Config.SkyColorEnabled)
    elseif Config.BindESP ~= "" and k == Config.BindESP then
        Config.ESP = not Config.ESP; setToggle(UI.Visuals.ESP, Config.ESP)
    elseif Config.BindNameTags ~= "" and k == Config.BindNameTags then
        Config.NameTags = not Config.NameTags; setToggle(UI.Visuals.NameTags, Config.NameTags)
    elseif Config.BindFullbright ~= "" and k == Config.BindFullbright then
        Config.Fullbright = not Config.Fullbright; setToggle(UI.Visuals.Fullbright, Config.Fullbright)
        if Config.Fullbright then enableFullbright() else disableFullbright() end
    elseif Config.BindTpLobby ~= "" and k == Config.BindTpLobby then
        local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(6.0, 505.2, -35.0) end
    elseif Config.BindTpMap ~= "" and k == Config.BindTpMap then
        local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(12.0, 291.7, 9040.0) end
    end
end)

notify("KyzaHub", "by Kyza — Загружено!")