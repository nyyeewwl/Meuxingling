-- PARTE 1: INTERFACE (Janela, Botões e Visual)
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

_G.State = {
    aimbotOn = false, espOn = true, noclipOn = false, speedOn = false,
    speedVal = 16, fovSize = 250, fovColor = Color3.fromRGB(0, 255, 170),
    espColor = Color3.fromRGB(0, 255, 170), aimForce = 50, minimized = false,
}
_G.C = {
    WIN_W = 320, WIN_H = 520, MINI_SIZE = 48, MARGEM_CANTO = 12,
    MAX_DIST = 350, ESP_MAX_DIST = 300, SPEED_MIN = 1, SPEED_MAX = 9999,
    FOV_MIN = 80, FOV_MAX = 500,
    PARTES_PROTEGIDAS = {HumanoidRootPart=true, Head=true, UpperTorso=true, LowerTorso=true, Torso=true},
}
_G.Theme = {
    bg = Color3.fromRGB(18, 18, 22), bgSoft = Color3.fromRGB(28, 28, 34),
    accent = Color3.fromRGB(0, 255, 170), accentDim = Color3.fromRGB(0, 180, 120),
    danger = Color3.fromRGB(255, 70, 90), text = Color3.fromRGB(235, 235, 245),
    textDim = Color3.fromRGB(150, 150, 165),
}

function _G.corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0, 10); c.Parent = p; return c end
function _G.stroke(p, color, th, tr) local s = Instance.new("UIStroke"); s.Color = color or _G.Theme.accentDim; s.Thickness = th or 1; s.Transparency = tr or 0.4; s.Parent = p; return s end

local State, C, Theme = _G.State, _G.C, _G.Theme
local corner, stroke = _G.corner, _G.stroke

_G.espGui = Instance.new("ScreenGui"); _G.espGui.Name = "ESPGui"; _G.espGui.ResetOnSpawn = false; _G.espGui.IgnoreGuiInset = true; _G.espGui.DisplayOrder = 998; _G.espGui.Parent = playerGui
_G.fovGui = Instance.new("ScreenGui"); _G.fovGui.Name = "FOVGui"; _G.fovGui.ResetOnSpawn = false; _G.fovGui.IgnoreGuiInset = true; _G.fovGui.DisplayOrder = 999; _G.fovGui.Parent = playerGui

_G.fovFrame = Instance.new("Frame"); _G.fovFrame.AnchorPoint = Vector2.new(0.5, 0.5); _G.fovFrame.Position = UDim2.fromScale(0.5, 0.5); _G.fovFrame.Size = UDim2.fromOffset(State.fovSize, State.fovSize); _G.fovFrame.BackgroundTransparency = 1; _G.fovFrame.Visible = false; _G.fovFrame.Parent = _G.fovGui
corner(_G.fovFrame, UDim.new(1, 0))
local fovStroke = Instance.new("UIStroke"); fovStroke.Color = State.fovColor; fovStroke.Thickness = 2; fovStroke.Transparency = 0.15; fovStroke.Parent = _G.fovFrame
_G.atualizarFOV = function() _G.fovFrame.Size = UDim2.fromOffset(State.fovSize, State.fovSize); fovStroke.Color = State.fovColor end

_G.gui = Instance.new("ScreenGui"); _G.gui.Name = "AimGui"; _G.gui.ResetOnSpawn = false; _G.gui.IgnoreGuiInset = true; _G.gui.DisplayOrder = 1000; _G.gui.Parent = playerGui
_G.main = Instance.new("Frame"); _G.main.AnchorPoint = Vector2.new(0.5, 0.5); _G.main.Position = UDim2.fromScale(0.5, 0.5); _G.main.Size = UDim2.fromOffset(C.WIN_W, C.WIN_H); _G.main.BackgroundColor3 = Theme.bg; _G.main.BackgroundTransparency = 0.25; _G.main.BorderSizePixel = 0; _G.main.Active = true; _G.main.ClipsDescendants = true; _G.main.Parent = _G.gui
corner(_G.main); stroke(_G.main, Theme.accentDim, 1.5, 0.35)

local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 42); header.BackgroundColor3 = Theme.bgSoft; header.BackgroundTransparency = 0.35; header.BorderSizePixel = 0; header.ZIndex = 3; header.Parent = _G.main; corner(header)
local title = Instance.new("TextLabel"); title.Text = "AIM  •  DEMO"; title.Font = Enum.Font.GothamBold; title.TextSize = 15; title.TextColor3 = Theme.accent; title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left; title.Position = UDim2.fromOffset(14, 0); title.Size = UDim2.new(0.55, 0, 1, 0); title.ZIndex = 4; title.Parent = header
local minBtn = Instance.new("TextButton"); minBtn.Text = "—"; minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 16; minBtn.TextColor3 = Theme.text; minBtn.BackgroundColor3 = Theme.bg; minBtn.BackgroundTransparency = 0.4; minBtn.AutoButtonColor = false; minBtn.AnchorPoint = Vector2.new(1, 0.5); minBtn.Position = UDim2.new(1, -42, 0.5, 0); minBtn.Size = UDim2.fromOffset(30, 28); minBtn.ZIndex = 4; minBtn.Parent = header; corner(minBtn, UDim.new(0, 8))
local closeBtn = Instance.new("TextButton"); closeBtn.Text = "✕"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14; closeBtn.TextColor3 = Theme.danger; closeBtn.BackgroundColor3 = Theme.bg; closeBtn.BackgroundTransparency = 0.4; closeBtn.AutoButtonColor = false; closeBtn.AnchorPoint = Vector2.new(1, 0.5); closeBtn.Position = UDim2.new(1, -8, 0.5, 0); closeBtn.Size = UDim2.fromOffset(30, 28); closeBtn.ZIndex = 4; closeBtn.Parent = header; corner(closeBtn, UDim.new(0, 8))

_G.body = Instance.new("Frame"); _G.body.Size = UDim2.new(1, -20, 1, -58); _G.body.Position = UDim2.fromOffset(10, 50); _G.body.BackgroundTransparency = 1; _G.body.ZIndex = 2; _G.body.Parent = _G.main
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = _G.body
_G.status = Instance.new("TextLabel"); _G.status.Size = UDim2.new(1, 0, 0, 32); _G.status.BackgroundColor3 = Color3.fromRGB(10, 10, 12); _G.status.BackgroundTransparency = 0.3; _G.status.Font = Enum.Font.Code; _G.status.TextSize = 11; _G.status.TextColor3 = Theme.accent; _G.status.TextXAlignment = Enum.TextXAlignment.Center; _G.status.Text = "STATUS: idle"; _G.status.LayoutOrder = 0; _G.status.ZIndex = 3; _G.status.Parent = _G.body; corner(_G.status, UDim.new(0, 6))

local function criarBotao(txt, ordem, altura)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, altura); b.BackgroundColor3 = Theme.bgSoft; b.BackgroundTransparency = 0.4; b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.TextColor3 = Theme.text; b.AutoButtonColor = false; b.LayoutOrder = ordem; b.ZIndex = 3; b.Parent = _G.body; corner(b)
    return b, stroke(b, Theme.accentDim, 1.5, 0.5)
end

_G.aimbotBtn, _G.aimbotStroke = criarBotao("AIMBOT  •  OFF", 1, 44)
_G.espBtn, _G.espStroke = criarBotao("ESP  •  ON", 2, 40)
_G.noclipBtn, _G.noclipStroke = criarBotao("NOCLIP  •  OFF", 3, 40)
_G.speedBtn, _G.speedStroke = criarBotao("VELOCIDADE  •  OFF", 4, 40)

_G.renderBotoes = function()
    if State.aimbotOn then _G.aimbotBtn.BackgroundColor3 = Theme.accent; _G.aimbotBtn.BackgroundTransparency = 0.15; _G.aimbotBtn.TextColor3 = Color3.fromRGB(10, 20, 15); _G.aimbotStroke.Color = Theme.accent; _G.aimbotStroke.Transparency = 0; _G.aimbotBtn.Text = "AIMBOT  •  ON"
    else _G.aimbotBtn.BackgroundColor3 = Theme.bgSoft; _G.aimbotBtn.BackgroundTransparency = 0.4; _G.aimbotBtn.TextColor3 = Theme.text; _G.aimbotStroke.Color = Theme.accentDim; _G.aimbotStroke.Transparency = 0.5; _G.aimbotBtn.Text = "AIMBOT  •  OFF" end
    if State.espOn then _G.espBtn.BackgroundColor3 = Color3.fromRGB(90, 160, 255); _G.espBtn.BackgroundTransparency = 0.15; _G.espBtn.TextColor3 = Color3.fromRGB(10, 15, 25); _G.espStroke.Color = Color3.fromRGB(90, 160, 255); _G.espStroke.Transparency = 0; _G.espBtn.Text = "ESP  •  ON"
    else _G.espBtn.BackgroundColor3 = Theme.bgSoft; _G.espBtn.BackgroundTransparency = 0.4; _G.espBtn.TextColor3 = Theme.text; _G.espStroke.Color = Theme.accentDim; _G.espStroke.Transparency = 0.5; _G.espBtn.Text = "ESP  •  OFF" end
    if State.noclipOn then _G.noclipBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 60); _G.noclipBtn.BackgroundTransparency = 0.15; _G.noclipBtn.TextColor3 = Color3.fromRGB(25, 15, 5); _G.noclipStroke.Color = Color3.fromRGB(255, 170, 60); _G.noclipStroke.Transparency = 0; _G.noclipBtn.Text = "NOCLIP  •  ON"
    else _G.noclipBtn.BackgroundColor3 = Theme.bgSoft; _G.noclipBtn.BackgroundTransparency = 0.4; _G.noclipBtn.TextColor3 = Theme.text; _G.noclipStroke.Color = Theme.accentDim; _G.noclipStroke.Transparency = 0.5; _G.noclipBtn.Text = "NOCLIP  •  OFF" end
    if State.speedOn then _G.speedBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 255); _G.speedBtn.BackgroundTransparency = 0.15; _G.speedBtn.TextColor3 = Color3.fromRGB(15, 5, 25); _G.speedStroke.Color = Color3.fromRGB(180, 120, 255); _G.speedStroke.Transparency = 0; _G.speedBtn.Text = "VELOCIDADE  •  ON (" .. State.speedVal .. ")"
    else _G.speedBtn.BackgroundColor3 = Theme.bgSoft; _G.speedBtn.BackgroundTransparency = 0.4; _G.speedBtn.TextColor3 = Theme.text; _G.speedStroke.Color = Theme.accentDim; _G.speedStroke.Transparency = 0.5; _G.speedBtn.Text = "VELOCIDADE  •  OFF" end
end
_G.renderBotoes()
