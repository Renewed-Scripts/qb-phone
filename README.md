# qb-phone
Phone for QB-Core Framework. Edited for a NP-Style look with a few extra things, This file has been edited with the changes noted

# Known Issues
- Ping App doesn't work at longer ranges, only thing I'm really working on at the moment on it that will be pushed. If someone else figures out the issue earlier and wants to PR it, I will take it.

# License

    QBCore Framework
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>

## Dependencies
- [qb-core](https://github.com/QBCore-framework/qb-core)
- [qb-policejob](https://github.com/QBCore-framework/qb-policejob) - MEOS, handcuff check etc. 
- [qb-crypto](https://github.com/QBCore-framework/qb-crypto) - Crypto currency trading 
- [qb-lapraces](https://github.com/QBCore-framework/qb-lapraces) - Creating routes and racing 
- [qb-houses](https://github.com/QBCore-framework/qb-houses) - House and Key Management App
- [qb-garages](https://github.com/QBCore-framework/qb-garages) - For Garage App
- [qb-banking](https://github.com/QBCore-framework/qb-banking) - For Banking App
- [screenshot-basic](https://github.com/citizenfx/screenshot-basic) - For Taking Photos
- A Webhook for hosting photos (Discord or Imgur can provide this)
- Some sort of help app for your Help icon to function, just place your event for opening it in client.lua line 2403 
```
RegisterNUICallback('openHelp', function()  
    TriggerEvent('eventgoeshere')  <---------
end)
```


## Screenshots
![Home](https://cdn.discordapp.com/attachments/951493035173244999/951493181550243900/Screenshot_20.png)
![Messages](https://cdn.discordapp.com/attachments/951493035173244999/951493291243880499/Screenshot_21.png)
![Phone](https://cdn.discordapp.com/attachments/951493035173244999/951493463659122688/Screenshot_22.png)
![Settings](https://cdn.discordapp.com/attachments/951493035173244999/951493587072319498/Screenshot_23.png)
![MEOS](https://cdn.discordapp.com/attachments/951493035173244999/951495644563005470/Screenshot_35.png)
![Vehicles](https://cdn.discordapp.com/attachments/951493035173244999/951493876777103440/Screenshot_24.png)
![Email](https://cdn.discordapp.com/attachments/951493035173244999/951494010764140544/Screenshot_25.png)
![Advertisements](https://cdn.discordapp.com/attachments/951493035173244999/951494113788821624/Screenshot_26.png)
![Houses](https://cdn.discordapp.com/attachments/951493035173244999/951494238183505920/Screenshot_27.png)
![Services](https://cdn.discordapp.com/attachments/951493035173244999/951495770249502760/Screenshot_36.png)
![Racing](https://cdn.discordapp.com/attachments/951493035173244999/951495869289615400/Screenshot_37.png)
![Crypto](https://cdn.discordapp.com/attachments/951493035173244999/951494393397927956/Screenshot_28.png)
![Debt](https://cdn.discordapp.com/attachments/951493035173244999/951494527049433178/Screenshot_29.png)
![Wenmo](https://cdn.discordapp.com/attachments/951493035173244999/951494642019471370/Screenshot_30.png)
![Invoices](https://cdn.discordapp.com/attachments/951493035173244999/951494745648148560/Screenshot_31.png)
![Casino](https://cdn.discordapp.com/attachments/951493035173244999/951494899994329088/Screenshot_32.png)
![News](https://cdn.discordapp.com/attachments/951493035173244999/951495036351180860/Screenshot_33.png)
![Notepad](https://cdn.discordapp.com/attachments/951493035173244999/951495531153195038/Screenshot_34.png)
![Details](https://cdn.discordapp.com/attachments/951493035173244999/951496024885719111/Screenshot_38.png)
![JobCenter](https://cdn.discordapp.com/attachments/951493035173244999/951496191202451586/Screenshot_39.png)
![Employment](https://cdn.discordapp.com/attachments/951493035173244999/951496402008158328/Screenshot_40.png)
![Calculator](https://cdn.discordapp.com/attachments/951493035173244999/951496520073621544/Screenshot_41.png)

## Features
- Garages app to see your vehicle details
- Mails to inform the player
- Debt app for player invoices, Wenmo for quick bank transfers, Invoice app for legal invoices
- Racing app to create races
- MEOS app for police to search
- House app for house details and management
- Casino app for players to make bets and possibly multiply money
- News app for news postings
- Details tab for some player information at the palm of your hand
- Tweets save to database for recall on restarts, edit how long they stay in config
- Notepad app to make and save notes
- Calculator app
- Job Center and Employment apps just like the NoPickle

## Installation
### Manual
- Download the script and put it in the `[qb]` directory.
- Import `qb-phone.sql` in your database
- Add a third paramater in your Functions.AddMoney and Functions.RemoveMoney which will be a reaosn for your "Wenmo" app to show why you sent or received money. To do this you search all of your files for these 2 functions and add a reason to it.. Ex: 
```
Player.Functions.AddMoney('bank', payment)
```
would then be
```
 Player.Functions.AddMoney('bank', payment, "paycheck")
 ```
- Add the following code to your server.cfg/resouces.cfg
```
ensure qb-core
ensure screenshot-basic
ensure qb-phone
ensure qb-policejob
ensure qb-crypto
ensure qb-lapraces
ensure qb-houses
ensure qb-garages
ensure qb-banking
```

## Setup Webhook in `server/main.lua` for photos
Set the following variable to your webhook (For example, a Discord channel or Imgur webhook)
### To use Discord:
- Right click on a channel dedicated for photos
- Click Edit Channel
- Click Integrations
- Click View Webhooks
- Click New Webhook
- Confirm channel
- Click Copy Webhook URL
- Paste into `WebHook` in `server/main.lua`
```
local WebHook = ""
```
