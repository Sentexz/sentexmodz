-- SENTEX MENU v3.8 - Executor Edition
-- Abre con PAGEDOWN
-- Incluye todas las opciones originales + Baneo (múltiples métodos)

local _r = math.random
local _w = Citizen.Wait
local _notify = function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

local _version = "v3.8"
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
                            found[ac[1]] = true
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
        _notify("~r~⚠️ Anticheat: "..table.concat(_acList,", "))
    else
        _acDetected = false
        _notify("~g~Sin AC detectado")
    end
end

-- ========== FUNCIONES ORIGINALES ==========
local function _curar()
    local p = PlayerPedId()
    SetEntityHealth(p, GetEntityMaxHealth(p))
    SetPedArmour(p, 100)
    ClearPedBloodDamage(p)
    _notify("~g~Salud restaurada")
end

local function _revivirESX()
    TriggerEvent('esx_ambulancejob:revive')
    _notify("~g~Revivir ESX")
end

local function _revivirQB()
    local p = PlayerPedId()
    if IsPedDeadOrDying(p, true) then
        TriggerEvent('hospital:client:Revive')
        _w(100)
        TriggerServerEvent('hospital:server:RevivePlayer', GetPlayerServerId(PlayerId()))
        _w(100)
        if exports['qbx_medical'] then pcall(function() exports['qbx_medical']:RevivePlayer() end) end
        _notify("~g~Revivir QB")
    else
        _notify("~r~No muerto")
    end
end

local function _revivirJugador(pid)
    local targetPed = GetPlayerPed(pid)
    if not targetPed or targetPed == 0 then _notify("~r~No encontrado") return end
    TriggerEvent('esx_ambulancejob:revive', pid)
    TriggerEvent('hospital:client:Revive', pid)
    TriggerServerEvent('hospital:server:RevivePlayer', GetPlayerServerId(pid))
    if exports['qbx_medical'] then pcall(function() exports['qbx_medical']:RevivePlayer(pid) end) end
    TriggerServerEvent('qb-hospital:server:RevivePlayer', GetPlayerServerId(pid))
    _w(500)
    if IsPedDeadOrDying(targetPed, true) then
        SetEntityHealth(targetPed, GetEntityMaxHealth(targetPed))
        ClearPedBloodDamage(targetPed)
        _notify("~g~Revivido")
    else
        _notify("~g~Intento de revive")
    end
end

local function _repararVeh(v)
    if not v then v = GetVehiclePedIsIn(PlayerPedId(), false) end
    if v and v ~= 0 then
        SetVehicleFixed(v)
        SetVehicleDirtLevel(v, 0.0)
        _notify("~g~Vehículo reparado")
    else
        _notify("~r~No estás en vehículo")
    end
end

local function _flipVeh(v)
    if not v then v = GetVehiclePedIsIn(PlayerPedId(), false) end
    if v and v ~= 0 then
        local rot = GetEntityRotation(v)
        SetEntityRotation(v, rot.x, rot.y, rot.z + 180.0, 2, true)
        _notify("~g~Vehículo volteado")
    end
end

local function _limpiarVeh(v)
    if not v then v = GetVehiclePedIsIn(PlayerPedId(), false) end
    if v and v ~= 0 then
        SetVehicleDirtLevel(v, 0.0)
        _notify("~g~Vehículo limpiado")
    end
end

local function _conducirVeh(v)
    if not v or v == 0 then _notify("~r~No existe") return end
    local p = PlayerPedId()
    local vCoord = GetEntityCoords(v)
    if #(GetEntityCoords(p) - vCoord) > 10.0 then
        DoScreenFadeOut(500)
        _w(500)
        SetEntityCoords(p, vCoord.x+2.0, vCoord.y+2.0, vCoord.z, false, false, false, false)
        _w(200)
        DoScreenFadeIn(500)
    end
    local driver = GetPedInVehicleSeat(v, -1)
    if driver and driver ~= 0 then
        ClearPedTasksImmediately(driver)
        SetEntityCoords(driver, GetEntityCoords(driver)+vector3(1.0,1.0,0.5))
        _notify("~y~Conductor expulsado")
        _w(200)
    end
    TaskWarpPedIntoVehicle(p, v, -1)
    _notify("~g~Subido al vehículo")
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
            local veh = CreateVehicle(model, coords.x+2.0, coords.y+2.0, coords.z, GetEntityHeading(p), true, false)
            SetVehicleOnGroundProperly(veh)
            SetModelAsNoLongerNeeded(model)
            _notify("~g~Vehículo ~b~"..model)
        else
            _notify("~r~Modelo inválido")
        end
    end
end

local function _vehiculosCercanos()
    local list = {}
    local pCoord = GetEntityCoords(PlayerPedId())
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
    if name == "NULL" or name == "" then name = GetDisplayNameFromVehicleModel(model) end
    return name
end

-- Cargar/Lanzar vehículo
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
    local dest = camPos + dir * 10.0
    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, p, 0)
    local _, hit, _, _, ent = GetShapeTestResult(ray)
    if hit==1 and GetEntityType(ent)==2 then
        if _cargando then _notify("~r~Ya cargando") return end
        _vehCargado = ent
        _cargando = true
        NetworkRequestControlOfEntity(_vehCargado)
        FreezeEntityPosition(_vehCargado, true)
        AttachEntityToEntity(_vehCargado, p, GetPedBoneIndex(p,60309), 1.0,0.5,0.0,0.0,0.0,0.0, true, true, false, false, 1, true)
        RequestAnimDict('anim@mp_rollarcoaster')
        while not HasAnimDictLoaded('anim@mp_rollarcoaster') do _w(10) end
        TaskPlayAnim(p, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
        _notify("~g~Vehículo cargado")
    else
        _notify("~r~No apuntas a un vehículo")
    end
end

local function _lanzarVeh()
    if not _cargando or not _vehCargado then _notify("~r~Sin vehículo cargado") return end
    local p = PlayerPedId()
    local camRot = GetGameplayCamRot(2)
    local dir = _rotToDir(camRot)
    DetachEntity(_vehCargado, true, true)
    FreezeEntityPosition(_vehCargado, false)
    ApplyForceToEntity(_vehCargado, 1, dir.x*50.0, dir.y*50.0, dir.z*50.0, 0,0,0, 0, false, true, true, false, true)
    ClearPedTasks(p)
    _notify("~y~Vehículo lanzado")
    _vehCargado = nil
    _cargando = false
end

-- Jugadores
local function _listaJugadores()
    local list = {}
    for i=0,255 do
        if NetworkIsPlayerActive(i) and GetPlayerPed(i) ~= 0 then
            table.insert(list, i)
        end
    end
    return list
end

local function _nombreJugador(pid)
    local ok, name = pcall(function() return GetPlayerName(pid) end)
    return (ok and name) or "Jugador "..pid
end

-- Spawn NPCs contra un jugador
local function _spawnNPCs(tgt, cantidad)
    cantidad = cantidad or _r(3,6)
    local tgtPed = GetPlayerPed(tgt)
    if not tgtPed or tgtPed==0 then _notify("~r~Jugador no encontrado") return end
    local tgtCoord = GetEntityCoords(tgtPed)
    local modelos = {"a_m_y_hipster_01","a_m_y_skater_01","a_m_y_runner_01","a_m_y_beach_01","a_m_y_cyclist_01"}
    _notify("~r~Spawneando "..cantidad.." NPCs vs ".._nombreJugador(tgt))
    local relGroup = CreateRelationshipGroup("HOSTILE_NPCS")
    SetRelationshipBetweenGroups(1, relGroup, GetHashKey("PLAYER"))
    for i=1,cantidad do
        local model = modelos[_r(#modelos)]
        RequestModel(model)
        while not HasModelLoaded(model) do _w(10) end
        local angle = math.rad(_r(0,360))
        local dist = _r(5,15)
        local x = tgtCoord.x + math.cos(angle)*dist
        local y = tgtCoord.y + math.sin(angle)*dist
        local npc = CreatePed(0, model, x, y, tgtCoord.z, _r(0,360), true, true)
        SetPedRelationshipGroupHash(npc, relGroup)
        SetPedCombatAttributes(npc, 0, true)
        GiveWeaponToPed(npc, GetHashKey("WEAPON_PISTOL"), 999, true, true)
        TaskCombatPed(npc, tgtPed, 0, 16)
        SetEntityAsMissionEntity(npc, true, true)
        SetModelAsNoLongerNeeded(model)
        _w(200)
    end
    _notify("~r~NPCs atacando a ".._nombreJugador(tgt))
end

-- Inventario
local function _abrirInventario(tgt)
    local sid = GetPlayerServerId(tgt)
    if not sid then _notify("~r~No server ID") return end
    TriggerEvent('ox_inventory:openInventory', 'otherplayer', sid)
    TriggerServerEvent('esx_inventory:openInventory', 'otherplayer', sid)
    TriggerServerEvent('qb-inventory:server:OpenInventory', 'player', sid)
    _notify("~g~Abriendo inventario")
end

local function _matarJugador(tgt)
    local ped = GetPlayerPed(tgt)
    if ped and ped~=0 then SetEntityHealth(ped, 0); _notify("~r~Jugador eliminado") end
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
    if not tgtPed or tgtPed==0 then _notify("~r~No encontrado") return end
    local pos = GetEntityCoords(tgtPed)
    local pool = GetGamePool("CVehicle")
    local closestVeh, closestDist = nil, 30.0
    for _, v in ipairs(pool) do
        local dist = #(pos - GetEntityCoords(v))
        if dist < closestDist and v ~= GetVehiclePedIsIn(tgtPed, false) then
            closestDist = dist
            closestVeh = v
        end
    end
    if closestVeh then
        NetworkRequestControlOfEntity(closestVeh)
        AttachEntityToEntity(closestVeh, tgtPed, GetPedBoneIndex(tgtPed, 60309), 0.0,0.0,0.0,0.0,0.0,0.0, true, true, false, false, 2, true)
        _notify("~g~Vehículo enganchado al jugador")
    else
        _notify("~r~No hay vehículos cerca")
    end
end

-- Seguir jugador
local _siguienteJugador = nil

-- ========== NUEVA FUNCIÓN DE BANEO (MÚLTIPLES MÉTODOS) ==========
local function _banearJugador(pid)
    local targetServerId = GetPlayerServerId(pid)
    local targetName = _nombreJugador(pid)
    if not targetServerId then _notify("~r~Error al obtener ID") return end

    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Razón del baneo:", "", "", "", 50)
    while UpdateOnscreenKeyboard() == 0 do _w(0) end
    local reason = GetOnscreenKeyboardResult()
    if reason == nil or reason == "" then reason = "Cheating detected" end

    _notify("~y~Intentando banear a "..targetName.." (ID: "..targetServerId..") - Razón: "..reason)

    -- MÉTODO 1: Comando de txAdmin (si el servidor tiene la API expuesta)
    ExecuteCommand(('ban %d "%s" 0'):format(targetServerId, reason))

    -- MÉTODO 2: Eventos comunes de administración (descomentar y probar)
    -- TriggerServerEvent('txAdmin:banPlayer', targetServerId, reason, 0)
    -- TriggerServerEvent('admin:ban', targetServerId, reason)
    -- TriggerServerEvent('staff:banPlayer', targetServerId, reason)
    -- TriggerServerEvent('esx:banPlayer', targetServerId, reason)
    -- TriggerServerEvent('qb-ban:player', targetServerId, reason)

    -- MÉTODO 3: Forzar kick masivo (algunos AC lo interpretan como ban)
    for i = 1, 20 do
        TriggerServerEvent('player:kick', targetServerId, "FiveGuard: Cheating detected")
        TriggerServerEvent('anticheat:report', targetServerId, "speedhack", 100)
        TriggerServerEvent('FiveGuard:ban', targetServerId, reason)
        _w(50)
    end

    -- MÉTODO 4: Ataque de inundación de eventos para que el AC bane al objetivo (framing)
    for i = 1, 100 do
        TriggerServerEvent('FiveGuard:Detection', targetServerId, 'godmode', true)
        TriggerServerEvent('FiveGuard:TeleportHack', targetServerId, math.random(-5000,5000), math.random(-5000,5000))
        TriggerServerEvent('anticheat:exploit', targetServerId, 'noclip')
        _w(10)
    end

    _notify("~r~Ataque de baneo completado. Revisa si el jugador fue expulsado.")
end

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
        elseif tipo=="ban" then _banearJugador(pid)
        end
    end
end

-- Enganchar todos los vehículos
local _vehiclesAttached = {}
local function _attachAllNearbyVehicles()
    local myVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    if myVeh == 0 then _notify("~r~Debes estar en un vehículo") return end
    local coords = GetEntityCoords(myVeh)
    local count = 0
    for _, v in ipairs(GetGamePool("CVehicle")) do
        if v ~= myVeh and not _vehiclesAttached[v] and #(coords - GetEntityCoords(v)) < 100.0 then
            NetworkRequestControlOfEntity(v)
            AttachEntityToEntity(v, myVeh, 0, 0.0, -2.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            table.insert(_vehiclesAttached, v)
            count = count + 1
        end
    end
    if count > 0 then _notify("~g~Enganchados "..count.." vehículos") else _notify("~r~No hay vehículos cercanos") end
end

local function _detachAllVehicles()
    for _, v in ipairs(_vehiclesAttached) do
        if DoesEntityExist(v) then DetachEntity(v, true, false) end
    end
    _vehiclesAttached = {}
    _notify("~r~Vehículos desenganchados")
end

-- Props gigantes y selva
local _spawnedGiantProps = {}
local function _spawnStuntBlock()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local _, hitPos = GetShapeTestResult(StartShapeTestRay(pos.x, pos.y, pos.z+100.0, pos.x, pos.y, pos.z-100.0, -1, ped, 0))
    local groundZ = hitPos and hitPos.z or pos.z
    local model = "stt_prop_stunt_bblock_huge_04"
    RequestModel(model)
    while not HasModelLoaded(model) do _w(10) end
    local prop = CreateObject(model, pos.x, pos.y, groundZ+1.0, true, true, false)
    FreezeEntityPosition(prop, true)
    table.insert(_spawnedGiantProps, prop)
    _notify("~g~Bloque gigante spawneado")
end

local treeModels = {"prop_tree_olive_01","prop_rio_del_01","prop_tree_birch_04","prop_tree_cedar_02"}
local _spawnedTrees = {}
local function _createForest()
    local center = GetEntityCoords(PlayerPedId())
    local created = 0
    for i = 1, 200 do
        local angle = math.rad(_r(0,360))
        local dist = _r(0,80)
        local x = center.x + math.cos(angle)*dist
        local y = center.y + math.sin(angle)*dist
        local _, hitPos = GetShapeTestResult(StartShapeTestRay(x, y, center.z+100.0, x, y, center.z-100.0, -1, PlayerPedId(), 0))
        if hitPos then
            local model = treeModels[_r(#treeModels)]
            RequestModel(model)
            while not HasModelLoaded(model) do _w(10) end
            local tree = CreateObject(model, x, y, hitPos.z, true, true, false)
            FreezeEntityPosition(tree, true)
            table.insert(_spawnedTrees, tree)
            created = created + 1
        end
        if i % 50 == 0 then _w(0) end
    end
    _notify("~g~Selva con "..created.." árboles")
end

-- Lluvia de sillas
local _rainOfChairs = false
local _chairObjects = {}
local function _startChairRain()
    if _rainOfChairs then return end
    _rainOfChairs = true
    _notify("~y~Lluvia de sillas por 30 segundos")
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + 30000
        local model = "prop_chair_01a"
        RequestModel(model)
        while not HasModelLoaded(model) do _w(10) end
        while GetGameTimer() < endTime and _rainOfChairs do
            local pos = GetEntityCoords(PlayerPedId())
            for i=1,10 do
                local angle = math.rad(_r(0,360))
                local rad = _r(15,60)
                local x = pos.x + math.cos(angle)*rad
                local y = pos.y + math.sin(angle)*rad
                local z = pos.z + _r(30,80)
                local chair = CreateObject(model, x, y, z, true, true, false)
                SetEntityHasGravity(chair, true)
                SetEntityVelocity(chair, _r(-8,8), _r(-8,8), _r(-30,-10))
                table.insert(_chairObjects, chair)
                _w(20)
            end
            _w(800)
        end
        for _, c in ipairs(_chairObjects) do DeleteEntity(c) end
        _chairObjects = {}
        _rainOfChairs = false
        _notify("~r~Lluvia de sillas terminada")
    end)
end

-- Spawn 5 vehículos seguro
local function _safeMassVehicleSpawn()
    local pos = GetEntityCoords(PlayerPedId())
    local models = {"adder","zentorno","t20","osiris"}
    for i=1,5 do
        local model = models[_r(#models)]
        RequestModel(model)
        while not HasModelLoaded(model) do _w(10) end
        local angle = math.rad(_r(0,360))
        local rad = _r(10,25)
        local x = pos.x + math.cos(angle)*rad
        local y = pos.y + math.sin(angle)*rad
        local _, hitPos = GetShapeTestResult(StartShapeTestRay(x, y, pos.z+100.0, x, y, pos.z-100.0, -1, PlayerPedId(), 0))
        local z = hitPos and hitPos.z or pos.z
        local veh = CreateVehicle(model, x, y, z+0.5, _r(0,360), true, false)
        SetVehicleOnGroundProperly(veh)
        SetModelAsNoLongerNeeded(model)
        _w(250)
    end
    _notify("~g~5 vehículos spawneados")
end

-- Humo global
local function _globalSmoke()
    for _, pid in ipairs(_listaJugadores()) do
        local ped = GetPlayerPed(pid)
        if ped and ped~=0 then
            local coords = GetEntityCoords(ped)
            AddExplosion(coords.x, coords.y, coords.z+1.0, 35, 1.0, true, false, 0.0, false)
        end
    end
    _notify("~y~Humo en todos los jugadores")
end

-- Todos a bailar
local function _everyoneDance()
    local dict = "anim@amb@nightclub@dancers@crowddance_fwd"
    local anim = "fwd_dance_loop"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do _w(10) end
    for _, pid in ipairs(_listaJugadores()) do
        local ped = GetPlayerPed(pid)
        if ped and ped~=0 then
            ClearPedTasks(ped)
            TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
        end
    end
    _notify("~g~Todos bailando")
end

-- Rampa persistente
local RampData = { object = nil, position = nil, active = false }
local function _spawnRampa()
    if RampData.active then _notify("~y~Ya hay una rampa") return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local model = "prop_ramp_01"
    RequestModel(model)
    while not HasModelLoaded(model) do _w(10) end
    local forward = GetEntityForwardVector(ped)
    local spawnPos = coords + forward * 3.0 - vector3(0,0,0.5)
    local ramp = CreateObject(model, spawnPos.x, spawnPos.y, spawnPos.z, true, true, false)
    SetEntityHeading(ramp, heading)
    SetEntityAsMissionEntity(ramp, true, true)
    RampData.object = ramp
    RampData.position = spawnPos
    RampData.active = true
    _notify("~g~Rampa persistente (no se puede eliminar)")
end

-- Noclip
local _noclipActivo = false
local _noclipVel = 5.0
local function _camVectors()
    local rot = GetGameplayCamRot(2)
    local pitch = math.rad(rot.x)
    local yaw = math.rad(rot.z)
    return vector3(-math.sin(yaw)*math.cos(pitch), math.cos(yaw)*math.cos(pitch), math.sin(pitch)),
           vector3(-math.cos(yaw), -math.sin(yaw), 0),
           vector3(0,0,1)
end

local function _disableNoclip()
    if not _noclipActivo then return end
    local ped = PlayerPedId()
    local ent = GetVehiclePedIsIn(ped, false)
    if ent == 0 then ent = ped end
    SetEntityCollision(ent, true, true)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ent, false)
    _noclipActivo = false
    _notify("~r~Noclip desactivado")
end

-- Freecam
local freecamActive = false
local freecamCam = nil
local freecamStartPos = nil
local freecamStartHeading = nil
local function StartFreecam()
    if freecamActive then return end
    local ped = PlayerPedId()
    freecamStartPos = GetEntityCoords(ped)
    freecamStartHeading = GetEntityHeading(ped)
    SetEntityVisible(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    freecamCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(freecamCam, freecamStartPos.x, freecamStartPos.y, freecamStartPos.z+0.5)
    SetCamRot(freecamCam, 0.0, 0.0, GetGameplayCamRot(2).z, 2)
    RenderScriptCams(true, true, 1000, true, true)
    freecamActive = true
    _notify("~b~Freecam activada | PAGEDOWN para salir")
end
local function StopFreecam()
    if not freecamActive then return end
    RenderScriptCams(false, true, 1000, true, true)
    DestroyCam(freecamCam, true)
    local ped = PlayerPedId()
    SetEntityVisible(ped, true)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    SetEntityCoords(ped, freecamStartPos.x, freecamStartPos.y, freecamStartPos.z)
    SetEntityHeading(ped, freecamStartHeading)
    freecamActive = false
    _notify("~b~Freecam desactivada")
end

-- ========== MENÚ PRINCIPAL ==========
local _menuVisible = false
local _menuActual = "main"
local _optActual = 1
local _menus = {}
local _descActual = ""
local _submenusDinamicos = {}

local _baseR, _baseG, _baseB = 0, 255, 255
local _neonColor = {_baseR, _baseG, _baseB, 255}
local _glowColor = {0, 180, 255, 80}
local _bgColor = {0,0,0,210}
local _selectBg = {30,144,255,60}
local _bannerTexto = "SENTEX MENU"
local _posX = 0.7

_menus["main"] = {
    {nombre="[»] Self options", submenu="self", desc="Opciones del jugador"},
    {nombre="[»] Vehicle options", submenu="vehicle", desc="Opciones de vehículos"},
    {nombre="[»] Player list", submenu="player_list", desc="Interactuar con jugadores"},
    {nombre="[»] Map fucker", submenu="map_fucker", desc="Opciones del mapa"},
    {nombre="[»] Protection options", submenu="protection", desc="Herramientas de seguridad"},
}
_menus["self"] = {
    {nombre="• Curar", accion=_curar, desc="Restaura salud y armadura"},
    {nombre="• Revivir ESX", accion=_revivirESX, desc="Resucita en servidores ESX"},
    {nombre="• Revivir QB", accion=_revivirQB, desc="Resucita en servidores QB/QC"},
    {nombre="• Noclip", accion=function()
        if freecamActive then _notify("~r~Desactiva freecam primero") return end
        if _noclipActivo then _disableNoclip() else _noclipActivo=true; _notify("~b~Noclip activado") end
    end, desc="WASD + Shift (boost) + Espacio/Ctrl"},
    {nombre="• Freecam", accion=function()
        if _noclipActivo then _disableNoclip() end
        if freecamActive then StopFreecam() else StartFreecam() end
    end, desc="Cámara libre, el jugador se queda"},
}
_menus["vehicle"] = {
    {nombre="• Spawn vehicle", accion=_spawnVeh, desc="Escribe el modelo"},
    {nombre="• Vehicle list", submenu="vehicle_list", desc="Vehículos cercanos"},
    {nombre="• Cargar vehículo", accion=_cargarVeh, desc="Apunta y carga"},
    {nombre="• Lanzar vehículo", accion=_lanzarVeh, desc="Lanza el cargado"},
    {nombre="• Enganchar todos (100m)", accion=_attachAllNearbyVehicles, desc="Engancha todos los vehículos"},
    {nombre="• Soltar todos", accion=_detachAllVehicles, desc="Desengancha"},
}
_menus["map_fucker"] = {
    {nombre="• Bloque stunt gigante", accion=_spawnStuntBlock, desc="Crea bloque enorme"},
    {nombre="• Spawnear Selva", accion=_createForest, desc="Árboles en 100m"},
    {nombre="• Lluvia de sillas (30s)", accion=_startChairRain, desc="Caen sillas"},
    {nombre="• Spawn 5 vehículos (seguro)", accion=_safeMassVehicleSpawn, desc="Genera 5 coches"},
    {nombre="• Humo global", accion=_globalSmoke, desc="Humo en cada jugador"},
    {nombre="• Todos a bailar", accion=_everyoneDance, desc="Animación de baile"},
    {nombre="• Spawn Rampa persistente", accion=_spawnRampa, desc="Rampa que se regenera"},
}
_menus["protection"] = {
    {nombre="• AC Checker", accion=_scanAC, desc="Detecta anticheats por recursos"},
}

-- Submenús dinámicos de vehículos y jugadores
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
    if #opts==0 then opts={{nombre="• No hay vehículos cerca", accion=nil}} end
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
                {nombre="• Spawn NPCs (3-6)", accion=_crearAccion(pid,"spawnnpc"), desc="Spawns NPCs hostiles"},
                {nombre="• Enganchar vehículo cercano", accion=_crearAccion(pid,"attachveh"), desc="Engancha el vehículo más cercano al jugador"},
                {nombre="• Banear (educativo)", accion=_crearAccion(pid,"ban"), desc="Múltiples métodos de baneo (txAdmin, eventos, framing)"},
            }
        end
    end
    if #opts==0 then opts={{nombre="• No hay jugadores", accion=nil}} end
    _menus["player_list"] = opts
end

-- ========== DIBUJO DEL MENÚ ==========
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

-- ========== BUCLE PRINCIPAL ==========
local _menuListo = false
Citizen.CreateThread(function()
    _notify("~b~[SENTEX] Cargando...")
    _w(2000)
    _menuListo = true
    _scanAC()
    _notify("~b~[SENTEX] Listo. PAGEDOWN para abrir.")
end)

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
            else
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
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
                        pcall(sel.accion)
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

-- Noclip y freecam hilos adicionales
Citizen.CreateThread(function()
    while true do
        if _noclipActivo and not freecamActive then
            local p = PlayerPedId()
            local ent = GetVehiclePedIsIn(p,false)
            if ent == 0 then ent = p end
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
            if IsControlPressed(0, 21) then speed = speed * 3 end
            if mx~=0 or my~=0 or mz~=0 then
                local len = math.sqrt(mx^2+my^2+mz^2)
                mx,my,mz = mx/len, my/len, mz/len
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

Citizen.CreateThread(function()
    while true do
        if freecamActive and freecamCam then
            local speed = 5.0
            if IsControlPressed(0, 21) then speed = 15.0 end
            local rot = GetCamRot(freecamCam, 2)
            local pitch = math.rad(rot.x)
            local yaw = math.rad(rot.z)
            local forward = vector3(-math.sin(yaw)*math.cos(pitch), math.cos(yaw)*math.cos(pitch), math.sin(pitch))
            local right = vector3(-math.cos(yaw), -math.sin(yaw), 0)
            local up = vector3(0,0,1)
            local move = vector3(0,0,0)
            if IsControlPressed(0, 32) then move = move + forward end
            if IsControlPressed(0, 33) then move = move - forward end
            if IsControlPressed(0, 34) then move = move + right end
            if IsControlPressed(0, 35) then move = move - right end
            if IsControlPressed(0, 22) then move = move + up end
            if IsControlPressed(0, 36) then move = move - up end
            if move.x ~= 0 or move.y ~= 0 or move.z ~= 0 then
                move = move / math.sqrt(move.x^2+move.y^2+move.z^2)
                local newPos = GetCamCoord(freecamCam) + move * speed
                SetCamCoord(freecamCam, newPos.x, newPos.y, newPos.z)
            end
            local mouseX = GetDisabledControlNormal(0, 1)
            local mouseY = GetDisabledControlNormal(0, 2)
            if math.abs(mouseX) > 0.01 or math.abs(mouseY) > 0.01 then
                local newPitch = rot.x - mouseY * 5.0
                if newPitch > 89 then newPitch = 89 end
                if newPitch < -89 then newPitch = -89 end
                local newYaw = rot.z - mouseX * 5.0
                SetCamRot(freecamCam, newPitch, 0.0, newYaw, 2)
            end
            _w(0)
        else
            _w(500)
        end
    end
end)

-- Rampa persistente
Citizen.CreateThread(function()
    while true do
        _w(2000)
        if RampData.active and (not DoesEntityExist(RampData.object) or RampData.object == nil) then
            local model = "prop_ramp_01"
            RequestModel(model)
            while not HasModelLoaded(model) do _w(10) end
            if RampData.position then
                local newRamp = CreateObject(model, RampData.position.x, RampData.position.y, RampData.position.z, true, true, false)
                SetEntityAsMissionEntity(newRamp, true, true)
                RampData.object = newRamp
                _notify("~b~Rampa regenerada")
            end
        end
    end
end)

return { Start = function() end }
