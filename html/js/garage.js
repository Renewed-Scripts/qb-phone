let veh
let plate

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

$(document).on('click', '.box-sellvehicle', function(e){
    e.preventDefault()
    plate = $(this).parent().attr('id');
    $('#garage-sellvehicle-menu').fadeIn(350);
});

$(document).on('click', '#garage-sellvehicle', function(e){
    e.preventDefault();
    var stateid = $(".garage-sellvehicle-stateid").val();
    var price = $(".garage-sellvehicle-price").val();
    if(price != "" && stateid != ""){
        $.post("https://qb-phone/sellVehicle", JSON.stringify({
            plate: plate,
            id: stateid,
            price: price
        }));
    }
    ClearInputNew()
    $('#garage-sellvehicle-menu').fadeOut(350);
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
                '<div class="garage-engine"><i class="fas fa-oil-can"></i>'+vehicle.engine + " %"+'</div>' +
                '<div class="garage-body"><i class="fas fa-car-crash"></i>'+vehicle.body+ " %"+'</div>' +
                '<div class="garage-payments"><i class="fas fa-hand-holding-usd"></i>'+vehicle.paymentsleft+' Payments Left</div>' +
                '<div class="garage-box" id="'+vehicle.plate+'"><span class="garage-box box-track" style="margin-left: 3.0vh;">TRACK</span><span class="garage-box box-sellvehicle" style = "margin-left: 1.1vh;">SELL</span></div>' +
            '</div>' +
            '</div>';

            $(".garage-vehicles").append(Element);
            $("#vehicle-"+i).data('VehicleData', vehicle);
        });
    }
}