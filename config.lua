-- CONFIGURACIÓN DEL BANNER PERSONALIZADO
local BANNER_URL = "https://raw.githubusercontent.com/Sentexz/sentexmodz/refs/heads/main/JV6Drrz.png"  -- <-- CAMBIA A TU URL RAW

-- Variable global para la función de dibujo
DrawCustomBanner = nil

-- Función para cargar la textura desde URL (compatible con GitHub raw)
local function LoadBannerTexture()
    local dict = "sentex_banner"
    local txd = CreateRuntimeTxd(dict)
    if not txd then return false end
    local success = CreateRuntimeTextureFromImage(txd, "banner", BANNER_URL)
    if success then
        print("^2[SENTEX] Banner cargado correctamente desde GitHub")
        return true
    else
        print("^1[SENTEX] No se pudo cargar el banner. Verifica la URL.")
        return false
    end
end

-- Definir la función que dibujará el banner (será llamada desde el menú)
function DrawCustomBanner(x, y, width, height)
    local dict = "sentex_banner"
    if not HasStreamedTextureDictLoaded(dict) then
        if not LoadBannerTexture() then
            -- Fallback: rectángulo azul con texto
            DrawRect(x, y, width, height, 0, 80, 160, 255)
            SetTextFont(1)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("SENTEXMODZ")
            DrawText(x, y - 0.01)
            return
        end
    end
    if HasStreamedTextureDictLoaded(dict) then
        DrawSprite(dict, "banner", x, y, width, height, 0.0, 255, 255, 255, 255)
    else
        RequestStreamedTextureDict(dict, false)
    end
end

print("^2[SENTEX] Configuración del banner cargada. URL: " .. BANNER_URL)
