fx_version 'cerulean'
game 'gta5'

author 'Respawn Modifications'
description 'Simple script for logging points given to players for rule violations with a UI'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/main.js'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}
