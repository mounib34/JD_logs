--[[
    #####################################################################
    #                _____           __          _                      #
    #               |  __ \         / _|        | |                     #
    #               | |__) | __ ___| |_ ___  ___| |__                   #
    #               |  ___/ '__/ _ \  _/ _ \/ __| '_ \                  #
    #               | |   | | |  __/ ||  __/ (__| | | |                 #
    #               |_|   |_|  \___|_| \___|\___|_| |_|                 #
    #                                                                   #
    #                 JD_logs By Prefech 01-11-2021                     #
    #                         www.prefech.com                           #
    #                                                                   #
    #####################################################################
]]

author 'Prefech'
description 'FXServer logs to Discord (https://prefech.com/)'
version '2.1.5'
url 'https://prefech.com'

-- Server Scripts
server_scripts {
    'server/server.lua',
    'server/functions.lua'
} 

--Client Scripts
client_scripts {
    'client/client.lua',
    'client/functions.lua',
    'client/weapons.lua'
}

files {
    'config/eventLogs.json',
    'config/config.json'
}

game 'gta5'
fx_version 'cerulean'
