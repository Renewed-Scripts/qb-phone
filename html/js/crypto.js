var test = true;

function LoadCryptoCoins(){
    $.post('https://qb-phone/GetCryptosFromDegens', JSON.stringify({}), function(Jobs){
        $(".crypto-lists").html("");
        for (const [k, v] of Object.entries(Jobs)) {
            var CryptoType = QB.Phone.Data.PlayerData.metadata.crypto;
            var Crypto = v.metadata;
            var AddOption = '<div class="crypto-list" id="crypto-id" ><span class="crypto-icon"><i class="'+v.icon+'"></i></span> <span class="crypto-label">'+v.label+'</span> <span class="crypto-value">'+CryptoType[Crypto]+'</span> <span class="crypto-block"><p>TESTING THIS DUMB SHIT AND MAKING IT WORK</p></span> </div>';
            
            $('.crypto-lists').append(AddOption);
        }

    });
};

$(document).on('click', '.crypto-list', function(e){
    e.preventDefault();

    if (test){
        $(".crypto-block").css({"display":"block"});
        test = false;
    }else{
        $(".crypto-block").css({"display":"none"});
        test = true;
    }
});