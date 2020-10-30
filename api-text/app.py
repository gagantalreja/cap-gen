from flask import Flask, jsonify
import gpt_2_simple as gpt2
app = Flask(__name__)

def call_model():
    #from model import run_model
    sess = gpt2.start_tf_sess()
    gpt2.load_gpt2(sess, run_name='run1')
    return gpt2.generate(sess, run_name='run1', return_as_list=True, temperature=0.7)[0]


@app.route("/", methods=["GET"])
def text_model():

    X = call_model()
    X = X.split("\n")
    if X[-1][-1] != '.':
        X = X[:-1]
    return jsonify(result=X)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000, debug=True)


