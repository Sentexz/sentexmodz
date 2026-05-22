--[[
    SENTEX MENU - v3.6 Beta
    Abre con PAGEDOWN - Carga diferida 5-15s
    CORREGIDO: NPCs agresivos solo desde Player list (contra el jugador elegido)
    Rampa persistente SIN opción de eliminar (para joder)
]]

local _r = math.random
local _w = Citizen.Wait
local _notify = function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

local _version = "v3.6 Beta"
local _discord = ".gg/sentexmodz"

-- ========== DETECCIÓN DE ANTICHEAT MEJORADA ==========
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

-- ========== ACCIONES ==========
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
        if IsPedDeadOrDying(p, true) and exports['qbx_medical'] then
            pcall(function() exports['qbx_medical']:RevivePlayer() end)
        end
        _notify("~g~Intentando revivir (QB/QC)")
    else
        _notify("~r~No estás muerto")
    end
end

-- REVIVIR JUGADOR (MULTI-FRAMEWORK)
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

-- VEHÍCULO
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

-- ========== SPAWN NPCs CONTRA UN JUGADOR ESPECÍFICO (DESDE PLAYER LIST) ==========
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

-- ABRIR INVENTARIO MULTI-FRAMEWORK
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

-- ENGANCHAR VEHÍCULO MÁS CERCANO AL JUGADOR OBJETIVO
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

-- ========== PROPS GIGANTES CON MÉTODOS AVANZADOS (GLOBALES Y SEGUROS) ==========
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

-- ========== BOSQUE (SELVA) MEJORADA ==========
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

-- ========== LLUVIA DE SILLAS CORREGIDA ==========
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

-- SPAWN DE VEHÍCULOS SEGURO
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

-- ========== RAMPA PERSISTENTE (SIN OPCIÓN DE ELIMINAR) ==========
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

-- Hilo de persistencia para la rampa (se regenera sola si la borran)
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

-- ========== MENÚ PRINCIPAL ==========
local _menuVisible = false
local _menuActual = "main"
local _optActual = 1
local _menus = {}
local _descActual = ""
local _submenusDinamicos = {}

local _baseR, _baseG, _baseB = 0, 255, 255
local function _variarSutil(v)
    local n = v + _r(-2,2)
    if n<0 then n=0 elseif n>255 then n=255 end
    return n
end
local _neonColor = {_baseR, _baseG, _baseB, 255}
local _glowColor = {0, 180, 255, 80}
local _bgColor = {0,0,0,210}
local _selectBg = {30,144,255,60}
local _bannerTexto = "SENTEX MENU"
local _posX = 0.7

local function _randomizarEstilos()
    _neonColor = {_variarSutil(_baseR), _variarSutil(_baseG), _variarSutil(_baseB), 255}
    _glowColor = {_variarSutil(0), _variarSutil(180), _variarSutil(255), 80}
    _selectBg = {_variarSutil(30), _variarSutil(144), _variarSutil(255), 60}
    _posX = 0.7 + (_r(-2,2)/100)
    local banners = {"SENTEX MENU", "SENTEX", "SX MENU", "SENTEX v3.6 Beta"}
    _bannerTexto = banners[_r(#banners)]
end

_menus["main"] = {
    {nombre="[»] Self options", submenu="self", desc="Opciones del jugador"},
    {nombre="[»] Vehicle options", submenu="vehicle", desc="Opciones para vehículos"},
    {nombre="[»] Player list", submenu="player_list", desc="Interactuar con otros jugadores"},
    {nombre="[»] Map fucker", submenu="map_fucker", desc="Opciones del mapa (molestas pero seguras)"},
    {nombre="[»] Protection options", submenu="protection", desc="Herramientas de seguridad"},
}
_menus["self"] = {
    {nombre="• Curar", accion=_curar, desc="Restaura salud y armadura"},
    {nombre="• Revivir ESX", accion=_revivirESX, desc="Resucita en servidores ESX"},
    {nombre="• Revivir QB", accion=_revivirQB, desc="Resucita en servidores QB/QC"},
    {nombre="• Noclip", accion=function()
        if freecamActive then _notify("~r~No puedes usar noclip en freecam") return end
        if _noclipActivo then
            _disableNoclip()
        else
            _noclipActivo = true
            _notify("~b~Noclip ACTIVADO")
        end
    end, desc="Atraviesa paredes. Controles: WASD, Shift (boost), Espacio (subir), Ctrl (bajar)"},
    {nombre="• Freecam", accion=function()
        if freecamActive then StopFreecam() else
            if _noclipActivo then _disableNoclip() end
            StartFreecam()
        end
    end, desc="Cámara libre (jugador se queda quieto e invisible)"},
}
_menus["vehicle"] = {
    {nombre="• Spawn vehicle", accion=_spawnVeh, desc="Escribe el modelo y spawnea el coche"},
    {nombre="• Vehicle list", submenu="vehicle_list", desc="Lista de vehículos cercanos (150m)"},
    {nombre="• Cargar vehículo", accion=_cargarVeh, desc="Apunta y carga un vehículo"},
    {nombre="• Lanzar vehículo", accion=_lanzarVeh, desc="Lanza el vehículo que tienes cargado"},
    {nombre="• Enganchar todos (100m)", accion=_attachAllNearbyVehicles, desc="Engancha TODOS los vehículos en 100m"},
    {nombre="• Soltar todos", accion=_detachAllVehicles, desc="Desengancha todos los enganchados"},
}
_menus["map_fucker"] = {
    {nombre="• Bloque stunt gigante", accion=_spawnStuntBlock, desc="Crea un bloque de stunt enorme (visible globalmente)"},
    {nombre="• Bloque stunt alternativo", accion=_spawnStuntBlockAlt, desc="Crea otro bloque stunt gigante"},
    {nombre="• Spawnear Selva", accion=_createForest, desc="Llena 100m a la redonda de árboles (visibles para todos)"},
    {nombre="• Lluvia de sillas (30s)", accion=_startChairRain, desc="Hace caer sillas a tu alrededor (con gravedad y visibles)"},
    {nombre="• Spawn 5 vehículos (seguro)", accion=_safeMassVehicleSpawn, desc="Genera 5 coches alrededor (evita baneo)"},
    {nombre="• Humo global", accion=_globalSmoke, desc="Humo en la posición de cada jugador"},
    {nombre="• Todos a bailar", accion=_everyoneDance, desc="Todos los jugadores bailan (animación real)"},
    -- SOLO LA RAMPA PERSISTENTE (SIN BORRAR)
    {nombre="• Spawn Rampa persistente", accion=_spawnRampa, desc="Crea una rampa que se regenera y NO se puede eliminar"},
}
_menus["protection"] = {
    {nombre="• AC Checker", accion=function()
        _notify("~y~Escaneando...")
        Citizen.CreateThread(function()
            local found={}
            local ok,num = pcall(GetNumResources)
            if ok then
                for i=0,num-1 do
                    local res=GetResourceByFindIndex(i)
                    if res then
                        local name=string.lower(res)
                        for _,ac in ipairs(_acDB) do
                            for _,p in ipairs(ac[2]) do
                                if name:find(p,1,true) then
                                    local startPos = name:find(p,1,true)
                                    if startPos == 1 or name:sub(startPos-1, startPos-1) == '_' then
                                        found[ac[1]]=true
                                    end
                                end
                            end
                        end
                    end
                    _w(0)
                end
            end
            if next(found) then
                _acDetected=true
                _acList={}
                for n,_ in pairs(found) do table.insert(_acList,n) end
                SetTextFont(4)
                SetTextScale(0.32,0.32)
                SetTextColour(255,50,50,255)
                SetTextCentre(true)
                SetTextEntry("STRING")
                AddTextComponentString("~r~⚠️ AC DETECTADO: ~y~"..table.concat(_acList,", "))
                DrawText(_posX,0.85)
                _notify("~r~Extrema precaución")
            else
                _acDetected=false
                _acList={}
                SetTextFont(4)
                SetTextScale(0.32,0.32)
                SetTextColour(50,255,50,255)
                SetTextCentre(true)
                SetTextEntry("STRING")
                AddTextComponentString("~g~✓ No se detectaron anticheats")
                DrawText(_posX,0.85)
                _notify("~g~Entorno seguro")
            end
        end)
    end, desc="Detecta anticheats por nombre de recursos"},
}

-- DINÁMICOS
local function _refrescarListaVeh()
    local vehs = _vehiculosCercanos()
    local opts = {}
    for i,v in ipairs(vehs) do
        local dname = _nombreVeh(v)
        opts[i] = {nombre="• "..dname, submenu="vehicle_"..tostring(v), desc="Opciones para "..dname, vehicle=v}
        if not _submenusDinamicos["vehicle_"..tostring(v)] then
            _submenusDinamicos["vehicle_"..tostring(v)] = {
                {nombre="• Reparar", accion=function() _repararVeh(v) end, desc="Repara este vehículo"},
                {nombre="• Voltear", accion=function() _flipVeh(v) end, desc="Voltea este vehículo"},
                {nombre="• Limpiar", accion=function() _limpiarVeh(v) end, desc="Limpia este vehículo"},
                {nombre="• Conducir", accion=function() _conducirVeh(v) end, desc="Subirte (expulsa conductor)"},
            }
        end
    end
    if #opts==0 then opts={{nombre="• No hay vehículos cerca", accion=nil, desc="Acércate"}} end
    _menus["vehicle_list"] = opts
end

local function _refrescarListaJugadores()
    local players = _listaJugadores()
    local opts = {}
    for i,pid in ipairs(players) do
        local name = _nombreJugador(pid)
        opts[i] = {nombre="• "..name, submenu="player_"..tostring(pid), desc="Opciones para "..name, player=pid}
        if not _submenusDinamicos["player_"..tostring(pid)] then
            _submenusDinamicos["player_"..tostring(pid)] = {
                {nombre="• Abrir inventario", accion=_crearAccion(pid,"inventory"), desc="Abre inventario (multi-framework)"},
                {nombre="• Revivir", accion=_crearAccion(pid,"revive"), desc="Intenta revivir (multi-framework)"},
                {nombre="• Matar", accion=_crearAccion(pid,"kill"), desc="Mata al jugador"},
                {nombre="• Seguir", accion=_crearAccion(pid,"follow"), desc="Sigue al jugador"},
                {nombre="• Teleportar", accion=_crearAccion(pid,"teleport"), desc="Teletransportarse a él"},
                {nombre="• Spawn NPCs (3-6)", accion=_crearAccion(pid,"spawnnpc"), desc="Spawns múltiples NPCs hostiles (no se atacan entre sí)"},
                {nombre="• Enganchar vehículo cercano", accion=_crearAccion(pid,"attachveh"), desc="Engancha el vehículo más cercano al jugador"},
            }
        end
    end
    if #opts==0 then opts={{nombre="• No hay jugadores", accion=nil, desc="Espera"}} end
    _menus["player_list"] = opts
end

-- DIBUJO DEL MENÚ
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

local function _drawBanner(x,y,w,h)
    DrawRect(x,y,w,h,0,30,60,200)
    SetTextFont(7)
    SetTextScale(0.55,0.55)
    SetTextColour(255,255,255,255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(_bannerTexto)
    DrawText(x,y-0.02)
    SetTextFont(0)
    SetTextScale(0.28,0.28)
    SetTextColour(200,200,200,255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(_version)
    DrawText(x,y+0.015)
end

local function _drawACAlert()
    if _acDetected then
        SetTextFont(4)
        SetTextScale(0.35,0.35)
        SetTextColour(255,50,50,255)
        SetTextCentre(false)
        SetTextEntry("STRING")
        AddTextComponentString("⚠️")
        DrawText(_posX-0.13,0.203)
    end
end

function _drawMenu()
    local w=0.26
    local x=_posX
    local y=0.2
    local bannerH=0.11
    local titleH=0.045
    local optH=0.042
    local lineH=0.032
    local padDesc=0.005

    local opts=_menus[_menuActual]
    if not opts then _menuActual="main"; opts=_menus["main"] end
    local numOpt=#opts

    local descLines={}
    if _descActual and _descActual~="" then
        local tmp=_descActual
        while #tmp>50 and #descLines<2 do
            local cut=tmp:sub(1,50):match("^.*[ ,]") or tmp:sub(1,50)
            table.insert(descLines,cut)
            tmp=tmp:sub(#cut+1)
        end
        if #tmp>0 and #descLines<2 then table.insert(descLines,tmp) end
    end
    local descH = #descLines*lineH + padDesc*2
    if #descLines==0 then descH=0.02 end

    local totalH = bannerH+titleH+(numOpt*optH)+descH+0.015
    local startY=y

    DrawRect(x, startY+totalH/2, w, totalH, _bgColor[1],_bgColor[2],_bgColor[3],_bgColor[4])
    DrawRect(x, startY, w, 0.0005, _neonColor[1],_neonColor[2],_neonColor[3],_neonColor[4])
    DrawRect(x, startY+totalH, w, 0.0005, _neonColor[1],_neonColor[2],_neonColor[3],_neonColor[4])
    DrawRect(x-w/2, startY+totalH/2, 0.0005, totalH, _neonColor[1],_neonColor[2],_neonColor[3],_neonColor[4])
    DrawRect(x+w/2, startY+totalH/2, 0.0005, totalH, _neonColor[1],_neonColor[2],_neonColor[3],_neonColor[4])
    DrawRect(x, startY, w+0.006, 0.001, _glowColor[1],_glowColor[2],_glowColor[3],_glowColor[4])
    DrawRect(x, startY+totalH, w+0.006, 0.001, _glowColor[1],_glowColor[2],_glowColor[3],_glowColor[4])

    _drawBanner(x, startY+bannerH/2, w-0.01, bannerH-0.01)
    DrawRect(x, startY+bannerH-0.001, w, 0.0005, _neonColor[1],_neonColor[2],_neonColor[3],200)

    local titleY = startY+bannerH+0.008
    local titleStr = (_menuActual=="main" and "MENU PRINCIPAL") or
                    (_menuActual=="self" and "SELF OPTIONS") or
                    (_menuActual=="vehicle" and "VEHICLE OPTIONS") or
                    (_menuActual=="vehicle_list" and "VEHICULOS CERCA") or
                    (_menuActual=="player_list" and "JUGADORES") or
                    (_menuActual=="map_fucker" and "MAP FUCKER") or
                    (_menuActual=="protection" and "PROTECTION OPTIONS") or
                    (_menuActual:match("^vehicle_") and "OPCIONES VEHICULO") or
                    (_menuActual:match("^player_") and "OPCIONES JUGADOR")
    _drawShadowText(titleStr, x, titleY, 0.48, 0, true, _neonColor)

    local optsY = startY+bannerH+titleH+0.008
    for i,opt in ipairs(opts) do
        local yOff = optsY+(i-1)*optH
        local color = (i==_optActual) and _neonColor or {200,200,200,255}
        if i==_optActual then
            DrawRect(x, yOff+optH/2-0.005, w-0.01, optH-0.005, _selectBg[1],_selectBg[2],_selectBg[3],_selectBg[4])
        end
        local display = opt.nombre:gsub("~b~",""):gsub("~r~",""):gsub("~g~",""):gsub("~y~","")
        _drawShadowText(display, x-w/2+0.02, yOff, 0.4, 0, false, color)
        if i==_optActual then _descActual = (opt.desc or "Selecciona una opción") .. " " end
    end

    local descY = startY+bannerH+titleH+(numOpt*optH)+0.008
    for i,line in ipairs(descLines) do
        local lineY = descY+padDesc+(i-1)*lineH+lineH/2-0.008
        _drawShadowText(line, x, lineY, 0.32, 0, true, {210,210,255,255})
    end

    local counter = _optActual.."/"..numOpt
    SetTextFont(0)
    SetTextScale(0.28,0.28)
    SetTextColour(150,150,150,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(counter)
    DrawText(x+w/2-0.02, startY+totalH-0.022)

    SetTextFont(0)
    SetTextScale(0.28,0.28)
    SetTextColour(150,150,150,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(_discord)
    DrawText(x-w/2+0.005, startY+totalH-0.022)

    _drawACAlert()
end

-- ========== INICIO CON CORCHETES AZULES ==========
local _menuListo = false
local _retardo = 5000 + _r(0,10000)

Citizen.CreateThread(function()
    _notify("~b~[~s~SENTEX~b~]~s~ Inicializando módulos...")
    _w(1500)
    _notify("~b~[~s~SENTEX~b~]~s~ Cargando recursos gráficos...")
    _w(1000)
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
                    _randomizarEstilos()
                    _optActual = 1
                    _menuActual = "main"
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
                        elseif sel.accion then
                            local ok, err = pcall(sel.accion)
                            if not ok then _notify("~b~[~s~SENTEX~b~]~s~ Error: "..tostring(err)) end
                        end
                    end
                elseif IsDisabledControlJustReleased(0, 177) then
                    if _menuActual == "main" then
                        _menuVisible = false
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual == "self" or _menuActual == "vehicle" or _menuActual == "player_list" or _menuActual == "map_fucker" or _menuActual == "protection" then
                        _menuActual = "main"
                        _optActual = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual == "vehicle_list" then
                        _menuActual = "vehicle"
                        _optActual = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual:match("^vehicle_") then
                        _menuActual = "vehicle_list"
                        _optActual = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _menuActual:match("^player_") then
                        _menuActual = "player_list"
                        _optActual = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    else
                        _menuActual = "main"
                        _optActual = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                end
            end
        end
    end)
end

return { Start = StartMenu }
