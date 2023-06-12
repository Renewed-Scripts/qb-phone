RegisterNUICallback('GetAvailableTaxiDrivers', function(_, cb)
    lib.callback('qb-phone:server:GetAvailableTaxiDrivers', false, function(drivers)
        cb(drivers)
    end)
end)

RegisterNetEvent('qb-phone:OpenAvailableTaxi', function()
    local taxiMenu = {}

    -- TO BE WRITTEN

    lib.registerContext({
        id = 'taxi_call_menu',
        title = 'Available Taxis',
        options = taxiMenu
    })
    lib.showContext('taxi_call_menu')
end)