Adverts = {}

local function GetAdvertFromNumb(src)
    for k, v in pairs(Adverts) do
        if v.source == src then
            return k
        end
    end
end

RegisterNetEvent('qb-phone:server:AddAdvert', function(msg, url)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    local table = GetAdvertFromNumb(src)
    if not url then url = "" else url = url:gsub("[%<>\"()\'$]","") end

    if table then
        Adverts[table] = {
            message = msg:gsub("[%<>\"()\'$]",""),
            name = name,
            number = Player.PlayerData.charinfo.phone,
            url = url,
            source = src,
        }
    else
        Adverts[#Adverts+1] = {
            message = msg:gsub("[%<>\"()\'$]",""),
            name = name,
            number = Player.PlayerData.charinfo.phone,
            url = url,
            source = src,
        }
    end

    TriggerClientEvent('qb-phone:client:UpdateAdverts', -1, Adverts, name, src)
end)

RegisterNetEvent('qb-phone:server:DeleteAdvert', function()
    local k = GetAdvertFromNumb(source)
    if not k then return end
    table.remove(Adverts, k)
    TriggerClientEvent('qb-phone:client:UpdateAdverts', -1, Adverts)
end)

RegisterNetEvent('qb-phone:server:flagAdvert', function(number)
    local src = source
    local Player = QBCore.Functions.GetPlayerByPhone(number)
    local citizenid = Player.PlayerData.citizenid
    local name = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
    -- Add some type of log here for admins to keep track of flagged posts
    TriggerClientEvent('QBCore:Notify', src, 'Post by '..name.. ' ['..citizenid..'] has been flagged', 'error')
end)
