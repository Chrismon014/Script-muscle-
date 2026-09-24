--[[
    NovaBlockStudio by @Christian_014
]]

local services = {
    players = game:GetService("Players"),
    replicatedstorage = game:GetService("ReplicatedStorage"),
    runservice = game:GetService("RunService"),
    tws = game:GetService("TweenService"),
    userinputservice = game:GetService("UserInputService"),
    httpservice = game:GetService("HttpService"),
    virtualuser = game:GetService("VirtualUser"),
    virtualinputmanager = game:GetService("VirtualInputManager"),
    lighting = game:GetService("Lighting"),
    startergui = game:GetService("StarterGui")
}

local lp = {
    player = services.players.LocalPlayer,
    userid = services.players.LocalPlayer.UserId,
    username = services.players.LocalPlayer.Name,
    displayname = services.players.LocalPlayer.DisplayName
}

lp.player.Idled:Connect(function()
    services.virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
    task.wait(0.05)
    services.virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
end)

function deleteAds()
    for _, portal in pairs(game:GetDescendants()) do
        if portal.Name == "RobloxForwardPortals" then
            portal:Destroy()
        end
    end
    if _G.ads then
        _G.ads:Disconnect()
    end

    _G.ads = game.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "RobloxForwardPortals" then
            descendant:Destroy()
        end
    end)
end
deleteAds()

function deleteBodyMovementScript()
    if lp.player.Character and lp.player.Character:FindFirstChild("bodyMovementScript") then
        lp.player.Character.bodyMovementScript:Destroy()
    end
end
deleteBodyMovementScript()

services.muscleEvent = lp.player:WaitForChild("muscleEvent")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Chrismon014/Script-muscle-/refs/heads/main/Library/eleriumv2.luau"))()
local silence = library:AddWindow("NovaBlockStudio | Fast Farming - Hello, " .. lp.displayname .. "!", {
    main_color = Color3.fromRGB(138, 0, 0),
    min_size = Vector2.new(500, 500),
    can_resize = false
})

local tabs = {
    rebirths = silence:AddTab("Rebirths"),
    strength = silence:AddTab("Strength (Fast)"),
    strength2 = silence:AddTab("Strength (Add)"),
    other = silence:AddTab("Other"),
    info = silence:AddTab("Info")
}

tabs.other:Show()

function formatNumber(num)
    if num >= 1e18 then return string.format("%.2fQi", num/1e18) end
    if num >= 1e15 then return string.format("%.2fQa", num/1e15) end
    if num >= 1e12 then return string.format("%.2fT", num/1e12) end
    if num >= 1e9 then return string.format("%.2fB", num/1e9) end
    if num >= 1e6 then return string.format("%.2fM", num/1e6) end
    if num >= 1e3 then return string.format("%.2fK", num/1e3) end
    return string.format("%.0f", num)
end

-- Rebirth Tab

tabs.rebirths.leaderstats = lp.player:WaitForChild("leaderstats")
tabs.rebirths.rebirths = tabs.rebirths.leaderstats:WaitForChild("Rebirths")
tabs.rebirths.strength = tabs.rebirths.leaderstats:WaitForChild("Strength")
tabs.rebirths.running = false
tabs.rebirths.workerActive = false
tabs.rebirths.startedAt = 0
tabs.rebirths.timerStarted = false
tabs.rebirths.hasStarted = false
tabs.rebirths.totalElapsed = 0
tabs.rebirths.startRebirths = tabs.rebirths.rebirths.Value
tabs.rebirths.gainedBaselineSet = false
tabs.rebirths.lastRebirthAt = tick()
tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
tabs.rebirths.paceBaselineReady = false
tabs.rebirths.petFolders = {}
tabs.rebirths.pets = {}
tabs.rebirths.uniquePets = {}
tabs.rebirths.omegas = {}
tabs.rebirths.swifts = {}
tabs.rebirths.hounds = {}
tabs.rebirths.hydras = {}
tabs.rebirths.tribals = {}
tabs.rebirths.folderIndex = 1
tabs.rebirths.petIndex = 1
tabs.rebirths.repIndex = 1
tabs.rebirths.equippedCount = 0
tabs.rebirths.currentPercent = 0
tabs.rebirths.maxSlots = 12
tabs.rebirths.strengthTarget = 0
tabs.rebirths.repsPerBurst = 12
tabs.rebirths.rebirthValueBefore = tabs.rebirths.rebirths.Value
tabs.rebirths.Status = tabs.rebirths:AddLabel("Status: Inactive")
tabs.rebirths.Runtime = tabs.rebirths:AddLabel("Runtime: 0d 0h 0m 0s")
tabs.rebirths.RebirthStats = tabs.rebirths:AddLabel("Rebirths: " .. formatNumber(tabs.rebirths.rebirths.Value) .. " | Gained: 0")
tabs.rebirths.Pace = tabs.rebirths:AddLabel("Pace: -- / Hour | -- / Day | -- / Week")
tabs.rebirths.AveragePace = tabs.rebirths:AddLabel("Average: -- / Hour | -- / Day | -- / Week")
tabs.rebirths.Status.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.rebirths.updateStats = function()
    tabs.rebirths.RebirthStats.Text = "Rebirths: " .. formatNumber(tabs.rebirths.rebirths.Value)
        .. " | Gained: " .. formatNumber(tabs.rebirths.rebirths.Value - tabs.rebirths.startRebirths)
end

tabs.rebirths.updateRuntime = function()
    tabs.rebirths.elapsed = tabs.rebirths.totalElapsed
    if tabs.rebirths.running and tabs.rebirths.timerStarted then
        tabs.rebirths.elapsed = tabs.rebirths.elapsed + tick() - tabs.rebirths.startedAt
    end

    tabs.rebirths.Runtime.Text = string.format(
        "Runtime: %dd %dh %dm %ds",
        math.floor(tabs.rebirths.elapsed / 86400),
        math.floor((tabs.rebirths.elapsed % 86400) / 3600),
        math.floor((tabs.rebirths.elapsed % 3600) / 60),
        math.floor(tabs.rebirths.elapsed % 60)
    )
end

tabs.rebirths.updatePace = function()
    if not tabs.rebirths.running then return end

    if not tabs.rebirths.paceBaselineReady then
        tabs.rebirths.paceBaselineReady = true
        tabs.rebirths.timerStarted = true
        tabs.rebirths.startedAt = tick()
        tabs.rebirths.lastRebirthAt = tick()
        tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
        tabs.rebirths.averageStartedAt = tick()
        tabs.rebirths.averageStartRebirths = tabs.rebirths.rebirths.Value
        return
    end

    if tabs.rebirths.rebirths.Value <= tabs.rebirths.lastRebirthValue then return end

    tabs.rebirths.rebirthGain = tabs.rebirths.rebirths.Value - tabs.rebirths.lastRebirthValue
    tabs.rebirths.secondsPerRebirth = (tick() - tabs.rebirths.lastRebirthAt) / tabs.rebirths.rebirthGain
    tabs.rebirths.hourlyPace = 3600 / tabs.rebirths.secondsPerRebirth
    tabs.rebirths.dailyPace = 86400 / tabs.rebirths.secondsPerRebirth
    tabs.rebirths.weeklyPace = 604800 / tabs.rebirths.secondsPerRebirth

    tabs.rebirths.Pace.Text = string.format(
        "Pace: %s / Hour | %s / Day | %s / Week",
        formatNumber(tabs.rebirths.hourlyPace),
        formatNumber(tabs.rebirths.dailyPace),
        formatNumber(tabs.rebirths.weeklyPace)
    )

    tabs.rebirths.averageElapsed = tick() - tabs.rebirths.averageStartedAt
    tabs.rebirths.averageHourlyPace = (tabs.rebirths.rebirths.Value - tabs.rebirths.averageStartRebirths)
        / tabs.rebirths.averageElapsed * 3600

    tabs.rebirths.AveragePace.Text = string.format(
        "Average: %s / Hour | %s / Day | %s / Week",
        formatNumber(tabs.rebirths.averageHourlyPace),
        formatNumber(tabs.rebirths.averageHourlyPace * 24),
        formatNumber(tabs.rebirths.averageHourlyPace * 168)
    )

    tabs.rebirths.lastRebirthAt = tick()
    tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
end

tabs.rebirths.unequipAllPets = function()
    tabs.rebirths.petFolders = lp.player.petsFolder:GetChildren()
    tabs.rebirths.folderIndex = 1
    while tabs.rebirths.folderIndex <= #tabs.rebirths.petFolders do
        tabs.rebirths.petFolder = tabs.rebirths.petFolders[tabs.rebirths.folderIndex]
        if tabs.rebirths.petFolder:IsA("Folder") then
            tabs.rebirths.pets = tabs.rebirths.petFolder:GetChildren()
            tabs.rebirths.petIndex = 1
            while tabs.rebirths.petIndex <= #tabs.rebirths.pets do
                tabs.rebirths.pet = tabs.rebirths.pets[tabs.rebirths.petIndex]
                services.replicatedstorage.rEvents.equipPetEvent:FireServer("unequipPet", tabs.rebirths.pet)
                tabs.rebirths.petIndex = tabs.rebirths.petIndex + 1
            end
        end
        tabs.rebirths.folderIndex = tabs.rebirths.folderIndex + 1
    end
    task.wait(0.1)
end

tabs.rebirths.equipFarmingPets = function()
    tabs.rebirths.unequipAllPets()

    tabs.rebirths.omegas = {}
    tabs.rebirths.swifts = {}
    tabs.rebirths.hounds = {}
    tabs.rebirths.uniquePets = lp.player.petsFolder.Unique:GetChildren()
    tabs.rebirths.petIndex = 1

    while tabs.rebirths.petIndex <= #tabs.rebirths.uniquePets do
        tabs.rebirths.pet = tabs.rebirths.uniquePets[tabs.rebirths.petIndex]
        if tabs.rebirths.pet.Name == "Omega Overlord" then
            table.insert(tabs.rebirths.omegas, tabs.rebirths.pet)
        elseif tabs.rebirths.pet.Name == "Swift Samurai" then
            table.insert(tabs.rebirths.swifts, tabs.rebirths.pet)
        elseif tabs.rebirths.pet.Name == "Powercore Hound" then
            table.insert(tabs.rebirths.hounds, tabs.rebirths.pet)
        end
        tabs.rebirths.petIndex = tabs.rebirths.petIndex + 1
    end

    tabs.rebirths.equippedCount = 0
    tabs.rebirths.currentPercent = 0

    tabs.rebirths.petIndex = #tabs.rebirths.omegas
    while tabs.rebirths.petIndex >= 1 do
        if tabs.rebirths.equippedCount < tabs.rebirths.maxSlots and tabs.rebirths.currentPercent < 100 then
            tabs.rebirths.pet = table.remove(tabs.rebirths.omegas, tabs.rebirths.petIndex)
            services.replicatedstorage.rEvents.equipPetEvent:FireServer("equipPet", tabs.rebirths.pet)
            tabs.rebirths.currentPercent = tabs.rebirths.currentPercent + 20
            tabs.rebirths.equippedCount = tabs.rebirths.equippedCount + 1
        end
        tabs.rebirths.petIndex = tabs.rebirths.petIndex - 1
    end

    tabs.rebirths.petIndex = #tabs.rebirths.swifts
    while tabs.rebirths.petIndex >= 1 do
        if tabs.rebirths.equippedCount < tabs.rebirths.maxSlots and tabs.rebirths.currentPercent < 100 then
            tabs.rebirths.pet = table.remove(tabs.rebirths.swifts, tabs.rebirths.petIndex)
            services.replicatedstorage.rEvents.equipPetEvent:FireServer("equipPet", tabs.rebirths.pet)
            tabs.rebirths.currentPercent = tabs.rebirths.currentPercent + 15
            tabs.rebirths.equippedCount = tabs.rebirths.equippedCount + 1
        end
        tabs.rebirths.petIndex = tabs.rebirths.petIndex - 1
    end

    if tabs.rebirths.currentPercent >= 100 then
        tabs.rebirths.petIndex = #tabs.rebirths.hounds
        while tabs.rebirths.petIndex >= 1 do
            if tabs.rebirths.equippedCount < tabs.rebirths.maxSlots then
                tabs.rebirths.pet = table.remove(tabs.rebirths.hounds, tabs.rebirths.petIndex)
                services.replicatedstorage.rEvents.equipPetEvent:FireServer("equipPet", tabs.rebirths.pet)
                tabs.rebirths.equippedCount = tabs.rebirths.equippedCount + 1
            end
            tabs.rebirths.petIndex = tabs.rebirths.petIndex - 1
        end
    end
end

tabs.rebirths.equipRebirthPets = function()
    tabs.rebirths.unequipAllPets()

    tabs.rebirths.hydras = {}
    tabs.rebirths.tribals = {}
    tabs.rebirths.uniquePets = lp.player.petsFolder.Unique:GetChildren()
    tabs.rebirths.petIndex = 1

    while tabs.rebirths.petIndex <= #tabs.rebirths.uniquePets do
        tabs.rebirths.pet = tabs.rebirths.uniquePets[tabs.rebirths.petIndex]
        if tabs.rebirths.pet.Name == "Titanium Hydra" then
            table.insert(tabs.rebirths.hydras, tabs.rebirths.pet)
        elseif tabs.rebirths.pet.Name == "Tribal Overlord" then
            table.insert(tabs.rebirths.tribals, tabs.rebirths.pet)
        end
        tabs.rebirths.petIndex = tabs.rebirths.petIndex + 1
    end

    tabs.rebirths.equippedCount = 0

    tabs.rebirths.petIndex = 1
    while tabs.rebirths.petIndex <= #tabs.rebirths.hydras do
        if tabs.rebirths.equippedCount < tabs.rebirths.maxSlots then
            tabs.rebirths.pet = tabs.rebirths.hydras[tabs.rebirths.petIndex]
            services.replicatedstorage.rEvents.equipPetEvent:FireServer("equipPet", tabs.rebirths.pet)
            tabs.rebirths.equippedCount = tabs.rebirths.equippedCount + 1
        end
        tabs.rebirths.petIndex = tabs.rebirths.petIndex + 1
    end

    tabs.rebirths.petIndex = 1
    while tabs.rebirths.petIndex <= #tabs.rebirths.tribals do
        if tabs.rebirths.equippedCount < tabs.rebirths.maxSlots then
            tabs.rebirths.pet = tabs.rebirths.tribals[tabs.rebirths.petIndex]
            services.replicatedstorage.rEvents.equipPetEvent:FireServer("equipPet", tabs.rebirths.pet)
            tabs.rebirths.equippedCount = tabs.rebirths.equippedCount + 1
        end
        tabs.rebirths.petIndex = tabs.rebirths.petIndex + 1
    end
end

tabs.rebirths.performRebirth = function()
    tabs.rebirths.strengthTarget = 5000 + tabs.rebirths.rebirths.Value * 2550
    tabs.rebirths.repsPerBurst = lp.player.MembershipType == Enum.MembershipType.Premium and 6 or 12

    tabs.rebirths.repIndex = 1
    while tabs.rebirths.running and tabs.rebirths.strength.Value < tabs.rebirths.strengthTarget do
        tabs.rebirths.repIndex = 1
        while tabs.rebirths.repIndex <= tabs.rebirths.repsPerBurst do
            services.muscleEvent:FireServer("rep")
            tabs.rebirths.repIndex = tabs.rebirths.repIndex + 1
        end
        task.wait(0.02)
    end

    if tabs.rebirths.running and tabs.rebirths.strength.Value >= tabs.rebirths.strengthTarget then
        tabs.rebirths.equipRebirthPets()
        task.wait(0.25)
        tabs.rebirths.rebirthValueBefore = tabs.rebirths.rebirths.Value

        repeat
            services.replicatedstorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            task.wait(0.05)
        until tabs.rebirths.rebirths.Value > tabs.rebirths.rebirthValueBefore or not tabs.rebirths.running
    end
end

tabs.rebirths.startWorker = function()
    if tabs.rebirths.workerActive then return end

    tabs.rebirths.workerActive = true
    task.spawn(function()
        while tabs.rebirths.running do
            tabs.rebirths.equipFarmingPets()
            tabs.rebirths.performRebirth()
            task.wait(0.5)
        end
        tabs.rebirths.workerActive = false
    end)
end

tabs.rebirths.rebirths:GetPropertyChangedSignal("Value"):Connect(function()
    tabs.rebirths.updatePace()
    tabs.rebirths.updateStats()
end)

tabs.rebirths:AddSwitch("Fast Rebirth", function(state)
    tabs.rebirths.running = state
    if state then
        tabs.rebirths.hasStarted = true
        tabs.rebirths.startedAt = 0
        tabs.rebirths.timerStarted = false
        if not tabs.rebirths.gainedBaselineSet then
            tabs.rebirths.startRebirths = tabs.rebirths.rebirths.Value
            tabs.rebirths.gainedBaselineSet = true
        end
        tabs.rebirths.lastRebirthAt = tick()
        tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
        tabs.rebirths.paceBaselineReady = false
        tabs.rebirths.Status.Text = "Status: Rebirthing"
        tabs.rebirths.Status.TextColor3 = Color3.fromRGB(80, 255, 120)
        tabs.rebirths.updateStats()
        tabs.rebirths.startWorker()
    else
        if tabs.rebirths.timerStarted and tabs.rebirths.startedAt > 0 then
            tabs.rebirths.totalElapsed = tabs.rebirths.totalElapsed + tick() - tabs.rebirths.startedAt
            tabs.rebirths.startedAt = 0
            tabs.rebirths.timerStarted = false
        end
        tabs.rebirths.Status.Text = tabs.rebirths.hasStarted and "Status: Paused" or "Status: Inactive"
        tabs.rebirths.Status.TextColor3 = tabs.rebirths.hasStarted and Color3.fromRGB(255, 180, 70) or Color3.fromRGB(255, 80, 80)
        tabs.rebirths.updateRuntime()
    end
end):Set(false)

task.spawn(function()
    while true do
        tabs.rebirths.updateRuntime()
        task.wait(1)
    end
end)

-- Strength Tab

tabs.strength.leaderstats = lp.player:WaitForChild("leaderstats")
tabs.strength.strength = tabs.strength.leaderstats:WaitForChild("Strength")
tabs.strength.durability = lp.player:WaitForChild("Durability")
tabs.strength.running = false
tabs.strength.workerActive = false
tabs.strength.startedAt = 0
tabs.strength.totalElapsed = 0
tabs.strength.timerStarted = false
tabs.strength.gainedBaselineSet = false
tabs.strength.startStrength = tabs.strength.strength.Value
tabs.strength.startDurability = tabs.strength.durability.Value
tabs.strength.lastSampleAt = tick()
tabs.strength.lastStrength = tabs.strength.strength.Value
tabs.strength.lastDurability = tabs.strength.durability.Value
tabs.strength.paceBaselineReady = false
tabs.strength.calculationInterval = 10
tabs.strength.lastCalculationAt = tick()
tabs.strength.lastCalculatedStrength = tabs.strength.strength.Value
tabs.strength.lastCalculatedDurability = tabs.strength.durability.Value
tabs.strength.initialSendRate = 200
tabs.strength.maxSendRate = 1200
tabs.strength.sendRate = tabs.strength.initialSendRate
tabs.strength.sendTokens = 0
tabs.strength.maxBurst = 24
tabs.strength.controlInterval = 0.5
tabs.strength.lastControlAt = tick()
tabs.strength.lastProgressAt = tick()
tabs.strength.lastControlStrength = tabs.strength.strength.Value
tabs.strength.lastControlDurability = tabs.strength.durability.Value
tabs.strength.stalledIntervals = 0
tabs.strength.lastLoopAt = os.clock()
tabs.strength.repIndex = 1
tabs.strength.Status = tabs.strength:AddLabel("Status: Inactive")
tabs.strength.Runtime = tabs.strength:AddLabel("Runtime: 0d 0h 0m 0s")
tabs.strength.StrengthStats = tabs.strength:AddLabel("Strength: " .. formatNumber(tabs.strength.strength.Value) .. " | Gained: 0")
tabs.strength.DurabilityStats = tabs.strength:AddLabel("Durability: " .. formatNumber(tabs.strength.durability.Value) .. " | Gained: 0")
tabs.strength.StrengthPace = tabs.strength:AddLabel("Strength Pace: -- / Hour | -- / Day")
tabs.strength.DurabilityPace = tabs.strength:AddLabel("Durability Pace: -- / Hour | -- / Day")
tabs.strength.StrengthAverage = tabs.strength:AddLabel("Strength Average: -- / Hour | -- / Day")
tabs.strength.DurabilityAverage = tabs.strength:AddLabel("Durability Average: -- / Hour | -- / Day")
tabs.strength.Status.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.strength.updateRuntime = function()
    tabs.strength.elapsed = tabs.strength.totalElapsed
    if tabs.strength.running and tabs.strength.timerStarted then
        tabs.strength.elapsed = tabs.strength.elapsed + tick() - tabs.strength.startedAt
    end

    tabs.strength.Runtime.Text = string.format(
        "Runtime: %dd %dh %dm %ds",
        math.floor(tabs.strength.elapsed / 86400),
        math.floor((tabs.strength.elapsed % 86400) / 3600),
        math.floor((tabs.strength.elapsed % 3600) / 60),
        math.floor(tabs.strength.elapsed % 60)
    )
end

tabs.strength.updateStats = function()
    tabs.strength.StrengthStats.Text = "Strength: " .. formatNumber(tabs.strength.strength.Value)
        .. " | Gained: " .. formatNumber(tabs.strength.strength.Value - tabs.strength.startStrength)
    tabs.strength.DurabilityStats.Text = "Durability: " .. formatNumber(tabs.strength.durability.Value)
        .. " | Gained: " .. formatNumber(tabs.strength.durability.Value - tabs.strength.startDurability)
end

tabs.strength.calculatePace = function()
    if not tabs.strength.running or not tabs.strength.timerStarted then return end
    if tick() - tabs.strength.lastCalculationAt < tabs.strength.calculationInterval then return end

    tabs.strength.calculationElapsed = tick() - tabs.strength.lastCalculationAt
    tabs.strength.strengthDelta = tabs.strength.strength.Value - tabs.strength.lastCalculatedStrength
    tabs.strength.durabilityDelta = tabs.strength.durability.Value - tabs.strength.lastCalculatedDurability
    tabs.strength.strengthHourlyPace = tabs.strength.strengthDelta / tabs.strength.calculationElapsed * 3600
    tabs.strength.durabilityHourlyPace = tabs.strength.durabilityDelta / tabs.strength.calculationElapsed * 3600

    if tabs.strength.strengthDelta > 0 then
        tabs.strength.StrengthPace.Text = "Strength Pace: " .. formatNumber(tabs.strength.strengthHourlyPace)
            .. " / Hour | " .. formatNumber(tabs.strength.strengthHourlyPace * 24) .. " / Day"
    end
    if tabs.strength.durabilityDelta > 0 then
        tabs.strength.DurabilityPace.Text = "Durability Pace: " .. formatNumber(tabs.strength.durabilityHourlyPace)
            .. " / Hour | " .. formatNumber(tabs.strength.durabilityHourlyPace * 24) .. " / Day"
    end

    tabs.strength.averageElapsed = tabs.strength.totalElapsed + tick() - tabs.strength.startedAt
    tabs.strength.averageStrengthHourly = (tabs.strength.strength.Value - tabs.strength.startStrength)
        / tabs.strength.averageElapsed * 3600
    tabs.strength.averageDurabilityHourly = (tabs.strength.durability.Value - tabs.strength.startDurability)
        / tabs.strength.averageElapsed * 3600
    tabs.strength.StrengthAverage.Text = "Strength Average: " .. formatNumber(tabs.strength.averageStrengthHourly)
        .. " / Hour | " .. formatNumber(tabs.strength.averageStrengthHourly * 24) .. " / Day"
    tabs.strength.DurabilityAverage.Text = "Durability Average: " .. formatNumber(tabs.strength.averageDurabilityHourly)
        .. " / Hour | " .. formatNumber(tabs.strength.averageDurabilityHourly * 24) .. " / Day"

    tabs.strength.lastCalculationAt = tick()
    tabs.strength.lastCalculatedStrength = tabs.strength.strength.Value
    tabs.strength.lastCalculatedDurability = tabs.strength.durability.Value
end

-- Strength2 Tab

tabs.strength2.leaderstats = lp.player:WaitForChild("leaderstats")
tabs.strength2.strength = tabs.strength2.leaderstats:WaitForChild("Strength")
tabs.strength2.durability = lp.player:WaitForChild("Durability")
tabs.strength2.running = false
tabs.strength2.workerActive = false
tabs.strength2.startedAt = 0
tabs.strength2.totalElapsed = 0
tabs.strength2.timerStarted = false
tabs.strength2.gainedBaselineSet = false
tabs.strength2.startStrength = tabs.strength2.strength.Value
tabs.strength2.startDurability = tabs.strength2.durability.Value
tabs.strength2.repSpeed = 20
tabs.strength2.pingControl = true

tabs.strength2.Status = tabs.strength2:AddLabel("Status: Inactive")
tabs.strength2.Runtime = tabs.strength2:AddLabel("Runtime: 0d 0h 0m 0s")
tabs.strength2.StrengthStats = tabs.strength2:AddLabel("Strength: " .. formatNumber(tabs.strength2.strength.Value) .. " | Gained: 0")
tabs.strength2.DurabilityStats = tabs.strength2:AddLabel("Durability: " .. formatNumber(tabs.strength2.durability.Value) .. " | Gained: 0")
tabs.strength2.StrengthPace = tabs.strength2:AddLabel("Strength Pace: -- / Hour | -- / Day")
tabs.strength2.DurabilityPace = tabs.strength2:AddLabel("Durability Pace: -- / Hour | -- / Day")
tabs.strength2.StrengthAverage = tabs.strength2:AddLabel("Strength Average: -- / Hour | -- / Day")
tabs.strength2.DurabilityAverage = tabs.strength2:AddLabel("Durability Average: -- / Hour | -- / Day")

tabs.strength2.updateRuntime = function()
    tabs.strength2.elapsed = tabs.strength2.totalElapsed
    if tabs.strength2.running and tabs.strength2.timerStarted then
        tabs.strength2.elapsed = tabs.strength2.elapsed + tick() - tabs.strength2.startedAt
    end

    tabs.strength2.Runtime.Text = string.format(
        "Runtime: %dd %dh %dm %ds",
        math.floor(tabs.strength2.elapsed / 86400),
        math.floor((tabs.strength2.elapsed % 86400) / 3600),
        math.floor((tabs.strength2.elapsed % 3600) / 60),
        math.floor(tabs.strength2.elapsed % 60)
    )
end

tabs.strength2.updateStats = function()
    tabs.strength2.StrengthStats.Text = "Strength: " .. formatNumber(tabs.strength2.strength.Value)
        .. " | Gained: " .. formatNumber(tabs.strength2.strength.Value - tabs.strength2.startStrength)
    tabs.strength2.DurabilityStats.Text = "Durability: " .. formatNumber(tabs.strength2.durability.Value)
        .. " | Gained: " .. formatNumber(tabs.strength2.durability.Value - tabs.strength2.startDurability)
end

tabs.strength2.networkStats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]

tabs.strength2.getCurrentPing = function()
    return tabs.strength2.networkStats:GetValue()
end

tabs.strength2.getAdaptiveSpeed = function(ping)
    if ping < 80 then return 500 end
    if ping < 150 then return 300 end
    if ping < 250 then return 100 end
    return 50
end

tabs.strength2.workerLoop = function()
    tabs.strength2.lastPingUpdate = time()
    tabs.strength2.currentPing = tabs.strength2.getCurrentPing()

    while tabs.strength2.running do
        if time() - tabs.strength2.lastPingUpdate > 0.5 then
            tabs.strength2.currentPing = tabs.strength2.getCurrentPing()
            tabs.strength2.lastPingUpdate = time()
        end

        tabs.strength2.repsToFire = tabs.strength2.pingControl
            and tabs.strength2.getAdaptiveSpeed(tabs.strength2.currentPing)
            or tabs.strength2.repSpeed
        tabs.strength2.repsToFire = math.min(tabs.strength2.repsToFire, tabs.strength2.repSpeed)
        tabs.strength2.delayBetweenBatches = math.clamp(tabs.strength2.currentPing / 2500, 0.001, 0.1)

        tabs.strength2.Status.Text = "Status: Farming | " .. formatNumber(tabs.strength2.repsToFire)
            .. " reps/batch | " .. formatNumber(tabs.strength2.currentPing) .. " ms"
        tabs.strength2.Status.TextColor3 = Color3.fromRGB(80, 255, 120)

        for repCount = 1, tabs.strength2.repsToFire do
            if not tabs.strength2.running then break end
            services.muscleEvent:FireServer("rep")
            if repCount % 500 == 0 then task.wait() end
        end
        task.wait(tabs.strength2.delayBetweenBatches)
    end

    tabs.strength2.workerActive = false
end

tabs.strength2.startWorker = function()
    if tabs.strength2.workerActive then return end
    tabs.strength2.workerActive = true
    task.spawn(tabs.strength2.workerLoop)
end

tabs.strength2:AddTextBox("Rep Speed:", function(inputText)
    tabs.strength2.speedValue = tonumber(inputText)
    if tabs.strength2.speedValue then
        tabs.strength2.repSpeed = math.clamp(math.floor(tabs.strength2.speedValue), 1, 1000)
    end
end)

tabs.strength2:AddSwitch("Controlled Speed", function(state)
    tabs.strength2.pingControl = state
end):Set(true)

tabs.strength2.FastRepToggle = tabs.strength2:AddSwitch("Fast Rep", function(state)
    tabs.strength2.running = state
    if state then
        if not tabs.strength2.gainedBaselineSet then
            tabs.strength2.startStrength = tabs.strength2.strength.Value
            tabs.strength2.startDurability = tabs.strength2.durability.Value
            tabs.strength2.gainedBaselineSet = true
        end
        tabs.strength2.Status.Text = "Status: Starting..."
        tabs.strength2.Status.TextColor3 = Color3.fromRGB(80, 255, 120)
        tabs.strength2.startWorker()
    else
        tabs.strength2.Status.Text = "Status: Paused"
        tabs.strength2.Status.TextColor3 = Color3.fromRGB(255, 180, 70)
    end
end)

tabs.strength2.FastRepToggle:Set(false)

task.spawn(function()
    while true do
        tabs.strength2.updateRuntime()
        task.wait(1)
    end
end)

tabs.strength2:AddLabel("For me, 20-40 works the best. Try around!")

-- Other Tab

function unequipPets()
    for _, folder in pairs(lp.player.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                services.replicatedstorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
end
