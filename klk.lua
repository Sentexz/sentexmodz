--[[
    SENTEX MENU - v3.6 (enganche vehículos) [ANTI-FIRMA SUTIL + FREECAM ZPROMISE]
    Abre con PAGEDOWN - Carga diferida 5-15s
--]]

-- ========== OFUSCACIÓN INICIAL ==========
local _r = math.random
local _w = Citizen.Wait
local _notify = function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

-- ========== CONFIGURACIÓN ==========
local _version = "v3.6 (enganchar vehículo de jugador)"
local _discord = ".gg/sentexmodz"

-- ========== DETECCIÓN DE ANTICHEAT (solo aviso) ==========
local _acDetected = false
local _acList = {}

local _acDB = {
    {"WaveShield", {"waveshield","ws_core","ws_anticheat"}},
    {"FiveGuard", {"fiveguard","fg_","fg_anticheat"}},
    {"ElectronAC", {"electronac","electron_","eac"}},
    {"Likizao", {"likizao","lkz","likizao_anticheat"}},
    {"Eulen", {"eulen","eulencheat","eulen_anticheat"}},
    {"RedEngine", {"redengine","red_anticheat","reac"}},
    {"InfinityAC", {"infinityac","infinity_","iac"}},
    {"PhoenixAC", {"phoenixac","phoenix_anticheat"}},
    {"VexAC", {"vexac","vex_anticheat"}},
    {"NexusAC", {"nexusac","nexus_anticheat"}}
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
                        if name:find(p) then found[ac[1]] = true end
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

-- ========== ACCIONES (TODAS ACTIVAS) ==========
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
    DisplayOnscreenKeyboard(1,"FMMC_KEY_TIP8","","Modelo (ej: adder)","","","",30)
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
        if v ~= 0 and #(pCoord - GetEntityCoords(v)) < 50.0 then
            table.insert(list, v)
        end
    end
    return list
end

local function _nombreVeh(v)
    local model = GetEntityModel(v)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if name == "NULL" then name = string.upper(GetDisplayNameFromVehicleModel(model)) end
    return name
end

-- CARGAR/LANZAR VEHÍCULO
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
    local force = 40.0
    ApplyForceToEntity(_vehCargado, 1, dir.x*force, dir.y*force, dir.z*force, 0.0,0.0,0.0, 0, false, true, true, false, true)
    ClearPedTasks(p)
    _notify("~y~Vehículo lanzado")
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

local function _spawnNPC(tgt)
    local tgtPed = GetPlayerPed(tgt)
    if not tgtPed or tgtPed==0 then _notify("~r~Jugador no encontrado") return end
    local tgtCoord = GetEntityCoords(tgtPed)
    local model = "a_m_y_hipster_01"
    RequestModel(model)
    while not HasModelLoaded(model) do _w(10) end
    local spawn = vector3(tgtCoord.x+10.0, tgtCoord.y+10.0, tgtCoord.z)
    local npc = CreatePed(0, model, spawn.x, spawn.y, spawn.z, 0.0, true, true)
    SetPedCombatAttributes(npc, 0, true)
    SetPedCombatAbility(npc, 100)
    SetPedAccuracy(npc, 60)
    SetPedArmour(npc, 50)
    SetPedCanRagdoll(npc, true)
    GiveWeaponToPed(npc, GetHashKey("WEAPON_PISTOL"), 999, true, true)
    SetPedInfiniteAmmo(npc, true)
    TaskGoToEntity(npc, tgtPed, -1, 2.0, 5.0, 1073741824, 0)
    _w(3000)
    TaskCombatPed(npc, tgtPed, 0, 16)
    SetEntityAsMissionEntity(npc, true, true)
    SetModelAsNoLongerNeeded(model)
    _notify("~r~NPC hostil spawneado cerca del jugador")
end

local function _abrirInventario(tgt)
    local sid = GetPlayerServerId(tgt)
    if sid then
        TriggerEvent('ox_inventory:openInventory', 'otherplayer', sid)
        _notify("~g~Abriendo inventario del jugador")
    else
        _notify("~r~No se pudo obtener Server ID")
    end
end

local function _darDinero(tgt)
    TriggerServerEvent('esx:giveMoney', tgt, 10000)
    _notify("~g~Se han dado 10k al jugador")
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

local function _engancharVehJugador(tgt)
    local myPed = PlayerPedId()
    local myVeh = GetVehiclePedIsIn(myPed, false)
    if myVeh == 0 then _notify("~r~Debes estar en un vehículo") return end
    local tgtPed = GetPlayerPed(tgt)
    if not tgtPed or tgtPed==0 then _notify("~r~Jugador no encontrado") return end
    local tgtVeh = GetVehiclePedIsIn(tgtPed, false)
    if tgtVeh == 0 then _notify("~r~El jugador no está en un vehículo") return end
    if tgtVeh == myVeh then _notify("~r~No puedes enganchar tu propio vehículo") return end
    if not NetworkHasControlOfEntity(tgtVeh) then
        NetworkRequestControlOfEntity(tgtVeh)
        local t=0
        while not NetworkHasControlOfEntity(tgtVeh) and t<20 do _w(50) t=t+1 end
    end
    AttachEntityToEntity(tgtVeh, myVeh, 0, 0.0, -2.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    _notify("~g~Vehículo enganchado al tuyo")
end

local _siguienteJugador = nil

local function _crearAccion(pid, tipo)
    return function()
        if tipo=="inventory" then _abrirInventario(pid)
        elseif tipo=="money" then _darDinero(pid)
        elseif tipo=="revive" then
            TriggerEvent('esx_ambulancejob:revive', pid)
            TriggerEvent('hospital:client:Revive', pid)
            _notify("~g~Reviviendo jugador")
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
        elseif tipo=="spawnnpc" then _spawnNPC(pid)
        elseif tipo=="attachveh" then _engancharVehJugador(pid)
        end
    end
end

-- MAP FUCKER (Attach cars, la freecam se reemplaza)
local _attachActivo = false
local _vehsEnganchados = {}

local function _toggleAttach()
    local p = PlayerPedId()
    local veh = GetVehiclePedIsIn(p, false)
    if veh == 0 then _notify("~r~Debes estar en un vehículo") return end
    if not _attachActivo then
        local coord = GetEntityCoords(veh)
        local pool = GetGamePool("CVehicle")
        local cnt = 0
        for _,v in ipairs(pool) do
            if v ~= veh then
                if #(coord - GetEntityCoords(v)) < 150.0 then
                    if not NetworkHasControlOfEntity(v) then
                        NetworkRequestControlOfEntity(v)
                        local t=0
                        while not NetworkHasControlOfEntity(v) and t<20 do _w(50) t=t+1 end
                    end
                    AttachEntityToEntity(v, veh, 0, 0.0, -2.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    table.insert(_vehsEnganchados, v)
                    cnt = cnt+1
                end
            end
        end
        if cnt>0 then
            _attachActivo = true
            _notify("~g~Enganchados "..cnt.." vehículos")
        else
            _notify("~r~No hay vehículos en 150 metros")
        end
    else
        for _,v in ipairs(_vehsEnganchados) do
            if DoesEntityExist(v) then DetachEntity(v, true, false) end
        end
        _vehsEnganchados = {}
        _attachActivo = false
        _notify("~r~Vehículos desenganchados")
    end
end

-- ========== NUEVA FREECAM ZPROMISE (extraída y adaptada) ==========
local freecamActive = false
local freecamHandle = nil
local freecamTargetCoords = nil
local freecamTargetEntity = nil
local freecamCurrentFeatureIndex = 1
local freecamPedsToSpawn = { "s_m_m_movalien_01", "u_m_y_zombie_01", "s_m_y_blackops_01", "csb_abigail", "a_c_coyote" }
local freecamCurrentPedIndex = 1
local freecamFeatures = {
    "Look-Around",
    "Spawn Ped",
    "Teleport",
    "Delete Entity",
    "Fling Entity",
    "Flip Vehicle",
    "Launch Vehicle",
    "Teleport Vehicle",
    "Mess With Vehicle"
}

-- Helper: dibujar texto en pantalla
local function freecamDrawText(content, x, y, options)
    SetTextFont(options.font or 4)
    SetTextScale(0.0, options.scale or 0.3)
    SetTextColour(options.color[1], options.color[2], options.color[3], options.color[4])
    SetTextOutline()
    if options.shadow then SetTextDropShadow(2, 0, 0, 0, 255) end
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(content)
    EndTextCommandDisplayText(x, y)
end

-- Hilo de dibujo de la interfaz de la freecam
local function freecamDrawThread()
    while freecamActive do
        Citizen.Wait(0)
        -- Mira
        freecamDrawText("•", 0.5, 0.485, {font = 4, scale = 0.5, color = {255,255,255,200}})

        local ui = { x = 0.5, y = 0.75, lineHeight = 0.03, maxVisible = 7, colors = { text = {245,245,245,120}, selected = {52,152,219,255} } }
        local numFeatures = #freecamFeatures
        local startIdx, endIdx = 1, numFeatures

        if numFeatures > ui.maxVisible then
            startIdx = math.max(1, freecamCurrentFeatureIndex - math.floor(ui.maxVisible / 2))
            endIdx = math.min(numFeatures, startIdx + ui.maxVisible - 1)
            if endIdx == numFeatures then
                startIdx = numFeatures - ui.maxVisible + 1
            end
        end

        freecamDrawText(("%d/%d"):format(freecamCurrentFeatureIndex, numFeatures), ui.x, ui.y - 0.035, {scale = 0.25, color = {255,255,255,120}})

        local displayCount = 0
        for i = startIdx, endIdx do
            local featureName = freecamFeatures[i]
            local isSelected = (i == freecamCurrentFeatureIndex)
            local lineY = ui.y + (displayCount * ui.lineHeight)
            if isSelected then
                freecamDrawText(("[ %s ]"):format(featureName), ui.x, lineY, {scale = 0.32, color = ui.colors.selected, shadow = true})
            else
                freecamDrawText(featureName, ui.x, lineY, {scale = 0.28, color = ui.colors.text})
            end
            displayCount = displayCount + 1
        end
    end
end

-- Hilo de lógica (cambiar función, acción al hacer clic)
local function freecamLogicThread()
    while freecamActive do
        Citizen.Wait(0)
        -- Cambiar función con flechas izquierda/derecha
        if IsDisabledControlJustPressed(0, 241) then -- flecha izquierda
            freecamCurrentFeatureIndex = (freecamCurrentFeatureIndex - 2 + #freecamFeatures) % #freecamFeatures + 1
        elseif IsDisabledControlJustPressed(0, 242) then -- flecha derecha
            freecamCurrentFeatureIndex = (freecamCurrentFeatureIndex % #freecamFeatures) + 1
        end

        -- Acción al hacer clic izquierdo
        if IsDisabledControlJustPressed(0, 24) then
            local currentFeature = freecamFeatures[freecamCurrentFeatureIndex]
            if currentFeature == "Teleport" and freecamTargetCoords then
                local ped = PlayerPedId()
                local found, z = GetGroundZFor_3dCoord(freecamTargetCoords.x, freecamTargetCoords.y, freecamTargetCoords.z + 1.0, false)
                SetEntityCoords(ped, freecamTargetCoords.x, freecamTargetCoords.y, found and z + 1.0 or freecamTargetCoords.z, false, false, false, true)
            elseif currentFeature == "Spawn Ped" and freecamTargetCoords then
                local model = freecamPedsToSpawn[freecamCurrentPedIndex]
                Citizen.CreateThread(function()
                    local modelHash = GetHashKey(model)
                    RequestModel(modelHash)
                    local timeout = 2000
                    while not HasModelLoaded(modelHash) and timeout > 0 do
                        Citizen.Wait(100)
                        timeout = timeout - 100
                    end
                    if HasModelLoaded(modelHash) then
                        local found, z = GetGroundZFor_3dCoord(freecamTargetCoords.x, freecamTargetCoords.y, freecamTargetCoords.z, false)
                        local spawnPos = vector3(freecamTargetCoords.x, freecamTargetCoords.y, found and z + 1.0 or freecamTargetCoords.z)
                        local newPed = CreatePed(4, modelHash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)
                        SetModelAsNoLongerNeeded(modelHash)
                        TaskStandStill(newPed, -1)
                        freecamCurrentPedIndex = (freecamCurrentPedIndex % #freecamPedsToSpawn) + 1
                    end
                end)
            elseif currentFeature == "Delete Entity" and freecamTargetEntity and DoesEntityExist(freecamTargetEntity) then
                SetEntityAsMissionEntity(freecamTargetEntity, true, true)
                DeleteEntity(freecamTargetEntity)
            elseif currentFeature == "Fling Entity" and freecamTargetEntity and (IsEntityAPed(freecamTargetEntity) or IsEntityAVehicle(freecamTargetEntity)) then
                ApplyForceToEntity(freecamTargetEntity, 1, math.random(-50.0, 50.0), math.random(-50.0, 50.0), 50.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            elseif currentFeature == "Flip Vehicle" and freecamTargetEntity and IsEntityAVehicle(freecamTargetEntity) then
                SetVehicleOnGroundProperly(freecamTargetEntity)
            elseif currentFeature == "Launch Vehicle" and freecamTargetEntity and IsEntityAVehicle(freecamTargetEntity) then
                ApplyForceToEntity(freecamTargetEntity, 1, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            elseif currentFeature == "Teleport Vehicle" and freecamTargetEntity and IsEntityAVehicle(freecamTargetEntity) then
                local currentCoords = GetEntityCoords(freecamTargetEntity)
                local newCoords = currentCoords + GetEntityForwardVector(freecamTargetEntity) * 5.0 + vector3(0.0, 0.0, 50.0)
                SetEntityCoords(freecamTargetEntity, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
            elseif currentFeature == "Mess With Vehicle" and freecamTargetEntity and IsEntityAVehicle(freecamTargetEntity) then
                local actions = {
                    function(veh) SetVehicleTyreBurst(veh, math.random(0, 5), false, 1000.0) end,
                    function(veh) SetVehicleDoorOpen(veh, math.random(0, 5), false, false) end,
                    function(veh) SetVehicleEngineOn(veh, not IsVehicleEngineOn(veh), false, true) end,
                    function(veh) SetVehicleLights(veh, math.random(0, 2)) end,
                    function(veh) StartVehicleHorn(veh, 1000, "HELDDOWN", false) end
                }
                local randomAction = actions[math.random(#actions)]
                randomAction(freecamTargetEntity)
            end
        end
    end
end

-- Hilo de movimiento de cámara
local function freecamCameraThread()
    local baseSpeed, boostSpeed, slowSpeed = 1.0, 9.0, 0.1
    local mouseSensitivity = 7.5

    local function clamp(val, min, max)
        return math.max(min, math.min(max, val))
    end

    local function rotToDir(rot)
        local rX, rZ = math.rad(rot.x), math.rad(rot.z)
        return vector3(-math.sin(rZ) * math.cos(rX), math.cos(rZ) * math.cos(rX), math.sin(rX))
    end

    while freecamActive do
        Citizen.Wait(0)
        local camPos = GetCamCoord(freecamHandle)
        local camRotRaw = GetCamRot(freecamHandle, 2)
        local camRot = { x = camRotRaw.x, y = camRotRaw.y, z = camRotRaw.z }
        local direction = rotToDir(camRot)
        local right = vector3(direction.y, -direction.x, 0)

        local speed = baseSpeed
        if IsDisabledControlPressed(0, 21) then speed = boostSpeed end
        if IsDisabledControlPressed(0, 19) then speed = slowSpeed end

        if IsDisabledControlPressed(0, 32) then camPos = camPos + direction * speed end
        if IsDisabledControlPressed(0, 33) then camPos = camPos - direction * speed end
        if IsDisabledControlPressed(0, 34) then camPos = camPos - right * speed end
        if IsDisabledControlPressed(0, 35) then camPos = camPos + right * speed end
        if IsDisabledControlPressed(0, 22) then camPos = camPos + vector3(0, 0, 1.0) * speed end
        if IsDisabledControlPressed(0, 36) then camPos = camPos - vector3(0, 0, 1.0) * speed end

        local mX = GetDisabledControlNormal(0, 1) * mouseSensitivity
        local mY = GetDisabledControlNormal(0, 2) * mouseSensitivity
        camRot.x = clamp(camRot.x - mY, -89.0, 89.0)
        camRot.z = camRot.z - mX

        SetCamCoord(freecamHandle, camPos.x, camPos.y, camPos.z)
        SetCamRot(freecamHandle, camRot.x, camRot.y, camRot.z, 2)
        SetFocusPosAndVel(camPos.x, camPos.y, camPos.z, 0.0, 0.0, 0.0)

        local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z,
            camPos.x + direction.x * 1000.0,
            camPos.y + direction.y * 1000.0,
            camPos.z + direction.z * 1000.0,
            -1, PlayerPedId(), 7)
        local _, hit, coords, _, entity = GetShapeTestResult(ray)
        if hit then
            freecamTargetCoords, freecamTargetEntity = coords, entity
        else
            freecamTargetCoords, freecamTargetEntity = nil, nil
        end
    end
end

-- Función para activar freecam
local function freecamStart()
    if freecamActive then return end
    freecamActive = true
    local startPos = GetGameplayCamCoord()
    local startRot = GetGameplayCamRot(2)
    local startFov = GetGameplayCamFov()
    freecamHandle = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", startPos.x, startPos.y, startPos.z, startRot.x, startRot.y, startRot.z, startFov, true, 2)
    if not DoesCamExist(freecamHandle) then
        freecamActive = false
        return
    end
    RenderScriptCams(true, false, 0, true, true)
    SetCamActive(freecamHandle, true)
    Citizen.CreateThread(freecamDrawThread)
    Citizen.CreateThread(freecamLogicThread)
    Citizen.CreateThread(freecamCameraThread)
end

-- Función para desactivar freecam
local function freecamStop()
    if not freecamActive then return end
    freecamActive = false
    if freecamHandle and DoesCamExist(freecamHandle) then
        SetCamActive(freecamHandle, false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(freecamHandle, false)
    end
    Citizen.Wait(10)
    SetFocusEntity(PlayerPedId())
    ClearFocus()
    freecamHandle = nil
end

-- Toggle llamada desde el menú
local function _toggleFreecam()
    if freecamActive then
        freecamStop()
        _notify("~b~Freecam DESACTIVADA")
    else
        freecamStart()
        _notify("~b~Freecam ACTIVADA (Zpromise style)")
        _notify("~w~Flechas ← → para cambiar función | Click izquierdo para ejecutar")
    end
end

-- NOCLIP
local _noclipActivo = false
local _noclipVel = 5.0
local _boostMult = 3.0
local _noclipKeys = {fwd=32, back=33, left=34, right=35, boost=21, up=22, down=36}

local function _camVectors()
    local rot = GetGameplayCamRot(2)
    local pitch = math.rad(rot.x)
    local yaw = math.rad(rot.z)
    local cosP = math.cos(pitch)
    local sinP = math.sin(pitch)
    local cosY = math.cos(yaw)
    local sinY = math.sin(yaw)
    local fwd = vector3(-sinY*cosP, cosY*cosP, sinP)
    local right = vector3(-cosY, -sinY, 0.0)
    local up = vector3(0.0, 0.0, 1.0)
    return fwd, right, up
end

Citizen.CreateThread(function()
    while true do
        if _noclipActivo then
            local p = PlayerPedId()
            local veh = GetVehiclePedIsIn(p, false)
            local ent = (veh~=0 and veh) or p
            SetEntityCollision(ent, false, false)
            SetEntityInvincible(p, true)
            FreezeEntityPosition(ent, false)
            SetEntityVelocity(ent, 0.0, 0.0, 0.0)
            local mx,my,mz = 0.0,0.0,0.0
            if IsControlPressed(0, _noclipKeys.fwd) then my=my+1.0 end
            if IsControlPressed(0, _noclipKeys.back) then my=my-1.0 end
            if IsControlPressed(0, _noclipKeys.left) then mx=mx+1.0 end
            if IsControlPressed(0, _noclipKeys.right) then mx=mx-1.0 end
            if IsControlPressed(0, _noclipKeys.up) then mz=mz+1.0 end
            if IsControlPressed(0, _noclipKeys.down) then mz=mz-1.0 end
            local speed = _noclipVel
            if IsControlPressed(0, _noclipKeys.boost) then speed = speed * _boostMult end
            if mx~=0 or my~=0 or mz~=0 then
                local len = math.sqrt(mx*mx + my*my + mz*mz)
                if len>0 then mx,my,mz = mx/len, my/len, mz/len end
                local fwd, right, up = _camVectors()
                local delta = (fwd*my) + (right*mx) + (up*mz)
                delta = delta * speed
                local newCoord = GetEntityCoords(ent) + delta
                SetEntityCoords(ent, newCoord.x, newCoord.y, newCoord.z, false, false, false, false)
            end
            _w(0)
        else
            _w(500)
        end
    end
end)

-- ========== MENÚ CON VARIACIÓN SUTIL DE COLORES ==========
local _menuVisible = false
local _menuActual = "main"
local _optActual = 1
local _menus = {}
local _descActual = ""
local _submenusDinamicos = {}

-- Colores base
local _baseR, _baseG, _baseB = 0, 255, 255
local function _variarSutil(valor)
    local offset = _r(-2, 2)
    local nuevo = valor + offset
    if nuevo < 0 then nuevo = 0 end
    if nuevo > 255 then nuevo = 255 end
    return nuevo
end

local _neonColor = {_baseR, _baseG, _baseB, 255}
local _glowColor = {0, 180, 255, 80}
local _bgColor = {0, 0, 0, 210}
local _selectBg = {30, 144, 255, 60}
local _bannerTexto = "SENTEX MENU"
local _posX = 0.7

local function _randomizarEstilos()
    _neonColor = {_variarSutil(_baseR), _variarSutil(_baseG), _variarSutil(_baseB), 255}
    _glowColor = {_variarSutil(0), _variarSutil(180), _variarSutil(255), 80}
    _selectBg = {_variarSutil(30), _variarSutil(144), _variarSutil(255), 60}
    _posX = 0.7 + (_r(-2,2) / 100)
    local banners = {"SENTEX MENU", "SENTEX", "SX MENU", "SENTEX v3.6"}
    _bannerTexto = banners[_r(#banners)]
end

-- ESTRUCTURA DEL MENÚ
_menus["main"] = {
    {nombre="[»] Self options", submenu="self", desc="Opciones del jugador"},
    {nombre="[»] Vehicle options", submenu="vehicle", desc="Opciones para vehículos"},
    {nombre="[»] Player list", submenu="player_list", desc="Interactuar con otros jugadores"},
    {nombre="[»] Map fucker", submenu="map_fucker", desc="Opciones del mapa"},
    {nombre="[»] Protection options", submenu="protection", desc="Herramientas de seguridad"},
}

_menus["self"] = {
    {nombre="• Curar", accion=_curar, desc="Restaura salud y armadura"},
    {nombre="• Revivir ESX", accion=_revivirESX, desc="Resucita en servidores ESX"},
    {nombre="• Revivir QB", accion=_revivirQB, desc="Resucita en servidores QB/QC"},
    {nombre="• Noclip", accion=function()
        _noclipActivo = not _noclipActivo
        if _noclipActivo then _notify("~b~Noclip ACTIVADO")
        else
            local p=PlayerPedId()
            local v=GetVehiclePedIsIn(p,false)
            local e=(v~=0 and v) or p
            SetEntityCollision(e, true, true)
            SetEntityInvincible(p, false)
            _notify("~r~Noclip DESACTIVADO")
        end
    end, desc="Atraviesa paredes. Controles: WASD, Shift (boost), Espacio (subir), Ctrl (bajar)"},
}

_menus["vehicle"] = {
    {nombre="• Spawn vehicle", accion=_spawnVeh, desc="Escribe el modelo y spawnea el coche"},
    {nombre="• Vehicle list", submenu="vehicle_list", desc="Lista de vehículos cercanos"},
    {nombre="• Cargar vehículo", accion=_cargarVeh, desc="Apunta y carga un vehículo"},
    {nombre="• Lanzar vehículo", accion=_lanzarVeh, desc="Lanza el vehículo cargado"},
}

_menus["map_fucker"] = {
    {nombre="• Attach cars", accion=_toggleAttach, desc="Engancha vehículos cercanos (150m)"},
    {nombre="• Freecam", accion=_toggleFreecam, desc="Cámara libre estilo Zpromise (menú flotante, teletransporte, spawn ped, etc.)"},
}

_menus["protection"] = {
    {nombre="• AC Checker", accion=function()
        _notify("~y~Escaneando recursos del servidor...")
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
                                if name:find(p) then found[ac[1]]=true end
                            end
                        end
                    end
                    _w(0)
                end
            end
            if next(found) then
                _acDetected=true
                _acList={}
                for name,_ in pairs(found) do table.insert(_acList,name) end
                _notify("~r~⚠️ ANTICHEAT DETECTADO: ~y~"..table.concat(_acList,", ").."~s~")
                _notify("~r~Extrema precaución. El uso es bajo tu responsabilidad.")
            else
                _acDetected=false
                _acList={}
                _notify("~g~No se detectaron anticheats conocidos")
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
        opts[i] = {
            nombre="• "..dname,
            submenu="vehicle_"..tostring(v),
            desc="Opciones para "..dname,
            vehicle=v
        }
        if not _submenusDinamicos["vehicle_"..tostring(v)] then
            _submenusDinamicos["vehicle_"..tostring(v)] = {
                {nombre="• Reparar", accion=function() _repararVeh(v) end, desc="Repara este vehículo"},
                {nombre="• Voltear", accion=function() _flipVeh(v) end, desc="Voltea este vehículo"},
                {nombre="• Limpiar", accion=function() _limpiarVeh(v) end, desc="Limpia este vehículo"},
                {nombre="• Conducir", accion=function() _conducirVeh(v) end, desc="Subirte (expulsa conductor)"},
            }
        end
    end
    if #opts==0 then opts={{nombre="• No hay vehículos cerca", accion=nil, desc="Acércate a algún vehículo"}} end
    _menus["vehicle_list"] = opts
end

local function _refrescarListaJugadores()
    local players = _listaJugadores()
    local opts = {}
    for i,pid in ipairs(players) do
        local name = _nombreJugador(pid)
        opts[i] = {
            nombre="• "..name,
            submenu="player_"..tostring(pid),
            desc="Opciones para "..name,
            player=pid
        }
        if not _submenusDinamicos["player_"..tostring(pid)] then
            _submenusDinamicos["player_"..tostring(pid)] = {
                {nombre="• Abrir inventario", accion=_crearAccion(pid,"inventory"), desc="Abre inventario ESX/ox"},
                {nombre="• Dar dinero (10k)", accion=_crearAccion(pid,"money"), desc="Da 10.000$ (ESX)"},
                {nombre="• Revivir", accion=_crearAccion(pid,"revive"), desc="Intenta revivir"},
                {nombre="• Matar", accion=_crearAccion(pid,"kill"), desc="Mata al jugador"},
                {nombre="• Seguir", accion=_crearAccion(pid,"follow"), desc="Sigue al jugador"},
                {nombre="• Teleportar", accion=_crearAccion(pid,"teleport"), desc="Teletransportarse a él"},
                {nombre="• Spawn NPC agresivo", accion=_crearAccion(pid,"spawnnpc"), desc="NPC que atacará al jugador"},
                {nombre="• Enganchar su vehículo", accion=_crearAccion(pid,"attachveh"), desc="Engancha su vehículo al tuyo"},
            }
        end
    end
    if #opts==0 then opts={{nombre="• No hay jugadores", accion=nil, desc="Espera a que alguien se conecte"}} end
    _menus["player_list"] = opts
end

-- DIBUJO (banner de texto mejorado)
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
    DrawRect(x, y, w, h, 10, 20, 40, 200)
    DrawRect(x, y - h/4, w, h/2, 20, 40, 80, 200)
    DrawRect(x, y + h/2 - 0.005, w, 0.008, _neonColor[1], _neonColor[2], _neonColor[3], 255)
    SetTextFont(7)
    SetTextScale(0.55, 0.55)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextDropshadow(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    AddTextComponentString(_bannerTexto)
    DrawText(x, y - 0.02)
    SetTextFont(0)
    SetTextScale(0.28, 0.28)
    SetTextColour(200, 200, 200, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(_version)
    DrawText(x, y + 0.015)
end

local function _drawACWarning(x,y,totalH)
    if _acDetected then
        local wy = y + totalH + 0.018
        SetTextFont(4)
        SetTextScale(0.28,0.28)
        SetTextColour(_neonColor[1],_neonColor[2],_neonColor[3],255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString("⚠️ ANTICHEAT DETECTADO - RIESGO ELEVADO ⚠️")
        DrawText(x, wy)
    end
end

function _drawMenu()
    local w = 0.26
    local x = _posX
    local y = 0.2
    local bannerH = 0.11
    local titleH = 0.045
    local optH = 0.042
    local lineH = 0.032
    local padDesc = 0.005

    local opts = _menus[_menuActual]
    if not opts then _menuActual = "main"; opts = _menus["main"] end
    local numOpt = #opts

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

    local totalH = bannerH + titleH + (numOpt * optH) + descH + 0.015
    local startY = y

    DrawRect(x, startY + totalH/2, w, totalH, _bgColor[1], _bgColor[2], _bgColor[3], _bgColor[4])
    DrawRect(x, startY, w, 0.0005, _neonColor[1], _neonColor[2], _neonColor[3], _neonColor[4])
    DrawRect(x, startY+totalH, w, 0.0005, _neonColor[1], _neonColor[2], _neonColor[3], _neonColor[4])
    DrawRect(x - w/2, startY+totalH/2, 0.0005, totalH, _neonColor[1], _neonColor[2], _neonColor[3], _neonColor[4])
    DrawRect(x + w/2, startY+totalH/2, 0.0005, totalH, _neonColor[1], _neonColor[2], _neonColor[3], _neonColor[4])
    DrawRect(x, startY, w+0.006, 0.001, _glowColor[1], _glowColor[2], _glowColor[3], _glowColor[4])
    DrawRect(x, startY+totalH, w+0.006, 0.001, _glowColor[1], _glowColor[2], _glowColor[3], _glowColor[4])

    _drawBanner(x, startY + bannerH/2, w-0.01, bannerH-0.01)
    DrawRect(x, startY+bannerH-0.001, w, 0.0005, _neonColor[1], _neonColor[2], _neonColor[3], 200)

    local titleY = startY + bannerH + 0.008
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

    local optsY = startY + bannerH + titleH + 0.008
    for i,opt in ipairs(opts) do
        local yOff = optsY + (i-1)*optH
        local color = (i==_optActual) and _neonColor or {200,200,200,255}
        if i==_optActual then
            DrawRect(x, yOff + optH/2 - 0.005, w-0.01, optH-0.005, _selectBg[1], _selectBg[2], _selectBg[3], _selectBg[4])
        end
        local display = opt.nombre:gsub("~b~",""):gsub("~r~",""):gsub("~g~",""):gsub("~y~","")
        _drawShadowText(display, x - w/2 + 0.02, yOff, 0.4, 0, false, color)
        if i==_optActual then _descActual = (opt.desc or "Selecciona una opción") .. " " end
    end

    local descY = startY + bannerH + titleH + (numOpt * optH) + 0.008
    for i,line in ipairs(descLines) do
        local lineY = descY + padDesc + (i-1)*lineH + lineH/2 - 0.008
        _drawShadowText(line, x, lineY, 0.32, 0, true, {210,210,255,255})
    end

    local counter = _optActual .. "/" .. numOpt
    SetTextFont(0)
    SetTextScale(0.28,0.28)
    SetTextColour(150,150,150,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(counter)
    DrawText(x + w/2 - 0.02, startY + totalH - 0.022)

    SetTextFont(0)
    SetTextScale(0.28,0.28)
    SetTextColour(150,150,150,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(_discord)
    DrawText(x - w/2 + 0.005, startY + totalH - 0.022)

    _drawACWarning(x, startY, totalH)
end

-- ========== INICIO CON CARGA PROFESIONAL ==========
local _menuListo = false
local _retardo = 5000 + _r(0,10000)

Citizen.CreateThread(function()
    _notify("^1[SENTEX] ^7Inicializando módulos...")
    _w(1500)
    _notify("^1[SENTEX] ^7Cargando recursos gráficos...")
    _w(1000)
    _notify("^1[SENTEX] ^7Estableciendo conexión con la API del juego...")
    _w(_retardo - 2500)
    _menuListo = true
    _scanAC()
    _notify("^1[SENTEX] ^2Sistema listo. ^7Presiona ^1PAGEDOWN^7 para abrir el menú.")
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
                    _notify("^1[SENTEX] ^2Menú abierto.")
                else
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    _notify("^1[SENTEX] ^3Menú cerrado.")
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
                            if not ok then _notify("^1[SENTEX] ^7Error: "..tostring(err)) end
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
