--[[
    ENDER OS v16 - GHOST & TORNADO MANAGEMENT
    - Control de Radio Dinámico
    - Limitador de Piezas ajustable por el usuario
    - Optimización de FPS para dispositivos móviles
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- CONFIGURACIÓN INICIAL (GESTIONABLE)
_G.TornadoData = {
    Enabled = false,
    Radius = 30,
    MaxParts = 40,
    Speed = 2,
    Strength = 1800
}

-- SISTEMA DE RED (NETWORK)
if not getgenv().Network then
    getgenv().Network = {BaseParts = {}, Velocity = Vector3.new(14.47, 14.47, 14.47)}
    task.spawn(function()
        LPlayer.ReplicationFocus = workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LPlayer, "SimulationRadius", math.huge)
            for _, p in pairs(getgenv().Network.BaseParts) do
                if p:IsDescendantOf(workspace) then p.Velocity = getgenv().Network.Velocity end
            end
        end)
    end)
end

-- INTERFAZ V16
local SG = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 300, 0, 450)
Main.Position = UDim2.new(0.5, -150, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -80)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- FUNCIÓN PARA CREAR GESTORES DE VALORES (TEXT + BOTÓN)
local function AddManager(title, valueKey, step, maxVal)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Text = title .. ": " .. _G.TornadoData[valueKey]
    label.TextColor3 = Color3.new(0, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = "Aumentar (+ " .. step .. ")"
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        _G.TornadoData[valueKey] = _G.TornadoData[valueKey] + step
        if _G.TornadoData[valueKey] > maxVal then _G.TornadoData[valueKey] = step end
        label.Text = title .. ": " .. _G.TornadoData[valueKey]
    end)
end

-- AGREGAR CONTROLES AL PANEL
AddManager("RADIO DE GIRO", "Radius", 15, 150)
AddManager("CANTIDAD DE PIEZAS", "MaxParts", 20, 200)

-- BOTÓN DE ACTIVACIÓN PRINCIPAL
local Toggle = Instance.new("TextButton", Scroll)
Toggle.Size = UDim2.new(1, 0, 0, 50)
Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Toggle.Text = "INICIAR TORNADO"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    _G.TornadoData.Enabled = not _G.TornadoData.Enabled
    Toggle.BackgroundColor3 = _G.TornadoData.Enabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 45)
    Toggle.Text = _G.TornadoData.Enabled and "TORNADO ACTIVO" or "INICIAR TORNADO"
end)

-- LÓGICA DE FÍSICA MEJORADA
RunService.Heartbeat:Connect(function()
    if not _G.TornadoData.Enabled then return end
    
    local character = LPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local currentCount = 0
    for _, part in pairs(workspace:GetDescendants()) do
        if currentCount >= _G.TornadoData.MaxParts then break end
        
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(character) then
            currentCount = currentCount + 1
            local pPos = part.Position
            local rPos = root.Position
            
            local dist = (Vector3.new(pPos.X, rPos.Y, pPos.Z) - rPos).Magnitude
            local angle = math.atan2(pPos.Z - rPos.Z, pPos.X - rPos.X)
            local newAngle = angle + math.rad(_G.TornadoData.Speed)
            
            local targetPos = Vector3.new(
                rPos.X + math.cos(newAngle) * math.min(_G.TornadoData.Radius, dist),
                rPos.Y + 5,
                rPos.Z + math.sin(newAngle) * math.min(_G.TornadoData.Radius, dist)
            )
            
            part.Velocity = (targetPos - pPos).Unit * _G.TornadoData.Strength
        end
    end
end)

print("Ender OS v16: Control de gestión de piezas activado.")
