from flask import Flask, jsonify, Blueprint
from random import sample
from app.helpers import emoji
from flask import request

api = Blueprint("api", __name__)
emotion_to_polarity = {
    "happy": [1, 2, 3, 4],
    "angry": [-4, -3],
    "sorrow": [-2, -1],
}

file = open("./app/text_gen/happy-sample.txt").readlines()
file_hashtags = open("./app/text_gen/hashtags.txt").readlines()


def get_text(next_=5):
    r = sample(file, next_)
    print(r)
    return r


def get_hashtags(next_=6):
    r = sample(file_hashtags, next_)
    print(r)
    return r


@api.route("/text-gen", methods=["GET"])
def text_gen():
    return jsonify(result=get_text())


@api.route("/emoji-gen", methods=["GET"])
def emoji_gen():
    pol = request.args.get("polarity")
    return jsonify(result=emoji.get_emoji(emotion_to_polarity.get(pol, "")))


@api.route("/hashtag-gen", methods=["GET"])
def hashtag_gen():
    return jsonify(result=get_hashtags())

@api.route("/text-gen-app", methods=["GET"])
def text_gen_app():
    q = request.args.get("q")
    if q == "happy":
        return jsonify(result=get_text())
    else:
        return jsonify(result=[])

@api.route("/tags-gen-app", methods=["GET"])
def tags_gen_app():
    q = request.args.get("q")
    if q == "happy":
        return jsonify(result=get_hashtags())
    else:
        return jsonify(result=[])

