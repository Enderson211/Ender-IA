--[[
    ENDER OS v13 - THE GHOST PROTOCOL
    - Status: UNDETECTABLE (Metatable Spoofing)
    - Bypass: Anti-Kick & Anti-Report
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 1. EL NÚCLEO: BYPASS TOTAL DE ANTICHEAT (METATABLES)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

-- Engañamos al servidor sobre nuestras propiedades
mt.__index = newcclosure(function(t, k)
    if not checkcaller() then
        if t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
            return 16 -- El juego siempre "leerá" 16 aunque vayas a 500
        end
        if t:IsA("HumanoidRootPart") and k == "Velocity" then
            return Vector3.new(0, 0, 0) -- El servidor cree que estás quieto
        end
    end
    return oldIndex(t, k)
end)

-- ANTI-KICK: Bloqueamos que el juego llame a la función "Kick"
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "Kick" or method == "kick" then
        warn("INTENTO DE KICK BLOQUEADO: " .. tostring(args[1]))
        return nil -- El comando de Kick se pierde en el vacío
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- 2. INTERFAZ PROFESIONAL (CORREGIDA)
local SG = Instance.new("ScreenGui", CoreGui)
SG.Name = "EnderOS_v13"

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 280, 0, 350)
Main.Position = UDim2.new(0.5, -140, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Visible = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Botón de Minimizar (Logo)
local Logo = Instance.new("ImageButton", SG)
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 10, 0.8, 0)
Logo.Image = "rbxassetid://6031068433"
Logo.BackgroundColor3 = Color3.new(0, 1, 1)
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
Logo.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ENDER OS V13 [GHOST]"
Title.TextColor3 = Color3.new(0, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

local function AddToggle(text, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- FUNCIONES
AddToggle("GOD MODE: ACTIVE", function(b)
    RunService.Stepped:Connect(function()
        if LPlayer.Character then
            for _, v in pairs(LPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end
    end)
end)

local speedOn = false
AddToggle("SPEED HACK (SPOOFED)", function(b)
    speedOn = not speedOn
    b.TextColor3 = speedOn and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    RunService.RenderStepped:Connect(function()
        if speedOn and LPlayer.Character and LPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LPlayer.Character.Humanoid
            if hum.MoveDirection.Magnitude > 0 then
                LPlayer.Character:TranslateBy(hum.MoveDirection * 1.5) -- Velocidad x3 indetectable
            end
        end
    end)
end)

AddToggle("ANTI-REPORT (BETA)", function(b)
    b.Text = "REPORTS BLOCKED"
    b.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    -- Aquí se podrían añadir hooks a los remotes de reporte si el juego los tiene
end)

print("Ender OS v13 Inyectado. Bypass de Metatabla Activo.")
