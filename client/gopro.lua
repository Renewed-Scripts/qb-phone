


RegisterNUICallback('SetupGoPros', function(_, cb)
    print("camerashit")
    local list = exports['qb-cameras']:GetMyCams()
    print(json.encode(list))
    cb(exports['qb-cameras']:GetMyCams())
end)

RegisterNUICallback('gopro-viewcam', function(data, cb)
    if not data then return end
    TriggerEvent('Renewed-Cameras:ViewCamera', tonumber(data.id))
    cb("ok")
end)

RegisterNUICallback('gopro-track', function(data, cb)
    print("TRACK")
    print(json.encode(data))
    TriggerEvent('Renewed-Cameras:client:TrackCam', data.id)
    if not data then return end
    cb("ok")
end)

RegisterNUICallback('gopro-transfer', function(data, cb)
    print("TRANSFER")
    print(json.encode(data))
    if not data then return end
    cb("ok")
end)