-- CONFIGURACIÓN DEL BANNER PERSONALIZADO
local bannerURL = "https://turaw.githubusercontent.com/tuusuario/turepo/main/tu_imagen.png"  -- <--- CAMBIA ESTA URL

-- Esta función será llamada desde el menú para dibujar el banner
function DrawCustomBanner(x, y, width, height)
    local dict = "sentex_banner"
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict, false)
        return
    end
    DrawSprite(dict, "banner", x, y, width, height, 0.0, 255, 255, 255, 255)
end

-- Cargar la textura desde la URL
Citizen.CreateThread(function()
    local success = CreateRuntimeTextureFromImage(dict, "banner", bannerURL)
    if not success then
        print("^1[SENTEX] No se pudo cargar el banner. Verifica la URL.")
    else
        print("^2[SENTEX] Banner personalizado cargado correctamente.")
    end
end)
