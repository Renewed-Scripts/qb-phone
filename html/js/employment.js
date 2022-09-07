var dropdownOpen = false
var cid = ''

// Right now only the first search bar works, then breaks when you click into a job and back out. Second page doesn't work at all. SHIT DEV
$(document).ready(function(){
    $("#employment-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".employment-list").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).ready(function(){
    $("#employment-job-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".employment-job-list").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
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

function LoadEmploymentApp(data){
    var jobs = data;
    $(".employment-lists").html("");
    for (const [k, v] of Object.entries(jobs)) {
        console.log(k)
        console.log(JSON.stringify(v))
        console.log(v.grade)
        console.log(JSON.stringify(QB.Phone.Data.PhoneJobs))
        var AddOption = '<div class="employment-list" data-job="'+k+'" data-grade="'+v.grade+'"><span class="employment-icon"><i class="fas fa-business-time"></i></span> <span class="employment-label">'+QB.Phone.Data.PhoneJobs[k].label+'</span> <span class="employment-grade">'+QB.Phone.Data.PhoneJobs[k].grades[v.grade].name+'</span>' +
        '</div>';

        $('.employment-lists').append(AddOption);
    }
};

function changePage(){
    $(".employment-header").html("");

    // Sets back to original header
    var HeaderOption = '<span id="employment-search-text">Search</span>'+
    '<i class="fas fa-search" id="employment-search-icon"></i>'+
    '<input type="text" id="employment-search" placeholder="" spellcheck="false">'

    $('.employment-header').append(HeaderOption); // Creates the original header
    // Load Home Page
    $.post('https://qb-phone/GetJobs', JSON.stringify({}), function(data){
        LoadEmploymentApp(data)
    });
}

$(document).on('click', '.employment-list', function(e){
    e.preventDefault();
    var job = $(this).data('job'); // Job Name
    var grade = $(this).data('grade'); // Job Grade Level
    $(".employment-lists").html(""); // Resets the old screen

    // Fade out the old header to create the new header
    $(".employment-header").html("");

    $.post('https://qb-phone/GetEmployees', JSON.stringify({job: job}), function(data){
        for (const [k, v] of Object.entries(data)) {
            // Option for creating the list of players having that job listed above
            var AddOption = '<div class="employment-job-list" data-csn='+v.cid+' data-job='+job+'><span class="employment-job-icon"><i class="fas fa-user-secret"></i></span>' +
            '<span class="employment-label">'+v.name+'</span> <span class="employment-grade">'+QB.Phone.Data.PhoneJobs[job].grades[v.grade].name+'</span>'+
            '<div class="employment-action-buttons">' +
                '<i class="fas fa-hand-holding-usd" id="employment-pay-employee" data-toggle="tooltip" title="Pay"></i>' +
                '<i class="fas fa-user-alt-slash" id="employment-remove-employee" data-toggle="tooltip" title="Remove Employee"></i>' +
                '<i class="fas fa-university" id="employment-bank-access" data-toggle="tooltip" title="Bank Access"></i>' +
            '</div></div>';

            $('.employment-lists').append(AddOption); // Creates the new screen
        }
    });

    // Creates the new header
    var HeaderOption = '<span id="employment-job-search-text">Search</span>' +
    '<i class="fas fa-chevron-left" id="employment-job-back-icon"></i>' +
    '<i class="fas fa-search" id="employment-job-search-icon"></i>' +
    '<i class="fas fa-ellipsis-v" id="employment-job-extras-icon"></i>' +
    '<input type="text" id="employment-job-search" placeholder="" spellcheck="false">'

    $('.employment-header').append(HeaderOption); // Creates the new header
});

$(document).on('click', '#employment-job-back-icon', function(e){
    e.preventDefault();
    changePage()
});

$(document).on('click', '#employment-job-extras-icon', function(e){
    e.preventDefault();
    dropdownOpen = true
    $('#employment-dropdown').fadeIn(350);
    // Gonna work on the dropdown menu here later
});

// Main Employee Buttons

$(document).on('click', '#employment-pay-employee', function(e){
    e.preventDefault();
    cid = $(this).parent().parent().data('csn');
    job = $(this).parent().parent().data('job');
    $('#pay-employee-menu').fadeIn(350);
});

$(document).on('click', '#send-employee-payment', function(e){
    var amount = $(".pay-employee-amount").val();
    if(amount != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post('https://qb-phone/SendEmployeePayment', JSON.stringify({
            cid: cid,
            job: job,
            amount: amount,
        }));
    }
    ClearInputNew()
    $('#pay-employee-menu').fadeOut(350);
    $(".pay-employee-amount").val(''); // Resets amount input
});

$(document).on('click', '#employment-remove-employee', function(e){
    e.preventDefault();
    cid = $(this).parent().parent().data('csn');
    job = $(this).parent().parent().data('job');
    setTimeout(function(){
        ConfirmationFrame()
    }, 150);
    $.post('https://qb-phone/RemoveEmployee', JSON.stringify({
        cid: cid,
        job: job,
    }));
});

$(document).on('click', '#employment-bank-access', function(e){
    e.preventDefault();
    cid = $(this).parent().parent().data('csn');
    setTimeout(function(){
        ConfirmationFrame()
    }, 150);
    $.post('https://qb-phone/GiveBankAccess', JSON.stringify({
        cid: cid,
    }));
});