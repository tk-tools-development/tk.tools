fx_version 'cerulean'
game 'gta5'

name 'tk-fighting'
description 'GTA IV Style Fighting Animations - Heavy punches, hit reactions, weaving, blocking & combos'
author 'TK Tools Development'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/utils.lua',
    'client/animations.lua',
    'client/combat.lua',
    'client/reactions.lua',
    'client/dodge.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}
