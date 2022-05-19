var ContactSearchActive = false;
var CurrentFooterTab = "contacts";
var CallData = {};
var ClearNumberTimer = null;
var SelectedSuggestion = null;
var AmountOfSuggestions = 0;
var keyPadHTML;

$(document).on('click', '.phone-app-footer-button', function(e){
    e.preventDefault();

    var PressedFooterTab = $(this).data('phonefootertab');

    if (PressedFooterTab !== CurrentFooterTab) {
        var PreviousTab = $(this).parent().find('[data-phonefootertab="'+CurrentFooterTab+'"');

        $('.phone-app-footer').find('[data-phonefootertab="'+CurrentFooterTab+'"').removeClass('phone-selected-footer-tab');
        $(this).addClass('phone-selected-footer-tab');

        $(".phone-"+CurrentFooterTab).hide();
        $(".phone-"+PressedFooterTab).show();

        if (PressedFooterTab == "recent") {
            $.post('https://5life-phone/ClearRecentAlerts');
        } else if (PressedFooterTab == "suggestedcontacts") {
            $.post('https://5life-phone/ClearRecentAlerts');
        }

        CurrentFooterTab = PressedFooterTab;
    }
});

$(document).on("click", "#phone-search-icon", function(e){
    e.preventDefault();

    if (!ContactSearchActive) {
        $("#phone-plus-icon").animate({
            opacity: "0.0",
            "display": "none"
        }, 150, function(){
            $("#contact-search").css({"display":"block"}).animate({
                opacity: "1.0",
            }, 150);
        });
    } else {
        $("#contact-search").animate({
            opacity: "0.0"
        }, 150, function(){
            $("#contact-search").css({"display":"none"});
            $("#phone-plus-icon").animate({
                opacity: "1.0",
                display: "block",
            }, 150);
        });
    }

    ContactSearchActive = !ContactSearchActive;
});

QB.Phone.Functions.SetupRecentCalls = function(recentcalls) {
    $(".phone-recent-calls").html("");

    recentcalls = recentcalls.reverse();

    $.each(recentcalls, function(i, recentCall){
        var FirstLetter = (recentCall.name).charAt(0);
        var TypeIcon = 'fas fa-phone';
        var IconStyle = "color: #e74c3c;";
        if (recentCall.type === "outgoing") {
            TypeIcon = 'fas fa-phone';
            var IconStyle = "color: #2ecc71; font-size: 1.4vh;";
        }
        if (!recentCall.anonymous) {
            var elem = '<div class="phone-recent-call" id="recent-'+i+'"><div class="phone-recent-call-image">'+FirstLetter+'</div> <div class="phone-recent-call-name">'+recentCall.name+'</div> <div class="phone-recent-call-type"><i class="'+TypeIcon+'" style="'+IconStyle+'"></i></div> <div class="phone-recent-call-time">'+recentCall.time+'</div> </div>'

        }

        $(".phone-recent-calls").append(elem);
        $("#recent-"+i).data('recentData', recentCall);
    });
}
 
$(document).on('click', '.phone-recent-call', function(e){
    e.preventDefault();

    var RecendId = $(this).attr('id');
    var RecentData = $("#"+RecendId).data('recentData');

    cData = {
        number: RecentData.number,
        name: RecentData.name
    }

    $.post('https://5life-phone/CallContact', JSON.stringify({
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

$(document).on('click', ".phone-recent-call-number", function(e){
    e.preventDefault();
    ClearInputNew()
    $('.phone-new-box-body').fadeIn(350);
});

$(document).on('click', "#phone-number-call-free-btn", function(e){
    e.preventDefault();
    var InputNum = $("#phone-number-call-free").val();

    if (InputNum != ""){
        cData = {
            number: InputNum,
            name: InputNum,
        }

        $.post('https://5life-phone/CallContact', JSON.stringify({
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

});

$(document).on('click', ".phone-keypad-key-call", function(e){
    e.preventDefault();

    var InputNum = keyPadHTML;

    cData = {
        number: InputNum,
        name: InputNum,
    }

    $.post('https://5life-phone/CallContact', JSON.stringify({
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

QB.Phone.Functions.LoadContacts = function(myContacts) {
    var ContactsObject = $(".phone-contact-list");
    $(ContactsObject).html("");

    $(".phone-contacts").hide();
    $(".phone-recent").hide();
    $(".phone-keypad").hide();

    $(".phone-"+CurrentFooterTab).show();

    $("#contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".phone-contact-list .phone-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            contact.name = DOMPurify.sanitize(contact.name , {
                ALLOWED_TAGS: [],
                ALLOWED_ATTR: []
            });
            if (contact.name == '') contact.name = 'Hmm, I shouldn\'t be able to do this...'
            var ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-firstletter" style="background-color: whitesmoke;">'+'<i style="color: rgb(44, 70, 95); font-size:2.4vh; margin-top:15%;" class="fas fa-user"></i>'+'</div><div class="phone-contact-name">'+contact.name+'</div><div class="phone-contact-action-buttons"> <i class="fas fa-user-alt-slash" id="block-contact"></i> <i class="fas fa-phone" id="phone-start-call"></i> <i class="fas fa-comment" id="new-chat-phone" style="font-size: 2.5vh;"></i> <i class="fas fa-clipboard" id="edit-contact"></i> <i class="fas fa-trash" id="delete-contact"></i> </div></div>'
            $(ContactsObject).append(ContactElement);
            $("[data-contactid='"+i+"']").data('contactData', contact);
        });
    }
};

$(document).on('click', '#new-chat-phone', function(e){
    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

    if (ContactData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
        $.post('https://5life-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
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

            $.post('https://5life-phone/GetWhatsappChat', JSON.stringify({phone: ContactData.number}), function(chat){
                QB.Phone.Functions.SetupChatMessages(chat, {
                    name: ContactData.name,
                    number: ContactData.number
                });
            });

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
    if (ContactData.iban != null && ContactData.iban != undefined) {
        $(".phone-edit-contact-iban").val(ContactData.iban);
        CurrentEditContactData.iban = ContactData.iban
    } else {
        $(".phone-edit-contact-iban").val("");
        CurrentEditContactData.iban = "";
    }

    $('#phone-contacts-edit-ui').fadeIn(350);
});

$(document).on('click', '#phone-number-savecontact-edit', function(e){
    e.preventDefault();

    var ContactName = DOMPurify.sanitize($(".phone-number-call-name-edit").val() , {
        ALLOWED_TAGS: [],
        ALLOWED_ATTR: []
    });
    if (ContactName == '') ContactName = 'Hmm, I shouldn\'t be able to do this...'
    var ContactNumber = $(".phone-number-call-number-edit").val();
    var ContactIban = $(".phone-edit-contact-iban").val();

    if (ContactName != "" && ContactNumber != "") {
        $.post('https://5life-phone/EditContact', JSON.stringify({
            CurrentContactName: ContactName,
            CurrentContactNumber: ContactNumber,
            CurrentContactIban: ContactIban,
            OldContactName: CurrentEditContactData.name,
            OldContactNumber: CurrentEditContactData.number,
            OldContactIban: CurrentEditContactData.iban,
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
    var ContactIban = ContactData.iban;

    $.post('https://5life-phone/DeleteContact', JSON.stringify({
        CurrentContactName: ContactName,
        CurrentContactNumber: ContactNumber,
        CurrentContactIban: ContactIban,
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

$(document).on('click', '.phone-keypad-key', function(e){
    e.preventDefault();
    var PressedButton = $(this).data('keypadvalue');
    if (!isNaN(PressedButton)) {
        keyPadHTML = $("#phone-keypad-input").text();
        $("#phone-keypad-input").text(keyPadHTML + PressedButton)
        keyPadHTML = $("#phone-keypad-input").text();
    } else if (PressedButton == "#") {
        keyPadHTML = $("#phone-keypad-input").text();
        $("#phone-keypad-input").text(keyPadHTML + PressedButton)
        keyPadHTML = $("#phone-keypad-input").text();
    } else if (PressedButton == "*") {
        if (ClearNumberTimer == null) {
            $("#phone-keypad-input").text("Cleared")
            ClearNumberTimer = setTimeout(function(){
                $("#phone-keypad-input").text("");
                keyPadHTML = $("#phone-keypad-input").text();
                ClearNumberTimer = null;
            }, 750);
        }
    }
})

var OpenedContact = null;

$(document).on('click', '.phone-contact-actions', function(e){
    e.preventDefault();

    var FocussedContact = $(this).parent();
    var ContactId = $(FocussedContact).data('contactid');

    if (OpenedContact === null) {
        $(FocussedContact).animate({
            "height":"12vh"
        }, 150, function(){
            $(FocussedContact).find('.phone-contact-action-buttons').fadeIn(100);
        });
        OpenedContact = ContactId;
    } else if (OpenedContact == ContactId) {
        $(FocussedContact).find('.phone-contact-action-buttons').fadeOut(100, function(){
            $(FocussedContact).animate({
                "height":"4.5vh"
            }, 150);
        });
        OpenedContact = null;
    } else if (OpenedContact != ContactId) {
        var PreviousContact = $(".phone-contact-list").find('[data-contactid="'+OpenedContact+'"]');
        $(PreviousContact).find('.phone-contact-action-buttons').fadeOut(100, function(){
            $(PreviousContact).animate({
                "height":"4.5vh"
            }, 150);
            OpenedContact = ContactId;
        });
        $(FocussedContact).animate({
            "height":"12vh"
        }, 150, function(){
            $(FocussedContact).find('.phone-contact-action-buttons').fadeIn(100);
        });
    }
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
    var ContactIban = $(".phone-add-contact-iban").val();

    if (ContactName != "" && ContactNumber != "") {
        $.post('https://5life-phone/AddNewContact', JSON.stringify({
            ContactName: ContactName,
            ContactNumber: ContactNumber,
            ContactIban: ContactIban,
        }), function(PhoneContacts){
            QB.Phone.Functions.LoadContacts(PhoneContacts);
        });
        QB.Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
        setTimeout(function(){
            $(".phone-number-call-name").val("");
            $(".phone-number-call-number").val("");
            $('#phone-contacts-new-ui').fadeOut(350);
        }, 250)

        if (SelectedSuggestion !== null) {
            $.post('https://5life-phone/RemoveSuggestion', JSON.stringify({
                data: $(SelectedSuggestion).data('SuggestionData')
            }));
            $(SelectedSuggestion).remove();
            SelectedSuggestion = null;
            var amount = parseInt(AmountOfSuggestions);
            if ((amount - 1) === 0) {
                amount = 0
            }
            $(".amount-of-suggested-contacts").html(amount + " contacts");
        }
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
    var retval = false;
    $.post('https://5life-phone/CallContact', JSON.stringify({
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

    $.post('https://5life-phone/CancelOutgoingCall');
});

$(document).on('click', '#incoming-deny', function(e){
    e.preventDefault();
    $.post('https://5life-phone/DenyIncomingCall');
});

$(document).on('click', '#ongoing-cancel', function(e){
    e.preventDefault();

    $.post('https://5life-phone/CancelOngoingCall');
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
        CallData = cData;
        $(".phone-currentcall-container").css({"display":"block"});

        if (!QB.Phone.Data.IsOpen == true) {
            QB.Phone.Animations.BottomSlideUp('.container', 150, -58);
        }
        if (cData.CallType == "incoming") {
            $(".phone-currentcall-title").html(cData.TargetData.name);
            $(".phone-currentcall-contact").html("Incoming Call");
            $("#incoming-answer").css({"display":"block"});
        } else if (cData.CallType == "outgoing") {
            $(".phone-currentcall-title").html(cData.TargetData.name);
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

    $.post('https://5life-phone/AnswerCall');
    $("#incoming-answer").css({"display":"none"});
});

QB.Phone.Functions.AnswerCall = function(CallData) {
    $(".phone-call-incoming").css({"display":"none"});
    $(".phone-call-outgoing").css({"display":"none"});
    $(".phone-call-ongoing").css({"display":"block"});
    $(".phone-call-ongoing-caller").html(CallData.TargetData.name);

    QB.Phone.Functions.Close();
}

QB.Phone.Functions.SetupSuggestedContacts = function(Suggested) {
    $(".suggested-contacts").html("");
    AmountOfSuggestions = Suggested.length;
    if (AmountOfSuggestions > 0) {
        $(".amount-of-suggested-contacts").html(AmountOfSuggestions + " contacts");
        Suggested = Suggested.reverse();
        $.each(Suggested, function(index, suggest){
            var elem = '<div class="suggested-contact" id="suggest-'+index+'"> <i class="fas fa-exclamation-circle"></i> <span class="suggested-name">'+suggest.name[0]+' '+suggest.name[1]+' &middot; <span class="suggested-number">'+suggest.number+'</span></span> </div>';
            $(".suggested-contacts").append(elem);
            $("#suggest-"+index).data('SuggestionData', suggest);
        });
    } else {
        $(".amount-of-suggested-contacts").html("0 contacts");
    }
}

$(document).on('click', '.suggested-contact', function(e){
    e.preventDefault();

    var SuggestionData = $(this).data('SuggestionData');
    SelectedSuggestion = this;

    QB.Phone.Animations.TopSlideDown(".phone-add-contact", 200, 25);

    $(".phone-add-contact-name").val(SuggestionData.name[0] + " " + SuggestionData.name[1]);
    $(".phone-add-contact-number").val(SuggestionData.number);
    $(".phone-add-contact-iban").val(SuggestionData.bank);
});

$(document).on('click', '#box-new-cancel', function(e){
    e.preventDefault();
    ClearInputNew()
    $('.phone-new-box-body').fadeOut(350);
});

function ClearInputNew(){
    $(".phone-new-input-class").val("");
}