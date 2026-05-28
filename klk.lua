--[[
    SENTEX MENU v3.6 Beta - NUI con GitHub Pages
    Abre con PAGEDOWN - Todas las funciones originales.
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
-- (Aquí debes incluir todas las funciones: _curar, _revivirESX, _revivirQB, _repararVeh, _flipVeh, _limpiarVeh, _conducirVeh, _spawnVeh, _vehiculosCercanos, _nombreVeh, _cargarVeh, _lanzarVeh, _listaJugadores, _nombreJugador, _spawnNPCs, _abrirInventario, _matarJugador, _teleportTo, _engancharVehCercano, _crearAccion, _attachAllNearbyVehicles, _detachAllVehicles, _spawnPropGlobal, _spawnStuntBlock, _spawnStuntBlockAlt, _createForest, _startChairRain, _safeMassVehicleSpawn, _globalSmoke, _everyoneDance, _spawnRampa, noclip, freecam, event hunter, framing, etc.)
-- Por brevedad, no las repetiré aquí. Asegúrate de tenerlas copiadas de tu script anterior.
-- Si necesitas el script completo con todas las acciones, dímelo y lo genero.

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
    SetNuiFocus(false, false)
    cb('ok')
end)

-- ========== CONTROL DEL MENÚ ==========
local isMenuOpen = false

function OpenMenu()
    if not isMenuOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openMenu' })
        isMenuOpen = true
    end
end

function CloseMenu()
    if isMenuOpen then
        SetNuiFocus(false, false)
        SendNUIMessage({ type = 'closeMenu' })
        isMenuOpen = false
    end
end

-- Tecla PAGEDOWN (código 11)
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 11) then
            if not isMenuOpen then
                OpenMenu()
            else
                CloseMenu()
            end
        end
    end
end)

-- ========== INICIALIZACIÓN ==========
-- Cargar la página NUI desde GitHub Pages (reemplaza la URL con la tuya)
-- Si no tienes GitHub Pages, usa el HTML incrustado como alternativa (comentado)
Citizen.CreateThread(function()
    -- Configura la URL de tu página HTML alojada en GitHub Pages
    -- Debe ser la URL completa donde está tu index.html
    local nuiUrl = "https://sentexz.github.io/sentexmodz/ui/index.html"
    
    -- Alternativa: si no tienes GitHub Pages, usa el HTML incrustado (descomentar y comentar el de arriba)
    -- local nuiHtml = [[ ... ]]  (todo el HTML, CSS, JS)
    -- local nuiUrl = "data:text/html;charset=utf-8," .. nuiHtml
    
    -- Cargar la página NUI
    SetNuiUrl(nuiUrl)
    
    _notify("~b~[~s~SENTEX~b~]~s~ Inicializando...")
    Wait(2000)
    _scanAC()
    _notify("~b~[~s~SENTEX~b~]~s~ Listo. Presiona PAGEDOWN para abrir el menú.")
    print("[SENTEX] Menú listo. Presiona PAGEDOWN.")
end)

-- Función Start para el loader
function StartMenu()
    print("[SENTEX] Menú iniciado. Presiona PAGEDOWN.")
end

return { Start = StartMenu }
