-- COLE ISSO NO EXECUTOR DO CELULAR
local url = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPOSITORIO/main/"

local function pegar(arquivo)
    local sucesso, texto = pcall(function() return game:HttpGet(url .. arquivo) end)
    if sucesso then loadstring(texto)() else warn("Erro ao baixar: " .. arquivo) end
end

pegar("parte1.lua")
pegar("parte2.lua")
pegar("parte3.lua")

print("Painel carregado com sucesso!")
