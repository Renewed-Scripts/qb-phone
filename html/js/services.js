SetupServices = function(data) {
    $(".services-list").html("");
    $.each(data, function(job, jobData) {
        $(".services-list").append(`<h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: ${jobData.HeaderBackgroundColor};">${jobData.Label} (${jobData.Players.length})</h1>`);
        $.each(jobData.Players, function(i, player) {
            $(".services-list").append(`<div class="service-list" id="player-${job}-${i}"> <div class="service-list-firstletter" style="background-color: #0d1218c0;">${(player.Name).charAt(0).toUpperCase()}</div> <div class="service-list-fullname">${player.Name}</div> <div class="service-list-call"><i class="fas fa-phone"></i></div></div>`);
            $(`#player-${job}-${i}`).data('PlayerData', player);
        });

        if (jobData.Players.length === 0) {
            $(".services-list").append(`<div class="service-list"><div class="no-services">There is no ${jobData.Label} available.</div></div>`);
        }
        $(".services-list").append("<br>");
    });
}

$(document).on('click', '.service-list-call', function(e){
    e.preventDefault();

    var PlayerData = $(this).parent().data('PlayerData');
    
    var cData = {
        number: PlayerData.Phone,
        name: PlayerData.Name
    }

    $.post('https://qb-phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: QB.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (QB.Phone.Data.AnonymousCall) {
                            QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You started a anonymous call!");
                        }
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        QB.Phone.Functions.HeaderTextColor("white", 400);
                        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".services-app").css({"display":"none"});
                            QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            QB.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        QB.Phone.Data.currentApplication = "phone-call";
                    } else {
                        QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You are already connected to a call!");
                    }
                } else {
                    QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is already in a call");
                }
            } else {
                QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
            }
        } else {
            QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call your own number!");
        }
    });
});
