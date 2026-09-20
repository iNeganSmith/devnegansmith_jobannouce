ClientFramework = ClientFramework or {
    name = nil
}

local function resourceStarted(name)
    return GetResourceState(name) == 'started'
end

function ClientFramework.Detect()
    if ClientFramework.name then return ClientFramework.name end

    local requested = string.lower(tostring(Config.Framework or 'auto'))
    if requested == 'qbox' then requested = 'qbx' end
    if requested == 'qb' or requested == 'qb-core' then requested = 'qbcore' end
    if requested == 'es_extended' then requested = 'esx' end

    if requested ~= 'auto' then
        ClientFramework.name = requested
        return ClientFramework.name
    end

    if resourceStarted('qbx_core') then
        ClientFramework.name = 'qbx'
    elseif resourceStarted('qb-core') then
        ClientFramework.name = 'qbcore'
    elseif resourceStarted('es_extended') then
        ClientFramework.name = 'esx'
    end

    return ClientFramework.name
end

ClientFramework.Detect()
