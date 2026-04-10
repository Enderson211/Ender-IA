--[[
    ENDER OS v17 - PRECISION MANAGEMENT
    - Controles Duales (+ / -) para Radio y Piezas.
    - Network Ownership Reforzado (Para que otros vean el efecto).
    - Optimización de Memoria.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- CONFIGURACIÓN DINÁMICA
_G.TornadoData = {
    Enabled = false,
    Radius = 30,
    MaxParts = 50,
    Speed = 2,
    Strength = 1800
}

-- [1] REFUERZO DE PROPIEDAD DE RED (NETWORK OWNERSHIP)
-- Esto es lo que hace que otros vean cómo las piezas se mueven.
if not getgenv().Network then
    getgenv().Network = {BaseParts = {}, Velocity = Vector3.new(14.47, 14.47, 14.47)}
    task.spawn(function()
        LPlayer.ReplicationFocus = workspace
        RunService.Heartbeat:Connect(function()
            -- Forzamos al motor a darnos el control de las piezas cercanas
            sethiddenproperty(LPlayer, "SimulationRadius", math.huge)
            for _, p in pairs(getgenv().Network.BaseParts) do
                if p:IsDescendantOf(workspace) and not p.Anchored then 
                    p.Velocity = getgenv().Network.Velocity 
                end
            end
        end)
    end)
end

-- [2] INTERFAZ PROFESIONAL V17
local SG = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 300, 0, 480)
Main.Position = UDim2.new(0.5, -150, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -80)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 12)

-- [3] FUNCIÓN DE GESTIÓN DUAL (SUBIR Y BAJAR)
local function AddDualControl(title, valueKey, step, minVal, maxVal)
    local container = Instance.new("Frame", Scroll)
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = title .. ": " .. _G.TornadoData[valueKey]
    label.TextColor3 = Color3.new(0, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    local downBtn = Instance.new("TextButton", container)
    downBtn.Size = UDim2.new(0.45, 0, 0, 35)
    downBtn.Position = UDim2.new(0, 0, 0, 30)
    downBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
    downBtn.Text = "- " .. step
    downBtn.TextColor3 = Color3.new(1, 0.5, 0.5)
    Instance.new("UICorner", downBtn)

    local upBtn = Instance.new("TextButton", container)
    upBtn.Size = UDim2.new(0.45, 0, 0, 35)
    upBtn.Position = UDim2.new(0.55, 0, 0, 30)
    upBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    upBtn.Text = "+ " .. step
    upBtn.TextColor3 = Color3.new(0.5, 1, 0.5)
    Instance.new("UICorner", upBtn)

    -- Lógica de los botones
    downBtn.MouseButton1Click:Connect(function()
        _G.TornadoData[valueKey] = math.max(minVal, _G.TornadoData[valueKey] - step)
        label.Text = title .. ": " .. _G.TornadoData[valueKey]
    end)

    upBtn.MouseButton1Click:Connect(function()
        _G.TornadoData[valueKey] = math.min(maxVal, _G.TornadoData[valueKey] + step)
        label.Text = title .. ": " .. _G.TornadoData[valueKey]
    end)
end

-- [4] AGREGAR CONTROLES PRECISOS
AddDualControl("RADIO DE GIRO", "Radius", 5, 5, 200)
AddDualControl("CANTIDAD DE PIEZAS", "MaxParts", 10, 10, 300)

-- BOTÓN DE ACTIVACIÓN
local Toggle = Instance.new("TextButton", Scroll)
Toggle.Size = UDim2.new(1, 0, 0, 50)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Toggle.Text = "ACTIVAR TORNADO"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    _G.TornadoData.Enabled = not _G.TornadoData.Enabled
    Toggle.BackgroundColor3 = _G.TornadoData.Enabled and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(45, 45, 50)
    Toggle.Text = _G.TornadoData.Enabled and "TORNADO ON" or "TORNADO OFF"
end)

-- [5] LÓGICA DE FÍSICA PARA REPLICACIÓN (TODO EL MUNDO VE)
RunService.Heartbeat:Connect(function()
    if not _G.TornadoData.Enabled then return end
    
    local root = LPlayer.Character and LPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local count = 0
    for _, part in pairs(workspace:GetDescendants()) do
        if count >= _G.TornadoData.MaxParts then break end
        
        -- Solo piezas que no estén fijas y no sean de nuestro personaje
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LPlayer.Character) then
            -- Intentamos tomar la propiedad de red para que los demás vean el movimiento
            if part.ReceiveAge == 0 then -- Solo si no la tenemos ya
                pcall(function() part:SetNetworkOwner(LPlayer) end)
            end

            count = count + 1
            local dist = (Vector3.new(part.Position.X, root.Position.Y, part.Position.Z) - root.Position).Magnitude
            local angle = math.atan2(part.Position.Z - root.Position.Z, part.Position.X - root.Position.X)
            local newAngle = angle + math.rad(_G.TornadoData.Speed)
            
            local targetPos = Vector3.new(
                root.Position.X + math.cos(newAngle) * math.min(_G.TornadoData.Radius, dist),
                root.Position.Y + 5,
                root.Position.Z + math.sin(newAngle) * math.min(_G.TornadoData.Radius, dist)
            )
            
            part.Velocity = (targetPos - part.Position).Unit * _G.TornadoData.Strength
        end
    end
end)
