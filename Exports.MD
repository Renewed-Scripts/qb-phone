qb-phone exports

# Crypto (Server side)

```

exports['qb-phone']:RemoveCrypto(src, type, amount)

exports['qb-phone']:hasEnough(src, type, amount)

exports['qb-phone']:AddCrypto(src, type, amount)

```

# Employment (Server side)

```

exports['qb-phone']:hireUser(Job, CID, grade)

exports['qb-phone']:fireUser(Job, CID)

```

# Groups (Server Side)
```

exports['qb-phone']:NotifyGroup(group, msg, type)

exports['qb-phone']:pNotifyGroup(group, header, msg, icon, colour, length)

exports['qb-phone']:CreateBlipForGroup(groupID, name, data)

exports['qb-phone']:RemoveBlipForGroup(groupID, name)

exports['qb-phone']:GetGroupByMembers(src)

exports['qb-phone']:getGroupMembers(groupID)

exports['qb-phone']:getGroupSize(groupID)

exports['qb-phone']:GetGroupLeader(groupID)

exports['qb-phone']:DestroyGroup(groupID)

exports['qb-phone']:isGroupLeader(src, groupID)

--------------------------------------------------

exports['qb-phone']:setJobStatus(groupID, status, stages)

exports['qb-phone']:getJobStatus(groupID)

exports['qb-phone']:resetJobStatus(groupID)

--------------------------------------------------

exports['qb-phone']:isGroupTemp(groupID)

exports['qb-phone']:CreateGroup(src, name, password)

```

# Notifications (Client side)

```

exports['qb-phone']:PhoneNotification(title, text, icon, color, timeout, accept, deny)

```

# Twitter (Server side)

```

local function escape_str(s)
	return s
end

local TweetData = {
    firstName = PhoneData.PlayerData.charinfo.firstname,
    lastName = PhoneData.PlayerData.charinfo.lastname,
    citizenid = PhoneData.PlayerData.citizenid,
    message = escape_str(data.Message):gsub("[%<>\"()\'$]",""),
    time = data.Date,
    tweetId = "TWEET-"..math.random(11111111, 99999999),
    type = data.type,
    url = URL
}

exports['qb-phone']:AddNewTweet(TweetData)

```
