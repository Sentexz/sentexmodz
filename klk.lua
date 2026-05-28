--[[
    SENTEX MENU v3.7 - Diseño premium rojo (sin iconos, sin desbordamiento)
    Abre con PAGEDOWN - Todas las funciones originales.
]]

local _r = math.random
local _w = Citizen.Wait
local _notify = function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

local _version = "v3.6 Beta + EH"   -- se mantiene por compatibilidad
local _discord = ".gg/sentexmodz"

-- ========== DETECCIÓN DE ANTICHEAT ==========
local _acDetected = false
local _acList = {}
local _acDB = {
    {"WaveShield", {"waveshield", "ws_core", "ws_anticheat"}},
    {"FiveGuard", {"fiveguard", "fg_anticheat"}},
    {"ElectronAC", {"electronac", "electron_", "eac"}},
    {"Likizao", {"likizao", "lkz", "likizao_anticheat"}},
    {"Eulen", {"eulen", "eulencheat", "eulen_anticheat"}},
    {"RedEngine", {"redengine", "red_anticheat", "reac"}},
    {"InfinityAC", {"infinityac", "infinity_", "iac"}},
    {"PhoenixAC", {"phoenixac", "phoenix_anticheat"}},
    {"VexAC", {"vexac", "vex_anticheat"}},
    {"NexusAC", {"nexusac", "nexus_anticheat"}},
    {"ReaperV4", {"reaperv4", "reaper_ac"}},
    {"Eagle", {"eagle", "ec_ac", "ec-ac"}},
    {"FiniAC", {"finiac", "fini_ac"}},
}
local function _scanAC()
    local found = {}
    local ok, num = pcall(GetNumResources)
    if ok then
        for i = 0, num - 1 do
            local res = GetResourceByFindIndex(i)
            if res then
                local name = string.lower(res)
                for _, ac in ipairs(_acDB) do
                    for _, p in ipairs(ac[2]) do
                        if name:find(p, 1, true) then
                            local startPos = name:find(p, 1, true)
                            if startPos == 1 or name:sub(startPos-1, startPos-1) == '_' then
                                found[ac[1]] = true
                            end
                        end
                    end
                end
            end
            _w(0)
        end
    end
    if next(found) then
        _acDetected = true
        _acList = {}
        for name,_ in pairs(found) do table.insert(_acList, name) end
        _notify("~r~⚠️ Anticheat detectado: ~y~"..table.concat(_acList,", ").."~s~")
        _notify("~r~ADVERTENCIA: Riesgo de sanción. Usa bajo tu responsabilidad.")
    else
        _acDetected = false
        _acList = {}
        _notify("~g~No se detectaron anticheats conocidos")
    end
end

-- ========== ACCIONES ORIGINALES ==========
local function _curar()
    local p = PlayerPedId()
    SetEntityHealth(p, GetEntityMaxHealth(p))
    SetPedArmour(p, 100)
    ClearPedBloodDamage(p)
    _notify("~g~Salud y armadura restauradas")
end

local function _revivirESX()
    TriggerEvent('esx_ambulancejob:revive')
    _notify("~g~Reviviendo (ESX)")
end

local function _revivirQB()
    local p = PlayerPedId()
    if IsPedDeadOrDying(p, true) then
        TriggerEvent('hospital:client:Revive')
        _w(100)
        if IsPedDeadOrDying(p, true) then
            TriggerServerEvent('hospital:server:RevivePlayer', GetPlayerServerId(PlayerId()))
        end
        _w(100)
        if exports['qbx_medical'] then
            pcall(function() exports['qbx_medical']:RevivePlayer() end)
        end
        _notify("~g~Intentando revivir (QB/QC)")
    else
        _notify("~r~No estás muerto")
    end
end

local function _revivirJugador(pid)
    local targetPed = GetPlayerPed(pid)
    if not targetPed or targetPed == 0 then _notify("~r~Jugador no encontrado") return end
    TriggerEvent('esx_ambulancejob:revive', pid)
    TriggerEvent('hospital:client:Revive', pid)
    TriggerServerEvent('hospital:server:RevivePlayer', GetPlayerServerId(pid))
    if exports['qbx_medical'] then pcall(function() exports['qbx_medical']:RevivePlayer(pid) end) end
    TriggerServerEvent('qb-hospital:server:RevivePlayer', GetPlayerServerId(pid))
    _w(500)
    if IsPedDeadOrDying(targetPed, true) then
        SetEntityHealth(targetPed, GetEntityMaxHealth(targetPed))
        ClearPedBloodDamage(targetPed)
        _notify("~g~Revivido por método directo")
    else
        _notify("~g~Intento de revivir completado")
    end
end

local function _repararVeh(v)
    if not v then v = GetVehiclePedIsIn(PlayerPedId(), false) end
    if v and v ~= 0 then
        SetVehicleFixed(v)
        SetVehicleDirtLevel(v, 0.0)
        _notify("~g~Vehículo reparado y limpiado")
    else
        _notify("~r~No estás en un vehículo")
    end
end

local function _tuneVehicleMax(veh)
    if not veh then veh = GetVehiclePedIsIn(PlayerPedId(), false) end
    if veh and veh ~= 0 then
        SetVehicleModKit(veh, 0)
        for i = 0, 49 do
            local numMods = GetNumVehicleMods(veh, i)
            if numMods > 0 then
                SetVehicleMod(veh, i, numMods - 1, false)
            end
        end
        ToggleVehicleMod(veh, 18, true)
        SetVehicleTyresCanBurst(veh, false)
        SetVehicleWindowTint(veh, 1)
        SetVehicleColours(veh, 120, 120)
        SetVehicleNeonLightsColour(veh, 0, 255, 255)
        SetVehicleNeonLightEnabled(veh, 0, true)
        SetVehicleNeonLightEnabled(veh, 1, true)
        SetVehicleNeonLightEnabled(veh, 2, true)
        SetVehicleNeonLightEnabled(veh, 3, true)
        _notify("~g~Vehículo tuneado al máximo")
    else
        _notify("~r~No estás en un vehículo")
    end
end

local _shiftBoostActive = false
local function _toggleShiftBoost()
    _shiftBoostActive = not _shiftBoostActive
    if _shiftBoostActive then
        _notify("~g~Shift Boost ACTIVADO (mantén SHIFT)")
    else
        _notify("~r~Shift Boost DESACTIVADO")
    end
end

Citizen.CreateThread(function()
    while true do
        if _shiftBoostActive then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 and IsControlPressed(0, 21) then
                local speed = GetEntitySpeed(veh) * 3.6
                if speed < 250 then
                    local fwd = GetEntityForwardVector(veh)
                    ApplyForceToEntity(veh, 1, fwd.x * 20.0, fwd.y * 20.0, fwd.z * 20.0, 0,0,0, 0, false, true, true, false, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end)

local function _flipVeh(v)
    if not v then v = GetVehiclePedIsIn(PlayerPedId(), false) end
    if v and v ~= 0 then
        local rot = GetEntityRotation(v)
        SetEntityRotation(v, rot.x, rot.y, rot.z + 180.0, 2, true)
        _notify("~g~Vehículo volteado")
    else
        _notify("~r~No estás en un vehículo")
    end
end

local function _limpiarVeh(v)
    if not v then v = GetVehiclePedIsIn(PlayerPedId(), false) end
    if v and v ~= 0 then
        SetVehicleDirtLevel(v, 0.0)
        _notify("~g~Vehículo limpiado")
    else
        _notify("~r~No estás en un vehículo")
    end
end

local function _conducirVeh(v)
    if not v or v == 0 then _notify("~r~El vehículo ya no existe") return end
    local p = PlayerPedId()
    local vCoord = GetEntityCoords(v)
    local dist = #(GetEntityCoords(p) - vCoord)
    if dist > 10.0 then
        _notify("~y~Teletransportando...")
        DoScreenFadeOut(500)
        _w(500 + _r(100,300))
        local offset = 2.0
        local newC = vector3(vCoord.x+offset, vCoord.y+offset, vCoord.z)
        SetEntityCoords(p, newC.x, newC.y, newC.z, false, false, false, false)
        _w(200)
        DoScreenFadeIn(500)
        _w(300)
    end
    local driver = GetPedInVehicleSeat(v, -1)
    if driver and driver ~= 0 then
        ClearPedTasksImmediately(driver)
        SetEntityCoords(driver, GetEntityCoords(driver)+vector3(1.0,1.0,0.5), false, false, false, false)
        _notify("~y~Conductor expulsado")
        _w(200)
    end
    TaskWarpPedIntoVehicle(p, v, -1)
    _notify("~g~Te has subido al vehículo")
end

local function _spawnVeh()
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Modelo:", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do _w(0) end
    local res = GetOnscreenKeyboardResult()
    if res and res ~= "" then
        local model = res:lower()
        if IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do _w(10) end
            local p = PlayerPedId()
            local coords = GetEntityCoords(p)
            local heading = GetEntityHeading(p)
            local veh = CreateVehicle(model, coords.x+2.0, coords.y+2.0, coords.z, heading, true, false)
            SetVehicleOnGroundProperly(veh)
            SetModelAsNoLongerNeeded(model)
            _notify("~g~Vehículo ~b~"..model.." ~g~spawneado")
        else
            _notify("~r~Modelo inválido: "..model)
        end
    end
end

local function _vehiculosCercanos()
    local list = {}
    local p = PlayerPedId()
    local pCoord = GetEntityCoords(p)
    local pool = GetGamePool("CVehicle")
    for i=1,#pool do
        local v = pool[i]
        if v ~= 0 and #(pCoord - GetEntityCoords(v)) < 150.0 then
            table.insert(list, v)
        end
    end
    return list
end

local function _nombreVeh(v)
    local model = GetEntityModel(v)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if name == "NULL" or name == "" then
        name = GetDisplayNameFromVehicleModel(model)
        if name == "NULL" or name == "" then
            name = tostring(model):upper()
        end
    end
    return name
end

local _vehCargado = nil
local _cargando = false

local function _rotToDir(rot)
    local adj = vec3((math.pi/180)*rot.x, (math.pi/180)*rot.y, (math.pi/180)*rot.z)
    return vec3(-math.sin(adj.z)*math.abs(math.cos(adj.x)), math.cos(adj.z)*math.abs(math.cos(adj.x)), math.sin(adj.x))
end

local function _cargarVeh()
    local p = PlayerPedId()
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local dir = _rotToDir(camRot)
    local dest = vec3(camPos.x+dir.x*10.0, camPos.y+dir.y*10.0, camPos.z+dir.z*10.0)
    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, p, 0)
    local _, hit, _, _, ent = GetShapeTestResult(ray)
    if hit==1 and GetEntityType(ent)==2 then
        if _cargando then _notify("~r~Ya estás cargando un vehículo") return end
        _vehCargado = ent
        _cargando = true
        if not NetworkHasControlOfEntity(_vehCargado) then
            NetworkRequestControlOfEntity(_vehCargado)
            local t = 0
            while not NetworkHasControlOfEntity(_vehCargado) and t < 20 do _w(50) t=t+1 end
        end
        FreezeEntityPosition(_vehCargado, true)
        AttachEntityToEntity(_vehCargado, p, GetPedBoneIndex(p,60309), 1.0,0.5,0.0,0.0,0.0,0.0, true, true, false, false, 1, true)
        RequestAnimDict('anim@mp_rollarcoaster')
        while not HasAnimDictLoaded('anim@mp_rollarcoaster') do _w(10) end
        TaskPlayAnim(p, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
        _notify("~g~Vehículo cargado")
    else
        _notify("~r~No estás mirando a ningún vehículo")
    end
end

local function _lanzarVeh()
    if not _cargando or not _vehCargado then
        _notify("~r~No tienes ningún vehículo cargado")
        return
    end
    local p = PlayerPedId()
    local camRot = GetGameplayCamRot(2)
    local dir = _rotToDir(camRot)
    DetachEntity(_vehCargado, true, true)
    FreezeEntityPosition(_vehCargado, false)
    local force = 50.0
    ApplyForceToEntity(_vehCargado, 1, dir.x*force, dir.y*force, dir.z*force, 0.0,0.0,0.0, 0, false, true, true, false, true)
    ClearPedTasks(p)
    _notify("~y~Vehículo lanzado con fuerza")
    _vehCargado = nil
    _cargando = false
end

-- JUGADORES
local function _listaJugadores()
    local list = {}
    for i=0,255 do
        if NetworkIsPlayerActive(i) then
            local ped = GetPlayerPed(i)
            if ped and ped~=0 then
                table.insert(list, i)
            end
        end
    end
    return list
end

local function _nombreJugador(pid)
    local ok, name = pcall(function() return GetPlayerName(pid) end)
    if ok and name then return name end
    return "Jugador "..pid
end

-- SPAWN NPCs hostiles (modo sigiloso)
local _spawnedNPCs = {}
local function _spawnNPCs(targetPid, cantidad)
    cantidad = cantidad or _r(3, 6)
    local targetPed = GetPlayerPed(targetPid)
    if not targetPed or targetPed == 0 then _notify("~r~Jugador no encontrado") return end
    local targetCoords = GetEntityCoords(targetPed)
    local modelos = {"a_m_y_hipster_01", "a_m_y_skater_01", "a_m_y_runner_01", "a_m_y_beach_01", "a_m_y_cyclist_01", "a_m_y_business_01", "a_m_y_breakdance_01", "a_m_y_roadcyc_01"}
    _notify("~r~Spawneando "..cantidad.." NPCs hostiles (modo sigiloso)")
    Citizen.CreateThread(function()
        for i = 1, cantidad do
            local model = modelos[_r(#modelos)]
            RequestModel(model)
            local timeout = 0
            while not HasModelLoaded(model) and timeout < 100 do _w(10) timeout=timeout+1 end
            if not HasModelLoaded(model) then _notify("~r~Error cargando modelo") return end
            local angle = math.rad(_r(0,360))
            local dist = _r(8,20)
            local x = targetCoords.x + math.cos(angle)*dist
            local y = targetCoords.y + math.sin(angle)*dist
            local z = targetCoords.z
            local npc = CreatePed(0, model, x, y, z, _r(0,360), true, false)
            if npc and npc ~= 0 then
                Citizen.Wait(_r(100,300))
                NetworkRegisterEntityAsNetworked(npc)
                SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(npc), true)
                SetEntityAsMissionEntity(npc, true, true)
                SetEntityInvincible(npc, false)
                SetPedCombatAttributes(npc, 0, true)
                SetPedCombatAttributes(npc, 1, true)
                SetPedCombatAttributes(npc, 2, true)
                SetPedCombatAbility(npc, 100)
                SetPedCombatMovement(npc, 2)
                SetPedCombatRange(npc, 2)
                SetPedAccuracy(npc, 85)
                SetPedArmour(npc, 100)
                SetPedCanRagdoll(npc, true)
                SetPedFleeAttributes(npc, 0, false)
                GiveWeaponToPed(npc, GetHashKey("WEAPON_ASSAULTRIFLE"), 999, true, true)
                SetPedInfiniteAmmo(npc, true)
                SetEntityHealth(npc, 200)
                TaskCombatPed(npc, targetPed, 0, 16)
                table.insert(_spawnedNPCs, npc)
            end
            SetModelAsNoLongerNeeded(model)
            Citizen.Wait(_r(200,800))
        end
        _notify("~r~"..cantidad.." NPCs hostiles atacando a ".._nombreJugador(targetPid))
    end)
end

local function _abrirInventario(tgt)
    local sid = GetPlayerServerId(tgt)
    if not sid then _notify("~r~No se pudo obtener Server ID") return end
    TriggerEvent('ox_inventory:openInventory', 'otherplayer', sid)
    TriggerServerEvent('esx_inventory:openInventory', 'otherplayer', sid)
    TriggerServerEvent('qb-inventory:server:OpenInventory', 'player', sid)
    TriggerEvent('inventory:client:openInventory', tgt)
    _notify("~g~Intentando abrir inventario del jugador")
end

local function _matarJugador(tgt)
    local tgtPed = GetPlayerPed(tgt)
    if tgtPed and tgtPed~=0 then
        SetEntityHealth(tgtPed, 0)
        _notify("~r~Jugador eliminado")
    end
end

local function _teleportTo(tgt)
    local tgtPed = GetPlayerPed(tgt)
    if tgtPed and tgtPed~=0 then
        local coord = GetEntityCoords(tgtPed)
        local p = PlayerPedId()
        DoScreenFadeOut(500)
        _w(500)
        SetEntityCoords(p, coord.x, coord.y, coord.z+0.5, false, false, false, false)
        _w(100)
        DoScreenFadeIn(500)
        _notify("~g~Teletransportado")
    end
end

local function _spectatePlayer(pid)
    local targetPed = GetPlayerPed(pid)
    if targetPed and targetPed ~= 0 then
        NetworkSetInSpectatorMode(true, targetPed)
        _notify("~b~Espectando a " .. _nombreJugador(pid))
    else
        _notify("~r~Jugador no encontrado")
    end
end

local function _engancharVehCercano(tgt)
    local tgtPed = GetPlayerPed(tgt)
    if not tgtPed or tgtPed == 0 then _notify("~r~Jugador no encontrado") return end
    local pos = GetEntityCoords(tgtPed)
    local pool = GetGamePool("CVehicle")
    local closestVeh = nil
    local closestDist = 30.0
    for _, v in ipairs(pool) do
        local vPos = GetEntityCoords(v)
        local dist = #(pos - vPos)
        if dist < closestDist and v ~= GetVehiclePedIsIn(tgtPed, false) then
            closestDist = dist
            closestVeh = v
        end
    end
    if closestVeh then
        if not NetworkHasControlOfEntity(closestVeh) then
            NetworkRequestControlOfEntity(closestVeh)
            local t=0
            while not NetworkHasControlOfEntity(closestVeh) and t<20 do _w(50) t=t+1 end
        end
        AttachEntityToEntity(closestVeh, tgtPed, GetPedBoneIndex(tgtPed, 60309), 0.0,0.0,0.0,0.0,0.0,0.0, true, true, false, false, 2, true)
        _notify("~g~Vehículo enganchado al jugador")
    else
        _notify("~r~No hay vehículos cerca del jugador")
    end
end

local _siguienteJugador = nil

local function _crearAccion(pid, tipo)
    return function()
        if tipo=="inventory" then _abrirInventario(pid)
        elseif tipo=="revive" then _revivirJugador(pid)
        elseif tipo=="kill" then _matarJugador(pid)
        elseif tipo=="follow" then
            if _siguienteJugador == pid then
                _siguienteJugador = nil
                SetPlayerFollowing(PlayerId(), 0)
                _notify("~y~Dejaste de seguir")
            else
                _siguienteJugador = pid
                _notify("~y~Siguiendo jugador")
            end
        elseif tipo=="teleport" then _teleportTo(pid)
        elseif tipo=="spawnnpc" then _spawnNPCs(pid, _r(3,6))
        elseif tipo=="attachveh" then _engancharVehCercano(pid)
        elseif tipo=="ban" then
            local sid = GetPlayerServerId(pid)
            if sid then
                TriggerServerEvent('admin:ban', sid, "test")
                TriggerServerEvent('staff:banPlayer', sid, "test")
                _notify("~y~Intento de baneo directo")
            end
        elseif tipo=="framing" then _framingAttack(pid)
        elseif tipo=="spectate" then _spectatePlayer(pid)
        end
    end
end

-- ========== EVENT HUNTER Y FRAMING ==========
local _fuzzingActive = false
local _foundEvents = {}
local _eventsToFuzz = {
    "ban", "banplayer", "kick", "admin:ban", "staff:ban", "esx:ban", "qb-ban:player",
    "FiveGuard:Ban", "anticheat:ban", "giveMoney", "addMoney", "giveItem", "revive",
    "teleport", "spawnVehicle"
}
local function _startFuzzing()
    if _fuzzingActive then _notify("~r~Ya hay escaneo") return end
    _fuzzingActive = true
    _foundEvents = {}
    _notify("~y~[Event Hunter] Fuzzing... 30s")
    for _, ev in ipairs(_eventsToFuzz) do
        for _, suffix in ipairs({"", "Player", "Command", "admin:", "staff:"}) do
            local fullEv = suffix .. ev
            pcall(function() TriggerServerEvent(fullEv, "test_".._r(1,999)) end)
            _w(50)
        end
        _notify("~b~Probado: "..ev)
    end
    _fuzzingActive = false
    _notify("~g~Fuzzing completado. Revisa la consola del servidor.")
end

local function _framingAttack(pid)
    local targetId = GetPlayerServerId(pid)
    if not targetId then _notify("~r~Error ID") return end
    local targetName = _nombreJugador(pid)
    _notify("~y~[Framing] Atacando a "..targetName)
    local logs = {"qb-log:server:CreateLog", "esx_logs:addLog", "anticheat:addViolation", "FiveGuard:SendLog"}
    for _, ev in ipairs(logs) do
        for _=1,3 do
            pcall(function() TriggerServerEvent(ev, "Suspicious activity from "..targetName, "HIGH", "CHEAT") end)
            _w(50)
        end
    end
    local violations = {"FiveGuard:AddViolation", "anticheat:report", "anticheat:godmode", "anticheat:teleport_hack"}
    for i=1,100 do
        local ev = violations[_r(#violations)]
        pcall(function() TriggerServerEvent(ev, targetId, "EXPLOIT", 100) end)
        _w(_r(5,20))
    end
    local bans = {"admin:ban", "staff:ban", "esx:ban", "qb-ban:player", "FiveGuard:Ban"}
    for _, ev in ipairs(bans) do
        pcall(function() TriggerServerEvent(ev, targetId, "Cheating detected") end)
        _w(30)
    end
    _notify("~r~Ataque completado. Si FiveGuard es vulnerable, el jugador será baneado.")
end

-- ========== ENGANCHAR TODOS LOS VEHÍCULOS ==========
local _vehiclesAttached = {}
local function _attachAllNearbyVehicles()
    local ped = PlayerPedId()
    local myVeh = GetVehiclePedIsIn(ped, false)
    if myVeh == 0 then _notify("~r~Debes estar en un vehículo") return end
    local coords = GetEntityCoords(myVeh)
    local pool = GetGamePool("CVehicle")
    local count = 0
    for _, v in ipairs(pool) do
        if v ~= myVeh and not _vehiclesAttached[v] then
            if #(coords - GetEntityCoords(v)) < 100.0 then
                if not NetworkHasControlOfEntity(v) then
                    NetworkRequestControlOfEntity(v)
                    local t=0
                    while not NetworkHasControlOfEntity(v) and t<20 do _w(50) t=t+1 end
                end
                AttachEntityToEntity(v, myVeh, 0, 0.0, -2.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                table.insert(_vehiclesAttached, v)
                count = count + 1
            end
        end
    end
    if count > 0 then _notify("~g~Enganchados "..count.." vehículos") else _notify("~r~No hay vehículos cercanos") end
end

local function _detachAllVehicles()
    for _, v in ipairs(_vehiclesAttached) do
        if DoesEntityExist(v) then DetachEntity(v, true, false) end
    end
    _vehiclesAttached = {}
    _notify("~r~Todos los vehículos desenganchados")
end

-- ========== PROPS GIGANTES ==========
local _spawnedGiantProps = {}
local function _spawnPropGlobal(model, x, y, z, freeze)
    local prop = CreateObject(GetHashKey(model), x, y, z, true, true, false)
    if not prop or prop == 0 then prop = CreateObjectNoOffset(GetHashKey(model), x, y, z, true, true, false) end
    if prop and prop ~= 0 then
        NetworkRegisterEntityAsNetworked(prop)
        local netId = NetworkGetNetworkIdFromEntity(prop)
        SetNetworkIdExistsOnAllMachines(netId, true)
        SetNetworkIdCanMigrate(netId, true)
        SetEntityAsMissionEntity(prop, true, true)
        SetEntityLoadCollisionFlag(prop, true)
        if freeze then FreezeEntityPosition(prop, true) end
        if _acDetected then
            Citizen.CreateThread(function()
                _w(100); SetEntityHeading(prop, _r(0,360)); SetEntityAlpha(prop, 255, false)
            end)
        end
        table.insert(_spawnedGiantProps, prop)
        return true
    end
    return false
end

local function _spawnStuntBlock()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local handle = StartShapeTestRay(pos.x, pos.y, pos.z+100.0, pos.x, pos.y, pos.z-100.0, -1, ped, 0)
    local _, hit, hitPos = GetShapeTestResult(handle)
    local groundZ = hit and hitPos.z or pos.z
    local spawnZ = groundZ + 1.0
    local model = "stt_prop_stunt_bblock_huge_04"
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do _w(10) timeout=timeout+1 end
    if HasModelLoaded(model) then
        if _spawnPropGlobal(model, pos.x, pos.y, spawnZ, true) then
            _notify("~g~Bloque stunt gigante spawneado (visible globalmente)")
        else
            _notify("~r~Error al spawnear bloque stunt")
        end
    else
        _notify("~r~No se pudo cargar el modelo")
    end
    SetModelAsNoLongerNeeded(model)
end

local treeModels = {"prop_tree_olive_01", "prop_rio_del_01", "prop_tree_birch_04", "prop_tree_cedar_02", "prop_tree_lficus_02", "prop_tree_cedar_s_04", "prop_rus_olive", "prop_tree_birch_02"}
local _spawnedTrees = {}
local function _createForest()
    local ped = PlayerPedId()
    local center = GetEntityCoords(ped)
    local radius = 100
    local count = 300
    _notify("~y~Creando selva... (~w~"..count.." árboles~y~)")
    local created = 0
    for i = 1, count do
        local angle = math.rad(_r(0,360))
        local dist = _r(0, radius)
        local x = center.x + math.cos(angle)*dist
        local y = center.y + math.sin(angle)*dist
        local groundHandle = StartShapeTestRay(x, y, center.z+100.0, x, y, center.z-100.0, -1, ped, 0)
        local _, hit, hitPos = GetShapeTestResult(groundHandle)
        if hit then
            local modelName = treeModels[_r(#treeModels)]
            RequestModel(modelName)
            local timeout = 0
            while not HasModelLoaded(modelName) and timeout < 50 do _w(10) timeout=timeout+1 end
            if HasModelLoaded(modelName) then
                local tree = CreateObject(GetHashKey(modelName), x, y, hitPos.z, true, true, false)
                if tree and tree~=0 then
                    FreezeEntityPosition(tree, true)
                    NetworkRegisterEntityAsNetworked(tree)
                    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(tree), true)
                    SetEntityAsMissionEntity(tree, true, true)
                    table.insert(_spawnedTrees, tree)
                    created = created + 1
                end
                SetModelAsNoLongerNeeded(modelName)
            end
        end
        if i%50==0 then _w(0) end
    end
    _notify("~g~Selva creada con "..created.." árboles (visibles para todos)")
end

-- ========== NOCLIP ==========
local _noclipActivo = false
local _noclipVel = 5.0
local _boostMult = 3.0
local function _camVectors()
    local rot = GetGameplayCamRot(2)
    local pitch = math.rad(rot.x)
    local yaw = math.rad(rot.z)
    local cosP, sinP = math.cos(pitch), math.sin(pitch)
    local cosY, sinY = math.cos(yaw), math.sin(yaw)
    return vector3(-sinY*cosP, cosY*cosP, sinP), vector3(-cosY, -sinY, 0), vector3(0,0,1)
end
local function _fixPlayerPosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z+5.0, coords.x, coords.y, coords.z-10.0, -1, ped, 0)
    local _, hit, hitPos, _, _ = GetShapeTestResult(rayHandle)
    if hit then
        local newZ = hitPos.z + 0.5
        SetEntityCoords(ped, coords.x, coords.y, newZ, false, false, false, false)
    end
end
local function _disableNoclip()
    if not _noclipActivo then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local ent = (veh~=0 and veh) or ped
    SetEntityCollision(ent, true, true)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ent, false)
    _fixPlayerPosition()
    _noclipActivo = false
    _notify("~r~Noclip DESACTIVADO (posición corregida)")
end
Citizen.CreateThread(function()
    while true do
        if _noclipActivo then
            local p = PlayerPedId()
            local ent = (GetVehiclePedIsIn(p,false)~=0 and GetVehiclePedIsIn(p,false)) or p
            SetEntityCollision(ent, false, false)
            SetEntityInvincible(p, true)
            FreezeEntityPosition(ent, false)
            SetEntityVelocity(ent, 0,0,0)
            local mx,my,mz = 0,0,0
            if IsControlPressed(0, 32) then my=my+1 end
            if IsControlPressed(0, 33) then my=my-1 end
            if IsControlPressed(0, 34) then mx=mx+1 end
            if IsControlPressed(0, 35) then mx=mx-1 end
            if IsControlPressed(0, 22) then mz=mz+1 end
            if IsControlPressed(0, 36) then mz=mz-1 end
            local speed = _noclipVel
            if IsControlPressed(0, 21) then speed = speed * _boostMult end
            if mx~=0 or my~=0 or mz~=0 then
                local len = math.sqrt(mx^2+my^2+mz^2)
                if len>0 then mx,my,mz = mx/len, my/len, mz/len end
                local fwd, right, up = _camVectors()
                local delta = (fwd*my) + (right*mx) + (up*mz)
                SetEntityCoords(ent, GetEntityCoords(ent) + delta*speed, false, false, false, false)
            end
            _w(0)
        else
            _w(500)
        end
    end
end)

-- ========== MENÚ REDISEÑADO (sin iconos, con scroll) ==========
local _menuVisible = false
local _menuActual = "main"
local _optActual = 1
local _menus = {}
local _descActual = ""
local _submenusDinamicos = {}

local _scrollOffset = 0
local _maxVisibleOptions = 12

-- Colores
local _headerColor = {225, 17, 79, 255}      -- rojo #e1114f
local _selectionColor = {225, 17, 79, 220}
local _bgColor = {10, 10, 10, 210}
local _separatorColor = {80, 80, 90, 100}
local _posX = 0.82

local function _drawShadowText(t,x,y,sc,font,center,col)
    SetTextFont(font)
    SetTextScale(sc,sc)
    SetTextColour(col[1],col[2],col[3],col[4])
    SetTextCentre(center)
    SetTextDropshadow(1,0,0,0,200)
    SetTextEntry("STRING")
    AddTextComponentString(t)
    DrawText(x,y)
end

local function _drawBanner(x, y, w, h)
    DrawRect(x, y, w, h, _headerColor[1], _headerColor[2], _headerColor[3], _headerColor[4])
    SetTextFont(1)
    SetTextScale(0.48,0.48)
    SetTextColour(255,255,255,255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("SENTEXMODZ v3.7")
    DrawText(x, y-0.005)
    DrawRect(x, y + h/2 - 0.008, w-0.02, 0.001, 150, 10, 30, 150)
end

local function _drawItem(x, yCenter, w, opt, isSelected)
    -- Separador vertical
    local sepX = x - w/2 + 0.02
    DrawRect(sepX, yCenter, 0.001, 0.03, _separatorColor[1], _separatorColor[2], _separatorColor[3], _separatorColor[4])

    -- Texto limpio (sin símbolos originales)
    local cleanText = opt.nombre:gsub("[%[»%]•]", ""):gsub("^%s*", "")
    SetTextFont(0)
    SetTextScale(0.4,0.4)
    SetTextColour(255,255,255,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(cleanText)
    DrawText(x - w/2 + 0.04, yCenter - 0.008)

    -- Flecha derecha
    SetTextFont(0)
    SetTextScale(0.45,0.45)
    SetTextColour(200,200,200,200)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString("→")
    DrawText(x + w/2 - 0.03, yCenter - 0.008)
end

local function _updateScroll(totalOpts)
    if totalOpts <= _maxVisibleOptions then
        _scrollOffset = 0
    else
        if _optActual < _scrollOffset + 1 then
            _scrollOffset = _optActual - 1
        elseif _optActual > _scrollOffset + _maxVisibleOptions then
            _scrollOffset = _optActual - _maxVisibleOptions
        end
        if _scrollOffset < 0 then _scrollOffset = 0 end
        if _scrollOffset > totalOpts - _maxVisibleOptions then
            _scrollOffset = totalOpts - _maxVisibleOptions
        end
    end
end

function _drawMenu()
    local w = 0.23
    local x = _posX
    local y = 0.2
    local headerH = 0.08
    local optH = 0.04
    local lineH = 0.032
    local padDesc = 0.005

    local opts = _menus[_menuActual]
    if not opts then _menuActual = "main"; opts = _menus["main"] end
    local totalOpts = #opts
    _updateScroll(totalOpts)
    local visibleOpts = math.min(totalOpts - _scrollOffset, _maxVisibleOptions)

    local descLines = {}
    if _descActual and _descActual ~= "" then
        local tmp = _descActual
        while #tmp > 50 and #descLines < 2 do
            local cut = tmp:sub(1,50):match("^.*[ ,]") or tmp:sub(1,50)
            table.insert(descLines, cut)
            tmp = tmp:sub(#cut+1)
        end
        if #tmp > 0 and #descLines < 2 then table.insert(descLines, tmp) end
    end
    local descH = #descLines * lineH + padDesc * 2
    if #descLines == 0 then descH = 0.02 end

    local totalH = headerH + (visibleOpts * optH) + descH + 0.015
    local startY = y

    DrawRect(x, startY + totalH/2, w, totalH, _bgColor[1], _bgColor[2], _bgColor[3], _bgColor[4])
    _drawBanner(x, startY + headerH/2, w, headerH)

    local optsY = startY + headerH + 0.008
    for i = 1, visibleOpts do
        local idx = _scrollOffset + i
        local opt = opts[idx]
        if opt then
            local yCenter = optsY + (i-1) * optH + optH/2
            local isSelected = (idx == _optActual)
            if isSelected then
                DrawRect(x, yCenter, w-0.02, optH-0.004, _selectionColor[1], _selectionColor[2], _selectionColor[3], _selectionColor[4])
            end
            _drawItem(x, yCenter, w, opt, isSelected)
            if isSelected then
                _descActual = (opt.desc or "Selecciona una opción") .. " "
            end
        end
    end

    local descY = startY + headerH + (visibleOpts * optH) + 0.008
    for i, line in ipairs(descLines) do
        local lineY = descY + padDesc + (i-1)*lineH + lineH/2 - 0.008
        SetTextFont(0)
        SetTextScale(0.3,0.3)
        SetTextColour(200,200,210,255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(line)
        DrawText(x, lineY)
    end

    local counter = _optActual .. "/" .. totalOpts
    SetTextFont(0)
    SetTextScale(0.25,0.25)
    SetTextColour(150,150,160,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(counter)
    DrawText(x + w/2 - 0.02, startY + totalH - 0.02)
    SetTextEntry("STRING")
    AddTextComponentString(_discord)
    DrawText(x - w/2 + 0.01, startY + totalH - 0.02)

    if _acDetected then
        SetTextFont(4)
        SetTextScale(0.35,0.35)
        SetTextColour(255,80,80,255)
        SetTextCentre(false)
        SetTextEntry("STRING")
        AddTextComponentString("⚠️")
        DrawText(x - w/2 - 0.02, startY + 0.01)
    end

    if totalOpts > _maxVisibleOptions then
        local scrollAreaY = startY + headerH + 0.008
        local scrollAreaH = visibleOpts * optH
        local thumbHeight = (visibleOpts / totalOpts) * scrollAreaH
        local thumbPos = (_scrollOffset / (totalOpts - visibleOpts)) * (scrollAreaH - thumbHeight)
        local barX = x + w/2 - 0.008
        DrawRect(barX, scrollAreaY + scrollAreaH/2, 0.003, scrollAreaH, 40,40,50,180)
        DrawRect(barX, scrollAreaY + thumbHeight/2 + thumbPos, 0.003, thumbHeight, _headerColor[1], _headerColor[2], _headerColor[3], 220)
    end
end

-- ========== MENÚS ESTÁTICOS ==========
_menus["main"] = {
    {nombre="[»] Self options", submenu="self", desc="Opciones del jugador"},
    {nombre="[»] Vehicle options", submenu="vehicle", desc="Opciones para vehículos"},
    {nombre="[»] Player list", submenu="player_list", desc="Interactuar con otros jugadores"},
    {nombre="[»] Map fucker", submenu="map_fucker", desc="Opciones del mapa"},
    {nombre="[»] Event Hunter", submenu="event_hunter", desc="Event Hunter y Framing"},
    {nombre="[»] Protection options", submenu="protection", desc="Herramientas de seguridad"},
}
_menus["self"] = {
    {nombre="• Curar", accion=_curar, desc="Restaura salud y armadura"},
    {nombre="• Revivir ESX", accion=_revivirESX, desc="Resucita en servidores ESX"},
    {nombre="• Revivir QB", accion=_revivirQB, desc="Resucita en servidores QB/QC"},
    {nombre="• Noclip", accion=function()
        if _noclipActivo then _disableNoclip() else _noclipActivo = true; _notify("~b~Noclip ACTIVADO") end
    end, desc="Atraviesa paredes. WASD, Shift (boost), Espacio/Ctrl"},
}
_menus["vehicle"] = {
    {nombre="• Spawn vehicle", accion=_spawnVeh, desc="Escribe modelo y spawnea"},
    {nombre="• Vehicle list", submenu="vehicle_list", desc="Vehículos cercanos (150m)"},
    {nombre="• Cargar vehículo", accion=_cargarVeh, desc="Apunta y carga un vehículo"},
    {nombre="• Lanzar vehículo", accion=_lanzarVeh, desc="Lanza el cargado"},
    {nombre="• Reparar", accion=function() _repararVeh() end, desc="Repara tu vehículo"},
    {nombre="• Tunear al máximo", accion=function() _tuneVehicleMax() end, desc="Mejora completa"},
    {nombre="• Shift Boost", accion=_toggleShiftBoost, desc="Aceleración extra con SHIFT"},
    {nombre="• Enganchar todos (100m)", accion=_attachAllNearbyVehicles, desc="Engancha todos"},
    {nombre="• Soltar todos", accion=_detachAllVehicles, desc="Desengancha todos"},
    {nombre="• Voltear", accion=function() _flipVeh() end, desc="Voltea el vehículo"},
    {nombre="• Limpiar", accion=function() _limpiarVeh() end, desc="Limpia el vehículo"},
}
_menus["map_fucker"] = {
    {nombre="• Bloque stunt gigante", accion=_spawnStuntBlock, desc="Crea bloque enorme"},
    {nombre="• Spawnear Selva", accion=_createForest, desc="Crea bosque de árboles"},
}
_menus["protection"] = {
    {nombre="• AC Checker", accion=_scanAC, desc="Detecta anticheats conocidos"},
}
_menus["event_hunter"] = {
    {nombre="• Iniciar Event Hunter", accion=_startFuzzing, desc="Prueba eventos comunes"},
    {nombre="• Ataque Framing (FiveGuard)", accion=function()
        _notify("~y~Selecciona jugador desde Player List")
        _menuActual = "player_list"
        _optActual = 1
    end, desc="Abre lista de jugadores"},
}

-- ========== DINÁMICOS ==========
local function _refrescarListaVeh()
    local vehs = _vehiculosCercanos()
    local opts = {}
    for i, v in ipairs(vehs) do
        local dname = _nombreVeh(v)
        opts[i] = {nombre="• "..dname, submenu="vehicle_"..tostring(v), desc="Opciones para "..dname, vehicle=v}
        if not _submenusDinamicos["vehicle_"..tostring(v)] then
            _submenusDinamicos["vehicle_"..tostring(v)] = {
                {nombre="• Reparar", accion=function() _repararVeh(v) end, desc="Repara"},
                {nombre="• Voltear", accion=function() _flipVeh(v) end, desc="Voltea"},
                {nombre="• Limpiar", accion=function() _limpiarVeh(v) end, desc="Limpia"},
                {nombre="• Conducir", accion=function() _conducirVeh(v) end, desc="Subirte (expulsa conductor)"},
                {nombre="• Tunear al máximo", accion=function() _tuneVehicleMax(v) end, desc="Mejora al máximo"},
            }
        end
    end
    if #opts == 0 then opts = {{nombre="• No hay vehículos cerca", accion=nil, desc="Acércate"}} end
    _menus["vehicle_list"] = opts
end

local function _refrescarListaJugadores()
    local players = _listaJugadores()
    local opts = {}
    for i, pid in ipairs(players) do
        local name = _nombreJugador(pid)
        opts[i] = {nombre="• "..name, submenu="player_"..tostring(pid), desc="Opciones para "..name, player=pid}
        if not _submenusDinamicos["player_"..tostring(pid)] then
            _submenusDinamicos["player_"..tostring(pid)] = {
                {nombre="• Abrir inventario", accion=_crearAccion(pid,"inventory"), desc="Abre inventario"},
                {nombre="• Revivir", accion=_crearAccion(pid,"revive"), desc="Intenta revivir"},
                {nombre="• Matar", accion=_crearAccion(pid,"kill"), desc="Mata al jugador"},
                {nombre="• Seguir", accion=_crearAccion(pid,"follow"), desc="Sigue al jugador"},
                {nombre="• Teleportar", accion=_crearAccion(pid,"teleport"), desc="Teletransportarse"},
                {nombre="• Spawn NPCs (3-6)", accion=_crearAccion(pid,"spawnnpc"), desc="NPCs hostiles"},
                {nombre="• Enganchar vehículo cercano", accion=_crearAccion(pid,"attachveh"), desc="Engancha vehículo"},
                {nombre="• Banear (simple)", accion=_crearAccion(pid,"ban"), desc="Intenta banear"},
                {nombre="• Ataque Framing", accion=_crearAccion(pid,"framing"), desc="Contra FiveGuard"},
                {nombre="• Espectear", accion=_crearAccion(pid,"spectate"), desc="Espectar al jugador"},
            }
        end
    end
    if #opts == 0 then opts = {{nombre="• No hay jugadores", accion=nil, desc="Espera"}} end
    _menus["player_list"] = opts
end

-- ========== INICIALIZACIÓN Y BUCLE PRINCIPAL ==========
local _menuListo = false
local _retardo = 5000 + _r(0,10000)

Citizen.CreateThread(function()
    _notify("~b~[~s~SENTEX~b~]~s~ Inicializando módulos...")
    _w(1500)
    _notify("~b~[~s~SENTEX~b~]~s~ Estableciendo conexión con la API del juego...")
    _w(_retardo - 2500)
    _menuListo = true
    _scanAC()
    _notify("~b~[~s~SENTEX~b~]~s~ Sistema listo. Presiona PAGEDOWN para abrir el menú.")
end)

local function StartMenu()
    Citizen.CreateThread(function()
        while true do
            _w(0)
            if _menuListo and IsDisabledControlJustReleased(0, 11) then
                _menuVisible = not _menuVisible
                if _menuVisible then
                    _optActual = 1
                    _menuActual = "main"
                    _scrollOffset = 0
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    _notify("~b~[~s~SENTEX~b~]~s~ Menú abierto.")
                else
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    _notify("~b~[~s~SENTEX~b~]~s~ Menú cerrado.")
                end
                _w(200)
            end

            if _menuVisible and _menuListo then
                if _menuActual == "vehicle_list" then _refrescarListaVeh()
                elseif _menuActual == "player_list" then _refrescarListaJugadores() end

                if _menuActual:match("^vehicle_") and not _menus[_menuActual] then
                    if _submenusDinamicos[_menuActual] then _menus[_menuActual] = _submenusDinamicos[_menuActual]
                    else _menuActual = "vehicle_list" end
                elseif _menuActual:match("^player_") and not _menus[_menuActual] then
                    if _submenusDinamicos[_menuActual] then _menus[_menuActual] = _submenusDinamicos[_menuActual]
                    else _menuActual = "player_list" end
                end

                _drawMenu()
                local maxOpt = #_menus[_menuActual]

                if IsDisabledControlJustReleased(0, 172) then
                    _optActual = _optActual - 1
                    if _optActual < 1 then _optActual = maxOpt end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                elseif IsDisabledControlJustReleased(0, 173) then
                    _optActual = _optActual + 1
                    if _optActual > maxOpt then _optActual = 1 end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                elseif IsDisabledControlJustReleased(0, 191) then
                    local sel = _menus[_menuActual][_optActual]
                    if sel then
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        if sel.submenu then
                            _menuActual = sel.submenu
                            _optActual = 1
                            _scrollOffset = 0
                        elseif sel.accion then
                            local ok, err = pcall(sel.accion)
                            if not ok then _notify("~b~[~s~SENTEX~b~]~s~ Error: "..tostring(err)) end
                        end
                    end
                elseif IsDisabledControlJustReleased(0, 177) then
                    if _menuActual == "main" then
                        _menuVisible = false
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual == "self" or _menuActual == "vehicle" or _menuActual == "player_list" or _menuActual == "map_fucker" or _menuActual == "protection" or _menuActual == "event_hunter" then
                        _menuActual = "main"
                        _optActual = 1
                        _scrollOffset = 0
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual == "vehicle_list" then
                        _menuActual = "vehicle"
                        _optActual = 1
                        _scrollOffset = 0
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual:match("^vehicle_") then
                        _menuActual = "vehicle_list"
                        _optActual = 1
                        _scrollOffset = 0
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual:match("^player_") then
                        _menuActual = "player_list"
                        _optActual = 1
                        _scrollOffset = 0
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    else
                        _menuActual = "main"
                        _optActual = 1
                        _scrollOffset = 0
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                end
            end
        end
    end)
end

return { Start = StartMenu }
