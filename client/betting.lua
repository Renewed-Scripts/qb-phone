local QBCore = exports['qb-core']:GetCoreObject()

-- NUI Callback

RegisterNUICallback('CasinoAddBet', function(data)
    TriggerServerEvent('qb-phone:server:CasinoAddBet', data)
end)

RegisterNetEvent('qb-phone:client:addbetForAll', function(data)
    SendNUIMessage({
        action = "BetAddToApp",
        datas = data,
    })
end)

RegisterNUICallback('BettingAddToTable', function(data)
    TriggerServerEvent('qb-phone:server:BettingAddToTable', data)
end)

RegisterNUICallback('CasinoDeleteTable', function(data)
    TriggerServerEvent('qb-phone:server:DeleteAndClearTable')
end)

RegisterNUICallback('CheckHasBetTable', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:CheckHasBetTable', function(HasTable)
        cb(HasTable)
    end)
end)

RegisterNUICallback('casino_status', function(data)
    TriggerServerEvent('qb-phone:server:casino_status')
end)

RegisterNUICallback('CheckHasBetStatus', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:CheckHasBetStatus', function(HasStatus)
        cb(HasStatus)
    end)
end)

RegisterNUICallback('WineridCasino', function(data)
    TriggerServerEvent('qb-phone:server:WineridCasino', data)
end)