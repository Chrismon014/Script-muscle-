local services = {
    http = game:GetService("HttpService"),
    players = game:GetService("Players")
}

-- Configuración de Work.ink
local WORKINK_SYSTEM_ID = "30WM"
local KEY_LINK = "https://work.ink/30WM/key-system"

-- Mapeo único para Muscle Legends en tu repositorio
getgenv().supported = {
    [3623096087] = "https://raw.githubusercontent.com/Chrismon014/Script-muscle-/refs/heads/main/Scripts/MuscleLegends/Loader.luau" -- Muscle Legends
}

-- Cargar librería UI EleriumV2 desde tu propio repositorio
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Chrismon014/Script-muscle-/refs/heads/main/eleriumv2.luau"))()
local window = library:AddWindow("NovaBlockStudio | Key System ML", {
    main_color = Color3.fromRGB(138, 0, 0),
    min_size = Vector2.new(400, 260),
    can_resize = false
})

local tab = window:AddTab("Autenticación")
tab:AddLabel("Completa las tareas para obtener tu Key de 24 horas:")

local userKeyInput = ""

tab:AddTextBox("Ingresar Key", function(txt)
    userKeyInput = txt
end)

-- Validación contra API de Work.ink
local function verifyWorkinkKey(key)
    if key == "" or #key < 4 then return false end

    local apiEndpoint = string.format("https://work.ink/_api/v2/token/isValid?token=%s&systemId=%s", key, WORKINK_SYSTEM_ID)
    local success, response = pcall(function()
        return game:HttpGet(apiEndpoint)
    end)

    if success and response then
        local ok, data = pcall(function()
            return services.http:JSONDecode(response)
        end)
        
        if ok and data and (data.valid == true or data.success == true) then
            return true
        end
    end
    return false
end

-- Botón para verificar y cargar Muscle Legends
tab:AddButton("Verificar y Cargar", function()
    if userKeyInput == "" then
        print("Error: Ingresa una Key primero.")
        return
    end

    if verifyWorkinkKey(userKeyInput) then
        print("Key confirmada. Cargando Muscle Legends...")
        
        local placeId = game.PlaceId
        local scriptUrl = getgenv().supported[placeId]
        
        if scriptUrl then
            loadstring(game:HttpGet(scriptUrl))()
        else
            warn("Este script solo está configurado para Muscle Legends.")
        end
    else
        warn("Key inválida o expirada. Completa el enlace de nuevo.")
    end
end)

-- Botón para copiar el enlace monetizado
tab:AddButton("Obtener Key (Copiar Enlace)", function()
    if setclipboard then
        setclipboard(KEY_LINK)
        print("¡Enlace copiado al portapapeles!")
    else
        print("Enlace: " .. KEY_LINK)
    end
end)

tab:Show()
