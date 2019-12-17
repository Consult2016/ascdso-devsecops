
# by Wilson Mar at https://github.com/wilsonmar/DevSecOps/master/Tesseract
# based on https://medium.com/better-programming/beginners-guide-to-tesseract-ocr-using-python-10ecbb426c3d

import os  # for os.getenv

TESSDATA_PREFIX = os.getenv('TESSDATA_PREFIX')
print("TESSDATA_PREFIX=" + TESSDATA_PREFIX)

from tesserocr import PyTessBaseAPI
with PyTessBaseAPI(path=TESSDATA_PREFIX, lang='eng') as api:
    print(api.GetAvailableLanguages())