let veh

$(document).ready(function(){
    $("#garage-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".garage-vehicle").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '.garage-vehicle', function(e){
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 30+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: 0+"vh"
    }, 200);
    $("#garage-search").fadeOut(150);
    $("#garage-search-icon").fadeOut(150);
    $("#whatsapp-search-text").fadeOut(150);

    var Id = $(this).attr('id');
    var VehData = $("#"+Id).data('VehicleData');
    veh = VehData
    SetupDetails(VehData);
});


$(document).on('click', '#track-vehicle', function(e){
    e.preventDefault()
    $.post("https://qb-phone/gps-vehicle-garage", JSON.stringify({
        veh: veh,
    }));
});


$(document).on('click', '#return-button', function(e){
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 00+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: -30+"vh"
    }, 200);
    $("#garage-search").fadeIn(150);
    $("#garage-search-icon").fadeIn(150);
    $("#whatsapp-search-text").fadeIn(150);
});

SetupGarageVehicles = function(Vehicles) {
    $(".garage-vehicles").html("");
    if (Vehicles != null) {
        $.each(Vehicles, function(i, vehicle){
            var Element = '<div class="garage-vehicle" id="vehicle-'+i+'"><span class="garage-vehicle-icon"><i class="fas fa-car"></i></span> <span class="garage-vehicle-name">'+vehicle.fullname+'</span> <span class="garage-plate-name">'+vehicle.plate+'</span> <span class="garage-state-name">'+vehicle.state+'</span> </div>';

            $(".garage-vehicles").append(Element);
            $("#vehicle-"+i).data('VehicleData', vehicle);
        });
    }
}

SetupDetails = function(data) {
    $(".vehicle-brand").find(".vehicle-answer").html(data.brand);
    $(".vehicle-model").find(".vehicle-answer").html(data.model);
    $(".vehicle-plate").find(".vehicle-answer").html(data.plate);
    $(".vehicle-garage").find(".vehicle-answer").html(data.garage);
    $(".vehicle-status").find(".vehicle-answer").html(data.state);
    $(".vehicle-fuel").find(".vehicle-answer").html(Math.ceil(data.fuel)+"%");
    $(".vehicle-engine").find(".vehicle-answer").html(Math.ceil(data.engine / 10)+"%");
    $(".vehicle-body").find(".vehicle-answer").html(Math.ceil(data.body / 10)+"%");
}