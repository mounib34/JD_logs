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

local JD_Debug = false -- Enable when you have issues or when asked by Prefech Staff

RegisterNetEvent('Prefech:JD_logs:Debug')
AddEventHandler('Prefech:JD_logs:Debug', log)

RegisterNetEvent('Prefech:JD_logs:errorLog')
AddEventHandler('Prefech:JD_logs:errorLog', errorLog)

function debugLog(x)
	if JD_Debug then
		print("^5[JD_logs]^0 " .. x)
	end
end

function errorLog(x)
	print("^5[JD_logs]^1 " .. x .."^0")
end

RegisterNetEvent("Prefech:discordLogs")
AddEventHandler("Prefech:discordLogs", function(message, color, channel)
    discordLog(message, color, channel)
end)

RegisterNetEvent("Prefech:ClientUploadScreenshot")
AddEventHandler("Prefech:ClientUploadScreenshot", function(args)
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
	debugLog('Server Old Export: '.. table.concat(args, "; "))
end)

exports('createLog', function(args)
	if args.screenshot then
		local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./json/webhooks.json")
		local webhooksFile = json.decode(webhooksLaodFile)
		args['url'] = webhooksFile['imageStore'].webhook
		TriggerClientEvent('Prefech:ClientCreateScreenshot', args.player_id, args)
	else
		ServerFunc.CreateLog(args)
	end
	debugLog('Server New Export: '.. table.concat(args, "; "))
end)

-- Event Handlers
-- Send message when Player connects to the server.
AddEventHandler("playerConnecting", function(name, setReason, deferrals)
	deferrals.defer()
	ServerFunc.CreateLog({EmbedMessage = '**' ..GetPlayerName(source).. '** is connecting to the server.', player_id = source, channel = 'joins'})

	local loadFile = LoadResourceFile(GetCurrentResourceName(), "./json/names.json")
	local loadedFile = json.decode(loadFile)
	local configFile = LoadResourceFile(GetCurrentResourceName(), "./json/config.json")
	local cfgFile = json.decode(configFile)
    local ids = ExtractIdentifiers(source)

	if ids.steam then
		deferrals.update("Checking your steam name")
		if loadedFile[ids.steam] ~= nil then 
			if loadedFile[ids.steam] ~= GetPlayerName(source) then 
				for _, i in ipairs(GetPlayers()) do
					if IsPlayerAceAllowed(i, cfgFile.nameChangePerms) then 
						TriggerClientEvent('chat:addMessage', i, {
							template = '<div style="background-color: rgba(90, 90, 90, 0.9); text-align: center; border-radius: 0.5vh; padding: 0.7vh; font-size: 1.7vh;"><b>Player ^1{0} ^0used to be named ^1{1}</b></div>',
							args = { GetPlayerName(source), loadedFile[ids.steam] }
						})
					end
				end
				ServerFunc.CreateLog({EmbedMessage = 'Player **' .. GetPlayerName(source) .. '** used to be named **' ..loadedFile[ids.steam]..'**', player_id = source, channel = 'NameChange'})
			end
		end
		loadedFile[ids.steam] = GetPlayerName(source)
		SaveResourceFile(GetCurrentResourceName(), "./json/names.json", json.encode(loadedFile), -1)
		deferrals.done()
	else
		if cfgFile.forceSteam then
			deferrals.done("Please start steam and reconnect to the server.")
		else
			for _, i in ipairs(GetPlayers()) do
				if IsPlayerAceAllowed(i, cfgFile.nameChangePerms) then 
					TriggerClientEvent('chat:addMessage', i, {
						template = '<div style="background-color: rgba(90, 90, 90, 0.9); text-align: center; border-radius: 0.5vh; padding: 0.7vh; font-size: 1.7vh;"><b>Player ^1{0} ^0is connecting wihout a steam id.</b></div>',
						args = { GetPlayerName(source) }
					})
				end
			end
			deferrals.done()
		end
	end
end)

-- Send message when Player disconnects from the server
AddEventHandler('playerDropped', function(reason)
	ServerFunc.CreateLog({EmbedMessage = '**' ..GetPlayerName(source).. '** has left the server. (Reason: ' .. reason .. ')', player_id = source, channel = 'leaving'})
end)

-- Send message when Player creates a chat message (Does not show commands)
AddEventHandler('chatMessage', function(source, name, msg)
	if string.sub(msg, 1, 1) ~= '/' then
		ServerFunc.CreateLog({EmbedMessage = '**'..GetPlayerName(source) .. '**: `' .. msg..'`', player_id = source, channel = 'chat'})
	end
end)

-- Send message when Player died (including reason/killer check) (Not always working)
RegisterServerEvent('Prefech:playerDied')
AddEventHandler('Prefech:playerDied',function(args)
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
RegisterServerEvent('Prefech:playerShotWeapon')
AddEventHandler('Prefech:playerShotWeapon', function(weapon)
	local configLoadFile = LoadResourceFile(GetCurrentResourceName(), "./json/config.json")
	local configFile = json.decode(configLoadFile)
	if configFile['weaponLog'] then
		ServerFunc.CreateLog({EmbedMessage = '**' .. GetPlayerName(source)  .. '** fired a `' .. weapon .. '`', player_id = source, channel = 'shooting'})
    end
end)

local explosionTypes = {'GRENADE', 'GRENADELAUNCHER', 'STICKYBOMB', 'MOLOTOV', 'ROCKET', 'TANKSHELL', 'HI_OCTANE', 'CAR', 'PLANE', 'PETROL_PUMP', 'BIKE', 'DIR_STEAM', 'DIR_FLAME', 'DIR_WATER_HYDRANT', 'DIR_GAS_CANISTER', 'BOAT', 'SHIP_DESTROY', 'TRUCK', 'BULLET', 'SMOKEGRENADELAUNCHER', 'SMOKEGRENADE', 'BZGAS', 'FLARE', 'GAS_CANISTER', 'EXTINGUISHER', 'PROGRAMMABLEAR', 'TRAIN', 'BARREL', 'PROPANE', 'BLIMP', 'DIR_FLAME_EXPLODE', 'TANKER', 'PLANE_ROCKET', 'VEHICLE_BULLET', 'GAS_TANK', 'BIRD_CRAP', 'RAILGUN', 'BLIMP2', 'FIREWORK', 'SNOWBALL', 'PROXMINE', 'VALKYRIE_CANNON', 'AIR_DEFENCE', 'PIPEBOMB', 'VEHICLEMINE', 'EXPLOSIVEAMMO', 'APCSHELL', 'BOMB_CLUSTER', 'BOMB_GAS', 'BOMB_INCENDIARY', 'BOMB_STANDARD', 'TORPEDO', 'TORPEDO_UNDERWATER', 'BOMBUSHKA_CANNON', 'BOMB_CLUSTER_SECONDARY', 'HUNTER_BARRAGE', 'HUNTER_CANNON', 'ROGUE_CANNON', 'MINE_UNDERWATER', 'ORBITAL_CANNON', 'BOMB_STANDARD_WIDE', 'EXPLOSIVEAMMO_SHOTGUN', 'OPPRESSOR2_CANNON', 'MORTAR_KINETIC', 'VEHICLEMINE_KINETIC', 'VEHICLEMINE_EMP', 'VEHICLEMINE_SPIKE', 'VEHICLEMINE_SLICK', 'VEHICLEMINE_TAR', 'SCRIPT_DRONE', 'RAYGUN', 'BURIEDMINE', 'SCRIPT_MISSIL'}

AddEventHandler('explosionEvent', function(source, ev)
    if ev.explosionType < -1 or ev.explosionType > 77 then
        ev.explosionType = 'UNKNOWN'
    else
        ev.explosionType = explosionTypes[ev.explosionType + 1]
    end
    ServerFunc.CreateLog({EmbedMessage = '**' .. GetPlayerName(source)  .. '** created a explosion `' .. ev.explosionType .. '`', player_id = source, channel = 'explosion'})
end)

-- Getting exports from clientside
RegisterServerEvent('Prefech:ClientDiscord')
AddEventHandler('Prefech:ClientDiscord', function(args)
	if args.screenshot then
		local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./json/webhooks.json")
		local webhooksFile = json.decode(webhooksLaodFile)
		args['url'] = webhooksFile['imageStore'].webhook
		TriggerClientEvent('Prefech:ClientCreateScreenshot', args.player_id, args)
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

local storage = nil
RegisterNetEvent('Prefech:sendClientLogStorage')
AddEventHandler('Prefech:sendClientLogStorage', function(_storage)
	storage = _storage
end)

RegisterCommand('logs', function(source, args, RawCommand)
	local configFile = LoadResourceFile(GetCurrentResourceName(), "./json/config.json")
	local cfgFile = json.decode(configFile)
	if GetResourceState('Prefech_Notify') == "started" then
		if IsPlayerAceAllowed(source, cfgFile.logHistoryPerms) then
			if tonumber(args[1]) then
				TriggerClientEvent('Prefech:getClientLogStorage', args[1])
				Citizen.Wait(500)
				if tablelength(storage) == 0 then
					exports.Prefech_Notify:Notify({
						title = "Recent logs for: "..GetPlayerName(args[1]).." (0)",
						message = "No logs avalible.",
						color = "#93CAED",
						target = source,
						timeout = 15
					})
				else
					for k,v in pairs(storage) do
						exports.Prefech_Notify:Notify({
							title = "Recent logs for: "..GetPlayerName(args[1]).." ("..k..")",
							message = "Channel: "..v.Channel.."\nMessage: "..v.Message:gsub("**",""):gsub("`","").."\nTimeStamp: "..v.TimeStamp,
							color = "#93CAED",
							target = source,
							timeout = 15
						})
					end
				end
			else
				exports.Prefech_Notify:Notify({
					title = "Error!",
					message = "Invalid player ID",
					color = "#93CAED",
					target = source,
					timeout = 15
				})
			end
		else
			exports.Prefech_Notify:Notify({
				title = "Error!",
				message = "You don't have permission to use this command",
				color = "#93CAED",
				target = source,
				timeout = 15
			})
		end
	else
		errorLog('Prefech_Notify is not installed.')
	end
end)

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local eventsLoadFile = LoadResourceFile(GetCurrentResourceName(), "json/eventLogs.json")
local eventsFile = json.decode(eventsLoadFile)
for k,v in pairs(eventsFile) do
	if v.Server then
		debugLog('Added Server Event Log: '..v.Event)
		AddEventHandler(v.Event, function()
			ServerFunc.CreateLog({EmbedMessage = '**EventLogger:** '..v.Message, channel = v.Channel})
		end)
	end
end

if GetCurrentResourceName() ~= "JD_logs" then
    errorLog('This recource should be named "JD_logs" for the exports to work properly.')
end

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
