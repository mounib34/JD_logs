function sanitize(string)
    return string:gsub('%@', '')
end

exports('sanitize', function(string)
    sanitize(string)
end)

RegisterNetEvent("discordLogs")
AddEventHandler("discordLogs", function(message, color, channel)
    discordLog(message, color, channel)
end)

-- Define default colors
if string.find(Config.joinColor,"#") then
	local joinColor = tonumber(Config.joinColor:gsub("#",""),16)
else
	local joinColor = Config.joinColor
end

if string.find(Config.leaveColor,"#") then
	local leaveColor = tonumber(Config.leaveColor:gsub("#",""),16)
else
	local leaveColor = Config.leaveColor
end

if string.find(Config.chatColor,"#") then
	local chatColor = tonumber(Config.chatColor:gsub("#",""),16)
else
	local chatColor = Config.chatColor
end

if string.find(Config.shootingColor,"#") then
	local shootingColor = tonumber(Config.shootingColor:gsub("#",""),16)
else
	local shootingColor = Config.shootingColor
end

if string.find(Config.deathColor,"#") then
	local deathColor = tonumber(Config.deathColor:gsub("#",""),16)
else
	local deathColor = Config.deathColor
end

if string.find(Config.resourceColor,"#") then
	local resourceColor = tonumber(Config.resourceColor:gsub("#",""),16)
else
	local resourceColor = Config.resourceColor
end


-- Get exports from server side
exports('discord', function(message, id, id2, color, channel)
	-- checking if export is used correctly
	local _message = message
	
	if message == nil then print("^1Error: JD_Logs Export. Invalid message.^0") return end
	if id == nil or id == "PLAYER_ID" or not tonumber(id) then print("^1Error: JD_Logs Export. Invalid player id.^0") return end
	if id == nil or id2 == "PLAYER_2_ID" or not tonumber(id2) then print("^1Error: JD_Logs Export. Invalid second player id.^0") return end
	if color == nil then print("^1Error: JD_Logs Export. Invalid color.^0") return end
	if channel == nil or channel == "" then print("^1Error: JD_Logs Export. Invalid channel.^0") return end

	-- Check if hex or decimal color is used
	if string.find(color,"#") then _color = tonumber(color:gsub("#",""),16) else _color = color end

	if id2 ~= 0 then
		local player1 = GetPlayerDetails(id)
		local player2 = GetPlayerDetails(id2)
		_message = message..'\n'..player1..'\n'..player2
	else
		if id == 0 then
			_message = message
		else
			local player1 = GetPlayerDetails(id)
			_message = message..'\n'..player1
		end
	end
   discordLog(_message, _color,  channel)
end)

-- Sending message to the All Logs channel and to the channel it has listed
function discordLog(message, color, channel)
  if Config.AllLogs then
	PerformHttpRequest(Config.webhooks["all"], function(err, text, headers) end, 'POST', json.encode({username = Config.username, embeds = {{["color"] = color, ["author"] = {["name"] = Config.communtiyName,["icon_url"] = Config.communtiyLogo}, ["description"] = "".. message .."",["footer"] = {["text"] = "© JokeDevil.com - "..os.date("%x %X %p"),["icon_url"] = "https://www.jokedevil.com/img/logo.png",},}}, avatar_url = Config.avatar}), { ['Content-Type'] = 'application/json' })
  end
	PerformHttpRequest(Config.webhooks[channel], function(err, text, headers) end, 'POST', json.encode({username = Config.username, embeds = {{["color"] = color, ["author"] = {["name"] = Config.communtiyName,["icon_url"] = Config.communtiyLogo}, ["description"] = "".. message .."",["footer"] = {["text"] = "© JokeDevil.com - "..os.date("%x %X %p"),["icon_url"] = "https://www.jokedevil.com/img/logo.png",},}}, avatar_url = Config.avatar}), { ['Content-Type'] = 'application/json' })
end

-- Event Handlers

-- Send message when Player connects to the server.
AddEventHandler("playerConnecting", function(name, setReason, deferrals)
	local info = GetPlayerDetails(source)
	discordLog('**' .. sanitize(GetPlayerName(source)) .. '** is connecting to the server.\n'..info, joinColor, 'joins')
end)

-- Send message when Player disconnects from the server
AddEventHandler('playerDropped', function(reason)
	local info = GetPlayerDetails(source)
	discordLog('**' .. sanitize(GetPlayerName(source)) .. '** has left the server. (Reason: ' .. reason .. ')'.._playerID..''.. _postal ..''.. _discordID..''.._steamID..''.._steamURL..''.._license..''.._ip..'', leaveColor, 'leaving')
end)

-- Send message when Player creates a chat message (Does not show commands)
AddEventHandler('chatMessage', function(source, name, msg)
	local info = GetPlayerDetails(source)
	discordLog('**' .. sanitize(GetPlayerName(source)) .. '**: ``' .. msg .. '``\n'..info, chatColor, 'chat')
end)

-- Send message when Player died (including reason/killer check) (Not always working)
RegisterServerEvent('playerDied')
AddEventHandler('playerDied',function(id,player,killer,DeathReason, Weapon)
	if Weapon == nil then _Weapon = "" else _Weapon = "`"..Weapon.."`" end
	local info = GetPlayerDetails(player)
	if id == 1 then  -- Suicide/died
        discordLog('**' .. sanitize(GetPlayerName(source)) .. '** '..DeathReason..' '.._Weapon..'\n'..info, deathColor, 'deaths') -- sending to deaths channel
	elseif id == 2 then -- Killed by other player
	local _killer = GetPlayerDetails(killer)
		discordLog('**' .. GetPlayerName(killer) .. '** '..DeathReason..' ' .. GetPlayerName(source).. ' `('.._Weapon..')`\n\n**[Player INFO]**'.._playerID..''.. _postal ..''.. info..'\n\n**[Killer INFO]**'.._killer, deathColor, 'deaths') -- sending to deaths channel
	else -- When gets killed by something else
        discordLog('**' .. sanitize(GetPlayerName(source)) .. '** `died`\n'.. info, deathColor, 'deaths') -- sending to deaths channel
	end
end)

-- Send message when Player fires a weapon
RegisterServerEvent('playerShotWeapon')
AddEventHandler('playerShotWeapon', function(weapon)
	local info = GetPlayerDetails(source)
	if Config.weaponLog then
		discordLog('**' .. sanitize(GetPlayerName(source))  .. '** fired a `' .. weapon .. '`\n'..info, shootingColor, 'shooting')
    end
end)

-- Getting exports from clientside
RegisterServerEvent('ClientDiscord')
AddEventHandler('ClientDiscord', function(message, id, id2, color, channel)
	local _message = message
	
	if message == nil then print("^1Error: JD_Logs Export. Invalid message.^0") return end
	if id == nil or id == "PLAYER_ID" or not tonumber(id) then print("^1Error: JD_Logs Export. Invalid player id.^0") return end
	if id == nil or id2 == "PLAYER_2_ID" or not tonumber(id2) then print("^1Error: JD_Logs Export. Invalid second player id.^0") return end
	if color == nil then print("^1Error: JD_Logs Export. Invalid color.^0") return end
	if channel == nil or channel == "" then print("^1Error: JD_Logs Export. Invalid channel.^0") return end

	-- Check if hex or decimal color is used
	if string.find(color,"#") then _color = tonumber(color:gsub("#",""),16) else _color = color end

	if id2 ~= 0 then
		local player1 = GetPlayerDetails(id)
		local player2 = GetPlayerDetails(id2)
		_message = message..'\n'..player1..'\n'..player2
	else
		if id == 0 then
			_message = message
		else
			local player1 = GetPlayerDetails(id)
			_message = message..'\n'..player1
		end
	end
   discordLog(_message, _color,  channel)
end)

-- Send message when a resource is being stopped
AddEventHandler('onResourceStop', function (resourceName)
    discordLog('**' .. resourceName .. '** has been stopped.', resourceColor, 'resources')
end)

-- Send message when a resource is being started
AddEventHandler('onResourceStart', function (resourceName)
    Wait(100)
    discordLog('**' .. resourceName .. '** has been started.', resourceColor, 'resources')
end)

function GetPlayerDetails(src)
	local player_id = src
	local ids = ExtractIdentifiers(player_id)
	local postal = getPlayerLocation(player_id)
	if Config.postal then _postal = "\n**Nearest Postal:** ".. postal .."" else _postal = "" end
	if Config.discordID then if ids.discord ~= "" then _discordID ="\n**Discord ID:** <@" ..ids.discord:gsub("discord:", "")..">" else _discordID = "\n**Discord ID:** N/A" end else _discordID = "" end
	if Config.steamID then if ids.steam ~= "" then _steamID ="\n**Steam ID:** " ..ids.steam.."" else _steamID = "\n**Steam ID:** N/A" end else _steamID = "" end
	if Config.steamURL then  if ids.steam ~= "" then _steamURL ="\nhttps://steamcommunity.com/profiles/" ..tonumber(ids.steam:gsub("steam:", ""),16).."" else _steamURL = "\n**Steam URL:** N/A" end else _steamURL = "" end
	if Config.license then if ids.license ~= "" then _license ="\n**License:** " ..ids.license else _license = "\n**License :** N/A" end else _license = "" end
	if Config.IP then if ids.ip ~= "" then _ip ="\n**IP:** " ..ids.ip else _ip = "\n**IP :** N/A" end else _ip = "" end
	if Config.playerID then _playerID ="\n**Player ID:** " ..player_id.."" else _playerID = "" end
	return _playerID..''.. _postal ..''.. _discordID..''.._steamID..''.._steamURL..''.._license..''.._ip
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

function getPlayerLocation(src)

local raw = LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_file'))
local postals = json.decode(raw)
local nearest = nil

local player = src
local ped = GetPlayerPed(player)
local playerCoords = GetEntityCoords(ped)

local x, y = table.unpack(playerCoords)

	local ndm = -1
	local ni = -1
	for i, p in ipairs(postals) do
		local dm = (x - p.x) ^ 2 + (y - p.y) ^ 2
		if ndm == -1 or dm < ndm then
			ni = i
			ndm = dm
		end
	end

	if ni ~= -1 then
		local nd = math.sqrt(ndm)
		nearest = {i = ni, d = nd}
	end
	_nearest = postals[nearest.i].code
	return _nearest
end

-- version check
Citizen.CreateThread( function()
		SetConvarServerInfo("JD_logs", "V"..Config.versionCheck)
		local vRaw = LoadResourceFile(GetCurrentResourceName(), 'version.json')
		if vRaw and Config.versionCheck then
			local v = json.decode(vRaw)
			PerformHttpRequest(
				'https://raw.githubusercontent.com/JokeDevil/JD_logs/master/version.json',
				function(code, res, headers)
					if code == 200 then
						local rv = json.decode(res)
						if rv.version ~= v.version then
							print(
								([[^1

-------------------------------------------------------
JD_logs
UPDATE: %s AVAILABLE
CHANGELOG: %s
-------------------------------------------------------
^0]]):format(
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