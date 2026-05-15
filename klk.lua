--[[
    SENTEX MENU - Versión v1.0.1 (beta)
    Abre con PAGEDOWN
]]

-- ==================== CONFIGURACIÓN ====================
local VERSION = "v1.0.1 (beta)"
local DISCORD = ".gg/sentexmodz"

-- ==================== NOTIFICACIONES ====================
local function MostrarNotificacion(texto)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(texto)
    DrawNotification(false, false)
end

-- ==================== ACCIONES GENERALES ====================
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

-- ==================== ACCIONES VEHÍCULO (nuevas) ====================
function RepararVehiculo(vehicle)
    if not vehicle then
        local ped = PlayerPedId()
        vehicle = GetVehiclePedIsIn(ped, false)
    end
    if vehicle and vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0.0)
        MostrarNotificacion("~g~Vehículo reparado y limpiado")
    else
        MostrarNotificacion("~r~No estás en un vehículo")
    end
end

function FlipVehiculo(vehicle)
    if not vehicle then
        local ped = PlayerPedId()
        vehicle = GetVehiclePedIsIn(ped, false)
    end
    if vehicle and vehicle ~= 0 then
        local rot = GetEntityRotation(vehicle)
        SetEntityRotation(vehicle, rot.x, rot.y, rot.z + 180.0, 2, true)
        MostrarNotificacion("~g~Vehículo volteado")
    else
        MostrarNotificacion("~r~No estás en un vehículo")
    end
end

function LimpiarVehiculo(vehicle)
    if not vehicle then
        local ped = PlayerPedId()
        vehicle = GetVehiclePedIsIn(ped, false)
    end
    if vehicle and vehicle ~= 0 then
        SetVehicleDirtLevel(vehicle, 0.0)
        MostrarNotificacion("~g~Vehículo limpiado")
    else
        MostrarNotificacion("~r~No estás en un vehículo")
    end
end

function ConducirVehiculo(vehicle)
    if vehicle and vehicle ~= 0 then
        local ped = PlayerPedId()
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        MostrarNotificacion("~g~Te has subido al vehículo")
    else
        MostrarNotificacion("~r~El vehículo ya no existe")
    end
end

-- Spawnear vehículo con teclado
function SpawnVehicle()
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Escribe el nombre del modelo", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end
    local result = GetOnscreenKeyboardResult()
    if result and result ~= "" then
        local model = result:lower()
        if IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(10)
            end
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local vehicle = CreateVehicle(model, coords.x + 2.0, coords.y + 2.0, coords.z, heading, true, false)
            SetVehicleOnGroundProperly(vehicle)
            SetModelAsNoLongerNeeded(model)
            MostrarNotificacion("~g~Vehículo ~b~" .. model .. " ~g~spawneado")
        else
            MostrarNotificacion("~r~Modelo inválido: " .. model)
        end
    end
end

-- Obtener vehículos cercanos
function GetNearbyVehicles()
    local vehicles = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local handle = GetGamePool("CVehicle")
    for i = 1, #handle do
        local v = handle[i]
        local dist = #(playerCoords - GetEntityCoords(v))
        if dist < 50.0 and v ~= 0 then
            table.insert(vehicles, v)
        end
    end
    return vehicles
end

-- Obtener nombre bonito del vehículo
function GetVehicleDisplayName(vehicle)
    local model = GetEntityModel(vehicle)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if name == "NULL" then
        name = string.upper(GetDisplayNameFromVehicleModel(model))
    end
    return name
end

-- ==================== NOCLIP (NO TOCAR, FUNCIONA) ====================
local noclipActive = false
local noclipSpeed = 5.0
local boostMultiplier = 3.0

local controls = {
    forward = 32, backward = 33, left = 34, right = 35,
    boost = 21, ascend = 22, descend = 36
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
            if IsControlPressed(0, controls.left) then moveX = moveX + 1.0 end
            if IsControlPressed(0, controls.right) then moveX = moveX - 1.0 end
            if IsControlPressed(0, controls.ascend) then moveZ = moveZ + 1.0 end
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

-- ==================== BANNER ====================
local function DibujarBanner(x, y, w, h)
    DrawRect(x, y, w, h, 0, 30, 60, 200)
    SetTextFont(7)
    SetTextScale(0.55, 0.55)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("SENTEX MENU")
    DrawText(x, y - 0.02)
    SetTextFont(0)
    SetTextScale(0.28, 0.28)
    SetTextColour(200, 200, 200, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(VERSION)
    DrawText(x, y + 0.015)
end

-- ==================== ESTRUCTURA DEL MENÚ ====================
local menuAbierto = false
local currentMenu = "main"
local currentOption = 1
local opcionesMenu = {}
local descripcionActual = ""

-- Submenús dinámicos para vehículos cercanos
local dynamicMenus = {} -- nombre -> tabla de opciones

local neonColor = {0, 255, 255, 255}
local neonGlow = {0, 180, 255, 80}
local bgColor = {0, 0, 0, 210}
local selectBg = {30, 144, 255, 60}

opcionesMenu["main"] = {
    { nombre = "[»] Self options", submenu = "self", desc = "Opciones del jugador" },
    { nombre = "[»] Vehicle options", submenu = "vehicle", desc = "Opciones para vehículos" },
}

opcionesMenu["self"] = {
    { nombre = "• Curar", accion = Curar, desc = "Restaura salud y armadura" },
    { nombre = "• Revivir ESX", accion = RevivirESX, desc = "Resucita en servidores ESX" },
    { nombre = "• Revivir QB", accion = RevivirQB, desc = "Resucita en servidores QB" },
    { nombre = "• Noclip",
      accion = function()
          noclipActive = not noclipActive
          if noclipActive then
              MostrarNotificacion("~b~Noclip ACTIVADO~s~  |  WASD | Shift (boost) | Espacio (subir) | Ctrl (bajar)")
          else
              local ped = PlayerPedId()
              local vehicle = GetVehiclePedIsIn(ped, false)
              local entity = (vehicle ~= 0 and vehicle) or ped
              SetEntityCollision(entity, true, true)
              SetEntityInvincible(ped, false)
              MostrarNotificacion("~r~Noclip DESACTIVADO")
          end
      end,
      desc = "Atraviesa paredes. Controles: WASD, Shift (boost), Espacio (subir), Ctrl (bajar)" },
}

-- Menú vehicle estático
opcionesMenu["vehicle"] = {
    { nombre = "• Spawn vehicle", accion = SpawnVehicle, desc = "Escribe el modelo y spawnea el coche" },
    { nombre = "• Vehicle list", submenu = "vehicle_list", desc = "Lista de vehículos cercanos" },
}

-- Función para generar el submenú dinámico de la lista de vehículos
local function RefreshVehicleListMenu()
    local vehicles = GetNearbyVehicles()
    local opts = {}
    for i, v in ipairs(vehicles) do
        local displayName = GetVehicleDisplayName(v)
        local vehicleHandle = v
        opts[i] = {
            nombre = "• " .. displayName,
            submenu = "vehicle_" .. tostring(v),
            desc = "Opciones para " .. displayName,
            vehicle = vehicleHandle
        }
        -- Crear submenú para cada vehículo
        if not dynamicMenus["vehicle_" .. tostring(v)] then
            dynamicMenus["vehicle_" .. tostring(v)] = {
                { nombre = "• Reparar", accion = function() RepararVehiculo(vehicleHandle) end, desc = "Repara este vehículo" },
                { nombre = "• Voltear", accion = function() FlipVehiculo(vehicleHandle) end, desc = "Voltea este vehículo" },
                { nombre = "• Limpiar", accion = function() LimpiarVehiculo(vehicleHandle) end, desc = "Limpia este vehículo" },
                { nombre = "• Conducir", accion = function() ConducirVehiculo(vehicleHandle) end, desc = "Subirte al vehículo" },
            }
        end
    end
    if #opts == 0 then
        opts = { { nombre = "• No hay vehículos cerca", accion = nil, desc = "Acércate a algún coche" } }
    end
    opcionesMenu["vehicle_list"] = opts
end

-- Registrar submenús dinámicos en opcionesMenu (se llenan en tiempo real)
-- vehicle_list se actualiza cada vez que se entra
-- Los vehicle_XXXX se crean bajo demanda

-- ==================== FUNCIONES AUXILIARES ====================
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
    if not opciones then
        -- Si por alguna razón el submenú no existe, volver al principal
        currentMenu = "main"
        opciones = opcionesMenu["main"]
    end
    local numOpt = #opciones

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

    DrawRect(x, startY + totalAlto/2, ancho, totalAlto, bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    DrawRect(x, startY, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x, startY + totalAlto, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x - ancho/2, startY + totalAlto/2, 0.0005, totalAlto, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x + ancho/2, startY + totalAlto/2, 0.0005, totalAlto, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x, startY, ancho + 0.006, 0.001, neonGlow[1], neonGlow[2], neonGlow[3], neonGlow[4])
    DrawRect(x, startY + totalAlto, ancho + 0.006, 0.001, neonGlow[1], neonGlow[2], neonGlow[3], neonGlow[4])

    DibujarBanner(x, startY + altoBanner/2, ancho - 0.01, altoBanner - 0.01)
    DrawRect(x, startY + altoBanner - 0.001, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], 200)

    local tituloY = startY + altoBanner + 0.008
    local tituloStr = (currentMenu == "main" and "MENU PRINCIPAL") or
                      (currentMenu == "self" and "SELF OPTIONS") or
                      (currentMenu == "vehicle" and "VEHICLE OPTIONS") or
                      (currentMenu == "vehicle_list" and "VEHICULOS CERCA") or
                      (currentMenu:match("^vehicle_") and "OPCIONES VEHICULO")
    DrawShadowText(tituloStr, x, tituloY, 0.48, 0, true, neonColor)

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

    local descY = startY + altoBanner + altoTitulo + (numOpt * altoOpcion) + 0.008
    if #lineasDesc > 0 then
        for i, linea in ipairs(lineasDesc) do
            local lineY = descY + paddingDesc + (i-1) * lineaH + lineaH/2 - 0.008
            DrawShadowText(linea, x, lineY, 0.32, 0, true, {210,210,255,255})
        end
    end

    -- Contador de opción
    local counterText = currentOption .. "/" .. numOpt
    SetTextFont(0)
    SetTextScale(0.28, 0.28)
    SetTextColour(150, 150, 150, 255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(counterText)
    DrawText(x + ancho/2 - 0.02, startY + totalAlto - 0.022)

    -- Discord
    SetTextFont(0)
    SetTextScale(0.28, 0.28)
    SetTextColour(150, 150, 150, 255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(DISCORD)
    DrawText(x - ancho/2 + 0.005, startY + totalAlto - 0.022)
end

-- ==================== HILO PRINCIPAL ====================
local MENU_READY = false
Citizen.CreateThread(function()
    Citizen.Wait(3000)
    MENU_READY = true
    MostrarNotificacion("~g~SENTEX MENU " .. VERSION .. "~s~ | Listo. Presiona ~y~PAGEDOWN~s~")
end)

local function StartMenu()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if MENU_READY and IsDisabledControlJustReleased(0, 11) then
                menuAbierto = not menuAbierto
                if menuAbierto then
                    currentOption = 1
                    currentMenu = "main"
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    MostrarNotificacion("~b~SENTEX MENU~s~ | Abierto")
                else
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    MostrarNotificacion("~b~SENTEX MENU~s~ | Cerrado")
                end
                Citizen.Wait(200)
            end

            if menuAbierto and MENU_READY then
                -- Refrescar lista de vehículos si estamos en vehicle_list
                if currentMenu == "vehicle_list" then
                    RefreshVehicleListMenu()
                end
                -- Asegurar que los submenús dinámicos existen en opcionesMenu
                if currentMenu:match("^vehicle_") and not opcionesMenu[currentMenu] then
                    if dynamicMenus[currentMenu] then
                        opcionesMenu[currentMenu] = dynamicMenus[currentMenu]
                    else
                        currentMenu = "vehicle_list"
                    end
                end

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
                        -- Volver al menú anterior (si es vehicle_XXX volver a vehicle_list)
                        if currentMenu:match("^vehicle_") then
                            currentMenu = "vehicle_list"
                        elseif currentMenu == "vehicle_list" then
                            currentMenu = "vehicle"
                        else
                            currentMenu = "main"
                        end
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
end

return { Start = StartMenu }
