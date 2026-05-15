-- ==================== DUMP DE RECURSOS (CORREGIDO) ====================
function ShowResourceInfo(resource)
    local success, state = pcall(function()
        return GetResourceState(resource)
    end)
    if not success then
        MostrarNotificacion("~r~No se pudo obtener el estado del recurso")
        return
    end
    local status = "~g~Iniciado"
    if state == "started" then
        status = "~g~Iniciado"
    elseif state == "stopped" then
        status = "~r~Detenido"
    else
        status = "~y~" .. tostring(state)
    end
    MostrarNotificacion("~b~" .. resource .. "~s~ | Estado: " .. status)
end

function RefreshResourcesListMenu()
    local resources = {}
    local success, num = pcall(GetNumResources)
    if not success then
        opcionesMenu["resources_list"] = { { nombre = "• Error: No se pueden listar recursos", accion = nil, desc = "Función no disponible" } }
        return
    end
    for i = 0, num - 1 do
        local resource = GetResourceByFindIndex(i)
        if resource and resource ~= "" then
            table.insert(resources, resource)
        end
        Citizen.Wait(0)
    end
    if #resources == 0 then
        opcionesMenu["resources_list"] = { { nombre = "• No se encontraron recursos", accion = nil, desc = "Lista vacía" } }
        return
    end
    local opts = {}
    for i, res in ipairs(resources) do
        opts[i] = {
            nombre = "• " .. res,
            accion = function() ShowResourceInfo(res) end,
            desc = "Haz clic para ver estado"
        }
    end
    opcionesMenu["resources_list"] = opts
end
