Config = Config or {}



Config.TsunamiTweets = 15 -- This is the value of max amount of tweets to go through each restart meaning that no more than these amount of tweets will be loaded between restarts
Config.DatabaseCleanup = {
    tweets = 0.5, -- This means tweets get cleared from database after 12 hours or 0.5 days
    mails = 2, -- This means mails get cleared from database after 2 days
}










-- If you have Lions Boosting System, enable this check to NOT produce any vehicle registration for vinscratched vehicles. Disable if you want to produce vehicle registration regardless
Config.Vinscratch = false
-- Item name for pings app ( Having a VPN sends an anonymous ping, else sends the players name)
Config.VPNItem = 'vpn'

-- How Long Does The Player Have To Accept The Ping - This Is In Seconds
Config.Timeout = 30

-- How Long Does The Blip Remain On The Map - This Is In Seconds
Config.BlipDuration = 30

-- Blip Settings - Find Info @ https://wiki.gtanet.work/index.php?title=Blips
Config.BlipColor = 4
Config.BlipIcon = 280
Config.BlipScale = 0.75

Config.BillingCommissions = { -- This is a percentage (0.10) == 10%
    mechanic = 0.10
}

Config.Linux = false -- True if linux
Config.TweetDuration = 8 -- How many hours to load tweets (12 will load the past 12 hours of tweets)
Config.RepeatTimeout = 4000
Config.CallRepeats = 10


-- Job = the sender of the bills Job, onDuty = if the sender must be on Duty, Comission = the commission the individual gets when someone pays the bill
Config.DebtJobs = {
    ["mechanic"] = { onDuty = true, comissionEnabled = true, comission = 0.10 },
    ["police"] = { onDuty = true, comissionEnabled = true, comission = 0.10 },
}

Config.ManagementType = "simple-banking" -- put qb-management for qb-management || put simple-banking for simple-banking implementation


Config.PhoneApplications = {
    ["details"] = {
        app = "details",
        color = "#5db9fc",
        color2 = "#008eff",
        icon = "fas fa-info-circle",
        tooltipText = "Details",
        tooltipPos = "top",
        style = "font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 1,
        Alerts = 0,
    },
    ["contacts"] = {
        app = "contacts",
        color = "#345b7a",
        color2 = "#122445",
        icon = "fas fa-phone-volume",
        tooltipText = "Contacts",
        tooltipPos = "top",
        style = "font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 2,
        Alerts = 0,
    },
    ["phone"] = {
        app = "phone",
        color = "#51da80",
        color2 = "#009436",
        icon = "fas fa-phone-volume",
        tooltipText = "Phone",
        tooltipPos = "top",
        style = "font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 3,
        Alerts = 0,
    },
    ["whatsapp"] = {
        app = "whatsapp",
        color = "#8bfc76",
        color2 = "#18d016",
        icon = "fas fa-comment",
        tooltipText = "Messages",
        tooltipPos = "top",
        style = "font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 4,
        Alerts = 0,
    },
    ["ping"] = {
        app = "ping",
        color = "#6d10f5",
        color2 = "#4b67ef",
        icon = "fas fa-map-marker-alt",
        tooltipText = "Ping",
        tooltipPos = "top",
        style = "font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 5,
        Alerts = 0,
    },
    ["mail"] = {
        app = "mail",
        color = "#009ee5",
        color2 = "#87d9e7",
        icon = "fas fa-envelope",
        tooltipText = "Mail",
        style = "font-size: 3vh";
        job = false,
        blockedjobs = {},
        slot = 6,
        Alerts = 0,
    },
    ["advert"] = {
        app = "advert",
        color = "#ffc900",
        color2 = "#f7c816",
        icon = "fas fa-bullhorn",
        tooltipText = "Advertisements",
        style = "font-size: 2vh";
        job = false,
        blockedjobs = {},
        slot = 7,
        Alerts = 0,
    },
    ["twitter"] = {
        app = "twitter",
        color = "#151515",
        color2 = "#161616",
        icon = "fab fa-twitter",
        tooltipText = "Twitter",
        tooltipPos = "top",
        style = "color: #2cabe0; font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 8,
        Alerts = 0,
    },
    ["garage"] = {
        app = "garage",
        color = "#ff8077",
        color2 = "#bb345d",
        icon = "fas fa-car",
        tooltipText = "Vehicles",
        style = "font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 9,
        Alerts = 0,
    },
    ["debt"] = {
        app = "debt",
        color = "#fdfeff",
        color2 = "#d5e6fa",
        icon = "fas fa-ad",
        tooltipText = "Debt",
        job = false,
        blockedjobs = {},
        slot = 10,
        Alerts = 0,
    },
    ["wenmo"] = {
        app = "wenmo",
        color = "#151515",
        color2 = "#161616",
        icon = "fas fa-ad",
        tooltipText = "Wenmo",
        job = false,
        blockedjobs = {},
        slot = 11,
        Alerts = 0,
    },
    ["documents"] = {
        app = "documents",
        color = "#f15ac1",
        color2 = "#aa4edd",
        icon = "fas fa-sticky-note",
        tooltipText = "Documents",
        style = "font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 12,
        Alerts = 0,
    },
    ["houses"] = {
        app = "houses",
        color = "#42a042",
        color2 = "#3f9e4a",
        icon = "fas fa-house-user",
        tooltipText = "Houses",
        style = "font-size: 3vh";
        job = false,
        blockedjobs = {},
        slot = 13,
        Alerts = 0,
    },
    ["crypto"] = {
        app = "crypto",
        color = "#000000",
        color2 = "#000000",
        icon = "fab fa-bitcoin",
        tooltipText = "Crypto",
        style = "font-size: 2.7vh";
        job = false,
        blockedjobs = {},
        slot = 14,
        Alerts = 0,
    },
    ["jobcenter"] = {
        app = "jobcenter",
        color = "#151515",
        color2 = "#161616",
        icon = "fas fa-id-badge",
        tooltipText = "Job Center",
        style = "color: #78bdfd; font-size: 2.7vh";
        job = false,
        blockedjobs = {},
        slot = 15,
        Alerts = 0,
    },
    ["employment"] = {
        app = "employment",
        color = "#151515",
        color2 = "#161616",
        icon = "fas fa-ad",
        tooltipText = "Employment",
        job = false,
        blockedjobs = {},
        slot = 16,
        Alerts = 0,
    },
    ["lsbn"] = {
        app = "lsbn",
        color = "#151515",
        color2 = "#161616",
        icon = "fas fa-ad",
        tooltipText = "LSBN",
        job = false,
        blockedjobs = {},
        slot = 17,
        Alerts = 0,
    },
    ["services"] = {
        app = "services",
        color = "#26d4ce",
        color2 = "#1e9c98",
        icon = "fas fa-briefcase",
        tooltipText = "Services",
        tooltipPos = "bottom",
        style = "font-size: 3vh";
        job = false,
        blockedjobs = {},
        slot = 18,
        Alerts = 0,
    },
    ["casino"] = {
        app = "casino",
        color = "#000100",
        color2 = "#000100",
        icon = "fas fa-gem",
        tooltipText = "Betting",
        tooltipPos = "bottom",
        style = "font-size: 2.7vh";
        job = false,
        blockedjobs = {},
        slot = 19,
        Alerts = 0,
    },
    ["calculator"] = {
        app = "calculator",
        color = "#c94001",
        color2 = "#9c3100",
        icon = "fas fa-calculator",
        tooltipText = "Calculator",
        tooltipPos = "bottom",
        style = "font-size: 2.5vh";
        job = false,
        blockedjobs = {},
        slot = 20,
        Alerts = 0,
    },
    ["gallery"] = {
        app = "gallery",
        color = "#189ec0",
        color2 = "#14819c",
        icon = "fas fa-images",
        tooltipText = "Gallery",
        tooltipPos = "bottom",
        style = "font-size: 2.7vh";
        job = false,
        blockedjobs = {},
        slot = 21,
        Alerts = 0,
    },
    ["racing"] = {
        app = "racing",
        color = "#353b48",
        color2 = "#242830",
        icon = "fas fa-flag-checkered",
        tooltipText = "Racing",
        style = "font-size: 3vh";
        job = false,
        blockedjobs = {},
        slot = 22,
        Alerts = 0,
    },
    ["bank"] = {
        app = "bank",
        color = "#9c88ff",
        color2 = "#8070d5",
        icon = "fas fa-file-contract",
        tooltipText = "Invoices",
        style = "font-size: 2.7vh";
        job = false,
        blockedjobs = {},
        slot = 23,
        Alerts = 0,
    },
    ["settings"] = {
        app = "settings",
        color = "#636e72",
        color2 = "#4c5558",
        icon = "fas fa-cog",
        tooltipText = "Settings",
        tooltipPos = "top",
        style = "padding-right: .08vh; font-size: 3.3vh";
        job = false,
        blockedjobs = {},
        slot = 24,
        Alerts = 0,
    },
    ["meos"] = {
        app = "meos",
        color = "#004682",
        color2 = "#00325c",
        icon = "fas fa-ad",
        tooltipText = "MDT",
        job = "police",
        blockedjobs = {},
        slot = 25,
        Alerts = 0,
    },
}
Config.MaxSlots = 28

Config.StoreApps = {
    ["territory"] = {
        app = "territory",
        color = "#353b48",
        icon = "fas fa-globe-europe",
        tooltipText = "Territorium",
        tooltipPos = "right",
        style = "";
        job = false,
        blockedjobs = {},
        slot = 17,
        Alerts = 0,
        password = true,
        creator = "QBCore",
        title = "Territory",
    },
}

Config.JobCenter = {
    [1] = {
        job = "unemployed",
        label = "Unemployment",
        Coords = {},
    },
    [2] = {
        job = "garbage",
        label = "Garbage",
        Coords = {-344.76, -1564.34},
    },
    [3] = {
        job = "taxi",
        label = "Taxi Driver",
        Coords = {909.11, -174.59},
    },
    [4] = {
        job = "amazon",
        label = "Amazon Driver",
        Coords = {-1071.08, -2004.0},
    },
    [5] = {
        job = "trucker",
        label = "Truck Driver",
        Coords = {925.83, -1560.23},
    },
}

Config.ServiceJobs = {
    {
        Job = "lawyer",
        HeaderBackgroundColor = "rgb(42, 137, 214)"
    },
    {
        Job = "realestate",
        HeaderBackgroundColor = "rgb(155, 15, 120)"
    },
    {
        Job = "mechanic",
        HeaderBackgroundColor = "rgb(0, 204, 102)"
    },
    {
        Job = "taxi",
        HeaderBackgroundColor = "rgb(255, 190, 27)"
    },
    {
        Job = "police",
        HeaderBackgroundColor = "rgb(0, 0, 255)"
    },
    {
        Job = "ambulance",
        HeaderBackgroundColor = "rgb(255, 0, 0)"
    }
}
