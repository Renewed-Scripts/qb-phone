var JoinPass = null;
var JoinID = null;

function LoadEmploymentApp(){
    $.post('https://qb-phone/GetGroupsApp', JSON.stringify({}), function(data){
        AddDIV(data)
    });
}

$(document).on('click', '.empolyment-btn-create-group', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#employment-box-new-dashboard').fadeIn(350);
});

$(document).on('click', '#employment-sbmit-for-create-group', function(e){
    e.preventDefault();
    var Name = $(".employment-input-group-name").val();
    var pass = $(".employment-input-password").val();
    var pass2 = $(".employment-input-password2").val();
    if (Name != "" && pass != "" && pass2 != ""){
        if(pass == pass2){
            $.post('https://qb-phone/employment_CreateJobGroup', JSON.stringify({
                name: Name,
                pass: pass,
            }));

            $('#employment-box-new-dashboard').fadeOut(350);
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
                    console.log(JSON.stringify(event.data.stage))
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
    var CSN = QB.Phone.Data.PlayerData.citizenid;
    $(".employment-list").html("");
    if(data) {
        Object.keys(data).map(function(element,index){
            if(data[element].leader == CSN) {
                AddOption = 
                `
                <div class="employment-div-job-group">
                <div class="employment-div-job-group-image">
                <i class="fas fa-users"></i>
                </div><div class="employment-div-job-group-body-main">
                ${data[element].GName}<i id="employment-block-grouped"
                data-id="${data[element].id}"
                data-pass="${data[element].GPass}" 
                class="fas fa-sign-in-alt">
                </i>
                <div class="employment-option-class-body">
                <i id="employment-list-group" data-id="${data[element].id}" style="padding-right: 5%;" class="fas fa-list-ul">
                </i><i id="employment-delete-group" data-delete="${data[element].id}" class="fas fa-trash-alt"></i>
                <i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends"> ${data[element].Users}</i></div></div></div>
                `
            } else {
                AddOption = `
                <div class="employment-div-job-group">
                <div class="employment-div-job-group-image">
                <i class="fas fa-users"></i></div>
                <div class="employment-div-job-group-body-main">'+v.GName+'<i id="employment-join-grouped" data-id="${data[element].id}" data-pass="${data[element].GPass}" class="fas fa-sign-in-alt">
                </i><div class="employment-option-class-body">
                <i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends">${data[element].Users}</i>
                </div></div></div>`
                Object.keys(data[element].members).map(function(element,index){
                    if(data[element].members[element].CID == CSN) {
                        AddOption = `
                        <div class="employment-div-job-group">
                        <div class="employment-div-job-group-image">
                        <i class="fas fa-users"></i></div>
                        <div class="employment-div-job-group-body-main">${data[element].GName}<i id="employment-leave-grouped"
                         data-id="${data[element].id}" data-pass="${data[element].GPass}" class="fas fa-sign-out-alt" style="transform: rotate(180deg);">
                         </i><div class="employment-option-class-body">
                         <i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends">${data[element].Users}</i></div></div></div>`
                    }
                })
            }
            $('.employment-list').append(AddOption);
        }) 
    } else {
        $(".employment-list").html("");
        var AddOption = '<div class="casino-text-clear">No Group</div>'
        $('.employment-list').append(AddOption);
    }
}

function AddGroupJobs(data){
    var AddOption;
    console.log(data)
    $(".employment-Groupjob").html("");
    $(".employment-list").html("");
    if(data) {

        for (const [k, v] of Object.entries(data)) {
            console.log(JSON.stringify(data))
            if (v.isDone) {
                AddOption = 
                `
                <div class="employment-div-active-stagee isDone">
                    <input type="checkbox" id="job${v.name}" checked disabled>
                    <i  class="employment-div-active-stage${v.id}">${v.name}</i>
                </div>
                `
            } else {
                AddOption = 
                `
                <div class="employment-div-active-stagee">
                    <input type="checkbox" id="job${v.name}" disabled>
                    <i  class="employment-div-active-stage${v.id}">${v.name}</i>
                </div>
                `
            }
            $('.employment-Groupjob').append(AddOption);
        }
    } else {
        console.log("Error")
    }
}

$(document).on('click', '#employment-delete-group', function(e){
    e.preventDefault();
    var Delete = $(this).data('delete')
    $.post('https://qb-phone/employment_DeleteGroup', JSON.stringify({
        delete: Delete,
    }));
});

$(document).on('click', '#employment-join-grouped', function(e){
    e.preventDefault();
    JoinPass = $(this).data('pass')
    JoinID = $(this).data('id')
    ClearInputNew()
    $('#employment-box-new-join').fadeIn(350);
});

$(document).on('click', '#employment-sbmit-for-join-group', function(e){
    e.preventDefault();
    var EnterPass = $(".employment-input-join-password").val();
    if(EnterPass == JoinPass){
        var CSN = QB.Phone.Data.PlayerData.citizenid;
        $.post('https://qb-phone/employment_JoinTheGroup', JSON.stringify({
            PCSN: CSN,
            id: JoinID,
        }));
        ClearInputNew()
    $('#employment-box-new-join').fadeOut(350);
    }
});

$(document).on('click', '#employment-list-group', function(e){
    e.preventDefault();
    var id = $(this).data('id')
    $.post('https://qb-phone/employment_CheckPlayerNames', JSON.stringify({
        id: id,
        }), function(Data){
           ClearInputNew()
           $('#employment-box-new-player-name').fadeIn(350);
           $("#phone-new-box-main-playername").html("");
            for (const [k, v] of Object.entries(Data)) {
                var AddOption = `<div class="casino-text-clear">${v}</div>`

                $('#phone-new-box-main-playername').append(AddOption);
            }

           var AddOption2 = '<p> </p>'+
           '<div class="phone-new-box-btn box-new-red" id="box-new-cancel">Cancel</div>'

           $('#phone-new-box-main-playername').append(AddOption2);
    });
});

$(document).on('click', '#employment-leave-grouped', function(e){
    e.preventDefault();
    var CSN = QB.Phone.Data.PlayerData.citizenid;
    var id = $(this).data('id')
    $.post('https://qb-phone/employment_leave_grouped', JSON.stringify({
        id: id,
        csn: CSN,
    }));
});