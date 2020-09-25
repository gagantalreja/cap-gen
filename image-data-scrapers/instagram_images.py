import requests, json, urllib.parse as up
from pprint import pprint
import time, json
from datetime import datetime, timedelta
import pytz, os
import downloader

class Instagram:

    def __init__(self, resp):
        self.data = dict()
        self.resp = resp

    def download(self, url, filename):
        downloader.get_image_from_url(url, filename)

    def has_next(self):
        return self.resp["hashtag"]["edge_hashtag_to_media"]["page_info"]["has_next_page"]
            
    def get_images_and_captions(self, tag='', c=1):

        posts = self.resp["hashtag"]["edge_hashtag_to_media"]["edges"]

        for post in posts:
            filename = post["node"]["id"]
            image_url = post["node"]["display_url"]
            mime = image_url.split('?')[0]
            mime = mime[::-1].split('/')[0][::-1]
            mime = mime[::-1].split('.')[0][::-1]
            caption = post["node"]["edge_media_to_caption"]["edges"][0]["node"]["text"]
            self.data[filename] = caption
            filename = f"{tag}/" + filename + f".{mime}"
            print(filename)
            self.download(image_url, filename)
        
        if c<=5 and self.has_next():
            time.sleep(5)
            cookie='mid=XbE4wgALAAGT4xzvnr1iKYAidyc7; fbm_124024574287414=base_domain=.instagram.com; ig_did=5DBDD105-A593-4DF3-9DB8-EFB3BE893251; shbid=487; fbsr_124024574287414=nBzYhrJSfkpwAPO9Wwdo-0vRQ32EzC40SBQVxxq7aVA.eyJ1c2VyX2lkIjoiMTAwMDAxOTg1NDgzNTA3IiwiY29kZSI6IkFRRDJmbGhpcVYwTXBxay16SHJKMXZ3VmllMS1KVDV1SFVFSjFRTEcyWXhHajdNTVh5SmZ2eXdxNzJwRkV3dUJZTUJtemtRb3pKeWNERU1CMTVsYUtKZy0zT2lxSFFDVlRGUUUzbjNsWTktVVRIaWlsR1NTdGNtVTA0MzZyaC1pUGRGalprSms3eWduQ2FCSGpSbjk0d0s0VVotZU1WSUI4eVNkQnhUeUMwVjFUYVdfSGdqeFd6dEljM044eWdYS2JEdU00Q2NGUWhlRmpFVFNINlU2bFduNGItQjRXRWs4YkFueEstVVhJSjZ6aUhtek5mVUMxLWsxeFYzUmJXckxPWE9TYWRrLTUxOC12eDhyTVdiSTZJdGtNVVEtLWRRTlY3bF9HVDRoSUt3NHJsd1Y5RFRjUmtYaElBV3VWTmN4YkF1RlJGWWM2bWZBRkljVzZqUDF6djlURU5Nd2pJZWtQLVcwX2xSYTlFQWluUSIsIm9hdXRoX3Rva2VuIjoiRUFBQnd6TGl4bmpZQkFFblgycldZYTI2eTdmQ05rU3hJOVpDSGtKQVpDVG1TQ2o3RkdPUVQzMlRUVjJrVHAyYVl1VW01SjVRb3N5U293VW11TnV4MUQ1dVpDVUNiSk9hUmlJRFBMM1czTVpDc2RIZHoyQWhtVEZZRzVVcEJCdkNiWkIzcWNNdU5Zd1hNbmtwa2dKTUQxYzIwbVNReVpBVUY1U3JObENIZnlwYllxdVE0aXE2aWdhIiwiYWxnb3JpdGhtIjoiSE1BQy1TSEEyNTYiLCJpc3N1ZWRfYXQiOjE1OTQ3NTE0ODJ9; ds_user_id=5554076353; sessionid=5554076353%3AlVBOujR2WpYE5w%3A21; csrftoken=PeaElM0ST1By3gIcKKt8SNV58Fm3OzNr; shbts=1595874965.7773309; rur=ATN; urlgen="{\"106.205.37.140\": 45609\054 \"27.60.37.44\": 45609\054 \"2405:204:a2a7:8fac:cd4a:2c7d:c192:6eb4\": 55836\054 \"2405:204:a2a7:8fac:81dd:4946:d727:8933\": 55836}:1k0leN:1lkJvwxzU1OdsVrhV5QQDAa0dHA"'
            user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36"
            end_cursor = self.resp["hashtag"]["edge_hashtag_to_media"]["page_info"]["end_cursor"]
            variables = f'"tag_name":"{tag}","first":500,"after":"{end_cursor}"'
            url = 'https://www.instagram.com/graphql/query/?query_hash=c769cb6c71b24c8a86590b22402fda50&variables={'+variables+'}'
            self.resp = requests.get(url, headers={'accept': 'application/json', "cookie": cookie, "user-agent": user_agent}).json()
            self.resp = self.resp["data"]
            self.get_images_and_captions(tag, c+1)

if __name__ == '__main__':
    tag = 'upsetface'
    os.mkdir(f'../data/images/{tag}')
    cookie='mid=XbE4wgALAAGT4xzvnr1iKYAidyc7; fbm_124024574287414=base_domain=.instagram.com; ig_did=5DBDD105-A593-4DF3-9DB8-EFB3BE893251; shbid=487; fbsr_124024574287414=nBzYhrJSfkpwAPO9Wwdo-0vRQ32EzC40SBQVxxq7aVA.eyJ1c2VyX2lkIjoiMTAwMDAxOTg1NDgzNTA3IiwiY29kZSI6IkFRRDJmbGhpcVYwTXBxay16SHJKMXZ3VmllMS1KVDV1SFVFSjFRTEcyWXhHajdNTVh5SmZ2eXdxNzJwRkV3dUJZTUJtemtRb3pKeWNERU1CMTVsYUtKZy0zT2lxSFFDVlRGUUUzbjNsWTktVVRIaWlsR1NTdGNtVTA0MzZyaC1pUGRGalprSms3eWduQ2FCSGpSbjk0d0s0VVotZU1WSUI4eVNkQnhUeUMwVjFUYVdfSGdqeFd6dEljM044eWdYS2JEdU00Q2NGUWhlRmpFVFNINlU2bFduNGItQjRXRWs4YkFueEstVVhJSjZ6aUhtek5mVUMxLWsxeFYzUmJXckxPWE9TYWRrLTUxOC12eDhyTVdiSTZJdGtNVVEtLWRRTlY3bF9HVDRoSUt3NHJsd1Y5RFRjUmtYaElBV3VWTmN4YkF1RlJGWWM2bWZBRkljVzZqUDF6djlURU5Nd2pJZWtQLVcwX2xSYTlFQWluUSIsIm9hdXRoX3Rva2VuIjoiRUFBQnd6TGl4bmpZQkFFblgycldZYTI2eTdmQ05rU3hJOVpDSGtKQVpDVG1TQ2o3RkdPUVQzMlRUVjJrVHAyYVl1VW01SjVRb3N5U293VW11TnV4MUQ1dVpDVUNiSk9hUmlJRFBMM1czTVpDc2RIZHoyQWhtVEZZRzVVcEJCdkNiWkIzcWNNdU5Zd1hNbmtwa2dKTUQxYzIwbVNReVpBVUY1U3JObENIZnlwYllxdVE0aXE2aWdhIiwiYWxnb3JpdGhtIjoiSE1BQy1TSEEyNTYiLCJpc3N1ZWRfYXQiOjE1OTQ3NTE0ODJ9; ds_user_id=5554076353; sessionid=5554076353%3AlVBOujR2WpYE5w%3A21; csrftoken=PeaElM0ST1By3gIcKKt8SNV58Fm3OzNr; shbts=1595874965.7773309; rur=ATN; urlgen="{\"106.205.37.140\": 45609\054 \"27.60.37.44\": 45609\054 \"2405:204:a2a7:8fac:cd4a:2c7d:c192:6eb4\": 55836\054 \"2405:204:a2a7:8fac:81dd:4946:d727:8933\": 55836}:1k0leN:1lkJvwxzU1OdsVrhV5QQDAa0dHA"'
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36"
    resp = requests.get(f"https://www.instagram.com/explore/tags/{tag}/?__a=1", headers={'accept': 'application/json', "cookie": cookie, "user-agent": user_agent})
    resp = resp.json()
    resp = resp["graphql"]
    I = Instagram(resp)
    I.get_images_and_captions(tag)
    pprint(I.data)
    
