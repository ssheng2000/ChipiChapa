from PIL import Image
import sys
name = sys.argv[1]
img = Image.open(f"{name}.png")
new_img = Image.new("RGBA", (img.width * 2, img.height))
new_img.paste(img, (0, 0))
new_img.paste(img, (img.width, 0))
new_img.save(f"{name}_doubled.png")
print("done")
