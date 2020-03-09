# run.py by Wilson Mar at https://github.com/wilsonmar/DevSecOps/master/Tesseract
# based on https://www.learnopencv.com/deep-learning-based-text-recognition-ocr-using-tesseract-and-opencv/
# https://medium.com/free-code-camp/getting-started-with-tesseract-part-i-2a6a6b1cf75e?
# and brew install pytesseract on macOS.

# USAGE: python3 run.py tsseract-quick-brown-fox.png  out

import cv2
import sys
import pytesseract

import os  # for os.getenv
 
if __name__ == '__main__':
 
  if len(sys.argv) < 2:
    print('Usage: python ocr_simple.py image.jpg')
    sys.exit(1)
   
  # Read image path from command line
  imPath = sys.argv[1]
     
  TESSDATA_PREFIX = os.getenv('TESSDATA_PREFIX')
  print("TESSDATA_PREFIX=" + TESSDATA_PREFIX)

  # Uncomment the line below to provide path to tesseract manually
  # pytesseract.pytesseract.tesseract_cmd = '/usr/bin/tesseract'
 
  # Define config parameters.
  # '-l eng'  for using the English language
  # '--oem 1' for using LSTM OCR Engine
  config = ('--tessdata-dir TESSDATA_PREFIX -l eng --oem 1 --psm 3')
 
  # Read image from disk
  im = cv2.imread(imPath, cv2.IMREAD_COLOR)
 
  # Run tesseract OCR on image
  text = pytesseract.image_to_string(im, config=config)
 
  # Print recognized text
  print(text)
  