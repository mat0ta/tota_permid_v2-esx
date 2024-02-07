ESX = exports["es_extended"]:getSharedObject()
local identifier = ""

ESX.RegisterCommand('permgiveitem', 'admin', function(xPlayer, args, showError)
    permanentId = args["permId"]
    getUserTempId(permanentId, xPlayer, args.item, args.count)
end, true, {help = "Give an item using Permanent user ID", validate = true, arguments = {
	{name = 'permId', help = "Permanent user ID", type = 'number'},
	{name = 'item', help = "Item name", type = 'item'},
	{name = 'count', help = "Item count", type = 'number'}
}})

ESX.RegisterCommand('idpanel', 'admin', function(xPlayer, args, showError)
    TriggerClientEvent("tota:client:triggerPanel", xPlayer.source)
end, true, {help = "Opens Tota Perm ID admin Panel", validate = true})

function processPermId(identifier, item, count)
    for i, p in pairs(GetPlayers()) do
        for k,v in pairs(ESX.GetPlayerFromId(p)) do
            if type(v) ~= 'table' and type(v) ~= 'boolean' then
                if string.sub(v, 1, string.len("license:")) == "license:" then
                    if string.sub(v, 9) == identifier then
                        ESX.GetPlayerFromId(p).addInventoryItem(item, count)
                    end
                end
            end
        end
    end
end

function getUserTempId(permId, xPlayer, item, count)
    MySQL.Async.fetchAll("SELECT identifier FROM users WHERE `permid` = '" .. permId .. "'", {}, function(result)
        if result[1] ~= nil then
            for k,v in pairs(result[1]) do
                if string.sub(v, 1, string.len("char")) == "char" then
                    local count = select(2, v:gsub(":", ""))
                    local id
                    if count > 1 then
                        id = string.match(v, ":(.*)")
                        id = string.match(id, ":(.*)")
                    else
                        id = string.match(v, ":(.*)")
                    end
                    processPermId(id, item, count)
                    return
                end
            end
        end
    end)
end