var JoinPass = null;
var JoinID = null;

function LoadEmploymentApp(){
    $.post('https://qb-phone/GetGroupsApp', JSON.stringify({}), function(Data){
        AddDIV(Data)
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
            case "GroupAddDIV":
                AddDIV(event.data.datas)
            break;
        }
    })
});

function AddDIV(data){
    var CSN = QB.Phone.Data.PlayerData.citizenid;
    $(".employment-list").html("");
    if(JSON.stringify(data) != "[]"){
        for (const [k, v] of Object.entries(data)) {
            var AddOption
            if (v.CSN == CSN){
                AddOption = '<div class="employment-div-job-group"><div class="employment-div-job-group-image"><i class="fas fa-users"></i></div><div class="employment-div-job-group-body-main">'+(v.GName).toUpperCase()+'<i id="employment-block-grouped" data-id="'+v.CSN+'" data-pass="'+v.GPass+'" class="fas fa-sign-in-alt"></i><div class="employment-option-class-body"><i id="employment-list-group" data-id="'+v.CSN+'" style="padding-right: 5%;" class="fas fa-list-ul"></i><i id="employment-delete-group" data-delete="'+v.CSN+'" class="fas fa-trash-alt"></i><i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends"> '+v.Users+'</i></div></div></div>'
            }else{
                AddOption = '<div class="employment-div-job-group"><div class="employment-div-job-group-image"><i class="fas fa-users"></i></div><div class="employment-div-job-group-body-main">'+(v.GName).toUpperCase()+'<i id="employment-join-grouped" data-id="'+v.CSN+'" data-pass="'+v.GPass+'" class="fas fa-sign-in-alt"></i><div class="employment-option-class-body"><i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends"> '+v.Users+'</i></div></div></div>'
                for (const [ke, ve] of Object.entries(v.UserName)) {
                    if(ve == CSN){
                        AddOption = '<div class="employment-div-job-group"><div class="employment-div-job-group-image"><i class="fas fa-users"></i></div><div class="employment-div-job-group-body-main">'+(v.GName).toUpperCase()+'<i id="employment-leave-grouped" data-id="'+v.CSN+'" data-pass="'+v.GPass+'" class="fas fa-sign-out-alt" style="transform: rotate(180deg);"></i><div class="employment-option-class-body"><i style="padding-left: 5%;padding-right: 5%;" class="fas fa-user-friends"> '+v.Users+'</i></div></div></div>'
                    }
                }
            }

            $('.employment-list').append(AddOption);
        }
    }else{
        $(".employment-list").html("");
        var AddOption = '<div class="casino-text-clear">No Group</div>'

        $('.employment-list').append(AddOption);
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
                var AddOption = '<div class="casino-text-clear">'+v+'</div>'

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