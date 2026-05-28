--[[
    SENTEX MENU v3.7 - Diseño premium rojo (texto centrado verticalmente)
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
-- (Todas las funciones: _curar, _revivirESX, _revivirQB, _revivirJugador, _repararVeh, _tuneVehicleMax, _toggleShiftBoost, _flipVeh, _limpiarVeh, _conducirVeh, _spawnVeh, _vehiculosCercanos, _nombreVeh, _cargarVeh, _lanzarVeh, _listaJugadores, _nombreJugador, _spawnNPCs, _abrirInventario, _matarJugador, _teleportTo, _spectatePlayer, _engancharVehCercano, _crearAccion, _attachAllNearbyVehicles, _detachAllVehicles, _spawnPropGlobal, _spawnStuntBlock, _createForest, noclip, event hunter, framing, etc.)
-- Como ya las tienes en tu script anterior, no las duplico aquí para no alargar. Asegúrate de que estén incluidas.

-- ========== MENÚ REDISEÑADO (texto centrado verticalmente) ==========
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
    DrawText(x, y-0.005)  -- ligeramente arriba del centro visual
    DrawRect(x, y + h/2 - 0.008, w-0.02, 0.001, 150, 10, 30, 150)
end

local function _drawItem(x, yCenter, w, opt, isSelected)
    -- Separador vertical
    local sepX = x - w/2 + 0.02
    DrawRect(sepX, yCenter, 0.001, 0.03, _separatorColor[1], _separatorColor[2], _separatorColor[3], _separatorColor[4])

    -- Texto limpio (sin símbolos originales) centrado verticalmente
    local cleanText = opt.nombre:gsub("[%[»%]•]", ""):gsub("^%s*", "")
    SetTextFont(0)
    SetTextScale(0.4,0.4)
    SetTextColour(255,255,255,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(cleanText)
    -- Altura aproximada del texto con escala 0.4 es ~0.025, por eso restamos 0.0125 para centrar
    DrawText(x - w/2 + 0.04, yCenter - 0.0125)

    -- Flecha derecha
    SetTextFont(0)
    SetTextScale(0.45,0.45)
    SetTextColour(200,200,200,200)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString("→")
    DrawText(x + w/2 - 0.03, yCenter - 0.0125)
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
    local optH = 0.042
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

    -- Contador de opciones (esquina inferior derecha del menú)
    local counter = _optActual .. "/" .. totalOpts
    SetTextFont(0)
    SetTextScale(0.25,0.25)
    SetTextColour(150,150,160,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(counter)
    DrawText(x + w/2 - 0.02, startY + totalH - 0.02)

    -- Alerta anticheat (dentro del menú, esquina superior izquierda)
    if _acDetected then
        SetTextFont(4)
        SetTextScale(0.35,0.35)
        SetTextColour(255,80,80,255)
        SetTextCentre(false)
        SetTextEntry("STRING")
        AddTextComponentString("⚠️")
        DrawText(x - w/2 - 0.02, startY + 0.01)
    end

    -- Scrollbar
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

-- ========== TEXTO DEL DISCORD (esquina inferior izquierda de la pantalla, fuera del menú) ==========
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        -- Solo dibujar cuando el menú está visible (opcional, si quieres que siempre esté, quita la condición)
        if _menuVisible then
            SetTextFont(0)
            SetTextScale(0.22, 0.22)
            SetTextColour(180, 180, 200, 200)
            SetTextCentre(false)
            SetTextEntry("STRING")
            AddTextComponentString(_discord)
            DrawText(0.01, 0.96)   -- esquina inferior izquierda
        end
    end
end)

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

-- ========== DINÁMICOS (no se incluyen para no extender, pero deben estar presentes) ==========
-- Nota: Asegúrate de incluir _refrescarListaVeh y _refrescarListaJugadores con las acciones correspondientes.

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
