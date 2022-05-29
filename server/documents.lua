local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("qb-phone:server:sendDocument", function(data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src) -- Me
    local Receiver = QBCore.Functions.GetPlayer(tonumber(data.StateID)) -- Shawn
    local SenderName = Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname
    if Receiver ~= nil then
        if Ply.PlayerData.citizenid ~= Receiver.PlayerData.citizenid then
            TriggerClientEvent("QBCore:Notify", src, 'Document Sent', "primary")
            TriggerClientEvent("qb-phone:client:sendingDocumentRequest", data.StateID, data, Receiver, Ply, SenderName)
        else
            TriggerClientEvent("QBCore:Notify", src, 'You can\'t send a document to yourself!', "error")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, 'This state id does not exists!', "error")
    end
end)

RegisterNetEvent("qb-phone:server:sendDocumentLocal", function(data, playerId)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src) 
    local Receiver = QBCore.Functions.GetPlayer(playerId) 
    local SenderName = Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname

    TriggerClientEvent("QBCore:Notify", src, 'Document Sent', "primary")
    TriggerClientEvent("qb-phone:client:sendingDocumentRequest", playerId, data, Receiver, Ply, SenderName)
end)

RegisterNetEvent('qb-phone:server:documents_Save_Note_As', function(data, Receiver, Ply, SenderName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if data.Type == "New" then
        exports.oxmysql:insert('INSERT INTO phone_note (citizenid, title,  text, lastupdate) VALUES (?, ?, ?, ?)',{Player.PlayerData.citizenid, data.Title, data.Text, data.Time})
        TriggerClientEvent('QBCore:Notify', src, 'Note Saved', "success")
    elseif data.Type == "Update" then
        local ID = tonumber(data.ID)
        local Note = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE id = ?', {ID})
        if Note[1] ~= nil then
            exports.oxmysql:execute('DELETE FROM phone_note WHERE id = ?', {ID})
            exports.oxmysql:insert('INSERT INTO phone_note (citizenid, title,  text, lastupdate) VALUES (?, ?, ?, ?)',{Player.PlayerData.citizenid, data.Title, data.Text, data.Time})
            TriggerClientEvent('QBCore:Notify', src, 'Note Updated', "success")
        end
    elseif data.Type == "Delete" then
        local ID = tonumber(data.ID)
        exports.oxmysql:execute('DELETE FROM phone_note WHERE id = ?', {ID})
        TriggerClientEvent('QBCore:Notify', src, 'Note Deleted', "error")
    elseif data.Type == "PermSend" then
        local ID = tonumber(data.ID)
        local Note = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE id = ?', {ID})
        if Note[1] ~= nil then
            exports.oxmysql:insert('INSERT INTO phone_note (citizenid, title,  text, lastupdate) VALUES (?, ?, ?, ?)',{Receiver.PlayerData.citizenid, data.Title, data.Text, data.Time})
            TriggerClientEvent('qb-phone:client:CustomNotification', tonumber(data.StateID), 'DOCUMENTS', 'New Document', 'fas fa-folder', '#d9d9d9', 5000)
        end
    end
    Wait(100)
    TriggerClientEvent('qb-phone:RefReshNotes_Free_Documents', src)
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetNote_for_Documents_app', function(source, cb)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Note = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE citizenid = ?', {Ply.PlayerData.citizenid})
    Wait(400)
    if Note[1] ~= nil then
        cb(Note)
    end
end)