RegisterNetEvent("qb-phone:server:sendPing", function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Shitter = tonumber(id)
    local Other = QBCore.Functions.GetPlayer(Shitter)
    local HasVPN = Player.Functions.GetItemByName(Config.VPNItem)
    local name = HasVPN and 'Anonymous' or Player.PlayerData.charinfo.firstname

    if not Other then return TriggerClientEvent("QBCore:Notify", src, 'State ID does not exist!', "error") end

    local info = { type = 'ping', Other = Shitter, Player = src, Name = name, OtherName = Other.PlayerData.charinfo.firstname }
    if Player.PlayerData.citizenid ~= Other.PlayerData.citizenid then
        TriggerClientEvent("qb-phone:client:sendNotificationPing", Shitter, info)
        TriggerClientEvent("QBCore:Notify", src, 'Request Sent', "success")
    else
        TriggerClientEvent("QBCore:Notify", src, 'You cannot send a ping to yourself!', "error")
    end
end)

RegisterNetEvent("qb-phone:server:sendingPing", function(Other, Player, Name, OtherName)
    TriggerClientEvent('qb-phone:client:CustomNotification', Player, "PING", OtherName..' Accepted Your Ping!', 'fas fa-map-pin', '#b3e0f2', 7500)
    TriggerClientEvent("qb-phone:client:sendPing", Other, Name, GetEntityCoords(GetPlayerPed(Player)))
end)