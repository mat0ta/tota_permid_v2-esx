ESX = exports["es_extended"]:getSharedObject()

local disPlayerNames = 5
local playerDistances = {}
playerPermIds = {}
local isShown = false
local permanentId = ""
local onScreen = false

local function DrawText3D(x,y,z, text, r,g,b) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz)-vector3(x,y,z))
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen and isShown then
        if not useCustomScale then
            SetTextScale(0.0*scale, 0.55*scale)
        else 
            SetTextScale(0.0*scale, customScale)
        end
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        for _, id in ipairs(GetActivePlayers()) do
            if GetPlayerPed(id) then
                x1, y1, z1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                distance = math.floor(#(vector3(x1,  y1,  z1)-vector3(x2,  y2,  z2)))
				playerDistances[id] = distance
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
	Wait(500)
    while Config.Marker do
        for _, id in ipairs(GetActivePlayers()) do
            if GetPlayerPed(id) and not IsControlPressed(0, 19) then
                if playerDistances[id] then
                        if (playerDistances[id] < disPlayerNames) then
                            x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                            if NetworkIsPlayerTalking(id) then
                            DrawMarker(2, x2, y2, z2+0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.08, 0.2, 0.08, 0, 255, 0, 155, false, false, false, true, false, false, false)
                            end
                        elseif (playerDistances[id] < 25) then
                            x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))						
                            if NetworkIsPlayerTalking(id) then
                                DrawMarker(2, x2, y2, z2+0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.08, 0.2, 0.08, 0, 255, 0, 155, false, false, false, true, false, false, false)
                            end
                        end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("tota:client:getId")
AddEventHandler("tota:client:getId", function(playerPermId, tempId, done)
    Citizen.Wait(1000)
    while isShown do
        for _, id in ipairs(GetActivePlayers()) do
            local server_id = ""
            if id == 128 or id == 0 then
                server_id = tempId
            else
                server_id = id
            end
            if GetPlayerPed(id) then
                if playerDistances[id] then
                    if (playerDistances[id] < disPlayerNames) then
                        if playerPermIds[server_id] == nil then
                            TriggerEvent("tota:client:checkPermId", server_id, done)
                            return TriggerEvent("tota:client:getId", playerPermId, tempId, done + 1)
                        end
                        x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                            if NetworkIsPlayerTalking(id) then
                                DrawText3D(x2, y2, z2+1.2, GetPlayerServerId(id).. " | ".. playerPermIds[server_id], 119,238,225)
                        if Config.Marker then
                            DrawMarker(2, x2, y2, z2+0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.08, 0.2, 0.08, 0, 255, 0, 155, false, false, false, true, false, false, false)
                        end
                        else
                            DrawText3D(x2, y2, z2+1, GetPlayerServerId(id).. " | ".. playerPermIds[server_id], 186,186,186)
                        end
                        elseif (playerDistances[id] < 25) then
                            x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))						
                            if NetworkIsPlayerTalking(id) then
                                if Config.Marker then
                                    DrawMarker(2, x2, y2, z2+0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.08, 0.2, 0.08, 0, 255, 0, 155, false, false, false, true, false, false, false)
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("tota:client:checkPermId")
AddEventHandler("tota:client:checkPermId", function(server_id, done)
    ESX.TriggerServerCallback('tota:server:getUserPermId', function(permanentId) 
        playerPermIds[server_id] = permanentId
    end, server_id)
end)

RegisterNetEvent("tota:client:updatePermIdTable")
AddEventHandler("tota:client:updatePermIdTable", function(server_id, perm_id)
    playerPermIds[server_id] = perm_id
end)

RegisterNetEvent("tota:client:notId")
AddEventHandler("tota:client:notId", function()
    if isShown == true then
        isShown = false
    else
        isShown = true
    end
end)

RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

RegisterNUICallback("main", function(data)
    SetDisplay(false)
end)

function SetDisplay(bool)
    onScreen = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

Citizen.CreateThread(function()
    while onScreen do
        Citizen.Wait(0)
        DisableControlAction(0, 1, onScreen) -- LookLeftRight
        DisableControlAction(0, 2, onScreen) -- LookUpDown
        DisableControlAction(0, 142, onScreen) -- MeleeAttackAlternate
        DisableControlAction(0, 18, onScreen) -- Enter
        DisableControlAction(0, 322, onScreen) -- ESC
        DisableControlAction(0, 106, onScreen) -- VehicleMouseControlOverride
        DisableControlAction(0, 122, onScreen)
        DisableControlAction(0, 135, onScreen)
        DisableControlAction(0, 142, onScreen)
        DisableControlAction(0, 257, onScreen)
        DisableControlAction(0, 329, onScreen)
        DisableControlAction(0, 346, onScreen)
        DisableControlAction(0, 24, onScreen)
        DisableControlAction(0, 69, onScreen)
        DisableControlAction(0, 70, onScreen)
        DisableControlAction(0, 92, onScreen)
        DisablePlayerFiring(source, onScreen)
        DisableControlAction(0,21,onScreen) -- disable sprint
        DisableControlAction(0,24,onScreen) -- disable attack
        DisableControlAction(0,25,onScreen) -- disable aim
        DisableControlAction(0,47,onScreen) -- disable weapon
        DisableControlAction(0,58,onScreen) -- disable weapon
        DisableControlAction(0,263,onScreen) -- disable melee
        DisableControlAction(0,264,onScreen) -- disable melee
        DisableControlAction(0,257,onScreen) -- disable melee
        DisableControlAction(0,140,onScreen) -- disable melee
        DisableControlAction(0,141,onScreen) -- disable melee
        DisableControlAction(0,142,onScreen) -- disable melee
        DisableControlAction(0,143,onScreen) -- disable melee
        DisableControlAction(0,75,onScreen) -- disable exit vehicle
        DisableControlAction(27,75,onScreen) -- disable exit vehicle
        DisableControlAction(0,32,onScreen) -- move (w)
        DisableControlAction(0,34,onScreen) -- move (a)
        DisableControlAction(0,33,onScreen) -- move (s)
        DisableControlAction(0,35,onScreen) -- move (d)
    end
end)

RegisterNetEvent("tota:client:triggerPanel")
AddEventHandler("tota:client:triggerPanel", function(xPlayer)
    playerNames = {}
    SetDisplay(not onScreen)
    TriggerServerEvent('tota:server:getAllIds')
    Wait(1000)
    for k, v in pairs(playerPermIds) do
        ESX.TriggerServerCallback('tota:server:getUserName', function(name)
            updateNameTable(k, name)
        end, k)
    end
    Wait(3000)
    SendNUIMessage{
        display = onScreen,
        permDict = playerPermIds,
        names = playerNames
    }
end)

function updateNameTable(k, name)
    playerNames[k] = name
end

RegisterNUICallback('action', function(data, cb)
    if data.action == "kill" then
        TriggerEvent('esx:killPlayer', data.id)
    end
    if data.action == "tp" then
        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(data.id))))
        SetEntityCoords(GetPlayerPed(GetPlayerFromServerId(source)), x, y, z+1)
    end
    if data.action == "bring" then
        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(source))))
        SetEntityCoords(GetPlayerPed(GetPlayerFromServerId(data.id)), x, y, z+1)
    end
    if data.action == "kick" then
        TriggerServerEvent('tota:server:kickPlayer', data.id)
    end
end)

RegisterNUICallback('close', function()
    SetDisplay(not onScreen)
    Wait(100)
    SendNUIMessage{
        display = onScreen
    }
end)