import pandas as pd
import numpy as np
import cv2

df = pd.read_csv('c:/users/gagan/desktop/fer2013.csv')
DIR = "../data/images"
counter = 0
for x in df[df.emotion==3].pixels:
    X = np.array(list(map(float, x.split()))).reshape((48, 48))
    cv2.imwrite(f"{DIR}/happy-gray/{counter}.png", X)
    counter +=1

counter = 0
for x in df[df.emotion==5].pixels:
    X = np.array(list(map(float, x.split()))).reshape((48, 48))
    cv2.imwrite(f"{DIR}/upset-gray/{counter}.png", X)
    counter +=1
