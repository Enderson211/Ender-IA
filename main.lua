--[[
    ENDER OS v18 - FINAL MASTER
    - Sistema de Minimizado (Icono Flotante).
    - Gestión Dual (+/-) de Radio y Piezas.
    - Replicación FE (Network Ownership reforzado).
    - Anti-Lag System.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- CONFIGURACIÓN GLOBAL
_G.TornadoData = {
    Enabled = false,
    Radius = 35,
    MaxParts = 60,
    Speed = 2.5,
    Strength = 2000
}

-- [1] SISTEMA DE RED REFORZADO (Para que otros vean)
if not getgenv().Network then
    getgenv().Network = {BaseParts = {}, Velocity = Vector3.new(14.47, 14.47, 14.47)}
    task.spawn(function()
        LPlayer.ReplicationFocus = workspace
        while task.wait(2) do -- Escaneo de piezas nuevas para reclamar
            sethiddenproperty(LPlayer, "SimulationRadius", math.huge)
            for _, p in pairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(LPlayer.Character) then
                    if (p.Position - LPlayer.Character.HumanoidRootPart.Position).Magnitude < 150 then
                        pcall(function() p:SetNetworkOwner(LPlayer) end)
                    end
                end
            end
        end
    end)
end

-- [2] INTERFAZ CON MINIMIZADO
local SG = Instance.new("ScreenGui", CoreGui)
SG.Name = "EnderOS_v18"

-- BOTÓN FLOTANTE (LOGO)
local Logo = Instance.new("ImageButton", SG)
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 10, 0.5, -25)
Logo.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Logo.Image = "rbxassetid://6031068433" -- Icono de rayo
Logo.ZIndex = 10
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Logo).Thickness = 2

-- PANEL PRINCIPAL
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 300, 0, 480)
Main.Position = UDim2.new(0.5, -150, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Main.Visible = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(0, 255, 255)
Stroke.Thickness = 1.5

-- Título
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "ENDER OS v18"
Title.TextColor3 = Color3.new(0, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -70)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- Lógica Minimizar
Logo.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- [3] GESTIÓN DE VALORES (+/-)
local function AddManager(title, key, step, min, max)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(1, 0, 0, 75)
    f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 30)
    l.Text = title .. ": " .. _G.TornadoData[key]
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.GothamBold
    l.BackgroundTransparency = 1

    local minus = Instance.new("TextButton", f)
    minus.Size = UDim2.new(0.45, 0, 0, 35)
    minus.Position = UDim2.new(0, 0, 0, 35)
    minus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    minus.Text = "-" .. step
    minus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", minus)

    local plus = Instance.new("TextButton", f)
    plus.Size = UDim2.new(0.45, 0, 0, 35)
    plus.Position = UDim2.new(0.55, 0, 0, 35)
    plus.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    plus.Text = "+" .. step
    plus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", plus)

    minus.MouseButton1Click:Connect(function()
        _G.TornadoData[key] = math.max(min, _G.TornadoData[key] - step)
        l.Text = title .. ": " .. _G.TornadoData[key]
    end)
    plus.MouseButton1Click:Connect(function()
        _G.TornadoData[key] = math.min(max, _G.TornadoData[key] + step)
        l.Text = title .. ": " .. _G.TornadoData[key]
    end)
end

AddManager("RADIO TORNADO", "Radius", 5, 5, 150)
AddManager("LIMITE PIEZAS", "MaxParts", 15, 15, 300)

-- BOTÓN ACTIVACIÓN
local ActiveBtn = Instance.new("TextButton", Scroll)
ActiveBtn.Size = UDim2.new(1, 0, 0, 50)
ActiveBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ActiveBtn.Text = "INICIAR TORNADO"
ActiveBtn.TextColor3 = Color3.new(1,1,1)
ActiveBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ActiveBtn)

ActiveBtn.MouseButton1Click:Connect(function()
    _G.TornadoData.Enabled = not _G.TornadoData.Enabled
    ActiveBtn.BackgroundColor3 = _G.TornadoData.Enabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(30, 30, 35)
    ActiveBtn.Text = _G.TornadoData.Enabled and "MODO: DESTRUCTOR" or "INICIAR TORNADO"
end)

-- [4] LÓGICA DE FÍSICA PRO
RunService.Heartbeat:Connect(function()
    if not _G.TornadoData.Enabled then return end
    local root = LPlayer.Character and LPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local c = 0
    for _, p in pairs(workspace:GetDescendants()) do
        if c >= _G.TornadoData.MaxParts then break end
        if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(LPlayer.Character) then
            c = c + 1
            local dist = (Vector3.new(p.Position.X, root.Position.Y, p.Position.Z) - root.Position).Magnitude
            local angle = math.atan2(p.Position.Z - root.Position.Z, p.Position.X - root.Position.X)
            local newAngle = angle + math.rad(_G.TornadoData.Speed)
            local targetPos = Vector3.new(
                root.Position.X + math.cos(newAngle) * math.min(_G.TornadoData.Radius, dist),
                root.Position.Y + (math.sin(tick() * 2) * 2) + 5, -- Movimiento ondulante
                root.Position.Z + math.sin(newAngle) * math.min(_G.TornadoData.Radius, dist)
            )
            p.Velocity = (targetPos - p.Position).Unit * _G.TornadoData.Strength
        end
    end
end)
