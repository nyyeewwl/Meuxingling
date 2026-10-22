-- PARTE 3: MOTOR (Aimbot, ESP, Noclip, Velocidade)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player, camera = Players.LocalPlayer, Workspace.CurrentCamera
local State, C = _G.State, _G.C
local espGui, fovFrame, status, renderBotoes = _G.espGui, _G.fovFrame, _G.status, _G.renderBotoes
local espCache = {}

local function criarEsp(modelo)
    local box = Instance.new("Frame"); box.BackgroundTransparency = 1; box.BorderSizePixel = 0; box.Visible = false; box.ZIndex = 2; box.Parent = espGui
    local s = Instance.new("UIStroke"); s.Color = State.espColor; s.Thickness = 1; s.Transparency = 0.1; s.Parent = box
    local nameLbl = Instance.new("TextLabel"); nameLbl.BackgroundTransparency = 1; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 9; nameLbl.TextColor3 = State.espColor; nameLbl.TextStrokeTransparency = 0.3; nameLbl.TextXAlignment = Enum.TextXAlignment.Center; nameLbl.AnchorPoint = Vector2.new(0.5, 1); nameLbl.Visible = false; nameLbl.ZIndex = 3; nameLbl.Parent = espGui
    espCache[modelo] = { box = box, stroke = s, name = nameLbl }; return espCache[modelo]
end
local function limparEsp(modelo) if espCache[modelo] then espCache[modelo].box:Destroy(); espCache[modelo].name:Destroy(); espCache[modelo] = nil end end

local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude; rayParams.IgnoreWater = true
local function getTorso(char) return char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")) end
local function getCabeca(char) return char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")) end

local function visivel(torso, meuChar)
    local camPos, delta = camera.CFrame.Position, torso.Position - camera.CFrame.Position
    local dist = delta.Magnitude
    if dist < 1 or dist > C.MAX_DIST or camera.CFrame.LookVector:Dot(delta.Unit) <= 0.1 then return false end
    local pos, onScreen = camera:WorldToViewportPoint(torso.Position)
    if not onScreen or pos.Z <= 0 then return false end
    local vp = camera.ViewportSize
    if pos.X < 0 or pos.X > vp.X or pos.Y < 0 or pos.Y > vp.Y then return false end
    local dx, dy = pos.X - (vp.X/2), pos.Y - (vp.Y/2)
    if math.sqrt(dx*dx + dy*dy) > State.fovSize / 2 then return false end
    rayParams.FilterDescendantsInstances = { meuChar, torso.Parent }
    local hit = Workspace:Raycast(camPos, delta, rayParams)
    if hit and hit.Instance then
        if hit.Instance:IsDescendantOf(torso.Parent) then return true end
        if hit.Instance.Transparency and hit.Instance.Transparency >= 0.95 then return true end
        return false
    end
    return true
end

local function acharAlvo()
    local meuChar = player.Character; if not meuChar or not camera then return nil end
    local centro, raio = camera.ViewportSize / 2, State.fovSize / 2
    local melhor, melhorDist = nil, math.huge
    for _, modelo in ipairs(Workspace:GetChildren()) do
        if modelo:IsA("Model") and modelo ~= meuChar then
            local hum, torso = modelo:FindFirstChildOfClass("Humanoid"), getTorso(modelo)
            if hum and torso and hum.Health > 0 and visivel(torso, meuChar) then
                local pos = camera:WorldToViewportPoint(torso.Position)
                local dx, dy = pos.X - centro.X, pos.Y - centro.Y
                local d = math.sqrt(dx*dx + dy*dy)
                if d <= raio and d < melhorDist then melhorDist = d; melhor = torso end
            end
        end
    end
    return melhor
end

local function noclip(char) if not char then return end; for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and not C.PARTES_PROTEGIDAS[p.Name] then p.CanCollide = false end end end
local function colisao(char) if not char then return end; for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and not C.PARTES_PROTEGIDAS[p.Name] then p.CanCollide = true end end end
_G.aplicarVelocidade = function() local char = player.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = State.speedVal end end end
local function restVelocidade() local char = player.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = 16 end end end

_G.aimbotBtn.MouseButton1Click:Connect(function() State.aimbotOn = not State.aimbotOn; renderBotoes() end)
_G.espBtn.MouseButton1Click:Connect(function() State.espOn = not State.espOn; renderBotoes() end)
_G.noclipBtn.MouseButton1Click:Connect(function() State.noclipOn = not State.noclipOn; if not State.noclipOn then colisao(player.Character) end; renderBotoes() end)
_G.speedBtn.MouseButton1Click:Connect(function() State.speedOn = not State.speedOn; if State.speedOn then _G.aplicarVelocidade() else restVelocidade() end; renderBotoes() end)
_G.closeBtn.MouseButton1Click:Connect(function() State.aimbotOn, State.noclipOn, State.speedOn = false, false, false; colisao(player.Character); restVelocidade(); _G.gui:Destroy(); _G.espGui:Destroy(); _G.fovGui:Destroy() end)

local timer = 0
RunService.RenderStepped:Connect(function(dt)
    timer = timer + dt; fovFrame.Visible = State.aimbotOn
    
    if State.aimbotOn then
        local alvo = acharAlvo()
        if alvo then
            local camPos, alvoPos = camera.CFrame.Position, alvo.Position
            local novoDir = camera.CFrame.LookVector:Lerp((alvoPos - camPos).Unit, math.clamp(State.aimForce / 100, 0, 1))
            local up = Vector3.new(0, 1, 0); if math.abs(novoDir.Y) > 0.99 then up = Vector3.new(0, 0, 1) end
            camera.CFrame = CFrame.lookAt(camPos, camPos + novoDir, up)
            if timer > 0.15 then timer = 0; status.Text = string.format("TRAVADO • %.0fm", (alvoPos - camPos).Magnitude) end
        elseif timer > 0.3 then timer = 0; status.Text = "AIMBOT • sem alvo na visão" end
    elseif timer > 0.5 then timer = 0; status.Text = "STATUS: idle" end

    if State.noclipOn and player.Character then noclip(player.Character) end
    if State.speedOn then _G.aplicarVelocidade() end

    if not State.espOn then for _, e in pairs(espCache) do e.box.Visible = false; e.name.Visible = false end; return end
    
    local meuChar, camPos, vistos = player.Character, camera.CFrame.Position, {}
    for _, modelo in ipairs(Workspace:GetChildren()) do
        if modelo:IsA("Model") and modelo ~= meuChar then
            local hum, cabeca = modelo:FindFirstChildOfClass("Humanoid"), getCabeca(modelo)
            if hum and hum.Health > 0 and cabeca then
                local dist = (cabeca.Position - camPos).Magnitude
                if dist <= C.ESP_MAX_DIST then
                    local entry = espCache[modelo] or criarEsp(modelo); vistos[modelo] = true
                    local pos, onScreen = camera:WorldToViewportPoint(cabeca.Position)
                    if onScreen then
                        local escala = math.clamp(1200 / dist, 10, 60)
                        entry.box.Position = UDim2.fromOffset(pos.X - escala/2, pos.Y - escala/2); entry.box.Size = UDim2.fromOffset(escala, escala); entry.box.Visible = true
                        entry.stroke.Color = State.espColor
                        entry.name.Position = UDim2.fromOffset(pos.X, pos.Y - escala/2 - 2); entry.name.Text = modelo.Name; entry.name.Visible = true; entry.name.TextColor3 = State.espColor
                    else entry.box.Visible = false; entry.name.Visible = false end
                end
            end
        end
    end
    for modelo, entry in pairs(espCache) do if not vistos[modelo] then entry.box.Visible = false; entry.name.Visible = false; if not modelo.Parent or not modelo:FindFirstChildOfClass("Humanoid") then limparEsp(modelo) end end end
end)

player.CharacterAdded:Connect(function(char) char:WaitForChild("Humanoid"); task.wait(0.2); if State.noclipOn then noclip(char) end; if State.speedOn then _G.aplicarVelocidade() end end)
renderBotoes(); status.Text = "STATUS: idle"
