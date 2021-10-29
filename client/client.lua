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

Citizen.CreateThread(function()
	local DeathReason, Killer, DeathCauseHash, Weapon

	while true do
		Citizen.Wait(0)
		if IsEntityDead(GetPlayerPed(PlayerId())) then
			Citizen.Wait(0)
			local PedKiller = GetPedSourceOfDeath(GetPlayerPed(PlayerId()))
			local killername = GetPlayerName(PedKiller)
			DeathCauseHash = GetPedCauseOfDeath(GetPlayerPed(PlayerId()))
			Weapon = ClientWeapons.WeaponNames[tostring(DeathCauseHash)]

			if IsEntityAPed(PedKiller) and IsPedAPlayer(PedKiller) then
				Killer = NetworkGetPlayerIndexFromPed(PedKiller)
			elseif IsEntityAVehicle(PedKiller) and IsEntityAPed(GetPedInVehicleSeat(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
				Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
			end

			if (Killer == PlayerId()) then
				DeathReason = 'committed suicide'
			elseif (Killer == nil) then
				DeathReason = 'died'
			else
				if ClientFunc.IsMelee(DeathCauseHash) then
					DeathReason = 'murdered'
				elseif ClientFunc.IsTorch(DeathCauseHash) then
					DeathReason = 'torched'
				elseif ClientFunc.IsKnife(DeathCauseHash) then
					DeathReason = 'knifed'
				elseif ClientFunc.IsPistol(DeathCauseHash) then
					DeathReason = 'pistoled'
				elseif ClientFunc.IsSub(DeathCauseHash) then
					DeathReason = 'riddled'
				elseif ClientFunc.IsRifle(DeathCauseHash) then
					DeathReason = 'rifled'
				elseif ClientFunc.IsLight(DeathCauseHash) then
					DeathReason = 'machine gunned'
				elseif ClientFunc.IsShotgun(DeathCauseHash) then
					DeathReason = 'pulverized'
				elseif ClientFunc.IsSniper(DeathCauseHash) then
					DeathReason = 'sniped'
				elseif ClientFunc.IsHeavy(DeathCauseHash) then
					DeathReason = 'obliterated'
				elseif ClientFunc.IsMinigun(DeathCauseHash) then
					DeathReason = 'shredded'
				elseif ClientFunc.IsBomb(DeathCauseHash) then
					DeathReason = 'bombed'
				elseif ClientFunc.IsVeh(DeathCauseHash) then
					DeathReason = 'mowed over'
				elseif ClientFunc.IsVK(DeathCauseHash) then
					DeathReason = 'flattened'
				else
					DeathReason = 'killed'
				end
			end

			if DeathReason == 'committed suicide' or DeathReason == 'died' then
				TriggerServerEvent('playerDied', {
					type = 1, 
					player_id = GetPlayerServerId(PlayerId()), 
					death_reason = DeathReason, 
					weapon = Weapon
				})
			else
				TriggerServerEvent('playerDied', {
					type = 2, 
					player_id = GetPlayerServerId(PlayerId()), 
					player_2_id = GetPlayerServerId(Killer), 
					death_reason = DeathReason, 
					weapon = Weapon
				})
			end
			Killer = nil
			DeathReason = nil
			DeathCauseHash = nil
			Weapon = nil
		end
		while IsEntityDead(PlayerPedId()) do
			Citizen.Wait(0)
		end
	end
end)

RegisterNetEvent('ClientCreateScreenshot')
AddEventHandler('ClientCreateScreenshot', function(args)
    exports['screenshot-basic']:requestScreenshotUpload(args.url, 'files[]', function(data)
        local resp = json.decode(data)		
		args['responseUrl'] = resp.attachments[1].url
        TriggerServerEvent('ClientUploadScreenshot', args)
    end)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerped = GetPlayerPed(PlayerId())
		if IsPedShooting(playerped) then
			if ClientWeapons.WeaponNames[tostring(GetSelectedPedWeapon(playerped))] then
				TriggerServerEvent('playerShotWeapon', ClientWeapons.WeaponNames[tostring(GetSelectedPedWeapon(playerped))])
			else
				TriggerServerEvent('playerShotWeapon', 'Undefined')
				TriggerServerEvent('JD_logs:Debug', 'Weapon not defined.', "Weapon not listed: "..tostring(GetSelectedPedWeapon(playerped)))
			end
		end
	end
end)

exports('discord', function(message, id, id2, color, channel)
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
	TriggerServerEvent('ClientDiscord', args)
	TriggerServerEvent('JD_logs:Debug', 'Server Old Export', args)
end)

exports('createLog', function(args)
	TriggerServerEvent('ClientDiscord', args)
	TriggerServerEvent('JD_logs:Debug', 'Server New Export', args)
end)