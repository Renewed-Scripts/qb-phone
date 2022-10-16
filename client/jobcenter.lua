local QBCore = exports['qb-core']:GetCoreObject()
NoVPN = {}
CreateThread(function ()
    for k, v in pairs(Config.JobCenter) do
        if v.vpn == false then
            NoVPN[#NoVPN+1] = v
        end
    end
end)

RegisterNUICallback('GetJobCentersJobs', function(data, cb)
    local result = QBCore.Functions.HasItem( "vpn")
    if result then
        cb(Config.JobCenter)
    else
        cb(NoVPN)
    end
end)

RegisterNUICallback('CasinoPhoneJobCenter', function(data)
    TriggerEvent(data.event)
end)

RegisterNetEvent('qb-phone:jobcenter:tow', function()
    SetNewWaypoint(-238.94, -1183.74)
end)

RegisterNetEvent('qb-phone:jobcenter:taxi', function()
    SetNewWaypoint(909.51, -177.36)
end)

RegisterNetEvent('qb-phone:jobcenter:postop', function()
    SetNewWaypoint(-432.51, -2787.98)
end)

RegisterNetEvent('qb-phone:jobcenter:sanitation', function()
    SetNewWaypoint(-351.44, -1566.37)
end)