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

ServerFunc = {}

ServerFunc.ConvertColor = function(channel)
    ConvertColor(channel)
end

function ConvertColor(channel)
    local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
	local webhooksFile = json.decode(webhooksLaodFile)
    if webhooksFile[channel] then
        src = webhooksFile[channel].color
        if string.find(src,"#") then 
            return tonumber(src:gsub("#",""),16) 
        else 
            return src
        end
    else 
        return 000000
    end
end

ServerFunc.sendWebhooks = function(load)
    sendWebhooks(load)
end

function sendWebhooks(load)
    local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
	local webhooksFile = json.decode(webhooksLaodFile)
    
    if webhooksFile[load.channel] then
        PerformHttpRequest(webhooksFile[load.channel].webhook, function(err, text, headers)
            ServerFunc.getStatus(err, load.channel)
        end, 'POST', json.encode(load.messageToDeliver), {
            ['Content-Type'] = 'application/json' 
        })
    else
        print('^1Error: No webhook channel set for: ^0'..load.channel)
    end
end

ServerFunc.GetTitle = function(channel, icon)
	GetTitle(channel, icon)
end

function GetTitle(channel, icon)
    if icon then
		return icon.." "..firstToUpper(channel)
	else
		return "❓ "..firstToUpper(channel)
	end
end

ServerFunc.getStatus = function(status, channel)
    local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
	local webhooksFile = json.decode(webhooksLaodFile)
	if status == 404 or status == 401 and webhooksFile[channel].webhook ~= "DISCORD_WEBHOOK" and webhooksFile[channel].webhook ~= "" then 
		print('^3Warn: JD_logs webhook. Possible invalid webhook for "'..channel..'" webhook. Status code: '..status)
	end
end

function GetPlayerDetails(src, config, channel)
    local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
	local webhooksFile = json.decode(webhooksLaodFile)

    local ids = ExtractIdentifiers(src)
	if config['postals'] and not webhooksFile[channel].Hide['Postal'] then
        postal = getPlayerLocation(src)
        _postal = "\n**Nearest Postal:** ".. postal ..""
    else
        _postal = ""
    end

    if config['discordId'] and not webhooksFile[channel].Hide['DiscordID']then
        if ids.discord then
            _discordID ="\n**Discord ID:** <@" ..ids.discord:gsub("discord:", "")..">"
        else
            _discordID = "\n**Discord ID:** N/A"
        end
    else
        _discordID = ""
    end

    if GetConvar("steam_webApiKey", "false") ~= 'false' then
        if config['steamId'] and not webhooksFile[channel].Hide['SteamID'] then 
            if ids.steam then 
                _steamID ="\n**Steam ID:** " ..ids.steam.."" 
            else 
                _steamID = "\n**Steam ID:** N/A" 
            end 
        else 
            _steamID = "" 
        end
        
        if config['steamUrl'] and not webhooksFile[channel].Hide['SteamURL'] then 
            if ids.steam then 
                _steamURL ="\nhttps://steamcommunity.com/profiles/" ..tonumber(ids.steam:gsub("steam:", ""),16).."" 
            else 
                _steamURL = "\n**Steam URL:** N/A" 
            end 
        else 
            _steamURL = "" 
        end       
    else
        _steamID = ""
        _steamURL = ""
        TriggerEvent('Prefech:JD_logs:errorLog', 'You need to set a steam api key in your server.cfg for the steam identifiers to work!.')
    end
 
	if config['license'] and not webhooksFile[channel].Hide['License'] then 
        if ids.license then 
            _license ="\n**License:** " ..ids.license
        else 
            _license = "\n**License:** N/A" 
        end 
    else 
        _license = "" 
    end

    if config['license2'] and not webhooksFile[channel].Hide['License2'] then 
        if ids.license2 then 
            _license2 ="\n**License 2:** " ..ids.license2
        else 
            _license2 = "\n**License 2:** N/A" 
        end 
    else 
        _license2 = "" 
    end

	if config['ip'] and not webhooksFile[channel].Hide['IP'] then 
        if ids.ip then 
            _ip ="\n**IP:** " ..ids.ip:gsub("ip:", "")
        else 
            _ip = "\n**IP:** N/A" 
        end 
    else 
        _ip = "" 
    end

    if config.Session or config.PlayTime and not webhooksFile[channel].Hide['PlayTime'] then
        if GetResourceState('Prefech_playTime') == "started" then
            playtime = exports.Prefech_playTime:getPlayTime(src)
            if config.Session and channel ~= 'joins' then
                playTimeArgs = SecondsToClock(playtime.Session)
                _session = "\n**Session Time:** `"..string.format("%02d:%02d:%02d", playTimeArgs.hours, playTimeArgs.minutes, playTimeArgs.seconds)..'`'
            else
                _session = ""
            end
            if config.PlayTime and channel ~= 'joins' then
                playTimeArgs = SecondsToClock(playtime.Total + playtime.Session)
                _total = "\n**Total Time:** `"..string.format("%d days and %02d:%02d:%02d", playTimeArgs.days, playTimeArgs.hours, playTimeArgs.minutes, playTimeArgs.seconds)..'`'
            else
                _total = ""
            end
        else
            TriggerEvent('Prefech:JD_logs:errorLog', 'Prefech_playTime is not installed.')
            _total = ""
            _session = ""
        end
    else
        _total = ""
        _session = ""
    end

	if config['playerId'] and not webhooksFile[channel].Hide['PlayerID'] then 
        if channel ~= 'joins' then
            _playerID ="\n**Player ID:** " ..src.."" 
        else
            _playerID = "\n**Player ID:** N/A"     
        end
    else 
        _playerID = "" 
    end

    if config['playerPing'] and not webhooksFile[channel].Hide['playerPing'] then
        _ping = "\n**Ping:** `"..GetPlayerPing(src)..'ms`'
    else
        _ping = ""
    end

    if config['playerHealth'] or config['playerArmor'] then
        local playerPed = GetPlayerPed(src)
        if config['playerHealth'] and config['playerArmor'] then            
            local maxHealth = GetEntityMaxHealth(playerPed)
            local health = GetEntityHealth(playerPed)
            if maxHealth == 200 then
                correction = 100
            else
                correction = 0
            end
            local maxHealth = maxHealth - correction
            local health = health - correction
            local maxArmour = GetPlayerMaxArmour(src)
            local armour = GetPedArmour(playerPed)
            _hp = "\n**Health:** ❤: `"..health.."/"..maxHealth.."` **|** 🛡: `"..armour.."/"..maxArmour.."`"
        elseif config['playerHealth'] then
            local maxHealth = GetEntityMaxHealth(playerPed)
            local health = GetEntityHealth(playerPed)
            if maxHealth == 200 then
                correction = 100
            else
                correction = 0
            end
            local maxHealth = maxHealth - correction
            local health = health - correction
            _hp = "\n**Health:** ❤: `"..health.."/"..maxHealth.."`"
        elseif config['playerArmor'] then
            local maxArmour = GetPlayerMaxArmour(src)
            local armour = GetPedArmour(playerPed)
            _hp = "\n**Health:** 🛡: `"..armour.."/"..maxArmour.."`"
        end
    else
        _hp = ""
    end

    return _playerID..''.. _postal ..''.._hp..''.. _discordID..''.._steamID..''.._steamURL..''.._license..''.._license2..''.._session..''.._total..''.._ip
end

function SecondsToClock(seconds)
	local days = math.floor(seconds / 86400)
	seconds = seconds - days * 86400
	local hours = math.floor(seconds / 3600)
	seconds = seconds - hours * 3600
	local minutes = math.floor(seconds / 60) 
	seconds = seconds - minutes * 60
	return {days = days, hours = hours, minutes = minutes, seconds = seconds}    
  end

ServerFunc.GetPlayerDetails = function(src, config, channel)
	GetPlayerDetails(src, config, channel)
end

ServerFunc.CreateLog = function(args)
    local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
	local configLoadFile = LoadResourceFile(GetCurrentResourceName(), "./config/config.json")
	local webhooksFile = json.decode(webhooksLaodFile)
	local configFile = json.decode(configLoadFile)
    --[[
        Start System channel filter
    ]]
    if args['channel'] == 'system' then
        message = {
            userName = "📢 Prefech",
            embeds = {{
                ["color"] = 3092790,
                ["author"] = {
                    ["name"] = "Prefech",
                    ["icon_url"] = "https://prefech.com/i/DiscordIcon.png",
                    ["url"] = "https://discord.gg/prefech"
                },
                ["title"] = "📢 SYSTEM",
                ["description"] = args['description'],
                ["footer"] = {
                    ["text"] = "2020 - "..os.date("%Y").." © Prefech • "..os.date("%x %X %p"),
                    ["icon_url"] = "https://prefech.com/i/DiscordIcon.png",
                },
            }}, 
            avatar_url = "https://prefech.com/i/DiscordIcon.png"
        }
        if args['isBanned'] then
            message['embeds'][1]['title'] = "⛔ Global Banned"
        end
        if args['ping'] then
            message['content'] = "@everyone"
        end
        if webhooksFile['system'].webhook ~= "DISCORD_WEBHOOK" and webhooksFile['system'].webhook ~= "" then
            return sendWebhooks({messageToDeliver = message, channel = 'system'})
        else
            return sendWebhooks({messageToDeliver = message, channel = 'all'})
        end
    end

    --[[
        End System channel filter
    ]]

    if webhooksFile[args.channel] then
        message = {
            userName = configFile.userName, 
            embeds = {{
                ["color"] = ConvertColor(args.channel), 
                ["author"] = {
                    ["name"] = configFile.communityName,
                    ["icon_url"] = configFile.communityLogo
                },
                ["title"] = GetTitle(args.channel, webhooksFile[args.channel].icon),
                ["description"] = args.EmbedMessage,
                ["footer"] = {
                    ["text"] = configFile.footerText.." • "..os.date("%x %X %p"),
                    ["icon_url"] = configFile.footerIcon,
                },
            }}, 
            avatar_url = configFile.avatar
        }

        if args.player_id then
            if webhooksFile[args.channel].logHistory then
                TriggerClientEvent('Prefech:ClientLogStorage', args.player_id, { Channel = args.channel, Message = args.EmbedMessage, TimeStamp = os.date("%x %X %p") })
            end
            Player_Details = GetPlayerDetails(args.player_id, configFile, args.channel)
            message['embeds'][1].fields = {
                {
                    ["name"] = "Player Details: "..GetPlayerName(args.player_id),
                    ["value"] = Player_Details,
                    ["inline"] = configFile.inlineField
                }
            }
            if configFile['timestamp'] then
                message['embeds'][1].fields[2]  = {
                    ["name"] = "Timestamp:",
                    ["value"] = "<t:".. math.floor(tonumber(os.time())) ..":R>",
                    ["inline"] = false
                }
            end
        end

        if args.player_2_id then
            if webhooksFile[args.channel].logHistory then
                TriggerClientEvent('Prefech:ClientLogStorage', args.player_2_id, { Channel = args.channel, Message = args.EmbedMessage, TimeStamp = os.date("%x %X %p") })
            end
            Player_2_Details = GetPlayerDetails(args.player_2_id, configFile, args.channel)
            message['embeds'][1].fields[2]  = {
                ["name"] = "Player Details: "..GetPlayerName(args.player_2_id),
                ["value"] = Player_2_Details,
                ["inline"] = configFile.inlineField
            }
            if configFile['timestamp'] then
                message['embeds'][1].fields[3]  = {
                    ["name"] = "Timestamp:",
                    ["value"] = "<t:".. math.floor(tonumber(os.time())) ..":R>",
                    ["inline"] = false
                }
            end
        end

        if not message['embeds'][1].fields then
            message['embeds'][1].fields = {
                {
                    ["name"] = "Timestamp:",
                    ["value"] = "<t:".. math.floor(tonumber(os.time())) ..":R>",
                    ["inline"] = false
                }
            }
        end

        if args.responseUrl then
            message['embeds'][1].image = {
                ["url"] = args.responseUrl
            }
        end

        content = {
            userName = configFile.userName, 
            content = args.EmbedMessage,
            avatar_url = configFile.avatar
        }

        if configFile.allLogs then
            if webhooksFile['all'].embed then
                sendWebhooks({messageToDeliver = message, channel = 'all'})
            else
                sendWebhooks({messageToDeliver = content, channel = 'all'})
            end
        end
        if webhooksFile[args.channel] then
            if webhooksFile[args.channel].embed then
                sendWebhooks({messageToDeliver = message, channel = args.channel})
            else
                sendWebhooks({messageToDeliver = content, channel = args.channel})
            end
        else
            sendWebhooks({messageToDeliver = content, channel = args.channel})
        end
    else
        print("JD_logs: Webhooks channel not found. ("..args.channel..")")
    end
end

function ExtractIdentifiers(src)
    local identifiers = {}

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam:") then
            identifiers['steam'] = id
        elseif string.find(id, "ip:") then
            identifiers['ip'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "license2:") then
            identifiers['license2'] = id
        elseif string.find(id, "xbl:") then
            identifiers['xbl'] = id
        elseif string.find(id, "live:") then
            identifiers['live'] = id
        end
    end

    return identifiers
end


function getPlayerLocation(src)
    local raw = LoadResourceFile(GetCurrentResourceName(), "./json/postals.json")

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

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end