var ContactSearchActive = false;
var CurrentFooterTab = "contacts";
var CallData = {};
var ClearNumberTimer = null;
var keyPadHTML;

$( "input[type=text], textarea, input[type=number]" ).focusin(function(e) {
    e.preventDefault();
    $.post('https://qb-phone/DissalowMoving');
});

$( "input[type=text], textarea, input[type=number]" ).focusout(function(e) {
    e.preventDefault();
    $.post('https://qb-phone/AllowMoving');
});

$(document).ready(function(){
    $("#phone-recent-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".phone-recent-calls .phone-recent-call").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

QB.Phone.Functions.SetupRecentCalls = function(recentcalls) { // THIS
    $(".phone-recent-calls").html("");

    recentcalls = recentcalls.reverse();

    if (recentcalls){
        $.each(recentcalls, function(i, recentCall){
            var TypeIcon = 'fas fa-phone';
            var IconStyle = "color: #e74c3c;";
            if (recentCall.type === "outgoing") {
                TypeIcon = 'fas fa-phone';
                var IconStyle = "color: #2ecc71;";
            }
            if (!recentCall.anonymous) {
                var elem = '<div class="phone-recent-call" data-recentid="'+i+'"><div class="phone-recent-call-image"><i style="color: rgb(44, 70, 95); font-size:2.4vh; margin-top:15%;" class="fas fa-user"></i>'+'</div> <div class="phone-recent-call-name">'+recentCall.name+'</div> <div class="phone-recent-call-number">'+formatPhoneNumber(recentCall.number)+'</div> <div class="phone-recent-call-type"><i class="'+TypeIcon+'" style="'+IconStyle+'"></i></div> <div class="phone-recent-call-time">'+recentCall.time+'</div> <div class="phone-recent-call-action-buttons"> <i class="fas fa-phone" id="phone-recent-start-call" data-toggle="tooltip" title="Call"></i> <i class="fas fa-comment" id="phone-recent-chat" data-toggle="tooltip" title="Message"></i> <i class="fas fa-clipboard" id="phone-recent-copy-contact" data-toggle="tooltip" title="Copy"></i>  </div></div>'

            }

            $("#phone-header-text").hide();
            $("#header-frown-icon").hide();
            $(".phone-recent-calls").append(elem);
            $("[data-recentid='"+i+"']").data('recentData', recentCall);

        });
    } else {
        $("#phone-header-text").show();
        $("#header-frown-icon").show();
    }
}

$(document).on('click', '#phone-recent-chat', function(e){
    var RecentId = $(this).parent().parent().data('recentid');
    var RecentData = $("[data-recentid='"+RecentId+"']").data('recentData');

    if (RecentData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
        $.post('https://qb-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
            QB.Phone.Functions.LoadWhatsappChats(chats);
        });

        $('.phone-application-container').animate({
            top: -160+"%"
        });
        QB.Phone.Functions.HeaderTextColor("white", 400);
        setTimeout(function(){
            $('.phone-application-container').animate({
                top: 0+"%"
            });

            QB.Phone.Functions.ToggleApp("phone", "none");
            QB.Phone.Functions.ToggleApp("whatsapp", "block");
            QB.Phone.Data.currentApplication = "whatsapp";

            $.post('https://qb-phone/GetWhatsappChat', JSON.stringify({phone: RecentData.number}), function(chat){
                QB.Phone.Functions.SetupChatMessages(chat, {
                    name: RecentData.name,
                    number: RecentData.number
                });
            });

            $("#whatsapp-contact-search").fadeOut(150);
            $("#phone-contact-search").hide();
            $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 150);
            $(".whatsapp-openedchat").css({"display":"block"});
            $(".whatsapp-openedchat").css({left: 0+"vh"});
            $(".whatsapp-chats").animate({left: 30+"vh"},100, function(){
                $(".whatsapp-chats").css({"display":"none"});
            });
        }, 400)
    } else {
        QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You can't whatsapp yourself..", "default", 3500);
    }
});

$(document).on('click', '#phone-recent-copy-contact', function(e){
    e.preventDefault();
    ClearInputNew()

    var RecentId = $(this).parent().parent().data('recentid');
    var RecentData = $("[data-recentid='"+RecentId+"']").data('recentData');
    var PhoneNumber = RecentData.number
    copyToClipboard(PhoneNumber)
    QB.Phone.Notifications.Add("fas fa-phone", "Contacts", "Phone Number Copied!");
});

$(document).on('click', '#phone-recent-start-call', function(e){
    e.preventDefault();

    var RecentId = $(this).parent().parent().data('recentid');
    var RecentData = $("[data-recentid='"+RecentId+"']").data('recentData');

    cData = {
        number: RecentData.number,
        name: RecentData.name
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
});

$(document).on('click', "#phone-recent-call-number", function(e){
    e.preventDefault();
    ClearInputNew()
    $('#phone-call-person-menu').fadeIn(350);
});

$(document).on('click', "#phone-number-call-free-btn", function(e){
    e.preventDefault();
    var InputNum = $(".phone-number-call-free").val();
    var regExp = /[a-zA-Z]/g;
    if (InputNum != "" && !regExp.test(InputNum)){
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
                            $('#phone-call-person-menu').fadeOut(350);
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

});

$(document).ready(function(){
    $("#phone-contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".phone-contact-list .phone-contact").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

QB.Phone.Functions.LoadContacts = function(myContacts) { // THIS
    var ContactsObject = $(".phone-contact-list");
    $(ContactsObject).html("");

    $(".phone-contacts").hide();
    $(".phone-recent").hide();
    $(".phone-keypad").hide();

    $(".phone-recent").show();
    $(".phone-contacts").show();

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            contact.name = DOMPurify.sanitize(contact.name , {
                ALLOWED_TAGS: [],
                ALLOWED_ATTR: []
            });
            if (contact.name == '') contact.name = 'Hmm, I shouldn\'t be able to do this...'
            var ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-firstletter" style="background-color: whitesmoke;">'+'<i style="color: rgb(44, 70, 95); font-size:2.4vh; margin-top:15%;" class="fas fa-user"></i>'+'</div><div class="phone-contact-name">'+contact.name+'</div><div class="phone-contact-number">'+formatPhoneNumber(contact.number)+'</div><div class="phone-contact-action-buttons"> <i class="fas fa-user-alt-slash" id="delete-contact" data-toggle="tooltip" title="Yeet"></i> <i class="fas fa-phone" id="phone-start-call" data-toggle="tooltip" title="Call"></i> <i class="fas fa-comment" id="new-chat-phone" data-toggle="tooltip" title="Message"></i> <i class="fas fa-edit" id="edit-contact" data-toggle="tooltip" title="Edit"></i> <i class="fas fa-clipboard" id="copy-contact" data-toggle="tooltip" title="Copy Contact"></i>  </div></div>'
            $(ContactsObject).append(ContactElement);
            $("[data-contactid='"+i+"']").data('contactData', contact);
        });
    }
};

$(document).on('click', '#new-chat-phone', function(e){
    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

    if (ContactData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
        $.post('https://qb-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
            QB.Phone.Functions.LoadWhatsappChats(chats);
        });

        $('.phone-application-container').animate({
            top: -160+"%"
        });
        QB.Phone.Functions.HeaderTextColor("white", 400);
        setTimeout(function(){
            $('.phone-application-container').animate({
                top: 0+"%"
            });

            QB.Phone.Functions.ToggleApp("contacts", "none");
            QB.Phone.Functions.ToggleApp("whatsapp", "block");
            QB.Phone.Data.currentApplication = "whatsapp";

            $.post('https://qb-phone/GetWhatsappChat', JSON.stringify({phone: ContactData.number}), function(chat){
                QB.Phone.Functions.SetupChatMessages(chat, {
                    name: ContactData.name,
                    number: ContactData.number
                });
            });

            $("#whatsapp-contact-search").fadeOut(150);
            $("#phone-contact-search").hide();
            $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 150);
            $(".whatsapp-openedchat").css({"display":"block"});
            $(".whatsapp-openedchat").css({left: 0+"vh"});
            $(".whatsapp-chats").animate({left: 30+"vh"},100, function(){
                $(".whatsapp-chats").css({"display":"none"});
            });
        }, 400)
    } else {
        QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You can't whatsapp yourself..", "default", 3500);
    }
});

var CurrentEditContactData = {}

$(document).on('click', '#edit-contact', function(e){
    e.preventDefault();
    ClearInputNew()

    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');


    CurrentEditContactData.name = DOMPurify.sanitize(ContactData.name , {
        ALLOWED_TAGS: [],
        ALLOWED_ATTR: []
    });
    if (CurrentEditContactData.name == '') CurrentEditContactData.name = 'Hmm, I shouldn\'t be able to do this...'
    CurrentEditContactData.number = ContactData.number

    $(".phone-edit-contact-header").text(ContactData.name+" Edit")
    $(".phone-number-call-name-edit").val(ContactData.name);
    $(".phone-number-call-number-edit").val(ContactData.number);

    $('#phone-contacts-edit-ui').fadeIn(350);
});

$(document).on('click', '#copy-contact', function(e){
    e.preventDefault();
    ClearInputNew()

    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');
    var PhoneNumber = ContactData.number
    copyToClipboard(PhoneNumber)
    QB.Phone.Notifications.Add("fas fa-phone", "Contacts", "Phone Number Copied!");
});

$(document).on('click', '#phone-number-savecontact-edit', function(e){
    e.preventDefault();

    var ContactName = DOMPurify.sanitize($(".phone-number-call-name-edit").val() , {
        ALLOWED_TAGS: [],
        ALLOWED_ATTR: []
    });
    if (ContactName == '') ContactName = 'Hmm, I shouldn\'t be able to do this...'
    var ContactNumber = $(".phone-number-call-number-edit").val();
    var regExp = /[a-zA-Z]/g;

    if (ContactName != "" && ContactNumber != "" && !regExp.test(ContactNumber)) {
        ConfirmationFrame()
        $.post('https://qb-phone/EditContact', JSON.stringify({
            CurrentContactName: ContactName,
            CurrentContactNumber: ContactNumber,
            OldContactName: CurrentEditContactData.name,
            OldContactNumber: CurrentEditContactData.number,
        }), function(PhoneContacts){
            QB.Phone.Functions.LoadContacts(PhoneContacts);
        });
        QB.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
        setTimeout(function(){
            $(".phone-number-call-number-edit").val("");
            $(".phone-number-call-name-edit").val("");
            $('#phone-contacts-edit-ui').fadeOut(350);
        }, 250)
    } else {
        QB.Phone.Notifications.Add("fas fa-exclamation-circle", "Edit Contact", "Fill out all fields!");
    }
});

$(document).on('click', '#delete-contact', function(e){
    e.preventDefault();

    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

    var ContactName = ContactData.name;
    var ContactNumber = ContactData.number;

    $.post('https://qb-phone/DeleteContact', JSON.stringify({
        CurrentContactName: ContactName,
        CurrentContactNumber: ContactNumber,
    }), function(PhoneContacts){
        QB.Phone.Functions.LoadContacts(PhoneContacts);
    });
    QB.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
    setTimeout(function(){
        $(".phone-edit-contact-number").val("");
        $(".phone-edit-contact-name").val("");
    }, 250);
});

$(document).on('click', '#edit-contact-cancel', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
    setTimeout(function(){
        $(".phone-edit-contact-number").val("");
        $(".phone-edit-contact-name").val("");
    }, 250)
});


$(document).on('click', '#phone-plus-icon', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#phone-contacts-new-ui').fadeIn(350);
});

$(document).on('click', '#phone-number-savecontact', function(e){
    e.preventDefault();

    var ContactName = DOMPurify.sanitize($(".phone-number-call-name").val() , {
        ALLOWED_TAGS: [],
        ALLOWED_ATTR: []
    });
    if (ContactName == '') ContactName = 'Hmm, I shouldn\'t be able to do this...'
    var ContactNumber = $(".phone-number-call-number").val();
    var regExp = /[a-zA-Z]/g;

    if (ContactName != "" && ContactNumber != "" && !regExp.test(ContactNumber)) {
        ConfirmationFrame()
        $.post('https://qb-phone/AddNewContact', JSON.stringify({
            ContactName: ContactName,
            ContactNumber: ContactNumber,
        }), function(PhoneContacts){
            QB.Phone.Functions.LoadContacts(PhoneContacts);
        });
        QB.Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
        setTimeout(function(){
            $(".phone-number-call-name").val("");
            $(".phone-number-call-number").val("");
            $('#phone-contacts-new-ui').fadeOut(350);
        }, 250)
    } else {
        QB.Phone.Notifications.Add("fas fa-exclamation-circle", "Add Contact", "Fill out all fields!");
    }
});

$(document).on('click', '#add-contact-cancel', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
    setTimeout(function(){
        $(".phone-add-contact-number").val("");
        $(".phone-add-contact-name").val("");
    }, 250)
});

$(document).on('click', '#phone-start-call', function(e){
    e.preventDefault();
    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

    SetupCall(ContactData);
});

SetupCall = function(cData) {
    $.post('https://qb-phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: QB.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        $(".phone-call-outgoing").css({"display":"none"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        QB.Phone.Functions.HeaderTextColor("white", 400);
                        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, -160);
                            QB.Phone.Functions.ToggleApp("contacts", "none");
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
                    QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is in a call!");
                }
            } else {
                QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
            }
        } else {
            QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call your own number!");
        }
    });
}

CancelOutgoingCall = function() {
    if (QB.Phone.Data.currentApplication == "phone-call") {
        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
        setTimeout(function(){
            QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
        }, 400)
        QB.Phone.Functions.HeaderTextColor("white", 300);

        QB.Phone.Data.CallActive = false;
        QB.Phone.Data.currentApplication = null;
    }
}

$(document).on('click', '#outgoing-cancel', function(e){
    e.preventDefault();

    $.post('https://qb-phone/CancelOutgoingCall');
});

$(document).on('click', '#incoming-deny', function(e){
    e.preventDefault();
    $.post('https://qb-phone/DenyIncomingCall');
});

$(document).on('click', '#ongoing-cancel', function(e){
    e.preventDefault();

    $.post('https://qb-phone/CancelOngoingCall');
});

IncomingCallAlert = function(CallData, Canceled, AnonymousCall) {
    if (!Canceled) {
        if (!QB.Phone.Data.CallActive) {
            QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
            setTimeout(function(){
                var Label = "You have an incoming call from "+CallData.name
                if (AnonymousCall) {
                    Label = "You're being called by a anonymous person"
                }
                $(".phone-call-outgoing").css({"display":"none"});
                $(".phone-call-incoming").css({"display":"block"});
                $(".phone-call-ongoing").css({"display":"none"});
                $(".phone-call-incoming-title").html(CallData.name);
                $(".phone-call-incoming-caller").html(CallData.name);
                $(".phone-app").css({"display":"none"});
                QB.Phone.Functions.HeaderTextColor("white", 400);
                $("."+QB.Phone.Data.currentApplication+"-app").css({"display":"none"});
                $(".phone-call-app").css({"display":"none"});
                QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, -160);
            }, 400);

            QB.Phone.Data.currentApplication = "phone-call";
            QB.Phone.Data.CallActive = true;
        }
        setTimeout(function(){
            $(".call-notifications").addClass('call-notifications-shake');
            setTimeout(function(){
                $(".call-notifications").removeClass('call-notifications-shake');
            }, 1000);
        }, 400);
    } else {
        $(".call-notifications").animate({
            right: -35+"vh"
        }, 400);
        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
        setTimeout(function(){
            $("."+QB.Phone.Data.currentApplication+"-app").css({"display":"none"});
            $(".phone-call-outgoing").css({"display":"none"});
            $(".phone-call-incoming").css({"display":"none"});
            $(".phone-call-ongoing").css({"display":"none"});
            $(".call-notifications").css({"display":"block"});
        }, 400)
        QB.Phone.Functions.HeaderTextColor("white", 300);
        QB.Phone.Data.CallActive = false;
        QB.Phone.Data.currentApplication = null;
    }
}

QB.Phone.Functions.SetupCurrentCall = function(cData) {
    if (cData.InCall) {
        var CallData = cData;
        var name = null;
        if (CallData.TargetData.name != null && CallData.TargetData.name != undefined && CallData.TargetData.name != "Unknown") {
            name = CallData.TargetData.name;
        } else {
            name = CallData.TargetData.number;
        }

        $(".phone-currentcall-container").css({"display":"block"});

        if (!QB.Phone.Data.IsOpen == true) {
            QB.Phone.Animations.BottomSlideUp('.container', 150, -58);
        }

        if (CallData.CallType == "incoming") {
            $(".phone-currentcall-title").html("Incoming Call");
            $(".phone-currentcall-contact").html("From "+name);
            $("#incoming-answer").css({"display":"block"});
        } else if (CallData.CallType == "outgoing") {
            $(".phone-currentcall-title").html("Outgoing Call");
            $(".phone-currentcall-contact").html("Dialing...");
            $("#incoming-deny").css({"right":"block"});
        }
        $(".notification-time-new").html("just now");
    } else {
        $(".phone-currentcall-container").css({"display":"none"});
    }
}

$(document).on('click', '#incoming-answer', function(e){
    e.preventDefault();

    $.post('https://qb-phone/AnswerCall');
    $("#incoming-answer").css({"display":"none"});
});

QB.Phone.Functions.AnswerCall = function(CallData) {
    $(".phone-call-incoming").css({"display":"none"});
    $(".phone-call-outgoing").css({"display":"none"});
    $(".phone-call-ongoing").css({"display":"block"});
    $(".phone-call-ongoing-caller").html(CallData.TargetData.name);

    QB.Phone.Functions.Close();
}

$(document).on('click', '#box-new-cancel', function(e){
    e.preventDefault();
    ClearInputNew()
    $('.phone-menu-body').fadeOut(350);
    //$('.phone-new-box-body').fadeOut(350);
});

function ClearInputNew(){
    $(".phone-new-input-class").val("");
}