from flask import request, jsonify, Blueprint, render_template, current_app as app
from flask import url_for, redirect
import requests
from PIL import Image
from google.cloud import vision
from google.oauth2 import service_account
from boto.s3.connection import S3Connection
from boto3.s3.transfer import TransferConfig
from botocore.exceptions import ClientError
import io, boto3
import random
import string, urllib.request as urllib

main_bp = Blueprint('main_bp', __name__)
BASE = "https://cap-gen.herokuapp.com"
creds = service_account.Credentials.from_service_account_file("./key1.json")
client = vision.ImageAnnotatorClient(credentials=creds)
s3_client = boto3.client('s3', aws_access_key_id="XXXXXXXXXXXXXXXXX",aws_secret_access_key="XXXXXXXXXXXXXXXXXXX",region_name='ap-south-1')

config = TransferConfig(multipart_threshold=1024 * 25,
                        max_concurrency=10,
                        multipart_chunksize=1024 * 25,
                        use_threads=True)
def upload_file(file, bucket, object_name):

    try:
        response = s3_client.upload_fileobj(file, bucket,object_name,ExtraArgs={'ACL': 'public-read'},Config=config)
    except ClientError as e:
        logging.error(e)
        return False
    return True

def image_save(img, mime, filename):
    try:
        c = Image.open(img)
        loc = f"images/{filename}.{mime}" 
        in_mem_file = io.BytesIO()
        c.save(in_mem_file, mime)
        in_mem_file.seek(0)
        upload_file(in_mem_file, 'cap-gen', loc)
        return True
    except Exception as e:
        print(e)
        return False

def get_emotion(path):

    content = urllib.urlopen(path)
    content = content.read()
    #print(content)
    image = vision.Image(content=content)
    #image.source.image_uri = path

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
        emotion["happy"] = emotion.get("happy", 0) + likelihood_map[likelihood_name[face.joy_likelihood]]
        emotion["surprise"] = emotion.get("surprise",0) + likelihood_map[likelihood_name[face.surprise_likelihood]]
        emotion["anger"] = emotion.get("anger",0) + likelihood_map[likelihood_name[face.anger_likelihood]]
        emotion["sorrow"] = emotion.get("sorrow",0) + likelihood_map[likelihood_name[face.sorrow_likelihood]]

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

def caption_api_caller(q):
    if q == "happy":
        r = requests.get(f"{BASE}/text-gen").json()
    else:
        r = {}
    return r

def hashtag_api_caller(q):
    if q == "happy":
        r = requests.get(f"{BASE}/hashtag-gen").json()
    else:
        r = {}
    return r

def emoji_api_caller(q):
    if q == "happy":
        r = requests.get(f"{BASE}/emoji-gen?polarity={q}").json()
    else:
        r = {}
    return r["result"]
        

@main_bp.route('/', methods=["GET"])
@main_bp.route('/test', methods=["GET"])
def test():
    return render_template('new_ui.html')


@main_bp.route('/upload', methods=["POST"])
def upload():
    data = request.files.getlist("file")
    x = data[0].content_type.split("/")[1]
    name = ''.join(random.choices(string.ascii_letters + string.digits, k=5))
    thumbs = list(data)
    for z,w in zip(thumbs, list(data)):
        image_save(w, x, name)
    return jsonify(src=f"https://cap-gen.s3.ap-south-1.amazonaws.com/images/{name}.{x}")


@main_bp.route('/get-result', methods=["GET"])
def get_res():
    x = request.args.get("image")
    emotion = get_emotion(x)
    print(emotion)
    emojis = emoji_api_caller(emotion)
    hashtags = hashtag_api_caller(emotion)
    output = caption_api_caller(emotion)
    return jsonify(result=output, emojis=emojis, tags=hashtags)


@main_bp.route("/text-api", methods=["GET"])
def text_api():
    q = request.args.get("q")
    return jsonify(result=caption_api_caller(q))

@main_bp.route("/tags-api", methods=["GET"])
def tags_api():
    q = request.args.get("q")
    return jsonify(result=hashtag_api_caller(q))

@main_bp.route("/emo-api", methods=["GET"])
def emo_api():
    q = request.args.get("q")
    return jsonify(result=emoji_api_caller(q))

@main_bp.route("/get-emotion", methods=["GET"])
def get_emotion_api():
    x = request.args.get("image")
    emotion = get_emotion(x)
    return jsonify(result=emotion)
