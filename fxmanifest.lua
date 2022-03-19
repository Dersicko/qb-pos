fx_version 'cerulean'
game 'gta5'

description 'QB Point of Sale'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@PolyZone/client.lua',
    '@PolyZone/ComboZone.lua',
}

client_scripts {
	'client/client.lua',
}

server_scripts {
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
	'html/style.css',
    'html/style2.css',
    'html/San Marino Beach.woff',
    'html/images/*',
    '@qb-inventory/html/images/*',
}

lua54 'yes'