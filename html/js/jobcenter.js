function LoadJobCenter(){
    $.post('https://qb-phone/GetJobCentersJobs', JSON.stringify({}), function(Jobs){
        $(".job-list").html("");
        for (const [_, v] of Object.entries(Jobs)) {
            var AddOption = '<div class="job-class-body-job" >'+'<div class="job-showitems-other"><i data-event="'+v.event+'" id="job-icon-class" class="fas fa-map-marked-alt"></i></div>'+v.label+'</div>'
            $('.job-list').append(AddOption);
        }
    });
};

$(document).on('click', '#job-icon-class', function(e){
    e.preventDefault();
    var event = $(this).data('event')
    $.post('https://qb-phone/CasinoPhoneJobCenter', JSON.stringify({
        event: event,
    }));
});