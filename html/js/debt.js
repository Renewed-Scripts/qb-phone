var ENDreason = null
var ENDamount = null
var ENDsenderCSN = null
var ENDsenderName = null
var ENDKey = null

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "DebtRefresh":
                LoadDebtJob();
            break;
        }
    })
});


function LoadDebtJob(){
    $(".debt-list").html("");
    var AddOption = '<div class="casino-text-clear">Nothing Here!</div>'+
                    '<div class="casino-text-clear" style="font-size: 500%;color: #0d1218c0;"><i class="fas fa-frown"></i></div>'
    $('.debt-list').append(AddOption);
    $.post('https://qb-phone/GetHasBills_debt', JSON.stringify({}), function(HasTable){

        if(HasTable){
            AddToDebitList(HasTable)
        }
    });
}

function AddToDebitList(data){
    $(".debt-list").html("");
    if(data){
        for (const [k, v] of Object.entries(data)) {
            var AddOption = '<div class="debt-form-style-body" style="color: whitesmoke;"><i style="color: whitesmoke;" class="fas fa-user"></i> '+v.sender+' | '+
                                '<div style="display: inline; color: #6cac59;"> <i class="fas fa-dollar-sign"></i>'+v.amount+'</div>'+
                                '<div data-key="'+v.id+'" data-senderN="'+v.sender+'" data-reason="'+v.reason+'" data-amount="'+v.amount+'" data-sendercsn="'+v.sendercitizenid+'" class="debt-btn-for-check-data"><i class="fas fa-search-dollar"></i></div>'+
                            '</div>'
            $('.debt-list').append(AddOption);
        }
    }
}

$(document).on('click', '.debt-create-bill-btn', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#debt-box-new-for-add').fadeIn(350);
});

$(document).on('click', '#debt-create-bill-ended', function(e){
    e.preventDefault();
    var ID = $(".debt-input-one").val();
    var Amount = $(".debt-input-two").val();
    var Reason = $(".debt-input-three").val();
    if ((ID && Amount && Reason) != "" && (ID && Amount) >= 1){
        $.post('https://qb-phone/SendBillForPlayer_debt', JSON.stringify({
            ID: ID,
            Amount: Amount,
            Reason: Reason,
        }));
        ClearInputNew()
        $('#debt-box-new-for-add').fadeOut(350);
    }else{
        QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", "Fields are incorrect")
    }

});



$(document).on('click', '.debt-btn-for-check-data', function(e){
    e.preventDefault();
    ENDreason = $(this).data('reason');
    ENDamount = $(this).data('amount');
    ENDsenderCSN = $(this).data('sendercsn');
    ENDsenderName = $(this).data('sendern');
    ENDKey = $(this).data('key');

    $(".debt-show-one").html('<i style="color: whitesmoke;" class="fas fa-clipboard"></i> '+ENDreason);
    $(".debt-show-two").html('<i class="fas fa-dollar-sign"></i>'+ENDamount);
    $(".debt-show-three").html('<i style="color: whitesmoke;" class="fas fa-user"></i> '+ENDsenderName);

    ClearInputNew()
    $('#debt-box-new-for-accept').fadeIn(350);
});

$(document).on('click', '#debt-create-bill-accept', function(e){
    e.preventDefault();
    var PlyMoney = QB.Phone.Data.PlayerData.money.bank;

    if(PlyMoney >= ENDamount){
        $.post('https://qb-phone/debit_AcceptBillForPay', JSON.stringify({
            id: ENDKey,
            Amount: ENDamount,
            CSN: ENDsenderCSN,
        }));
        ClearInputNew()
        $('#debt-box-new-for-accept').fadeOut(350);
    }
});