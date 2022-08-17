var OpenedMail = null;

// Mail APP

// Search

$(document).ready(function(){
    $("#mail-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".mail").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

// Functions

QB.Phone.Functions.SetupMails = function(Mails) {
    if (Mails !== null && Mails !== undefined) {
        Mails = Mails.reverse();
        if (Mails.length > 0) {
            $(".mail-list").html("");
            $.each(Mails, function(i, mail){
                var TimeAgo = moment(mail.date).format('MM/DD/YYYY hh:mm');

                if (JSON.stringify(mail.button) != "[]"){
                    var element = '<div class="mail" id="mail-'+mail.mailid+'" data-mailid="'+mail.mailid +'">'+
                        '<span class="mail-sender">From: '+mail.sender+'</span>' +
                            '<div class="mail-subject"><p>Subject: '+mail.subject+'</p></div>' +
                            '<div class="mail-block">' +
                                '<div class="mail-message">'+mail.message+'</div>' +
                                '<div class="mail-box"><span class="mail-box mail-accept" style="margin-left: 4.0vh;">ACCEPT</span><span class="mail-box mail-delete" style = "margin-left: 1.1vh;">DELETE</span></div>' +
                            '</div>' +
                            '<div class="mail-line"></div>' +
                            '<div class="mail-time">'+TimeAgo+'</div>' +
                        '</div>';
                        $(".mail-list").append(element);
                        $("#mail-"+mail.mailid).data('MailData', mail);
                }else{
                    var element = '<div class="mail" id="mail-'+mail.mailid+'" data-mailid="'+mail.mailid +'">'+
                        '<span class="mail-sender">From: '+mail.sender+'</span>' +
                            '<div class="mail-subject"><p>Subject: '+mail.subject+'</p></div>' +
                            '<div class="mail-block">' +
                                '<div class="mail-message">'+mail.message+'</div>' +
                                '<div class="mail-box"><span class="mail-box mail-delete" style = "margin-left: 7.0vh;">DELETE</span></div>' +
                            '</div>' +
                            '<div class="mail-line"></div>' +
                            '<div class="mail-time">'+TimeAgo+'</div>' +
                        '</div>';
                    $(".mail-list").append(element);
                    $("#mail-"+mail.mailid).data('MailData', mail);
                }
            });
        } else {
            $(".mail-list").html('<p class="nomails">Nothing Here! <i class="fas fa-frown" id="mail-frown"></i></p>');
        }

    }
}

// Clicks

$(document).on('click', '.mail-accept', function(e){
    e.preventDefault();
    var mailId = $(this).parent().parent().parent().data('mailid');
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('https://qb-phone/AcceptMailButton', JSON.stringify({
        buttonEvent: MailData.button.buttonEvent,
        buttonData: MailData.button.buttonData,
        isServer: MailData.button.isServer,
        mailId: mailId,
    }));
});

$(document).on('click', '.mail-delete', function(e){
    e.preventDefault();
    var mailId = $(this).parent().parent().parent().data('mailid');
    $.post('https://qb-phone/RemoveMail', JSON.stringify({
        mailId: mailId
    }));
});

$(document).on('click', '.mail', function(e){
    e.preventDefault();
    $(this).find(".mail-block").toggle();
    OpenedMail = $(this).attr('id');
});