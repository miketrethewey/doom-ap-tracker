import json
import os

from natsort import natsorted

images = []

def process_images(dirname):
    for r,d,f in os.walk(dirname):
        d.sort()
        f.sort()
        for filename in f:
            image = os.path.join(r, filename)
            image = image[2:]
            image = image.replace("\\", "/")
            images.append(image)

dirname = os.path.join(".", "images")
process_images(dirname)

variantsDir = os.path.join(".", "variants")
for r, d, f in os.walk(variantsDir):
    d.sort()
    f = natsorted(f)
    if "images" in r and len(f):
        process_images(r)

outputdir = os.path.join(".","resources","tests","output")
if not os.path.exists(outputdir):
    os.makedirs(outputdir)
with open(os.path.join(outputdir, "imageFiles.json"), mode="w+", encoding="utf-8") as imagesJSON:
    imagesJSON.write(json.dumps(natsorted(set(images)), indent=2))
