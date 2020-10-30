from flask import request, jsonify, Blueprint, render_template, current_app as app
from flask import url_for, redirect
import requests
from google.cloud import vision
from google.oauth2 import service_account
import io
import random
import string

main_bp = Blueprint('main_bp', __name__)

creds = service_account.Credentials.from_service_account_file("./key1.json")
client = vision.ImageAnnotatorClient(credentials=creds)


def get_emotion(path):
    with io.open(path, 'rb') as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.face_detection(image=image)
    faces = response.face_annotations
    likelihood_name = ('UNKNOWN', 'VERY_UNLIKELY', 'UNLIKELY', 'POSSIBLE',
                       'LIKELY', 'VERY_LIKELY')
    likelihood_map = {
        'UNKNOWN': 0,
        'VERY_UNLIKELY': -2,
        'UNLIKELY': -1,
        'POSSIBLE': 0,
        'LIKELY': 1,
        'VERY_LIKELY': 2
    }

    emotion = dict()
    for face in faces:
        emotion["happy"] = emotion.get(
            "happy", 0) + likelihood_map[likelihood_name[face.joy_likelihood]]
        emotion["surprise"] = emotion.get(
            "surprise",
            0) + likelihood_map[likelihood_name[face.surprise_likelihood]]
        emotion["anger"] = emotion.get(
            "anger",
            0) + likelihood_map[likelihood_name[face.anger_likelihood]]
        emotion["sorrow"] = emotion.get(
            "sorrow",
            0) + likelihood_map[likelihood_name[face.sorrow_likelihood]]

    if response.error.message:
        raise Exception('{}\nFor more info on error messages, check: '
                        'https://cloud.google.com/apis/design/errors'.format(
                            response.error.message))
    mx, em = 0, "neutral"
    for k, v in emotion.items():
        if v > mx:
            mx = v
            em = k
    return em


@main_bp.route('/', methods=["GET"])
@main_bp.route('/test', methods=["GET"])
def test():
    return render_template('new_ui.html')


@main_bp.route('/upload', methods=["POST"])
def upload():
    data = request.files.get("file")
    x = data.content_type.split("/")[1]
    name = ''.join(random.choices(string.ascii_letters + string.digits, k=5))
    data.save(f"./app/static/uploads/{name}.{x}")
    return jsonify(src=url_for("static", filename=f"uploads/{name}.{x}"))


@main_bp.route('/get-result', methods=["GET"])
def get_res():
    x = request.args.get("image")
    x = f"./app/{x}"
    emotion = get_emotion(x)
    print(emotion)
    api_url = url_for("main_bp.text_api", q=emotion)
    output = requests.get(f"http://13.126.44.143:3000{api_url}").json()
    return jsonify(result=output)


@main_bp.route("/text-api", methods=["GET"])
def text_api():
    emotion = request.args.get("q")
    if emotion == "happy":
        r = requests.get("http://13.126.44.143/text-gen")
        return jsonify(r.json())
    else:
        return jsonify(result="")
