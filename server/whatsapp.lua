RegisterNetEvent('qb-phone:server:UpdateMessages', function(ChatMessages, ChatNumber)
    if not ChatNumber or not ChatMessages then return end

    local src = source
    local SenderData = QBCore.Functions.GetPlayer(src)
    local TargetData = QBCore.Functions.GetPlayerByPhone(ChatNumber)

    if TargetData then
        local Chat = MySQL.query.await('SELECT * FROM phone_messages WHERE citizenid = ? AND number = ?', {SenderData.PlayerData.citizenid, ChatNumber})
        if Chat[1] then
            MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), TargetData.PlayerData.citizenid, SenderData.PlayerData.charinfo.phone})
            MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), SenderData.PlayerData.citizenid, TargetData.PlayerData.charinfo.phone})
            TriggerClientEvent('qb-phone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, false)
        else
            MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {TargetData.PlayerData.citizenid, SenderData.PlayerData.charinfo.phone, json.encode(ChatMessages)})
            MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {SenderData.PlayerData.citizenid, TargetData.PlayerData.charinfo.phone, json.encode(ChatMessages)})
            TriggerClientEvent('qb-phone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, true)
        end
    else
        local query = '%' .. ChatNumber .. '%'
        local Player = MySQL.query.await('SELECT * FROM players WHERE charinfo LIKE ?', {query})
        local Chat = MySQL.query.await('SELECT * FROM phone_messages WHERE citizenid = ? AND number = ?', {SenderData.PlayerData.citizenid, ChatNumber})
        if Chat[1] and Player[1] then
            MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), Player[1].citizenid, SenderData.PlayerData.charinfo.phone})
            Player[1].charinfo = json.decode(Player[1].charinfo)
            MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), SenderData.PlayerData.citizenid, Player[1].charinfo.phone})
        elseif Player[1] then
            MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {Player[1].citizenid, SenderData.PlayerData.charinfo.phone, json.encode(ChatMessages)})
            Player[1].charinfo = json.decode(Player[1].charinfo)
            MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {SenderData.PlayerData.citizenid, Player[1].charinfo.phone, json.encode(ChatMessages)})
        end
    end
end)