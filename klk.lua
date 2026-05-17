--[[
    SENTEX MENU - Versión v3.6 (enganchar vehículo de jugador) [SECURE EDITION]
    Abre con PAGEDOWN
--]]

-- ==================== CONFIGURACIÓN OFUSCADA ====================
local _V = "v3.6".." (enganchar vehículo de jugador)"
local _D = ".gg/".."sentexmodz"

-- ==================== NOTIFICACIONES (ofuscadas) ====================
local function _notif(t)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(t)
    DrawNotification(false, false)
end

-- ==================== DETECCIÓN DE ANTICHEAT CON CAMBIO DE COMPORTAMIENTO ====================
local _acDetected = false
local _acList = {}
local _safeMode = false   -- <-- NUEVO: modo seguro cuando hay anticheat

local _acPatterns = {
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

local function _scanSilent()
    local found = {}
    local ok, num = pcall(GetNumResources)
    if ok then
        for i = 0, num - 1 do
            local res = GetResourceByFindIndex(i)
            if res then
                local name = string.lower(res)
                for _, ac in ipairs(_acPatterns) do
                    for _, p in ipairs(ac.patterns) do
                        if name:find(p) then
                            found[ac.name] = true
                        end
                    end
                end
            end
            Citizen.Wait(0)
        end
    end
    if next(found) then
        _acDetected = true
        _acList = {}
        for name, _ in pairs(found) do
            table.insert(_acList, name)
        end
        _safeMode = true   -- ACTIVAR MODO SEGURO
        _notif("~r~⚠️ ".."Anticheat detectado: ~y~" .. table.concat(_acList, ", ") .. "~s~")
        _notif("~r~MODO SEGURO ACTIVADO - Acciones bloqueadas~s~")
    else
        _acDetected = false
        _acList = {}
        _safeMode = false
        _notif("~g~No se detectaron anticheats conocidos")
    end
end

-- ==================== ACCIONES (con bloqueo en modo seguro) ====================
local function _checkSafe()
    if _safeMode then
        _notif("~r~Acción bloqueada (Anticheat detectado)~s~")
        return true
    end
    return false
end

function _heal()
    if _checkSafe() then return end
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)
    _notif("~g~Salud y armadura restauradas")
end

function _reviveESX()
    if _checkSafe() then return end
    TriggerEvent('esx_ambulancejob:revive')
    _notif("~g~Reviviendo (ESX)")
end

function _reviveQB()
    if _checkSafe() then return end
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
        _notif("~g~Intentando revivir (QB/QC)")
    else
        _notif("~r~No estás muerto")
    end
end

-- VEHÍCULO
function _repairVeh(v)
    if _checkSafe() then return end
    if not v then
        local ped = PlayerPedId()
        v = GetVehiclePedIsIn(ped, false)
    end
    if v and v ~= 0 then
        SetVehicleFixed(v)
        SetVehicleDirtLevel(v, 0.0)
        _notif("~g~Vehículo reparado y limpiado")
    else
        _notif("~r~No estás en un vehículo")
    end
end

function _flipVeh(v)
    if _checkSafe() then return end
    if not v then
        local ped = PlayerPedId()
        v = GetVehiclePedIsIn(ped, false)
    end
    if v and v ~= 0 then
        local rot = GetEntityRotation(v)
        SetEntityRotation(v, rot.x, rot.y, rot.z + 180.0, 2, true)
        _notif("~g~Vehículo volteado")
    else
        _notif("~r~No estás en un vehículo")
    end
end

function _cleanVeh(v)
    if _checkSafe() then return end
    if not v then
        local ped = PlayerPedId()
        v = GetVehiclePedIsIn(ped, false)
    end
    if v and v ~= 0 then
        SetVehicleDirtLevel(v, 0.0)
        _notif("~g~Vehículo limpiado")
    else
        _notif("~r~No estás en un vehículo")
    end
end

function _driveVeh(v)
    if _checkSafe() then return end
    if not v or v == 0 then
        _notif("~r~El vehículo ya no existe")
        return
    end
    local ped = PlayerPedId()
    local vCoord = GetEntityCoords(v)
    local dist = #(GetEntityCoords(ped) - vCoord)
    if dist > 10.0 then
        _notif("~y~Teletransportando...")
        DoScreenFadeOut(500)
        Citizen.Wait(500 + math.random(100, 300))
        local offset = 2.0
        local newC = vector3(vCoord.x + offset, vCoord.y + offset, vCoord.z)
        SetEntityCoords(ped, newC.x, newC.y, newC.z, false, false, false, false)
        Citizen.Wait(200)
        DoScreenFadeIn(500)
        Citizen.Wait(300)
    end
    local driver = GetPedInVehicleSeat(v, -1)
    if driver and driver ~= 0 then
        ClearPedTasksImmediately(driver)
        SetEntityCoords(driver, GetEntityCoords(driver) + vector3(1.0, 1.0, 0.5), false, false, false, false)
        _notif("~y~Conductor expulsado")
        Citizen.Wait(200)
    end
    TaskWarpPedIntoVehicle(ped, v, -1)
    _notif("~g~Te has subido al vehículo")
end

function _spawnVeh()
    if _checkSafe() then return end
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Modelo (ej: adder)", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end
    local res = GetOnscreenKeyboardResult()
    if res and res ~= "" then
        local model = res:lower()
        if IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do Citizen.Wait(10) end
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local veh = CreateVehicle(model, coords.x + 2.0, coords.y + 2.0, coords.z, heading, true, false)
            SetVehicleOnGroundProperly(veh)
            SetModelAsNoLongerNeeded(model)
            _notif("~g~Vehículo ~b~" .. model .. " ~g~spawneado")
        else
            _notif("~r~Modelo inválido: " .. model)
        end
    end
end

function _getNearbyVehicles()
    local vehs = {}
    local ped = PlayerPedId()
    local pCoord = GetEntityCoords(ped)
    local pool = GetGamePool("CVehicle")
    for i = 1, #pool do
        local v = pool[i]
        local dist = #(pCoord - GetEntityCoords(v))
        if dist < 50.0 and v ~= 0 then
            table.insert(vehs, v)
        end
    end
    return vehs
end

function _getVehDisplay(v)
    local model = GetEntityModel(v)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if name == "NULL" then name = string.upper(GetDisplayNameFromVehicleModel(model)) end
    return name
end

-- CARGAR / LANZAR
local _carriedVeh = nil
local _carrying = false

function _loadVeh()
    if _checkSafe() then return end
    local ped = PlayerPedId()
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local dir = _rotToDir(camRot)
    local dest = vec3(camPos.x + dir.x * 10.0, camPos.y + dir.y * 10.0, camPos.z + dir.z * 10.0)
    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, ped, 0)
    local _, hit, _, _, ent = GetShapeTestResult(ray)
    if hit == 1 and GetEntityType(ent) == 2 then
        if _carrying then
            _notif("~r~Ya estás cargando un vehículo")
            return
        end
        _carriedVeh = ent
        _carrying = true
        if not NetworkHasControlOfEntity(_carriedVeh) then
            NetworkRequestControlOfEntity(_carriedVeh)
            local to = 0
            while not NetworkHasControlOfEntity(_carriedVeh) and to < 20 do
                Citizen.Wait(50)
                to = to + 1
            end
        end
        FreezeEntityPosition(_carriedVeh, true)
        AttachEntityToEntity(_carriedVeh, ped, GetPedBoneIndex(ped, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
        RequestAnimDict('anim@mp_rollarcoaster')
        while not HasAnimDictLoaded('anim@mp_rollarcoaster') do Citizen.Wait(10) end
        TaskPlayAnim(ped, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
        _notif("~g~Vehículo cargado")
    else
        _notif("~r~No estás mirando a ningún vehículo")
    end
end

function _throwVeh()
    if _checkSafe() then return end
    if not _carrying or not _carriedVeh then
        _notif("~r~No tienes ningún vehículo cargado")
        return
    end
    local ped = PlayerPedId()
    local camRot = GetGameplayCamRot(2)
    local dir = _rotToDir(camRot)
    DetachEntity(_carriedVeh, true, true)
    FreezeEntityPosition(_carriedVeh, false)
    local force = 40.0
    ApplyForceToEntity(_carriedVeh, 1, dir.x * force, dir.y * force, dir.z * force, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    ClearPedTasks(ped)
    _notif("~y~Vehículo lanzado")
    _carriedVeh = nil
    _carrying = false
end

function _rotToDir(rot)
    local adj = vec3((math.pi/180)*rot.x, (math.pi/180)*rot.y, (math.pi/180)*rot.z)
    local dir = vec3(-math.sin(adj.z)*math.abs(math.cos(adj.x)), math.cos(adj.z)*math.abs(math.cos(adj.x)), math.sin(adj.x))
    return dir
end

-- JUGADORES
function _getPlayers()
    local list = {}
    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            local ped = GetPlayerPed(i)
            if ped and ped ~= 0 then
                table.insert(list, i)
            end
        end
    end
    return list
end

function _getPlayerNameSafe(pl)
    local ok, name = pcall(function() return GetPlayerName(pl) end)
    if ok and name then return name end
    return "Jugador " .. pl
end

function _spawnNPC(tgt)
    if _checkSafe() then return end
    local tgtPed = GetPlayerPed(tgt)
    if not tgtPed or tgtPed == 0 then
        _notif("~r~Jugador no encontrado")
        return
    end
    local tgtCoord = GetEntityCoords(tgtPed)
    local model = "a_m_y_hipster_01"
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(10) end
    local spawn = vector3(tgtCoord.x + 10.0, tgtCoord.y + 10.0, tgtCoord.z)
    local npc = CreatePed(0, model, spawn.x, spawn.y, spawn.z, 0.0, true, true)
    SetPedCombatAttributes(npc, 0, true)
    SetPedCombatAbility(npc, 100)
    SetPedAccuracy(npc, 60)
    SetPedArmour(npc, 50)
    SetPedCanRagdoll(npc, true)
    GiveWeaponToPed(npc, GetHashKey("WEAPON_PISTOL"), 999, true, true)
    SetPedInfiniteAmmo(npc, true)
    TaskGoToEntity(npc, tgtPed, -1, 2.0, 5.0, 1073741824, 0)
    Citizen.Wait(3000)
    TaskCombatPed(npc, tgtPed, 0, 16)
    SetEntityAsMissionEntity(npc, true, true)
    SetModelAsNoLongerNeeded(model)
    _notif("~r~NPC sospechoso spawneado cerca del jugador")
end

function _openInv(tgt)
    if _checkSafe() then return end
    local sid = GetPlayerServerId(tgt)
    if sid then
        TriggerEvent('ox_inventory:openInventory', 'otherplayer', sid)
        _notif("~g~Abriendo inventario del jugador")
    else
        _notif("~r~No se pudo obtener Server ID")
    end
end

function _giveMoney(tgt)
    if _checkSafe() then return end
    TriggerServerEvent('esx:giveMoney', tgt, 10000)
    _notif("~g~Se han dado 10k al jugador")
end

function _killPlayer(tgt)
    if _checkSafe() then return end
    local tgtPed = GetPlayerPed(tgt)
    if tgtPed and tgtPed ~= 0 then
        SetEntityHealth(tgtPed, 0)
        _notif("~r~Jugador eliminado")
    end
end

function _teleportTo(tgt)
    if _checkSafe() then return end
    local tgtPed = GetPlayerPed(tgt)
    if tgtPed and tgtPed ~= 0 then
        local coord = GetEntityCoords(tgtPed)
        local ped = PlayerPedId()
        DoScreenFadeOut(500)
        Citizen.Wait(500)
        SetEntityCoords(ped, coord.x, coord.y, coord.z + 0.5, false, false, false, false)
        Citizen.Wait(100)
        DoScreenFadeIn(500)
        _notif("~g~Teletransportado")
    end
end

function _attachPlayerVeh(tgt)
    if _checkSafe() then return end
    local myPed = PlayerPedId()
    local myVeh = GetVehiclePedIsIn(myPed, false)
    if myVeh == 0 then
        _notif("~r~Debes estar en un vehículo para enganchar")
        return
    end
    local tgtPed = GetPlayerPed(tgt)
    if not tgtPed or tgtPed == 0 then
        _notif("~r~Jugador no encontrado")
        return
    end
    local tgtVeh = GetVehiclePedIsIn(tgtPed, false)
    if tgtVeh == 0 then
        _notif("~r~El jugador no está en un vehículo")
        return
    end
    if tgtVeh == myVeh then
        _notif("~r~No puedes enganchar tu propio vehículo")
        return
    end
    if not NetworkHasControlOfEntity(tgtVeh) then
        NetworkRequestControlOfEntity(tgtVeh)
        local to = 0
        while not NetworkHasControlOfEntity(tgtVeh) and to < 20 do
            Citizen.Wait(50)
            to = to + 1
        end
    end
    AttachEntityToEntity(tgtVeh, myVeh, 0, 0.0, -2.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    _notif("~g~Vehículo enganchado al tuyo")
end

function _makePlayerAction(pid, atype)
    return function()
        if atype == "inventory" then _openInv(pid)
        elseif atype == "money" then _giveMoney(pid)
        elseif atype == "revive" then
            if _checkSafe() then return end
            TriggerEvent('esx_ambulancejob:revive', pid)
            TriggerEvent('hospital:client:Revive', pid)
            _notif("~g~Reviviendo jugador")
        elseif atype == "kill" then _killPlayer(pid)
        elseif atype == "follow" then
            if _checkSafe() then return end
            if _following == pid then
                _following = nil
                SetPlayerFollowing(PlayerId(), 0)
                _notif("~y~Dejaste de seguir")
            else
                _following = pid
                _notif("~y~Siguiendo jugador")
            end
        elseif atype == "teleport" then _teleportTo(pid)
        elseif atype == "spawnnpc" then _spawnNPC(pid)
        elseif atype == "attachveh" then _attachPlayerVeh(pid)
        end
    end
end

local _following = nil

-- MAP FUCKER
local _attachActive = false
local _attachedVehs = {}

function _toggleAttach()
    if _checkSafe() then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        _notif("~r~Debes estar en un vehículo")
        return
    end
    if not _attachActive then
        local coord = GetEntityCoords(veh)
        local pool = GetGamePool("CVehicle")
        local count = 0
        for _, v in ipairs(pool) do
            if v ~= veh then
                local dist = #(coord - GetEntityCoords(v))
                if dist < 150.0 then
                    if not NetworkHasControlOfEntity(v) then
                        NetworkRequestControlOfEntity(v)
                        local to = 0
                        while not NetworkHasControlOfEntity(v) and to < 20 do
                            Citizen.Wait(50)
                            to = to + 1
                        end
                    end
                    AttachEntityToEntity(v, veh, 0, 0.0, -2.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    table.insert(_attachedVehs, v)
                    count = count + 1
                end
            end
        end
        if count > 0 then
            _attachActive = true
            _notif("~g~Enganchados " .. count .. " vehículos")
        else
            _notif("~r~No hay vehículos en 150 metros")
        end
    else
        for _, v in ipairs(_attachedVehs) do
            if DoesEntityExist(v) then
                DetachEntity(v, true, false)
            end
        end
        _attachedVehs = {}
        _attachActive = false
        _notif("~r~Vehículos desenganchados")
    end
end

-- Freecam
local _freecamActive = false
local _freecamCam = nil

function _toggleFreecam()
    if _checkSafe() then return end
    _freecamActive = not _freecamActive
    if _freecamActive then
        _freecamCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        local ped = PlayerPedId()
        local coord = GetEntityCoords(ped)
        SetCamCoord(_freecamCam, coord.x, coord.y, coord.z + 2.0)
        SetCamRot(_freecamCam, 0.0, 0.0, GetEntityHeading(ped))
        RenderScriptCams(true, true, 1000, true, true)
        SetPlayerControl(PlayerId(), false, 0)
        SetEntityVisible(ped, false, false)
        _notif("~b~Freecam ACTIVADA | WASD + Ratón | BACKSPACE para salir")
    else
        RenderScriptCams(false, true, 1000, true, true)
        SetPlayerControl(PlayerId(), true, 0)
        local ped = PlayerPedId()
        SetEntityVisible(ped, true, false)
        DestroyCam(_freecamCam, true)
        _freecamCam = nil
        _notif("~b~Freecam DESACTIVADA")
    end
end

Citizen.CreateThread(function()
    while true do
        if _freecamActive and _freecamCam then
            local speed = 5.0
            local mx, my, mz = 0.0, 0.0, 0.0
            if IsControlPressed(0, 32) then my = my + speed end
            if IsControlPressed(0, 33) then my = my - speed end
            if IsControlPressed(0, 34) then mx = mx - speed end
            if IsControlPressed(0, 35) then mx = mx + speed end
            if IsControlPressed(0, 22) then mz = mz + speed end
            if IsControlPressed(0, 36) then mz = mz - speed end
            local pos = GetCamCoord(_freecamCam)
            local newPos = vector3(pos.x + mx, pos.y + my, pos.z + mz)
            SetCamCoord(_freecamCam, newPos.x, newPos.y, newPos.z)
            local mouseX = GetDisabledControlNormal(0, 1)
            local mouseY = GetDisabledControlNormal(0, 2)
            local rot = GetCamRot(_freecamCam, 2)
            SetCamRot(_freecamCam, rot.x + mouseY * -50.0, 0.0, rot.z + mouseX * -50.0, 2)
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- ==================== AC CHECKER (manual) ====================
local _isChecking = false
function _checkACManual()
    if _isChecking then
        _notif("~y~Ya se está ejecutando...")
        return
    end
    _isChecking = true
    for i, opt in ipairs(_opts["protection"]) do
        if opt.nombre == "• AC Checker" then
            opt.nombre = "~b~• Checking..."
            break
        end
    end
    Citizen.CreateThread(function()
        local found = {}
        local ok, num = pcall(GetNumResources)
        if ok then
            for i = 0, num - 1 do
                local res = GetResourceByFindIndex(i)
                if res then
                    local name = string.lower(res)
                    for _, ac in ipairs(_acPatterns) do
                        for _, p in ipairs(ac.patterns) do
                            if name:find(p) then
                                found[ac.name] = true
                            end
                        end
                    end
                end
                Citizen.Wait(0)
            end
        end
        if next(found) then
            _acDetected = true
            _acList = {}
            for name, _ in pairs(found) do
                table.insert(_acList, name)
            end
            _safeMode = true
            local txt = table.concat(_acList, ", ")
            _notif("~r~⚠️ ANTICHEAT DETECTADO: ~y~" .. txt .. "~s~")
            _notif("~r~MODO SEGURO ACTIVADO~s~")
        else
            _acDetected = false
            _acList = {}
            _safeMode = false
            _notif("~g~No se detectó ningún anticheat conocido")
        end
        for i, opt in ipairs(_opts["protection"]) do
            if opt.nombre == "~b~• Checking..." then
                opt.nombre = "• AC Checker"
                break
            end
        end
        _isChecking = false
    end)
end

-- ==================== NOCLIP (con bloqueo) ====================
local _noclipActive = false
local _noclipSpeed = 5.0
local _boostMult = 3.0
local _noclipControls = { fwd=32, back=33, left=34, right=35, boost=21, up=22, down=36 }

local function _getCamVecs()
    local rot = GetGameplayCamRot(2)
    local pitch = math.rad(rot.x)
    local yaw = math.rad(rot.z)
    local cosP = math.cos(pitch)
    local sinP = math.sin(pitch)
    local cosY = math.cos(yaw)
    local sinY = math.sin(yaw)
    local fwd = vector3(-sinY * cosP, cosY * cosP, sinP)
    local right = vector3(-cosY, -sinY, 0.0)
    local up = vector3(0.0, 0.0, 1.0)
    return fwd, right, up
end

Citizen.CreateThread(function()
    while true do
        if _noclipActive then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            local ent = (veh ~= 0 and veh) or ped
            SetEntityCollision(ent, false, false)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ent, false)
            SetEntityVelocity(ent, 0.0, 0.0, 0.0)
            local mx, my, mz = 0.0, 0.0, 0.0
            if IsControlPressed(0, _noclipControls.fwd) then my = my + 1.0 end
            if IsControlPressed(0, _noclipControls.back) then my = my - 1.0 end
            if IsControlPressed(0, _noclipControls.left) then mx = mx + 1.0 end
            if IsControlPressed(0, _noclipControls.right) then mx = mx - 1.0 end
            if IsControlPressed(0, _noclipControls.up) then mz = mz + 1.0 end
            if IsControlPressed(0, _noclipControls.down) then mz = mz - 1.0 end
            local speed = _noclipSpeed
            if IsControlPressed(0, _noclipControls.boost) then speed = speed * _boostMult end
            if mx ~= 0 or my ~= 0 or mz ~= 0 then
                local len = math.sqrt(mx*mx + my*my + mz*mz)
                if len > 0 then mx, my, mz = mx/len, my/len, mz/len end
                local fwd, right, up = _getCamVecs()
                local delta = (fwd * my) + (right * mx) + (up * mz)
                delta = delta * speed
                local newCoord = GetEntityCoords(ent) + delta
                SetEntityCoords(ent, newCoord.x, newCoord.y, newCoord.z, false, false, false, false)
            end
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- ==================== MENÚ (estilos y dibujo) ====================
local _neonCol = {0,255,255,255}
local _glow = {0,180,255,80}
local _bg = {0,0,0,210}
local _selBg = {30,144,255,60}

local function _drawBanner(x, y, w, h)
    DrawRect(x, y, w, h, 0, 30, 60, 200)
    SetTextFont(7)
    SetTextScale(0.55, 0.55)
    SetTextColour(255,255,255,255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("SENT".."EX".." MENU")
    DrawText(x, y-0.02)
    SetTextFont(0)
    SetTextScale(0.28, 0.28)
    SetTextColour(200,200,200,255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(_V)
    DrawText(x, y+0.015)
end

local function _drawACWarning(x, y, totalH, w)
    if _acDetected then
        local wy = y + totalH + 0.018
        SetTextFont(4)
        SetTextScale(0.28, 0.28)
        SetTextColour(_neonCol[1], _neonCol[2], _neonCol[3], 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString("⚠️ ANTICHEAT DETECTADO - MODO SEGURO ACTIVO ⚠️")
        DrawText(x, wy)
    end
end

-- ESTRUCTURA DEL MENÚ
local _menuOpen = false
local _curMenu = "main"
local _curOpt = 1
local _opts = {}
local _curDesc = ""
local _dynMenus = {}

_opts["main"] = {
    { nombre = "[»] Self options", submenu = "self", desc = "Opciones del jugador" },
    { nombre = "[»] Vehicle options", submenu = "vehicle", desc = "Opciones para vehículos" },
    { nombre = "[»] Player list", submenu = "player_list", desc = "Interactuar con otros jugadores" },
    { nombre = "[»] Map fucker", submenu = "map_fucker", desc = "Opciones locas del mapa" },
    { nombre = "[»] Protection options", submenu = "protection", desc = "Herramientas de seguridad" },
}

_opts["self"] = {
    { nombre = "• Curar", accion = _heal, desc = "Restaura salud y armadura" },
    { nombre = "• Revivir ESX", accion = _reviveESX, desc = "Resucita en servidores ESX" },
    { nombre = "• Revivir QB", accion = _reviveQB, desc = "Resucita en servidores QB/QC" },
    { nombre = "• Noclip",
      accion = function()
          if _safeMode then _notif("~r~Acción bloqueada (Anticheat detectado)~s~") return end
          _noclipActive = not _noclipActive
          if _noclipActive then _notif("~b~Noclip ACTIVADO")
          else
              local ped = PlayerPedId()
              local veh = GetVehiclePedIsIn(ped, false)
              local ent = (veh ~= 0 and veh) or ped
              SetEntityCollision(ent, true, true)
              SetEntityInvincible(ped, false)
              _notif("~r~Noclip DESACTIVADO")
          end
      end,
      desc = "Atraviesa paredes. Controles: WASD, Shift (boost), Espacio (subir), Ctrl (bajar)" },
}

_opts["vehicle"] = {
    { nombre = "• Spawn vehicle", accion = _spawnVeh, desc = "Escribe el modelo y spawnea el coche" },
    { nombre = "• Vehicle list", submenu = "vehicle_list", desc = "Lista de vehículos cercanos" },
    { nombre = "• Cargar vehículo", accion = _loadVeh, desc = "Apunta a un vehículo y presiónalo para cargarlo" },
    { nombre = "• Lanzar vehículo", accion = _throwVeh, desc = "Lanza el vehículo que tienes cargado" },
}

_opts["map_fucker"] = {
    { nombre = "• Attach cars", accion = _toggleAttach, desc = "Engancha cualquier vehículo cercano (150m)" },
    { nombre = "• Freecam", accion = _toggleFreecam, desc = "Cámara libre (toggle)" },
}

_opts["protection"] = {
    { nombre = "• AC Checker", accion = _checkACManual, desc = "Detecta anticheats (activa modo seguro)" },
}

-- FUNCIONES DINÁMICAS
function _refreshVehList()
    local vehs = _getNearbyVehicles()
    local opts = {}
    for i, v in ipairs(vehs) do
        local dname = _getVehDisplay(v)
        opts[i] = {
            nombre = "• " .. dname,
            submenu = "vehicle_" .. tostring(v),
            desc = "Opciones para " .. dname,
            vehicle = v
        }
        if not _dynMenus["vehicle_" .. tostring(v)] then
            _dynMenus["vehicle_" .. tostring(v)] = {
                { nombre = "• Reparar", accion = function() _repairVeh(v) end, desc = "Repara este vehículo" },
                { nombre = "• Voltear", accion = function() _flipVeh(v) end, desc = "Voltea este vehículo" },
                { nombre = "• Limpiar", accion = function() _cleanVeh(v) end, desc = "Limpia este vehículo" },
                { nombre = "• Conducir", accion = function() _driveVeh(v) end, desc = "Subirte (expulsa conductor actual)" },
            }
        end
    end
    if #opts == 0 then opts = { { nombre = "• No hay vehículos cerca", accion = nil, desc = "Acércate" } } end
    _opts["vehicle_list"] = opts
end

function _refreshPlayerList()
    local players = _getPlayers()
    local opts = {}
    for i, pid in ipairs(players) do
        local name = _getPlayerNameSafe(pid)
        opts[i] = {
            nombre = "• " .. name,
            submenu = "player_" .. tostring(pid),
            desc = "Opciones para " .. name,
            player = pid
        }
        if not _dynMenus["player_" .. tostring(pid)] then
            _dynMenus["player_" .. tostring(pid)] = {
                { nombre = "• Abrir inventario", accion = _makePlayerAction(pid, "inventory"), desc = "Abre el inventario ESX/ox_inventory" },
                { nombre = "• Dar dinero (10k)", accion = _makePlayerAction(pid, "money"), desc = "Da 10.000$ al jugador (ESX)" },
                { nombre = "• Revivir", accion = _makePlayerAction(pid, "revive"), desc = "Intenta revivir" },
                { nombre = "• Matar", accion = _makePlayerAction(pid, "kill"), desc = "Mata al jugador" },
                { nombre = "• Seguir", accion = _makePlayerAction(pid, "follow"), desc = "Cámara sigue al jugador" },
                { nombre = "• Teleportar", accion = _makePlayerAction(pid, "teleport"), desc = "Teletransportarse" },
                { nombre = "• Spawn NPC agresivo", accion = _makePlayerAction(pid, "spawnnpc"), desc = "Spawn un NPC que atacará al jugador" },
                { nombre = "• Enganchar su vehículo", accion = _makePlayerAction(pid, "attachveh"), desc = "Engancha el vehículo del jugador al tuyo" },
            }
        end
    end
    if #opts == 0 then opts = { { nombre = "• No hay jugadores", accion = nil, desc = "Espera" } } end
    _opts["player_list"] = opts
end

-- DIBUJO PRINCIPAL
local function _drawShadowText(t, x, y, sc, font, center, col)
    SetTextFont(font)
    SetTextScale(sc, sc)
    SetTextColour(col[1], col[2], col[3], col[4])
    SetTextCentre(center)
    SetTextDropshadow(1,0,0,0,200)
    SetTextEntry("STRING")
    AddTextComponentString(t)
    DrawText(x, y)
end

function _drawMenu()
    local w = 0.26
    local x = 0.7
    local y = 0.2
    local bannerH = 0.11
    local titleH = 0.045
    local optH = 0.042
    local lineH = 0.032
    local padDesc = 0.005

    local opts = _opts[_curMenu]
    if not opts then _curMenu = "main"; opts = _opts["main"] end
    local numOpt = #opts

    local descLines = {}
    if _curDesc and _curDesc ~= "" then
        local tmp = _curDesc
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

    DrawRect(x, startY + totalH/2, w, totalH, _bg[1], _bg[2], _bg[3], _bg[4])
    DrawRect(x, startY, w, 0.0005, _neonCol[1], _neonCol[2], _neonCol[3], _neonCol[4])
    DrawRect(x, startY + totalH, w, 0.0005, _neonCol[1], _neonCol[2], _neonCol[3], _neonCol[4])
    DrawRect(x - w/2, startY + totalH/2, 0.0005, totalH, _neonCol[1], _neonCol[2], _neonCol[3], _neonCol[4])
    DrawRect(x + w/2, startY + totalH/2, 0.0005, totalH, _neonCol[1], _neonCol[2], _neonCol[3], _neonCol[4])
    DrawRect(x, startY, w+0.006, 0.001, _glow[1], _glow[2], _glow[3], _glow[4])
    DrawRect(x, startY + totalH, w+0.006, 0.001, _glow[1], _glow[2], _glow[3], _glow[4])

    _drawBanner(x, startY + bannerH/2, w-0.01, bannerH-0.01)
    DrawRect(x, startY + bannerH - 0.001, w, 0.0005, _neonCol[1], _neonCol[2], _neonCol[3], 200)

    local titleY = startY + bannerH + 0.008
    local titleStr = (_curMenu == "main" and "MENU PRINCIPAL") or
                     (_curMenu == "self" and "SELF OPTIONS") or
                     (_curMenu == "vehicle" and "VEHICLE OPTIONS") or
                     (_curMenu == "vehicle_list" and "VEHICULOS CERCA") or
                     (_curMenu == "player_list" and "JUGADORES") or
                     (_curMenu == "map_fucker" and "MAP FUCKER") or
                     (_curMenu == "protection" and "PROTECTION OPTIONS") or
                     (_curMenu:match("^vehicle_") and "OPCIONES VEHICULO") or
                     (_curMenu:match("^player_") and "OPCIONES JUGADOR")
    _drawShadowText(titleStr, x, titleY, 0.48, 0, true, _neonCol)

    local optsY = startY + bannerH + titleH + 0.008
    for i, opt in ipairs(opts) do
        local yOff = optsY + (i-1)*optH
        local col = (i == _curOpt) and _neonCol or {200,200,200,255}
        if i == _curOpt then
            DrawRect(x, yOff + optH/2 - 0.005, w-0.01, optH-0.005, _selBg[1], _selBg[2], _selBg[3], _selBg[4])
        end
        local display = opt.nombre:gsub("~b~",""):gsub("~r~",""):gsub("~g~",""):gsub("~y~","")
        _drawShadowText(display, x - w/2 + 0.02, yOff, 0.4, 0, false, col)
        if i == _curOpt then _curDesc = (opt.desc or "Selecciona una opción") .. " " end
    end

    local descY = startY + bannerH + titleH + (numOpt * optH) + 0.008
    for i, line in ipairs(descLines) do
        local lineY = descY + padDesc + (i-1)*lineH + lineH/2 - 0.008
        _drawShadowText(line, x, lineY, 0.32, 0, true, {210,210,255,255})
    end

    local counter = _curOpt .. "/" .. numOpt
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
    AddTextComponentString(_D)
    DrawText(x - w/2 + 0.005, startY + totalH - 0.022)

    _drawACWarning(x, startY, totalH, w)
end

-- HILO PRINCIPAL
local _menuReady = false
Citizen.CreateThread(function()
    Citizen.Wait(3000)
    _menuReady = true
    _scanSilent()
    _notif("~g~SENTEX MENU " .. _V .. "~s~ | Presiona ~y~PAGEDOWN~s~")
end)

local function StartMenu()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if _menuReady and IsDisabledControlJustReleased(0, 11) then
                _menuOpen = not _menuOpen
                if _menuOpen then
                    _curOpt = 1
                    _curMenu = "main"
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    _notif("~b~SENTEX MENU~s~ | Abierto")
                else
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    _notif("~b~SENTEX MENU~s~ | Cerrado")
                end
                Citizen.Wait(200)
            end

            if _menuOpen and _menuReady then
                if _curMenu == "vehicle_list" then _refreshVehList()
                elseif _curMenu == "player_list" then _refreshPlayerList() end

                if _curMenu:match("^vehicle_") and not _opts[_curMenu] then
                    if _dynMenus[_curMenu] then _opts[_curMenu] = _dynMenus[_curMenu]
                    else _curMenu = "vehicle_list" end
                elseif _curMenu:match("^player_") and not _opts[_curMenu] then
                    if _dynMenus[_curMenu] then _opts[_curMenu] = _dynMenus[_curMenu]
                    else _curMenu = "player_list" end
                end

                _drawMenu()
                local maxOpt = #_opts[_curMenu]

                if IsDisabledControlJustReleased(0, 172) then
                    _curOpt = _curOpt - 1
                    if _curOpt < 1 then _curOpt = maxOpt end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                elseif IsDisabledControlJustReleased(0, 173) then
                    _curOpt = _curOpt + 1
                    if _curOpt > maxOpt then _curOpt = 1 end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                elseif IsDisabledControlJustReleased(0, 191) then
                    local sel = _opts[_curMenu][_curOpt]
                    if sel then
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        if sel.submenu then
                            _curMenu = sel.submenu
                            _curOpt = 1
                        elseif sel.accion then
                            local ok, err = pcall(sel.accion)
                            if not ok then _notif("~r~Error: " .. tostring(err)) end
                        end
                    end
                elseif IsDisabledControlJustReleased(0, 177) then
                    if _curMenu == "main" then
                        _menuOpen = false
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _curMenu == "self" or _curMenu == "vehicle" or _curMenu == "player_list" or _curMenu == "map_fucker" or _curMenu == "protection" then
                        _curMenu = "main"
                        _curOpt = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _curMenu == "vehicle_list" then
                        _curMenu = "vehicle"
                        _curOpt = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _curMenu:match("^vehicle_") then
                        _curMenu = "vehicle_list"
                        _curOpt = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif _curMenu:match("^player_") then
                        _curMenu = "player_list"
                        _curOpt = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    else
                        _curMenu = "main"
                        _curOpt = 1
                        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                end
            end
        end
    end)
end

return { Start = StartMenu }
