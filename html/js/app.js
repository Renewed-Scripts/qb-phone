QB = {}
QB.Phone = {}
QB.Screen = {}
QB.Phone.Functions = {}
QB.Phone.Animations = {}
QB.Phone.Notifications = {}
QB.Phone.Notifications.Custom = {}
QB.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

QB.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

QB.Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

var CanOpenApp = true;
var up = false


function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && QB.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

QB.Phone.Functions.SetupApplications = function(data) {
    QB.Phone.Data.Applications = data.applications;

    var i;
    for (i = 1; i <= QB.Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, QB.Phone.Data.PlayerJob.name)

        if ((!app.job || app.job === QB.Phone.Data.PlayerJob.name) && !blockedapp) {
            $(applicationSlot).css("background-image","-webkit-gradient(linear,0% 0%,0% 100%,color-stop(0.4, "+app.color+"),color-stop(0.9, "+app.color2+")");


            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            if (app.app == "meos") {
                icon = '<img src="./img/apps/politie.png" class="police-icon">';
            } else if (app.app == "garage"){
                icon = '<img src="./img/apps/garage_img.png" class="garage-icon">';
            } else if (app.app == "advert"){
                icon = '<img src="./img/apps/Advertisements.png" class="advert-icon">';
            } else if (app.app == "calculator"){
                icon = '<img src="./img/apps/calcilator.png" class="calc-icon">';
            } else if (app.app == "employment"){
                icon = '<img src="./img/apps/employment.png" style="width: 87%;margin-top: 6%;margin-left: -2%;">';
            } else if (app.app == "debt"){
                icon = '<img src="./img/apps/debt.png">';
            } else if (app.app == "wenmo"){
                icon = '<img src="./img/apps/wenmo.png" class="calc-icon">';
            } else if (app.app == "jobcenter"){
                icon = '<img src="./img/apps/jobcenter.png" class="calc-icon">';
            } else if (app.app == "crypto"){
                icon = '<img src="./img/apps/crypto.png" style="width: 85%;margin-top: 7%;">';
            } else if (app.app == "taxi"){
                icon = '<img src="./img/apps/taxiapp.png" style="width: 85%;margin-top: 7%;">';
            } else if (app.app == "lsbn"){
                icon = '<img src="./img/apps/lsbn.png" style="width: 85%;margin-top: 7%;">';
            } else if (app.app == "contacts"){
                icon = '<img src="./img/apps/contacts.png" style="width: 85%;margin-top: 7%;">';
            }



            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

QB.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

QB.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (QB.Phone.Data.currentApplication == null) {
                QB.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                QB.Phone.Functions.ToggleApp(PressedApplication, "block");

                if (QB.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    QB.Phone.Functions.HeaderTextColor("black", 300);
                }

                QB.Phone.Data.currentApplication = PressedApplication;

                if (PressedApplication == "twitter") {
                    if (QB.Phone.Data.IsOpen) {
                        $.post('https://qb-phone/GetTweets', JSON.stringify({}), function(Tweets){
                            QB.Phone.Notifications.LoadTweets(Tweets);
                        });
                    }
                } else if (PressedApplication == "bank") {
                    QB.Phone.Functions.DoBankOpen();
                    $('.bank-app-header-button').click();
                    $.post('https://qb-phone/GetBankContacts', JSON.stringify({}), function(contacts){
                        QB.Phone.Functions.LoadContactsWithNumber(contacts);
                    });
                    $.post('https://qb-phone/GetInvoices', JSON.stringify({}), function(invoices){
                        QB.Phone.Functions.LoadBankInvoices(invoices);
                    });
                } else if (PressedApplication == "whatsapp") {
                    $.post('https://qb-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
                        QB.Phone.Functions.LoadWhatsappChats(chats);
                    });
                } else if (PressedApplication == "phone") {
                    $.post('https://qb-phone/GetMissedCalls', JSON.stringify({}), function(recent){
                        QB.Phone.Functions.SetupRecentCalls(recent);
                    });
                    $.post('https://qb-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "phone"
                    }));
                } else if (PressedApplication == "mail") {
                    $.post('https://qb-phone/GetMails', JSON.stringify({}), function(mails){
                        QB.Phone.Functions.SetupMails(mails);
                    });
                    $.post('https://qb-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                } else if (PressedApplication == "advert") {
                    $.post('https://qb-phone/LoadAdverts', JSON.stringify({}), function(Adverts){
                        QB.Phone.Functions.RefreshAdverts(Adverts);
                    })
                } else if (PressedApplication == "garage") {
                    $.post('https://qb-phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                        SetupGarageVehicles(Vehicles);
                    })
                } else if (PressedApplication == "racing") {
                    $.post('https://qb-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                } else if (PressedApplication == "houses") {
                    $.post('https://qb-phone/GetPlayerHouses', JSON.stringify({}), function(Houses){
                        SetupPlayerHouses(Houses);
                    });
                    $.post('https://qb-phone/GetPlayerKeys', JSON.stringify({}), function(Keys){
                        $(".house-app-mykeys-container").html("");
                        if (Keys.length > 0) {
                            $.each(Keys, function(i, key){
                                var elem = '<div class="mykeys-key" id="keyid-'+i+'"><span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Click to set GPS</span> </div>';
                                $(".house-app-mykeys-container").append(elem);
                                $("#keyid-"+i).data('KeyData', key);
                            });
                        }
                    });
                } else if (PressedApplication == "meos") {
                    SetupMeosHome();
                } else if (PressedApplication == "taxi") {
                    $.post('https://qb-phone/GetAvailableTaxiDrivers', JSON.stringify({}), function(data){
                        SetupTaxiDrivers(data);
                    });
                }
                else if (PressedApplication == "gallery") {
                    $.post('https://qb-phone/GetGalleryData', JSON.stringify({}), function(data){
                        setUpGalleryData(data);
                    });
                }
                else if (PressedApplication == "details") {
                    LoadPlayerMoneys();
                }
                else if (PressedApplication == "casino") {
                    LoadCasinoJob();
                }
                else if (PressedApplication == "jobcenter") {
                    LoadJobCenterApp();
                }
                else if (PressedApplication == "crypto") {
                    LoadCryptoCoins();
                }
                else if (PressedApplication == "employment") {
                    $.post('https://qb-phone/GetJobs', JSON.stringify({}), function(data){
                        LoadEmploymentApp(data)
                    });
                } else if (PressedApplication == "debt") {
                    $.post('https://qb-phone/GetPlayersDebt', JSON.stringify({}), function(data){
                        LoadDebtJob(data);
                    });
                }
                else if (PressedApplication == "gopro") {
                    $.post('https://qb-phone/SetupGoPros', JSON.stringify({}), function(Cams){
                        SetupGoPros(Cams);
                    })
                }
                else if (PressedApplication == "documents") {
                    LoadGetNotes();
                }
                else if (PressedApplication == "lsbn") {
                    LoadLSBNEvent();
                } else if (PressedApplication == "contacts") {
                    $("#phone-contact-search").show();
                    $.post('https://qb-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "contacts"
                    }));
                } else if(PressedApplication == "group-chats") {
                    $.post('https://qb-phone/GetChatRooms', JSON.stringify({}), function(ChatRooms){
                        QB.Phone.Functions.HeaderTextColor("white", 100);
                        QB.Phone.Functions.LoadChatRooms(ChatRooms)
                    })
                }
            }
        }
    } else {
        if (PressedApplication != null){
            QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", QB.Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
        }
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('https://qb-phone/SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-take-camera-button', function(event){
    event.preventDefault();
    $.post('https://qb-phone/TakePhoto', JSON.stringify({}),function(url){
        // setUpCameraApp(url)
    })
    QB.Phone.Functions.Close();
});

$(document).on('click', '.phone-silent-button', function(event){
    event.preventDefault();
    $.post('https://qb-phone/phone-silent-button', JSON.stringify({}),function(Data){
        if(Data){
            $(".silent-mode-two").css({"display":"block"});
            $(".silent-mode-one").css({"display":"none"});
        }else{
            $(".silent-mode-two").css({"display":"none"});
            $(".silent-mode-one").css({"display":"block"});
        }
    })
});

$(document).on('click', '.phone-tab-button', function(event){
    event.preventDefault();

    if (QB.Phone.Data.currentApplication === null) {
        QB.Phone.Functions.Close();
    } else {
        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        QB.Phone.Functions.HeaderTextColor("white", 300);

        if (QB.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (QB.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});

                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');

                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');

                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (QB.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("noodknop");
                $(".meos-recent-alert").css({"background-color":"#004682"});
            }, 400)
        }

        QB.Phone.Data.currentApplication = null;
    }
});

QB.Phone.Functions.Open = function(data) {
    QB.Phone.Animations.BottomSlideUp('.container', 500, -6.6);
    QB.Phone.Notifications.LoadTweets(data.Tweets);
    QB.Phone.Data.IsOpen = true;
}

QB.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

QB.Phone.Functions.Close = function() {
    if (QB.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            QB.Phone.Functions.HeaderTextColor("white", 300);

            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            QB.Phone.Data.currentApplication = null;
        }, 500)
    } else if (QB.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("noodknop");
        $(".meos-recent-alert").css({"background-color":"#004682"});
    }
    $('.publicphonebase').css('display', 'none')
    QB.Phone.Animations.BottomSlideDown('.container', 500, -70);
    $.post('https://qb-phone/Close');
    QB.Phone.Data.IsOpen = false;
}

QB.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

QB.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

QB.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

QB.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

QB.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

QB.Phone.Notifications.Custom.Add = function(icon, title, text, color, timeout, accept, deny) {
    $.post('https://qb-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (color != null || color != undefined) {
                $(".notification-icon-new").css({"color":color});
                $(".notification-title-new").css({"color":"#FFFFFF"});

                $(".notification-accept").css({"color":"#a6f1a6"});
                $(".notification-deny").css({"color":"#F28C28"});

            } else if (color == "default" || color == null || color == undefined) {
                $(".notification-icon-new").css({"color":"#FFFFFF"});
                $(".notification-title-new").css({"color":"#FFFFFF"});

                if (accept != "NONE"){ // ACCEPT COLOR
                    $(".notification-accept").css({"color":"#a6f1a6"});
                }
                if (deny != "NONE"){ // DENY COLOR
                    $(".notification-deny").css({"color":"#F28C28"});
                }

            }
            if (!QB.Phone.Data.IsOpen == true) {
                QB.Phone.Animations.BottomSlideUp('.container', 150, -55);
            }

            QB.Phone.Animations.TopSlideDown(".phone-notification-container-new", 600, 6);

            $(".notification-icon-new").html('<i class="'+icon+'"></i>');
            $(".notification-title-new").html(title);
            $(".notification-text-new").html(text);
            $(".notification-time-new").html("just now");

            if (accept != "NONE"){ // ACCEPT SYMBOL
                $(".notification-accept").html('<i class="'+accept+'"></i>');
            }
            if (deny != "NONE"){ // DENY SYMBOL
                $(".notification-deny").html('<i class="'+deny+'"></i>');
            }

            if (timeout != "NONE"){
                if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
                    clearTimeout(QB.Phone.Notifications.Timeout);
                }
                QB.Phone.Notifications.Timeout = setTimeout(function(){
                    QB.Phone.Animations.TopSlideUp(".phone-notification-container-new", 150, -8);
                    QB.Phone.Notifications.Timeout = setTimeout(function(){
                        if (!QB.Phone.Data.IsOpen == true) {
                        QB.Phone.Animations.BottomSlideUp('.container', 450, -70);
                        }
                    }, 500)
                    QB.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

QB.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('https://qb-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (QB.Phone.Notifications.Timeout == undefined || QB.Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!QB.Phone.Data.IsOpen == true) {
                    QB.Phone.Animations.BottomSlideUp('.container', 450, -57);
                }
                    QB.Phone.Animations.TopSlideDown(".phone-notification-container", 600, 6);
                if (icon !== "politie") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                $(".notification-time").html("just now");
                if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
                    clearTimeout(QB.Phone.Notifications.Timeout);
                }
                QB.Phone.Notifications.Timeout = setTimeout(function(){
                    QB.Phone.Animations.TopSlideUp(".phone-notification-container", 600, -8);

                    QB.Phone.Notifications.Timeout = setTimeout(function(){
                    if (!QB.Phone.Data.IsOpen == true) {
                    QB.Phone.Animations.BottomSlideUp('.container', 450, -70);
                    }
                }, 500)
                    QB.Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!QB.Phone.Data.IsOpen) {
                    QB.Phone.Animations.BottomSlideUp('.container', 300, -56);
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                $(".notification-time").html("just now");
                if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
                    clearTimeout(QB.Phone.Notifications.Timeout);
                }
                QB.Phone.Notifications.Timeout = setTimeout(function(){
                    QB.Phone.Animations.TopSlideUp(".phone-notification-container", 150, -8);
                    QB.Phone.Notifications.Timeout = setTimeout(function(){
                        if (!QB.Phone.Data.IsOpen == true) {
                        QB.Phone.Animations.BottomSlideUp('.container', 450, -70);
                        }
                    }, 500)
                    QB.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

$(document).on('click', ".phone-notification-container", function() {
    QB.Phone.Animations.TopSlideUp(".phone-notification-container", 150, -8);
    QB.Phone.Notifications.Timeout = null

    if (!QB.Phone.Data.IsOpen == true) {
    QB.Phone.Animations.BottomSlideUp('.container', 450, -70);
    }
})


$(document).on('click', ".notification-accept", function() {
    $.post('https://qb-phone/AcceptNotification', JSON.stringify({})),
    QB.Phone.Animations.TopSlideUp(".phone-notification-container-new", 150, -8);
    QB.Phone.Notifications.Timeout = null

    if (!QB.Phone.Data.IsOpen == true) {
    QB.Phone.Animations.BottomSlideUp('.container', 450, -70);
    }
})

$(document).on('click', ".notification-deny", function() {
    $.post('https://qb-phone/DenyNotification', JSON.stringify({})),
    QB.Phone.Notifications.Timeout = null

    QB.Phone.Animations.TopSlideUp(".phone-notification-container-new", 150, -8);

    if (!QB.Phone.Data.IsOpen == true) {
    QB.Phone.Animations.BottomSlideUp('.container', 450, -70);
    }
})

QB.Phone.Functions.LoadPhoneData = function(data) {
    QB.Phone.Data.PlayerData = data.PlayerData;
    QB.Phone.Data.PlayerJob = data.PlayerJob;
    QB.Phone.Data.MetaData = data.PhoneData.MetaData;
    QB.Phone.Data.PhoneJobs = data.PhoneJobs
    QB.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    QB.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    QB.Phone.Functions.SetupApplications(data);

    $("#player-id").html("<span>" + "# " + data.PlayerId + "</span>")
}

QB.Phone.Functions.UpdateTime = function(data) {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html("<span>" + data.InGameTime.hour + ":" + data.InGameTime.minute + "</span>");
}

var NotificationTimeout = null;

QB.Screen.Notification = function(title, content, icon, timeout, color) {
    $.post('https://qb-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (color != null && color != undefined) {
                $(".screen-notifications-container").css({"background-color":color});
            }
            $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
            $(".screen-notification-title").text(title);
            $(".screen-notification-content").text(content);
            $(".screen-notifications-container").css({'display':'block'}).animate({
                right: 5+"vh",
            }, 200);

            if (NotificationTimeout != null) {
                clearTimeout(NotificationTimeout);
            }

            NotificationTimeout = setTimeout(function(){
                $(".screen-notifications-container").animate({
                    right: -35+"vh",
                }, 200, function(){
                    $(".screen-notifications-container").css({'display':'none'});
                });
                NotificationTimeout = null;
            }, timeout);
        }
    });
}

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
        if (dropdownOpen){
            $('.phone-dropdown-menu').fadeOut(350);
            dropdownOpen = false
        }else if (up){
            $('#popup').fadeOut('slow');
            $('.popupclass').fadeOut('slow');
            $('.popupclass').html("");
            up = false
        } else {
            QB.Phone.Functions.Close();
            break;
        }
    }
});

QB.Screen.popUp = function(source){
    if(!up){
        $('#popup').fadeIn('slow');
        $('.popupclass').fadeIn('slow');
        $('<img class="popupclass2" src='+source+'>').appendTo('.popupclass')
        up = true
    }
}

QB.Screen.popDown = function(){
    if(up){
        $('#popup').fadeOut('slow');
        $('.popupclass').fadeOut('slow');
        $('.popupclass').html("");
        up = false
    }
}

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                QB.Phone.Functions.Open(event.data);
                QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
                QB.Phone.Functions.SetupCurrentCall(event.data.CallData);
                QB.Phone.Data.IsOpen = true;
                QB.Phone.Data.PlayerData = event.data.PlayerData;
                break;
            case "LoadPhoneData":
                QB.Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                QB.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                QB.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
                break;
            case "PhoneNotification":
                QB.Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout, event.data.PhoneNotify.accept, event.data.PhoneNotify.deny);
                break;
            case "PhoneNotificationCustom":
                QB.Phone.Notifications.Custom.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout, event.data.PhoneNotify.accept, event.data.PhoneNotify.deny);
                break;
            case "RefreshAppAlerts":
                QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html("&#36; "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (QB.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        QB.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        QB.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "RefreshWhatsappAlerts":
                QB.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('https://qb-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('https://qb-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "refreshInvoice":
                    QB.Phone.Functions.LoadBankInvoices(event.data.invoices);
                break;
            case "SetupHomeCall":
                QB.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                QB.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);
                if (!QB.Phone.Data.IsOpen) {
                    QB.Phone.Animations.BottomSlideUp('.container', 150, -58);
                    $(".call-notifications-title").html(event.data.Name);
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                    $("#incoming-answer").css({"display":"none"});
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                    $(".call-notifications-title").html(event.data.Name);
                }
                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html(event.data.Name);
                $(".phone-currentcall-contact").html(timeString);
                $(".notification-time-new").html("just now");

                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    QB.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                QB.Phone.Functions.HeaderTextColor("white", 300);

                QB.Phone.Data.CallActive = false;
                QB.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                QB.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                QB.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (QB.Phone.Data.currentApplication == "advert") {
                    QB.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "UpdateTweets":
                if (QB.Phone.Data.currentApplication == "twitter") {
                    QB.Phone.Notifications.LoadTweets(event.data.Tweets);
                }
                break;

            case "refreshDebt":
                if (QB.Phone.Data.currentApplication == "debt") {
                    LoadDebtJob(event.data.debt);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                QB.Phone.Data.PlayerJob = event.data.JobData;
                QB.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateCrypto":
                if (QB.Phone.Data.currentApplication == "crypto") {
                    QB.Phone.Data.PlayerData = event.data.PlayerData;
                    LoadCryptoCoins()
                }
                break;
            case "UpdateGarages":
                $.post('https://qb-phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                    SetupGarageVehicles(Vehicles);
                })
                break;
            case "UpdateRacingApp":
                $.post('https://qb-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
            case "RefreshChatRooms":
                let rooms = $.map(event.data.Rooms, (r) => {
                    return r
                })
                QB.Phone.Functions.LoadChatRooms(rooms)
                break;
            case "RefreshGroupChat":
                QB.Phone.Functions.RefreshGroupChat(event.data.messageData)
                break;
        }
    })
});