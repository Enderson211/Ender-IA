--[[
    ENDER OS v15 - INSANIDY GHOST + TORNADO
    - Nueva Función: Super Ring Part (Tornado)
    - Optimización: Limitador de Piezas (Anti-Lag)
    - Estilo: Neón Cyan con Toggle de Radio
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- [1] NÚCLEO DE RED (Para controlar piezas ajenas)
if not getgenv().Network then
    getgenv().Network = {BaseParts = {}, Velocity = Vector3.new(14.46, 14.46, 14.46)}
    local function EnablePartControl()
        LPlayer.ReplicationFocus = workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(getgenv().Network.BaseParts) do
                if Part:IsDescendantOf(workspace) then Part.Velocity = getgenv().Network.Velocity end
            end
        end)
    end
    task.spawn(EnablePartControl)
end

-- [2] VARIABLES DEL TORNADO
local tornadoConfig = {
    Enabled = false,
    Radius = 20,
    MaxParts = 50, -- LIMITE PARA EVITAR LAG
    Speed = 2,
    Strength = 1500
}

-- [3] INTERFAZ ACTUALIZADA (v15)
local SG = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 280, 0, 420)
Main.Position = UDim2.new(0.5, -140, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -80)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- FUNCIÓN PARA BOTONES PRO
local function AddToggle(name, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 45)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(25, 25, 30)
        callback(active)
    end)
end

-- [4] INTEGRACIÓN DE FUNCIONES
AddToggle("GOD MODE", function(state)
    _G.God = state
    while _G.God do
        if LPlayer.Character then
            for _, v in pairs(LPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end
        task.wait(0.5)
    end
end)

AddToggle("TORNADO DE PIEZAS", function(state)
    tornadoConfig.Enabled = state
end)

-- Slider Simple para Radio
AddToggle("RADIO TORNADO (+20)", function()
    tornadoConfig.Radius = tornadoConfig.Radius + 20
    if tornadoConfig.Radius > 200 then tornadoConfig.Radius = 20 end
    print("Nuevo Radio: "..tornadoConfig.Radius)
end)

-- [5] LÓGICA DEL TORNADO OPTIMIZADA (ANTI-LAG)
RunService.Heartbeat:Connect(function()
    if not tornadoConfig.Enabled then return end
    
    local root = LPlayer.Character and LPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local count = 0
    for _, part in pairs(workspace:GetDescendants()) do
        if count >= tornadoConfig.MaxParts then break end -- AQUÍ DETENEMOS EL LAG
        
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LPlayer.Character) then
            count = count + 1
            local dist = (Vector3.new(part.Position.X, root.Position.Y, part.Position.Z) - root.Position).Magnitude
            local angle = math.atan2(part.Position.Z - root.Position.Z, part.Position.X - root.Position.X)
            local newAngle = angle + math.rad(tornadoConfig.Speed)
            
            local targetPos = Vector3.new(
                root.Position.X + math.cos(newAngle) * math.min(tornadoConfig.Radius, dist),
                root.Position.Y + 5, -- Elevación fija para que se vea como anillo
                root.Position.Z + math.sin(newAngle) * math.min(tornadoConfig.Radius, dist)
            )
            
            part.Velocity = (targetPos - part.Position).Unit * tornadoConfig.Strength
        end
    end
end)

print("Ender OS v15: Tornado de Piezas optimizado y cargado.")
