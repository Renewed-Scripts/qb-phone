local QBCore = exports['qb-core']:GetCoreObject()

local function GetGarageNamephone(name)
    for k,v in pairs(Garages) do
        if k == name then
            return true
        end
    end
end

QBCore.Functions.CreateCallback('qb-phone:server:GetGarageVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Vehicles = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid = ?',
        {Player.PlayerData.citizenid})
    if result[1] then
        for k, v in pairs(result) do
            local VehicleData = QBCore.Shared.Vehicles[v.vehicle]
            local VehicleGarage = "None"
            if v.garage then
                if GetGarageNamephone(v.garage) then
                    if Garages[v.garage] or GangGarages[v.garage] or JobGarages[v.garage] then
                        if Garages[v.garage] then
                            VehicleGarage = Garages[v.garage]["label"]
                        elseif GangGarages[v.garage] then
                            VehicleGarage = GangGarages[v.garage]["label"]
                        elseif JobGarages[v.garage] then
                            VehicleGarage = JobGarages[v.garage]["label"]
                        end
                    end
                else
                    VehicleGarage = v.garage
                end
            end

            local VehicleState = "In"
            if v.state == 0 then
                VehicleState = "Out"
            elseif v.state == 2 then
                VehicleState = "Impounded"
            end

            local vehdata = {}
            if Config.Vinscratch then
                vinscratched = v.vinscratched
            else
                vinscratched = 'false'
            end
            if VehicleData["brand"] then
                if VehicleState == 'Out' then
                    state = 'Out'
                elseif VehicleState == 'In' then
                    state = 'Stored'
                end
                vehdata = {
                    fullname = VehicleData["brand"] .. " " .. VehicleData["name"],
                    brand = VehicleData["brand"],
                    model = VehicleData["name"],
                    vinscratched = vinscratched,
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = state,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body
                }
            else
                vehdata = {
                    fullname = VehicleData["name"],
                    brand = VehicleData["name"],
                    model = VehicleData["name"],
                    vinscratched = vinscratched,
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = state,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body
                }
            end
            Vehicles[#Vehicles+1] = vehdata
        end
        cb(Vehicles)
    else
        cb(nil)
    end
end)