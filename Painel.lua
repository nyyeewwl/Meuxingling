-- ============================================================
--  PARTE 1 / 3 — Interface base
--  AIMBOT + ESP + NOCLIP + VELOCIDADE — v21
--  ⚠️ Executar PRIMEIRO. Depois Parte 2, depois Parte 3.
--  ⚠️ Uso apenas em place próprio com NPCs seus.
-- ============================================================

local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera    = Workspace.CurrentCamera

-- ============================================================
--  ESTADO GLOBAL (compartilhado entre as 3 partes)
-- ============================================================
_G.AimState = {
    aimbotOn  = false,
    espOn     = true,
    noclipOn  = false,
    speedOn   = false,
    speedVal  = 16,
    fovSize   = 250,
    fovColor  = Color3.fromRGB(0, 255, 170),
    espColor  = Color3.fromRGB(0, 255, 170),
    aimForce  = 50,
    minimized = false,
}

_G.AimConst = {
    WIN_W = 320, WIN_H = 520,
    MINI_SIZE = 48, MARGEM_CANTO = 12,
    MAX_DIST = 350, ESP_MAX_DIST = 300,
    SPEED_MIN = 1, SPEED_MAX = 9999,
    FOV_MIN = 80, FOV_MAX = 500,
    PARTES_PROTEGIDAS = {
        HumanoidRootPart = true, Head = true,
        UpperTorso = true, LowerTorso = true, Torso = true,
    },
}

_G.AimTheme = {
    bg        = Color3.fromRGB(18, 18, 22),
    bgSoft    = Color3.fromRGB(28, 28, 34),
    accent    = Color3.fromRGB(0, 255, 170),
    accentDim = Color3.fromRGB(0, 180, 120),
    danger    = Color3.fromRGB(255, 70, 90),
    text      = Color3.fromRGB(235, 235, 245),
    textDim   = Color3.fromRGB(150, 150, 165),
}

local State = _G.AimState
local C     = _G.AimConst
local Theme = _G.AimTheme

-- helpers globais
function _G.AimCorner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0, 10); c.Parent = p; return c
end
function _G.AimStroke(p, color, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.accentDim; s.Thickness = th or 1; s.Transparency = tr or 0.4
    s.Parent = p; return s
end

local corner = _G.AimCorner
local stroke = _G.AimStroke

-- ============================================================
--  ESP GUI
-- ============================================================
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPGui"; espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true; espGui.DisplayOrder = 998
espGui.Parent = playerGui
_G.AimEspGui = espGui
_G.AimEspCache = {}

-- ============================================================
--  CÍRCULO DO FOV
-- ============================================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVGui"; fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true; fovGui.DisplayOrder = 999
fovGui.Parent = playerGui
_G.AimFovGui = fovGui

local fovFrame = Instance.new("Frame")
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.fromScale(0.5, 0.5)
fovFrame.Size = UDim2.fromOffset(State.fovSize, State.fovSize)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = false
fovFrame.Parent = fovGui
corner(fovFrame, UDim.new(1, 0))

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = State.fovColor
fovStroke.Thickness = 2
fovStroke.Transparency = 0.15
fovStroke.Parent = fovFrame

_G.AimFovFrame  = fovFrame
_G.AimFovStroke = fovStroke

function _G.AimAtualizarFOV()
    fovFrame.Size = UDim2.fromOffset(State.fovSize, State.fovSize)
    fovStroke.Color = State.fovColor
end

-- ============================================================
--  JANELA PRINCIPAL
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "AimGui"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true; gui.DisplayOrder = 1000
gui.Parent = playerGui
_G.AimGui = gui

local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(C.WIN_W, C.WIN_H)
main.BackgroundColor3 = Theme.bg
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0; main.Active = true; main.ClipsDescendants = true
main.Parent = gui
corner(main)
stroke(main, Theme.accentDim, 1.5, 0.35)
_G.AimMain = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Theme.bgSoft
header.BackgroundTransparency = 0.35
header.BorderSizePixel = 0; header.ZIndex = 3; header.Parent = main
corner(header)
_G.AimHeader = header

local title = Instance.new("TextLabel")
title.Text = "AIM  •  DEMO"
title.Font = Enum.Font.GothamBold
title.TextSize = 15; title.TextColor3 = Theme.accent
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.fromOffset(14, 0)
title.Size = UDim2.new(0.55, 0, 1, 0)
title.ZIndex = 4; title.Parent = header
_G.AimTitle = title

local minBtn = Instance.new("TextButton")
minBtn.Text = "—"; minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16; minBtn.TextColor3 = Theme.text
minBtn.BackgroundColor3 = Theme.bg; minBtn.BackgroundTransparency = 0.4
minBtn.AutoButtonColor = false
minBtn.AnchorPoint = Vector2.new(1, 0.5)
minBtn.Position = UDim2.new(1, -42, 0.5, 0)
minBtn.Size = UDim2.fromOffset(30, 28)
minBtn.ZIndex = 4; minBtn.Parent = header
corner(minBtn, UDim.new(0, 8))
_G.AimMinBtn = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"; closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14; closeBtn.TextColor3 = Theme.danger
closeBtn.BackgroundColor3 = Theme.bg; closeBtn.BackgroundTransparency = 0.4
closeBtn.AutoButtonColor = false
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.new(1, -8, 0.5, 0)
closeBtn.Size = UDim2.fromOffset(30, 28)
closeBtn.ZIndex = 4; closeBtn.Parent = header
corner(closeBtn, UDim.new(0, 8))
_G.AimCloseBtn = closeBtn

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -20, 1, -58)
body.Position = UDim2.fromOffset(10, 50)
body.BackgroundTransparency = 1; body.ZIndex = 2; body.Parent = main
_G.AimBody = body

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = body

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 32)
status.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
status.BackgroundTransparency = 0.3
status.Font = Enum.Font.Code
status.TextSize = 11; status.TextColor3 = Theme.accent
status.TextXAlignment = Enum.TextXAlignment.Center
status.Text = "STATUS: idle"
status.LayoutOrder = 0; status.ZIndex = 3; status.Parent = body
corner(status, UDim.new(0, 6))
_G.AimStatus = status

-- ============================================================
--  BOTÕES ON/OFF
-- ============================================================
local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Size = UDim2.new(1, 0, 0, 44)
aimbotBtn.BackgroundColor3 = Theme.bgSoft
aimbotBtn.BackgroundTransparency = 0.4
aimbotBtn.Text = "AIMBOT  •  OFF"
aimbotBtn.Font = Enum.Font.GothamBold
aimbotBtn.TextSize = 14; aimbotBtn.TextColor3 = Theme.text
aimbotBtn.AutoButtonColor = false
aimbotBtn.LayoutOrder = 1; aimbotBtn.ZIndex = 3; aimbotBtn.Parent = body
corner(aimbotBtn)
local aimbotStroke = stroke(aimbotBtn, Theme.accentDim, 1.5, 0.5)
_G.AimAimbotBtn = aimbotBtn
_G.AimAimbotStroke = aimbotStroke

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, 0, 0, 40)
espBtn.BackgroundColor3 = Theme.bgSoft
espBtn.BackgroundTransparency = 0.4
espBtn.Text = "ESP  •  OFF"
espBtn.Font = Enum.Font.GothamBold
espBtn.TextSize = 14; espBtn.TextColor3 = Theme.text
espBtn.AutoButtonColor = false
espBtn.LayoutOrder = 2; espBtn.ZIndex = 3; espBtn.Parent = body
corner(espBtn)
local espStroke = stroke(espBtn, Theme.accentDim, 1.5, 0.5)
_G.AimEspBtn = espBtn
_G.AimEspStroke = espStroke

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(1, 0, 0, 40)
noclipBtn.BackgroundColor3 = Theme.bgSoft
noclipBtn.BackgroundTransparency = 0.4
noclipBtn.Text = "NOCLIP  •  OFF"
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextSize = 14; noclipBtn.TextColor3 = Theme.text
noclipBtn.AutoButtonColor = false
noclipBtn.LayoutOrder = 3; noclipBtn.ZIndex = 3; noclipBtn.Parent = body
corner(noclipBtn)
local noclipStroke = stroke(noclipBtn, Theme.accentDim, 1.5, 0.5)
_G.AimNoclipBtn = noclipBtn
_G.AimNoclipStroke = noclipStroke

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, 0, 0, 40)
speedBtn.BackgroundColor3 = Theme.bgSoft
speedBtn.BackgroundTransparency = 0.4
speedBtn.Text = "VELOCIDADE  •  OFF"
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 14; speedBtn.TextColor3 = Theme.text
speedBtn.AutoButtonColor = false
speedBtn.LayoutOrder = 4; speedBtn.ZIndex = 3; speedBtn.Parent = body
corner(speedBtn)
local speedStroke = stroke(speedBtn, Theme.accentDim, 1.5, 0.5)
_G.AimSpeedBtn = speedBtn
_G.AimSpeedStroke = speedStroke

-- ============================================================
--  RENDER DOS BOTÕES (função global, Parte 2 e 3 usam)
-- ============================================================
function _G.AimRenderBotoes()
    if State.aimbotOn then
        aimbotBtn.BackgroundColor3 = Theme.accent
        aimbotBtn.BackgroundTransparency = 0.15
        aimbotBtn.TextColor3 = Color3.fromRGB(10, 20, 15)
        aimbotStroke.Color = Theme.accent; aimbotStroke.Transparency = 0
        aimbotBtn.Text = "AIMBOT  •  ON"
    else
        aimbotBtn.BackgroundColor3 = Theme.bgSoft
        aimbotBtn.BackgroundTransparency = 0.4
        aimbotBtn.TextColor3 = Theme.text
        aimbotStroke.Color = Theme.accentDim; aimbotStroke.Transparency = 0.5
        aimbotBtn.Text = "AIMBOT  •  OFF"
    end

    if State.espOn then
        espBtn.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
        espBtn.BackgroundTransparency = 0.15
        espBtn.TextColor3 = Color3.fromRGB(10, 15, 25)
        espStroke.Color = Color3.fromRGB(90, 160, 255); espStroke.Transparency = 0
        espBtn.Text = "ESP  •  ON"
    else
        espBtn.BackgroundColor3 = Theme.bgSoft
        espBtn.BackgroundTransparency = 0.4
        espBtn.TextColor3 = Theme.text
        espStroke.Color = Theme.accentDim; espStroke.Transparency = 0.5
        espBtn.Text = "ESP  •  OFF"
    end

    if State.noclipOn then
        noclipBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 60)
        noclipBtn.BackgroundTransparency = 0.15
        noclipBtn.TextColor3 = Color3.fromRGB(25, 15, 5)
        noclipStroke.Color = Color3.fromRGB(255, 170, 60); noclipStroke.Transparency = 0
        noclipBtn.Text = "NOCLIP  •  ON"
    else
        noclipBtn.BackgroundColor3 = Theme.bgSoft
        noclipBtn.BackgroundTransparency = 0.4
        noclipBtn.TextColor3 = Theme.text
        noclipStroke.Color = Theme.accentDim; noclipStroke.Transparency = 0.5
        noclipBtn.Text = "NOCLIP  •  OFF"
    end

    if State.speedOn then
        speedBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 255)
        speedBtn.BackgroundTransparency = 0.15
        speedBtn.TextColor3 = Color3.fromRGB(15, 5, 25)
        speedStroke.Color = Color3.fromRGB(180, 120, 255); speedStroke.Transparency = 0
        speedBtn.Text = "VELOCIDADE  •  ON (" .. State.speedVal .. ")"
    else
        speedBtn.BackgroundColor3 = Theme.bgSoft
        speedBtn.BackgroundTransparency = 0.4
        speedBtn.TextColor3 = Theme.text
        speedStroke.Color = Theme.accentDim; speedStroke.Transparency = 0.5
        speedBtn.Text = "VELOCIDADE  •  OFF"
    end
end

-- INIT
_G.AimRenderBotoes()
status.Text = "STATUS: idle"

-- ============================================================
--  PARTE 2 / 3 — Sliders, campo de velocidade, minimizar, drag, fechar
--  AIMBOT + ESP + NOCLIP + VELOCIDADE — v21
--  ⚠️ Executar DEPOIS da Parte 1, ANTES da Parte 3.
-- ============================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local State = _G.AimState
local C     = _G.AimConst
local Theme = _G.AimTheme
local body  = _G.AimBody
local main  = _G.AimMain
local header = _G.AimHeader
local title = _G.AimTitle
local minBtn = _G.AimMinBtn
local closeBtn = _G.AimCloseBtn
local corner = _G.AimCorner
local stroke = _G.AimStroke
local renderBotoes = _G.AimRenderBotoes
local atualizarFOV = _G.AimAtualizarFOV

-- ============================================================
--  SLIDER FORÇA DA MIRA
-- ============================================================
local forceLabel = Instance.new("TextLabel")
forceLabel.Size = UDim2.new(1, 0, 0, 16)
forceLabel.BackgroundTransparency = 1
forceLabel.Font = Enum.Font.Gotham
forceLabel.TextSize = 12; forceLabel.TextColor3 = Theme.textDim
forceLabel.TextXAlignment = Enum.TextXAlignment.Left
forceLabel.Text = "FORÇA DA MIRA"
forceLabel.LayoutOrder = 5; forceLabel.ZIndex = 3; forceLabel.Parent = body

local sliderHolder = Instance.new("Frame")
sliderHolder.Size = UDim2.new(1, 0, 0, 40)
sliderHolder.BackgroundColor3 = Theme.bgSoft
sliderHolder.BackgroundTransparency = 0.4
sliderHolder.BorderSizePixel = 0
sliderHolder.LayoutOrder = 6; sliderHolder.ZIndex = 3; sliderHolder.Parent = body
corner(sliderHolder)

local sliderTrack = Instance.new("Frame")
sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
sliderTrack.Position = UDim2.new(0, 12, 0.5, 0)
sliderTrack.Size = UDim2.new(1, -96, 0, 6)
sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
sliderTrack.BorderSizePixel = 0; sliderTrack.ZIndex = 4; sliderTrack.Parent = sliderHolder
corner(sliderTrack, UDim.new(1, 0))

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(State.aimForce / 100, 0, 1, 0)
sliderFill.BackgroundColor3 = Theme.accent
sliderFill.BorderSizePixel = 0; sliderFill.ZIndex = 5; sliderFill.Parent = sliderTrack
corner(sliderFill, UDim.new(1, 0))

local sliderKnob = Instance.new("Frame")
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(State.aimForce / 100, 0, 0.5, 0)
sliderKnob.Size = UDim2.fromOffset(16, 16)
sliderKnob.BackgroundColor3 = Theme.text
sliderKnob.BorderSizePixel = 0; sliderKnob.ZIndex = 6; sliderKnob.Parent = sliderTrack
corner(sliderKnob, UDim.new(1, 0))

local forceValue = Instance.new("TextLabel")
forceValue.AnchorPoint = Vector2.new(1, 0.5)
forceValue.Position = UDim2.new(1, -12, 0.5, 0)
forceValue.Size = UDim2.fromOffset(64, 20)
forceValue.BackgroundTransparency = 1
forceValue.Font = Enum.Font.GothamBold
forceValue.TextSize = 13; forceValue.TextColor3 = Theme.accent
forceValue.Text = tostring(State.aimForce) .. "%"
forceValue.ZIndex = 6; forceValue.Parent = sliderHolder

-- ============================================================
--  SLIDER FOV
-- ============================================================
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 16)
fovLabel.BackgroundTransparency = 1
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 12; fovLabel.TextColor3 = Theme.textDim
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Text = "TAMANHO DO FOV"
fovLabel.LayoutOrder = 7; fovLabel.ZIndex = 3; fovLabel.Parent = body

local fovHolder = Instance.new("Frame")
fovHolder.Size = UDim2.new(1, 0, 0, 40)
fovHolder.BackgroundColor3 = Theme.bgSoft
fovHolder.BackgroundTransparency = 0.4
fovHolder.BorderSizePixel = 0
fovHolder.LayoutOrder = 8; fovHolder.ZIndex = 3; fovHolder.Parent = body
corner(fovHolder)

local fovTrack = Instance.new("Frame")
fovTrack.AnchorPoint = Vector2.new(0, 0.5)
fovTrack.Position = UDim2.new(0, 12, 0.5, 0)
fovTrack.Size = UDim2.new(1, -96, 0, 6)
fovTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
fovTrack.BorderSizePixel = 0; fovTrack.ZIndex = 4; fovTrack.Parent = fovHolder
corner(fovTrack, UDim.new(1, 0))

local FOV_MIN, FOV_MAX = C.FOV_MIN, C.FOV_MAX
local fovPct = (State.fovSize - FOV_MIN) / (FOV_MAX - FOV_MIN)

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(fovPct, 0, 1, 0)
fovFill.BackgroundColor3 = Theme.accentDim
fovFill.BorderSizePixel = 0; fovFill.ZIndex = 5; fovFill.Parent = fovTrack
corner(fovFill, UDim.new(1, 0))

local fovKnob = Instance.new("Frame")
fovKnob.AnchorPoint = Vector2.new(0.5, 0.5)
fovKnob.Position = UDim2.new(fovPct, 0, 0.5, 0)
fovKnob.Size = UDim2.fromOffset(16, 16)
fovKnob.BackgroundColor3 = Theme.text
fovKnob.BorderSizePixel = 0; fovKnob.ZIndex = 6; fovKnob.Parent = fovTrack
corner(fovKnob, UDim.new(1, 0))

local fovValue = Instance.new("TextLabel")
fovValue.AnchorPoint = Vector2.new(1, 0.5)
fovValue.Position = UDim2.new(1, -12, 0.5, 0)
fovValue.Size = UDim2.fromOffset(64, 20)
fovValue.BackgroundTransparency = 1
fovValue.Font = Enum.Font.GothamBold
fovValue.TextSize = 13; fovValue.TextColor3 = Theme.accentDim
fovValue.Text = tostring(State.fovSize) .. "px"
fovValue.ZIndex = 6; fovValue.Parent = fovHolder

-- ============================================================
--  BIND DOS SLIDERS
-- ============================================================
local function clamp01(v) return math.clamp(v, 0, 1) end
local function bindSlider(track, fill, knob, onUpdate)
    local dragging = false
    local function process(input)
        local abs = track.AbsolutePosition
        local absSize = track.AbsoluteSize
        if absSize.X <= 0 then return end
        local pct = clamp01((input.Position.X - abs.X) / absSize.X)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        onUpdate(pct)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; process(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            process(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

bindSlider(sliderTrack, sliderFill, sliderKnob, function(pct)
    State.aimForce = math.floor(pct * 100 + 0.5)
    forceValue.Text = tostring(State.aimForce) .. "%"
end)

bindSlider(fovTrack, fovFill, fovKnob, function(pct)
    State.fovSize = math.floor(FOV_MIN + (FOV_MAX - FOV_MIN) * pct + 0.5)
    fovValue.Text = tostring(State.fovSize) .. "px"
    atualizarFOV()
end)

-- ============================================================
--  CAMPO DE VELOCIDADE
-- ============================================================
local speedHolder = Instance.new("Frame")
speedHolder.Size = UDim2.new(1, 0, 0, 40)
speedHolder.BackgroundColor3 = Theme.bgSoft
speedHolder.BackgroundTransparency = 0.4
speedHolder.BorderSizePixel = 0
speedHolder.LayoutOrder = 9; speedHolder.ZIndex = 3; speedHolder.Parent = body
corner(speedHolder)

local speedLabel = Instance.new("TextLabel")
speedLabel.AnchorPoint = Vector2.new(0, 0.5)
speedLabel.Position = UDim2.new(0, 12, 0.5, 0)
speedLabel.Size = UDim2.fromOffset(80, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12; speedLabel.TextColor3 = Theme.textDim
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Text = "Valor (1-9999)"
speedLabel.ZIndex = 5; speedLabel.Parent = speedHolder

local speedBox = Instance.new("TextBox")
speedBox.AnchorPoint = Vector2.new(1, 0.5)
speedBox.Position = UDim2.new(1, -12, 0.5, 0)
speedBox.Size = UDim2.fromOffset(110, 28)
speedBox.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
speedBox.BackgroundTransparency = 0.2
speedBox.BorderSizePixel = 0
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 14
speedBox.TextColor3 = Theme.accent
speedBox.Text = tostring(State.speedVal)
speedBox.PlaceholderText = "1 - 9999"
speedBox.PlaceholderColor3 = Theme.textDim
speedBox.ClearTextOnFocus = false
speedBox.ZIndex = 5
speedBox.Parent = speedHolder
corner(speedBox, UDim.new(0, 6))
stroke(speedBox, Theme.accentDim, 1, 0.5)
_G.AimSpeedBox = speedBox

speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text)
    if not num then
        speedBox.Text = tostring(State.speedVal)
        return
    end
    num = math.floor(num)
    num = math.clamp(num, C.SPEED_MIN, C.SPEED_MAX)
    State.speedVal = num
    speedBox.Text = tostring(num)
    if State.speedOn and _G.AimAplicarVelocidade then
        _G.AimAplicarVelocidade()
    end
    renderBotoes()
end)

speedBox:GetPropertyChangedSignal("Text"):Connect(function()
    local txt = speedBox.Text
    local limpo = txt:gsub("[^%d]", "")
    if limpo ~= txt then
        speedBox.Text = limpo
    end
    if #limpo > 4 then
        speedBox.Text = limpo:sub(1, 4)
    end
end)

-- ============================================================
--  BOTÕES ON/OFF (handlers)
-- ============================================================
_G.AimAimbotBtn.MouseButton1Click:Connect(function()
    State.aimbotOn = not State.aimbotOn
    renderBotoes()
end)

_G.AimEspBtn.MouseButton1Click:Connect(function()
    State.espOn = not State.espOn
    renderBotoes()
end)

_G.AimNoclipBtn.MouseButton1Click:Connect(function()
    State.noclipOn = not State.noclipOn
    if not State.noclipOn and _G.AimRestaurarColisao then
        _G.AimRestaurarColisao(player.Character)
    end
    renderBotoes()
end)

_G.AimSpeedBtn.MouseButton1Click:Connect(function()
    State.speedOn = not State.speedOn
    if State.speedOn and _G.AimAplicarVelocidade then
        _G.AimAplicarVelocidade()
    elseif not State.speedOn and _G.AimRestaurarVelocidade then
        _G.AimRestaurarVelocidade()
    end
    renderBotoes()
end)

-- ============================================================
--  MINIMIZAR / RESTAURAR
-- ============================================================
local posAntesDeMinimizar = nil

local function setMinimized(min)
    State.minimized = min
    if min then
        posAntesDeMinimizar = main.Position
        main.Size = UDim2.fromOffset(C.MINI_SIZE, C.MINI_SIZE)
        main.AnchorPoint = Vector2.new(1, 0)
        main.Position = UDim2.new(1, -C.MARGEM_CANTO, 0, C.MARGEM_CANTO)
        body.Visible = false
        title.Visible = false
        minBtn.Visible = false
        closeBtn.Visible = false
    else
        main.Size = UDim2.fromOffset(C.WIN_W, C.WIN_H)
        main.AnchorPoint = Vector2.new(0.5, 0.5)
        main.Position = posAntesDeMinimizar or UDim2.fromScale(0.5, 0.5)
        body.Visible = true
        title.Visible = true
        minBtn.Visible = true
        closeBtn.Visible = true
    end
end

minBtn.MouseButton1Click:Connect(function() setMinimized(true) end)

main.InputBegan:Connect(function(input)
    if State.minimized
    and (input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch) then
        setMinimized(false)
    end
end)

-- ============================================================
--  DRAG
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(input)
    if State.minimized then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
--  FECHAR
-- ============================================================
closeBtn.MouseButton1Click:Connect(function()
    State.aimbotOn = false
    State.noclipOn = false
    State.speedOn = false
    if _G.AimRestaurarColisao then _G.AimRestaurarColisao(player.Character) end
    if _G.AimRestaurarVelocidade then _G.AimRestaurarVelocidade() end
    if _G.AimGui then _G.AimGui:Destroy() end
    if _G.AimEspGui then _G.AimEspGui:Destroy() end
    if _G.AimFovGui then _G.AimFovGui:Destroy() end
end)

-- ============================================================
--  PARTE 3 / 3 — Lógica (aimbot, ESP, noclip, velocidade, loops)
--  AIMBOT + ESP + NOCLIP + VELOCIDADE — v21
--  ⚠️ Executar por ÚLTIMO, depois da Parte 1 e Parte 2.
--  ⚠️ Uso apenas em place próprio com NPCs seus.
-- ============================================================

local Players   = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local State = _G.AimState
local C     = _G.AimConst
local espGui = _G.AimEspGui
local espCache = _G.AimEspCache
local fovFrame = _G.AimFovFrame
local status = _G.AimStatus
local renderBotoes = _G.AimRenderBotoes

-- ============================================================
--  HELPERS DE ESP
-- ============================================================
local function criarEspPara(modelo)
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 2
    box.Parent = espGui

    local s = Instance.new("UIStroke")
    s.Color = State.espColor
    s.Thickness = 1
    s.Transparency = 0.1
    s.Parent = box

    local nameLbl = Instance.new("TextLabel")
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 9
    nameLbl.TextColor3 = State.espColor
    nameLbl.TextStrokeTransparency = 0.3
    nameLbl.TextXAlignment = Enum.TextXAlignment.Center
    nameLbl.AnchorPoint = Vector2.new(0.5, 1)
    nameLbl.Visible = false
    nameLbl.ZIndex = 3
    nameLbl.Parent = espGui

    espCache[modelo] = { box = box, stroke = s, name = nameLbl }
    return espCache[modelo]
end

local function limparEspDe(modelo)
    local entry = espCache[modelo]
    if entry then
        entry.box:Destroy()
        entry.name:Destroy()
        espCache[modelo] = nil
    end
end

-- ============================================================
--  HELPERS NPC / VISÃO
-- ============================================================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function acharTorso(character)
    if not character then return nil end
    return character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
end

local function acharCabeca(character)
    if not character then return nil end
    return character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

local function alvoNaVisao(torso, meuChar)
    local camPos = camera.CFrame.Position
    local delta = torso.Position - camPos
    local dist = delta.Magnitude
    if dist < 1 or dist > C.MAX_DIST then return false end
    if camera.CFrame.LookVector:Dot(delta.Unit) <= 0.1 then return false end

    local posTela, onScreen = camera:WorldToViewportPoint(torso.Position)
    if not onScreen then return false end
    if posTela.Z <= 0 then return false end

    local vp = camera.ViewportSize
    if posTela.X < 0 or posTela.X > vp.X
    or posTela.Y < 0 or posTela.Y > vp.Y then
        return false
    end

    local centro = vp / 2
    local dx, dy = posTela.X - centro.X, posTela.Y - centro.Y
    if math.sqrt(dx*dx + dy*dy) > State.fovSize / 2 then return false end

    rayParams.FilterDescendantsInstances = { meuChar, torso.Parent }
    local hit = Workspace:Raycast(camPos, delta, rayParams)
    if hit and hit.Instance then
        if hit.Instance:IsDescendantOf(torso.Parent) then return true end
        if hit.Instance.Transparency and hit.Instance.Transparency >= 0.95 then
            return true
        end
        return false
    end
    return true
end

local function acharAlvo()
    local meuChar = player.Character
    if not meuChar or not camera then return nil end

    local centro = camera.ViewportSize / 2
    local raio = State.fovSize / 2
    local melhor, melhorDist = nil, math.huge

    for _, modelo in ipairs(Workspace:GetChildren()) do
        if modelo:IsA("Model") and modelo ~= meuChar then
            local hum = modelo:FindFirstChildOfClass("Humanoid")
            local torso = acharTorso(modelo)
            if hum and torso and hum.Health > 0 and alvoNaVisao(torso, meuChar) then
                local posTela = camera:WorldToViewportPoint(torso.Position)
                local dx, dy = posTela.X - centro.X, posTela.Y - centro.Y
                local d = math.sqrt(dx*dx + dy*dy)
                if d <= raio and d < melhorDist then
                    melhorDist = d
                    melhor = torso
                end
            end
        end
    end
    return melhor
end

-- ============================================================
--  NOCLIP
-- ============================================================
local function aplicarNoclip(char)
    if not char then return end
    for _, parte in ipairs(char:GetDescendants()) do
        if parte:IsA("BasePart") and not C.PARTES_PROTEGIDAS[parte.Name] then
            parte.CanCollide = false
        end
    end
end

local function restaurarColisao(char)
    if not char then return end
    for _, parte in ipairs(char:GetDescendants()) do
        if parte:IsA("BasePart") and not C.PARTES_PROTEGIDAS[parte.Name] then
            parte.CanCollide = true
        end
    end
end

_G.AimRestaurarColisao = restaurarColisao

-- ============================================================
--  VELOCIDADE
-- ============================================================
local function aplicarVelocidade()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.speedVal
    end
end

local function restaurarVelocidade()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
    end
end

_G.AimAplicarVelocidade = aplicarVelocidade
_G.AimRestaurarVelocidade = restaurarVelocidade

-- ============================================================
--  AIMBOT — FIX: NÃO muda CameraType
-- ============================================================
local function mirarNoAlvo(torso)
    local camPos = camera.CFrame.Position
    local alvoPos = torso.Position
    local dir = (alvoPos - camPos).Unit

    local atual = camera.CFrame.LookVector
    local forca = math.clamp(State.aimForce / 100, 0, 1)
    local novoDir = atual:Lerp(dir, forca)

    local up = Vector3.new(0, 1, 0)
    if math.abs(novoDir.Y) > 0.99 then up = Vector3.new(0, 0, 1) end

    -- NÃO mexe em CameraType. Só sobrescreve o CFrame.
    camera.CFrame = CFrame.lookAt(camPos, camPos + novoDir, up)
end

-- ============================================================
--  LOOP PRINCIPAL
-- ============================================================
local statusTimer = 0

RunService.RenderStepped:Connect(function(dt)
    statusTimer = statusTimer + dt

    fovFrame.Visible = State.aimbotOn

    -- ===== AIMBOT =====
    if State.aimbotOn then
        local alvo = acharAlvo()
        if alvo then
            mirarNoAlvo(alvo)
            if statusTimer > 0.15 then
                statusTimer = 0
                status.Text = string.format("TRAVADO • %.0fm",
                    (alvo.Position - camera.CFrame.Position).Magnitude)
            end
        else
            if statusTimer > 0.3 then
                statusTimer = 0
                status.Text = "AIMBOT • sem alvo na visão"
            end
        end
    else
        if statusTimer > 0.5 then
            statusTimer = 0
            status.Text = "STATUS: idle"
        end
    end

    -- ===== NOCLIP =====
    if State.noclipOn then
        local char = player.Character
        if char then aplicarNoclip(char) end
    end

    -- ===== VELOCIDADE =====
    if State.speedOn then
        aplicarVelocidade()
    end

    -- ===== ESP =====
    if not State.espOn then
        for _, e in pairs(espCache) do
            e.box.Visible = false
            e.name.Visible = false
        end
        return
    end

    local meuChar = player.Character
    local camPos = camera.CFrame.Position
    local vistos = {}

    for _, modelo in ipairs(Workspace:GetChildren()) do
        if modelo:IsA("Model") and modelo ~= meuChar then
            local hum = modelo:FindFirstChildOfClass("Humanoid")
            local cabeca = acharCabeca(modelo)
            if hum and hum.Health > 0 and cabeca then
                local dist = (cabeca.Position - camPos).Magnitude
                if dist <= C.ESP_MAX_DIST then
                    local entry = espCache[modelo] or criarEspPara(modelo)
                    vistos[modelo] = true

                    local pos, onScreen = camera:WorldToViewportPoint(cabeca.Position)
                    if onScreen then
                        local escala = math.clamp(1200 / dist, 10, 60)
                        entry.box.Position = UDim2.fromOffset(pos.X - escala/2, pos.Y - escala/2)
                        entry.box.Size = UDim2.fromOffset(escala, escala)
                        entry.box.Visible = true
                        entry.stroke.Color = State.espColor
                        entry.name.Position = UDim2.fromOffset(pos.X, pos.Y - escala/2 - 2)
                        entry.name.Text = modelo.Name
                        entry.name.Visible = true
                        entry.name.TextColor3 = State.espColor
                    else
                        entry.box.Visible = false
                        entry.name.Visible = false
                    end
                end
            end
        end
    end

    for modelo, entry in pairs(espCache) do
        if not vistos[modelo] then
            entry.box.Visible = false
            entry.name.Visible = false
            if not modelo.Parent or not modelo:FindFirstChildOfClass("Humanoid") then
                limparEspDe(modelo)
            end
        end
    end
end)

-- ============================================================
--  AUTO-APLICAR AO RESPAWNAR
-- ============================================================
local function onChar(char)
    char:WaitForChild("Humanoid")
    task.wait(0.2)
    if State.noclipOn then aplicarNoclip(char) end
    if State.speedOn then aplicarVelocidade() end
end

if player.Character then onChar(player.Character) end
player.CharacterAdded:Connect(onChar)

print("[PARTE 3] Lógica carregada. Tudo funcionando.")
