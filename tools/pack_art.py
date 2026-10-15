"""Slice generated atlases into engine cells with stable sprite pivots."""
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1]
src=root/'art/source';out=root/'game/assets'
def cell(im,col,row,cols,rows):
 w,h=im.size
 return im.crop((round(col*w/cols),round(row*h/rows),round((col+1)*w/cols),round((row+1)*h/rows)))
def sprite(im,size=96,extent=84):
 # Ignore almost-transparent generation residue when calculating the game pivot.
 alpha=im.getchannel('A');alpha=alpha.point(lambda v:255 if v>=160 else 0)
 im.putalpha(alpha);box=alpha.getbbox();im=im.crop(box)
 im.thumbnail((extent,extent),Image.Resampling.NEAREST)
 canvas=Image.new('RGBA',(size,size));canvas.alpha_composite(im,((size-im.width)//2,size-12-im.height));return canvas
im=Image.open(src/'mia-sheet.png').convert('RGBA');frames=[]
for row in range(4):
 for col in range(4):frames.append(sprite(cell(im,col,row,4,4),96,80))
atlas=Image.new('RGBA',(384,384))
for i,f in enumerate(frames):atlas.alpha_composite(f,((i%4)*96,(i//4)*96))
atlas.save(out/'cat.png')
frames[0].resize((192,192),Image.Resampling.NEAREST).save(out/'icon.png')
im=Image.open(src/'objects.png').convert('RGBA')
props=Image.new('RGBA',(384,96))
for i in range(4):props.alpha_composite(sprite(cell(im,i,0,4,2)),(i*96,0))
props.save(out/'props.png')
for name,col in [('flowers',1),('ring',2),('checkpoint',3)]:sprite(cell(im,col,1,4,2)).save(out/(name+'.png'))
# Crop the opaque interior of the source terrain tile for a solid repeating texture.
tile=cell(im,0,1,4,2);tile=tile.crop((42,26,tile.width-25,tile.height-35));tile.resize((128,128),Image.Resampling.NEAREST).convert('RGB').save(out/'tiles.png')
bg=Image.open(src/'coast.png').convert('RGB').resize((480,270),Image.Resampling.NEAREST).resize((960,540),Image.Resampling.NEAREST);bg.save(out/'background.png')
# Mirror the second panorama to make the repeating edges meet exactly in-game.
bg.transpose(Image.Transpose.FLIP_LEFT_RIGHT).save(out/'background-reverse.png')
gif=[]
for i in [4,5,6,7]*3:
 scene=bg.resize((480,270),Image.Resampling.NEAREST).convert('RGBA')
 f=frames[i].resize((192,192),Image.Resampling.NEAREST);scene.alpha_composite(f,(144,68));gif.append(scene.convert('RGB'))
gif[0].save(root/'releases/Mia-correndo.gif',save_all=True,append_images=gif[1:],duration=95,loop=0)
print('Packed: 16 Mia frames, 4 props, 3 decorative sprites, terrain, 2 panoramas, icon, GIF.')
