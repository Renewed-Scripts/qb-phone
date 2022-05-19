var WhatsappSearchActive = false;
var OpenedChatPicture = null;
var ExtraButtonsOpen = false;

$(document).ready(function(){
    $("#whatsapp-contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".whatsapp-chats .whatsapp-chat").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '#whatsapp-newconvo-icon', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#whatsapp-box-new-add-new').fadeIn(350);
});

$(document).on('click', '.whatsapp-chat', function(e){
    e.preventDefault();

    var ChatId = $(this).attr('id');
    var ChatData = $("#"+ChatId).data('chatdata');

    QB.Phone.Functions.SetupChatMessages(ChatData);

    $.post('https://5life-phone/ClearAlerts', JSON.stringify({
        number: ChatData.number
    }));

    $("#whatsapp-contact-search").fadeOut(150);

    $(".whatsapp-openedchat").css({"display":"block"});
    $(".whatsapp-openedchat").animate({
        left: 0+"vh"
    },200);

    $(".whatsapp-chats").animate({
        left: 30+"vh"
    },200, function(){
        $(".whatsapp-chats").css({"display":"none"});
    });

    $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 150);

    if (OpenedChatPicture == null) {
        OpenedChatPicture = "./img/default.png";
        if (ChatData.picture != null || ChatData.picture != undefined || ChatData.picture != "default") {
            OpenedChatPicture = ChatData.picture
        }
        $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
    }
});

$(document).on('click', '#whatsapp-openedchat-back', function(e){
    e.preventDefault();
    $.post('https://5life-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
        QB.Phone.Functions.LoadWhatsappChats(chats);
    });
    OpenedChatData.number = null;
    $(".whatsapp-chats").css({"display":"block"});
    $(".whatsapp-chats").animate({
        left: 0+"vh"
    }, 200);
    $(".whatsapp-openedchat").animate({
        left: -30+"vh"
    }, 200, function(){
        $(".whatsapp-openedchat").css({"display":"none"});
    });
    $("#whatsapp-contact-search").fadeIn(150);
    OpenedChatPicture = null;
});

QB.Phone.Functions.GetLastMessage = function(messages) {
    var CurrentDate = new Date();
    var CurrentMonth = CurrentDate.getMonth();
    var CurrentDOM = CurrentDate.getDate();
    var CurrentYear = CurrentDate.getFullYear();
    var LastMessageData = {
        time: "00:00",
        message: "nothing"
    }

    $.each(messages[messages.length - 1], function(i, msg){
        var msgData = msg[msg.length - 1];
        LastMessageData.time = msgData.time
        LastMessageData.message = DOMPurify.sanitize(msgData.message , {
            ALLOWED_TAGS: [],
            ALLOWED_ATTR: []
        });
        if(LastMessageData.message == '') 'Hmm, I shouldn\'t be able to do this...'
    });

    return LastMessageData
}

GetCurrentDateKey = function() {
    var CurrentDate = new Date();
    var CurrentMonth = CurrentDate.getMonth();
    var CurrentDOM = CurrentDate.getDate();
    var CurrentYear = CurrentDate.getFullYear();
    var CurDate = ""+CurrentDOM+"-"+CurrentMonth+"-"+CurrentYear+"";

    return CurDate;
}

QB.Phone.Functions.LoadWhatsappChats = function(chats) {
    $(".whatsapp-chats").html("");
    $.each(chats, function(i, chat){
        var profilepicture = "./img/default.png";
        if (chat.picture !== "default") {
            profilepicture = chat.picture
        }
        var LastMessage = QB.Phone.Functions.GetLastMessage(chat.messages);
        var ChatElement = '<div class="whatsapp-chat" id="whatsapp-chat-'+i+'"><div class="whatsapp-chat-picture" style="background-image: url('+profilepicture+');"></div><div class="whatsapp-chat-name"><p>'+chat.name+'</p></div><div class="whatsapp-chat-lastmessage"><p>'+LastMessage.message+'</p></div><div class="whatsapp-chat-unreadmessages unread-chat-id-'+i+'">1</div></div>';

        $(".whatsapp-chats").append(ChatElement);
        $("#whatsapp-chat-"+i).data('chatdata', chat);

        if (chat.Unread > 0 && chat.Unread !== undefined && chat.Unread !== null) {
            $(".unread-chat-id-"+i).html(chat.Unread);
            $(".unread-chat-id-"+i).css({"display":"block"});
        } else {
            $(".unread-chat-id-"+i).css({"display":"none"});
        }
    });
}

QB.Phone.Functions.ReloadWhatsappAlerts = function(chats) {
    $.each(chats, function(i, chat){
        if (chat.Unread > 0 && chat.Unread !== undefined && chat.Unread !== null) {
            $(".unread-chat-id-"+i).html(chat.Unread);
            $(".unread-chat-id-"+i).css({"display":"block"});
        } else {
            $(".unread-chat-id-"+i).css({"display":"none"});
        }
    });
}

const monthNames = ["January", "February", "March", "April", "May", "June", "JulY", "August", "September", "October", "November", "December"];

FormatChatDate = function(date) {
    var TestDate = date.split("-");
    var NewDate = new Date((parseInt(TestDate[1]) + 1)+"-"+TestDate[0]+"-"+TestDate[2]);

    var CurrentMonth = monthNames[NewDate.getMonth()];
    var CurrentDOM = NewDate.getDate();
    var CurrentYear = NewDate.getFullYear();
    var CurDateee = CurrentDOM + "-" + NewDate.getMonth() + "-" + CurrentYear;
    var ChatDate = CurrentDOM + " " + CurrentMonth + " " + CurrentYear;
    var CurrentDate = GetCurrentDateKey();

    var ReturnedValue = ChatDate;
    if (CurrentDate == CurDateee) {
        ReturnedValue = "Today";
    }

    return ReturnedValue;
}

FormatMessageTime = function() {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    if (NewHour < 10) {
        Hourssssss = "0" + NewHour;
    }
    var MessageTime = Hourssssss + ":" + Minutessss
    return MessageTime;
}

$(document).on('click', '#whatsapp-save-note-for-doc', function(e){
    e.preventDefault();
    var Message = $(".whatsapp-input-message").val();
    var Number = $(".whatsapp-input-number").val();

    if ((Message &&Number ) != ""){
        $.post('https://5life-phone/SendMessage', JSON.stringify({
            ChatNumber: Number,
            ChatDate: GetCurrentDateKey(),
            ChatMessage: Message,
            ChatTime: FormatMessageTime(),
            ChatType: "message",
        }));
        ClearInputNew()
        $(".whatsapp-input-message").val("");
        $(".whatsapp-input-number").val("");
        $('#whatsapp-box-new-add-new').fadeOut(350);
        $.post('https://5life-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
            QB.Phone.Functions.LoadWhatsappChats(chats);
        });
    } else {
        QB.Phone.Notifications.Add("fas fa-comment", "Messages", "You can't send a empty message!", "#25D366", 1750);
    }
});

$(document).on('click', '#whatsapp-openedchat-send', function(e){
    e.preventDefault();
    var Message = $("#whatsapp-openedchat-message").val();

    if (Message !== null && Message !== undefined && Message !== "") {
        $.post('https://5life-phone/SendMessage', JSON.stringify({
            ChatNumber: OpenedChatData.number,
            ChatDate: GetCurrentDateKey(),
            ChatMessage: Message,
            ChatTime: FormatMessageTime(),
            ChatType: "message",
        }));
        $(".emojionearea-editor").html("");
        $("#whatsapp-openedchat-message").val("");
    } else {
        QB.Phone.Notifications.Add("fas fa-comment", "Messages", "You can't send a empty message!", "#25D366", 1750);
    }
});

$(document).on('click', '#whatsapp-openedchat-call', function(e){
    e.preventDefault();
    var InputNum = OpenedChatData.number;

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

$(document).on('click', '#send-location', function(e){
    e.preventDefault();
    $('#whatsapp-openedchat-message-extras').click();
    $.post('https://5life-phone/SendMessage', JSON.stringify({
        ChatNumber: OpenedChatData.number,
        ChatDate: GetCurrentDateKey(),
        ChatMessage: "Shared location",
        ChatTime: FormatMessageTime(),
        ChatType: "location",
    }));
});

$(document).on('click', '#send-image', function(e){
    e.preventDefault();
    $('#whatsapp-openedchat-message-extras').click();
    let ChatNumber2 = OpenedChatData.number;
    $.post('https://5life-phone/TakePhoto', JSON.stringify({}),function(url){
        if(url != "[]"){
        $.post('https://5life-phone/SendMessage', JSON.stringify({
        ChatNumber: ChatNumber2,
        ChatDate: GetCurrentDateKey(),
        ChatMessage: "Photo",
        ChatTime: FormatMessageTime(),
        ChatType: "picture",
        url : url
    }))}})
    QB.Phone.Functions.Close();
});

$(document).on('click', '#send-gallery-image', function(e){
    e.preventDefault();
    $(".whatsapp-gallery-box").html("");
    $('.whatsapp-gallery').fadeIn(350);
    $('#whatsapp-openedchat-message-extras').click();
    $.post('https://5life-phone/GetGalleryData', JSON.stringify({}), function(data){
        setTimeout(()=>{
                for (const [k, v] of Object.entries(data)) {
                    var Element = '<div data-url="'+v.image+'" class="whatsapp-image-body"><img src="'+v.image+'" class="whatsapp-image-image"></div>';
                    $(".whatsapp-gallery-box").append(Element);
                }
        },200)
    });
});

$(document).on('click', '.whatsapp-gallery-close', function(e){
    e.preventDefault();
    $('.whatsapp-gallery').fadeOut(350);
});

$(document).on('click', '.whatsapp-image-body', function(e){
    e.preventDefault();
    let ChatNumber2 = OpenedChatData.number;
    var galleryURL = $(this).data('url');
    $.post('https://5life-phone/SendMessage', JSON.stringify({
        ChatNumber: ChatNumber2,
        ChatDate: GetCurrentDateKey(),
        ChatMessage: "Photo",
        ChatTime: FormatMessageTime(),
        ChatType: "picture",
        url : galleryURL
    }))
    $('.whatsapp-gallery').fadeOut(350);
});

QB.Phone.Functions.SetupChatMessages = function(cData, NewChatData) {
    if (cData) {
        OpenedChatData.number = cData.number;

        if (OpenedChatPicture == null) {
            $.post('https://5life-phone/GetProfilePicture', JSON.stringify({
                number: OpenedChatData.number,
            }), function(picture){
                OpenedChatPicture = "./img/default.png";
                if (picture != "default" && picture != null) {
                    OpenedChatPicture = picture
                }
                $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
            });
        } else {
            $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
        }

        $(".whatsapp-openedchat-name").html("<p>"+cData.name+"</p>");
        $(".whatsapp-openedchat-messages").html("");

        $.each(cData.messages, function(i, chat){

            var ChatDate = FormatChatDate(chat.date);
            var ChatDiv = '<div class="whatsapp-openedchat-messages-'+i+' unique-chat"><div class="whatsapp-openedchat-date">'+ChatDate+'</div></div>';

            $(".whatsapp-openedchat-messages").append(ChatDiv);

            $.each(cData.messages[i].messages, function(index, message){
                message.message = DOMPurify.sanitize(message.message , {
                    ALLOWED_TAGS: [],
                    ALLOWED_ATTR: []
                });
                if (message.message == '') message.message = 'Hmm, I shouldn\'t be able to do this...'
                var Sender = "me";
                if (message.sender !== QB.Phone.Data.PlayerData.citizenid) { Sender = "other"; }
                var MessageElement
                if (message.type == "message") {
                    MessageElement = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+Sender+'">'+message.message+'</div><div class="clearfix"></div>'
                } else if (message.type == "location") {
                    MessageElement = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+Sender+' whatsapp-shared-location" data-x="'+message.data.x+'" data-y="'+message.data.y+'"><span style="font-size: 1.2vh;"><i class="fas fa-map-marker-alt" style="font-size: 1vh;"></i> Location</span><div class="whatsapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
                } else if (message.type == "picture") {
                    MessageElement = '<div class="whatsapp-openedchat-message-test whatsapp-openedchat-message-test-'+Sender+'" data-id='+OpenedChatData.number+'><img class="wppimage" src='+message.data.url +'  style=" border-radius:0; width: 80%; position:relative; z-index: 1; right:-2.8vh;height: auto;"></div></div><div class="clearfix"></div>'
                }
                $(".whatsapp-openedchat-messages-"+i).append(MessageElement);
            });
        });
        $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 1);
    } else {
        OpenedChatData.number = NewChatData.number;
        if (OpenedChatPicture == null) {
            $.post('https://5life-phone/GetProfilePicture', JSON.stringify({
                number: OpenedChatData.number,
            }), function(picture){
                OpenedChatPicture = "./img/default.png";
                if (picture != "default" && picture != null) {
                    OpenedChatPicture = picture
                }
                $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
            });
        }

        $(".whatsapp-openedchat-name").html("<p>"+NewChatData.name+"</p>");
        $(".whatsapp-openedchat-messages").html("");
        var NewDate = new Date();
        var NewDateMonth = NewDate.getMonth();
        var NewDateDOM = NewDate.getDate();
        var NewDateYear = NewDate.getFullYear();
        var DateString = ""+NewDateDOM+"-"+(NewDateMonth+1)+"-"+NewDateYear;
        var ChatDiv = '<div class="whatsapp-openedchat-messages-'+DateString+' unique-chat"><div class="whatsapp-openedchat-date">TODAY</div></div>';

        $(".whatsapp-openedchat-messages").append(ChatDiv);
    }

    $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 1);
}

$(document).on('click', '.whatsapp-shared-location', function(e){
    e.preventDefault();
    var messageCoords = {}
    messageCoords.x = $(this).data('x');
    messageCoords.y = $(this).data('y');

    $.post('https://5life-phone/SharedLocation', JSON.stringify({
        coords: messageCoords,
    }))
});

$(document).on('click', '.wppimage', function(e){
    e.preventDefault();
    let source = $(this).attr('src')
   QB.Screen.popUp(source)
});

$(document).on('click', '#whatsapp-openedchat-message-extras', function(e){
    e.preventDefault();

    if (!ExtraButtonsOpen) {
        $(".whatsapp-extra-buttons").css({"display":"block"}).animate({
            left: 3+"%",
            top:  14+"%"
        }, 250);
        ExtraButtonsOpen = true;
    } else {
        $(".whatsapp-extra-buttons").animate({
            left: -20+"vh",
        }, 250, function(){
            $(".whatsapp-extra-buttons").css({"display":"block"});
            ExtraButtonsOpen = false;
        });
    }
});