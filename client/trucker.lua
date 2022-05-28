local QBCore = exports['qb-core']:GetCoreObject()

-- NUI Callback

RegisterNUICallback('GetTruckerData', function(data, cb)
    local TruckerMeta = PlayerData.metadata["jobrep"]["trucker"]
    local TierData = exports['qb-trucker']:GetTier(TruckerMeta)
    cb(TierData)
end)