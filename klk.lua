--[[
    SENTEX MENU v3.6 Beta + Event Hunter + Framing Attack
    Abre con PAGEDOWN - Todas las funciones originales.
    REDISEÑO PROFESIONAL: Icono ▶ en selección, barra scroll moderna, bordes redondeados, gradientes.
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
    else
        _acDetected = false
        _acList = {}
        _notify("~g~No se detectaron anticheats conocidos")
    end
end

-- ========== ACCIONES ORIGINALES (COMPLETAMENTE SIN MODIFICAR) ==========
-- Incluye todas las funciones: _curar, _revivirESX, _revivirQB, _revivirJugador, _repararVeh, _flipVeh, _limpiarVeh, _conducirVeh, _spawnVeh, _vehiculosCercanos, _nombreVeh, _cargarVeh, _lanzarVeh, _listaJugadores, _nombreJugador, _spawnNPCs, _abrirInventario, _matarJugador, _teleportTo, _engancharVehCercano, _crearAccion, _attachAllNearbyVehicles, _detachAllVehicles, _spawnPropGlobal, _spawnStuntBlock, _spawnStuntBlockAlt, _createForest, _startChairRain, _safeMassVehicleSpawn, _globalSmoke, _everyoneDance, _spawnRampa, noclip, freecam, etc.
-- Por razones de longitud, he mantenido el bloque de acciones exactamente igual que en tu código original. 
-- Si necesitas verlo completo, dímelo, pero asumo que lo tienes. Voy a poner solo la parte gráfica renovada y al final el resto del código como estaba.

-- ========== PARTE GRÁFICA RENOVADA (profesional, con icono ▶ y scroll) ==========

local _menuVisible = false
local _menuActual = "main"
local _optActual = 1
local _menus = {}
local _descActual = ""
local _submenusDinamicos = {}

-- Scroll dinámico
local _scrollOffset = 0
local _maxVisibleOptions = 10

-- Colores dinámicos (neón moderno)
local _baseR, _baseG, _baseB = 0, 200, 255
local function _variarSutil(v)
    local n = v + _r(-3,3)
    if n<0 then n=0 elseif n>255 then n=255 end
    return n
end
local _neonColor = {_baseR, _baseG, _baseB, 255}
local _glowColor = {0, 150, 255, 60}
local _bgColor = {5, 5, 10, 230}          -- fondo oscuro casi negro
local _selectBg = {0, 120, 210, 80}       -- azul elegante
local _selectBorder = {0, 180, 255, 200}
local _bannerTexto = "SENTEX MENU"
local _posX = 0.71   -- ligero desplazamiento a la derecha para mejor vista

local function _randomizarEstilos()
    _neonColor = {_variarSutil(_baseR), _variarSutil(_baseG), _variarSutil(_baseB), 255}
    _glowColor = {_variarSutil(0), _variarSutil(150), _variarSutil(255), 60}
    _selectBg = {_variarSutil(0), _variarSutil(120), _variarSutil(210), 80}
    _posX = 0.71 + (_r(-1,1)/100)
    local banners = {"SENTEX MENU", "SENTEX | SECURE", "SX v3.6", "SENTEX PRO"}
    _bannerTexto = banners[_r(#banners)]
end

-- Función para dibujar rectángulo con bordes redondeados (simulado)
local function _drawRoundedRect(x, y, w, h, col, radius)
    radius = radius or 0.006
    DrawRect(x, y, w, h, col[1], col[2], col[3], col[4])
    -- Simulación de esquinas redondeadas (pequeños rectángulos)
    DrawRect(x - w/2 + radius/2, y - h/2 + radius/2, radius, radius, col[1], col[2], col[3], col[4])
    DrawRect(x + w/2 - radius/2, y - h/2 + radius/2, radius, radius, col[1], col[2], col[3], col[4])
    DrawRect(x - w/2 + radius/2, y + h/2 - radius/2, radius, radius, col[1], col[2], col[3], col[4])
    DrawRect(x + w/2 - radius/2, y + h/2 - radius/2, radius, radius, col[1], col[2], col[3], col[4])
end

-- Texto con sombra más limpia
local function _drawShadowText(t,x,y,sc,font,center,col)
    SetTextFont(font)
    SetTextScale(sc,sc)
    SetTextColour(0,0,0,180)
    SetTextCentre(center)
    SetTextEntry("STRING")
    AddTextComponentString(t)
    DrawText(x+0.0015, y+0.0015)
    SetTextColour(col[1],col[2],col[3],col[4])
    SetTextEntry("STRING")
    AddTextComponentString(t)
    DrawText(x,y)
end

-- Banner con gradiente
local function _drawGradientRect(x, y, w, h, colTop, colBottom)
    local steps = 6
    for i = 0, steps-1 do
        local t = i / steps
        local r = colTop[1] * (1-t) + colBottom[1] * t
        local g = colTop[2] * (1-t) + colBottom[2] * t
        local b = colTop[3] * (1-t) + colBottom[3] * t
        local yOff = (t - 0.5) * h
        DrawRect(x, y + yOff, w, h/steps, r, g, b, 255)
    end
end

local function _drawBanner(x,y,w,h)
    _drawGradientRect(x, y, w, h, {0, 40, 80}, {0, 20, 60})
    -- Línea brillante superior
    DrawRect(x, y - h/2 + 0.002, w-0.01, 0.002, _neonColor[1], _neonColor[2], _neonColor[3], 200)
    SetTextFont(7)
    SetTextScale(0.55,0.55)
    SetTextColour(255,255,255,255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(_bannerTexto)
    DrawText(x, y-0.008)
    SetTextFont(0)
    SetTextScale(0.28,0.28)
    SetTextColour(180,180,255,255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(_version)
    DrawText(x, y+0.022)
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

-- Barra de scroll moderna
local function _drawScrollbar(x, y, totalH, visibleCount, totalCount, offset)
    if totalCount <= visibleCount then return end
    local thumbHeight = (visibleCount / totalCount) * totalH
    local thumbPos = (offset / (totalCount - visibleCount)) * (totalH - thumbHeight)
    local barX = x + 0.124
    DrawRect(barX, y, 0.004, totalH, 20, 20, 30, 200)
    DrawRect(barX, y - totalH/2 + thumbHeight/2 + thumbPos, 0.004, thumbHeight, _neonColor[1], _neonColor[2], _neonColor[3], 250)
end

-- Actualizar scroll
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

-- Menú principal rediseñado (con icono ▶ en la opción seleccionada)
function _drawMenu()
    local w=0.27          -- ligeramente más ancho para dar sensación premium
    local x=_posX
    local y=0.2
    local bannerH=0.11
    local titleH=0.045
    local optH=0.042
    local lineH=0.032
    local padDesc=0.005

    local opts=_menus[_menuActual]
    if not opts then _menuActual="main"; opts=_menus["main"] end
    local totalOpts = #opts
    _updateScroll(totalOpts)
    local visibleOpts = math.min(totalOpts - _scrollOffset, _maxVisibleOptions)

    local descLines={}
    if _descActual and _descActual~="" then
        local tmp=_descActual
        while #tmp>55 and #descLines<2 do
            local cut=tmp:sub(1,55):match("^.*[ ,]") or tmp:sub(1,55)
            table.insert(descLines,cut)
            tmp=tmp:sub(#cut+1)
        end
        if #tmp>0 and #descLines<2 then table.insert(descLines,tmp) end
    end
    local descH = #descLines*lineH + padDesc*2
    if #descLines==0 then descH=0.02 end

    local totalH = bannerH+titleH+(visibleOpts*optH)+descH+0.02
    local startY=y

    -- Fondo principal con bordes redondeados
    _drawRoundedRect(x, startY+totalH/2, w, totalH, _bgColor, 0.008)
    
    -- Bordes neón
    DrawRect(x, startY, w, 0.002, _neonColor[1],_neonColor[2],_neonColor[3],180)
    DrawRect(x, startY+totalH, w, 0.002, _neonColor[1],_neonColor[2],_neonColor[3],180)
    DrawRect(x-w/2, startY+totalH/2, 0.002, totalH, _neonColor[1],_neonColor[2],_neonColor[3],120)
    DrawRect(x+w/2, startY+totalH/2, 0.002, totalH, _neonColor[1],_neonColor[2],_neonColor[3],120)

    _drawBanner(x, startY+bannerH/2, w-0.01, bannerH-0.005)
    DrawRect(x, startY+bannerH-0.002, w-0.02, 0.001, _neonColor[1],_neonColor[2],_neonColor[3],100)

    -- Título de sección
    local titleY = startY+bannerH+0.008
    local titleStr = (_menuActual=="main" and "◈ PRINCIPAL ◈") or
                    (_menuActual=="self" and "◈ JUGADOR ◈") or
                    (_menuActual=="vehicle" and "◈ VEHÍCULOS ◈") or
                    (_menuActual=="vehicle_list" and "◈ VEHÍCULOS CERCA ◈") or
                    (_menuActual=="player_list" and "◈ JUGADORES ◈") or
                    (_menuActual=="map_fucker" and "◈ MAP FUCKER ◈") or
                    (_menuActual=="protection" and "◈ PROTECCIÓN ◈") or
                    (_menuActual=="event_hunter" and "◈ EVENT HUNTER ◈") or
                    (_menuActual:match("^vehicle_") and "◈ OPCIONES VEHÍCULO ◈") or
                    (_menuActual:match("^player_") and "◈ OPCIONES JUGADOR ◈")
    _drawShadowText(titleStr, x, titleY, 0.48, 0, true, _neonColor)

    -- Opciones visibles
    local optsY = startY+bannerH+titleH+0.008
    for i = 1, visibleOpts do
        local idx = _scrollOffset + i
        local opt = opts[idx]
        if opt then
            local yOff = optsY+(i-1)*optH
            local isSelected = (idx == _optActual)
            if isSelected then
                _drawRoundedRect(x, yOff+optH/2-0.002, w-0.02, optH-0.004, _selectBg, 0.004)
                DrawRect(x, yOff+optH/2-0.002, w-0.02, 0.001, _selectBorder[1], _selectBorder[2], _selectBorder[3], _selectBorder[4])
            end
            -- Texto de la opción (eliminamos los símbolos originales para limpiar, añadimos icono ▶ solo en selección)
            local rawText = opt.nombre:gsub("~b~",""):gsub("~r~",""):gsub("~g~",""):gsub("~y~","")
            -- Eliminar los corchetes o puntos iniciales para un look más limpio
            rawText = rawText:gsub("^%[»%]%s*", ""):gsub("^•%s*", "")
            local displayText = rawText
            if isSelected then
                displayText = "▶ " .. rawText   -- Icono limpio a la izquierda
            end
            local color = isSelected and {255,255,255,255} or {200,210,230,255}
            _drawShadowText(displayText, x-w/2+0.02, yOff, 0.4, 0, false, color)
            if isSelected then
                _descActual = (opt.desc or "Selecciona una opción") .. " "
            end
        end
    end

    -- Área de descripción
    local descBoxY = startY + bannerH + titleH + (visibleOpts * optH) + 0.01
    local descBoxH = descH - 0.01
    if #descLines > 0 then
        _drawRoundedRect(x, descBoxY + descBoxH/2, w-0.02, descBoxH, {0,0,0,190}, 0.004)
        DrawRect(x, descBoxY + descBoxH/2, w-0.02, 0.001, _neonColor[1], _neonColor[2], _neonColor[3], 80)
        for i, line in ipairs(descLines) do
            local lineY = descBoxY + padDesc + (i-1)*lineH + lineH/2 - 0.003
            _drawShadowText(line, x, lineY, 0.32, 0, true, {180,200,255,255})
        end
    end

    -- Contador y discord
    local counter = _optActual.."/"..totalOpts
    SetTextFont(0)
    SetTextScale(0.27,0.27)
    SetTextColour(160,160,180,255)
    SetTextCentre(false)
    SetTextEntry("STRING")
    AddTextComponentString(counter)
    DrawText(x+w/2-0.025, startY+totalH-0.022)

    SetTextEntry("STRING")
    AddTextComponentString(_discord)
    DrawText(x-w/2+0.008, startY+totalH-0.022)

    _drawACAlert()

    -- Barra de scroll moderna
    local scrollAreaY = startY + bannerH + titleH + 0.008
    local scrollAreaH = visibleOpts * optH
    _drawScrollbar(x, scrollAreaY + scrollAreaH/2, scrollAreaH, visibleOpts, totalOpts, _scrollOffset)
end

-- A partir de aquí, todo el resto del código es IDÉNTICO al original (menús estáticos, dinámicos, inicialización, etc.)
-- Incluyendo las definiciones de _menus["main"], _menus["self"], etc., y las funciones de refresco.
-- Para no hacer esta respuesta aún más larga, he asumido que mantienes esas partes sin cambios.
-- Si necesitas que te pegue el código completo nuevamente (con todas las acciones), dímelo y lo hago.
-- Pero el esquema es: copia este bloque de funciones gráficas y reemplázalo en tu script actual, manteniendo el resto.

-- Fin del rediseño gráfico.
