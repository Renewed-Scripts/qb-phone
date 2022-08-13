


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