import requests
from bs4 import BeautifulSoup

url = 'https://github.com/JyCyunMe/Clash.Mini/releases/tag/${{}'
headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/605.1.15 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/605.1.15'}
rsp = requests.get(url, headers = headers)
soup = BeautifulSoup(rsp.text, 'html.parser')
md=""
for e in soup.find("div",class_="markdown-body"):
    md += str(e)
print("Release Page:", md)

f = open (r'./.github/output/release_log','w')
print (md, file = f)
f.close()