local QBCore = exports['qb-core']:GetCoreObject()

-- NUI Callback

RegisterNUICallback('GetCryptosFromDegens', function(data, cb)
    cb(Config.CryptoCoins)
end)