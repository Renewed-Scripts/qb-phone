if GetResourceState('brazzers-cameras') == 'started' then
    RegisterNUICallback('SetupGoPros', function(_, cb)
        local list = Config.BrazzersCameras and exports['brazzers-cameras']:GetMyCams() or {}
        cb(list)
    end)

    RegisterNUICallback('gopro-viewcam', function(data, cb)
        if not data then return end
        TriggerEvent('Renewed-Cameras:ViewCamera', tonumber(data.id))
        cb("ok")
    end)

    RegisterNUICallback('gopro-track', function(data, cb)
        TriggerEvent('Renewed-Cameras:client:TrackCam', data.id)
        if not data then return end
        cb("ok")
    end)

    RegisterNUICallback('gopro-transfer', function(data, cb)
        if not data then return end
        TriggerEvent("Renewed-Cameras:client:GrantAccess", tonumber(data.id), tonumber(data.stateid))
        cb("ok")
    end)
end