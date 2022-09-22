# Installation steps

## General Setup
General setup is quite easy, delete your OLD qb-phone
if you server havent been running previously then go ahead and run the provided SQL file in your database.

If your server has been running qb-phone previously please update your sql while being carefull and take a backup so you have no data lost.

After the SQL setup you can now drop the resource into your server and start it up while you conduct the next steps.

## Employment setup
Setting up employment and multijob can be quite tricky so make sure to reread this if you have any issues...
If you already have a multijob system and you do not wish to use this then you can skip this step.


1. Head over to qb-phone/server/employment.lua and change local FirstStart from false to true like shown below

```lua
    local FirstStart = true
```

2. Start the script and make sure it's fully done, it can take a while depending on your current playerbase (ensure qb-phone in console or f8)

3. Head over to qb-phone/server/employment.lua again and change the FirstStart to false

Like so:
```lua
    local FirstStart = false
```

4. Headover to your qb-core/server/commands.lua and find the follow command 'setjob'

replace the commands with the code below:
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

5. Now below that add the new command called 'removejob' like shown below

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

6. If you use qb-cityhall then u have to Find ApplyJob in qb-cityhall/server/main.lua and replace with this one

```lua
RegisterNetEvent('qb-cityhall:server:ApplyJob', function(job, cityhallCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local JobInfo = QBCore.Shared.Jobs[job]
    if #(pedCoords - cityhallCoords) >= 20.0 or not availableJobs[job] then
        return DropPlayer(source, "Attempted exploit abuse")
    end
    Player.Functions.SetJob(job, 0)
    exports['qb-phone']:hireUser(job, Player.PlayerData.citizenid, 0)
TriggerClientEvent('QBCore:Notify', src, Lang:t('info.new_job', {job = JobInfo.label}))
end)
```

7. Restart your server fully to get the new commands working and also to get the phone fully working.


It should now look like this

![QBCore Commands](https://i.gyazo.com/beb2bd18c02088c184e5e381a9f4962a.png)


## Crypto Setup

1. Head over to your qb-core/server/Player.lua
2. Paste the below code into your metadata if you dont know what is metadata it looks something like this: PlayerData.metadata['inside']

Code to be pasted
```lua
    PlayerData.metadata['crypto'] = PlayerData.metadata['crypto'] or {
        ["shung"] = 0,
        ["gne"] = 0,
        ["xcoin"] = 0,
        ["lme"] = 0
    }
```

It should now all look like this:

![Metadata Table](https://i.gyazo.com/5422c6ebd1ede57ab523f2e1e07218c4.png)


This is pretty much everything to do with setting up the phone. If you encounter any issues please open a issue tab here on Github and I will try to fix them asap.


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

<details>
    <summary><b>uShifty</b></summary>
        <p>
            <a href="https://github.com/uShifty">
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
</details>

<details>
    <summary><b>iLLeniumStudios</b></summary>
        <p>
            <a href="https://github.com/iLLeniumStudios">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
        <p>
            <a href="https://discord.illenium.dev/">
                <img alt="GitHub" src="https://logos-download.com/wp-content/uploads/2021/01/Discord_Logo_full.png"
                width="150" height="55">
            </a>
        </p>
</details>

<details>
    <summary><b>ChatDisabled</b></summary>
        <p>
            <a href="https://github.com/ChatDisabled">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
</details>

<details>
    <summary><b>Devyn</b></summary>
        <p>Thanks to devyn for allowing us to use his original Group Backend code for the phone.</p>
        <p>
            <a href="https://github.com/darktrovx">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
</details>

<details>
    <summary><b>ST4LTH</b></summary>
        <p>
            <a href="https://github.com/ST4LTH">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
</details>

### Other Other Contributors

<details>
    <summary><b>DevTheBully</b></summary>
        <p>
            <a href="https://github.com/DevTheBully">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
</details>

<details>
    <summary><b>JonasDev99</b></summary>
        <p>
            <a href="https://github.com/JonasDev99">
                <img alt="GitHub" src="https://logos-world.net/wp-content/uploads/2020/11/GitHub-Emblem.png"
                width="150" height="70">
            </a>
        </p>
</details>


#### Other Other Other Contributors

<details>
    <summary><b>QBCore</b></summary>
        <p>Made the original phone ages ago and it was ok ish so shoutout to them IG</p>
</details>

<details>
    <summary><b>Kakarot</b></summary>
        <p>He cured my boredom over at twitch.tv/kakarotqb</p>
</details>

<details>
    <summary><b>amir_expert</b></summary>
        <p>Sold a $50 CSS and JS edit pretty poggers</p>
</details>

<details>
    <summary><b>Booya</b></summary>
        <p>Reuploaded a $50 CSS and JS edit even more poggers</p>
</details>

