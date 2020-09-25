sentences = open('../data/captions/sad.txt', 'r').readlines()
new_sentences = ""

for sentence in sentences:
    if len(sentence.split()) > 2:
        new_sentences += sentence.strip().strip("\n") + "\n"

with open("../data/captions/final_sad.txt", "w") as file:
    file.write(new_sentences)

        
    
