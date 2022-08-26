var CurrentTwitterTab = "twitter-home"
var HashtagOpen = false;
var MinimumTrending = 100;

// Search

$(document).ready(function(){
    $("#twitter-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".twitter-tweet").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

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

function CopyMentionTag(elem) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(elem).data('mentiontag')).select();
    QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", $(elem).data('mentiontag')+ " copied!", "rgb(27, 149, 224)", 1250);
    document.execCommand("copy");
    $temp.remove();
}

QB.Phone.Notifications.LoadTweets = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        $(".twitter-home-tab").html("");
        $.each(Tweets, function(i, Tweet){
            var TwtMessage = Tweet.message
            var TimeAgo = moment(Tweet.date).format('MM/DD/YYYY hh:mm');
            var TwitterHandle = Tweet.firstName + ' ' + Tweet.lastName

            if (Tweet.url == "") {
                if (Tweet.citizenid === QB.Phone.Data.PlayerData.citizenid){
                    var TweetElement = '<div class="twitter-tweet" data-twtid ="'+Tweet.tweetId+'" data-twthandler="@' + TwitterHandle.replace(" ", "_") + '" data-type ="'+Tweet.type+'">'+
                        '<div class="tweet-tweeter">' + ' &nbsp;<span>@' + TwitterHandle.replace(" ", "_") + '</span></div>' + // Title
                        '<div class="tweet-reply"><i class="fas fa-reply"></i></div>' +
                        '<div class="twitter-retweet" data-twtmessage="'+TwtMessage+'"><div class="tweet-retweet"><i class="fas fa-retweet"></i></div>'+
                        '<div class="tweet-flag"><i class="fas fa-flag"></i></div>'+
                        '<div class="tweet-trash"><i class="fas fa-trash"></i></div>'+
                        '<div class="tweet-message" style="padding-bottom: 2.5vh;">' + TwtMessage + '</div>' +
                        '<div class="tweet-time">' + TimeAgo + '</div>' +
                    '</div>';
                    $(".twitter-home-tab").append(TweetElement);
                }else{
                    var TweetElement = '<div class="twitter-tweet" data-twtid ="'+Tweet.tweetId+'" data-twthandler="@' + TwitterHandle.replace(" ", "_") + '" data-type ="'+Tweet.type+'">'+
                        '<div class="tweet-tweeter">' + ' &nbsp;<span>@' + TwitterHandle.replace(" ", "_") + '</span></div>' + // Title
                        '<div class="tweet-reply"><i class="fas fa-reply"></i></div>' +
                        '<div class="twitter-retweet" data-twtmessage="'+TwtMessage+'"><div class="tweet-retweet"><i class="fas fa-retweet"></i></div>'+
                        '<div class="tweet-trash"><i class="fas fa-trash"></i></div>'+
                        '<div class="tweet-message" style="padding-bottom: 2.5vh;">' + TwtMessage + '</div>' +
                        '<div class="tweet-time">' + TimeAgo + '</div>' +
                    '</div>';
                    $(".twitter-home-tab").append(TweetElement);
                }
            } else {
                if (Tweet.citizenid === QB.Phone.Data.PlayerData.citizenid){
                    var TweetElement = '<div class="twitter-tweet" data-twtid ="'+Tweet.tweetId+'" data-twthandler="@'+TwitterHandle.replace(" ", "_") + '" data-type ="'+Tweet.type+'">'+
                            '<div class="tweet-tweeter">' + ' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+ '</span></div>'+ // Title
                            '<div class="tweet-reply"><i class="fas fa-reply"></i></div>'+
                            '<div class="twitter-retweet" data-imagemessage="'+Tweet.url+'" data-twtmessage="'+TwtMessage+'"><div class="tweet-retweet"><i class="fas fa-retweet"></i></div>'+
                            '<div class="tweet-flag"><i class="fas fa-flag"></i></div>'+
                            '<div class="tweet-trash"><i class="fas fa-trash"></i></div>'+
                            '<div class="tweet-message"><p>'+TwtMessage+'</p></div>' +
                            '<div class="tweet-image-attached">Images Attached: 1<p><u>Hide (click image to copy URL)</u></p></div>'+
                            '<div class="tweet-time">' + TimeAgo + '</div>' +
                            '<img class="image" src= ' + Tweet.url + ' style = " display: none; border-radius:4px; width: 70%; position:relative; z-index: 1; left:25px; margin:.6rem .5rem .6rem 1rem;height: auto; bottom: 20px;">' +
                            '<div class="tweet-block">' +
                                '<div class="tweet-eye"><i class="fas fa-eye"></i></div>'+
                                '<div class="tweet-image-text">Click to View</div>'+
                                '<div class="tweet-image-text-other">Only revel images from those you<p>know are not dick heads</p></div>'+
                            '</div>'+
                        '</div>';
                    $(".twitter-home-tab").append(TweetElement);
                }else{
                    var TweetElement = '<div class="twitter-tweet" data-twtid ="'+Tweet.tweetId+'" data-twthandler="@'+TwitterHandle.replace(" ", "_") + '" data-type ="'+Tweet.type+'">'+
                    '<div class="tweet-tweeter">' + ' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+ '</span></div>'+ // Title
                    '<div class="tweet-reply"><i class="fas fa-reply"></i></div>'+
                    '<div class="twitter-retweet" data-imagemessage="'+Tweet.url+'" data-twtmessage="'+TwtMessage+'"><div class="tweet-retweet"><i class="fas fa-retweet"></i></div>'+
                    '<div class="tweet-flag"><i class="fas fa-flag"></i></div>'+
                    '<div class="tweet-message"><p>'+TwtMessage+'</p></div>' +
                    '<div class="tweet-image-attached">Images Attached: 1<p><u>Hide (click image to copy URL)</u></p></div>'+
                    '<div class="tweet-time">' + TimeAgo + '</div>' +
                    '<img class="image" src= ' + Tweet.url + ' style = " display: none; border-radius:4px; width: 70%; position:relative; z-index: 1; left:25px; margin:.6rem .5rem .6rem 1rem;height: auto; bottom: 20px;">' +
                    '<div class="tweet-block">' +
                        '<div class="tweet-eye"><i class="fas fa-eye"></i></div>'+
                        '<div class="tweet-image-text">Click to View</div>'+
                        '<div class="tweet-image-text-other">Only revel images from those you<p>know are not dick heads</p></div>'+
                    '</div>'+
                '</div>';
            $(".twitter-home-tab").append(TweetElement);
                }

            }
        });
    }
}

// Clicks

$(document).on('click', '.twitter-new-tweet', function(e){ // Post Tweet Button
    e.preventDefault();
    ClearInputNew()
    $('#twt-box-textt').fadeIn(350);
});

$(document).on('click', '#twt-sendmessage-chat', function(e){ // Submit Button For Twitter Message
    e.preventDefault();

    var TweetMessage = $(".twt-box-textt-input").val();
    var imageURL = $('.twt-box-image-input').val()
    if (TweetMessage != "" || imageURL !== "") {
        var CurrentDate = new Date();
        if (imageURL != ""){
            setTimeout(function(){
                ConfirmationFrame()
            }, 150);
        }
        $.post('https://qb-phone/PostNewTweet', JSON.stringify({
            Message: TweetMessage,
            Date: CurrentDate,
            url: imageURL,
            type: 'tweet'
        }), function(){
            ClearInputNew();
            $('#twt-box-textt').fadeOut(350);
        });
    } else {
        QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", "Fill a message!", "#1DA1F2");
    };
    $('.twt-box-image-input').val("");
});

// Clicks

$(document).on('click', '.tweet-eye', function(e){
    e.preventDefault();

    $(this).parent().parent().find(".image").css({"display":"block"});
    $(this).parent().parent().find(".tweet-block").css({"display":"none"});
});

$(document).on('click', '.tweet-image-attached', function(e){
    e.preventDefault();

    $(this).parent().parent().find(".image").css({"display":"none"});
    $(this).parent().parent().find(".tweet-block").css({"display":"block"});
});

$(document).on('click', '#image-container', function(e){
    e.preventDefault();
    QB.Screen.popUp(source)
});

$(document).on('click', '.tweet-reply', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');

    ClearInputNew()
    $('#twt-box-textt').fadeIn(350);
    $(".twt-box-textt-input").val(TwtName+ " ");
});

$(document).on('click', '.tweet-retweet', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().parent().data('twthandler');
    var isRetweet =  $(this).parent().parent().data('type');
    var TwtMessage = $(this).parent().data('twtmessage');
    var imageURL = $(this).parent().data('imagemessage');
    var CompleteRetweet = "RT " + TwtName + " " + TwtMessage

    if (isRetweet !== 'retweet'){
        var CurrentDate = new Date();
        if (imageURL == null){
            imageURL = ""
        }
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post('https://qb-phone/PostNewTweet', JSON.stringify({
            Message: CompleteRetweet,
            Date: CurrentDate,
            url: imageURL,
            type: 'retweet'
        }))
    } else {
        QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", "Cannot retweet a retweet!", "#1DA1F2");
    }
});

$(document).on('click', '.tweet-flag', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().parent().data('twthandler');
    var TwtMessage = $(this).parent().data('twtmessage');
    $.post('https://qb-phone/FlagTweet', JSON.stringify({
        name: TwtName,
        message: TwtMessage,
    }))
});

$(document).on('click','.tweet-trash',function(e){
    e.preventDefault();
    var source = $(this).parent().parent().data('twtid');
    $.post('https://qb-phone/DeleteTweet', JSON.stringify({id: source}))
})
