var CryptoMeta = ''
var CryptoName = ''
var formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
});

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

function LoadCryptoCoins(){
    $.post('https://qb-phone/GetCryptosFromDegens', JSON.stringify({}), function(Jobs){
        $(".crypto-lists").html("");
        for (const [k, v] of Object.entries(Jobs)) {
            var CryptoType = QB.Phone.Data.PlayerData.metadata.crypto;
            var Crypto = v.metadata;

            if (v.purchase){
                var AddOption = '<div class="crypto-list" id="crypto-id"><span class="crypto-icon"><i class="'+v.icon+'"></i></span> <span class="crypto-label">'+v.label+'</span> <span class="crypto-value">'+CryptoType[Crypto]+'</span>' +
                '<div class="crypto-block">' +
                    '<div class="crypto-abbrev"><i class="fas fa-id-card"></i>'+v.abbrev+' ('+k+')</div>' +
                    '<div class="crypto-extralabel"><i class="fas fa-tag"></i>'+v.label+'</div>' +
                    '<div class="crypto-current"><i class="fas fa-money-check-alt"></i>'+CryptoType[Crypto]+'</div>' +
                    '<div class="crypto-cost"><i class="fas fa-chart-bar"></i>'+formatter.format(v.value)+'</div>' +
                    '<div class="crypto-box"><span class="crypto-box box-purchase" data-cryptometa="'+v.metadata+'" data-label="'+v.label+'" style="margin-left: 0.5vh;">PURCHASE</span><span class="crypto-box box-exchange" data-cryptometa="'+v.metadata+'" data-label="'+v.label+'" style = "margin-left: 1.1vh;">EXCHANGE</span></div>' +
                    '</div>' +
                '</div>';
            }else{
                var AddOption = '<div class="crypto-list" id="crypto-id" ><span class="crypto-icon"><i class="'+v.icon+'"></i></span> <span class="crypto-label">'+v.label+'</span> <span class="crypto-value">'+CryptoType[Crypto]+'</span>' +
                '<div class="crypto-block">' +
                    '<div class="crypto-abbrev"><i class="fas fa-id-card"></i>'+v.abbrev+' ('+k+')</div>' +
                    '<div class="crypto-extralabel"><i class="fas fa-tag"></i>'+v.label+'</div>' +
                    '<div class="crypto-current"><i class="fas fa-money-check-alt"></i>'+CryptoType[Crypto]+'</div>' +
                    '<div class="crypto-cost"><i class="fas fa-chart-bar"></i>'+formatter.format(v.value)+'</div>' +
                    '<div class="crypto-box"><span class="crypto-box box-exchange" data-cryptometa="'+v.metadata+'" data-label="'+v.label+'" style = "margin-left: 5.2vh;">EXCHANGE</span></div>' +
                    '</div>' +
                '</div>';
            }
            
            $('.crypto-lists').append(AddOption);
        }
    });
};

$(document).ready(function(){
    $("#crypto-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".crypto-list").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '.crypto-list', function(e){
    e.preventDefault();

    $(this).find(".crypto-block").toggle();
});

$(document).on('click', '.box-purchase', function(e){
    e.preventDefault();
    ClearInputNew()
    CryptoMeta = $(this).data('cryptometa')
    CryptoName = $(this).data('label')
    $('#crypto-purchase-tab').fadeIn(350);
});

$(document).on('click', '#crypto-send-purchase', function(e){
    e.preventDefault();
    var crypto = CryptoMeta;
    var amount = $(".crypto-amount").val();
    if(amount != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post('https://qb-phone/BuyCrypto', JSON.stringify({
            metadata: crypto,
            amount: amount,
        }));
    }
    ClearInputNew()
    $('#crypto-purchase-tab').fadeOut(350);
});

$(document).on('click', '.box-exchange', function(e){
    e.preventDefault();
    ClearInputNew()
    CryptoMeta = $(this).data('cryptometa')
    CryptoName = $(this).data('label')
    $('#crypto-exchange-tab').fadeIn(350);
});

$(document).on('click', '#crypto-send-exchange', function(e){
    e.preventDefault();
    var crypto = CryptoMeta;
    var amount = $(".crypto-amount-exchange").val();
    var stateid = $(".crypto-stateid-exchange").val();
    var CryptoType = QB.Phone.Data.PlayerData.metadata.crypto;
    if(amount != "" || stateid != ""){
        if (CryptoType[crypto] - amount > 0){
            setTimeout(function(){
                ConfirmationFrame()
            }, 150);
            $.post('https://qb-phone/ExchangeCrypto', JSON.stringify({
                metadata: crypto,
                amount: amount,
                stateid: stateid,
            }));
        }else{
            QB.Phone.Notifications.Add("fas fa-chart-line", "WALLET", "You don\'t have that much crypto", "#D3B300");
        }
    }
    ClearInputNew()
    $('#crypto-exchange-tab').fadeOut(350);
});