--[[
    #####################################################################
    #                _____           __          _                      #
    #               |  __ \         / _|        | |                     #
    #               | |__) | __ ___| |_ ___  ___| |__                   #
    #               |  ___/ '__/ _ \  _/ _ \/ __| '_ \                  #
    #               | |   | | |  __/ ||  __/ (__| | | |                 #
    #               |_|   |_|  \___|_| \___|\___|_| |_|                 #
    #                                                                   #
    #                 JD_logs By Prefech 23-11-2021                     #
    #                         www.prefech.com                           #
    #                                                                   #
    #####################################################################
]]

local JD_Debug = false -- Enable when you have issues or when asked by Prefech DevTeam

RegisterNetEvent("discordLogs")
AddEventHandler("discordLogs", function(message, color, channel)
    discordLog(message, color, channel)
end)

RegisterNetEvent("ClientUploadScreenshot")
AddEventHandler("ClientUploadScreenshot", function(args)
	ServerFunc.CreateLog(args)
end)

exports('discord', function(msg, player_1, player_2, color, channel)
	args ={
		['EmbedMessage'] = msg,
		['color'] = color,
		['channel'] = channel
	}
	if player_1 ~= 0 then
		args['player_id'] = player_1
	end
	if player_2 ~= 0 then
		args['player_2_id'] = player_2
	end
	ServerFunc.CreateLog(args)
	TriggerEvent('JD_logs:Debug', 'Server Old Export', args)
end)

exports('createLog', function(args)
	if args.screenshot then
		local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./json/webhooks.json")
		local webhooksFile = json.decode(webhooksLaodFile)
		args['url'] = webhooksFile['imageStore'].webhook
		TriggerClientEvent('ClientCreateScreenshot', args.player_id, args)
	else
		ServerFunc.CreateLog(args)
	end
	TriggerEvent('JD_logs:Debug', 'Server New Export', args)
end)

-- Event Handlers
-- Send message when Player connects to the server.
AddEventHandler("playerConnecting", function(name, setReason, deferrals)
	ServerFunc.CreateLog({EmbedMessage = '**' ..GetPlayerName(source).. '** is connecting to the server.', player_id = source, channel = 'joins'})

	local loadFile = LoadResourceFile(GetCurrentResourceName(), "./json/names.json")
	local loadedFile = json.decode(loadFile)
	local conaifFile = LoadResourceFile(GetCurrentResourceName(), "./json/names.json")
	local cfgFile = json.decode(conaifFile)
    local steam = ExtractIdentifiers(source).steam

    if loadedFile[steam] ~= nil then 
        if loadedFile[steam] ~= GetPlayerName(source) then 
            for _, i in ipairs(GetPlayers()) do
                if IsPlayerAceAllowed(i, cfgFile.nameChangePerms) then 
                    TriggerClientEvent('chat:addMessage', i, {
                        template = '<div style="background-color: rgba(90, 90, 90, 0.9); text-align: center; border-radius: 0.5vh; padding: 0.7vh; font-size: 1.7vh;"><b>Player ^1{0} ^0used to be named ^1{1}</b></div>',
                        args = { GetPlayerName(source), loadedFile[steam] }
                    })
                end
            end
			ServerFunc.CreateLog({EmbedMessage = 'Player **" .. GetPlayerName(source) .. "** used to be named **" ..loadedFile[steam].."**', player_id = source, channel = 'NameChange'})
        end
    end
    loadedFile[steam] = GetPlayerName(source)
    SaveResourceFile(GetCurrentResourceName(), "./json/names.json", json.encode(loadedFile), -1)
end)

-- Send message when Player disconnects from the server
AddEventHandler('playerDropped', function(reason)
	ServerFunc.CreateLog({EmbedMessage = '**' ..GetPlayerName(source).. '** has left the server. (Reason: ' .. reason .. ')', player_id = source, channel = 'leaving'})
end)

-- Send message when Player creates a chat message (Does not show commands)
AddEventHandler('chatMessage', function(source, name, msg)
	ServerFunc.CreateLog({EmbedMessage = '**'..GetPlayerName(source) .. '**: `' .. msg..'`', player_id = source, channel = 'chat'})
end)

-- Send message when Player died (including reason/killer check) (Not always working)
RegisterServerEvent('playerDied')
AddEventHandler('playerDied',function(args)
	if args.weapon == nil then _Weapon = "" else _Weapon = ""..args.weapon.."" end
	if args.type == 1 then  -- Suicide/died
		ServerFunc.CreateLog({
			EmbedMessage = '**'..GetPlayerName(source) .. '** `'..args.death_reason..'` '.._Weapon, 
			player_id = source,
			channel = 'deaths'
		})
	elseif args.type == 2 then -- Killed by other player
		ServerFunc.CreateLog({
			EmbedMessage = '**' .. GetPlayerName(args.player_2_id) .. '** '..args.death_reason..' **' .. GetPlayerName(source).. '** `('.._Weapon..')`', 
			player_id = source,
			player_2_id = args.player_2_id,
			channel = 'deaths'
		})
	else -- When gets killed by something else
		ServerFunc.CreateLog({
			EmbedMessage = '**'..GetPlayerName(source) .. '** `'..args.death_reason..'` '.._Weapon, 
			player_id = source,
			channel = 'deaths'
		})
	end
end)

-- Send message when Player fires a weapon
RegisterServerEvent('playerShotWeapon')
AddEventHandler('playerShotWeapon', function(weapon)
	local configLoadFile = LoadResourceFile(GetCurrentResourceName(), "./json/config.json")
	local configFile = json.decode(configLoadFile)
	if configFile['weaponLog'] then
		ServerFunc.CreateLog({EmbedMessage = '**' .. GetPlayerName(source)  .. '** fired a `' .. weapon .. '`', player_id = source, channel = 'shooting'})
    end
end)

-- Getting exports from clientside
RegisterServerEvent('ClientDiscord')
AddEventHandler('ClientDiscord', function(args)
	if args.screenshot then
		local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./json/webhooks.json")
		local webhooksFile = json.decode(webhooksLaodFile)
		args['url'] = webhooksFile['imageStore'].webhook
		TriggerClientEvent('ClientCreateScreenshot', args.player_id, args)
	else
		ServerFunc.CreateLog(args)
	end
end)

-- Send message when a resource is being stopped
AddEventHandler('onResourceStop', function (resourceName)
	ServerFunc.CreateLog({EmbedMessage = '**' .. resourceName .. '** has been stopped.', channel = 'resources'})
end)

-- Send message when a resource is being started
AddEventHandler('onResourceStart', function (resourceName)
    Citizen.Wait(100)
	ServerFunc.CreateLog({EmbedMessage = '**' .. resourceName .. '** has been started.', channel = 'resources'})
end)

RegisterNetEvent('JD_logs:Debug')
AddEventHandler('JD_logs:Debug' function(msg, err)
	if JD_Debug then
		print("^1 Error: JD_logs"..msg.."^0")
		print("^1"..err.."^0")
	end
end)

-- version check
Citizen.CreateThread( function()
		SetConvarServerInfo("JD_logs", "V"..GetResourceMetadata(GetCurrentResourceName(), 'version'))
		if GetResourceMetadata(GetCurrentResourceName(), 'version') then
			PerformHttpRequest(
				'https://raw.githubusercontent.com/Prefech/JD_logs/master/json/version.json',
				function(code, res, headers)
					if code == 200 then
						local rv = json.decode(res)
						if rv.version ~= GetResourceMetadata(GetCurrentResourceName(), 'version') then
							print(
								([[^1-------------------------------------------------------
JD_logs
UPDATE: %s AVAILABLE
CHANGELOG: %s
-------------------------------------------------------^0]]):format(
									rv.version,
									rv.changelog
								)
							)
						end
					else
						print('JD_logs unable to check version')
					end
				end,
				'GET'
			)
		end
	end
)
