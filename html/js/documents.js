var DocEndtitle = null
var DocEndtext = null
var DocEndid = null
var DocEndcitizenid = null
var ExtraButtonsOpen = false;
var MonthFormatting = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

$(document).ready(function(){
    $("#documents-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".documents-test").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "DocumentRefresh":
                getDocuments();
            break;
            case "DocumentSent":
                SendDocument(event.data.DocumentSend.title, event.data.DocumentSend.text);
            break;
        }
    })
});

// Functions

function MainMenu(){
    $(".documents-list").html("");
    $(".document-body-class-body-main").html("");
    $('.documents-tupe-text-btn').fadeIn(50);
    $('#documents-search-text').fadeIn(50);
    $('#documents-search-icon').fadeIn(50);
    $('#documents-search').fadeIn(50);
    $('.documents-dropdown').fadeIn(50);
    $('.documents-select').fadeIn(50);

    if (ExtraButtonsOpen) {
        $(".documents-extra-buttons").animate({
            right: -60+"%",
        }, 250, function(){
            $(".documents-extra-buttons").css({"display":"block"});

            $(".documents-extra-buttons-registration").animate({
                right: -60+"%",
            }, 250, function(){
                $(".documents-extra-buttons-registration").css({"display":"block"});
            });
            ExtraButtonsOpen = false;
        });
    }
}

function getDocuments(){
    $(this).parents('.documents-dropdown').find('span').text($(this).text());
    $(this).parents('.documents-dropdown').find('input').attr('value', $(this).attr('id'));
    $(".documents-list").html(""); // Frown Face before loading any contents if any!
        var AddOption = '<div class="casino-text-clear">Nothing Here!</div>'+
        '<div class="casino-text-clear" style="font-size: 500%;color: #FFFFFF;"><i class="fas fa-frown"></i></div>'
    $('.documents-list').append(AddOption);

    $.post('https://qb-phone/GetNote_for_Documents_app', JSON.stringify({}), function(HasNote){
        if(HasNote){
            AddDocuments(HasNote)
        }
    });
}

function AddDocuments(data){
    $(".documents-list").html("");

    DocEndtitle = null
    DocEndtext = null
    DocEndid = null
    DocEndcitizenid = null

    for (const [k, v] of Object.entries(data)) {
        var firstLetter = v.title.substring(0, 1);  
        var Fulltext = firstLetter.toUpperCase()+(v.title).replace(firstLetter,'')
        
        var AddOption = '<div class="documents-test">' + 
            '<div class="documents-title-title">'+Fulltext+'</div>' +
            '<div class="documents-title-icon" data-title="'+v.title+'" data-text="'+v.text+'" data-id="'+v.id+'" data-csn="'+v.citizenid+'"><i class="fas fa-eye"></i></div>'+
        '</div>';

        $('.documents-list').append(AddOption);
    }
}

function LoadGetNotes(){
    $(".documents-dropdown-menu").html("");
    var Shitter = '<li id="documents-docs" data-title="Documents">Documents' +
        '<li id="documents-licenses" data-title="Licenses">Licenses</li>' +
        '<li id="documents-vehicle" data-title="Vehicle">Vehicle Registrations</li>' +
    '</li>';

    $('.documents-dropdown-menu').append(Shitter);
}

function SendDocument(title, text){
    MainMenu()
    $(".documents-list").html("");

    $('.documents-tupe-text-btn').fadeOut(50);
    $('#documents-search-text').fadeOut(50);
    $('#documents-search-icon').fadeOut(50);
    $('#documents-search').fadeOut(50);
    $('.documents-dropdown').fadeOut(50);
    $('.documents-select').fadeOut(50);


    DocEndtitle = title
    DocEndtext = text
    DocEndid = $(this).data('id')
    DocEndcitizenid = $(this).data('csn')

    var AddOption = `
    <div class="document-body-class-body-main">'+
        <div id="documents-textarea-new" spellcheck="false" required placeholder="Text" maxlength="4000">${DocEndtext}</div>
    </div>`;

    var AnotherOption = `
    <div class="document-body-class-body-main">
        <div class="documents-input-title-list">Title</div>
        <div class="documents-input-title-name">${DocEndtitle}</div>
        <div class="documents-input-tags"><i class="fas fa-tags"></i></div>
        <div class="documents-input-back"><i class="fas fa-chevron-left"></i></div>
    </div>`;

    $('.documents-list').append(AddOption);
    $('.documents-header').append(AnotherOption);
}

// Clicks

$(document).on('click', '#documents-docs', function(e) {
    getDocuments();
});

$(document).on('click', '#documents-vehicle', function(e) {
    $(this).parents('.documents-dropdown').find('span').text($(this).text());
    $(this).parents('.documents-dropdown').find('input').attr('value', $(this).attr('id'));
    $(".documents-list").html("");
    $.post('https://qb-phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
        if(Vehicles != null){
            $.each(Vehicles, function(i, vehicle){
                if (vehicle.vinscratched != 'false'){
                        DocEndtitle = null
                        DocEndtext = null
                        DocEndid = null
                        DocEndcitizenid = null
        
                        var firstLetter = vehicle.fullname.substring(0, 1);  
                        var Fulltext = firstLetter.toUpperCase()+(vehicle.fullname).replace(firstLetter,'')
                        var FirstName = QB.Phone.Data.PlayerData.charinfo.firstname;
                        var LastName = QB.Phone.Data.PlayerData.charinfo.lastname;
                
                        var AddOption = '<div class="documents-test">' + 
                            '<div class="documents-title-title">'+Fulltext+'</div>' +
                            '<div class="documents-title-icon-registration" data-title="'+vehicle.fullname+'" data-text="<b><center><u>San Andreas DMV</u></b></center><p><p><b>Name: </b>'+vehicle.brand+'</p></p><p><b>Model: </b>'+vehicle.model+'</p><p><b>Plate: </b>'+vehicle.plate+'</p><p><b>Owner: </b>'+FirstName+' '+LastName+'</p><p><b><center>Official State Document Of San Andreas</p></b></center>"><i class="fas fa-eye"></i></div>'+
                        '</div>';
                
                        $('.documents-list').append(AddOption);
                    }
            });
        } else {
            var AddOption = '<div class="casino-text-clear">Nothing Here!</div>'+
            '<div class="casino-text-clear" style="font-size: 500%;color: #0d1218c0;"><i class="fas fa-frown"></i></div>'
        $('.documents-list').append(AddOption);
        }
    });
});

$(document).on('click', '#documents-licenses', function(e) {
    var PlayerLicenses = QB.Phone.Data.PlayerData.metadata.licences;
    var FirstName = QB.Phone.Data.PlayerData.charinfo.firstname;
    var LastName = QB.Phone.Data.PlayerData.charinfo.lastname;
    var StateId = QB.Phone.Data.PlayerData.citizenid;
    var Sex = QB.Phone.Data.PlayerData.charinfo.gender;
    $(this).parents('.documents-dropdown').find('span').text($(this).text());
    $(this).parents('.documents-dropdown').find('input').attr('value', $(this).attr('id'));
    $(".documents-list").html("");

    if (Sex == 0){
        label = 'Male'
    } else if (Sex == 1){
        label = 'Female'
    }

    if (PlayerLicenses){
        for (const [k, v] of Object.entries(PlayerLicenses)) {
            if (v){
                var firstLetter = k.substring(0, 1);  
                var Fulltext = firstLetter.toUpperCase()+k.replace(firstLetter,'')+" License"
        
                var AddOption = `
                <div class="documents-test">
                    <div class="documents-title-title">${Fulltext}</div>
                    <div class="documents-title-icon-registration" data-title=${Fulltext} data-text="<b><u>Issued To</u></b><p><p><b>Name: </b>${FirstName} ${LastName}</p></p></b><p><b>ID: </b>${StateId}</p></b><p><b>Sex: </b>${label}</p></b><p><b><u>Issued By</u></b></p><p><b>Name: </b>State Account</p><p><b><center>Official Document Of San Andreas</p></b></center>"><i class="fas fa-eye"></i></div>
                </div>`
        
                $('.documents-list').append(AddOption);
            }
        }
    } else {
        var AddOption = '<div class="casino-text-clear">Nothing Here!</div>'+
        '<div class="casino-text-clear" style="font-size: 500%;color: #0d1218c0;"><i class="fas fa-frown"></i></div>'
    $('.documents-list').append(AddOption);
    }
});

$(document).on('click', '.documents-tupe-text-btn', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#documents-box-new-add-new').fadeIn(350);
});

$(document).on('click', '#documents-send-perm', function(e){
    e.preventDefault();
    var date = new Date();
    var Times = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
    var StateID = $(".documents-input-stateid").val();
    var NewText = $("#documents-textarea-new").val();
    if(NewText != ""){
        $.post('https://qb-phone/document_Send_Note', JSON.stringify({
            Title: DocEndtitle,
            Text: NewText,
            Time: Times,
            ID: DocEndid,
            CSN: DocEndcitizenid,
            StateID: StateID,
            Type: "PermSend",
        }));
    }
    ClearInputNew()
    $('#documents-send-stateid').fadeOut(350);
});

$(document).on('click', '#documents-save-note-for-doc', function(e){
    e.preventDefault();
    var Title = $(".documents-input-title").val();
    var Text = $("#documents-textarea").val();
    var date = new Date();
    var Times = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();

    if ((Title && Text) != ""){
        $.post('https://qb-phone/documents_Save_Note_As', JSON.stringify({
            Title: Title,
            Text: Text,
            Time: Times,
            Type: "New",
        }));
        ClearInputNew()
        $("#documents-textarea").val("");
        $('#documents-box-new-add-new').fadeOut(350);
    }
});

$(document).on('click', '.documents-title-icon-registration', function(e){
    e.preventDefault();
    $(".documents-list").html("");

    $('.documents-tupe-text-btn').fadeOut(50);
    $('#documents-search-text').fadeOut(50);
    $('#documents-search-icon').fadeOut(50);
    $('#documents-search').fadeOut(50);
    $('.documents-dropdown').fadeOut(50);
    $('.documents-select').fadeOut(50);

    DocEndtitle = $(this).data('title')
    DocEndtext = $(this).data('text')
    DocEndid = $(this).data('id')
    DocEndcitizenid = $(this).data('csn')

    var AddOption = `
    <div class="document-body-class-body-main">
        <div id="documents-textarea-new" spellcheck="false" required placeholder="Text" maxlength="4000">${DocEndtext}</div>
    </div>`;

    var AnotherOption = `
    <div class="document-body-class-body-main">
        <div class="documents-extras-button-registration"><i class="fas fa-ellipsis-v"></i></div>
        <div class="documents-input-title-list">Title</div>
        <div class="documents-input-title-name">${DocEndtitle}</div>
        <div class="documents-input-tags"><i class="fas fa-tags"></i></div>
        <div class="documents-input-back"><i class="fas fa-chevron-left"></i></div>
    </div>`;

    $('.documents-list').append(AddOption);
    $('.documents-header').append(AnotherOption);
});

$(document).on('click', '.documents-extras-button-registration', function(e) {
    e.preventDefault();
    if (!ExtraButtonsOpen) {
        $(".documents-extra-buttons-registration").css({"display":"block"}).animate({
            right: 15+"%",
        }, 250);
        ExtraButtonsOpen = true;
    } else {
        $(".documents-extra-buttons-registration").animate({
            right: -60+"%",
        }, 250, function(){
            $(".documents-extra-buttons-registration").css({"display":"block"});
            ExtraButtonsOpen = false;
        });
    }
});

$(document).on('click', '.documents-title-icon', function(e){
    e.preventDefault();
    $(".documents-list").html("");

    $('.documents-tupe-text-btn').fadeOut(50);
    $('#documents-search-text').fadeOut(50);
    $('#documents-search-icon').fadeOut(50);
    $('#documents-search').fadeOut(50);
    $('.documents-dropdown').fadeOut(50);
    $('.documents-select').fadeOut(50);


    DocEndtitle = $(this).data('title')
    DocEndtext = $(this).data('text')
    DocEndid = $(this).data('id')
    DocEndcitizenid = $(this).data('csn')

    var AddOption = `
    <div class="document-body-class-body-main">
        <textarea id="documents-textarea-new" spellcheck="false" required placeholder="Text" maxlength="4000">${DocEndtext}</textarea>
    </div>`;

    var AnotherOption = `
    <div class="document-body-class-body-main">
        <div class="documents-extras-button"><i class="fas fa-ellipsis-v"></i></div>
        <div class="documents-input-title-list">Title</div>
        <div class="documents-input-title-name">${DocEndtitle}</div>
        <div class="documents-input-tags"><i class="fas fa-tags"></i></div>
        <div class="documents-input-back"><i class="fas fa-chevron-left"></i></div>
    </div>`;

    $('.documents-list').append(AddOption);
    $('.documents-header').append(AnotherOption);
});

$('.documents-dropdown').click(function () {
    $(this).attr('tabindex', 1).focus();
    $(this).toggleClass('active');
    $(this).find('.documents-dropdown-menu').slideToggle(300);
});

$('.documents-dropdown').focusout(function () {
    $(this).removeClass('active');
    $(this).find('.documents-dropdown-menu').slideUp(300);
});

$(document).on('click', '.documents-input-back', function(e) {
    MainMenu()
    LoadGetNotes()
});

$(document).on('click', '.documents-extras-button', function(e) {
    e.preventDefault();
    if (!ExtraButtonsOpen) {
        $(".documents-extra-buttons").css({"display":"block"}).animate({
            right: 15+"%",
        }, 250);
        ExtraButtonsOpen = true;
    } else {
        $(".documents-extra-buttons").animate({
            right: -60+"%",
        }, 250, function(){
            $(".documents-extra-buttons").css({"display":"block"});
            ExtraButtonsOpen = false;
        });
    }
});

$(document).on('click', '#documents-share-local', function(e){
    e.preventDefault();

    $.post('https://qb-phone/document_Send_Note', JSON.stringify({
        Title: DocEndtitle,
        Text: DocEndtext,
        ID: DocEndid,
        Type: "LocalSend",
    }));
});

$(document).on('click', '#documents-save', function(e){
    e.preventDefault();
    var date = new Date();
    var Times = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
    var NewText = $("#documents-textarea-new").val();
    if(NewText != ""){
        $.post('https://qb-phone/documents_Save_Note_As', JSON.stringify({
            Title: DocEndtitle,
            Text: NewText,
            Time: Times,
            ID: DocEndid,
            CSN: DocEndcitizenid,
            Type: "Update",
        }));
    }
});

$(document).on('click', '#documents-delete', function(e){
    e.preventDefault();

    $.post('https://qb-phone/documents_Save_Note_As', JSON.stringify({
        ID: DocEndid,
        Type: "Delete",
    }));
    MainMenu()
    LoadGetNotes()
});

$(document).on('click', '#documents-share-perm', function(e){
    e.preventDefault();
    ClearInputNew()
    $('#documents-send-stateid').fadeIn(350);
});