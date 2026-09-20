fx_version 'cerulean'
game 'gta5'

name 'negan_jobannouncements'
author 'DevNeganSmith'
description 'Anuncios públicos de servicios para QBX, QBCore y ESX Legacy'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    'locales/es.lua'
}

client_scripts {
    'client/framework.lua',
    'client/main.lua'
}

server_scripts {
    'server/framework.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/img/jobs/*.png',
    'html/sounds/*.wav'
}
