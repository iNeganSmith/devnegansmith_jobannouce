local cooldowns = {}

local function debugPrint(message)
    if Config.Debug then
        print(('[negan_jobannouncements] %s'):format(message))
    end
end

local function notify(source, message, kind)
    TriggerClientEvent('negan_jobannouncements:client:notify', source, message, kind or 'error')
end

local function trim(value)
    return (tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function normalizeMessage(value)
    value = tostring(value or '')
    value = value:gsub('[%z\1-\8\11\12\14-\31\127]', '')
    value = value:gsub('[\r\n\t]+', ' ')
    value = value:gsub('%s%s+', ' ')
    return trim(value)
end

local function characterLength(value)
    if utf8 and utf8.len then
        local ok, length = pcall(utf8.len, value)
        if ok and length then return length end
    end

    return #value
end

local function cooldownKey(source)
    local ok, license = pcall(function()
        return GetPlayerIdentifierByType(source, 'license')
    end)

    if ok and license and license ~= '' then
        return license
    end

    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and identifier:sub(1, 8) == 'license:' then
            return identifier
        end
    end

    return ('source:%s'):format(source)
end

local function getRemainingCooldown(source)
    local key = cooldownKey(source)
    local expiresAt = cooldowns[key]
    if not expiresAt then return 0 end

    local remaining = expiresAt - os.time()
    if remaining <= 0 then
        cooldowns[key] = nil
        return 0
    end

    return remaining
end

local function setCooldown(source)
    local cooldown = math.max(0, tonumber(Config.Cooldown) or 0)
    if cooldown <= 0 then return end
    cooldowns[cooldownKey(source)] = os.time() + cooldown
end

local function getServerCoords(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return nil end

    local coords = GetEntityCoords(ped)
    if not coords then return nil end

    return {
        x = coords.x + 0.0,
        y = coords.y + 0.0,
        z = coords.z + 0.0
    }
end

local function buildAnnouncement(jobName, jobConfig, message, source)
    return {
        job = jobName,
        label = jobConfig.label or jobName,
        subtitle = jobConfig.subtitle or 'ANUNCIO DE SERVICIO',
        logo = jobConfig.logo or '',
        accent = jobConfig.accent or '#FFFFFF',
        accentSoft = jobConfig.accentSoft or 'rgba(255, 255, 255, 0.18)',
        message = message,
        coords = Config.ShowLocation and getServerCoords(source) or nil,
        showLocation = Config.ShowLocation == true,
        duration = math.max(1000, tonumber(Config.Duration) or 10000),
        sound = Config.Sound == true,
        soundVolume = math.max(0.0, math.min(1.0, tonumber(Config.SoundVolume) or 0.20)),
        soundFile = tostring(Config.SoundFile or 'sounds/notify.wav'),
        enableQueue = Config.EnableQueue == true,
        maxQueue = math.max(1, tonumber(Config.MaxQueue) or 5),
        position = tostring(Config.Position or 'top-center')
    }
end

local function handleAnnouncementCommand(source, args)
    if source == 0 then
        print('[negan_jobannouncements] /anuncio solo puede utilizarse dentro del juego.')
        return
    end

    local frameworkName = Framework.Detect()
    if not frameworkName then
        notify(source, Locale.framework_error)
        return
    end

    local job = Framework.GetPlayerJob(source)
    if not job or not job.name then
        notify(source, Locale.player_error)
        return
    end

    local jobConfig = Config.Jobs[job.name]
    if not jobConfig then
        notify(source, Locale.no_permission)
        return
    end

    if Config.RequireDuty and not job.onDuty then
        notify(source, Locale.not_on_duty)
        return
    end

    local message = normalizeMessage(table.concat(args or {}, ' '))
    if message == '' then
        notify(source, Locale.no_message)
        return
    end

    local messageLength = characterLength(message)
    local maxLength = math.max(1, tonumber(Config.MaxMessageLength) or 150)
    if messageLength > maxLength then
        notify(source, Locale.message_too_long:format(maxLength))
        return
    end

    local remaining = getRemainingCooldown(source)
    if remaining > 0 then
        notify(source, Locale.cooldown:format(remaining))
        return
    end

    setCooldown(source)

    local announcement = buildAnnouncement(job.name, jobConfig, message, source)
    TriggerClientEvent('negan_jobannouncements:client:showAnnouncement', -1, announcement)

    debugPrint(('Anuncio enviado por %s (%s) usando %s'):format(GetPlayerName(source) or source, job.name, frameworkName))
end

CreateThread(function()
    local frameworkName = Framework.Detect()

    if frameworkName then
        print(('[negan_jobannouncements] Framework detectado: %s'):format(frameworkName))
    else
        print('^1[negan_jobannouncements] ERROR: No se detectó QBX, QBCore ni ESX Legacy.^0')
    end
end)

RegisterCommand(Config.Command, function(source, args)
    handleAnnouncementCommand(source, args)
end, false)

AddEventHandler('playerDropped', function()
    -- Los cooldowns usan licencia cuando está disponible, por lo que no se eliminan
    -- al desconectar durante la misma ejecución del recurso.
end)
