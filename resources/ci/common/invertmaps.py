import os
from PIL import Image, ImageOps

baseTheme = "heretic"
baseGame = "heretic"

mapRoot = os.path.join(
    "variants",
    baseTheme,
    baseGame,
    "images",
    "maps"
)

print(f"{baseTheme}/{baseGame}")

for episodePath in os.listdir(mapRoot):
    if os.path.isdir(os.path.join(mapRoot,episodePath)):
        print(f" {episodePath}")
        for mapPath in os.listdir(os.path.join(mapRoot,episodePath)):
            if os.path.isfile(os.path.join(mapRoot,episodePath,mapPath)):
                mapHandle = mapPath[:mapPath.find("_")]
                mapImage = Image.open(os.path.join(mapRoot,episodePath,mapPath))
                if mapImage:
                    if mapImage.mode == "P":
                        mapImage = mapImage.convert("RGB")
                    pixel = mapImage.getpixel((0,0))
                    if isinstance(pixel, tuple):
                        pR = pixel[0]
                        pB = pixel[1]
                        pG = pixel[2]
                        if (pR, pB, pG) == (255, 255, 255):
                            print(f"  {mapHandle}")
                            mapInverted = ImageOps.invert(mapImage)
                            mapInverted.save(os.path.join(mapRoot,episodePath,mapPath))
