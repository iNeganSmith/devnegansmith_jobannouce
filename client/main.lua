local function getLocationLabel(coords)
    if not coords or not coords.x or not coords.y or not coords.z then
        return Locale.location_unknown
    end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)

    if not x or not y or not z then
        return Locale.location_unknown
    end

    local streetHash, crossingHash = GetStreetNameAtCoord(x, y, z)
    local street = streetHash and streetHash ~= 0 and GetStreetNameFromHashKey(streetHash) or ''
    local crossing = crossingHash and crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or ''

    local zoneCode = GetNameOfZone(x, y, z)
    local zone = ''

    if zoneCode and zoneCode ~= '' then
        local zoneLabel = GetLabelText(zoneCode)
        if zoneLabel and zoneLabel ~= 'NULL' then
            zone = zoneLabel
        end
    end

    local parts = {}

    if zone ~= '' then
        parts[#parts + 1] = zone
    end

    if street ~= '' then
        local streetText = street
        if crossing ~= '' and crossing ~= street then
            streetText = ('%s / %s'):format(street, crossing)
        end
        parts[#parts + 1] = streetText
    end

    if #parts == 0 then
        return Locale.location_unknown
    end

    return table.concat(parts, ' - ')
end

local function nativeNotify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(tostring(message or ''))
    EndTextCommandThefeedPostTicker(false, false)
end

RegisterNetEvent('negan_jobannouncements:client:notify', function(message)
    nativeNotify(message)
end)

RegisterNetEvent('negan_jobannouncements:client:showAnnouncement', function(data)
    if type(data) ~= 'table' then return end

    local location = nil
    if data.showLocation then
        location = getLocationLabel(data.coords)
    end

    SendNUIMessage({
        action = 'announcement',
        data = {
            job = data.job,
            label = data.label,
            subtitle = data.subtitle,
            logo = data.logo,
            accent = data.accent,
            accentSoft = data.accentSoft,
            message = data.message,
            location = location,
            duration = data.duration,
            sound = data.sound,
            soundVolume = data.soundVolume,
            soundFile = data.soundFile,
            enableQueue = data.enableQueue,
            maxQueue = data.maxQueue,
            position = data.position
        }
    })
end)
