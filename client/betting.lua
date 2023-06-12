-- NUI Callback

RegisterNUICallback('CasinoAddBet', function(data, cb)
    TriggerServerEvent('qb-phone:server:CasinoAddBet', data)
    cb("ok")
end)

RegisterNetEvent('qb-phone:client:addbetForAll', function(data)
    SendNUIMessage({
        action = "BetAddToApp",
        datas = data,
    })
end)

RegisterNUICallback('BettingAddToTable', function(data, cb)
    TriggerServerEvent('qb-phone:server:BettingAddToTable', data)
    cb("ok")
end)

RegisterNUICallback('CasinoDeleteTable', function(_, cb)
    TriggerServerEvent('qb-phone:server:DeleteAndClearTable')
    cb("ok")
end)

RegisterNUICallback('CheckHasBetTable', function(_, cb)
    lib.callback('qb-phone:server:CheckHasBetTable', false, function(HasTable)
        cb(HasTable)
    end)
end)

RegisterNUICallback('casino_status', function(_, cb)
    TriggerServerEvent('qb-phone:server:casino_status')
    cb("ok")
end)

RegisterNUICallback('CheckHasBetStatus', function(_, cb)
    lib.callback('qb-phone:server:CheckHasBetStatus', false, function(HasStatus)
        cb(HasStatus)
    end)
end)

RegisterNUICallback('WineridCasino', function(data, cb)
    TriggerServerEvent('qb-phone:server:WineridCasino', data)
    cb("ok")
end)