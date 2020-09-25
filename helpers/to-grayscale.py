import os
import numpy as np
import cv2

DIR = "../data/images/upsetface"
NEW_DIR = "../data/images/upset-gray"
#os.mkdir(NEW_DIR)
img_list = os.listdir(DIR)
c = 1
for img in img_list:
    im = cv2.imread(f"{DIR}/{img}")
    y = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    y = cv2.resize(y, (48,48), interpolation=cv2.INTER_CUBIC)
    cv2.imwrite(f"{NEW_DIR}/{img}", y)
