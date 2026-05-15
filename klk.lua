--[[
    SENTEX MENU - Versión v3.4 (advertencia anticheat con estilo del menú)
    Abre con PAGEDOWN
]]

-- ==================== CONFIGURACIÓN ====================
local VERSION = "v3.4 (advertencia integrada)"
local DISCORD = ".gg/sentexmodz"

-- ==================== NOTIFICACIONES ====================
local function MostrarNotificacion(texto)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(texto)
    DrawNotification(false, false)
end

-- ==================== DETECCIÓN DE ANTICHEAT (SOLO ADVERTENCIA) ====================
local anticheatDetected = false
local anticheatList = {}

local anticheats = {
    { name = "WaveShield", patterns = { "waveshield", "ws_core", "ws_anticheat" } },
    { name = "FiveGuard", patterns = { "fiveguard", "fg_", "fg_anticheat" } },
    { name = "ElectronAC", patterns = { "electronac", "electron_", "eac" } },
    { name = "Likizao", patterns = { "likizao", "lkz", "likizao_anticheat" } },
    { name = "Eulen", patterns = { "eulen", "eulencheat", "eulen_anticheat" } },
    { name = "RedEngine", patterns = { "redengine", "red_anticheat", "reac" } },
    { name = "InfinityAC", patterns = { "infinityac", "infinity_", "iac" } },
    { name = "PhoenixAC", patterns = { "phoenixac", "phoenix_anticheat" } },
    { name = "VexAC", patterns = { "vexac", "vex_anticheat" } },
    { name = "NexusAC", patterns = { "nexusac", "nexus_anticheat" } },
}

local function ScanAntiCheatSilent()
    local found = {}
    local success, num = pcall(GetNumResources)
    if success then
        for i = 0, num - 1 do
            local resource = GetResourceByFindIndex(i)
            if resource then
                local name = string.lower(resource)
                for _, ac in ipairs(anticheats) do
                    for _, pattern in ipairs(ac.patterns) do
                        if name:find(pattern) then
                            found[ac.name] = true
                        end
                    end
                end
            end
            Citizen.Wait(0)
        end
    end
    if next(found) then
        anticheatDetected = true
        anticheatList = {}
        for name, _ in pairs(found) do
            table.insert(anticheatList, name)
        end
        MostrarNotificacion("~r~⚠️ Anticheat detectado: ~y~" .. table.concat(anticheatList, ", ") .. "~s~")
    else
        anticheatDetected = false
        anticheatList = {}
        MostrarNotificacion("~g~No se detectaron anticheats conocidos")
    end
end

-- ==================== ACCIONES (SIN BLOQUEOS) ====================
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
    local ped = PlayerPedId()
    if IsPedDeadOrDying(ped, true) then
        TriggerEvent('hospital:client:Revive')
        Citizen.Wait(100)
        if IsPedDeadOrDying(ped, true) then
            TriggerServerEvent('hospital:server:RevivePlayer', GetPlayerServerId(PlayerId()))
        end
        Citizen.Wait(100)
        if IsPedDeadOrDying(ped, true) and exports['qbx_medical'] then
            pcall(function() exports['qbx_medical']:RevivePlayer() end)
        end
        MostrarNotificacion("~g~Intentando revivir (QB/QC)")
    else
        MostrarNotificacion("~r~No estás muerto")
    end
end

-- ==================== ACCIONES VEHÍCULO ====================
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
    if not vehicle or vehicle == 0 then
        MostrarNotificacion("~r~El vehículo ya no existe")
        return
    end
    local ped = PlayerPedId()
    local vehCoords = GetEntityCoords(vehicle)
    local dist = #(GetEntityCoords(ped) - vehCoords)
    
    if dist > 10.0 then
        MostrarNotificacion("~y~Teletransportando...")
        DoScreenFadeOut(500)
        Citizen.Wait(500 + math.random(100, 300))
        local offset = 2.0
        local newCoords = vector3(vehCoords.x + offset, vehCoords.y + offset, vehCoords.z)
        SetEntityCoords(ped, newCoords.x, newCoords.y, newCoords.z, false, false, false, false)
        Citizen.Wait(200)
        DoScreenFadeIn(500)
        Citizen.Wait(300)
    end
    
    local driver = GetPedInVehicleSeat(vehicle, -1)
    if driver and driver ~= 0 then
        ClearPedTasksImmediately(driver)
        SetEntityCoords(driver, GetEntityCoords(driver) + vector3(1.0, 1.0, 0.5), false, false, false, false)
        MostrarNotificacion("~y~Conductor expulsado")
        Citizen.Wait(200)
    end
    
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    MostrarNotificacion("~g~Te has subido al vehículo")
end

function SpawnVehicle()
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Modelo (ej: adder)", "", "", "", 30)
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

function GetVehicleDisplayName(vehicle)
    local model = GetEntityModel(vehicle)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if name == "NULL" then
        name = string.upper(GetDisplayNameFromVehicleModel(model))
    end
    return name
end

-- ==================== CARGAR Y LANZAR VEHÍCULO ====================
local carriedVehicle = nil
local carryingVehicle = false

function LoadVehicle()
    local ped = PlayerPedId()
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local direction = RotationToDirection(camRot)
    local dest = vec3(camPos.x + direction.x * 10.0, camPos.y + direction.y * 10.0, camPos.z + direction.z * 10.0)
    local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, ped, 0)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
    
    if hit == 1 and GetEntityType(entityHit) == 2 then
        if carryingVehicle then
            MostrarNotificacion("~r~Ya estás cargando un vehículo")
            return
        end
        carriedVehicle = entityHit
        carryingVehicle = true
        if not NetworkHasControlOfEntity(carriedVehicle) then
            NetworkRequestControlOfEntity(carriedVehicle)
            local timeout = 0
            while not NetworkHasControlOfEntity(carriedVehicle) and timeout < 20 do
                Citizen.Wait(50)
                timeout = timeout + 1
            end
        end
        FreezeEntityPosition(carriedVehicle, true)
        AttachEntityToEntity(carriedVehicle, ped, GetPedBoneIndex(ped, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
        RequestAnimDict('anim@mp_rollarcoaster')
        while not HasAnimDictLoaded('anim@mp_rollarcoaster') do Citizen.Wait(10) end
        TaskPlayAnim(ped, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
        MostrarNotificacion("~g~Vehículo cargado")
    else
        MostrarNotificacion("~r~No estás mirando a ningún vehículo")
    end
end

function ThrowVehicle()
    if not carryingVehicle or not carriedVehicle then
        MostrarNotificacion("~r~No tienes ningún vehículo cargado")
        return
    end
    local ped = PlayerPedId()
    local camRot = GetGameplayCamRot(2)
    local direction = RotationToDirection(camRot)
    DetachEntity(carriedVehicle, true, true)
    FreezeEntityPosition(carriedVehicle, false)
    local force = 40.0
    ApplyForceToEntity(carriedVehicle, 1, direction.x * force, direction.y * force, direction.z * force, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    ClearPedTasks(ped)
    MostrarNotificacion("~y~Vehículo lanzado")
    carriedVehicle = nil
    carryingVehicle = false
end

function RotationToDirection(rotation)
    local adjusted = vec3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vec3(-math.sin(adjusted.z) * math.abs(math.cos(adjusted.x)), math.cos(adjusted.z) * math.abs(math.cos(adjusted.x)), math.sin(adjusted.x))
    return direction
end

-- ==================== ACCIONES JUGADORES ====================
function GetPlayerList()
    local players = {}
    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            local ped = GetPlayerPed(i)
            if ped and ped ~= 0 then
                table.insert(players, i)
            end
        end
    end
    return players
end

function GetPlayerNameSafe(player)
    local success, name = pcall(function()
        return GetPlayerName(player)
    end)
    if success and name then
        return name
    end
    return "Jugador " .. player
end

function SpawnAggressiveNPC(targetPlayerId)
    local targetPed = GetPlayerPed(targetPlayerId)
    if not targetPed or targetPed == 0 then
        MostrarNotificacion("~r~Jugador no encontrado")
        return
    end
    local targetCoords = GetEntityCoords(targetPed)
    local model = "a_m_y_hipster_01"
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    local spawnCoords = vector3(targetCoords.x + 10.0, targetCoords.y + 10.0, targetCoords.z)
    local npc = CreatePed(0, model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
    SetPedCombatAttributes(npc, 0, true)
    SetPedCombatAbility(npc, 100)
    SetPedAccuracy(npc, 60)
    SetPedArmour(npc, 50)
    SetPedCanRagdoll(npc, true)
    GiveWeaponToPed(npc, GetHashKey("WEAPON_PISTOL"), 999, true, true)
    SetPedInfiniteAmmo(npc, true)
    TaskGoToEntity(npc, targetPed, -1, 2.0, 5.0, 1073741824, 0)
    Citizen.Wait(3000)
    TaskCombatPed(npc, targetPed, 0, 16)
    SetEntityAsMissionEntity(npc, true, true)
    SetModelAsNoLongerNeeded(model)
    MostrarNotificacion("~r~NPC sospechoso spawneado cerca del jugador")
end

function OpenPlayerInventory(targetPlayerId)
    local targetServerId = GetPlayerServerId(targetPlayerId)
    if targetServerId then
        TriggerEvent('ox_inventory:openInventory', 'otherplayer', targetServerId)
        MostrarNotificacion("~g~Abriendo inventario del jugador")
    else
        MostrarNotificacion("~r~No se pudo obtener Server ID")
    end
end

function GiveMoneyToPlayer(targetPlayerId)
    TriggerServerEvent('esx:giveMoney', targetPlayerId, 10000)
    MostrarNotificacion("~g~Se han dado 10k al jugador")
end

function KillPlayer(targetPlayerId)
    local targetPed = GetPlayerPed(targetPlayerId)
    if targetPed and targetPed ~= 0 then
        SetEntityHealth(targetPed, 0)
        MostrarNotificacion("~r~Jugador eliminado")
    end
end

function TeleportToPlayer(targetPlayerId)
    local targetPed = GetPlayerPed(targetPlayerId)
    if targetPed and targetPed ~= 0 then
        local coords = GetEntityCoords(targetPed)
        local ped = PlayerPedId()
        DoScreenFadeOut(500)
        Citizen.Wait(500)
        SetEntityCoords(ped, coords.x, coords.y, coords.z + 0.5, false, false, false, false)
        Citizen.Wait(100)
        DoScreenFadeIn(500)
        MostrarNotificacion("~g~Teletransportado")
    end
end

function MakePlayerAction(pid, actionType)
    return function()
        if actionType == "inventory" then
            OpenPlayerInventory(pid)
        elseif actionType == "money" then
            GiveMoneyToPlayer(pid)
        elseif actionType == "revive" then
            TriggerEvent('esx_ambulancejob:revive', pid)
            TriggerEvent('hospital:client:Revive', pid)
            MostrarNotificacion("~g~Reviviendo jugador")
        elseif actionType == "kill" then
            KillPlayer(pid)
        elseif actionType == "follow" then
            if followingPlayer == pid then
                followingPlayer = nil
                SetPlayerFollowing(PlayerId(), 0)
                MostrarNotificacion("~y~Dejaste de seguir")
            else
                followingPlayer = pid
                MostrarNotificacion("~y~Siguiendo jugador")
            end
        elseif actionType == "teleport" then
            TeleportToPlayer(pid)
        elseif actionType == "spawnnpc" then
            SpawnAggressiveNPC(pid)
        end
    end
end

local followingPlayer = nil

-- ==================== MAP FUCKER (ATTACH + FREECAM) ====================
local attachActive = false
local attachedVehicles = {}

function ToggleAttachCars()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        MostrarNotificacion("~r~Debes estar en un vehículo")
        return
    end

    if not attachActive then
        local coords = GetEntityCoords(vehicle)
        local handle = GetGamePool("CVehicle")
        local count = 0
        for _, v in ipairs(handle) do
            if v ~= vehicle then
                local dist = #(coords - GetEntityCoords(v))
                if dist < 150.0 then
                    if not NetworkHasControlOfEntity(v) then
                        NetworkRequestControlOfEntity(v)
                        local timeout = 0
                        while not NetworkHasControlOfEntity(v) and timeout < 20 do
                            Citizen.Wait(50)
                            timeout = timeout + 1
                        end
                    end
                    AttachEntityToEntity(v, vehicle, 0, 0.0, -2.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    table.insert(attachedVehicles, v)
                    count = count + 1
                end
            end
        end
        if count > 0 then
            attachActive = true
            MostrarNotificacion("~g~Enganchados " .. count .. " vehículos")
        else
            MostrarNotificacion("~r~No hay vehículos en 150 metros")
        end
    else
        for _, v in ipairs(attachedVehicles) do
            if DoesEntityExist(v) then
                DetachEntity(v, true, false)
            end
        end
        attachedVehicles = {}
        attachActive = false
        MostrarNotificacion("~r~Vehículos desenganchados")
    end
end

-- Freecam
local freecamActive = false
local freecamEntity = nil

function ToggleFreecam()
    freecamActive = not freecamActive
    if freecamActive then
        freecamEntity = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        SetCamCoord(freecamEntity, coords.x, coords.y, coords.z + 2.0)
        SetCamRot(freecamEntity, 0.0, 0.0, GetEntityHeading(ped))
        RenderScriptCams(true, true, 1000, true, true)
        SetPlayerControl(PlayerId(), false, 0)
        SetEntityVisible(ped, false, false)
        MostrarNotificacion("~b~Freecam ACTIVADA | WASD + Ratón | BACKSPACE para salir")
    else
        RenderScriptCams(false, true, 1000, true, true)
        SetPlayerControl(PlayerId(), true, 0)
        local ped = PlayerPedId()
        SetEntityVisible(ped, true, false)
        DestroyCam(freecamEntity, true)
        freecamEntity = nil
        MostrarNotificacion("~b~Freecam DESACTIVADA")
    end
end

Citizen.CreateThread(function()
    while true do
        if freecamActive and freecamEntity then
            local speed = 5.0
            local moveX, moveY, moveZ = 0.0, 0.0, 0.0
            if IsControlPressed(0, 32) then moveY = moveY + speed end
            if IsControlPressed(0, 33) then moveY = moveY - speed end
            if IsControlPressed(0, 34) then moveX = moveX - speed end
            if IsControlPressed(0, 35) then moveX = moveX + speed end
            if IsControlPressed(0, 22) then moveZ = moveZ + speed end
            if IsControlPressed(0, 36) then moveZ = moveZ - speed end
            
            local currentPos = GetCamCoord(freecamEntity)
            local newPos = vector3(currentPos.x + moveX, currentPos.y + moveY, currentPos.z + moveZ)
            SetCamCoord(freecamEntity, newPos.x, newPos.y, newPos.z)
            
            local mouseX = GetDisabledControlNormal(0, 1)
            local mouseY = GetDisabledControlNormal(0, 2)
            local rot = GetCamRot(freecamEntity, 2)
            SetCamRot(freecamEntity, rot.x + mouseY * -50.0, 0.0, rot.z + mouseX * -50.0, 2)
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- ==================== AC CHECKER ====================
local isChecking = false
function CheckAntiCheatManual()
    if isChecking then
        MostrarNotificacion("~y~Ya se está ejecutando...")
        return
    end
    isChecking = true
    for i, opt in ipairs(opcionesMenu["protection"]) do
        if opt.nombre == "• AC Checker" then
            opt.nombre = "~b~• Checking..."
            break
        end
    end
    Citizen.CreateThread(function()
        local found = {}
        local success, num = pcall(GetNumResources)
        if success then
            for i = 0, num - 1 do
                local resource = GetResourceByFindIndex(i)
                if resource then
                    local name = string.lower(resource)
                    for _, ac in ipairs(anticheats) do
                        for _, pattern in ipairs(ac.patterns) do
                            if name:find(pattern) then
                                found[ac.name] = true
                            end
                        end
                    end
                end
                Citizen.Wait(0)
            end
        end
        
        if next(found) then
            anticheatDetected = true
            anticheatList = {}
            for name, _ in pairs(found) do
                table.insert(anticheatList, name)
            end
            local ac_text = table.concat(anticheatList, ", ")
            MostrarNotificacion("~r~⚠️ ANTICHEAT DETECTADO: ~y~" .. ac_text .. "~s~")
        else
            anticheatDetected = false
            anticheatList = {}
            MostrarNotificacion("~g~No se detectó ningún anticheat conocido")
        end
        
        for i, opt in ipairs(opcionesMenu["protection"]) do
            if opt.nombre == "~b~• Checking..." then
                opt.nombre = "• AC Checker"
                break
            end
        end
        isChecking = false
    end)
end

-- ==================== NOCLIP ====================
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

-- ==================== BANNER Y ESTILOS ====================
local neonColor = {0, 255, 255, 255}
local neonGlow = {0, 180, 255, 80}
local bgColor = {0, 0, 0, 210}
local selectBg = {30, 144, 255, 60}

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

-- Advertencia con estilo del menú
local function DibujarAdvertenciaAnticheat(x, y, totalAlto, ancho)
    if anticheatDetected then
        local warningY = y + totalAlto + 0.008
        local warningW = ancho - 0.01
        local warningH = 0.028
        -- Fondo oscuro igual que el menú
        DrawRect(x, warningY + warningH/2, warningW, warningH, bgColor[1], bgColor[2], bgColor[3], bgColor[4])
        -- Borde neón (igual que el menú)
        DrawRect(x, warningY + warningH/2, warningW, 0.0015, neonColor[1], neonColor[2], neonColor[3], 200)
        -- Texto de advertencia en color neón
        SetTextFont(4)
        SetTextScale(0.28, 0.28)
        SetTextColour(neonColor[1], neonColor[2], neonColor[3], 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString("⚠️ ANTICHEAT DETECTADO - TEN CUIDADO ⚠️")
        DrawText(x, warningY + 0.01)
    end
end

-- ==================== ESTRUCTURA DEL MENÚ ====================
local menuAbierto = false
local currentMenu = "main"
local currentOption = 1
local opcionesMenu = {}
local descripcionActual = ""

local dynamicMenus = {}

opcionesMenu["main"] = {
    { nombre = "[»] Self options", submenu = "self", desc = "Opciones del jugador" },
    { nombre = "[»] Vehicle options", submenu = "vehicle", desc = "Opciones para vehículos" },
    { nombre = "[»] Player list", submenu = "player_list", desc = "Interactuar con otros jugadores" },
    { nombre = "[»] Map fucker", submenu = "map_fucker", desc = "Opciones locas del mapa" },
    { nombre = "[»] Protection options", submenu = "protection", desc = "Herramientas de seguridad" },
}

opcionesMenu["self"] = {
    { nombre = "• Curar", accion = Curar, desc = "Restaura salud y armadura" },
    { nombre = "• Revivir ESX", accion = RevivirESX, desc = "Resucita en servidores ESX" },
    { nombre = "• Revivir QB", accion = RevivirQB, desc = "Resucita en servidores QB/QC" },
    { nombre = "• Noclip",
      accion = function()
          noclipActive = not noclipActive
          if noclipActive then
              MostrarNotificacion("~b~Noclip ACTIVADO")
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

opcionesMenu["vehicle"] = {
    { nombre = "• Spawn vehicle", accion = SpawnVehicle, desc = "Escribe el modelo y spawnea el coche" },
    { nombre = "• Vehicle list", submenu = "vehicle_list", desc = "Lista de vehículos cercanos" },
    { nombre = "• Cargar vehículo", accion = LoadVehicle, desc = "Apunta a un vehículo y presiónalo para cargarlo" },
    { nombre = "• Lanzar vehículo", accion = ThrowVehicle, desc = "Lanza el vehículo que tienes cargado" },
}

opcionesMenu["map_fucker"] = {
    { nombre = "• Attach cars", accion = ToggleAttachCars, desc = "Engancha cualquier vehículo cercano (150m)" },
    { nombre = "• Freecam", accion = ToggleFreecam, desc = "Cámara libre (toggle)" },
}

opcionesMenu["protection"] = {
    { nombre = "• AC Checker", accion = CheckAntiCheatManual, desc = "Detecta anticheats (solo advertencia visual)" },
}

-- ==================== FUNCIONES DINÁMICAS ====================
function RefreshVehicleListMenu()
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
        if not dynamicMenus["vehicle_" .. tostring(v)] then
            dynamicMenus["vehicle_" .. tostring(v)] = {
                { nombre = "• Reparar", accion = function() RepararVehiculo(vehicleHandle) end, desc = "Repara este vehículo" },
                { nombre = "• Voltear", accion = function() FlipVehiculo(vehicleHandle) end, desc = "Voltea este vehículo" },
                { nombre = "• Limpiar", accion = function() LimpiarVehiculo(vehicleHandle) end, desc = "Limpia este vehículo" },
                { nombre = "• Conducir", accion = function() ConducirVehiculo(vehicleHandle) end, desc = "Subirte (expulsa conductor actual)" },
            }
        end
    end
    if #opts == 0 then
        opts = { { nombre = "• No hay vehículos cerca", accion = nil, desc = "Acércate" } }
    end
    opcionesMenu["vehicle_list"] = opts
end

function RefreshPlayerListMenu()
    local players = GetPlayerList()
    local opts = {}
    for i, pid in ipairs(players) do
        local name = GetPlayerNameSafe(pid)
        opts[i] = {
            nombre = "• " .. name,
            submenu = "player_" .. tostring(pid),
            desc = "Opciones para " .. name,
            player = pid
        }
        if not dynamicMenus["player_" .. tostring(pid)] then
            dynamicMenus["player_" .. tostring(pid)] = {
                { nombre = "• Abrir inventario", accion = MakePlayerAction(pid, "inventory"), desc = "Abre el inventario ESX/ox_inventory" },
                { nombre = "• Dar dinero (10k)", accion = MakePlayerAction(pid, "money"), desc = "Da 10.000$ al jugador (ESX)" },
                { nombre = "• Revivir", accion = MakePlayerAction(pid, "revive"), desc = "Intenta revivir" },
                { nombre = "• Matar", accion = MakePlayerAction(pid, "kill"), desc = "Mata al jugador" },
                { nombre = "• Seguir", accion = MakePlayerAction(pid, "follow"), desc = "Cámara sigue al jugador" },
                { nombre = "• Teleportar", accion = MakePlayerAction(pid, "teleport"), desc = "Teletransportarse" },
                { nombre = "• Spawn NPC agresivo", accion = MakePlayerAction(pid, "spawnnpc"), desc = "Spawn un NPC que atacará al jugador" },
            }
        end
    end
    if #opts == 0 then
        opts = { { nombre = "• No hay jugadores", accion = nil, desc = "Espera" } }
    end
    opcionesMenu["player_list"] = opts
end

-- ==================== DIBUJO PRINCIPAL ====================
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
                      (currentMenu == "player_list" and "JUGADORES") or
                      (currentMenu == "map_fucker" and "MAP FUCKER") or
                      (currentMenu == "protection" and "PROTECTION OPTIONS") or
                      (currentMenu:match("^vehicle_") and "OPCIONES VEHICULO") or
                      (currentMenu:match("^player_") and "OPCIONES JUGADOR")
    DrawShadowText(tituloStr, x, tituloY, 0.48, 0, true, neonColor)

    local optsY = startY + altoBanner + altoTitulo + 0.008
    for i, opt in ipairs(opciones) do
        local yOff = optsY + (i-1) * altoOpcion
        local color = (i == currentOption) and neonColor or {200,200,200,255}
        if i == currentOption then
            DrawRect(x, yOff + altoOpcion/2 - 0.005, ancho - 0.01, altoOpcion - 0.005, selectBg[1], selectBg[2], selectBg[3], selectBg[4])
        end
        local displayName = opt.nombre:gsub("~b~", ""):gsub("~r~", ""):gsub("~g~", ""):gsub("~y~", "")
        DrawShadowText(displayName, x - ancho/2 + 0.02, yOff, 0.4, 0, false, color)
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

    local counterText = currentOption .. "/" .. numOpt
    SetTextFont(0)
    SetTextScale(0.28, 0.28)
    SetTextColour(150, 150, 150, 255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(counterText)
    DrawText(x + ancho/2 - 0.02, startY + totalAlto - 0.022)

    SetTextFont(0)
    SetTextScale(0.28, 0.28)
    SetTextColour(150, 150, 150, 255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(DISCORD)
    DrawText(x - ancho/2 + 0.005, startY + totalAlto - 0.022)
    
    -- Advertencia de anticheat debajo del menú
    DibujarAdvertenciaAnticheat(x, startY, totalAlto, ancho)
end

-- ==================== HILO PRINCIPAL ====================
local MENU_READY = false
Citizen.CreateThread(function()
    Citizen.Wait(3000)
    MENU_READY = true
    ScanAntiCheatSilent()
    MostrarNotificacion("~g~SENTEX MENU " .. VERSION .. "~s~ | Presiona ~y~PAGEDOWN~s~")
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
                if currentMenu == "vehicle_list" then
                    RefreshVehicleListMenu()
                elseif currentMenu == "player_list" then
                    RefreshPlayerListMenu()
                end

                if currentMenu:match("^vehicle_") and not opcionesMenu[currentMenu] then
                    if dynamicMenus[currentMenu] then
                        opcionesMenu[currentMenu] = dynamicMenus[currentMenu]
                    else
                        currentMenu = "vehicle_list"
                    end
                elseif currentMenu:match("^player_") and not opcionesMenu[currentMenu] then
                    if dynamicMenus[currentMenu] then
                        opcionesMenu[currentMenu] = dynamicMenus[currentMenu]
                    else
                        currentMenu = "player_list"
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
                            local ok, err = pcall(sel.accion)
                            if not ok then
                                MostrarNotificacion("~r~Error: " .. tostring(err))
                            end
                        end
                    end
                elseif IsDisabledControlJustReleased(0, 177) then
                    if currentMenu == "main" then
                        menuAbierto = false
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu == "self" then
                        currentMenu = "main"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu == "vehicle" then
                        currentMenu = "main"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu == "player_list" then
                        currentMenu = "main"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu == "map_fucker" then
                        currentMenu = "main"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu == "protection" then
                        currentMenu = "main"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu == "vehicle_list" then
                        currentMenu = "vehicle"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu:match("^vehicle_") then
                        currentMenu = "vehicle_list"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif currentMenu:match("^player_") then
                        currentMenu = "player_list"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    else
                        currentMenu = "main"
                        currentOption = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                end
            end
        end
    end)
end

return { Start = StartMenu }
