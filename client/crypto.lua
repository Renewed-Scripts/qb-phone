local QBCore = exports['qb-core']:GetCoreObject()

-- NUI Callback

RegisterNUICallback('GetCryptosFromDegens', function(data, cb)
    cb(Config.CryptoCoins)
end)






-- This is not setup just put it in here when we do need it
RegisterNUICallback('BuyCrypto', function(data, cb)

    TriggerServerEvent('qb-phone:server:PurchaseCrypto', data.metadata, data.amount)

    cb("ok")
end)

