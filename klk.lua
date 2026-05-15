--[[
    SENTEXMODZ PREMIUM 2026 - Menú estable
    Abre con PAGEDOWN (control 11)
]]

-- ==================== CONFIGURACIÓN ====================
local BANNER_URL = "https://i.ibb.co/9Hc78NTn/JV6Drrz.png"

-- ==================== NOTIFICACIONES ====================
local function MostrarNotificacion(texto)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(texto)
    DrawNotification(false, false)
end

-- ==================== ACCIONES ====================
function Curar()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)
    MostrarNotificacion("~g~Salud y armadura restauradas")
end

function RevivirESX()
    TriggerEvent('esx_ambulancejob:revive')
    MostrarNotificacion("~g~Reviviendo (ESX)")
end

function RevivirQB()
    TriggerEvent("hospital:client:Revive")
    MostrarNotificacion("~g~Reviviendo (QB)")
end

-- ==================== NOCLIP (WASD + Shift/Ctrl) CORREGIDO ====================
local noclipActive = false
local noclipSpeed = 5.0
local boostMultiplier = 3.0

-- Controles estándar
local controls = {
    forward = 32,  -- W
    backward = 33, -- S
    left = 34,     -- A
    right = 35,    -- D
    boost = 21,    -- LEFT SHIFT
    descend = 36   -- LEFT CTRL
}

-- Obtener vectores de movimiento RELATIVOS a la cámara (sin invertir)
local function getMovementVectors()
    local camRot = GetGameplayCamRot(2)
    local pitch = math.rad(camRot.x)
    local yaw = math.rad(camRot.z)
    local cosPitch = math.cos(pitch)
    local sinPitch = math.sin(pitch)
    local cosYaw = math.cos(yaw)
    local sinYaw = math.sin(yaw)
    
    -- Vector adelante (donde mira la cámara en el plano horizontal + inclinación)
    local forward = vector3(-sinYaw * cosPitch, cosYaw * cosPitch, sinPitch)
    -- Vector derecha (perpendicular en el plano horizontal)
    local right = vector3(cosYaw, sinYaw, 0.0)   -- CORREGIDO: antes era -cosYaw, -sinYaw, lo que invertía
    -- Vector arriba
    local up = vector3(0.0, 0.0, 1.0)
    
    return forward, right, up
end

Citizen.CreateThread(function()
    while true do
        if noclipActive then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            local entity = (vehicle ~= 0 and vehicle) or ped
            
            -- Desactivar colisiones y gravedad
            SetEntityCollision(entity, false, false)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(entity, false)
            SetEntityVelocity(entity, 0.0, 0.0, 0.0)
            
            -- Leer entradas
            local moveForward = 0.0
            local moveRight = 0.0
            local moveUp = 0.0
            
            if IsControlPressed(0, controls.forward) then moveForward = moveForward + 1.0 end
            if IsControlPressed(0, controls.backward) then moveForward = moveForward - 1.0 end
            if IsControlPressed(0, controls.right) then moveRight = moveRight + 1.0 end
            if IsControlPressed(0, controls.left) then moveRight = moveRight - 1.0 end
            if IsControlPressed(0, controls.descend) then moveUp = moveUp - 1.0 end
            
            -- Boost
            local speed = noclipSpeed
            if IsControlPressed(0, controls.boost) then speed = speed * boostMultiplier end
            
            -- Si hay movimiento
            if moveForward ~= 0 or moveRight ~= 0 or moveUp ~= 0 then
                -- Normalizar para movimiento diagonal uniforme
                local len = math.sqrt(moveForward*moveForward + moveRight*moveRight + moveUp*moveUp)
                if len > 0 then
                    moveForward = moveForward / len
                    moveRight = moveRight / len
                    moveUp = moveUp / len
                end
                
                local forward, right, up = getMovementVectors()
                -- Movimiento: adelante/atrás con forward, lateral con right, vertical con up
                local delta = (forward * moveForward) + (right * moveRight) + (up * moveUp)
                delta = delta * speed
                
                local newCoords = GetEntityCoords(entity) + delta
                SetEntityCoords(entity, newCoords.x, newCoords.y, newCoords.z, false, false, false, false)
            end
            
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- ==================== MENÚ ====================
local menuAbierto = false
local currentMenu = "main"
local currentOption = 1
local opcionesMenu = {}
local descripcionActual = ""

-- Colores
local neonColor = {0, 255, 255, 255}
local neonGlow = {0, 180, 255, 80}
local bgColor = {0, 0, 0, 210}
local selectBg = {30, 144, 255, 60}

-- Opciones sin emojis raros
opcionesMenu["main"] = {
    { nombre = "> Self Options", submenu = "self", desc = "Opciones avanzadas del jugador" },
}
opcionesMenu["self"] = {
    { nombre = "[+] Curar", accion = Curar, desc = "Restaura salud y armadura" },
    { nombre = "[R] Revivir ESX", accion = RevivirESX, desc = "Resucita en servidores ESX" },
    { nombre = "[R] Revivir QB", accion = RevivirQB, desc = "Resucita en servidores QB" },
    { nombre = "[N] Noclip",
      accion = function()
          noclipActive = not noclipActive
          if noclipActive then
              MostrarNotificacion("~b~Noclip ACTIVADO~s~  |  WASD | Shift (boost) | Ctrl (bajar)")
          else
              local ped = PlayerPedId()
              local vehicle = GetVehiclePedIsIn(ped, false)
              local entity = (vehicle ~= 0 and vehicle) or ped
              SetEntityCollision(entity, true, true)
              SetEntityInvincible(ped, false)
              MostrarNotificacion("~r~Noclip DESACTIVADO")
          end
      end,
      desc = "Atraviesa paredes. Controles: WASD, Shift (boost), Ctrl (bajar)" },
}

-- ==================== BANNER CON CARGA DIFERIDA ====================
local bannerDict = "sentex_banner"
local bannerLoaded = false
local bannerLoadAttempts = 0

local function LoadBanner()
    if bannerLoaded then return true end
    if bannerLoadAttempts > 3 then return false end
    bannerLoadAttempts = bannerLoadAttempts + 1
    
    print("^3[SENTEX] Intentando cargar banner (intento " .. bannerLoadAttempts .. ")")
    local txd = CreateRuntimeTxd(bannerDict)
    if txd then
        local success = CreateRuntimeTextureFromImage(txd, "banner", BANNER_URL)
        if success then
            bannerLoaded = true
            print("^2[SENTEX] Banner cargado correctamente")
            return true
        else
            print("^1[SENTEX] Fallo al crear textura desde URL")
        end
    else
        print("^1[SENTEX] Fallo al crear TXD")
    end
    return false
end

local function DibujarBanner(x, y, w, h)
    if not bannerLoaded then
        LoadBanner()
    end
    if bannerLoaded and HasStreamedTextureDictLoaded(bannerDict) then
        DrawSprite(bannerDict, "banner", x, y, w, h, 0.0, 255, 255, 255, 255)
    else
        -- Fallback: rectángulo con degradado simple
        DrawRect(x, y, w, h, 0, 80, 160, 200)
        -- Texto opcional
        SetTextFont(0)
        SetTextScale(0.4, 0.4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString("SENTEXMODZ")
        DrawText(x, y - 0.02)
    end
end

-- ==================== TEXTO CON SOMBRA ====================
local function DrawShadowText(text, x, y, scale, font, center, color)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextCentre(center)
    SetTextDropshadow(1, 0, 0, 0, 200)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- ==================== DIBUJO DEL MENÚ ====================
function DibujarMenu()
    local ancho = 0.26
    local x = 0.7
    local y = 0.2
    local altoBanner = 0.11
    local altoTitulo = 0.045
    local altoOpcion = 0.042
    local lineaH = 0.032
    local paddingDesc = 0.005

    local opciones = opcionesMenu[currentMenu]
    local numOpt = #opciones

    -- Preparar descripción
    local lineasDesc = {}
    if descripcionActual and descripcionActual ~= "" then
        local temp = descripcionActual
        while #temp > 50 and #lineasDesc < 2 do
            local cut = temp:sub(1,50):match("^.*[ ,]") or temp:sub(1,50)
            table.insert(lineasDesc, cut)
            temp = temp:sub(#cut+1)
        end
        if #temp > 0 and #lineasDesc < 2 then
            table.insert(lineasDesc, temp)
        end
    end
    local descH = #lineasDesc * lineaH + paddingDesc * 2
    if #lineasDesc == 0 then descH = 0.02 end

    local totalAlto = altoBanner + altoTitulo + (numOpt * altoOpcion) + descH + 0.015
    local startY = y

    -- Fondo
    DrawRect(x, startY + totalAlto/2, ancho, totalAlto, bgColor[1], bgColor[2], bgColor[3], bgColor[4])

    -- Bordes
    DrawRect(x, startY, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x, startY + totalAlto, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x - ancho/2, startY + totalAlto/2, 0.0005, totalAlto, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x + ancho/2, startY + totalAlto/2, 0.0005, totalAlto, neonColor[1], neonColor[2], neonColor[3], neonColor[4])

    -- Resplandor
    DrawRect(x, startY, ancho + 0.006, 0.001, neonGlow[1], neonGlow[2], neonGlow[3], neonGlow[4])
    DrawRect(x, startY + totalAlto, ancho + 0.006, 0.001, neonGlow[1], neonGlow[2], neonGlow[3], neonGlow[4])

    -- Banner
    DibujarBanner(x, startY + altoBanner/2, ancho - 0.01, altoBanner - 0.01)

    -- Línea brillo bajo banner
    DrawRect(x, startY + altoBanner - 0.001, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], 200)

    -- Título (sin emojis)
    local tituloY = startY + altoBanner + 0.008
    local tituloStr = (currentMenu == "main" and "MENU PRINCIPAL") or (currentMenu == "self" and "SELF OPTIONS")
    DrawShadowText(tituloStr, x, tituloY, 0.48, 0, true, neonColor)

    -- Opciones
    local optsY = startY + altoBanner + altoTitulo + 0.008
    for i, opt in ipairs(opciones) do
        local yOff = optsY + (i-1) * altoOpcion
        local color = (i == currentOption) and neonColor or {200,200,200,255}
        if i == currentOption then
            DrawRect(x, yOff + altoOpcion/2 - 0.005, ancho - 0.01, altoOpcion - 0.005, selectBg[1], selectBg[2], selectBg[3], selectBg[4])
        end
        DrawShadowText(opt.nombre, x - ancho/2 + 0.02, yOff, 0.4, 0, false, color)
        if i == currentOption then
            descripcionActual = (opt.desc or "Selecciona una opción") .. " "
        end
    end

    -- Descripción
    local descY = startY + altoBanner + altoTitulo + (numOpt * altoOpcion) + 0.008
    if #lineasDesc > 0 then
        for i, linea in ipairs(lineasDesc) do
            local lineY = descY + paddingDesc + (i-1) * lineaH + lineaH/2 - 0.008
            DrawShadowText(linea, x, lineY, 0.32, 0, true, {210,210,255,255})
        end
    end
end

-- ==================== CONTROL PRINCIPAL CON ESPERA DE 3 SEGUNDOS ====================
local menuReady = false

local function StartMenu()
    -- Precargar banner al inicio
    Citizen.CreateThread(function()
        print("^3[SENTEX] Precargando banner...")
        LoadBanner()
        -- Si falla, reintentar cada segundo durante 3 segundos
        for i = 1, 3 do
            Citizen.Wait(1000)
            if not bannerLoaded then
                LoadBanner()
            end
        end
        menuReady = true
        MostrarNotificacion("~b~SENTEXMODZ PREMIUM 2026~s~ | Menu listo (~y~PAGEDOWN~s~)")
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if menuReady and IsDisabledControlJustReleased(0, 11) then -- PAGEDOWN
                menuAbierto = not menuAbierto
                if menuAbierto then
                    currentOption = 1
                    currentMenu = "main"
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    MostrarNotificacion("~b~SENTEXMODZ PREMIUM 2026~s~ | Menu abierto")
                else
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    MostrarNotificacion("~b~SENTEXMODZ PREMIUM 2026~s~ | Menu cerrado")
                end
                Citizen.Wait(200)
            end

            if menuReady and menuAbierto then
                DibujarMenu()
                local maxOpt = #opcionesMenu[currentMenu]

                if IsDisabledControlJustReleased(0, 172) then
                    currentOption = currentOption - 1
                    if currentOption < 1 then currentOption = maxOpt end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                elseif IsDisabledControlJustReleased(0, 173) then
                    currentOption = currentOption + 1
                    if currentOption > maxOpt then currentOption = 1 end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                elseif IsDisabledControlJustReleased(0, 191) then
                    local sel = opcionesMenu[currentMenu][currentOption]
                    if sel then
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        if sel.submenu then
                            currentMenu = sel.submenu
                            currentOption = 1
                        elseif sel.accion then
                            sel.accion()
                        end
                    end
                elseif IsDisabledControlJustReleased(0, 177) then
                    if currentMenu ~= "main" then
                        currentMenu = "main"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    else
                        menuAbierto = false
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                end
            end
        end
    end)

    -- Mensaje inicial rápido
    Citizen.CreateThread(function()
        Citizen.Wait(500)
        MostrarNotificacion("~b~SENTEXMODZ PREMIUM 2026~s~ | Cargando... espera 3 segundos")
    end)
end

return { Start = StartMenu }
