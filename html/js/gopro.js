let cam

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

SetupGoPros = function(cams) {
    $(".gopro-lists").html("");
    if (JSON.stringify(cams) != "[]"){
        $.each(cams, function(i, cams){
            var Element = '<div class="gopro-list" id="vehicle-'+i+'"> <div class="gopro-list-icon"><i class="fas fa-camera"></i></div> <div class="gopro-list-name">'+cams.name+'</div> <div class="gopro-action-buttons"> <i class="fas fa-eye" id="gopro-view-camera" data-id="'+cams.id+'" data-toggle="tooltip" title="View"></i> <i class="fas fa-thumbtack" id="gopro-track-camera" data-id="'+cams.id+'" data-toggle="tooltip" title="Track"></i> <i class="fas fa-user-plus" id="gopro-addto-camera" data-id="'+cams.id+'" data-toggle="tooltip" title="Add Someone"></i>  </div></div>';
            $(".gopro-lists").append(Element);
        });
    }else{
        $(".gopro-lists").html('<p class="nomails">Nothing Here! <i class="fas fa-frown" id="mail-frown"></i></p>');
    }
}

// Search Bar Filter

$(document).ready(function(){
    $("#gopro-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".gopro-list").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

// On Clicks

$(document).on('click', '#gopro-view-camera', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $.post("https://qb-phone/gopro-viewcam", JSON.stringify({
        id: cam,
    }));
});

$(document).on('click', '#gopro-track-camera', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $.post("https://qb-phone/gopro-track", JSON.stringify({
        id: cam,
    }));
});

$(document).on('click', '#gopro-addto-camera', function(e){
    e.preventDefault();
    ClearInputNew()
    cam = $(this).data('id')
    $('#gopro-access-menu').fadeIn(350);
});

$(document).on('click', '#gopro-send-access', function(e){
    e.preventDefault();
    var stateid = $(".gopro-stateid-access").val();
    if(stateid != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post("https://qb-phone/gopro-transfer", JSON.stringify({
            id: cam,
            stateid: stateid,
        }));
    }
    ClearInputNew()
    $('#gopro-access-menu').fadeOut(350);
});
