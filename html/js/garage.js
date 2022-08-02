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

    $(this).find(".garage-block").toggle();
    var Id = $(this).attr('id');
    var VehData = $("#"+Id).data('VehicleData');
    veh = VehData
});


$(document).on('click', '.box-track', function(e){
    e.preventDefault()
    $.post("https://qb-phone/gps-vehicle-garage", JSON.stringify({
        veh: veh,
    }));
});

SetupGarageVehicles = function(Vehicles) {
    $(".garage-vehicles").html("");
    if (Vehicles != null) {
        $.each(Vehicles, function(i, vehicle){
            var Element = '<div class="garage-vehicle" id="vehicle-'+i+'"><span class="garage-vehicle-icon"><i class="fas fa-car"></i></span> <span class="garage-vehicle-name">'+vehicle.fullname+'</span> <span class="garage-plate-name">'+vehicle.plate+'</span> <span class="garage-state-name">'+vehicle.state+'</span>' +
            '<div class="garage-block">' +
                '<div class="garage-name"><i class="fas fa-map-marker-alt"></i>'+vehicle.garage+'</div>' +
                '<div class="garage-plate"><i class="fas fa-closed-captioning"></i>'+vehicle.plate+'</div>' +
                '<div class="garage-fuel"><i class="fas fa-gas-pump"></i>'+vehicle.fuel+'</div>' +
                '<div class="garage-payments"><i class="fas fa-hand-holding-usd"></i>'+vehicle.paymentsleft+' Payments Left</div>' +
                '<div class="garage-box"><span class="garage-box box-track">TRACK</span></div>' +
            '</div>' +
            '</div>';

            $(".garage-vehicles").append(Element);
            $("#vehicle-"+i).data('VehicleData', vehicle);
        });
    }
}