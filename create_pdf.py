# -*- coding: utf-8 -*-
from PIL import Image
import os
import glob

# Folder path with images
folder_path = r"D:\Xpiano\tai-lieu"

# Get all jpg files sorted by name
image_files = sorted([f for f in os.listdir(folder_path) if f.endswith('.jpg')])

# Open all images
images = []
for img_file in image_files:
    img_path = os.path.join(folder_path, img_file)
    img = Image.open(img_path)
    # Convert to RGB if needed
    if img.mode != 'RGB':
        img = img.convert('RGB')
    images.append(img)

# Save first image and append others
output_path = r"D:\Xpiano\Xpiano_TaiLieu.pdf"
print(f"Converting {len(images)} images to PDF...")
images[0].save(
    output_path,
    save_all=True,
    append_images=images[1:],
    resolution=100.0,
    quality=95,
    optimize=True
)

print(f"✅ PDF created successfully: {output_path}")
print(f"📄 Total pages: {len(images)}")
