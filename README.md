# Installation steps
 (needs to be organized - rephrased)
- When launching this resource for the first time set FirstRun to true: - provide location of it
```lua
    local FirstRun = true
```
and then set it to false:
```lua
    local FirstRun = false
```

- replace commands below:
setjob command - add the location of it
```lua
QBCore.Commands.Add('setjob', 'Set A Players Job (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'job', help = 'Job name' }, { name = 'grade', help = 'Grade' } }, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
        exports['qb-phone']:hireUser(tostring(args[2]), Player.PlayerData.citizenid, tonumber(args[3]))
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')
```

removejob command - add the location of it
```lua
QBCore.Commands.Add('removejob', 'Removes A Players Job (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'job', help = 'Job name' } }, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        if Player.PlayerData.job.name == tostring(args[2]) then
            Player.Functions.SetJob("unemployed", 0)
        end
        exports['qb-phone']:fireUser(tostring(args[2]), Player.PlayerData.citizenid)
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')
```


# Contributors

## Main Contributors
<details>
    <summary><b>FjamZoo</b></summary>
        <p>
            <a href="https://github.com/FjamZoo">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
        <p>
            <a href="https://discord.gg/AS2Y8TWejt">
                <img alt="GitHub" src="https://logos-download.com/wp-content/uploads/2021/01/Discord_Logo_full.png"
                width="150" height="55">
            </a>
        </p>
        <p>
            <a href="https://ko-fi.com/FjamZoo">
                <img alt="GitHub" src="https://uploads-ssl.webflow.com/5c14e387dab576fe667689cf/61e11149b3af2ee970bb8ead_Ko-fi_logo.png"
                width="150" height="55">
            </a>
        </p>
</details>

<details>
    <summary><b>MannyOnBrazzers</b></summary>
        <p>
            <a href="https://github.com/MannyOnBrazzers">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
        <p>
            <a href="https://discord.gg/puWUx5FsAv">
                <img alt="GitHub" src="https://logos-download.com/wp-content/uploads/2021/01/Discord_Logo_full.png"
                width="150" height="55">
            </a>
        </p>
        <p>
            <a href="https://ko-fi.com/mannyonbrazzers">
                <img alt="GitHub" src="https://uploads-ssl.webflow.com/5c14e387dab576fe667689cf/61e11149b3af2ee970bb8ead_Ko-fi_logo.png"
                width="150" height="55">
            </a>
        </p>
</details>

### Other Contributors