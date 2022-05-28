local QBCore = exports['qb-core']:GetCoreObject()
local GeneratedPlates = {}

-- Functions

local function escape_sqli(source)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return source:gsub("['\"]", replacements)
end

local function GenerateOwnerName()
    local names = {
        [1] = {
            name = "Jan Bloksteen",
            citizenid = "DSH091G93"
        },
        [2] = {
            name = "Jay Dendam",
            citizenid = "AVH09M193"
        },
        [3] = {
            name = "Ben Klaariskees",
            citizenid = "DVH091T93"
        },
        [4] = {
            name = "Karel Bakker",
            citizenid = "GZP091G93"
        },
        [5] = {
            name = "Klaas Adriaan",
            citizenid = "DRH09Z193"
        },
        [6] = {
            name = "Nico Wolters",
            citizenid = "KGV091J93"
        },
        [7] = {
            name = "Mark Hendrickx",
            citizenid = "ODF09S193"
        },
        [8] = {
            name = "Bert Johannes",
            citizenid = "KSD0919H3"
        },
        [9] = {
            name = "Karel de Grote",
            citizenid = "NDX091D93"
        },
        [10] = {
            name = "Jan Pieter",
            citizenid = "ZAL0919X3"
        },
        [11] = {
            name = "Huig Roelink",
            citizenid = "ZAK09D193"
        },
        [12] = {
            name = "Corneel Boerselman",
            citizenid = "POL09F193"
        },
        [13] = {
            name = "Hermen Klein Overmeen",
            citizenid = "TEW0J9193"
        },
        [14] = {
            name = "Bart Rielink",
            citizenid = "YOO09H193"
        },
        [15] = {
            name = "Antoon Henselijn",
            citizenid = "QBC091H93"
        },
        [16] = {
            name = "Aad Keizer",
            citizenid = "YDN091H93"
        },
        [17] = {
            name = "Thijn Kiel",
            citizenid = "PJD09D193"
        },
        [18] = {
            name = "Henkie Krikhaar",
            citizenid = "RND091D93"
        },
        [19] = {
            name = "Teun Blaauwkamp",
            citizenid = "QWE091A93"
        },
        [20] = {
            name = "Dries Stielstra",
            citizenid = "KJH0919M3"
        },
        [21] = {
            name = "Karlijn Hensbergen",
            citizenid = "ZXC09D193"
        },
        [22] = {
            name = "Aafke van Daalen",
            citizenid = "XYZ0919C3"
        },
        [23] = {
            name = "Door Leeferds",
            citizenid = "ZYX0919F3"
        },
        [24] = {
            name = "Nelleke Broedersen",
            citizenid = "IOP091O93"
        },
        [25] = {
            name = "Renske de Raaf",
            citizenid = "PIO091R93"
        },
        [26] = {
            name = "Krisje Moltman",
            citizenid = "LEK091X93"
        },
        [27] = {
            name = "Mirre Steevens",
            citizenid = "ALG091Y93"
        },
        [28] = {
            name = "Joosje Kalvenhaar",
            citizenid = "YUR09E193"
        },
        [29] = {
            name = "Mirte Ellenbroek",
            citizenid = "SOM091W93"
        },
        [30] = {
            name = "Marlieke Meilink",
            citizenid = "KAS09193"
        }
    }
    return names[math.random(1, #names)]
end

-- Events

QBCore.Functions.CreateCallback('qb-phone:server:GetVehicleSearchResults', function(source, cb, search)
    local search = escape_sqli(search)
    local searchData = {}
    local query = '%' .. search .. '%'
    local result = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE plate LIKE ? OR citizenid = ?',
        {query, search})
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local player = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', {result[k].citizenid})
            if player[1] ~= nil then
                local charinfo = json.decode(player[1].charinfo)
                local vehicleInfo = QBCore.Shared.Vehicles[result[k].vehicle]
                if vehicleInfo ~= nil then
                    searchData[#searchData+1] = {
                        plate = result[k].plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[k].citizenid,
                        label = vehicleInfo["name"]
                    }
                else
                    searchData[#searchData+1] = {
                        plate = result[k].plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[k].citizenid,
                        label = "Name not found.."
                    }
                end
            end
        end
    else
        if GeneratedPlates[search] ~= nil then
            searchData[#searchData+1] = {
                plate = GeneratedPlates[search].plate,
                status = GeneratedPlates[search].status,
                owner = GeneratedPlates[search].owner,
                citizenid = GeneratedPlates[search].citizenid,
                label = "Brand unknown.."
            }
        else
            local ownerInfo = GenerateOwnerName()
            GeneratedPlates[search] = {
                plate = search,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid
            }
            searchData[#searchData+1] = {
                plate = search,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid,
                label = "Brand unknown.."
            }
        end
    end
    cb(searchData)
end)

QBCore.Functions.CreateCallback('qb-phone:server:ScanPlate', function(source, cb, plate)
    local src = source
    local vehicleData = {}
    if plate ~= nil then
        local result = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
        if result[1] ~= nil then
            local player = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', {result[1].citizenid})
            local charinfo = json.decode(player[1].charinfo)
            vehicleData = {
                plate = plate,
                status = true,
                owner = charinfo.firstname .. " " .. charinfo.lastname,
                citizenid = result[1].citizenid
            }
        elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then
            vehicleData = GeneratedPlates[plate]
        else
            local ownerInfo = GenerateOwnerName()
            GeneratedPlates[plate] = {
                plate = plate,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid
            }
            vehicleData = {
                plate = plate,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid
            }
        end
        cb(vehicleData)
    else
        TriggerClientEvent('QBCore:Notify', src, 'No Vehicle Nearby', "error")
        cb(nil)
    end
end)