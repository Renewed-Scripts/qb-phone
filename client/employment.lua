local QBCore = exports['qb-core']:GetCoreObject()


-- Use This Callback Whenever You Need To Get A the information --
local cachedEmployees = {}
local myJobs = {}

-- NUI Callbacks

RegisterNUICallback('GetJobs', function(_, cb)
    cb(myJobs)
end)

RegisterNUICallback('GetEmployees', function(data, cb)
    if not data.job then return end

    local employees = cachedEmployees[data.job] or {}

    cb(employees)
end)

RegisterNUICallback('SendEmployeePayment', function(data, cb)
    -- params ( data.cid / data.amount -- amount sent to employee )
end)

RegisterNUICallback('RemoveEmployee', function(data, cb)
    -- params ( data.cid )
end)

RegisterNUICallback('GiveBankAccess', function(data, cb)
    -- params ( data.cid ) This will be toggable since there is not a 'remove bank access' button
    -- Maybe we can get some data sent to the java script where it can define if someone has bank access or not
end)

RegisterNetEvent('qb-phone:client:JobsHandler', function(job, employees)
    if not job or not employees then return end

    if not cachedEmployees[job] then return end

    cachedEmployees[job].employees = employees

    table.sort(cachedEmployees[job].employees, function(a, b)
        return a.grade.level > b.grade.level
    end)
end)


RegisterNetEvent('qb-phone:client:MyJobsHandler', function(job, table)
    print(job, table)
    if not QBCore.Shared.Jobs[job] then return end

    myJobs[job] = table
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(300)
        QBCore.Functions.TriggerCallback('qb-phone:server:GetMyJobs', function(employees, myShit)
            print(json.encode(employees), json.encode(myShit))
            cachedEmployees = employees

            print(json.encode(cachedEmployees))

            if myShit then
                for k, v in pairs(myShit) do
                    if not myJobs[k] then myJobs[k] = v end
                end
            end
        end)
    end
end)
