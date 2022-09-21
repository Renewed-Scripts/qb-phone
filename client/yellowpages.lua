-- Yellow Pages
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNUICallback('GetCurrentyellowpages', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetCurrentyellowpages', function(yellowpages)
        cb(yellowpages)
    end)
end)

RegisterNUICallback('callJob', function(data, cb)

    QBCore.Functions.TriggerCallback("qb-phone:server:getRandomJobContact", function(result)
        if result ~= nil then
            QBCore.Functions.TriggerCallback('qb-phone:server:GetCallState2', function(CanCall, IsOnline)
                local status = { 
                    CanCall = CanCall, 
                    IsOnline = IsOnline,
                    InCall = PhoneData.CallData.InCall,
                    data = {
                        name = result.joblabel,
                        number = result.number
                    }
                }
                cb(status)
                if CanCall and not status.InCall then
                    CallContact(result, data.Anonymous)
                end
            end, result.source)
        else
            SendNUIMessage({ action = "PhoneNotification", 
            PhoneNotify = { 
                timeout= 3000, 
                title = "Yellow Pages", 
                text = "No one in service currently!", 
                icon = "fas fa-phone", 
                color = "#FFD700", }, })
        end
    end, data.job)
end)