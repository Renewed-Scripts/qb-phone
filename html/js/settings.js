QB.Phone.Settings = {};
QB.Phone.Settings.Background = "default-QBCore";

// Functions

QB.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        QB.Phone.Settings.Background = MetaData.background;
    } else {
        QB.Phone.Settings.Background = "default-QBCore";
    }

    var hasCustomBackground = QB.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+QB.Phone.Settings.Background+"')"});
    }
}
QB.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    if (QB.Phone.Settings.Background == 'default-QBCore'){
        retval = false;
    }
    return retval
}

// Clicks

$(document).on("click", ".settings-app-toggle", function(){
    ClearInputNew()
    $('#settings-app-menu').fadeIn(350);
})

$(document).on('click', '#settings-app-submit', function(e){
    e.preventDefault();

    var checkbox = document.getElementById("checkbox").checked;
    var customurl = $('.settings-customurl').val()

    if (checkbox != false && customurl != ''){
        QB.Phone.Notifications.Add("fas fa-cog", "SETTINGS", "You can only pick one option!")
        return
    }

    if (checkbox){
        QB.Phone.Notifications.Add("fas fa-paint-brush", "SETTINGS", "Default background set!")
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/default-qbcore.png')"})
        $.post('https://qb-phone/SetBackground', JSON.stringify({
            background: '/html/img/backgrounds/default-qbcore.png',
        }))
    }else if (customurl){
        QB.Phone.Notifications.Add("fas fa-paint-brush", "SETTINGS", "Personal background set!")
        $(".phone-background").css({"background-image":"url('"+customurl+"')"});
        $.post('https://qb-phone/SetBackground', JSON.stringify({
            background: customurl,
        }))
    }
    $('.settings-customurl').val("")
    $('#settings-app-menu').fadeOut(350);
});