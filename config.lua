Config = {}

-- auto | qbx | qbcore | esx
-- 'auto' detecta automáticamente QBX/Qbox, QBCore o ESX Legacy.
Config.Framework = 'auto'

Config.Command = 'anuncio'
Config.Duration = 10000          -- milisegundos
Config.Cooldown = 30             -- segundos
Config.MaxMessageLength = 150    -- caracteres
Config.ShowLocation = true
Config.RequireDuty = true

Config.EnableQueue = true
Config.MaxQueue = 5

Config.Sound = true
Config.SoundVolume = 0.20
Config.SoundFile = 'sounds/notify.wav'

-- top-center | top-left | top-right | bottom-center
Config.Position = 'bottom-center'

-- ESX no siempre expone duty en todos los forks/servidores.
-- Si el campo no existe, true permite el anuncio y false lo bloquea.
Config.ESXAssumeOnDutyIfMissing = true

Config.Debug = false

-- Puedes añadir nuevos jobs sin modificar el código principal.
-- Reemplaza los PNG dentro de html/img/jobs/ manteniendo el nombre,
-- o cambia la propiedad logo por otro archivo de esa carpeta.
Config.Jobs = {
    police = {
        label = 'POLICE',
        subtitle = 'COMUNICADO OFICIAL',
        logo = 'police.png',
        accent = '#358d1f',
        accentSoft = 'rgba(37, 99, 18, 0.71)'
    },

    ambulance = {
        label = 'EMS',
        subtitle = 'AVISO DE EMERGENCIA',
        logo = 'ambulance.png',
        accent = '#44dcf0',
        accentSoft = 'rgba(17, 184, 196, 0.81)'
    },

    mechanic = {
        label = 'MECHANIC',
        subtitle = 'ASISTENCIA EN CARRETERA',
        logo = 'mechanic.png',
        accent = '#e99d39',
        accentSoft = 'rgba(240, 168, 75, 0.20)'
    }
}
