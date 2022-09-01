var dropdownOpen = false

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

function LoadEmploymentApp(){
    var jobs = QB.Phone.Data.PlayerData.metadata.phoneJobs;
    $(".employment-lists").html("");
    for (const [k, v] of Object.entries(jobs)) {
        var AddOption = '<div class="employment-list" data-job="'+k+'" data-grade="'+v+'"><span class="employment-icon"><i class="fas fa-business-time"></i></span> <span class="employment-label">'+QB.Phone.Data.PhoneJobs[k].label+'</span> <span class="employment-grade">'+QB.Phone.Data.PhoneJobs[k].grades[v].name+'</span>' +
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
    LoadEmploymentApp()
}

$(document).on('click', '.employment-list', function(e){
    e.preventDefault();
    var job = $(this).data('job'); // Job Name
    var grade = $(this).data('grade'); // Job Grade Level
    $(".employment-lists").html(""); // Resets the old screen

    // Fade out the old header to create the new header
    $(".employment-header").html("");

    // Option for creating the list of players having that job listed above
    var AddOption = '<div class="employment-job-list"><span class="employment-job-icon"><i class="fas fa-user-secret"></i></span>' +
    '<span class="employment-label">MannyOnBrazzers</span> <span class="employment-grade">Owner</span>'+
    '<div class="employment-action-buttons">' +
        '<i class="fas fa-user-tag" data-csn="INSERT-CSN-DATA-HERE" id="employment-view-camera" data-toggle="tooltip" title="Change Role"></i>'+
        '<i class="fas fa-hand-holding-usd" data-csn="INSERT-CSN-DATA-HERE" id="employment-track-camera" data-toggle="tooltip" title="Pay"></i>' +
        '<i class="fas fa-user-alt-slash" data-csn="INSERT-CSN-DATA-HERE" id="employment-addto-camera" data-toggle="tooltip" title="Remove Employee"></i>' +  
        '<i class="fas fa-university" data-csn="INSERT-CSN-DATA-HERE" id="employment-addto-camera" data-toggle="tooltip" title="Bank Access"></i>' +  
    '</div></div>';

    // Creates the new header
    var HeaderOption = '<span id="employment-job-search-text">Search</span>' +
    '<i class="fas fa-chevron-left" id="employment-job-back-icon"></i>' + 
    '<i class="fas fa-search" id="employment-job-search-icon"></i>' + 
    '<i class="fas fa-ellipsis-v" id="employment-job-extras-icon"></i>' +
    '<input type="text" id="employment-job-search" placeholder="" spellcheck="false">'

    $('.employment-lists').append(AddOption); // Creates the new screen
    $('.employment-header').append(HeaderOption); // Creates the new header
});

$(document).on('click', '#employment-job-back-icon', function(e){
    e.preventDefault();
    changePage()
}); 

$(document).on('click', '#employment-job-extras-icon', function(e){
    e.preventDefault();
    console.log('DROP DOWN')
    dropdownOpen = true

    $('#employment-dropdown').fadeIn(350);
    // Gonna work on the dropdown menu here later
});