var dropdownOpen = false
var cid = ''
var job = ''
var grade = ''

var onDuty = true
var currentJob = ''

// Hiring & Changing Role var
var gradeLevel = ''

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
    job = $(this).data('job'); // Job Name
    grade = $(this).data('grade'); // Job Grade Level
    $(".employment-lists").html(""); // Resets the old screen
    $(".grade-dropdown-menu").html("");

    // Fade out the old header to create the new header
    $(".employment-header").html("");

    $.post('https://qb-phone/GetEmployees', JSON.stringify({job: job}), function(data){
        for (const [k, v] of Object.entries(data)) {
            var icon

            if (QB.Phone.Data.PhoneJobs[job].grades[v.grade].isboss) {
                icon = "fas fa-user-secret"
            } else {
                icon = "fas fa-user"
            }

            if (QB.Phone.Data.PhoneJobs[job].grades[grade].isboss){
                var AddOption = '<div class="employment-job-list" data-csn='+v.cid+' data-job='+job+'><span class="employment-job-icon"><i class="'+icon+'"></i></span>' +
                '<span class="employment-label">'+v.name+'</span> <span class="employment-grade">'+QB.Phone.Data.PhoneJobs[job].grades[v.grade].name+'</span>'+
                '<div class="employment-action-buttons">' +
                    '<i class="fas fa-hand-holding-usd" id="employment-pay-employee" data-toggle="tooltip" title="Pay"></i>' +
                    '<i class="fas fa-user-alt-slash" id="employment-remove-employee" data-toggle="tooltip" title="Remove Employee"></i>' +
                    '<i class="fas fa-users" id="employment-changerole" data-toggle="tooltip" title="Change Role"></i>' +
                '</div></div>';
            }else{
                var AddOption = '<div class="employment-job-list" data-csn='+v.cid+' data-job='+job+'><span class="employment-job-icon"><i class="'+icon+'"></i></span>' +
                '<span class="employment-label">'+v.name+'</span> <span class="employment-grade">'+QB.Phone.Data.PhoneJobs[job].grades[v.grade].name+'</span></div>';
            }
            $('.employment-lists').append(AddOption); // Creates the new screen
        }

        // Drop Down Data

        for (const [k, v] of Object.entries(QB.Phone.Data.PhoneJobs[job].grades)) {

            var element = '<li data-gradelevel="'+k+'">'+v.name+'</li>';
            $(".grade-dropdown-menu").append(element);
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
    $('#employment-dropdown').html('')
    dropdownOpen = true

    $.post('https://qb-phone/dutyStatus', JSON.stringify({}), function(data) {
        currentJob = data["job"]
        if (data["duty"]) {
            onDuty = true
        } else {
            onDuty = false
        }
    });

    if (QB.Phone.Data.PhoneJobs[job].grades[grade].isboss){
        if (onDuty && currentJob == job) {
            var AddOption = `<div class="list-content" id='clock-in' ><i class="fas fa-clock"></i>Go Off Duty</div>
            <div class="list-content" id='hire-fucker' ><i class="fas fa-user-plus"></i>Hire</div>
            <div class="list-content" id='charge-mf'><i class="fas fa-credit-card"></i>Charge Customer</div>`
        } else {
            var AddOption = `<div class="list-content" id='clock-in' ><i class="fas fa-clock"></i>Go On Duty</div>
            <div class="list-content" id='hire-fucker' ><i class="fas fa-user-plus"></i>Hire</div>
            <div class="list-content" id='charge-mf'><i class="fas fa-credit-card"></i>Charge Customer</div>`
        }
    }else{
        if (onDuty && currentJob == job) {
            var AddOption = `<div class="list-content" id='clock-in' ><i class="fas fa-clock"></i>Go Off Duty</div>
            <div class="list-content" id='charge-mf'><i class="fas fa-credit-card"></i>Charge Customer</div>`
        } else {
            var AddOption = `<div class="list-content" id='clock-in' ><i class="fas fa-clock"></i>Go On Duty</div>
            <div class="list-content" id='charge-mf'><i class="fas fa-credit-card"></i>Charge Customer</div>`
        }
    }
    $('#employment-dropdown').append(AddOption);
    $('#employment-dropdown').fadeIn(350);
});

// Drop Down Menu Options

function closeDropDown(){
    dropdownOpen = false
    $('.phone-dropdown-menu').fadeOut(350);
}

$(document).on('click', '#clock-in', function(e){
    e.preventDefault();

    $.post('https://qb-phone/ClockIn', JSON.stringify({
        job: job
    }));
    closeDropDown()
});

$(document).on('click', '#hire-fucker', function(e){
    e.preventDefault();
    console.log(job)
    $('#hire-worker-menu').fadeIn(350);
    closeDropDown()
});

$(document).on('click', '#hire-worker-submit', function(e){
    var stateid = $(".hire-worker-stateid").val();
    var grade = gradeLevel
    if(stateid != "" && grade != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post('https://qb-phone/HireFucker', JSON.stringify({
            stateid: stateid,
            grade: grade,
            job: job,
        }));
    }
    ClearInputNew()
    $('#hire-worker-menu').fadeOut(350);
    $(".hire-worker-stateid").val(''); // Resets amount input
});

$(document).on('click', '#charge-mf', function(e){
    e.preventDefault();
    console.log(job)
    $('#employment-chargemf-menu').fadeIn(350);
    closeDropDown()
});

$(document).on('click', '#employment-chargemf-submit', function(e){
    var stateid = $(".employment-chargemf-stateid").val();
    var amount = $(".employment-chargemf-amount").val();
    var note = $(".employment-chargemf-note").val();
    if(stateid != "" && amount != "" && note != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post('https://qb-phone/ChargeMF', JSON.stringify({
            stateid: stateid,
            amount: amount,
            note: note,
            job: job,
        }));
    }
    ClearInputNew()
    $('#employment-chargemf-menu').fadeOut(350);
    $(".employment-chargemf-stateid").val(''); // Resets input
    $(".employment-chargemf-amount").val(''); // Resets input
    $(".employment-chargemf-note").val(''); // Resets input
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
    var note = $(".pay-employee-note").val();
    if(amount != "" && note != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post('https://qb-phone/SendEmployeePayment', JSON.stringify({
            cid: cid,
            job: job,
            amount: amount,
            note: note,
        }));
    }
    ClearInputNew()
    $('#pay-employee-menu').fadeOut(350);
    $(".pay-employee-amount").val(''); // Resets amount input
    $(".pay-employee-note").val(''); // Resets amount input
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

$(document).on('click', '#employment-changerole', function(e){
    e.preventDefault();
    cid = $(this).parent().parent().data('csn');
    $('#employment-changerole-menu').fadeIn(350);
});

$(document).on('click', '#employment-changerole-submit', function(e){
    var grade = gradeLevel
    if(grade != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post('https://qb-phone/ChangeRole', JSON.stringify({
            cid: cid,
            grade: grade,
            job: job
        }));
    }
    ClearInputNew()
    $('#employment-changerole-menu').fadeOut(350);
});

/* Dropdown Menu */

$('.grade-dropdown').click(function () {
    $(this).attr('tabindex', 1).focus();
    $(this).toggleClass('active');
    $(this).find('.grade-dropdown-menu').slideToggle(300);
});

$('.grade-dropdown').focusout(function () {
    $(this).removeClass('active');
    $(this).find('.grade-dropdown-menu').slideUp(300);
});

$(document).on('click', '.grade-dropdown .grade-dropdown-menu li', function(e) {
    console.log($(this).data('gradelevel'))
    gradeLevel = $(this).data('gradelevel')

    $(this).parents('.grade-dropdown').find('span').text($(this).text());
    $(this).parents('.grade-dropdown').find('input').attr('value', $(this).data('gradelevel'));
});