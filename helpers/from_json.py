import os, json
import re, string
import nltk
from nltk.tokenize import word_tokenize

def cleaner(docs):
    for i in range(len(docs)):
        docs[i] = docs[i].strip("\n").strip("\t")
        docs[i] = " ".join(docs[i].split("\n"))
        #docs[i] = docs[i].translate(docs[i].maketrans('', '', '"'))
        docs[i] = re.sub(r'^https?:\/\/.*[\r\n]*', '', docs[i], flags=re.MULTILINE)
        #docs[i] = docs[i].translate(docs[i].maketrans('', '', string.punctuation))
        docs[i] = ' '.join([j for j in docs[i].split() if 'https' not in j and '#' not in j and '@' not in j])
        docs[i] = ' '.join([re.sub("\d+", "", j) for j in docs[i].split()])
        docs[i].split()
    isvalid = lambda x: 48 <= ord(x) <= 57 or 65 <= ord(x) <= 90 or  97 <= ord(x) <= 122 or ord(x) == 32 or x in set(".,?!\"\'")
    for i in range(len(docs)):
        k = list(docs[i])
        for j in range(len(k)):
            k[j] = k[j] if isvalid(k[j]) else ''
        docs[i] = ''.join(k)
    return docs


if __name__ == "__main__":

    DIR = "../data/captions/sad"
    file_list = os.listdir(DIR)

    sentences = []

    for file in file_list:
        try:
            data = json.load(open(f"{DIR}/{file}"))
            sentences.append(data["text"])
        except Exception as e:
            print(e)
            print(file)

    sentences = cleaner(sentences)
    with open(f"../data/captions/sad.txt", "w", encoding="UTF-8") as file:
        for sentence in sentences:
            file.write(sentence)
            file.write("\n")
    

    

