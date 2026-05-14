--[[
    SENTEXMODZ PREMIUM 2026 - Menú completo
    Incluye banner personalizado, sistema de dibujo y navegación.
]]

-- ==================== CONFIGURACIÓN ====================
local BANNER_URL = "https://i.ibb.co/4nTvq9w9/k-ZN3Yet.png"   -- <-- CAMBIA AQUÍ LA URL DE TU BANNER
local OPEN_KEY = 11   -- PAGEDOWN (11)

-- ==================== VARIABLES GLOBALES ====================
local menuAbierto = false
local currentMenu = "main"
local currentOption = 1
local opcionesMenu = {}
local descripcionActual = ""

-- Colores y estilos
local neonColor = {0, 255, 255, 255}
local neonGlow = {0, 180, 255, 80}
local bgColor = {0, 0, 0, 210}
local bannerColor = {0, 80, 160, 255}  -- color de respaldo si falla el banner
local selectBg = {30, 144, 255, 60}

-- ==================== FUNCIONES DE UTILIDAD ====================
local function MostrarNotificacion(texto)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(texto)
    DrawNotification(false, false)
end

-- ==================== ACCIONES DEL MENÚ ====================
function Curar()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)
    MostrarNotificacion("~g~Salud y armadura restauradas")
end

function RevivirESX()
    TriggerEvent('esx_ambulancejob:revive')
    MostrarNotificacion("~g~Reviviendo (ESX Sentex Bypass)")
end

function RevivirQB()
    TriggerEvent("hospital:client:Revive")
    MostrarNotificacion("~g~Reviviendo (QB Sentex Bypass)")
end

-- ==================== DEFINICIÓN DEL MENÚ ====================
opcionesMenu["main"] = {
    { nombre = "❤️ Self Options", submenu = "self", desc = "Accede a las opciones avanzadas" },
}
opcionesMenu["self"] = {
    { nombre = "❤️ Curar", accion = Curar, desc = "Restaura completamente salud y armadura" },
    { nombre = "⚕️ Revivir (ESX)", accion = RevivirESX, desc = "Revive mediante bypass ESX" },
    { nombre = "⚕️ Revivir (QB)", accion = RevivirQB, desc = "Revive mediante bypass QB" },
}

-- ==================== DIBUJO DE TEXTO CON SOMBRA ====================
local function DrawShadowText(text, x, y, scale, font, center, color)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextCentre(center)
    SetTextDropshadow(1, 0, 0, 0, 200)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- ==================== BANNER PERSONALIZADO ====================
local bannerTextureDict = "sentex_banner"
local bannerLoaded = false

local function LoadBanner()
    if bannerLoaded then return true end
    -- Usar CreateRuntimeTextureFromImage (funciona en la mayoría de servidores actualizados)
    local success = CreateRuntimeTextureFromImage(bannerTextureDict, "banner", BANNER_URL)
    if success then
        bannerLoaded = true
        print("^2[SENTEX] Banner cargado correctamente")
    else
        print("^1[SENTEX] Fallo al cargar banner, usando fondo sólido")
    end
    return success
end

local function DrawCustomBanner(x, y, width, height)
    if not bannerLoaded then
        if not LoadBanner() then
            -- Fallback: rectángulo de color
            DrawRect(x, y, width, height, bannerColor[1], bannerColor[2], bannerColor[3], bannerColor[4])
            DrawShadowText("SENTEXMODZ", x, y - 0.01, 0.5, 1, true, {255,255,255,255})
            return
        end
    end
    if HasStreamedTextureDictLoaded(bannerTextureDict) then
        DrawSprite(bannerTextureDict, "banner", x, y, width, height, 0.0, 255, 255, 255, 255)
    else
        RequestStreamedTextureDict(bannerTextureDict, false)
        DrawRect(x, y, width, height, bannerColor[1], bannerColor[2], bannerColor[3], bannerColor[4])
    end
end

-- ==================== DIBUJO DEL MENÚ ====================
function DibujarMenu()
    local ancho = 0.26
    local x = 0.7
    local y = 0.2
    local altoBanner = 0.11
    local altoTitulo = 0.045
    local altoOpcion = 0.042
    local lineaH = 0.032
    local paddingDesc = 0.005

    local opciones = opcionesMenu[currentMenu]
    local numOpt = #opciones

    -- Preparar descripción (máximo 2 líneas)
    local lineasDesc = {}
    if descripcionActual and descripcionActual ~= "" then
        local temp = descripcionActual
        while #temp > 50 and #lineasDesc < 2 do
            local cut = temp:sub(1,50):match("^.*[ ,]") or temp:sub(1,50)
            table.insert(lineasDesc, cut)
            temp = temp:sub(#cut+1)
        end
        if #temp > 0 and #lineasDesc < 2 then
            table.insert(lineasDesc, temp)
        end
    end
    local descH = #lineasDesc * lineaH + paddingDesc * 2
    if #lineasDesc == 0 then descH = 0.02 end

    local totalAlto = altoBanner + altoTitulo + (numOpt * altoOpcion) + descH + 0.015
    local startY = y

    -- Fondo principal
    DrawRect(x, startY + totalAlto/2, ancho, totalAlto, bgColor[1], bgColor[2], bgColor[3], bgColor[4])

    -- Bordes ultrafinos
    DrawRect(x, startY, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x, startY + totalAlto, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x - ancho/2, startY + totalAlto/2, 0.0005, totalAlto, neonColor[1], neonColor[2], neonColor[3], neonColor[4])
    DrawRect(x + ancho/2, startY + totalAlto/2, 0.0005, totalAlto, neonColor[1], neonColor[2], neonColor[3], neonColor[4])

    -- Resplandor exterior
    DrawRect(x, startY, ancho + 0.006, 0.001, neonGlow[1], neonGlow[2], neonGlow[3], neonGlow[4])
    DrawRect(x, startY + totalAlto, ancho + 0.006, 0.001, neonGlow[1], neonGlow[2], neonGlow[3], neonGlow[4])

    -- Banner personalizado
    DrawCustomBanner(x, startY + altoBanner/2, ancho - 0.01, altoBanner - 0.01)

    -- Línea de brillo bajo el banner
    DrawRect(x, startY + altoBanner - 0.001, ancho, 0.0005, neonColor[1], neonColor[2], neonColor[3], 200)

    -- Título de la sección
    local tituloY = startY + altoBanner + 0.008
    local tituloStr = (currentMenu == "main" and "=== MENU PRINCIPAL ===") or (currentMenu == "self" and "⚙️ SELF OPTIONS ⚙️")
    DrawShadowText(tituloStr, x, tituloY, 0.48, 0, true, neonColor)

    -- Opciones
    local optsY = startY + altoBanner + altoTitulo + 0.008
    for i, opt in ipairs(opciones) do
        local yOff = optsY + (i-1) * altoOpcion
        local color = (i == currentOption) and neonColor or {200,200,200,255}
        if i == currentOption then
            DrawRect(x, yOff + altoOpcion/2 - 0.005, ancho - 0.01, altoOpcion - 0.005, selectBg[1], selectBg[2], selectBg[3], selectBg[4])
        end
        DrawShadowText(opt.nombre, x - ancho/2 + 0.02, yOff, 0.4, 0, false, color)
        if i == currentOption then
            descripcionActual = (opt.desc or "Selecciona una opción") .. " "
        end
    end

    -- Descripción (solo texto)
    local descY = startY + altoBanner + altoTitulo + (numOpt * altoOpcion) + 0.008
    if #lineasDesc > 0 then
        for i, linea in ipairs(lineasDesc) do
            local lineY = descY + paddingDesc + (i-1) * lineaH + lineaH/2 - 0.008
            DrawShadowText(linea, x, lineY, 0.32, 0, true, {210,210,255,255})
        end
    end
end

-- ==================== HILO PRINCIPAL DEL MENÚ ====================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsDisabledControlJustReleased(0, OPEN_KEY) then
            menuAbierto = not menuAbierto
            if menuAbierto then
                currentOption = 1
                currentMenu = "main"
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                MostrarNotificacion("~b~★ SENTEXMODZ PREMIUM 2026 ★~s~ | Menú abierto")
            else
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
            Citizen.Wait(200)
        end

        if menuAbierto then
            DibujarMenu()
            local maxOpt = #opcionesMenu[currentMenu]

            if IsDisabledControlJustReleased(0, 172) then
                currentOption = currentOption - 1
                if currentOption < 1 then currentOption = maxOpt end
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsDisabledControlJustReleased(0, 173) then
                currentOption = currentOption + 1
                if currentOption > maxOpt then currentOption = 1 end
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif IsDisabledControlJustReleased(0, 191) then
                local sel = opcionesMenu[currentMenu][currentOption]
                if sel then
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    if sel.submenu then
                        currentMenu = sel.submenu
                        currentOption = 1
                    elseif sel.accion then
                        sel.accion()
                    end
                end
            elseif IsDisabledControlJustReleased(0, 177) then
                if currentMenu ~= "main" then
                    currentMenu = "main"
                    currentOption = 1
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                else
                    menuAbierto = false
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
        end
    end
end)

-- Notificación de bienvenida
Citizen.CreateThread(function()
    Citizen.Wait(1500)
    MostrarNotificacion("~b~★ SENTEXMODZ PREMIUM 2026 ★~s~ | Presiona ~y~PAGEDOWN~s~ para abrir")
end)

print("^2[SENTEX] Menú cargado correctamente. Usa PAGEDOWN para abrir.")
