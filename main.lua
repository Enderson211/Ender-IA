--[[
    ENDER OS - DEFINITIVE MASTER BUILD
    Arquitectura: Dynamic Referencing & FE Forcing
    Protección: Strict Metatable Hooking (Anti-Kick/Anti-Report)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LPlayer = Players.LocalPlayer

-- ==========================================
-- 1. SISTEMA CORE Y PROTECCIÓN (ANTI-CHEAT BYPASS)
-- ==========================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "Kick" or method == "kick" or method == "ReportAbuse" then
        return nil -- Intercepción silenciosa de comandos críticos
    end
    return oldNamecall(self, ...)
end)

mt.__index = newcclosure(function(t, k)
    if not checkcaller() then
        if t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
            return 16
        end
    end
    return oldIndex(t, k)
end)
setreadonly(mt, true)

-- ==========================================
-- 2. CONFIGURACIÓN GLOBAL ESTRICTA
-- ==========================================
local EnderConfig = {
    Tornado = {
        Active = false,
        Radius = 40,
        MaxParts = 80,
        Speed = 3,
        Strength = 3000
    },
    GodMode = false,
    SpeedHack = false
}

-- ==========================================
-- 3. NETWORK OWNERSHIP EXPLOIT (REPLICACIÓN FE)
-- ==========================================
-- Forzamos al servidor a darnos el control de las físicas cercanas
task.spawn(function()
    while task.wait(0.5) do
        local success, err = pcall(function()
            if EnderConfig.Tornado.Active then
                sethiddenproperty(LPlayer, "SimulationRadius", math.huge)
                sethiddenproperty(LPlayer, "MaxSimulationRadius", math.huge)
                LPlayer.ReplicationFocus = workspace
            end
        end)
    end
end)

-- ==========================================
-- 4. INTERFAZ GRÁFICA (GUI) INMORTAL
-- ==========================================
local targetGuiParent = (gethui and gethui()) or game:GetService("CoreGui")
if targetGuiParent:FindFirstChild("EnderOS_Definitive") then
    targetGuiParent.EnderOS_Definitive:Destroy()
end

local SG = Instance.new("ScreenGui", targetGuiParent)
SG.Name = "EnderOS_Definitive"
SG.ResetOnSpawn = false -- Crítico para evitar destrucción al morir

-- Logo Flotante (Minimizar)
local Logo = Instance.new("ImageButton", SG)
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 15, 0.5, -25)
Logo.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Logo.Image = "rbxassetid://6031068433"
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Logo).Thickness = 2

-- Marco Principal
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 320, 0, 500)
Main.Position = UDim2.new(0.5, -160, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 1.5

-- Título
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ENDER OS | MASTER BUILD"
Title.TextColor3 = Color3.new(0, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- Contenedor con Scroll
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 12)

-- Lógica de Arrastre (Drag)
local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Lógica de Minimizar
Logo.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ==========================================
-- 5. CONSTRUCTORES DE ELEMENTOS UI
-- ==========================================
local function CreateToggle(name, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = name
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

local function CreateDualManager(title, dict, key, step, min, max)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Text = title .. ": " .. dict[key]
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.BackgroundTransparency = 1

    local btnMinus = Instance.new("TextButton", frame)
    btnMinus.Size = UDim2.new(0.48, 0, 0, 35)
    btnMinus.Position = UDim2.new(0, 0, 0, 30)
    btnMinus.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    btnMinus.Text = "-" .. step
    btnMinus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnMinus)

    local btnPlus = Instance.new("TextButton", frame)
    btnPlus.Size = UDim2.new(0.48, 0, 0, 35)
    btnPlus.Position = UDim2.new(0.52, 0, 0, 30)
    btnPlus.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    btnPlus.Text = "+" .. step
    btnPlus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnPlus)

    btnMinus.MouseButton1Click:Connect(function()
        dict[key] = math.max(min, dict[key] - step)
        lbl.Text = title .. ": " .. dict[key]
    end)
    btnPlus.MouseButton1Click:Connect(function()
        dict[key] = math.min(max, dict[key] + step)
        lbl.Text = title .. ": " .. dict[key]
    end)
end

-- ==========================================
-- 6. INTEGRACIÓN DE MÓDULOS
-- ==========================================
CreateToggle("GOD MODE (COLLISION BYPASS)", function(state)
    EnderConfig.GodMode = state
end)

CreateToggle("SPEED HACK (C-FRAME ALGORITHM)", function(state)
    EnderConfig.SpeedHack = state
end)

CreateDualManager("RADIO TORNADO", EnderConfig.Tornado, "Radius", 10, 10, 300)
CreateDualManager("LIMITE PIEZAS", EnderConfig.Tornado, "MaxParts", 20, 20, 500)

CreateToggle("ACTIVAR TORNADO MAESTRO", function(state)
    EnderConfig.Tornado.Active = state
end)

-- ==========================================
-- 7. NÚCLEO DE FÍSICA Y RENDERIZADO (DYNAMIC)
-- ==========================================
RunService.Stepped:Connect(function()
    local character = LPlayer.Character
    if not character then return end
    
    -- GOD MODE LOGIC (Se aplica constantemente para evitar que el respawn lo rompa)
    if EnderConfig.GodMode then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanTouch then
                v.CanTouch = false
            end
        end
    else
        -- Restaurar colisiones si se desactiva
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") and not v.CanTouch then
                v.CanTouch = true
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local character = LPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- SPEED HACK LOGIC
    if EnderConfig.SpeedHack and humanoid and humanoid.MoveDirection.Magnitude > 0 then
        character:TranslateBy(humanoid.MoveDirection * 1.8)
    end
end)

RunService.Heartbeat:Connect(function()
    if not EnderConfig.Tornado.Active then return end
    
    local character = LPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local count = 0
    local rootPos = root.Position
    
    for _, part in pairs(workspace:GetDescendants()) do
        if count >= EnderConfig.Tornado.MaxParts then break end
        
        -- Validación estricta usando pcall para evitar errores si la pieza se destruye
        pcall(function()
            if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(character) then
                local partPos = part.Position
                local dist = (Vector3.new(partPos.X, rootPos.Y, partPos.Z) - rootPos).Magnitude
                
                -- Solo procesar piezas dentro de un rango lógico para evitar cálculos inútiles
                if dist < (EnderConfig.Tornado.Radius * 3) then
                    count = count + 1
                    
                    local angle = math.atan2(partPos.Z - rootPos.Z, partPos.X - rootPos.X)
                    local newAngle = angle + math.rad(EnderConfig.Tornado.Speed)
                    
                    local targetPos = Vector3.new(
                        rootPos.X + math.cos(newAngle) * math.min(EnderConfig.Tornado.Radius, dist),
                        rootPos.Y + 4,
                        rootPos.Z + math.sin(newAngle) * math.min(EnderConfig.Tornado.Radius, dist)
                    )
                    
                    -- Aplicación directa de fuerza y eliminación de gravedad local
                    part.Velocity = (targetPos - partPos).Unit * EnderConfig.Tornado.Strength
                    part.AssemblyLinearVelocity = (targetPos - partPos).Unit * EnderConfig.Tornado.Strength
                end
            end
        end)
    end
end)

print("ENDER OS MASTER LOADED. SUCCESS.")
