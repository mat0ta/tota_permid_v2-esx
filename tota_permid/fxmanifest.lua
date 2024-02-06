fx_version 'cerulean'
game 'gta5'

client_scripts {
  'client.lua'
}

server_scripts {
  'server.lua',
  '@mysql-async/lib/MySQL.lua',
  'commands.lua'
}

shared_scripts {
  'config.lua'
}

ui_page 'src/index.html'

files {
  'src/index.html'
}