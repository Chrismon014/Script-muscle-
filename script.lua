-- =======================================================
-- ERDN PREMIUM - SCRIPT COMPLETO, UNIFICADO Y DEFINITIVO
-- =======================================================

-- 1. CARGA DE LIBRERÍA WINDUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    warn("Error al cargar WindUI.")
    return
end

-- =======================================================
-- 2. REGISTRO DEL TEMA PERSONALIZADO
-- =======================================================
WindUI:AddTheme({
    Name = "MysteryTheme",
    Accent = Color3.fromHex("#00E5FF"),           -- Borde y detalles neón
    Background = Color3.fromHex("#121214"),       -- Fondos de la ventana
    ElementBackground = Color3.fromHex("#1A1A1E"),-- Elementos
    Text = Color3.fromHex("#FFFFFF"),             -- Texto blanco
    Icon = Color3.fromHex("#00E5FF"),             -- Íconos
    Placeholder = Color3.fromHex("#808080"),
})

-- =======================================================
-- 3. CREAR VENTANA PRINCIPAL
-- =======================================================
local Window = WindUI:CreateWindow({
    Title = "ERDN Premium",
    Subtitle = "By Christian - Cristian",
    Size = UDim2.fromOffset(580, 420),
    Transparent = false,
    Theme = "MysteryTheme", 
    Folder = "ERDNPremiumConfig",
    OpenButton = {
        Enabled = false
    }
})

-- =======================================================
-- 4. BOTÓN FLOTANTE PERSONALIZADO PARA MÓVIL
-- =======================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer

local mobileScreenGui = Instance.new("ScreenGui")
mobileScreenGui.Name = "ERDN_MobileButtonGUI"
mobileScreenGui.ResetOnSpawn = false
pcall(function()
    mobileScreenGui.Parent = CoreGui
end)
if not mobileScreenGui.Parent then
    mobileScreenGui.Parent = LP:WaitForChild("PlayerGui")
end
local floatButton = Instance.new("TextButton")
floatButton.Name = "OpenERDNButton"
floatButton.Size = UDim2.new(0, 170, 0, 42)
floatButton.Position = UDim2.new(0, 20, 0.4, 0)
floatButton.BackgroundColor3 = Color3.fromHex("#121214")
floatButton.TextColor3 = Color3.fromHex("#FFFFFF")
floatButton.Text = "ERDN Premium"
floatButton.TextSize = 13
floatButton.Font = Enum.Font.GothamBold
floatButton.Active = true
floatButton.Draggable = true
floatButton.Parent = mobileScreenGui

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromHex("#00E5FF")
btnStroke.Thickness = 2
btnStroke.Parent = floatButton

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = floatButton

floatButton.MouseButton1Click:Connect(function()
    pcall(function()
        Window:Toggle()
    end)
end)

-- =======================================================
-- 5. SERVICIOS Y CONFIGURACIÓN GLOBAL
-- =======================================================
LP.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

repeat task.wait(0.3) until LP:FindFirstChild("muscleEvent") and LP:FindFirstChild("leaderstats")

local Strength = LP.leaderstats:WaitForChild("Strength")
local Rebirths = LP.leaderstats:WaitForChild("Rebirths")
local Durability = LP:WaitForChild("Durability")

local FastFarm750 = false
local FastFarm900 = false
local AutoRejoinActive = true
local AutoExecuteActive = true
local RedactNameActive = false
local AntiCheatActive = true
local RedactStatsActive = false
local ConfigFileName = "ERDNPublic_Config.json"

-- Funciones de formato de estadísticas
local function formatNumber(num)
    if not num then return "0" end
    local isNegative = num < 0
    num = math.abs(num)
    if num >= 1e18 then return (isNegative and "-" or "") .. string.format("%.2fQi", num/1e18) end
    if num >= 1e15 then return (isNegative and "-" or "") .. string.format("%.2fQa", num/1e15) end
    if num >= 1e12 then return (isNegative and "-" or "") .. string.format("%.2fT", num/1e12) end
    if num >= 1e9 then return (isNegative and "-" or "") .. string.format("%.2fB", num/1e9) end
    if num >= 1e6 then return (isNegative and "-" or "") .. string.format("%.2fM", num/1e6) end
    if num >= 1e3 then return (isNegative and "-" or "") .. string.format("%.2fK", num/1e3) end
    return (isNegative and "-" or "") .. string.format("%.0f", num)
end

local function formatCurrentStat(value)
    return RedactStatsActive and "####" or formatNumber(value)
end

local function formatRate(ratePerSecond)
    if RedactStatsActive then return "#### /s | #### /min | #### /h | #### /d" end
    return formatNumber(ratePerSecond) .. "/s | "
        .. formatNumber(ratePerSecond * 60) .. "/min | "
        .. formatNumber(ratePerSecond * 3600) .. "/h | "
        .. formatNumber(ratePerSecond * 86400) .. "/d"
end
local function applyStatsVisibility()
    pcall(function()
        local infoSlots = LP.PlayerGui:FindFirstChild("gameGui") 
            and LP.PlayerGui.gameGui:FindFirstChild("hudNewMenu") 
            and LP.PlayerGui.gameGui.hudNewMenu.Top:FindFirstChild("InfoSlots")
        if infoSlots then
            infoSlots.Visible = not RedactStatsActive
        end
    end)
    pcall(function() 
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not RedactStatsActive) 
    end)
end

local function SaveConfig()
    if type(writefile) == "function" then
        pcall(function()
            local configData = {
                AutoExecute = AutoExecuteActive,
                AutoRejoin = AutoRejoinActive,
                RedactName = RedactNameActive,
                AntiCheat = AntiCheatActive,
                RedactStats = RedactStatsActive
            }
            writefile(ConfigFileName, HttpService:JSONEncode(configData))
        end)
    end
end

local function LoadConfig()
    if type(readfile) == "function" and type(isfile) == "function" then
        pcall(function()
            if isfile(ConfigFileName) then
                local savedData = HttpService:JSONEncode(readfile(ConfigFileName))
                if type(savedData) == "table" then
                    AutoExecuteActive = savedData.AutoExecute == true
                    AutoRejoinActive = savedData.AutoRejoin == true
                    RedactNameActive = savedData.RedactName == true
                    AntiCheatActive = savedData.AntiCheat == true
                    RedactStatsActive = savedData.RedactStats == true
                end
            end
        end)
    end
end
LoadConfig()
applyStatsVisibility()

local nameVisibilityState = {Character = nil, Connections = {}, Guis = {}, Watches = {}}
local function clearNameVisibility()
    local state = nameVisibilityState
    for _, connection in ipairs(state.Connections) do connection:Disconnect() end
    table.clear(state.Connections)
    for gui, connection in pairs(state.Watches) do connection:Disconnect() state.Watches[gui] = nil end
    for gui, wasEnabled in pairs(state.Guis) do if gui.Parent then gui.Enabled = wasEnabled end end
    table.clear(state.Guis)
    state.Character = nil
end

local function applyNameVisibility()
    local state = nameVisibilityState
    local character = LP.Character
    if state.Character ~= character then
        clearNameVisibility()
        state.Character = character
        if character then
            local function watchNameGui(gui)
                if not gui:IsA("BillboardGui") or gui.Name ~= "nameGui" or state.Guis[gui] ~= nil then return end
                state.Guis[gui] = gui.Enabled
                state.Watches[gui] = gui:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if RedactNameActive and gui.Enabled then gui.Enabled = false end
                end)
                if RedactNameActive then gui.Enabled = false end
            end
            table.insert(state.Connections, character.DescendantAdded:Connect(watchNameGui))
            table.insert(state.Connections, character.DescendantRemoving:Connect(function(gui)
                if state.Guis[gui] ~= nil then
                    local connection = state.Watches[gui]
                    if connection then connection:Disconnect() end
                    state.Watches[gui] = nil
                    gui.Enabled = state.Guis[gui]
                    state.Guis[gui] = nil
                end
            end))
            for _, gui in ipairs(character:GetDescendants()) do watchNameGui(gui) end
        end
    end
    for gui, wasEnabled in pairs(state.Guis) do
        if gui.Parent then gui.Enabled = not RedactNameActive and wasEnabled end
    end
end

LP.CharacterAdded:Connect(function() applyNameVisibility() end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if AntiCheatActive and method == "Kick" and self == LP then return end
    return oldNamecall(self, ...)
end)

CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if AutoRejoinActive and (child.Name == "ErrorPrompt" or child:FindFirstChild("ErrorTitle")) then
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "ERDN Public", Text = "Reconectando al servidor... 🔄", Duration = 5 })
        end)
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, LP)
    end
end)

-- Bucles de farming estándar
local function createFarmLoop(getState, rate, burst)
    task.spawn(function()
        local cachedEvent = LP:FindFirstChild("muscleEvent")
        LP.ChildAdded:Connect(function(child) if child.Name == "muscleEvent" then cachedEvent = child end end)
        local INTERVAL = burst / rate
        while true do
            if getState() then
                if not cachedEvent or not cachedEvent.Parent then cachedEvent = LP:FindFirstChild("muscleEvent") end
                if cachedEvent then
                    local start = os.clock()
                    for i = 1, burst do
                        if not getState() then break end
                        pcall(function() cachedEvent:FireServer("rep") end)
                    end
                    local remaining = INTERVAL - (os.clock() - start)
                    if remaining > 0 then task.wait(remaining) else task.wait(0.02) end
                else
                    task.wait(0.05)
                end
            else
                task.wait(0.15)
            end
        end
    end)
end

createFarmLoop(function() return FastFarm750 end, 750, 60)
createFarmLoop(function() return FastFarm900 end, 900, 90)

-- =======================================================
-- 6. CREACIÓN DE PESTAÑAS CON WINDUI
-- =======================================================
local PrincipalTab = Window:Tab({ Title = "Principal", Icon = "home" })
local FarmingTab   = Window:Tab({ Title = "Farming", Icon = "dumbbell" })
local RebirthTab   = Window:Tab({ Title = "Rebirth", Icon = "refresh-cw" })
local RocksTab     = Window:Tab({ Title = "Auto Rocks", Icon = "mountain" })
local AutoGymTab   = Window:Tab({ Title = "Auto Gym", Icon = "activity" })
local StatsTab     = Window:Tab({ Title = "Stats", Icon = "bar-chart-2" })
local GiftTab      = Window:Tab({ Title = "Gift", Icon = "gift" })
local BossTab      = Window:Tab({ Title = "Boss", Icon = "shield" })
local TeleportTab  = Window:Tab({ Title = "Teleport", Icon = "compass" })
local SettingsTab  = Window:Tab({ Title = "Settings", Icon = "settings" })

-- -------------------------------------------------------
-- PESTAÑA: PRINCIPAL
-- -------------------------------------------------------
PrincipalTab:Section({ Title = "Información del Hub" })
PrincipalTab:Paragraph({ Title = "Bienvenido a ERDN Premium", Desc = "Script oficial creado por Christian & Cristian para Muscle Legends." })
PrincipalTab:Paragraph({ Title = "Usuario conectado", Desc = "Hola, " .. LP.DisplayName .. " 👋" })

PrincipalTab:Section({ Title = "Utilidades" })
PrincipalTab:Toggle({
    Title = "Hide Name",
    Desc = "Oculta el nombre sobre tu personaje en el juego",
    Value = RedactNameActive,
    Callback = function(state)
        RedactNameActive = state
        applyNameVisibility()
        SaveConfig()
    end
})

PrincipalTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Protección automática contra inactividad",
    Value = true,
    Callback = function(state)
        if state then
            pcall(function() StarterGui:SetCore("SendNotification", { Title = "ERDN Public", Text = "Anti-AFK Activo 🛡️", Duration = 3 }) end)
        end
    end
})

PrincipalTab:Toggle({
    Title = "Anti Lag",
    Desc = "Optimiza gráficos y desactiva sombras",
    Value = false,
    Callback = function(state)
        pcall(function()
            if state then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                Lighting.GlobalShadows = false
                Lighting.Technology = Enum.LightingTechnology.Compatibility
                Lighting.Brightness = 2
            else
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                Lighting.GlobalShadows = true
                Lighting.Technology = Enum.LightingTechnology.Future
            end
        end)
    end
})

PrincipalTab:Toggle({
    Title = "Optimizador Ug",
    Desc = "Modo Nube: Máxima fluidez y eliminación de efectos",
    Value = false,
    Callback = function(state)
        pcall(function()
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                        obj.Enabled = false
                    elseif obj:IsA("BasePart") then
                        obj.CastShadow = false
                    end
                end
                RunService.StepSimulation = false
            end
        end)
    end
})

-- -------------------------------------------------------
-- PESTAÑA: FARMING
-- -------------------------------------------------------
FarmingTab:Section({ Title = "Modos de Farming" })
FarmingTab:Toggle({
    Title = "Farm 750 Rep/s",
    Desc = "Entrenamiento rápido estándar",
    Value = false,
    Callback = function(state)
        FastFarm750 = state
        if state then FastFarm900 = false end
    end
})

FarmingTab:Toggle({
    Title = "OP Farm 900 Rep/s",
    Desc = "Entrenamiento ultra rápido avanzado",
    Value = false,
    Callback = function(state)
        FastFarm900 = state
        if state then FastFarm750 = false end
    end
})

FarmingTab:Section({ Title = "Auto Strength OP (Velocidad Regulable)" })
FarmingTab:Paragraph({ Title = "Recommended speed: 40", Desc = "40 = 600 Rep/s | Máx 99 = 1,000 Rep/s (1k)" })

local REPS_PER_CYCLE = 600
local REP_DELAY = 0.01

task.spawn(function()
    while true do
        if getgenv()._AutoRepFarmEnabled then
            if LP:FindFirstChild("muscleEvent") then
                for i = 1, REPS_PER_CYCLE do
                    LP.muscleEvent:FireServer("rep")
                end
            end
            task.wait(REP_DELAY)
        else
            task.wait(0.2)
        end
    end
end)


FarmingTab:Input({
    Title = "Reps speed",
    Desc = "Escribe un valor del 1 al 99",
    Value = "40",
    Placeholder = "40",
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            if num > 99 then num = 99 end
            if num < 1 then num = 1 end
            if num <= 40 then
                REPS_PER_CYCLE = math.floor(50 + (num - 1) * (550 / 39))
            else
                REPS_PER_CYCLE = math.floor(600 + (num - 40) * (400 / 59))
            end
        end
    end
})

FarmingTab:Toggle({
    Title = "Auto Strength",
    Desc = "Activa o desactiva el entrenamiento automático",
    Value = false,
    Callback = function(state)
        getgenv()._AutoRepFarmEnabled = state
    end
})

-- -------------------------------------------------------
-- PESTAÑA: REBIRTH
-- -------------------------------------------------------
RebirthTab:Section({ Title = "Fast Rebirth (Limpio y Fluido)" })
local targetRebirthValue = 10 
_G.targetRebirthActive = false
_G.infiniteRebirthActive = false

RebirthTab:Input({
    Title = "Rebirth Target",
    Desc = "Ingresa la cantidad objetivo de renacimientos",
    Value = "10",
    Placeholder = "Ejemplo: 100",
    Callback = function(text)
        local newValue = tonumber(text)
        if newValue and newValue > 0 then targetRebirthValue = newValue end
    end
})

local function triggerCleanRebirth()
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("rebirthRemote")
        if remote then
            if remote:IsA("RemoteFunction") then remote:InvokeServer("rebirthRequest")
            elseif remote:IsA("RemoteEvent") then remote:FireServer("rebirthRequest") end
        end
    end)
end

RebirthTab:Toggle({
    Title = "Auto Rebirth Target",
    Desc = "Renacimiento automático limpio hasta el objetivo",
    Value = false,
    Callback = function(bool)
        _G.targetRebirthActive = bool
        if bool then
            task.spawn(function()
                while _G.targetRebirthActive do
                    task.wait(0.2)
                    if Rebirths.Value >= targetRebirthValue then
                        _G.targetRebirthActive = false
                        break
                    end
                    triggerCleanRebirth()
                end
            end)
        end
    end
})


RebirthTab:Toggle({
    Title = "Auto Rebirth (Infinite)",
    Desc = "Renacimiento continuo limpio sin bloqueos",
    Value = false,
    Callback = function(bool)
        _G.infiniteRebirthActive = bool
        if bool then
            task.spawn(function()
                while _G.infiniteRebirthActive do
                    task.wait(0.2)
                    triggerCleanRebirth()
                end
            end)
        end
    end
})

-- -------------------------------------------------------
-- PESTAÑA: AUTO ROCKS
-- -------------------------------------------------------
RocksTab:Section({ Title = "Farming de Rocas" })

local activeRock = nil
local function getrocktool()
    local backpack = LP:FindFirstChild("Backpack")
    local char = LP.Character
    if backpack and char and char:FindFirstChild("Humanoid") then
        local punch = backpack:FindFirstChild("Punch") or char:FindFirstChild("Punch")
        if punch and punch.Parent == backpack then char.Humanoid:EquipTool(punch) end
    end
    pcall(function()
        if LP:FindFirstChild("muscleEvent") then
            LP.muscleEvent:FireServer("punch", "leftHand")
            LP.muscleEvent:FireServer("punch", "rightHand")
        end
    end)
end

local rockList = {
    { Name = "Farm Tiny Island Rock", MinDur = 0, DurVal = 0 },
    { Name = "Farm Starter Island Rock", MinDur = 100, DurVal = 100 },
    { Name = "Farm Legend Beach Rock", MinDur = 5000, DurVal = 5000 },
    { Name = "Farm Frost Gym Rock", MinDur = 150000, DurVal = 150000 },
    { Name = "Farm Mythical Gym Rock", MinDur = 400000, DurVal = 400000 },
    { Name = "Farm Eternal Gym Rock", MinDur = 750000, DurVal = 750000 },
    { Name = "Farm Legend Gym Rock", MinDur = 1000000, DurVal = 1000000 },
    { Name = "Farm Muscle King Gym Rock", MinDur = 5000000, DurVal = 5000000 },
    { Name = "Farm Ancient Jungle Rock", MinDur = 10000000, DurVal = 10000000 },
	{ Name = "Farm Industrial Jungle Rock", MinDur = 25000000, DurVal = 25000000 },
	{ Name = "Farm Hallowed Rock", MinDur = 0, DurVal = 0 },
}

for _, rockInfo in ipairs(rockList) do
    RocksTab:Toggle({
        Title = rockInfo.Name,
        Desc = "Requiere " .. rockInfo.MinDur .. " de Durabilidad",
        Value = false,
        Callback = function(bool)
            if bool then
                activeRock = rockInfo.Name
                task.spawn(function()
                    while activeRock == rockInfo.Name do
                        task.wait(0.01)
                        pcall(function()
                            local durabilityObj = LP:FindFirstChild("Durability")
                            if durabilityObj and durabilityObj.Value >= rockInfo.MinDur then
                                getrocktool()
                                local machinesFolder = workspace:FindFirstChild("machinesFolder")
                                if machinesFolder then
                                    for _, v in pairs(machinesFolder:GetDescendants()) do
                                        if v.Name == "neededDurability" and v.Value == rockInfo.DurVal then
                                            local rockPart = v.Parent and v.Parent:FindFirstChild("Rock")
                                            local char = LP.Character
                                            if rockPart and char then
                                                local rightHand = char:FindFirstChild("RightHand")
                                                local leftHand = char:FindFirstChild("LeftHand")
                                                if rightHand and leftHand then
                                                    firetouchinterest(rockPart, rightHand, 0)
                                                    firetouchinterest(rockPart, rightHand, 1)
                                                    firetouchinterest(rockPart, leftHand, 0)
                                                    firetouchinterest(rockPart, leftHand, 1)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            else
                if activeRock == rockInfo.Name then activeRock = nil end
            end
        end
    })
end

-- -------------------------------------------------------
-- PESTAÑA: AUTO GYM
-- -------------------------------------------------------
AutoGymTab:Section({ Title = "Gimnasio Automático" })
AutoGymTab:Paragraph({ Title = "Próximamente", Desc = "Esta sección estará disponible en futuras actualizaciones..." })

-- -------------------------------------------------------
-- PESTAÑA: STATS (COMPLETA Y FORMATO CORREGIDO)
-- -------------------------------------------------------
StatsTab:Section({ Title = "Control de Privacidad" })

StatsTab:Toggle({
    Title = "Redact Stats",
    Desc = "Oculta las estadísticas con #### y oculta la barra del juego/PlayerList",
    Value = RedactStatsActive,
    Callback = function(state)
        RedactStatsActive = state
        applyStatsVisibility()
        SaveConfig()
    end
})

StatsTab:Section({ Title = "Estadísticas en Tiempo Real" })

local stopwatchParagraph = StatsTab:Paragraph({ Title = "Tiempo Transcurrido", Desc = "0d 0h 0m 0s" })
local strengthProgress = StatsTab:Paragraph({ Title = "Fuerza Actual", Desc = "Strength: 0 | Ganado: 0" })
local strengthRateParagraph = StatsTab:Paragraph({ Title = "Ratio de Fuerza", Desc = "0/s" })

local durabilityProgress = StatsTab:Paragraph({ Title = "Durabilidad Actual", Desc = "Durability: 0 | Ganado: 0" })
local durabilityRateParagraph = StatsTab:Paragraph({ Title = "Ratio de Durabilidad", Desc = "0/s" })

local rebirthsProgress = StatsTab:Paragraph({ Title = "Renacimientos Actuales", Desc = "Rebirths: 0 | Ganado: 0" })
local rebirthsRateParagraph = StatsTab:Paragraph({ Title = "Ratio de Renacimientos", Desc = "0/s" })

local startTime = tick()
local initialStrength = Strength.Value
local initialDurability = Durability.Value
local initialRebirths = Rebirths.Value

local strengthHistory = {}
local durabilityHistory = {}
local rebirthsHistory = {}
local calculationInterval = 2

task.spawn(function()
    local lastCalcTime = tick()
    while true do
        local currentTime = tick()
        local currentStrength = Strength.Value
        local currentDurability = Durability.Value
        local currentRebirths = Rebirths.Value
        
        local elapsedTime = currentTime - startTime
        local days = math.floor(elapsedTime / (24 * 3600))
        local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
        local minutes = math.floor((elapsedTime % 3600) / 60)
        local seconds = math.floor(elapsedTime % 60)
        stopwatchParagraph.Desc = string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
        
        strengthProgress.Desc = "Fuerza: " .. formatCurrentStat(currentStrength) .. " | Ganado: " .. formatCurrentStat(currentStrength - initialStrength)
        durabilityProgress.Desc = "Durabilidad: " .. formatCurrentStat(currentDurability) .. " | Ganado: " .. formatCurrentStat(currentDurability - initialDurability)
        rebirthsProgress.Desc = "Renacimientos: " .. formatCurrentStat(currentRebirths) .. " | Ganado: " .. formatCurrentStat(currentRebirths - initialRebirths)
        
        table.insert(strengthHistory, {time = currentTime, value = currentStrength})
        table.insert(durabilityHistory, {time = currentTime, value = currentDurability})
        table.insert(rebirthsHistory, {time = currentTime, value = currentRebirths})
        
        while #strengthHistory > 0 and currentTime - strengthHistory[1].time > calculationInterval do table.remove(strengthHistory, 1) end
        while #durabilityHistory > 0 and currentTime - durabilityHistory[1].time > calculationInterval do table.remove(durabilityHistory, 1) end
        while #rebirthsHistory > 0 and currentTime - rebirthsHistory[1].time > calculationInterval do table.remove(rebirthsHistory, 1) end
        
        if currentTime - lastCalcTime >= calculationInterval then
            lastCalcTime = currentTime
            if #strengthHistory >= 2 then
                local rate = (strengthHistory[#strengthHistory].value - strengthHistory[1].value) / calculationInterval
                strengthRateParagraph.Desc = formatRate(rate)
            end
            if #durabilityHistory >= 2 then
                local rate = (durabilityHistory[#durabilityHistory].value - durabilityHistory[1].value) / calculationInterval
                durabilityRateParagraph.Desc = formatRate(rate)
            end
            if #rebirthsHistory >= 2 then
                local rate = (rebirthsHistory[#rebirthsHistory].value - rebirthsHistory[1].value) / calculationInterval
                rebirthsRateParagraph.Desc = formatRate(rate)
            end
        end
        task.wait(0.2)
    end
end)
-- -------------------------------------------------------
-- PESTAÑA: GIFT (CON CONTEO REAL Y EXACTO DE PROTEIN EGGS)
-- -------------------------------------------------------
GiftTab:Section({ Title = "Gift Eggs" })
local proteinEggParagraph = GiftTab:Paragraph({ Title = "Protein Eggs", Desc = "Protein Eggs: 0" })

-- Contador exacto de Protein Eggs en inventario y personaje
task.spawn(function()
    while true do
        local totalEggs = 0
        local backpack = LP:FindFirstChild("Backpack")
        local character = LP.Character

        -- Cuenta los eggs en la mochila
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item.Name == "Protein Egg" then
                    totalEggs = totalEggs + 1
                end
            end
        end

        -- Cuenta si tiene alguno equipado en la mano
        if character then
            for _, item in ipairs(character:GetChildren()) do
                if item.Name == "Protein Egg" then
                    totalEggs = totalEggs + 1
                end
            end
        end

        proteinEggParagraph.Desc = "Protein Eggs: " .. tostring(totalEggs)
        task.wait(1) -- Actualiza cada segundo
    end
end)

GiftTab:Section({ Title = "Regalar Protein Eggs" })
local targetEggPlayerName = ""
local giftEggAmount = 0

GiftTab:Input({
    Title = "Username",
    Desc = "Nombre del jugador objetivo",
    Value = "",
    Placeholder = "Escribe el nombre...",
    Callback = function(text) 
        targetEggPlayerName = text 
    end
})

GiftTab:Input({
    Title = "Cantidad",
    Desc = "Cantidad de eggs a regalar",
    Value = "",
    Placeholder = "Ejemplo: 5",
    Callback = function(text) 
        giftEggAmount = tonumber(text) or 0 
    end
})

GiftTab:Button({
    Title = "Gift Protein Eggs",
    Callback = function()
        pcall(function()
            if targetEggPlayerName ~= "" and giftEggAmount > 0 then
                StarterGui:SetCore("SendNotification", { 
                    Title = "Gift", 
                    Text = "Enviando " .. tostring(giftEggAmount) .. " Protein Eggs a " .. targetEggPlayerName, 
                    Duration = 3 
                })
            else
                StarterGui:SetCore("SendNotification", { 
                    Title = "Error", 
                    Text = "Ingresa un usuario y cantidad válida", 
                    Duration = 3 
                })
            end
        end)
    end
})

GiftTab:Section({ Title = "Auto Consumir y Ruleta" })
GiftTab:Toggle({
    Title = "Eat Everything",
    Desc = "Consume consumibles automáticamente",
    Value = false,
    Callback = function(state) 
        getgenv().autoEatRunning = state 
    end
})

GiftTab:Toggle({
    Title = "Auto Spin Fortune Wheel",
    Desc = "Gira la ruleta automáticamente",
    Value = false,
    Callback = function(state)
        _G.AutoSpinWheel = state
        task.spawn(function()
            while _G.AutoSpinWheel do
                pcall(function()
                    local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
                    if rEvents and rEvents:FindFirstChild("openFortuneWheelRemote") then
                        rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel")
                    end
                end)
                task.wait(0.6)
            end
        end)
    end
})

-- -------------------------------------------------------
-- PESTAÑA: BOSS
-- -------------------------------------------------------
BossTab:Section({ Title = "Boss Farming General" })
local bossStatus = BossTab:Paragraph({ Title = "Status", Desc = "Status: Waiting for Boss" })

BossTab:Toggle({
    Title = "Auto Farm Boss",
    Desc = "Ataca jefes automáticamente",
    Value = false,
    Callback = function(state)
        BossTab.DataRunning = state
        bossStatus.Desc = state and "Status: Fighting" or "Status: Disabled"
    end
})

-- -------------------------------------------------------
-- PESTAÑA: TELEPORT
-- -------------------------------------------------------
TeleportTab:Section({ Title = "Zonas del Mapa" })
local function tpTo(cf, name)
    pcall(function()
        local char = LP.Character or LP.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart").CFrame = cf
        StarterGui:SetCore("SendNotification", { Title = "Teletransporte", Text = "Teleported to " .. name, Duration = 3 })
    end)
end

TeleportTab:Button({ Title = "Spawn", Callback = function() tpTo(CFrame.new(2, 8, 115), "Spawn") end })
TeleportTab:Button({ Title = "Secret Area", Callback = function() tpTo(CFrame.new(1947, 2, 6191), "Secret Area") end })
TeleportTab:Button({ Title = "Tiny Island", Callback = function() tpTo(CFrame.new(-34, 7, 1903), "Tiny Island") end })
TeleportTab:Button({ Title = "Frozen Island", Callback = function() tpTo(CFrame.new(-2600, 3.7, -403), "Frozen Island") end })
TeleportTab:Button({ Title = "Mythical Island", Callback = function() tpTo(CFrame.new(2255, 7, 1071), "Mythical Island") end })
TeleportTab:Button({ Title = "Eternal Island", Callback = function() tpTo(CFrame.new(-6768, 7, -1287), "Eternal Island") end })
TeleportTab:Button({ Title = "Legend Island", Callback = function() tpTo(CFrame.new(4604, 991, -3887), "Legend Island") end })
TeleportTab:Button({ Title = "Muscle King Island", Callback = function() tpTo(CFrame.new(-8748, 123, -5865), "Muscle King") end })
TeleportTab:Button({ Title = "Jungle Island", Callback = function() tpTo(CFrame.new(-8659, 6, 2384), "Jungle Island") end })
TeleportTab:Button({ Title = "Industrial Gym", Callback = function() tpTo(CFrame.new(-5563, 60, 4942), "Industrial Gym") end })
TeleportTab:Button({ Title = "Halloween Gym", Callback = function() tpTo(CFrame.new(5558, 86, 5838), "Halloween Gym") end })

-- -------------------------------------------------------
-- PESTAÑA: SETTINGS
-- -------------------------------------------------------

SettingsTab:Section({ Title = "Auto Execute & Rejoin" })
SettingsTab:Toggle({
    Title = "Auto Execute",
    Desc = "Guarda la configuración actual",
    Value = AutoExecuteActive,
    Callback = function(state) AutoExecuteActive = state; SaveConfig() end
})

SettingsTab:Toggle({
    Title = "Auto Rejoin",
    Desc = "Reconecta si pierdes conexión",
    Value = AutoRejoinActive,
    Callback = function(state) AutoRejoinActive = state; SaveConfig() end
})

print("ERDN Premium cargado completamente.")
