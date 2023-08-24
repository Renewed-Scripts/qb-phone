RegisterNUICallback('GetAvailableTaxiDrivers', function(_, cb)
    local drivers = lib.callback.await('qb-phone:server:GetAvailableTaxiDrivers', false)
    cb(drivers)
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