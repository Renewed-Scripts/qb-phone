local QBCore = exports['qb-core']:GetCoreObject()


-- Use This Callback Whenever You Need To Get A the information --
local cachedEmployees = {}
local myJobs = {}

RegisterNUICallback('GetJobs', function(_, cb)
    cb(myJobs)
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
