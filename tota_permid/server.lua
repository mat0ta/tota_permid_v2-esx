ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source)
    if Config.Debug then print("[tota_permId]: Player Loaded") end
    TriggerEvent('tota:server:displayid', source)
	Wait(1000)
	checkDiscord(source)
end)

RegisterServerEvent('tota:server:displayid')
AddEventHandler('tota:server:displayid', function(source, permId, cb)
	local identifier = ""

	while identifier == "" or identifier == " " do
		identifier = getLicense(source)
		Wait(1000)
	end

	steamId = "char1:" .. identifier

    MySQL.Async.fetchAll("SELECT permid FROM users WHERE `identifier` = '" .. steamId .. "'  AND LENGTH(permid) > 1", {}, function(result)
    	if result[1] == nil then
			checkForDuplicates(source, steamId)
		end
    end)
end)

function checkForDuplicates(source, steamId)
	local number = math.random(1, Config.MaxNumber)
    MySQL.Async.fetchAll("SELECT permid FROM users WHERE `permid` = '" .. number .. "'", {}, function(result)
        if result and #result > 0 then
            if Config.Debug then  print("Duplicate permId: " .. number .. ". Retrying with a new ID.") end
            checkForDuplicates(steamId)
        else
            MySQL.Async.fetchAll("UPDATE users SET permid = '" .. number .. "' WHERE `identifier` = '" .. steamId .. "'", {}, function(result)
				if Config.Debug then print("New ID: " .. number) end
				TriggerClientEvent("tota:client:updatePermIdTable", source, number)
			end)
        end
    end)
end

function checkDiscord(source)
	local discord = ""
	local id = ""
		
	identifiers = GetNumPlayerIdentifiers(source)
	for i = 0, identifiers + 1 do
		if GetPlayerIdentifier(source, i) ~= nil then
			if string.match(GetPlayerIdentifier(source, i), "discord") then
				discord = GetPlayerIdentifier(source, i)
				id = string.sub(discord, 9, -1)
				MySQL.Async.fetchAll("UPDATE users SET discord = '"..id.."' WHERE `identifier` = '"..steamId.."'", {}, function(result) end)
			end
		end
	end
end

function getLicense(source)
	local identifier = ""

	for k,v in pairs(GetPlayerIdentifiers(source)) do
		if string.sub(v, 1, string.len("license:")) == "license:" then
			identifier = string.sub(v, 9)
		end
	end
	return identifier
end

RegisterServerEvent('tota:server:getAllIds')
AddEventHandler('tota:server:getAllIds', function(source)
	permanent_ids = {}
	for x, y in pairs(ESX.GetPlayers()) do
		for k,v in pairs(GetPlayerIdentifiers(y)) do
			if string.sub(v, 1, string.len("license:")) == "license:" then
				identifier = "char1:" .. string.sub(v, 9)
				MySQL.Async.fetchAll("SELECT permid FROM users WHERE `identifier` = '"..identifier.."'", {}, function(result)
					permanentId = result[1].permid
					TriggerClientEvent('tota:client:updatePermIdTable', y, y, permanentId)
				end)
			end
		end
	end
end)

ESX.RegisterServerCallback('tota:server:getUserPermId', function(source, cb, tempId)
	local identifier = ""
	local user = ""
	local permanentId = ""

	for k,v in pairs(GetPlayerIdentifiers(tempId)) do
		if string.sub(v, 1, string.len("license:")) == "license:" then
			identifier = string.sub(v, 9)
		end
	end
	
	steamId = "char1:" .. identifier 

	MySQL.Async.fetchAll("SELECT permid FROM users WHERE `identifier` = '"..steamId.."'", {}, function(result)
		permanentId = result[1].permid
		cb(permanentId)
		return
	end)
end)

RegisterCommand(Config.Command, function(source, args)
	local identifier = ""
	TriggerEvent('tota:server:displayid', source)
	TriggerClientEvent("tota:client:notId", source)
	for k,v in pairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("license:")) == "license:" then
			identifier = string.sub(v, 9)
		end
	end
	steamId = "char1:" .. identifier
	MySQL.Async.fetchAll("SELECT permid FROM users WHERE `identifier` = '"..steamId.."'", {}, function(result)
		permanentId = result[1].permid
		tempId = source
		TriggerClientEvent("tota:client:getId", source, permanentId, tempId, 1)
	end)
end)

ESX.RegisterServerCallback('tota:server:getUserName', function(source, cb, id)
	cb(GetPlayerName(id))
end)

RegisterServerEvent('tota:server:kickPlayer')
AddEventHandler('tota:server:kickPlayer', function(id)
	if (Config.Debug) then print('Player ' .. GetPlayerName(id) .. ' [' .. id .. '] has been kicked from the server.') end
	DropPlayer(id, Config.KickedMessage)
end)