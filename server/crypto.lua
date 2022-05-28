local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-phone:server:AddTransaction', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:insert('INSERT INTO crypto_transactions (citizenid, title, message) VALUES (?, ?, ?)', {
        Player.PlayerData.citizenid,
        data.TransactionTitle,
        data.TransactionMessage
    })
end)