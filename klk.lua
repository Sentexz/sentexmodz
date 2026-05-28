-- PRUEBA MÍNIMA: solo dibuja un rectángulo rojo al presionar PAGEDOWN
local menuVisible = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 11) then -- PAGEDOWN
            menuVisible = not menuVisible
            print("[SENTEX] PAGEDOWN presionada, menuVisible =", menuVisible)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if menuVisible then
            DrawRect(0.5, 0.5, 0.2, 0.1, 255, 0, 0, 200)
            SetTextFont(4)
            SetTextScale(1.0, 1.0)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("MENU DE PRUEBA")
            DrawText(0.5, 0.5)
        end
    end
end)

function StartMenu()
    print("[SENTEX] Script de prueba iniciado. Presiona PAGEDOWN.")
end

return { Start = StartMenu }
