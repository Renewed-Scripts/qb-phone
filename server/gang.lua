local QBCore = exports['qb-core']:GetCoreObject()

local function notifyPlayer(src, message)
    if not src or not message then return end

    TriggerClientEvent('qb-phone:client:CustomNotification', src,
        "Gang",
        message,
        "fas fa-network-wired",
        "#FFFC00",
        10000
    )
end


---- ** Handles the hiring someone at the gang ** ----
RegisterNetEvent('qb-phone:server:HireGangMember', function(Gang, id, grade)
    local src = source
    local hiredPlayer = QBCore.Functions.GetPlayer(tonumber(id))

    if hiredPlayer then
        hiredPlayer.Functions.SetGang(Gang, grade)
        notifyPlayer(src, "You let the person into your gang...")
    else
        notifyPlayer(src, "Person is not in the city...")
    end
end)

---- ** Handles the yeeting of member from gang ** ----
RegisterNetEvent('qb-phone:server:YeetMember', function(CID)
    local src = source
    local Player = QBCore.Functions.GetPlayerByCitizenId(CID)

    if Player then
        Player.Functions.SetGang("none", 0)
        notifyPlayer(src, "You kicked the person from the gang..")
    else
        notifyPlayer(src, "Person is not in the city...")
    end
end)

---- ** Handles the changing of someone grade within the job ** ----

RegisterNetEvent('qb-phone:server:ManageGangMembers', function(Gang, CID, grade)
    local src = source
    if not Gang or not CID then return end
    local Player = QBCore.Functions.GetPlayerByCitizenId(CID)
    if Player then
        Player.Functions.SetGang(Gang, grade)
        notifyPlayer(src, "You changed the persons role...")
    else
        notifyPlayer(src, "Person is not in the city...")
    end
end)

---- Gets the client side cache for players ----
QBCore.Functions.CreateCallback("qb-phone:server:GetGangMembers", function(_, cb, gangname)
    local employees = {}
	local players = MySQL.Sync.fetchAll("SELECT * FROM `players` WHERE `gang` LIKE '%".. gangname .."%'", {})
	if players[1] ~= nil then
		for _, value in pairs(players) do
            QBCore.Debug(value.gang)
			local isOnline = QBCore.Functions.GetPlayerByCitizenId(value.citizenid)
			if isOnline then
				employees[#employees+1] = {
				empSource = isOnline.PlayerData.citizenid,
				grade = isOnline.PlayerData.gang.grade,
				isboss = isOnline.PlayerData.gang.isboss,
                gangName = isOnline.PlayerData.gang.name,
                gangLabel = isOnline.PlayerData.gang.label,
                gradeName = isOnline.PlayerData.gang.grade.name,
                gradeLevel = isOnline.PlayerData.gang.grade.level,
				name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
				}
			else
				employees[#employees+1] = {
				empSource = value.citizenid,
				grade =  json.decode(value.gang).grade,
				isboss = json.decode(value.gang).isboss,
                gangName = json.decode(value.gang).name,
                gangLabel = json.decode(value.gang).label,
                gradeName = json.decode(value.gang).grade.name,
                gradeLevel = json.decode(value.gang).grade.level,
				name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
				}
			end
		end
	end
	cb(employees)
end)