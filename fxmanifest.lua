fx_version 'cerulean'
game 'gta5'

author 'FjamZoo#0001 & MannyOnBrazzers#6826'
description 'A No Pixel inspired edit of QBCore\'s Phone. Released By RenewedScripts'
version '2.0.0'

dependencies {
    'ox_lib',
    'ox_target'
}

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    'shared/shared.lua',
    '@qb-apartments/config.lua',
    '@qb-garages/config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

files {
    'html/*.html',
    'html/js/*.js',
    'html/img/*.png',
    'html/css/*.css',
    'html/img/backgrounds/*.png',
    'html/img/apps/*.png',
}

lua54 'yes'

dependency 'qb-target'
