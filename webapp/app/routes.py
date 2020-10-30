from flask import request, jsonify, Blueprint, render_template
from flask import url_for, redirect
import requests, numpy
import app.model as model

main_bp = Blueprint('main_bp', __name__)


@main_bp.route('/', methods=["GET"])
def index():
    return render_template('index.html')


@main_bp.route('/test', methods=["GET"])
def test():
    return render_template('new_ui.html')


@main_bp.route('/upload', methods=["POST"])
def upload():
    data = request.files.get("file")
    print(data)
    x = data.content_type.split("/")[1]
    data.save(f"./app/static/image.{x}")
    return jsonify(src=url_for("static", filename=f"image.{x}"))


@main_bp.route('/get-result', methods=["GET"])
def get_res():
    x = request.args.get("image")
    x = f"./app/{x}"
    #x = model.main(x).lower()
    #print(request.base_url, request.referrer)
    api_url = url_for("main_bp.text_api", q="happy")
    output = requests.get(f"http://localhost:5000/{api_url}").json()
    return jsonify(result=output)


@main_bp.route("/text-api", methods=["GET"])
def text_api():
    emotion = request.args.get("q")
    if emotion == "happy":
        r = requests.get("http://13.126.44.143/text-gen")
        return jsonify(r.json())
    else:
        return jsonify(result="")
