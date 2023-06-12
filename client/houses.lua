-- NUI Callback

RegisterNUICallback('GetPlayerHouses', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetPlayerHouses', function(Houses)
        cb(Houses)
    end)
end)

RegisterNUICallback('GetPlayerKeys', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetHouseKeys', function(Keys)
        cb(Keys)
    end)
end)

RegisterNUICallback('SetHouseLocation', function(data, cb)
    SetNewWaypoint(data.HouseData.HouseData.coords.enter.x, data.HouseData.HouseData.coords.enter.y)
    QBCore.Functions.Notify("GPS set to " .. data.HouseData.HouseData.adress .. "!", "success")
    cb("ok")
end)

RegisterNUICallback('RemoveKeyholder', function(data, cb)
    TriggerServerEvent('qb-houses:server:removeHouseKey', data.HouseData.name, {
        citizenid = data.HolderData.citizenid,
        firstname = data.HolderData.charinfo.firstname,
        lastname = data.HolderData.charinfo.lastname,
    })

    cb("ok")
end)

RegisterNUICallback('TransferCid', function(data, cb)
    local TransferedCid = data.newBsn

    QBCore.Functions.TriggerCallback('qb-phone:server:TransferCid', function(CanTransfer)
        cb(CanTransfer)
    end, TransferedCid, data.HouseData)
end)

RegisterNUICallback('FetchPlayerHouses', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:MeosGetPlayerHouses', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('SetGPSLocation', function(data, cb)
    SetNewWaypoint(data.coords.x, data.coords.y)
    QBCore.Functions.Notify('GPS set!', "success")

    cb("ok")
end)

RegisterNUICallback('SetApartmentLocation', function(data, cb)
    local ApartmentData = data.data.appartmentdata
    local TypeData = Apartments.Locations[ApartmentData.type]

    SetNewWaypoint(TypeData.coords.enter.x, TypeData.coords.enter.y)
    QBCore.Functions.Notify('GPS set!', "success")

    cb("ok")
end)