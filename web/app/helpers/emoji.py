import json
from random import sample
emoji = json.loads(open("./app/text_gen/emoji.json", encoding="utf-8").read())


def get_emoji(polarity):
    l = [em for em in emoji if em["polarity"] in polarity]
    r = sample(l, 5)
    return r
