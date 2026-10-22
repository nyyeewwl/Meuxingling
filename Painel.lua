-- ============================================================
--  PARTE 1 — AIMBOT + ESP + NOCLIP — v18
--  (interface, GUI, ESP, FOV, sliders)
-- ============================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera    = Workspace.CurrentCamera

-- ============================================================
--  ESTADO
-- ============================================================
local State = {
    aimbotOn  = false,
    espOn     = true,
    noclipOn  = false,
    fovSize   = 250,
    fovColor  = Color3.fromRGB(0, 255, 170),
    espColor  = Color3.fromRGB(0, 255, 170),
    aimForce  = 50,
    minimized = false,
}

local WIN_W, WIN_H = 320, 440
local MINI_SIZE    = 48
local MARGEM_CANTO = 12
local MAX_DIST     = 350
local ESP_MAX_DIST = 300
local WALKSPEED_PADRAO = 16
local JUMPPOWER_PADRAO = 50

-- ============================================================
--  TEMA / HELPERS
-- ============================================================
local Theme = {
    bg        = Color3.fromRGB(18, 18, 22),
    bgSoft    = Color3.fromRGB(28, 28, 34),
    accent    = Color3.fromRGB(0, 255, 170),
    accentDim = Color3.fromRGB(0, 180, 120),
    danger    = Color3.fromRGB(255, 70, 90),
    text      = Color3.fromRGB(235, 235, 245),
    textDim   = Color3.fromRGB(150, 150, 165),
}

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0, 10); c.Parent = p; return c
end
local function stroke(p, color, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.accentDim; s.Thickness = th or 1; s.Transparency = tr or 0.4
    s.Parent = p; return s
end

-- ============================================================
--  ESP GUI
-- ============================================================
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPGui"; espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true; espGui.DisplayOrder = 998
espGui.Parent = playerGui

local espCache = {}

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
--  CÍRCULO DO FOV
-- ============================================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVGui"; fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true; fovGui.DisplayOrder = 999
fovGui.Parent = playerGui

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

local function atualizarFOV()
    fovFrame.Size = UDim2.fromOffset(State.fovSize, State.fovSize)
    fovStroke.Color = State.fovColor
end

-- ============================================================
--  JANELA
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "AimGui"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true; gui.DisplayOrder = 1000
gui.Parent = playerGui

local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(WIN_W, WIN_H)
main.BackgroundColor3 = Theme.bg
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0; main.Active = true; main.ClipsDescendants = true
main.Parent = gui
corner(main)
stroke(main, Theme.accentDim, 1.5, 0.35)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Theme.bgSoft
header.BackgroundTransparency = 0.35
header.BorderSizePixel = 0; header.ZIndex = 3; header.Parent = main
corner(header)

local title = Instance.new("TextLabel")
title.Text = "AIM  •  DEMO"
title.Font = Enum.Font.GothamBold
title.TextSize = 15; title.TextColor3 = Theme.accent
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.fromOffset(14, 0)
title.Size = UDim2.new(0.55, 0, 1, 0)
title.ZIndex = 4; title.Parent = header

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

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -20, 1, -58)
body.Position = UDim2.fromOffset(10, 50)
body.BackgroundTransparency = 1; body.ZIndex = 2; body.Parent = main

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

local function renderBotoes()
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
end

-- ============================================================
--  SLIDERS
-- ============================================================
local forceLabel = Instance.new("TextLabel")
forceLabel.Size = UDim2.new(1, 0, 0, 16)
forceLabel.BackgroundTransparency = 1
forceLabel.Font = Enum.Font.Gotham
forceLabel.TextSize = 12; forceLabel.TextColor3 = Theme.textDim
forceLabel.TextXAlignment = Enum.TextXAlignment.Left
forceLabel.Text = "FORÇA DA MIRA"
forceLabel.LayoutOrder = 4; forceLabel.ZIndex = 3; forceLabel.Parent = body

local sliderHolder = Instance.new("Frame")
sliderHolder.Size = UDim2.new(1, 0, 0, 40)
sliderHolder.BackgroundColor3 = Theme.bgSoft
sliderHolder.BackgroundTransparency = 0.4
sliderHolder.BorderSizePixel = 0
sliderHolder.LayoutOrder = 5; sliderHolder.ZIndex = 3; sliderHolder.Parent = body
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

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 16)
fovLabel.BackgroundTransparency = 1
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 12; fovLabel.TextColor3 = Theme.textDim
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Text = "TAMANHO DO FOV"
fovLabel.LayoutOrder = 6; fovLabel.ZIndex = 3; fovLabel.Parent = body

local fovHolder = Instance.new("Frame")
fovHolder.Size = UDim2.new(1, 0, 0, 40)
fovHolder.BackgroundColor3 = Theme.bgSoft
fovHolder.BackgroundTransparency = 0.4
fovHolder.BorderSizePixel = 0
fovHolder.LayoutOrder = 7; fovHolder.ZIndex = 3; fovHolder.Parent = body
corner(fovHolder)

local fovTrack = Instance.new("Frame")
fovTrack.AnchorPoint = Vector2.new(0, 0.5)
fovTrack.Position = UDim2.new(0, 12, 0.5, 0)
fovTrack.Size = UDim2.new(1, -96, 0, 6)
fovTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
fovTrack.BorderSizePixel = 0; fovTrack.ZIndex = 4; fovTrack.Parent = fovHolder
corner(fovTrack, UDim.new(1, 0))

local FOV_MIN, FOV_MAX = 80, 500
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
--  PARTE 2 — AIMBOT + ESP + NOCLIP — v18
--  (helpers, noclip, aimbot, loop principal, botões,
--   minimizar, drag, fechar, respawn)
-- ============================================================

-- ============================================================
--  HELPERS DE NPC / VISÃO
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
    if dist < 1 or dist > MAX_DIST then return false end
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
    if not hit then return true end
    if hit.Instance:IsDescendantOf(torso.Parent) then return true end
    if hit.Instance.Transparency and hit.Instance.Transparency >= 0.95 then
        return true
    end
    return false
end

local function acharAlvo()
    local meuChar = player.Character
    if not meuChar then return nil end
    if not camera then return nil end

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
--  NOCLIP — SEM QUEBRAR O HUMANOID
-- ============================================================
local partesIgnoradasNoclip = {
    HumanoidRootPart = true,
}

local function aplicarNoclip(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.WalkSpeed ~= WALKSPEED_PADRAO then
            hum.WalkSpeed = WALKSPEED_PADRAO
        end
        if hum.JumpPower ~= JUMPPOWER_PADRAO then
            hum.JumpPower = JUMPPOWER_PADRAO
        end
    end
    for _, parte in ipairs(char:GetDescendants()) do
        if parte:IsA("BasePart") and not partesIgnoradasNoclip[parte.Name] then
            if parte.CanCollide then
                parte.CanCollide = false
            end
        end
    end
end

local function restaurarColisao(char)
    if not char then return end
    for _, parte in ipairs(char:GetDescendants()) do
        if parte:IsA("BasePart") then
            if parte.Name ~= "HumanoidRootPart" then
                parte.CanCollide = true
            end
        end
    end
end

-- ============================================================
--  AIMBOT — CÂMERA SEM TRAVAR O BONECO
-- ============================================================
local function restaurarCamera()
    if camera.CameraType == Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Custom
    end
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
            local camPos = camera.CFrame.Position
            local alvoPos = alvo.Position
            local dir = (alvoPos - camPos).Unit
            local atual = camera.CFrame.LookVector
            local forca = math.clamp(State.aimForce / 100, 0, 1) * 0.35
            local novoDir = atual:Lerp(dir, forca)

            if camera.CameraType ~= Enum.CameraType.Custom then
                camera.CameraType = Enum.CameraType.Custom
            end

            local up = Vector3.new(0, 1, 0)
            if math.abs(novoDir.Y) > 0.99 then up = Vector3.new(0, 0, 1) end
            camera.CFrame = CFrame.lookAt(camPos, camPos + novoDir, up)

            if statusTimer > 0.15 then
                statusTimer = 0
                status.Text = string.format("TRAVADO • %.0fm", (alvoPos - camPos).Magnitude)
            end
        else
            if statusTimer > 0.3 then
                statusTimer = 0
                status.Text = "AIMBOT • sem alvo na visão"
            end
        end
    else
        restaurarCamera()
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
                if dist <= ESP_MAX_DIST then
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
--  BOTÕES ON/OFF
-- ============================================================
aimbotBtn.MouseButton1Click:Connect(function()
    State.aimbotOn = not State.aimbotOn
    if not State.aimbotOn then restaurarCamera() end
    renderBotoes()
end)

espBtn.MouseButton1Click:Connect(function()
    State.espOn = not State.espOn
    renderBotoes()
end)

noclipBtn.MouseButton1Click:Connect(function()
    State.noclipOn = not State.noclipOn
    if not State.noclipOn then
        restaurarColisao(player.Character)
    end
    renderBotoes()
end)

-- ============================================================
--  MINIMIZAR → CANTO DIREITO
-- ============================================================
local posAntesDeMinimizar = nil

local function setMinimized(min)
    State.minimized = min
    if min then
        posAntesDeMinimizar = main.Position
        main.Size = UDim2.fromOffset(MINI_SIZE, MINI_SIZE)
        main.AnchorPoint = Vector2.new(1, 0)
        main.Position = UDim2.new(1, -MARGEM_CANTO, 0, MARGEM_CANTO)
        body.Visible = false
        title.Visible = false
        minBtn.Visible = false
        closeBtn.Visible = false
    else
        main.Size = UDim2.fromOffset(WIN_W, WIN_H)
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
    restaurarColisao(player.Character)
    restaurarCamera()
    gui:Destroy()
    espGui:Destroy()
    fovGui:Destroy()
end)

-- ============================================================
--  AUTO-NOCLIP AO RESPAWNAR
-- ============================================================
local function onChar(char)
    char:WaitForChild("Humanoid")
    task.wait(0.2)
    if State.noclipOn then
        aplicarNoclip(char)
    end
end

if player.Character then onChar(player.Character) end
player.CharacterAdded:Connect(onChar)

-- INIT
renderBotoes()
status.Text = "STATUS: idle"
