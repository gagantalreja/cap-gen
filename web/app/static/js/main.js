var addText = function (res, k) {
    var html = '';
    var c = "new"
    res.forEach(function (text) {
        if (k.indexOf(text) === -1) {
            html += `<li class="${c}">
                    <div class="d-flex justify-content-around align-items-xl-center element" style="">
                        <p class="d-xl-flex align-items-xl-center" style="">${text}<br></p>
                        <button class="text-center copy" style="border: none; background: transparent;">
                            <i class="material-icons" style="width: 24px;margin-left: 5px;padding-right: 47px;">content_copy</i>
                        </button>
                    </div>
                </li>`;
            c = "";
        }
    });

    return html;
}

var addEmoji = function (res) {
    var html = "";
    res.forEach(function (emo) {
        html += `<button class="emo-butt butt-copy d-xl-flex justify-content-xl-center align-items-xl-center">${emo["emoji"]}</button>`
    });
    return html;
}

var addTags = function (res) {
    var html = `<div class="d-flex justify-content-between pb-3 pt-3">`;
    var c = 0;
    res.forEach(function (tag) {
        if (c < 3) {
            html += `<button class="tag-butt butt-copy d-xl-flex justify-content-xl-center align-items-xl-center">#${tag}</button>`;
            c+=1;
        }
    });
    html += "</div>";
    html += `<div class="d-flex justify-content-between">`;
    c = 0;
    res.forEach(function (tag) {
        if (c >= 3) {
            html += `<button class="tag-butt butt-copy d-xl-flex justify-content-xl-center align-items-xl-center">#${tag}</button>`;
        }
        c+=1;
    });
    html += "</div>";
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
                    $('.cap-list').html("");
                    $('.emo-list').html("");
                    $('.tag-list').html("");
                    console.log(res["emojis"])
                    $('.cap-list').append(addText(res["result"]["result"], []));
                    $('.emo-list').append(addEmoji(res["emojis"]));
                    console.log(res)
                    $('.tag-list').append(addTags(res["tags"]["result"]));
                }
            });
        }

    });

    $('.more_butt').on('click', function () {
        $.ajax({
            type: 'GET',
            url: '/text-api',
            data: {
                'q': 'happy'
            },
            success: function (res) {
                $('.new').removeClass('new');
                var k = []
                $('.cap-list li p').each(function (x) {
                    k.push($(this).text())
                });
                $('.cap-list').append(addText(res["result"]["result"], k));
                console.log($('.cap-list').scrollTop());
                $('.cap-list').stop().animate({
                    scrollTop: $('.new').position().top + $('.cap-list').scrollTop()
                }, 1500, 'linear');
            }
        });
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
    
    $('.hashtags').on('click', '.butt-copy', function () {
        var text = $(this).text().trim();
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

    $('.refresh-button').on('click', function () {
        $('.emo-butt').addClass('pulse-button');
        $.ajax({
            type: 'GET',
            url: '/emo-api',
            data: {
                q: 'happy',
            },
            success: function (res) {
                console.log(res);
                $('.emo-list').html(addEmoji(res["result"]));
                $('.emo-butt').removeClass('pulse-button');
            }
        });
    });
});
