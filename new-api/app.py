from flask import Flask, jsonify
from random import sample
app = Flask(__name__)

file = open("text_gen/happy-sample.txt").readlines()
def get_model(next_=5):
    r = sample(file, next_)
    return r


@app.route("/text-gen", methods=["GET"])
def text_gen():
    return jsonify(result=get_model())


if __name__ == "__main__":
    app.run(debug=True)
