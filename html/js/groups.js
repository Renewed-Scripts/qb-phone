var JoinPass = null;
var JoinID = null;

function LoadJobCenterApp(){
    $.post('https://qb-phone/GetGroupsApp', JSON.stringify({}), function(data){
        AddDIV(data)
    });
}

$(document).on('click', '.jobcenter-btn-create-group', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#jobcenter-box-new-dashboard').fadeIn(350);
});

$(document).on('click', '#jobcenter-submit-create-group', function(e){
    e.preventDefault();
    var Name = $(".jobcenter-input-group-name").val();
    var pass = $(".jobcenter-input-password").val();
    var pass2 = $(".jobcenter-input-password2").val();
    if (Name != "" && pass != "" && pass2 != ""){
        if(pass == pass2){
            $.post('https://qb-phone/jobcenter_CreateJobGroup', JSON.stringify({
                name: Name,
                pass: pass,
            }));




            $('#jobcenter-box-new-dashboard').fadeOut(350);
        }else{
            QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", "The password entered is incorrect")
        }
    }else{
        QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", "Fields are incorrect")
    }
});

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "refreshApp":
                $(".jobcenter-list").css({"display": "inline"});
                $(".jobcenter-btn-create-group").css({"display": "inline"});
                $(".jobcenter-text-header").css({"display": "block"});
                $(".jobcenter-Groupjob").css({"margin-top": "47%"});
                clearInterval(Interval);
                tens = "00";
                seconds = "00";
                minutes = "00";
                appendTens.innerHTML = tens;
                appendSeconds.innerHTML = seconds;
                appendminutes.innerHTML = minutes;
                $(".jobcenter-groupjob-timer").css({"display": "none"});
            AddDIV(event.data.data)
            break;
            case "addGroupStage":
                AddGroupJobs(event.data.status)
            break;
        }
    })
});

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "GroupAddDIV":
                if(event.data.showPage && event.data.job != "WAITING"){
                    AddGroupJobs(event.data.stage)
                } else {
                    AddDIV(event.data.data)
                }
            break;
        }
    })
});

function AddDIV(data){
    var AddOption;
    var CSN = QB.Phone.Data.PlayerData.source;
    $(".jobcenter-list").html("");
    if(data) {
        Object.keys(data).map(function(element,index){
            if(data[element].leader == CSN) {
                AddOption = `
                <div class="jobcenter-div-job-group">
                <div class="jobcenter-div-job-group-image">
                <i class="fas fa-users"></i>
                </div><div class="jobcenter-div-job-group-body-main">
                ${data[element].GName}<i id="jobcenter-block-grouped"
                data-id="${data[element].id}"
                data-pass="${data[element].GPass}"
                class="fas fa-sign-in-alt">
                </i>
                <div class="jobcenter-option-class-body">
                <i id="jobcenter-list-group" data-id="${data[element].id}" style="padding-right: 5%;" class="fas fa-list-ul"></i>
                <i id="jobcenter-delete-group" data-delete="${data[element].id}" class="fas fa-trash-alt"></i>
                <i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends"> ${data[element].Users}</i></div></div></div>
                `
            } else {
                AddOption = `
                <div class="jobcenter-div-job-group">
                <div class="jobcenter-div-job-group-image">
                <i class="fas fa-users"></i></div>
                <div class="jobcenter-div-job-group-body-main">${data[element].GName}<i id="jobcenter-join-grouped" data-id="${data[element].id}" data-pass="${data[element].GPass}" class="fas fa-sign-in-alt">
                </i><div class="jobcenter-option-class-body">
                <i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends">${data[element].Users}</i>
                </div></div></div>
                `
                Object.keys(data[element].members).map(function(element2, _){
                    if(data[element].members[element2].Player == CSN) {
                        AddOption = `
                        <div class="jobcenter-div-job-group">
                        <div class="jobcenter-div-job-group-image">
                        <i class="fas fa-users"></i>
                        </div><div class="jobcenter-div-job-group-body-main">
                        ${data[element].GName}<i id="jobcenter-leave-grouped"
                        data-id="${data[element].id}" 
                        data-pass="${data[element].GPass}" 
                        class="fas fa-sign-out-alt" style="transform: rotate(180deg);">
                        </i>
                        <div class="jobcenter-option-class-body">
                        <i id="jobcenter-list-group" data-id="${data[element].id}" style="padding-right: 5%;" class="fas fa-list-ul"></i>
                        <i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends">${data[element].Users}</i></div></div></div>
                        `
                    }
                })
            }
            $('.jobcenter-list').append(AddOption);
        })
    } else {
        $(".jobcenter-list").html("");
        var AddOption = '<div class="casino-text-clear">No Group</div>'
        $('.jobcenter-list').append(AddOption);
    }
}

function AddGroupJobs(data){
    var AddOption;
    $(".jobcenter-Groupjob").html("");
    $(".jobcenter-Groupjob").css({"margin-top": "23%"});
    $(".jobcenter-list").html("");
    $(".jobcenter-list").css({"display": "none"});
    $(".jobcenter-btn-create-group").css({"display": "none"});
    $(".jobcenter-text-header").css({"display": "none"});
    $(".jobcenter-groupjob-timer").css({"display": "block"});
    clearInterval(Interval);
    Interval = setInterval(startTimer, 10);
    if(data) {


        for (const [k, v] of Object.entries(data)) {
            if (v.isDone) {
                AddOption =
                `
                <div class="jobcenter-div-active-stagee isDone">
                    <p class="jobcenter-job-value"> 1 / 1</p>
                    <i style="margin-bottom:15px; class="jobcenter-div-active-stage${v.id}">${v.name}</i>
                </div>
                `
            } else {
                AddOption =
                `
                <div class="jobcenter-div-active-stagee">
                    <p class="jobcenter-job-value"> 0 / 1 </p>
                    <i style="margin-bottom:15px;" class="jobcenter-div-active-stage${v.id}">${v.name}</i>
                </div>
                `
            }
            $('.jobcenter-Groupjob').append(AddOption);
        }
    } else {
        $(".jobcenter-list").css({"display": "block"});
        $(".jobcenter-btn-create-group").css({"display": "block"});
        $(".jobcenter-text-header").css({"display": "block"});
    }
}

$(document).on('click', '#jobcenter-delete-group', function(e){
    e.preventDefault();
    var Delete = $(this).data('delete')
    $.post('https://qb-phone/jobcenter_DeleteGroup', JSON.stringify({
        delete: Delete,
    }));
});

$(document).on('click', '#jobcenter-join-grouped', function(e){
    e.preventDefault();
    JoinPass = $(this).data('pass')
    JoinID = $(this).data('id')
    ClearInputNew()
    $('#jobcenter-box-new-join').fadeIn(350);
});

$(document).on('click', '#jobcenter-submit-join-group', function(e){
    e.preventDefault();
    var EnterPass = $(".jobcenter-input-join-password").val();
    if(EnterPass == JoinPass){
        var CSN = QB.Phone.Data.PlayerData.citizenid;
        $.post('https://qb-phone/jobcenter_JoinTheGroup', JSON.stringify({
            PCSN: CSN,
            id: JoinID,
        }));
        ClearInputNew()
        $('#jobcenter-box-new-join').fadeOut(350);
    }
});

$(document).on('click', '#jobcenter-list-group', function(e){
    e.preventDefault();
    var id = $(this).data('id')
    $.post('https://qb-phone/jobcenter_CheckPlayerNames', JSON.stringify({
        id: id,
        }), function(Data){
           ClearInputNew()
           $('#jobcenter-box-new-player-name').fadeIn(350);
           $("#phone-new-box-main-playername").html("");
            for (const [k, v] of Object.entries(Data)) {
                var AddOption = `<div style=" margin-top: 10px; height: 6vh; font-size: 2vh; border-bottom: 1px white solid; background: #2c465f;" class="casino-text-clear icon"><div style="position: absolute;"><i class="fas fa-user" style="font-size: 4.2vh; margin-left: 15px; margin-top: 10px;"></i></div class="jobcenter-playerlist-name" style="color: black;"><div class="jobcenter-playerlist-name">${v}</div></div>`

                $('#phone-new-box-main-playername').append(AddOption);
            }

           var AddOption2 = '<p> </p>'

           $('#phone-new-box-main-playername').append(AddOption2);
    });
});

$(document).on('click', '#jobcenter-leave-grouped', function(e){
    e.preventDefault();
    var CSN = QB.Phone.Data.PlayerData.citizenid;
    var id = $(this).data('id')
    $.post('https://qb-phone/jobcenter_leave_grouped', JSON.stringify({
        id: id,
        csn: CSN,
    }));
});

var minutes = 00; 
var seconds = 00; 
var tens = 00; 
var appendTens = document.getElementById("tens")
var appendSeconds = document.getElementById("seconds")
var appendminutes = document.getElementById("minutes")
var buttonStart = document.getElementById('button-start');
var buttonStop = document.getElementById('button-stop');
var buttonReset = document.getElementById('button-reset');
var Interval ;

function startTimer () {
    tens++; 
    
    if(tens <= 9){
      appendTens.innerHTML = "0" + tens;
    }
    
    if (tens > 9){
      appendTens.innerHTML = tens;
      
    } 
    
    if (tens > 99) {
      seconds++;
      appendSeconds.innerHTML = "0" + seconds;
      tens = 0;
      appendTens.innerHTML = "0" + 0;
    }
    
    if (seconds > 9){
      appendSeconds.innerHTML = seconds;
    }
    
    if (seconds > 60){
        minutes++;
        appendminutes.innerHTML = "0" + minutes;
        seconds = 0;
        appendSeconds.innerHTML = "0" + 0;
      }
  }