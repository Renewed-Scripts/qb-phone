SetupYellowPages = function(data) {
    $(".yellowpages-list").html("");
        $(".yellowpages-list").append(`<img src="img/joblogos/police.png" class="yellowpages-job-img"><h1>Police</h1><a class="waves-effect waves-light btn call-btn" id="police">Call</a>`);
        $(".yellowpages-list").append('<br><br><img src="img/joblogos/hospital.png" class="yellowpages-job-img"><h1>Hospital</h1><a class="waves-effect waves-light btn call-btn" id="ambulance">Call</a>');
        $(".yellowpages-list").append('<br><br><img src="img/joblogos/mechanic.png" class="yellowpages-job-img"><h1>Mechanic</h1><a class="waves-effect waves-light btn call-btn" id="mechanic">Call</a>');
        $(".yellowpages-list").append('<br><br><img src="img/joblogos/realestate.png" class="yellowpages-job-img"><h1>Real estate</h1><a class="waves-effect waves-light btn call-btn" id="realestate">Call</a>');
        $(".yellowpages-list").append('<br><br>')
}

$("body").on("click", ".call-btn", function(e) {
    e.preventDefault()

    var job = $(this).attr("id")

    if (job !== undefined) {
        $.post('https://qb-phone/callJob', JSON.stringify({
            job: job,
            Anonymous: QB.Phone.Data.AnonymousCall
        }), function(status) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (QB.Phone.Data.AnonymousCall) {
                            QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You started an anonymous call");
                        }
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(status.data.name);
                        QB.Phone.Functions.HeaderTextColor("white", 400);
                        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".yellowpages-app").css({"display":"none"});
                            QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            QB.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);

                        CallData.name = status.data.name;
                        CallData.number = status.data.number;
                    
                        QB.Phone.Data.currentApplication = "phone-call";
                    } else {
                        QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You're already in a call!");
                    }
                } else {
                    QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is busy!");
                }
            } else {
                QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
            }
        })
    }
});