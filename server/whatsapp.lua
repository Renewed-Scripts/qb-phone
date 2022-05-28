local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-phone:server:UpdateMessages', function(ChatMessages, ChatNumber, New)
    local src = source
    local SenderData = QBCore.Functions.GetPlayer(src)
    local query = '%' .. ChatNumber .. '%'
    local Player = exports.oxmysql:executeSync('SELECT * FROM players WHERE charinfo LIKE ?', {query})
    if Player[1] ~= nil then
        local TargetData = QBCore.Functions.GetPlayerByCitizenId(Player[1].citizenid)
        if TargetData ~= nil then
            local Chat = exports.oxmysql:executeSync('SELECT * FROM phone_messages WHERE citizenid = ? AND number = ?', {SenderData.PlayerData.citizenid, ChatNumber})
            if Chat[1] ~= nil then
                exports.oxmysql:execute('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), TargetData.PlayerData.citizenid, SenderData.PlayerData.charinfo.phone})
                exports.oxmysql:execute('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), SenderData.PlayerData.citizenid, TargetData.PlayerData.charinfo.phone})
                TriggerClientEvent('qb-phone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, false)
            else
                exports.oxmysql:insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {TargetData.PlayerData.citizenid, SenderData.PlayerData.charinfo.phone, json.encode(ChatMessages)})
                exports.oxmysql:insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {SenderData.PlayerData.citizenid, TargetData.PlayerData.charinfo.phone, json.encode(ChatMessages)})
                TriggerClientEvent('qb-phone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, true)
            end
        else
            local Chat = exports.oxmysql:executeSync('SELECT * FROM phone_messages WHERE citizenid = ? AND number = ?', {SenderData.PlayerData.citizenid, ChatNumber})
            if Chat[1] ~= nil then
                exports.oxmysql:execute('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), Player[1].citizenid, SenderData.PlayerData.charinfo.phone})
                Player[1].charinfo = json.decode(Player[1].charinfo)
                exports.oxmysql:execute('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), SenderData.PlayerData.citizenid, Player[1].charinfo.phone})
            else
                exports.oxmysql:insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {Player[1].citizenid, SenderData.PlayerData.charinfo.phone, json.encode(ChatMessages)})
                Player[1].charinfo = json.decode(Player[1].charinfo)
                exports.oxmysql:insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {SenderData.PlayerData.citizenid, Player[1].charinfo.phone, json.encode(ChatMessages)})
            end
        end
    end
end)