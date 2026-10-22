-- PARTE 2: CONTROLES (Sliders, Campo, Arrastar, Minimizar)
local UserInputService = game:GetService("UserInputService")
local State, C, Theme = _G.State, _G.C, _G.Theme
local corner, stroke, body, main, header = _G.corner, _G.stroke, _G.body, _G.main, _G.header
local title, minBtn, closeBtn, renderBotoes, atualizarFOV = _G.title, _G.minBtn, _G.closeBtn, _G.renderBotoes, _G.atualizarFOV

-- SLIDERS
local function bindSlider(track, fill, knob, onUpdate)
    local dragging = false
    local function process(input)
        local abs = track.AbsolutePosition
        local absSize = track.AbsoluteSize
        if absSize.X <= 0 then return end
        local pct = math.clamp((input.Position.X - abs.X) / absSize.X, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        onUpdate(pct)
    end
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; process(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then process(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local fLabel = Instance.new("TextLabel"); fLabel.Size = UDim2.new(1, 0, 0, 16); fLabel.BackgroundTransparency = 1; fLabel.Font = Enum.Font.Gotham; fLabel.TextSize = 12; fLabel.TextColor3 = Theme.textDim; fLabel.TextXAlignment = Enum.TextXAlignment.Left; fLabel.Text = "FORÇA DA MIRA"; fLabel.LayoutOrder = 5; fLabel.ZIndex = 3; fLabel.Parent = body
local sHolder = Instance.new("Frame"); sHolder.Size = UDim2.new(1, 0, 0, 40); sHolder.BackgroundColor3 = Theme.bgSoft; sHolder.BackgroundTransparency = 0.4; sHolder.BorderSizePixel = 0; sHolder.LayoutOrder = 6; sHolder.ZIndex = 3; sHolder.Parent = body; corner(sHolder)
local sTrack = Instance.new("Frame"); sTrack.AnchorPoint = Vector2.new(0, 0.5); sTrack.Position = UDim2.new(0, 12, 0.5, 0); sTrack.Size = UDim2.new(1, -96, 0, 6); sTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 58); sTrack.BorderSizePixel = 0; sTrack.ZIndex = 4; sTrack.Parent = sHolder; corner(sTrack, UDim.new(1, 0))
local sFill = Instance.new("Frame"); sFill.Size = UDim2.new(State.aimForce / 100, 0, 1, 0); sFill.BackgroundColor3 = Theme.accent; sFill.BorderSizePixel = 0; sFill.ZIndex = 5; sFill.Parent = sTrack; corner(sFill, UDim.new(1, 0))
local sKnob = Instance.new("Frame"); sKnob.AnchorPoint = Vector2.new(0.5, 0.5); sKnob.Position = UDim2.new(State.aimForce / 100, 0, 0.5, 0); sKnob.Size = UDim2.fromOffset(16, 16); sKnob.BackgroundColor3 = Theme.text; sKnob.BorderSizePixel = 0; sKnob.ZIndex = 6; sKnob.Parent = sTrack; corner(sKnob, UDim.new(1, 0))
local sVal = Instance.new("TextLabel"); sVal.AnchorPoint = Vector2.new(1, 0.5); sVal.Position = UDim2.new(1, -12, 0.5, 0); sVal.Size = UDim2.fromOffset(64, 20); sVal.BackgroundTransparency = 1; sVal.Font = Enum.Font.GothamBold; sVal.TextSize = 13; sVal.TextColor3 = Theme.accent; sVal.Text = tostring(State.aimForce) .. "%"; sVal.ZIndex = 6; sVal.Parent = sHolder

bindSlider(sTrack, sFill, sKnob, function(pct) State.aimForce = math.floor(pct * 100 + 0.5); sVal.Text = tostring(State.aimForce) .. "%" end)

local vLabel = Instance.new("TextLabel"); vLabel.Size = UDim2.new(1, 0, 0, 16); vLabel.BackgroundTransparency = 1; vLabel.Font = Enum.Font.Gotham; vLabel.TextSize = 12; vLabel.TextColor3 = Theme.textDim; vLabel.TextXAlignment = Enum.TextXAlignment.Left; vLabel.Text = "TAMANHO DO FOV"; vLabel.LayoutOrder = 7; vLabel.ZIndex = 3; vLabel.Parent = body
local vHolder = Instance.new("Frame"); vHolder.Size = UDim2.new(1, 0, 0, 40); vHolder.BackgroundColor3 = Theme.bgSoft; vHolder.BackgroundTransparency = 0.4; vHolder.BorderSizePixel = 0; vHolder.LayoutOrder = 8; vHolder.ZIndex = 3; vHolder.Parent = body; corner(vHolder)
local vTrack = Instance.new("Frame"); vTrack.AnchorPoint = Vector2.new(0, 0.5); vTrack.Position = UDim2.new(0, 12, 0.5, 0); vTrack.Size = UDim2.new(1, -96, 0, 6); vTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 58); vTrack.BorderSizePixel = 0; vTrack.ZIndex = 4; vTrack.Parent = vHolder; corner(vTrack, UDim.new(1, 0))
local vPct = (State.fovSize - C.FOV_MIN) / (C.FOV_MAX - C.FOV_MIN)
local vFill = Instance.new("Frame"); vFill.Size = UDim2.new(vPct, 0, 1, 0); vFill.BackgroundColor3 = Theme.accentDim; vFill.BorderSizePixel = 0; vFill.ZIndex = 5; vFill.Parent = vTrack; corner(vFill, UDim.new(1, 0))
local vKnob = Instance.new("Frame"); vKnob.AnchorPoint = Vector2.new(0.5, 0.5); vKnob.Position = UDim2.new(vPct, 0, 0.5, 0); vKnob.Size = UDim2.fromOffset(16, 16); vKnob.BackgroundColor3 = Theme.text; vKnob.BorderSizePixel = 0; vKnob.ZIndex = 6; vKnob.Parent = vTrack; corner(vKnob, UDim.new(1, 0))
local vVal = Instance.new("TextLabel"); vVal.AnchorPoint = Vector2.new(1, 0.5); vVal.Position = UDim2.new(1, -12, 0.5, 0); vVal.Size = UDim2.fromOffset(64, 20); vVal.BackgroundTransparency = 1; vVal.Font = Enum.Font.GothamBold; vVal.TextSize = 13; vVal.TextColor3 = Theme.accentDim; vVal.Text = tostring(State.fovSize) .. "px"; vVal.ZIndex = 6; vVal.Parent = vHolder

bindSlider(vTrack, vFill, vKnob, function(pct) State.fovSize = math.floor(C.FOV_MIN + (C.FOV_MAX - C.FOV_MIN) * pct + 0.5); vVal.Text = tostring(State.fovSize) .. "px"; atualizarFOV() end)

-- CAMPO VELOCIDADE
local spHolder = Instance.new("Frame"); spHolder.Size = UDim2.new(1, 0, 0, 40); spHolder.BackgroundColor3 = Theme.bgSoft; spHolder.BackgroundTransparency = 0.4; spHolder.BorderSizePixel = 0; spHolder.LayoutOrder = 9; spHolder.ZIndex = 3; spHolder.Parent = body; corner(spHolder)
local spLabel = Instance.new("TextLabel"); spLabel.AnchorPoint = Vector2.new(0, 0.5); spLabel.Position = UDim2.new(0, 12, 0.5, 0); spLabel.Size = UDim2.fromOffset(80, 20); spLabel.BackgroundTransparency = 1; spLabel.Font = Enum.Font.Gotham; spLabel.TextSize = 12; spLabel.TextColor3 = Theme.textDim; spLabel.TextXAlignment = Enum.TextXAlignment.Left; spLabel.Text = "Valor (1-9999)"; spLabel.ZIndex = 5; spLabel.Parent = spHolder
local spBox = Instance.new("TextBox"); spBox.AnchorPoint = Vector2.new(1, 0.5); spBox.Position = UDim2.new(1, -12, 0.5, 0); spBox.Size = UDim2.fromOffset(110, 28); spBox.BackgroundColor3 = Color3.fromRGB(10, 10, 12); spBox.BackgroundTransparency = 0.2; spBox.BorderSizePixel = 0; spBox.Font = Enum.Font.GothamBold; spBox.TextSize = 14; spBox.TextColor3 = Theme.accent; spBox.Text = tostring(State.speedVal); spBox.ClearTextOnFocus = false; spBox.ZIndex = 5; spBox.Parent = spHolder; corner(spBox, UDim.new(0, 6)); stroke(spBox, Theme.accentDim, 1, 0.5)
_G.speedBox = spBox

spBox.FocusLost:Connect(function() local num = tonumber(spBox.Text); if not num then spBox.Text = tostring(State.speedVal); return end; num = math.clamp(math.floor(num), C.SPEED_MIN, C.SPEED_MAX); State.speedVal = num; spBox.Text = tostring(num); if State.speedOn and _G.aplicarVelocidade then _G.aplicarVelocidade() end; renderBotoes() end)
spBox:GetPropertyChangedSignal("Text"):Connect(function() local limpo = spBox.Text:gsub("[^%d]", ""); if limpo ~= spBox.Text then spBox.Text = limpo end; if #limpo > 4 then spBox.Text = limpo:sub(1, 4) end end)

-- CONTROLES DA JANELA
local posAntes = nil
_G.setMinimized = function(min)
    State.minimized = min
    if min then
        posAntes = main.Position; main.Size = UDim2.fromOffset(C.MINI_SIZE, C.MINI_SIZE); main.AnchorPoint = Vector2.new(1, 0); main.Position = UDim2.new(1, -C.MARGEM_CANTO, 0, C.MARGEM_CANTO)
        body.Visible = false; title.Visible = false; minBtn.Visible = false; closeBtn.Visible = false
    else
        main.Size = UDim2.fromOffset(C.WIN_W, C.WIN_H); main.AnchorPoint = Vector2.new(0.5, 0.5); main.Position = posAntes or UDim2.fromScale(0.5, 0.5)
        body.Visible = true; title.Visible = true; minBtn.Visible = true; closeBtn.Visible = true
    end
end
minBtn.MouseButton1Click:Connect(function() _G.setMinimized(true) end)
main.InputBegan:Connect(function(input) if State.minimized and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then _G.setMinimized(false) end end)

local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(input) if State.minimized then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
