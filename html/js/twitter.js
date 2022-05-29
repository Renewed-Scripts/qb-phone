var CurrentTwitterTab = "twitter-home"
var HashtagOpen = false;
var MinimumTrending = 100;

$(document).ready(function(){
    $("#twitter-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".twitter-tweet").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '.twitter-header-tab', function(e){
    e.preventDefault();

    var PressedTwitterTab = $(this).data('twittertab');
    var PreviousTwitterTabObject = $('.twitter-header').find('[data-twittertab="'+CurrentTwitterTab+'"]');

    if (PressedTwitterTab !== CurrentTwitterTab) {
        $(this).addClass('selected-twitter-header-tab');
        $(PreviousTwitterTabObject).removeClass('selected-twitter-header-tab');

        $("."+CurrentTwitterTab+"-tab").css({"display":"none"});
        $("."+PressedTwitterTab+"-tab").css({"display":"block"});

        if (PressedTwitterTab === "twitter-mentions") {
            $.post('https://qb-phone/ClearMentions');
        }

        if (PressedTwitterTab == "twitter-home") {
            $.post('https://qb-phone/GetTweets', JSON.stringify({}), function(Tweets){
                QB.Phone.Notifications.LoadTweets(Tweets);
            });
        }

        CurrentTwitterTab = PressedTwitterTab;

        if (HashtagOpen) {
            event.preventDefault();

            $(".twitter-hashtag-tweets").css({"left": "30vh"});
            $(".twitter-hashtags").css({"left": "0vh"});
            $(".twitter-new-tweet").css({"display":"block"});
            $(".twitter-hashtags").css({"display":"block"});
            HashtagOpen = false;
        }
    } else if (CurrentTwitterTab == "twitter-hashtags" && PressedTwitterTab == "twitter-hashtags") {
        if (HashtagOpen) {
            event.preventDefault();

            $(".twitter-hashtags").css({"display":"block"});
            $(".twitter-hashtag-tweets").animate({
                left: 30+"vh"
            }, 150);
            $(".twitter-hashtags").animate({
                left: 0+"vh"
            }, 150);
            HashtagOpen = false;
        }
    } else if (CurrentTwitterTab == "twitter-home" && PressedTwitterTab == "twitter-home") {
        event.preventDefault();

        $.post('https://qb-phone/GetTweets', JSON.stringify({}), function(Tweets){
            QB.Phone.Notifications.LoadTweets(Tweets);
        });
    } else if (CurrentTwitterTab == "twitter-mentions" && PressedTwitterTab == "twitter-mentions") {
        event.preventDefault();

        $.post('https://qb-phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
            QB.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
        })
    }
});

$(document).on('click', '.twitter-new-tweet', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#twt-box-textt').fadeIn(350);
});

$(document).on('click', '#twt-sendmessage-chat', function(e){
    e.preventDefault();

    var TweetMessage = $(".twt-box-textt-input").val();
    var imageURL = $('.twt-box-image-input').val()
    if (TweetMessage != "" || imageURL !== "") {
        var CurrentDate = new Date();
        $.post('https://qb-phone/PostNewTweet', JSON.stringify({
            Message: TweetMessage,
            Date: CurrentDate,
            Picture: QB.Phone.Data.MetaData.profilepicture,
            url: imageURL
        }), function(Tweets){
            QB.Phone.Notifications.LoadTweets(Tweets);
            ClearInputNew();
            $('#twt-box-textt').fadeOut(350);
        });
        $.post('https://qb-phone/GetHashtags', JSON.stringify({}), function(Hashtags){
            QB.Phone.Notifications.LoadHashtags(Hashtags)
        })
        QB.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
    } else {
        QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", "Fill a message!", "#1DA1F2");
    };
    $('.twt-box-image-input').val("");
});

QB.Phone.Notifications.LoadTweets = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        $(".twitter-home-tab").html("");
        $.each(Tweets, function(i, Tweet){
            var clean = DOMPurify.sanitize(Tweet.message , {
                ALLOWED_TAGS: [],
                ALLOWED_ATTR: []
            });
            //if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
            var TwtMessage = QB.Phone.Functions.FormatTwitterMessage(clean);
            var TimeAgo = moment(Tweet.date).format('MM/DD/YYYY hh:mm');

            var TwitterHandle = Tweet.firstName + ' ' + Tweet.lastName
            var PictureUrl = "./img/default.png"
            if (Tweet.picture !== "default") {
                PictureUrl = Tweet.picture
            }

            if (Tweet.url == "") {
                let TweetElement = '<div class="twitter-tweet" data-twtcid="'+Tweet.citizenid+'" data-twtid ="'+Tweet.tweetId+'" data-twthandler="@' + TwitterHandle.replace(" ", "_") + '"><div class="tweet-reply"><i class="fas fa-reply"></i></div>' +
                    '<div class="twitter-retweet" data-twthandler="@'+TwitterHandle.replace(" ", "_")+'" data-twtmessage="'+TwtMessage+'"><div class="tweet-retweet"><i class="fas fa-retweet"></i></div>'+
                    '<div class="tweet-flag"><i class="fas fa-flag"></i></div>'+
                    '<div class="tweet-tweeter">' + ' &nbsp;<span>@' + TwitterHandle.replace(" ", "_") + '</span></div>' + //' &middot; '+TimeAgo+'
                    '<div class="tweet-message">' + TwtMessage + '</div>' +
                    '<div class="tweet-time">' + TimeAgo + '</div>' +
                    //'<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image"></div>' +
                    '</div>';
                    $(".twitter-home-tab").append(TweetElement);
            } else {
                let TweetElement = '<div class="twitter-tweet" data-twthandler="@'+TwitterHandle.replace(" ", "_")+'"><div class="tweet-reply"><i class="fas fa-reply"></i></div>'+
                    '<div class="twitter-retweet" data-twthandler="@'+TwitterHandle.replace(" ", "_")+'" data-twtmessage="'+TwtMessage+'"><div class="tweet-retweet"><i class="fas fa-retweet"></i></div>'+
                    '<div class="tweet-flag"><i class="fas fa-flag"></i></div>'+
                    '<div class="tweet-tweeter">' + ' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+ '</span></div>'+ //' &middot; '+TimeAgo+'
                    '<div class="tweet-message">'+TwtMessage+'</div>'+
                    '<div class="tweet-time">' + TimeAgo + '</div>' +
                    '<img class="image" src= ' + Tweet.url + ' style = " border-radius:4px; width: 70%; position:relative; z-index: 1; left:25px; margin:.6rem .5rem .6rem 1rem;height: auto; bottom: 20px;">' +
                    //'<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image"></div>' +
                    '</div>';
                $(".twitter-home-tab").append(TweetElement);
            }
        });
    }
}

$(document).on('click','#twt-delete-click',function(e){
    e.preventDefault();
    let source = $('.twitter-tweet').data('twtid')
    $(this).parent().parent().parent().parent().remove()
    $.post('https://qb-phone/DeleteTweet', JSON.stringify({id: source}))
})

$(document).on('click', '.tweet-reply', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');

    ClearInputNew()
    $('#twt-box-textt').fadeIn(350);
    $(".twt-box-textt-input").val(TwtName+ " ");
});

$(document).on('click', '.tweet-retweet', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');
    var TwtMessage = $(this).parent().data('twtmessage');
    ClearInputNew()
    $('#twt-box-textt').fadeIn(350);
    $(".twt-box-textt-input").val("RT "+TwtName+ " "+ TwtMessage);
});

$(document).on('click', '.tweet-flag', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');
    var TwtMessage = $(this).parent().data('twtmessage');
    $.post('https://qb-phone/FlagTweet', JSON.stringify({
        name: TwtName,
        message: TwtMessage,
    }))
});

QB.Phone.Notifications.LoadMentionedTweets = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets.length > 0) {
        $(".twitter-mentions-tab").html("");
        $.each(Tweets, function(i, Tweet){
            var clean = DOMPurify.sanitize(Tweet.message , {
                ALLOWED_TAGS: [],
                ALLOWED_ATTR: []
            });
            //if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
            var TwtMessage = QB.Phone.Functions.FormatTwitterMessage(clean);
            var TimeAgo = moment(Tweet.date).format('MM/DD/YYYY hh:mm');

            var TwitterHandle = Tweet.firstName + ' ' + Tweet.lastName
            var PictureUrl = "./img/default.png";
            if (Tweet.picture !== "default") {
                PictureUrl = Tweet.picture
            }

            var TweetElement =
            '<div class="twitter-tweet">'+
                '<div class="tweet-tweeter">'+Tweet.firstName+' '+Tweet.lastName+' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+' &middot; '+TimeAgo+'</span></div>'+
                '<div class="tweet-message">'+TwtMessage+'</div>'+
            '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image"></div></div>';

            $(".twitter-mentioned-tweet").css({"background-color":"#F5F8FA"});
            $(".twitter-mentions-tab").append(TweetElement);
        });
    }
}

QB.Phone.Functions.FormatTwitterMessage = function(TwitterMessage) {
    var TwtMessage = TwitterMessage;
    var res = TwtMessage.split("@");
    var tags = TwtMessage.split("#");
    var InvalidSymbols = [
        "[",
        "?",
        "!",
        "@",
        "#",
        "]",
    ]

    for(i = 1; i < res.length; i++) {
        var MentionTag = res[i].split(" ")[0];
        if (MentionTag !== null && MentionTag !== undefined && MentionTag !== "") {
            TwtMessage = TwtMessage.replace("@"+MentionTag, "<span class='mentioned-tag' data-mentiontag='@"+MentionTag+"''>@"+MentionTag+"</span>");
        }
    }

    for(i = 1; i < tags.length; i++) {
        var Hashtag = tags[i].split(" ")[0];

        for(i = 1; i < InvalidSymbols.length; i++){
            var symbol = InvalidSymbols[i];
            var res = Hashtag.indexOf(symbol);

            if (res > -1) {
                Hashtag = Hashtag.replace(symbol, "");
            }
        }

        if (Hashtag !== null && Hashtag !== undefined && Hashtag !== "") {
            TwtMessage = TwtMessage.replace("#"+Hashtag, "<span class='hashtag-tag-text' data-hashtag='"+Hashtag+"''>#"+Hashtag+"</span>");
        }
    }

    return TwtMessage
}

$(document).on('click', '.image', function(e){
    e.preventDefault();
    let source = $(this).attr('src')
    QB.Screen.popUp(source)
});

$(document).on('click', '.mentioned-tag', function(e){
    e.preventDefault();
    CopyMentionTag(this);
});

$(document).on('click', '.hashtag-tag-text', function(e){
    e.preventDefault();
    if (!HashtagOpen) {
        var Hashtag = $(this).data('hashtag');
        var PreviousTwitterTabObject = $('.twitter-header').find('[data-twittertab="'+CurrentTwitterTab+'"]');

        $("#twitter-hashtags").addClass('selected-twitter-header-tab');
        $(PreviousTwitterTabObject).removeClass('selected-twitter-header-tab');

        $("."+CurrentTwitterTab+"-tab").css({"display":"none"});
        $(".twitter-hashtags-tab").css({"display":"block"});

        $.post('https://qb-phone/GetHashtagMessages', JSON.stringify({hashtag: Hashtag}), function(HashtagData){
            QB.Phone.Notifications.LoadHashtagMessages(HashtagData.messages);
        });

        $(".twitter-hashtag-tweets").css({"display":"block", "left":"30vh"});
        $(".twitter-hashtag-tweets").css({"left": "0vh"});
        $(".twitter-hashtags").css({"left": "-30vh"});
        $(".twitter-hashtags").css({"display":"none"});
        HashtagOpen = true;

        CurrentTwitterTab = "twitter-hashtags";
    }
});

function CopyMentionTag(elem) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(elem).data('mentiontag')).select();
    QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", $(elem).data('mentiontag')+ " copied!", "rgb(27, 149, 224)", 1250);
    document.execCommand("copy");
    $temp.remove();
}

QB.Phone.Notifications.LoadHashtags = function(hashtags) {
    if (hashtags !== null) {
        $(".twitter-hashtags").html("");

        $.each(hashtags, function(i, hashtag){
            var Elem = '';
            var TweetHandle = "Tweet";
            if (hashtag.messages.length > 1 ) {
               TweetHandle = "Tweets";
            }
            if (hashtag.messages.length >= MinimumTrending) {
                Elem = '<div class="twitter-hashtag" id="tag-'+hashtag.hashtag+'"><div class="twitter-hashtag-status">Trending in City</div> <div class="twitter-hashtag-tag">#'+hashtag.hashtag+'</div> <div class="twitter-hashtag-messages">'+hashtag.messages.length+' '+TweetHandle+'</div> </div>';
            } else {
                Elem = '<div class="twitter-hashtag" id="tag-'+hashtag.hashtag+'"><div class="twitter-hashtag-status">Not trending in City</div> <div class="twitter-hashtag-tag">#'+hashtag.hashtag+'</div> <div class="twitter-hashtag-messages">'+hashtag.messages.length+' '+TweetHandle+'</div> </div>';
            }

            $(".twitter-hashtags").append(Elem);
            $("#tag-"+hashtag.hashtag).data('tagData', hashtag);
        });
    }
}

QB.Phone.Notifications.LoadHashtagMessages = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        $(".twitter-hashtag-tweets").html("");
        $.each(Tweets, function(i, Tweet){
            var clean = DOMPurify.sanitize(Tweet.message , {
                ALLOWED_TAGS: [],
                ALLOWED_ATTR: []
            });
            //if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
            var TwtMessage = QB.Phone.Functions.FormatTwitterMessage(clean);
            var TimeAgo = moment(Tweet.date).format('MM/DD/YYYY hh:mm');

            var TwitterHandle = Tweet.firstName + ' ' + Tweet.lastName
            var PictureUrl = "./img/default.png"
            if (Tweet.picture !== "default") {
                PictureUrl = Tweet.picture
            }

            var TweetElement =
            '<div class="twitter-tweet">'+
                '<div class="tweet-tweeter">'+Tweet.firstName+' '+Tweet.lastName+' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+' &middot; '+TimeAgo+'</span></div>'+
                '<div class="tweet-message">'+TwtMessage+'</div>'+
            '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image"></div></div>';

            $(".twitter-hashtag-tweets").append(TweetElement);
        });
    }
}


$(document).on('click', '.twitter-hashtag', function(event){
    event.preventDefault();

    var TweetId = $(this).attr('id');
    var TweetData = $("#"+TweetId).data('tagData');

    QB.Phone.Notifications.LoadHashtagMessages(TweetData.messages);

    $(".twitter-hashtag-tweets").css({"display":"block", "left":"30vh"});
    $(".twitter-hashtag-tweets").animate({
        left: 0+"vh"
    }, 150);
    $(".twitter-hashtags").animate({
        left: -30+"vh"
    }, 150, function(){
        $(".twitter-hashtags").css({"display":"none"});
    });
    HashtagOpen = true;
});
