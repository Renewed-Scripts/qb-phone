-- NUI Callback

RegisterNUICallback('GetGalleryData', function(_, cb)
    local data = PhoneData.Images
    cb(data)
end)

RegisterNUICallback('DeleteImage', function(image,cb)
    TriggerServerEvent('qb-phone:server:RemoveImageFromGallery',image)
    Wait(400)
    TriggerServerEvent('qb-phone:server:getImageFromGallery')
    cb(true)
end)

-- Events

RegisterNetEvent('qb-phone:refreshImages', function(images)
    PhoneData.Images = images
end)