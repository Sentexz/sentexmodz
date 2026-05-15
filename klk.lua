--[[
    SENTEXMODZ PREMIUM 2026 - Menú con banner externo desde URL fiable
    Abre con PAGEDOWN (control 11). Sección "Self Options" con funciones mejoradas.
]]

-- ==================== CONFIGURACIÓN ====================
local BANNER_URL = "https://i.ibb.co/9Hc78NTn/JV6Drrz.png"

-- ==================== FUNCIONES AUXILIARES ====================
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

-- ==================== NOCLIP CORREGIDO ====================
local noclipActive = false
local noclipSpeed = 5.0
local boostMultiplier = 3.0

local controls = {
    forward = 32, backward = 33, left = 34, right = 35,
    boost = 21, descend = 36
}

local function getCamVectors()
    local camRot = GetGameplayCamRot(2)
    local pitch = math.rad(camRot.x)
    local yaw = math.rad(camRot.z)
    
    local cosPitch = math.cos(pitch)
    local sinPitch = math.sin(pitch)
    local cosYaw = math.cos(yaw)
    local sinYaw = math.sin(yaw)
    
    local forward = vector3(-sinYaw * cosPitch, cosYaw * cosPitch, sinPitch)
    local right = vector3(-cosYaw, -sinYaw, 0.0)
    local up = vector3(0.0, 0.0, 1.0)
    
    return forward, right, up
end

Citizen.CreateThread(function()
    while true do
        if noclipActive then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            local entity = (vehicle ~= 0 and vehicle) or ped
            
            SetEntityCollision(entity, false, false)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(entity, false)
            SetEntityVelocity(entity, 0.0, 0.0, 0.0)
            
            local moveX, moveY, moveZ = 0.0, 0.0, 0.0
            if IsControlPressed(0, controls.forward) then moveY = moveY + 1.0 end
            if IsControlPressed(0, controls.backward) then moveY = moveY - 1.0 end
            if IsControlPressed(0, controls.right) then moveX = moveX + 1.0 end
            if IsControlPressed(0, controls.left) then moveX = moveX - 1.0 end
            if IsControlPressed(0, controls.descend) then moveZ = moveZ - 1.0 end
            
            local speed = noclipSpeed
            if IsControlPressed(0, controls.boost) then speed = speed * boostMultiplier end
            
            if moveX ~= 0 or moveY ~= 0 or moveZ ~= 0 then
                local len = math.sqrt(moveX*moveX + moveY*moveY + moveZ*moveZ)
                if len > 0 then
                    moveX, moveY, moveZ = moveX/len, moveY/len, moveZ/len
                end
                local forward, right, up = getCamVectors()
                local delta = (forward * moveY) + (right * moveX) + (up * moveZ)
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

-- ==================== ESTRUCTURA DEL MENÚ ====================
local menuAbierto = false
local currentMenu = "main"
local currentOption = 1
local opcionesMenu = {}
local descripcionActual = ""

-- Colores y estilos
local neonColor = {0, 255, 255, 255}
local neonGlow = {0, 180, 255, 80}
local bgColor = {0, 0, 0, 210}
local selectBg = {30, 144, 255, 60}

opcionesMenu["main"] = {
    { nombre = "➤ Self Options", submenu = "self", desc = "Accede a las opciones del jugador" },
}
opcionesMenu["self"] = {
    { nombre = "⚡ Curar", accion = Curar, desc = "Restaura salud y armadura al máximo" },
    { nombre = "♻️ Revivir (ESX)", accion = RevivirESX, desc = "Resucita en servidores ESX" },
    { nombre = "♻️ Revivir (QB)", accion = RevivirQB, desc = "Resucita en servidores QB" },
    { nombre = "🌀 Noclip", 
      accion = function()
          noclipActive = not noclipActive
          if noclipActive then
              MostrarNotificacion("~b~Noclip ACTIVADO~s~\nWASD | Shift = Boost | Ctrl = Bajar")
          else
              local ped = PlayerPedId()
              local vehicle = GetVehiclePedIsIn(ped, false)
              local entity = (vehicle ~= 0 and vehicle) or ped
              SetEntityCollision(entity, true, true)
              SetEntityInvincible(ped, false)
              MostrarNotificacion("~r~Noclip DESACTIVADO")
          end
      end,
      desc = "Atraviesa paredes y vuela. Controles: WASD, Shift (boost), Ctrl (bajar)" },
}

-- ==================== BANNER ====================
local bannerDict = "sentex_banner"
local bannerLoaded = false

local function LoadBanner()
    if bannerLoaded then return true end
    local txd = CreateRuntimeTxd(bannerDict)
    if txd then
        local success = CreateRuntimeTextureFromImage(txd, "banner", BANNER_URL)
        if success then
            bannerLoaded = true
            print("^2[SENTEX] Banner cargado")
            return true
        end
    end
    return false
end

local function DibujarBanner(x, y, w, h)
    if not bannerLoaded then LoadBanner() end
    if bannerLoaded and HasStreamedTextureDictLoaded(bannerDict) then
        DrawSprite(bannerDict, "banner", x, y, w, h, 0.0, 255, 255, 255, 255)
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

    -- Línea bajo banner
    DrawRect(x, startY + altoBanner - 0.001, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], 200)

    -- Título de sección (sin "===")
    local tituloY = startY + altoBanner + 0.008
    local tituloStr = (currentMenu == "main" and "◆ MENU PRINCIPAL ◆") or (currentMenu == "self" and "⚙️ SELF OPTIONS ⚙️")
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

-- ==================== HILO PRINCIPAL ====================
local function StartMenu()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsDisabledControlJustReleased(0, 11) then
                menuAbierto = not menuAbierto
                if menuAbierto then
                    currentOption = 1
                    currentMenu = "main"
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    MostrarNotificacion("~b~★ SENTEXMODZ PREMIUM 2026 ★~s~ | Menú abierto")
                else
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    MostrarNotificacion("~b~★ SENTEXMODZ PREMIUM 2026 ★~s~ | Menú cerrado")
                end
                Citizen.Wait(200)
            end

            if menuAbierto then
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

    Citizen.CreateThread(function()
        Citizen.Wait(500)
        MostrarNotificacion("~b~★ SENTEXMODZ PREMIUM 2026 ★~s~ | Presiona ~y~PAGEDOWN~s~")
    end)
end

return { Start = StartMenu }
