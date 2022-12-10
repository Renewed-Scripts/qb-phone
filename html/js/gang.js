var dropdownOpen = false
var cid = ''
var job = ''
var grade = ''

var onDuty = true
var currentJob = ''

// Hiring & Changing Role var
var gradeLevel = ''

function ConfirmationFrameGang() {
    $('.spinner-input-frame').css("display", "flex");
    setTimeout(function () {
        $('.spinner-input-frame').css("display", "none");
        $('.checkmark-input-frame').css("display", "flex");
        setTimeout(function () {
            $('.checkmark-input-frame').css("display", "none");
        }, 2000)
    }, 1000)
    QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        QB.Phone.Functions.HeaderTextColor("white", 300);
        QB.Phone.Data.currentApplication = null;
}

function LoadGangApp(){
    gang = QB.Phone.Data.gang.name; // Job Name
    grade = QB.Phone.Data.PhoneGangs; // Job Grade Level
    $(".gang-lists").html(""); // Resets the old screen
    $(".gang-grade-dropdown-menu").html("");

    // Fade out the old header to create the new header
    $(".gang-header").html("");

    $.post('https://qb-phone/GetGangMembers', JSON.stringify({gang: gang}), function(data){

        for (const [k, v] of Object.entries(data)) {
            var icon
            icon = "fas fa-user"
            if (QB.Phone.Data.gang.isboss){
                var AddOption = '<div class="gang-job-list" data-csn='+v.empSource+' data-job='+gang+'><span class="gang-job-icon"><i class="'+icon+'"></i></span>' +
                '<span class="gang-label">'+v.name+'</span> <span class="gang-grade">'+v.gradeName+'</span>'+
                '<div class="gang-action-buttons">' +
                    '<i class="fas fa-user-alt-slash" id="gang-remove-gangmember" data-toggle="tooltip" title="Kick gangmember"></i>' +
                    '<i class="fas fa-users" id="gang-changerole" data-toggle="tooltip" title="Change Role"></i>' +
                '</div></div>';
            }else{
                var AddOption = '<div class="gang-job-list" data-csn='+v.cid+' data-job='+v.gang+'><span class="gang-job-icon"><i class="'+icon+'"></i></span>' +
                '<span class="gang-label">'+v.name+'</span> <span class="gang-grade">'+v.gradeName+'</span></div>';
            }
            $('.gang-lists').append(AddOption); // Creates the new screen
        }

        // Drop Down Data
        for (const [k, v] of Object.entries(QB.Phone.Data.PhoneGangs[gang].grades)) {
            var element = '<li data-gradelevel="'+k+'">'+v.name+'</li>';
            $(".gang-grade-dropdown-menu").append(element);
        }
    });

    // Creates the new header
    var HeaderOption = '<i class="gang-header-text">'+QB.Phone.Data.gang.label+'</i>'+
    '<i class="fas fa-ellipsis-v" id="gang-job-extras-icon"></i>'


    $('.gang-header').append(HeaderOption); // Creates the new header
};

function changePage(){
    $(".gang-header").html("");

    // Sets back to original header
    var HeaderOption = '<span id="gang-search-text">Search</span>'+
    '<i class="fas fa-search" id="gang-search-icon"></i>'+
    '<input type="text" id="gang-search" placeholder="" spellcheck="false">'

    $('.gang-header').append(HeaderOption); // Creates the original header
    // Load Home Page
    $.post('https://qb-phone/GetGang', JSON.stringify({}), function(data){
        LoadGangApp(data)
    });
}

$(document).on('click', '.gang-list', function(e){
    e.preventDefault();
    gang = QB.Phone.Data.gang.name; // Job Name
    grade = QB.Phone.Data.PhoneGangs; // Job Grade Level
    $(".gang-lists").html(""); // Resets the old screen
    $(".gang-grade-dropdown-menu").html("");

    // Fade out the old header to create the new header
    $(".gang-header").html("");

    $.post('https://qb-phone/GetGangMembers', JSON.stringify({gang: gang}), function(data){
        for (const [k, v] of Object.entries(data)) {
            var icon
            if (QB.Phone.Data.gang.isboss){
                icon = "fas fa-user"
                var AddOption = '<div class="gang-job-list" data-csn='+v.cid+' data-job='+gang+'><span class="gang-job-icon"><i class="'+icon+'"></i></span>' +
                '<span class="gang-label">'+v.name+'</span> <span class="gang-grade">'+v.grade+'</span>'+
                '<div class="gang-action-buttons">' +
                    '<i class="fas fa-user-alt-slash" id="gang-remove-gangmember" data-toggle="tooltip" title="Kick gangmember"></i>' +
                    '<i class="fas fa-users" id="gang-changerole" data-toggle="tooltip" title="Change Role"></i>' +
                '</div></div>';
            }else{
                var AddOption = '<div class="gang-job-list" data-csn='+v.cid+' data-job='+v.gangLabel+'><span class="gang-job-icon"><i class="'+icon+'"></i></span>' +
                '<span class="gang-label">'+v.name+'</span> <span class="gang-grade">'+v.grade+'</span></div>';
            }
            $('.gang-lists').append(AddOption); // Creates the new screen
        }

        // Drop Down Data
        for (const [k, v] of Object.entries(QB.Phone.Data.PhoneGangs[gang].grades)) {
            var element = '<li data-gradelevel="'+k+'">'+v.name+'</li>';
            $(".gang-grade-dropdown-menu").append(element);
        }
    });

    // Creates the new header
    var HeaderOption = '<i class="fas fa-ellipsis-v" id="gang-job-extras-icon"></i>' +

    $('.gang-header').append(HeaderOption); // Creates the new header
});

$(document).on('click', '#gang-job-extras-icon', function(e){
    e.preventDefault();
    $('#gang-dropdown').html('')
    dropdownOpen = true

    if (QB.Phone.Data.gang.isboss){
            var AddOption = `<div class="list-content" id='hire-gangMember' ><i class="fas fa-user-plus"></i>Hire</div>`
    }else{
    }
    $('#gang-dropdown').append(AddOption);
    $('#gang-dropdown').fadeIn(350);
});

// Drop Down Menu Options

function closeDropDown(){
    dropdownOpen = false
    $('.phone-dropdown-menu').fadeOut(350);
}

$(document).on('click', '#hire-gangMember', function(e){
    e.preventDefault();
    $('#hire-gang-menu').fadeIn(350);
    closeDropDown()
});

$(document).on('click', '#hire-gang-submit', function(e){
    var stateid = $(".hire-gang-stateid").val();
    var grade = gradeLevel
    if(stateid != "" && grade != ""){
        setTimeout(function(){
            ConfirmationFrameGang()
        }, 150);
        $.post('https://qb-phone/HireGangMember', JSON.stringify({
            stateid: stateid,
            grade: grade,
            gang: gang,
        }));
    }
    ClearInputNew()
    $('#hire-gang-menu').fadeOut(350);
    $(".hire-gang-stateid").val(''); // Resets amount input
});
// Main gangmember Buttons

$(document).on('click', '#gang-remove-gangmember', function(e){
    e.preventDefault();
    cid = $(this).parent().parent().data('csn');
    setTimeout(function(){
        ConfirmationFrameGang()
    }, 150);
    $.post('https://qb-phone/Removegangmember', JSON.stringify({
        cid: cid,
    }));
});

$(document).on('click', '#gang-changerole', function(e){
    e.preventDefault();
    cid = $(this).parent().parent().data('csn');
    $('#gang-changerole-menu').fadeIn(350);
});

$(document).on('click', '#gang-changerole-submit', function(e){
    var grade = gradeLevel
    // TODO: Fix grade >= 0
    if(grade != ""){
        setTimeout(function(){
            ConfirmationFrameGang()
        }, 150);
        $.post('https://qb-phone/ChangeGangRole', JSON.stringify({
            cid: cid,
            grade: grade,
            gang: QB.Phone.Data.gang.name
        }));
    }
    ClearInputNew()
    $('#gang-changerole-menu').fadeOut(350);
});

/* Dropdown Menu */

$('.gang-grade-dropdown').click(function () {
    $(this).attr('tabindex', 1).focus();
    $(this).toggleClass('active');
    $(this).find('.gang-grade-dropdown-menu').slideToggle(300);
});

$('.gang-grade-dropdown').focusout(function () {
    $(this).removeClass('active');
    $(this).find('.gang-grade-dropdown-menu').slideUp(300);
});

$(document).on('click', '.gang-grade-dropdown .gang-grade-dropdown-menu li', function(e) {
    gradeLevel = $(this).data('gradelevel')

    $(this).parents('.gang-grade-dropdown').find('span').text($(this).text());
    $(this).parents('.gang-grade-dropdown').find('input').attr('value', $(this).data('gradelevel'));
});