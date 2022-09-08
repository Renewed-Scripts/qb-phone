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
    if not data.job or not data.cid or not data.amount then return end
    -- params ( data.cid / data.amount / data.note -- amount sent to employee )
    TriggerServerEvent('qb-phone:server:SendEmploymentPayment', data.job, data.cid, data.amount)
    cb("ok")
end)

RegisterNUICallback('RemoveEmployee', function(data, cb)
    --if data.cid == PlayerData.citizenid then return print("Cant fire yourself") end
    if not data or not data.job or not data.cid then return end
    -- params ( data.cid )
    print(json.encode(data))


    TriggerServerEvent('qb-phone:server:fireUser', data.job, data.cid)

    cb("ok")
end)

RegisterNUICallback('GiveBankAccess', function(data, cb)
    -- params ( data.cid ) This will be toggable since there is not a 'remove bank access' button
    -- Maybe we can get some data sent to the java script where it can define if someone has bank access or not
end)

RegisterNUICallback('ClockIn', function(data, cb)
    -- ( data.job )  is the job to click into here
end)

RegisterNUICallback('HireFucker', function(data, cb)
    -- ( data.stateid - as source right now but we can change if needed )
    -- ( data.job ) job to be hired to
    -- ( data.grade ) grade level to be hired to
    print(data.stateid)
    print(data.job)
    print(data.grade)
end)

RegisterNUICallback('ChargeMF', function(data, cb)
    -- ( data.stateid - as source right now but we can change if needed )
    -- ( data.amount ) amount billed
    -- ( data.note ) note that comes with the invoice/ bill
    print(data.stateid)
    print(data.amount)
    print(data.note)
end)

RegisterNetEvent('qb-phone:client:JobsHandler', function(job, employees)
    if not job or not employees then return end

    if not cachedEmployees[job] then return end

    cachedEmployees[job] = employees

    table.sort(cachedEmployees[job], function(a, b)
        return a.grade.level > b.grade.level
    end)
end)


RegisterNetEvent('qb-phone:client:MyJobsHandler', function(job, table, employees)
    print(job, table)
    if not QBCore.Shared.Jobs[job] then return end

    myJobs[job] = table
    cachedEmployees[job] = employees
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
