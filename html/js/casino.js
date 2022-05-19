var PlayerNameOf = null
var PlayerChanseOf = null
var PlayerIDOf = null

function LoadCasinoJob(){
    var PlayerJob = QB.Phone.Data.PlayerData.job.name;
    if (PlayerJob == "pilot"){
        $(".casino-dashboard-boss").css({"display":"block"});
        $("#casino-Winer-this").css({"display":"block"});
    } else {
        $(".casino-dashboard-boss").css({"display":"none"});
        $("#casino-Winer-this").css({"display":"none"});
    }

    CheckStatus();

    $.post('https://qb-phone/CheckHasBetTable', JSON.stringify({}), function(HasTable){
        if(JSON.stringify(HasTable) != "[]"){
            AddToChat(HasTable)
        }else{
            $(".casino-list").html("");
            var AddOption = '<div class="casino-text-clear">No Event</div>'+
                                '<br />'+
                                '<br />'+
                                '<br />'+
                                '<div class="casino-text-clear" style="font-size: 600%;color: #0d1218c0;"><i class="fas fa-gem"></i></div>'
            $('.casino-list').append(AddOption);
        }
    });
}

$(document).on('click', '.casino-dashboard-boss', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#casino-dashboard-box').fadeIn(350);
});

$(document).on('click', '#casino_create_bet', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#casino-dashboard-box').fadeOut(350);
    $('#casino-dashboard-box-create-bet').fadeIn(350);
});

$(document).on('click', '#casino_delete', function(e){
    e.preventDefault();
    $.post('https://qb-phone/CasinoDeleteTable', JSON.stringify({}));
});

$(document).on('click', '#casino_status', function(e){
    e.preventDefault();
    $.post('https://qb-phone/casino_status', JSON.stringify({}));
    CheckStatus();
});

$(document).on('click', '#casino-submit-bet', function(e){
    e.preventDefault();
    var InName = $(".casino_input_name").val();
    var InChanse = $(".casino_input_Chanse").val();
    if (InName != "" && InChanse != "" && InChanse >= 1.0){
        $.post('https://qb-phone/CasinoAddBet', JSON.stringify({
            name: InName,
            chanse: InChanse,
        }));
        ClearInputNew();
    } else {
        QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", "Fields are incorrect")
    }
});

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "BetAddToApp":
                AddToChat(event.data.datas)
            break;
        }
    })
});

function AddToChat(data){
    $(".casino-list").html("");
    if(JSON.stringify(data) != "[]"){
        for (const [k, v] of Object.entries(data)) {
            var firstLetter = v.Name.substring(0, 1);  
            var Fulltext = firstLetter.toUpperCase()+(v.Name).replace(firstLetter,'')

            var AddOption = '<div class="casino-license-body-main">'+
                                '<div class="casino-license-text-class">'+Fulltext+'</div>'+
                                '<div class="casino-license-icon-class"><i data-name="'+Fulltext+'" data-chanse="'+v.chanse+'" data-id="'+v.id+'" id="casino-click-beting" class="fas fa-coins"></i></div>'+
                            '</div>'
            $('.casino-list').append(AddOption);
        }
    }else{
        $(".casino-list").html("");
            var AddOption = '<div class="casino-text-clear">No Event</div>'+
                                '<br />'+
                                '<br />'+
                                '<br />'+
                                '<div class="casino-text-clear" style="font-size: 600%;color: #0d1218c0;"><i class="fas fa-gem"></i></div>'
            $('.casino-list').append(AddOption);
    }
}

function CheckStatus(){
    $.post('https://qb-phone/CheckHasBetStatus', JSON.stringify({}), function(HasStatus){
        if (HasStatus){
            $("#casino_status").html("Status: Betting Enabled");
        }else{
            $("#casino_status").html("Status: Betting Disabled");
        }
    });
}


$(document).on('click', '#casino-click-beting', function(e){
    e.preventDefault();
    PlayerNameOf = $(this).data('name')
    PlayerChanseOf = $(this).data('chanse')
    PlayerIDOf = $(this).data('id')
    $("#casino-info-player").html(PlayerNameOf);
    $("#casino-info-total").html("0 Dollars");
    $("#casino-info-chanse").html("x"+PlayerChanseOf);
    $('#casin-bet-boxing-player').fadeIn(350);
});

$(".casino-amount-for-bet-player").keyup(function(){
    var input = this.value
    var MoneyAmount = input * PlayerChanseOf

    $("#casino-info-total").html(MoneyAmount+" Dollars");
});

$(document).on('click', '#casino-end-task-accept', function(e){
    e.preventDefault();
    var Amount = $(".casino-amount-for-bet-player").val();
    if (Amount != "" && Amount >= 1.0){
        $.post('https://qb-phone/BettingAddToTable', JSON.stringify({
            amount: Amount,
            chanse: PlayerChanseOf,
            player: PlayerNameOf,
            id: PlayerIDOf,
        }));
        ClearInputNew();
    } else {
        QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", "Fields are incorrect")
    }
});

$(document).on('click', '#casino-Winer-this', function(e){
    e.preventDefault();
        $.post('https://qb-phone/WineridCasino', JSON.stringify({
            id: PlayerIDOf,
        }));
});