RegisterNetEvent('qb-phone:server:addImageToGallery', function(image)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:insert('INSERT INTO phone_gallery (`citizenid`, `image`) VALUES (?, ?)',{Player.PlayerData.citizenid,image})
end)

RegisterNetEvent('qb-phone:server:getImageFromGallery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local images = exports.oxmysql:executeSync('SELECT * FROM phone_gallery WHERE citizenid = ? ORDER BY `date` DESC',{Player.PlayerData.citizenid})
    TriggerClientEvent('qb-phone:refreshImages', src, images)
end)

RegisterNetEvent('qb-phone:server:RemoveImageFromGallery', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local image = data.image
    exports.oxmysql:execute('DELETE FROM phone_gallery WHERE citizenid = ? AND image = ?',{Player.PlayerData.citizenid,image})
end)