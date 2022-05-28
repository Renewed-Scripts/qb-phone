local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())
    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end
	return closestPlayer, closestDistance
end

-- NUI Callback

RegisterNUICallback('documents_Save_Note_As', function(data)
    TriggerServerEvent('qb-phone:server:documents_Save_Note_As', data)
end)

RegisterNUICallback('document_Send_Note', function(data)
    if data.Type == 'LocalSend' then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 2.5 then
            local playerId = GetPlayerServerId(player)
            TriggerServerEvent("qb-phone:server:sendDocumentLocal", data, playerId)
        else
            TriggerEvent("DoShortHudText", "No one around!", 2)
        end
    elseif data.Type == 'PermSend' then
        TriggerServerEvent('qb-phone:server:sendDocument', data)
    end
end)

RegisterNetEvent("qb-phone:client:sendingDocumentRequest", function(data, Receiver, Ply, SenderName)
    local success = exports['qb-phone']:PhoneNotification("DOCUMENTS", SenderName..' Incoming Document', 'fas fa-folder', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if success then
        if data.Type == 'PermSend' then
            TriggerServerEvent("qb-phone:server:documents_Save_Note_As", data, Receiver, Ply, SenderName)
        elseif data.Type == 'LocalSend' then
            TriggerEvent('qb-phone:client:CustomNotification', 'DOCUMENTS', 'New Document', 'fas fa-folder', '#d9d9d9', 5000)
            SendNUIMessage({
                action = "DocumentSent",
                DocumentSend = {
                    title = data.Title,
                    text = data.Text,
                },
            })
        end
    end
end)

RegisterNUICallback('GetNote_for_Documents_app', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetNote_for_Documents_app', function(Has)
        cb(Has)
    end)
end)

RegisterNetEvent('qb-phone:RefReshNotes_Free_Documents', function()
    SendNUIMessage({
        action = "DocumentRefresh",
    })
end)