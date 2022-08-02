let cam

$(document).ready(function(){
    $("#gopro-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".gopro-vehicle").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '.gopro-vehicle', function(e){
    e.preventDefault();

    $(this).find(".gopro-block").toggle();
    cam = $(this).data('id')
});


$(document).on('click', '.box-purchase', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $.post("https://qb-phone/gopro-viewcam", JSON.stringify({
        id: cam,
    }));
});

SetupGoPros = function(cams) {
    $(".gopro-vehicles").html("");
    if (cams != null) {
        $.each(cams, function(i, cams){
            var Element = '<div class="gopro-vehicle" id="vehicle-'+i+'"><span class="gopro-vehicle-icon"><i class="fas fa-camera-retro"></i></span> <span class="gopro-vehicle-name">'+cams.name+'</span> ' +
            '<div class="gopro-block">' +
                '<div class="gopro-name"><i class="fas fa-map-marker-alt"></i>'+cams.gopro+'</div>' +
                '<div class="gopro-fuel"><i class="fas fa-gas-pump"></i>'+JSON.stringify(cams.access)+'</div>' +
                '<div class="gopro-box"><span class="gopro-box box-purchase" data-id="'+cams.id+'">VIEW</span><span class="gopro-box box-exchange" data-id="'+cams.id+'" style="margin-left: 40%;">TRANSFER</span></div>' +
                '</div>' +
            '</div>';

            $(".gopro-vehicles").append(Element);
        });
    }
}
