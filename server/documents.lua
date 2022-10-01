local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("qb-phone:server:sendDocument", function(data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Receiver = QBCore.Functions.GetPlayer(tonumber(data.StateID))
    local SenderName = Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname
    if not Receiver then
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "Documents",
            "Invalid State ID",
            "fas fa-folder",
            "#d9d9d9",
            5000
        )
        return
    end

    if Ply.PlayerData.citizenid ~= Receiver.PlayerData.citizenid then
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "Documents",
            "Document Sent",
            "fas fa-folder",
            "#d9d9d9",
            5000
        )
        TriggerClientEvent("qb-phone:client:sendingDocumentRequest", data.StateID, data, Receiver, Ply, SenderName)
    else
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "Documents",
            "You can't send a document to yourself!",
            "fas fa-folder",
            "#d9d9d9",
            5000
        )
    end
end)

RegisterNetEvent("qb-phone:server:sendDocumentLocal", function(data, playerId)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Receiver = QBCore.Functions.GetPlayer(playerId)
    local SenderName = Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname

    TriggerClientEvent('qb-phone:client:CustomNotification', src,
        "Documents",
        "Document Sent",
        "fas fa-folder",
        "#d9d9d9",
        5000
    )
    TriggerClientEvent("qb-phone:client:sendingDocumentRequest", playerId, data, Receiver, Ply, SenderName)
end)

local function saveNote(data, CID, src)
    if not data or not data.Title or not  data.Text or not data.Time or not CID or not src then return end

    exports.oxmysql:insert('INSERT INTO phone_note (citizenid, title,  text, lastupdate) VALUES (?, ?, ?, ?)',{CID, data.Title, data.Text, data.Time})

    TriggerClientEvent('qb-phone:client:CustomNotification', src,
        "Documents",
        "Created new Document",
        "fas fa-folder",
        "#d9d9d9",
        5000
    )
end

local function updateNote(data, ID, src)
    if not data or not data.Title or not  data.Text or not data.Time or not ID or not src then return end
    MySQL.Sync.execute('UPDATE phone_note SET title = @title, text = @text, lastupdate = @lastupdate WHERE id = @id', {
        ["@id"] = ID,
        ["@title"] = data.Title,
        ["@text"] = data.Text,
        ["@lastupdate"] = data.Time
    })


    TriggerClientEvent('qb-phone:client:CustomNotification', src,
        "Documents",
        "Document Saved",
        "fas fa-folder",
        "#d9d9d9",
        5000
    )
end

local function deleteNote(ID, src)
    if not ID or not src then return end

    exports.oxmysql:execute('DELETE FROM phone_note WHERE id = ?', {ID})
    TriggerClientEvent('qb-phone:client:CustomNotification', src,
        "Documents",
        "Document Deleted",
        "fas fa-folder",
        "#d9d9d9",
        5000
    )
end

RegisterNetEvent('qb-phone:server:documents_Save_Note_As', function(data, Receiver)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not data or not Player then return end
    if data.Type ~= 'Delete' then
        if not data.Title or not data.Text or not data.Time then return end
    end

    local CID = Player.PlayerData.citizenid
    local ID

    if data.Type ~= "New" and not data.ID then return else ID = tonumber(data.ID) end

    if data.Type == "New" then
        saveNote(data, CID, src)
    elseif data.Type == "Update" then
        local Note = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE id = ?', {ID})
        if Note[1] then
            updateNote(data, ID, src)
        end
    elseif data.Type == "Delete" then
        deleteNote(ID, src)
    elseif data.Type == "PermSend" then
        local Note = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE id = ?', {ID})
        if Note[1] then
            Wait(400)
            exports.oxmysql:insert('INSERT INTO phone_note (citizenid, title,  text, lastupdate) VALUES (?, ?, ?, ?)',{Receiver.PlayerData.citizenid, data.Title, data.Text, data.Time})
            TriggerClientEvent('qb-phone:client:CustomNotification', tonumber(data.StateID), 'DOCUMENTS', 'New Document', 'fas fa-folder', '#d9d9d9', 5000)
        end
    end

    local Notes = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE citizenid = ?', {CID})
    Wait(100)
    TriggerClientEvent('qb-phone:RefReshNotes_Free_Documents', src, Notes)
end)
