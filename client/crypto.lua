-- NUI Callback

RegisterNUICallback('GetCryptosFromDegens', function(_, cb)
    cb(Config.CryptoCoins)
end)


RegisterNUICallback('BuyCrypto', function(data, cb)
    TriggerServerEvent('qb-phone:server:PurchaseCrypto', data.metadata, data.amount)

    cb("ok")
end)

RegisterNUICallback('SellCrypto', function(data, cb)
    TriggerServerEvent('qb-phone:server:SellCrypto', data.metadata, data.amount)
    cb("ok")
end)

RegisterNUICallback('ExchangeCrypto', function(data, cb)
    TriggerServerEvent('qb-phone:server:ExchangeCrypto', data.metadata, data.amount, data.stateid)

    cb("ok")
end)

RegisterNetEvent('qb-phone:client:UpdateCrypto', function()
    SendNUIMessage({
        action = "UpdateCrypto",
        PlayerData = PlayerData,
    })
end)
