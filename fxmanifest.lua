fx_version 'cerulean'
game       'gta5'

author      'TonNom'
description 'Admin-BossMenu avec whitelist Discord'
version     '1.0.0'

shared_scripts { 'config.lua', '@es_extended/imports.lua' }

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/main.lua'
}

client_scripts { 'client/main.lua' }

ui_page 'html/index.html'
files { 'html/*.*' }
