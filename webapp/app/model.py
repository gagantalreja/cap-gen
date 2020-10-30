import numpy as np
import face_recognition
import keras, json
from keras.models import model_from_json
import cv2

def main(image_path):

    face_image  = cv2.imread(image_path)
    #face_image = cv2.cvtColor(face_image, cv2.COLOR_BGR2GRAY)
    #face_image = cv2.imdecode(image_path, cv2.IMREAD_UNCHANGED)
    face_locations = face_recognition.face_locations(face_image)
    top, right, bottom, left = face_locations[0]
    face_image = face_image[top:bottom, left:right]

    face_image = cv2.resize(face_image, (48,48))
    face_image = cv2.cvtColor(face_image, cv2.COLOR_BGR2GRAY)
    face_image = np.reshape(face_image, [1, face_image.shape[0], face_image.shape[1], 1])

    json_model_file = json.dumps(json.load(open("./app/model/fer.json")))
    model = model_from_json(json_model_file)
    model.load_weights("./app/model/fer.h5")

    label_map = {0: 'Angry', 5:'Sad', 4: 'Neutral', 1: 'Disgust', 6: 'Surprise', 2: 'Fear', 3: 'Happy'}
    predicted_class = np.argmax(model.predict(face_image))
    predicted_label = label_map[predicted_class]
    
    return predicted_label
