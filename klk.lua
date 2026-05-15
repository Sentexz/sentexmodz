-- ==================== SERVER RESOURCES (VERSIÓN SEGURA) ====================
local serverResources = {}
local resourceScanComplete = false
local isScanning = false

function ScanServerResources()
    if isScanning then return end
    isScanning = true
    serverResources = {}
    
    -- Mostrar notificación de carga
    MostrarNotificacion("~y~Escaneando recursos del servidor...")
    
    -- Usar un hilo separado para no bloquear el menú
    Citizen.CreateThread(function()
        local success, num = pcall(GetNumResources)
        if not success or type(num) ~= "number" then
            MostrarNotificacion("~r~Error: No se puede obtener la lista de recursos")
            isScanning = false
            resourceScanComplete = true
            return
        end
        
        for i = 0, num - 1 do
            local resName = GetResourceByFindIndex(i)
            if resName and resName ~= "" then
                local state = "unknown"
                local successState, resState = pcall(GetResourceState, resName)
                if successState then state = resState end
                table.insert(serverResources, {
                    name = resName,
                    state = state,
                })
            end
            Citizen.Wait(0) -- Pequeña pausa para no saturar
        end
        
        resourceScanComplete = true
        isScanning = false
        MostrarNotificacion("~g~Escaneo completado: " .. #serverResources .. " recursos encontrados")
        
        -- Si el menú está actualmente en resources_list, refrescar la vista
        if currentMenu == "resources_list" then
            RefreshResourcesListMenu()
        end
    end)
end

function ShowResourceInfo(res)
    local stateColor = (res.state == "started") and "~g~" or (res.state == "stopped") and "~r~" or "~y~"
    MostrarNotificacion("~b~" .. res.name .. "~s~ | Estado: " .. stateColor .. res.state .. "~s~")
end

function RefreshResourcesListMenu()
    -- Si todavía está escaneando, mostrar un mensaje de carga
    if isScanning then
        opcionesMenu["resources_list"] = {
            { nombre = "⏳ Cargando recursos...", accion = nil, desc = "Espera un momento" },
            { nombre = "↻ Reintentar", accion = function() ScanServerResources(); RefreshResourcesListMenu() end, desc = "Vuelve a escanear" }
        }
        return
    end
    
    if not resourceScanComplete then
        ScanServerResources()
        opcionesMenu["resources_list"] = {
            { nombre = "⏳ Escaneando...", accion = nil, desc = "Por favor espera" }
        }
        return
    end
    
    local opts = {}
    -- Opción de refrescar
    table.insert(opts, {
        nombre = "↻ Refresh list",
        accion = function()
            resourceScanComplete = false
            ScanServerResources()
            RefreshResourcesListMenu()
        end,
        desc = "Vuelve a escanear los recursos"
    })
    -- Separador
    table.insert(opts, { nombre = "── RECURSOS (" .. #serverResources .. ") ──", accion = nil, desc = "" })
    
    -- Si no hay recursos, mostrar mensaje
    if #serverResources == 0 then
        table.insert(opts, { nombre = "• No se encontraron recursos", accion = nil, desc = "" })
    else
        -- Añadir cada recurso (limitado a 200 para evitar saturar el menú)
        local maxDisplay = 200
        for i, res in ipairs(serverResources) do
            if i > maxDisplay then
                table.insert(opts, { nombre = "... y " .. (#serverResources - maxDisplay) .. " recursos más", accion = nil, desc = "Usa 'Refresh list' para ver todos" })
                break
            end
            local icon = (res.state == "started") and "🟢" or (res.state == "stopped") and "🔴" or "🟡"
            table.insert(opts, {
                nombre = icon .. " " .. res.name,
                accion = function() ShowResourceInfo(res) end,
                desc = "Estado: " .. res.state
            })
        end
    end
    
    opcionesMenu["resources_list"] = opts
end

-- Inicializar el escaneo al cargar el menú (opcional)
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Esperar a que todo cargue
    ScanServerResources()
end)
