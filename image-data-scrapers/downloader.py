import requests
import shutil

def get_image_from_url(url, filename):
    try:
        r = requests.get(url, stream = True)
        r.raw.decode_content = True
        with open(f"../data/images/{filename}",'wb') as f:
                shutil.copyfileobj(r.raw, f)
        return True
    except Exception as e:
        print(e)
        return False


#https://www.instagram.com/graphql/query/?query_hash=c769cb6c71b24c8a86590b22402fda50&variables=%7B%22tag_name%22%3A%22happy%22%2C%22first%22%3A4%2C%22after%22%3A%22QVFDZ2ItUEhheEpzVUotdmtXMmRMNmFaVmh6cVhYQ1pCRGk2Z1AzS1B0U2FzUXlkb2NCNzRncU9FUVRrLW9IWVZ6Tm81R0piOHljTTZ0NXNrMlp0Q3BucA%3D%3D%22%7D
#'https://www.instagram.com/graphql/query/?query_hash=c769cb6c71b24c8a86590b22402fda50&variables={"tag_name":"happy","first":4,"after":"QVFDZ2ItUEhheEpzVUotdmtXMmRMNmFaVmh6cVhYQ1pCRGk2Z1AzS1B0U2FzUXlkb2NCNzRncU9FUVRrLW9IWVZ6Tm81R0piOHljTTZ0NXNrMlp0Q3BucA=="}'
