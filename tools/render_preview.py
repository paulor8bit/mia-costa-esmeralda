from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import json,sys,math
root=Path(__file__).resolve().parents[1]
canvas=Image.new('RGBA',(960,540));color=(255,255,255,255);width=1;size=16;cache={}
fontpath='/system/fonts/Roboto-Regular.ttf'
for line in Path(sys.argv[1]).read_text().splitlines():
 op,*v=json.loads(line)
 if op=='color':color=tuple(round(max(0,min(1,x))*255) for x in v)
 elif op=='font':size=v[0]
 elif op=='width':width=max(1,round(v[0]))
 elif op in ('rect','ellipse','text'):
  layer=Image.new('RGBA',canvas.size);d=ImageDraw.Draw(layer)
  if op=='text':
   text,x,y,w,align=v
   try:font=ImageFont.truetype(fontpath,size)
   except OSError:font=ImageFont.load_default(size=size)
   if align=='center':x+=(w-d.textlength(text,font=font))/2
   d.text((x,y-2),text,font=font,fill=color)
  else:
   mode,x,y,w,h,*rad=v
   if op=='ellipse':box=(x-w,y-h,x+w,y+h)
   else:box=(x,y,x+max(0,w)-1,y+max(0,h)-1)
   if box[2]<box[0] or box[3]<box[1]:continue
   kw={'fill':color} if mode=='fill' else {'outline':color,'width':width}
   if op=='ellipse':d.ellipse(box,**kw)
   else:d.rounded_rectangle(box,radius=rad[0] if rad else 0,**kw)
  canvas=Image.alpha_composite(canvas,layer)
 elif op=='image':
  path,qx,qy,qw,qh,x,y,sx,sy,ox,oy=v
  if path not in cache:cache[path]=Image.open(root/'game'/path).convert('RGBA')
  src=cache[path];qx,qy,qw,qh=map(round,(qx,qy,qw,qh))
  tw,th=src.size
  tiled=Image.new('RGBA',(max(tw,qx+qw),max(th,qy+qh)))
  for ty in range(0,tiled.height,th):
   for tx in range(0,tiled.width,tw):tiled.paste(src,(tx,ty))
  im=tiled.crop((qx,qy,qx+qw,qy+qh));im=im.resize((max(1,round(qw*abs(sx))),max(1,round(qh*abs(sy)))),Image.Resampling.NEAREST)
  if sx<0:im=im.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
  left=round(x-ox*sx) if sx>0 else round(x-(qw-ox)*abs(sx))
  top=round(y-oy*sy)
  if left>960 or top>540 or left+im.width<0 or top+im.height<0:continue
  canvas.alpha_composite(im,(left,top))
canvas.convert('RGB').save(sys.argv[2])
