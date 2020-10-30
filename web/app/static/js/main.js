var addText = function (res) {
    var html = '';
    res.forEach(function (text) {
        html += `<li>
                    <div class="d-flex justify-content-around align-items-xl-center element" style="">
                        <p class="d-xl-flex align-items-xl-center" style="">${text}<br></p>
                        <button class="text-center copy" style="border: none; background: transparent;">
                            <i class="material-icons" style="width: 24px;margin-left: 5px;padding-right: 47px;">content_copy</i>
                        </button>
                    </div>
                </li>`;
    });

    return html;
}

$(document).ready(function () {

    $('.head').on('click', function () {
        $('.head').removeClass('active');
        $(this).addClass('active');
    });

    $('.show-caption').on('click', function () {
        $('.captions').removeClass('d-none');
        $('.hashtags').addClass('d-none');
    });

    $('.show-hashtag').on('click', function () {
        $('.captions').addClass('d-none');
        $('.hashtags').removeClass('d-none');
    });

    $('.submit-btn').on('click', function (e) {
        e.preventDefault();
        $('.uploaded').attr('src', 'static/img/fake_img.svg');
        $('#file').click();
    });

    $('#file').on('change', function () {
        if ($(this).val() !== null) {
            $.ajax({
                'type': 'POST',
                'url': '/upload',
                'data': new FormData($('#form')[0]),
                'contentType': false,
                'cache': false,
                'processData': false,
                'success': function (res) {
                    $('.uploaded').attr('src', res["src"]);
                    $('.uploaded').css({
                        'border-radius': '50%'
                    });
                }
            });
        }
    });

    $(".generate").on('click', function () {
        if ($('.uploaded').attr('src') === 'static/img/fake_img.svg') {
            alert("Please upload an image");
        } else {
            $('.rotatable').addClass('rotate');
            $.ajax({
                type: 'GET',
                url: '/get-result',
                data: {
                    'image': $('.uploaded').attr('src')
                },
                success: function (res) {
                    console.log(res);
                    $('.rotatable').removeClass('rotate');
                    $('#gen-text').removeClass('d-none');
                    $('html, body').stop().animate({
                        scrollTop: $('#gen-text').offset().top
                    }, 1500, 'easeInOutExpo');
                    $('.pic-sec').css({
                        'background': `url("${$('.uploaded').attr('src')}") bottom / contain no-repeat, #ffffff`
                    });
                    $('.uploaded').attr('src', 'static/img/fake_img.svg');
                    $('.cap-list').append(addText(res["result"]["result"]));
                }
            });
        }

    });

    $('.cap-list').on('scroll', function () {
        if ($('#indicator').offset().top - $('.show-hashtag').offset().top <= 0) {
            $.ajax({
                type: 'GET',
                url: '/text-api',
                data: {
                    'q': 'happy'
                },
                success: function (res) {
                    $('.cap-list').append(addText(res["result"]));
                }
            });
        }
    });

    $('.cap-list').on('click', '.copy', function () {
        var text = $(this).closest('.element').children('p').text().trim();
        var elem = document.createElement("textarea");
        document.body.appendChild(elem);
        elem.value = text;
        elem.select();
        try {
            var ok = document.execCommand('copy');
            if (ok) alert('Copied!');
            else alert('Unable to copy!');
        } catch (err) {
            alert('Unsupported Browser!');
        }
    });
});
