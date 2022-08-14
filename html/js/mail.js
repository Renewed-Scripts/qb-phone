var OpenedMail = null;

$(document).ready(function(){
    $("#advert-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".advert").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).ready(function(){
    $("#mail-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".mail").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '.mail', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 30+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: 0+"vh"
    }, 300);

    var MailData = $("#"+$(this).attr('id')).data('MailData');
    QB.Phone.Functions.SetupMail(MailData);

    OpenedMail = $(this).attr('id');
});

$(document).on('click', '.mail-back', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
    OpenedMail = null;
});

$(document).on('click', '#accept-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('https://qb-phone/AcceptMailButton', JSON.stringify({
        buttonEvent: MailData.button.buttonEvent,
        buttonData: MailData.button.buttonData,
        mailId: MailData.mailid,
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

$(document).on('click', '#remove-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('https://qb-phone/RemoveMail', JSON.stringify({
        mailId: MailData.mailid
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

QB.Phone.Functions.SetupMails = function(Mails) {
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
    var MessageTime = Hourssssss + ":" + Minutessss;

    $("#mail-header-mail").html(QB.Phone.Data.PlayerData.charinfo.firstname+"."+QB.Phone.Data.PlayerData.charinfo.lastname+"@brazzers.cum");
    if (Mails !== null && Mails !== undefined) {
        if (Mails.length > 0) {
            $(".mail-list").html("");
            $.each(Mails, function(i, mail){
                var date = new Date(mail.date);
                var DateString = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
                var element = '<div class="mail" id="mail-'+mail.mailid+'"><span class="mail-sender" style="font-weight: bold;">'+mail.sender+'</span> <div class="mail-text"><p>'+mail.message+'</p></div> <div class="mail-time">'+DateString+'</div></div>';

                $(".mail-list").append(element);
                $("#mail-"+mail.mailid).data('MailData', mail);
            });
        } else {
            $(".mail-list").html('<p class="nomails">Nothing Here! <i class="fas fa-frown" id="mail-frown"></i></p>');
        }

    }
}

var MonthFormatting = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

QB.Phone.Functions.SetupMail = function(MailData) {
    var date = new Date(MailData.date);
    var DateString = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
    $(".mail-subject").html("<p><span style='font-weight: bold;'>"+MailData.sender+"</span><br>"+MailData.subject+"</p>");
    $(".mail-date").html("<p>"+DateString+"</p>");
    $(".mail-content").html("<p>"+MailData.message+"</p>");

    var AcceptElem = '<div class="opened-mail-footer-item" id="accept-mail"><i class="fas fa-check-circle mail-icon"></i></div>';
    var RemoveElem = '<div class="opened-mail-footer-item" id="remove-mail"><i class="fas fa-trash-alt mail-icon"></i></div>';

    $(".opened-mail-footer").html("");

    if (MailData.button !== undefined && MailData.button !== null) {
        $(".opened-mail-footer").append(AcceptElem);
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"50%"});
    } else {
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"100%"});
    }
}

// Advert JS

// Functions

function ConfirmationFrame() {
    $('.spinner-input-frame').css("display", "flex");
    setTimeout(function () {
        $('.spinner-input-frame').css("display", "none");
        $('.checkmark-input-frame').css("display", "flex");
        setTimeout(function () {
            $('.checkmark-input-frame').css("display", "none");
        }, 2000)
    }, 1000)
}

function formatPhoneNumber(phoneNumberString) {
    var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
    var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
    if (match) {
      return '(' + match[1] + ') ' + match[2] + '-' + match[3];
    }
    return null;
}

QB.Phone.Functions.RefreshAdverts = function(Adverts) {
    Adverts = Adverts.reverse();
    if (Adverts.length > 0 || Adverts.length == undefined) {
        $(".advert-list").html("");
        $.each(Adverts, function(_, advert){
            if (advert.url) {
                if (advert.number === QB.Phone.Data.PlayerData.charinfo.phone){
                    var element = '<div class="advert" id="'+ advert.number +'">'+
                    '<div class="advert-message">' + advert.message + '</span></div>'+
                    '<div class="advert-contact-info">'+ advert.name + ' ┃ ' + formatPhoneNumber(advert.number) + '</span></div>'+
                    '<div class="advert-image-attached">Images Attached: 1<p><u>Hide (click image to copy URL)</u></p></div>'+
                    '<div class="advert-flag"><i class="fas fa-flag"></i></div>'+
                    '<div class="advert-trash"><i class="fas fa-trash"></i></div>'+
                    '<img class="image" src= ' + advert.url + ' style = " display: none; border-radius:4px; width: 70%; position:relative; z-index: 1; left:25px; margin:.6rem .5rem .6rem 1rem;height: auto; bottom: 20px;">' +
                        '<div class="advert-block">' +
                            '<div class="advert-eye"><i class="fas fa-eye"></i></div>'+
                            '<div class="advert-image-text">Click to View</div>'+
                            '<div class="advert-image-text-other">Only revel images from those you<p>know are not dick heads</p></div>'+
                        '</div>'+
                    '</div>';
                }else{
                    var element = '<div class="advert" id="'+ advert.number +'">'+
                    '<div class="advert-message">' + advert.message + '</span></div>'+
                    '<div class="advert-contact-info">'+ advert.name + ' ┃ ' + formatPhoneNumber(advert.number) + '</span></div>'+
                    '<div class="advert-image-attached">Images Attached: 1<p><u>Hide (click image to copy URL)</u></p></div>'+
                    '<div class="advert-flag" id="adv-delete"><i class="fas fa-flag"></i></div>'+
                    '<img class="image" src= ' + advert.url + ' style = " display: none; border-radius:4px; width: 70%; position:relative; z-index: 1; left:25px; margin:.6rem .5rem .6rem 1rem;height: auto; bottom: 20px;">' +
                        '<div class="advert-block">' +
                            '<div class="advert-eye"><i class="fas fa-eye"></i></div>'+
                            '<div class="advert-image-text">Click to View</div>'+
                            '<div class="advert-image-text-other">Only revel images from those you<p>know are not dick heads</p></div>'+
                        '</div>'+
                    '</div>';
                }
            } else {
                if (advert.number === QB.Phone.Data.PlayerData.charinfo.phone){
                    var element = '<div class="advert" id="'+ advert.number +'">'+
                        '<div class="advert-message">' + advert.message + '</span></div>'+
                        '<div class="advert-contact-info" style = "padding-bottom: 2.5vh;">'+ advert.name + ' ┃ ' + formatPhoneNumber(advert.number) + '</span></div>'+
                        '<div class="advert-flag"><i class="fas fa-flag"></i></div>'+
                        '<div class="advert-trash"><i class="fas fa-trash"></i></div>'+
                    '</div>';
                }else{
                    var element = '<div class="advert" id="'+ advert.number +'">'+
                    '<div class="advert-message">' + advert.message + '</span></div>'+
                    '<div class="advert-contact-info" style = "padding-bottom: 2.5vh;">'+ advert.name + ' ┃ ' + formatPhoneNumber(advert.number) + '</span></div>'+
                    '<div class="advert-flag"><i class="fas fa-flag"></i></div>'+
                '</div>';
                }
            }

            $(".advert-list").append(element);
        });
    } else {
        $(".advert-list").html('<p class="noadverts">Nothing Here! <i class="fas fa-frown" id="advert-frown"></i></p>');
    }
}

// Clicks

$(document).on('click', '.create-advert', function(e){
    e.preventDefault();

    ClearInputNew()
    $('#advert-box-textt').fadeIn(350);
});

$(document).on('click', '#advert-sendmessage-chat', function(e){
    e.preventDefault();

    var Advert = $(".advert-box-textt-input").val();
    let picture = $('.advert-box-image-input').val();

    if (Advert !== "" || picture != "") {
        if (picture != ""){
            setTimeout(function(){
                ConfirmationFrame()
            }, 150);
        }
        $.post('https://qb-phone/PostAdvert', JSON.stringify({
            message: Advert,
            url: picture
        }));
        ClearInputNew()
        $('#advert-box-textt').fadeOut(350);
    } else {
        QB.Phone.Notifications.Add("fas fa-ad", "Advertisement", "You can\'t post an empty ad!", "#ff8f1a", 2000);
    }
});

$(document).on('click','.advert-contact-info',function(e){
    e.preventDefault();
    var Number = $(this).parent().attr('id');
    if (Number != undefined){
        var InputNum = Number;

        if (InputNum != ""){
            cData = {
                number: InputNum,
                name: InputNum,
            }
            $.post('https://qb-phone/CallContact', JSON.stringify({
                ContactData: cData,
                Anonymous: QB.Phone.Data.AnonymousCall,
            }), function(status){
                if (cData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
                    if (status.IsOnline) {
                        if (status.CanCall) {
                            if (!status.InCall) {
                                $('.phone-new-box-body').fadeOut(350);
                                ClearInputNew()
                                $(".phone-call-outgoing").css({"display":"none"});
                                $(".phone-call-incoming").css({"display":"none"});
                                $(".phone-call-ongoing").css({"display":"none"});
                                $(".phone-call-outgoing-caller").html(cData.name);
                                QB.Phone.Functions.HeaderTextColor("white", 400);
                                QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                                setTimeout(function(){
                                    $(".phone-app").css({"display":"none"});
                                    QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, -160);
                                    QB.Phone.Functions.ToggleApp("phone-call", "block");
                                    $(".phone-currentcall-container").css({"display":"block"});
                                    $("#incoming-answer").css({"display":"none"});
                                }, 450);
        
                                CallData.name = cData.name;
                                CallData.number = cData.number;
        
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
                } else {
                    QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call yourself!");
                }
            });
        } 
    }
})

$(document).on('click', '.advert-eye', function(e){
    e.preventDefault();

    $(this).parent().parent().find(".image").css({"display":"block"});
    $(this).parent().parent().find(".advert-block").css({"display":"none"});
});

$(document).on('click', '.advert-image-attached', function(e){
    e.preventDefault();

    $(this).parent().parent().find(".image").css({"display":"none"});
    $(this).parent().parent().find(".advert-block").css({"display":"block"});
});

$(document).on('click', '.advert-flag', function(e){
    e.preventDefault();
    var Number = $(this).parent().attr('id');
    $.post('https://qb-phone/FlagAdvert', JSON.stringify({number: Number}))
});

$(document).on('click','.advert-trash',function(e){
    e.preventDefault();
    setTimeout(function(){
        ConfirmationFrame()
        QB.Phone.Notifications.Add("fas fa-ad", "Advertisement", "The ad was deleted", "#ff8f1a", 2000);
    }, 150);
    $.post('https://qb-phone/DeleteAdvert', function(){});
})