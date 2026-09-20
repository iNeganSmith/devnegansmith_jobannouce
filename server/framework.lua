Framework = Framework or {
    name = nil,
    object = nil
}

local function resourceStarted(name)
    return GetResourceState(name) == 'started'
end

local function normalizeFrameworkName(value)
    value = string.lower(tostring(value or 'auto'))

    if value == 'qbox' then return 'qbx' end
    if value == 'qb' or value == 'qb-core' then return 'qbcore' end
    if value == 'es_extended' then return 'esx' end

    return value
end

function Framework.Detect()
    if Framework.name then
        return Framework.name
    end

    local requested = normalizeFrameworkName(Config.Framework)

    if requested ~= 'auto' then
        if requested == 'qbx' and resourceStarted('qbx_core') then
            Framework.name = 'qbx'
        elseif requested == 'qbcore' and resourceStarted('qb-core') then
            Framework.name = 'qbcore'
        elseif requested == 'esx' and resourceStarted('es_extended') then
            Framework.name = 'esx'
        end
    else
        if resourceStarted('qbx_core') then
            Framework.name = 'qbx'
        elseif resourceStarted('qb-core') then
            Framework.name = 'qbcore'
        elseif resourceStarted('es_extended') then
            Framework.name = 'esx'
        end
    end

    if Framework.name == 'qbcore' then
        local ok, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok then Framework.object = core end
    elseif Framework.name == 'esx' then
        local ok, core = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok then Framework.object = core end
    end

    return Framework.name
end

function Framework.GetPlayerJob(source)
    if not Framework.name then Framework.Detect() end

    if Framework.name == 'qbx' then
        local ok, player = pcall(function()
            return exports.qbx_core:GetPlayer(source)
        end)

        if not ok or not player or not player.PlayerData or not player.PlayerData.job then
            return nil
        end

        local job = player.PlayerData.job
        return {
            name = job.name,
            label = job.label,
            onDuty = job.onduty == true
        }
    end

    if Framework.name == 'qbcore' then
        local player

        local directOk, directPlayer = pcall(function()
            return exports['qb-core']:GetPlayer(source)
        end)

        if directOk and directPlayer then
            player = directPlayer
        elseif Framework.object and Framework.object.Functions then
            player = Framework.object.Functions.GetPlayer(source)
        end

        if not player or not player.PlayerData or not player.PlayerData.job then
            return nil
        end

        local job = player.PlayerData.job
        return {
            name = job.name,
            label = job.label,
            onDuty = job.onduty == true
        }
    end

    if Framework.name == 'esx' then
        local esx = Framework.object
        if not esx then
            local ok, core = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)
            if ok then
                esx = core
                Framework.object = core
            end
        end

        if not esx or not esx.GetPlayerFromId then
            return nil
        end

        local xPlayer = esx.GetPlayerFromId(source)
        if not xPlayer or not xPlayer.getJob then
            return nil
        end

        local job = xPlayer.getJob()
        if not job then return nil end

        local duty = job.onDuty
        if duty == nil then duty = job.onduty end
        if duty == nil then duty = Config.ESXAssumeOnDutyIfMissing end

        return {
            name = job.name,
            label = job.label,
            onDuty = duty == true
        }
    end

    return nil
end
