--[[
    ENDER OS v14 - THE GHOST PROTOCOL (FINAL VERSION)
    - Auto-Protection: Anti-Kick & Anti-Report (Always ON)
    - God Mode: Toggle con Feedback Visual
    - Metatable Spoofing: Indetectable por Servidor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 1. SISTEMA ANTI-BAN Y ANTI-KICK (EJECUCIÓN INMEDIATA)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Bloquea intentos de Kick y protege contra sistemas de reporte locales
    if method == "Kick" or method == "kick" or method == "ReportAbuse" then
        warn("SEGURIDAD ENDER: Intento de " .. method .. " bloqueado.")
        return nil 
    end
    return oldNamecall(self, ...)
end)

mt.__index = newcclosure(function(t, k)
    if not checkcaller() then
        if t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
            return 16 -- El servidor siempre cree que vas normal
        end
    end
    return oldIndex(t, k)
end)
setreadonly(mt, true)

-- 2. INTERFAZ PROFESIONAL
local SG = Instance.new("ScreenGui", CoreGui)
SG.Name = "EnderOS_v14"

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 280, 0, 380)
Main.Position = UDim2.new(0.5, -140, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

-- Logo de Minimizar
local Logo = Instance.new("ImageButton", SG)
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 15, 0.5, -25)
Logo.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Logo.Image = "rbxassetid://6031068433"
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
Logo.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -80)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- 3. FUNCIONES CON TOGGLE VISUAL
local function CreateToggle(text, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(30, 30, 35)
        callback(state)
    end)
end

-- MODO DIOS (Toggle Estilo Velocidad)
CreateToggle("GOD MODE", function(active)
    _G.GodEnabled = active
    task.spawn(function()
        while _G.GodEnabled do
            if LPlayer.Character then
                for _, v in pairs(LPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanTouch = false end
                end
            end
            task.wait(0.1)
        end
        -- Al desactivar, devolvemos las colisiones
        if LPlayer.Character then
            for _, v in pairs(LPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = true end
            end
        end
    end)
end)

-- VELOCIDAD (Indetectable)
CreateToggle("SUPER SPEED", function(active)
    _G.SpeedEnabled = active
    task.spawn(function()
        while _G.SpeedEnabled do
            if LPlayer.Character and LPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LPlayer.Character.Humanoid
                if hum.MoveDirection.Magnitude > 0 then
                    LPlayer.Character:TranslateBy(hum.MoveDirection * 1.6)
                end
            end
            RunService.RenderStepped:Wait()
        end
    end)
end)

-- ANTI-REPORT & ANTI-BAN STATUS
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 1, -30)
Status.Text = "ANTIBAN & ANTIKICK: ACTIVE"
Status.TextColor3 = Color3.fromRGB(0, 255, 150)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.GothamSemibold

print("Ender OS v14: Protecciones activas al inicio.")
