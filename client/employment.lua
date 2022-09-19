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

RegisterNUICallback('ChangeRole', function(data, cb)
    if not data then return end

    cb("ok")

    -- params ( data.cid / data.grade) This will be toggable since there is not a 'remove bank access' button
    -- Maybe we can get some data sent to the java script where it can define if someone has bank access or not
end)

RegisterNUICallback('ClockIn', function(data, cb)
    if not data or not data.job then return end
    print("clock in")

    print(json.encode(data))


    TriggerServerEvent('qb-phone:server:clockOnDuty', data.job)

    cb("ok")
    -- ( data.job )  is the job to click into here
end)

RegisterNUICallback('HireFucker', function(data, cb)
    -- ( data.stateid - as source right now but we can change if needed )
    -- ( data.job ) job to be hired to
    -- ( data.grade ) grade level to be hired to
    print(data.stateid)
    print(data.job)
    print(data.grade)

    TriggerServerEvent('qb-phone:server:hireUser',data.job, data.stateid, data.grade)

    cb("ok")
end)

RegisterNUICallback('ChargeMF', function(data, cb)
    if not data or not data.stateid or not data.amount or not data.job then return end

    TriggerServerEvent('qb-phone:server:ChargeCustomer', data.stateid, data.amount, data.note, data.job)

    cb("ok")
end)

RegisterNetEvent('qb-phone:client:JobsHandler', function(job, employees)
    if not job or not employees then return end
    if not cachedEmployees[job] then return end

    cachedEmployees[job] = {}
    for _, v in pairs(employees) do
        cachedEmployees[job][#cachedEmployees[job]+1] = {
            cid = v.cid,
            name = v.name,
            grade = tonumber(v.grade),
        }
        table.sort(cachedEmployees[job], function(a, b)
            return a.grade > b.grade
        end)
    end
end)


RegisterNetEvent('qb-phone:client:MyJobsHandler', function(job, jobTable, employees)
    if not QBCore.Shared.Jobs[job] then return end

    myJobs[job] = jobTable

    if employees then
        cachedEmployees[job] = {}
        for _, v in pairs(employees) do
            cachedEmployees[job][#cachedEmployees[job]+1] = {
                cid = v.cid,
                name = v.name,
                grade = tonumber(v.grade),
            }
            table.sort(cachedEmployees[job], function(a, b)
                return a.grade > b.grade
            end)
        end
    else
        cachedEmployees[job] = nil
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(300)
        QBCore.Functions.TriggerCallback('qb-phone:server:GetMyJobs', function(employees, myShit)
            for k, _ in pairs(employees) do
                for _, v in pairs(employees[k]) do
                    if not cachedEmployees[k] then cachedEmployees[k] = {} end
                    cachedEmployees[k][#cachedEmployees[k]+1] = {
                        cid = v.cid,
                        name = v.name,
                        grade = tonumber(v.grade),
                    }
                end
                table.sort(cachedEmployees[k], function(a, b)
                    return a.grade > b.grade
                end)
            end


            if myShit then
                for k, v in pairs(myShit) do
                    if QBCore.Shared.Jobs[k] and not myJobs[k] then myJobs[k] = v end
                end
            end
        end)
    end
end)



RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-phone:server:GetMyJobs', function(employees, myShit)
        for k, _ in pairs(employees) do
            for _, v in pairs(employees[k]) do
                if not cachedEmployees[k] then cachedEmployees[k] = {} end
                cachedEmployees[k][#cachedEmployees[k]+1] = {
                    cid = v.cid,
                    name = v.name,
                    grade = tonumber(v.grade),
                }
            end
            table.sort(cachedEmployees[k], function(a, b)
                return a.grade > b.grade
            end)
        end


        if myShit then
            for k, v in pairs(myShit) do
                if QBCore.Shared.Jobs[k] and not myJobs[k] then myJobs[k] = v end
            end
        end
    end)
end)
