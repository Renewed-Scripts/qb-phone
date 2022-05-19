$(document).on('click', '.wenmo-send-money-btn', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#wenmo-box-new-for-give').fadeIn(350);
});

$(document).on('click', '#wenmo-send-money-ended', function(e){
    e.preventDefault();
    var ID = $(".wenmo-input-one").val();
    var Amount = $(".wenmo-input-two").val();
    var Reason = $(".wenmo-input-three").val();
    if ((ID && Amount && Reason) != "" && (ID && Amount) >= 1){
        $.post('https://qb-phone/wenmo_givemoney_toID', JSON.stringify({
            ID: ID,
            Amount: Amount,
            Reason: Reason,
        }));
        
        ClearInputNew()
        $('#wenmo-box-new-for-give').fadeIn(350);
    }
});

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "ChangeMoney_Wenmo":
                var date = new Date();
                var Times = date.getHours()+":"+date.getMinutes();
                var AddOption = '<div style="color: '+event.data.Color+';" class="wenmo-form-style-body">'+event.data.Amount+'<div class="wenmo-time-class-body">'+Times+'</div>'+
                                    '<div style="color: #a8a8a8;">'+event.data.Reason+'</div>'+
                                '</div>'

                    $('.wenmo-list').prepend(AddOption);
            break;
        }
    })
});