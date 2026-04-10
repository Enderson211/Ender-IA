--[[
    ENDER OS V11 - INSANIDY EDITION
    - UI: Modern Dark / Neon Cyan
    - Security: Metatable Hooking (Anti-Detection)
    - Performance: No Lag Rendering
]]

-- 1. BYPASS DE SEGURIDAD (HOOKING)
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(t, k)
    if k == "WalkSpeed" or k == "JumpPower" then return 16 end
    return oldIndex(t, k)
end)
setreadonly(mt, true)

-- 2. VARIABLES DE ESTADO
local active = {God = false, Speed = 16, KillAura = false, Fly = false}

-- 3. INTERFAZ PROFESIONAL
local CoreGui = game:GetService("CoreGui")
local SG = Instance.new("ScreenGui", CoreGui)
SG.Name = "EnderOS_v11"

-- Botón de Minimizar (El Loguito)
local Logo = Instance.new("ImageButton", SG)
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 10, 0.5, -25)
Logo.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Logo.Image = "rbxassetid://6031068433" -- Icono de Ninja/Ender
local uicLogo = Instance.new("UICorner", Logo); uicLogo.CornerRadius = UDim.new(1, 0)

-- Contenedor Principal
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 280, 0, 380)
Main.Position = UDim2.new(0.5, -140, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.Visible = false
local uicMain = Instance.new("UICorner", Main); uicMain.CornerRadius = UDim.new(0, 12)

-- Barra de Título
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Header.BackgroundTransparency = 0.8
local uicHeader = Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.size(1, 0, 1, 0)
Title.Text = "ENDER OS V11 [INSANIDY]"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- CONTENEDOR DE BOTONES (Scrollable)
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Content.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", Content)
layout.Padding = UDim.new(0, 8)

-- FUNCIÓN PARA CREAR BOTONES MODERNOS
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = text
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local uic = Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
end

-- LOGICA DE MINIMIZADO
Logo.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- 4. FUNCIONES INSANAS
-- GOD MODE (Nivel Servidor)
CreateButton("GOD MODE: OFF", function(self)
    active.God = not active.God
    self.Text = active.God and "GOD MODE: ON" or "GOD MODE: OFF"
    self.TextColor3 = active.God and Color3.new(0, 1, 0) or Color3.new(0.8, 0.8, 0.8)
    
    game:GetService("RunService").Stepped:Connect(function()
        if active.God and game.Players.LocalPlayer.Character then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end
    end)
end)

-- SPEED BYPASS (Indetectable)
CreateButton("SPEED (60 FPS)", function(self)
    active.Speed = active.Speed == 16 and 100 or 16
    self.Text = "SPEED: " .. active.Speed
    game:GetService("RunService").RenderStepped:Connect(function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * (active.Speed / 100))
        end
    end)
end)

-- KILL AURA (Efecto BlueHammer pero automático)
CreateButton("AURA DESTRUCTORA", function(self)
    active.KillAura = not active.KillAura
    self.TextColor3 = active.KillAura and Color3.new(0, 1, 1) or Color3.new(0.8, 0.8, 0.8)
    
    task.spawn(function()
        while active.KillAura do
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored then
                    local dist = (part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 20 then
                        part.Velocity = Vector3.new(0, -500, 0)
                        part.CFrame = CFrame.new(0, -1000, 0)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- FLY (Modo Vuelo)
CreateButton("MODO FLY", function(self)
    active.Fly = not active.Fly
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    if active.Fly then
        bodyVel.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
        task.spawn(function()
            while active.Fly do
                bodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * 50
                task.wait()
            end
            bodyVel:Destroy()
        end)
    end
end)

print("Ender OS v11 Cargado. Pulsa el logo cian para abrir.")
