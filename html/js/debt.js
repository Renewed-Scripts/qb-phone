let debt

// Search

$(document).ready(function(){
    $("#debt-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".debt-list").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

// Functions

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

// Debt Shit

// Block
$(document).on('click', '.debt-list', function(e){
    e.preventDefault();

    $(this).find(".debt-block").toggle();
    var Id = $(this).attr('id');
    debt = Id
});

// Pay All Tab
$(document).on('click', '.send-all-box', function(e){
    e.preventDefault();

    var Id = $(this).parent().parent().parent().attr('id');
    debt = Id
    setTimeout(function(){
        ConfirmationFrame()
    }, 150);
    $.post('https://qb-phone/SendAllPayment', JSON.stringify({
        id: Id,
    }));
});

// Pay Minimum
$(document).on('click', '.send-minimum-box', function(e){
    e.preventDefault();

    var Id = $(this).parent().parent().parent().attr('id');
    debt = Id
    setTimeout(function(){
        ConfirmationFrame()
    }, 150);
    $.post('https://qb-phone/SendMinimumPayment', JSON.stringify({
        id: Id,
    }));
});

function LoadDebtJob(data){
    $(".debts-list").html("");
    if(data) {
        Object.keys(data).map(function(element, index){
            if (element === 'assets'){
                $(".debts-list").append(`<h1 style="font-size: 1.6vh; padding-left: 0.8vh; padding-bottom: 0.3vh; color:#fff; margin-top:0; width:100%; display:block;">Asset Fees</h1>`);
            }else if (element === 'loan'){
                $(".debts-list").append(`<h1 style="font-size: 1.6vh; padding-left: 0.8vh; padding-bottom: 0.3vh; color:#fff; margin-top:0; width:100%; display:block;">Loan Payment</h1>`);
            }else if (element === 'fine'){
                $(".debts-list").append(`<h1 style="font-size: 1.6vh; padding-left: 0.8vh; padding-bottom: 0.3vh; color:#fff; margin-top:0; width:100%; display:block;">Bill Payments</h1>`);
            }
            Object.keys(data[element]).map(function(element2, _){
                if (element === 'assets'){
                    $(".debts-list").append('<div class="debt-list" id="'+data[element][element2].id+'"><span class="debt-icon"><i class="fas fa-car"></i></span> <span class="debt-main-title">'+data[element][element2].car+'</span> <span class="debt-main-fee">'+formatter.format(data[element][element2].totalamount)+'</span>' +
                        '<div class="debt-block">' +
                            '<div class="debt-title"><i class="fas fa-inbox"></i>'+data[element][element2].sender+'</div>' +
                            '<div class="debt-extrainfo"><i class="fas fa-closed-captioning"></i>'+data[element][element2].plate+'</div>' +
                            '<div class="debt-due"><i class="fas fa-calendar"></i>in '+data[element][element2].display+'</div>' +
                            '<div class="debt-box"><span class="debt-box send-all-box" style = "margin-left: 6.2vh;">PAY</span></div>' +
                        '</div>' +
                    '</div>');

                } else if (element === 'loan'){
                    $(".debts-list").append('<div class="debt-list" id="'+data[element][element2].id+'"><span class="debt-icon"><i class="fas fa-file-invoice-dollar"></i></span> <span class="debt-main-title">'+data[element][element2].car+'</span> <span class="debt-main-fee">'+formatter.format(data[element][element2].totalamount)+'</span>' +
                        '<div class="debt-block">' +
                            '<div class="debt-title"><i class="fas fa-inbox"></i>'+data[element][element2].sender+'</div>' +
                            '<div class="debt-extrainfo"><i class="fas fa-closed-captioning"></i>'+data[element][element2].plate+'</div>' +
                            '<div class="debt-due"><i class="fas fa-calendar"></i>in '+data[element][element2].display+'</div>' +
                            '<div class="debt-box"><span class="debt-box send-minimum-box" style = "margin-left: 0.9vh;">PAY MINIMUM</span><span class="debt-box send-all-box" style="margin-left: 1.2vh;">PAY ALL</span></div>' +
                        '</div>' +
                    '</div>');
                } else if (element === 'fine'){
                    $(".debts-list").append('<div class="debt-list" id="'+data[element][element2].id+'"><span class="debt-icon"><i class="fas fa-hand-holding-usd"></i></span> <span class="debt-main-title">'+data[element][element2].name+'</span> <span class="debt-main-fee">'+formatter.format(data[element][element2].totalamount)+'</span> <span class="debt-remaining-payments">'+data[element][element2].paybacks+"/"+data[element][element2].totalPays+'</span>' +
                        '<div class="debt-block">' +
                            '<div class="debt-title"><i class="fas fa-inbox"></i>'+data[element][element2].sender+'</div>' +
                            '<div class="debt-extrainfo"><i class="fas fa-closed-captioning"></i>'+data[element][element2].notes+'</div>' +
                            '<div class="debt-due"><i class="fas fa-calendar"></i>in '+data[element][element2].display+'</div>' +
                            '<div class="debt-box"><span class="debt-box send-minimum-box" style = "margin-left: 0.9vh;">PAY MINIMUM</span><span class="debt-box send-all-box" style="margin-left: 1.2vh;">PAY ALL</span></div>' +
                        '</div>' +
                    '</div>');
                }
                $("#debt-"+data[element][element2].id).data('debtId', element2);
            })
        })
    }
}