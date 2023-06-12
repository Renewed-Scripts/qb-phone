QBCore.Commands.Add("setmetadata", "Set Player Metadata (God Only)", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if args[1] then
        if args[1] == "trucker" then
            if args[2] then
                local newrep = Player.PlayerData.metadata["jobrep"]
                newrep.trucker = tonumber(args[2])
                Player.Functions.SetMetaData("jobrep", newrep)
            end
        end
    end
end, "god")

QBCore.Commands.Add("p#", "Provide Phone Number", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerPed = GetPlayerPed(src)
    local number = Player.PlayerData.charinfo.phone
	local PlayerCoords = GetEntityCoords(PlayerPed)
	for _, v in pairs(QBCore.Functions.GetPlayers()) do
		local TargetPed = GetPlayerPed(v)
		local dist = #(PlayerCoords - GetEntityCoords(TargetPed))

		if dist < 3.0 then
            TriggerClientEvent('chat:addMessage', v, {
                color = { 255, 0, 0},
                multiline = true,
                args = {"Phone #", number}
            })
		end
	end
end)
