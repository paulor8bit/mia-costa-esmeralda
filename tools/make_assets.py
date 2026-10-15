from PIL import Image, ImageDraw
from pathlib import Path
import math, random, wave, struct
root=Path(__file__).resolve().parents[1]; out=root/'game/assets';out.mkdir(exist_ok=True)
INK='#29334e'; FUR='#f4c1a2'; LIGHT='#ffe5c4'; PINK='#ee759b'; MINT='#64d6ba'
def cat(frame):
 im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im)
 bob=[0,1,0,-1][frame%4]; y=18+bob
 if frame in (11,12):
  d.ellipse((13,13,51,51),fill=INK);d.ellipse((16,16,48,48),fill=FUR);d.arc((21,21,44,44),20,300,fill=PINK,width=4);d.polygon([(19,21),(20,10),(29,20)],fill=FUR);d.ellipse((35,23,40,28),fill=INK)
  return im
 d.line([(18,43+bob),(8,36+bob),(7,26+bob),(12,24+bob)],fill=INK,width=8);d.line([(18,43+bob),(8,36+bob),(7,26+bob),(12,24+bob)],fill=FUR,width=4)
 stride=([-5,0,5,0][frame%4] if 4<=frame<=7 else 0)
 if frame in (8,9,10): stride=5
 for x,off in [(26,stride),(39,-stride)]:
  d.rectangle((x-4,39+bob,x+3,49+off),fill=INK);d.rectangle((x-2,40+bob,x+1,48+off),fill=FUR);d.rounded_rectangle((x-5,47+off,x+8,53+off),radius=2,fill=INK);d.rectangle((x-3,48+off,x+6,51+off),fill=MINT)
 d.ellipse((19,28+bob,46,46+bob),fill=INK);d.ellipse((22,30+bob,43,44+bob),fill=FUR);d.ellipse((28,32+bob,39,43+bob),fill=LIGHT)
 d.polygon([(19,y+8),(18,y-10),(31,y-1),(40,y-3),(48,y-11),(50,y+11)],fill=INK)
 d.polygon([(22,y+7),(21,y-6),(31,y+2),(40,y),(46,y-6),(47,y+10)],fill=FUR)
 d.polygon([(23,y-3),(24,y+3),(28,y+1)],fill=PINK);d.polygon([(43,y+1),(46,y-3),(46,y+5)],fill=PINK)
 d.ellipse((18,y,51,y+25),fill=INK);d.ellipse((21,y+2,48,y+22),fill=FUR);d.ellipse((31,y+13,46,y+21),fill=LIGHT)
 if frame==2: d.line((29,y+9,34,y+9),fill=INK,width=2);d.line((40,y+9,45,y+9),fill=INK,width=2)
 else:
  for x in (29,41): d.rectangle((x,y+7,x+4,y+13),fill=INK);d.point((x+1,y+8),fill='white')
 d.polygon([(36,y+14),(40,y+14),(38,y+17)],fill=PINK);d.line((38,y+17,38,y+19),fill=INK)
 for x in (21,44):d.line((x,y+16,x+7,y+17),fill='#bf7f7a',width=1)
 d.polygon([(18,y-3),(24,y-6),(26,y-1),(31,y-5),(31,y+3),(25,y+1),(21,y+4)],fill=PINK)
 d.rectangle((24,28+bob,43,31+bob),fill=PINK)
 if frame>=13:d.line((42,35,53,25),fill=FUR,width=6)
 return im
sheet=Image.new('RGBA',(256,256));frames=[cat(i) for i in range(16)]
for i,f in enumerate(frames):sheet.paste(f,((i%4)*64,(i//4)*64))
sheet.save(out/'cat.png')
frames[0].resize((192,192),Image.Resampling.NEAREST).save(out/'icon.png')
gif=[]
for f in frames[4:8]*3:
 bg=Image.new('RGB',(256,192),'#163247');bg.paste(f.resize((192,192),Image.Resampling.NEAREST),(32,0),f.resize((192,192),Image.Resampling.NEAREST));gif.append(bg)
gif[0].save(root/'releases/Mia-correndo.gif',save_all=True,append_images=gif[1:],duration=90,loop=0)
im=Image.new('RGB',(64,64));d=ImageDraw.Draw(im)
for y in range(0,64,16):
 for x in range(0,64,16):d.rectangle((x,y,x+15,y+15),fill='#a46b47' if (x//16+y//16)%2 else '#7c4a3a');d.line((x+2,y+3,x+12,y+3),fill='#bb8558',width=2)
im.save(out/'tiles.png')
im=Image.new('RGBA',(256,64));d=ImageDraw.Draw(im)
d.rectangle((28,20,36,63),fill='#ae744c');d.line((31,22,33,62),fill='#e5b778',width=3)
for a in range(6):
 angle=a*math.pi/3;cx=32+math.cos(angle)*18;cy=20+math.sin(angle)*10;d.ellipse((cx-15,cy-7,cx+15,cy+7),fill='#32674d');d.line((32,20,cx,cy),fill='#88c871',width=2)
# robot crab
for x in (72,102): d.line((x,48,x-5,57),fill=INK,width=4)
d.ellipse((72,29,119,53),fill=INK);d.ellipse((75,32,116,49),fill='#e55b71')
for x in (82,103):d.rectangle((x,24,x+7,38),fill=INK);d.rectangle((x+2,26,x+5,31),fill='#fff2aa')
d.rectangle((83,44,106,47),fill='#823d59')
# spring
for y in range(37,57,5):d.line((144,y,177,y+3),fill='#c4d6e6',width=3)
d.rectangle((140,30,181,38),fill=INK);d.rectangle((143,31,178,35),fill='#e65d88');d.rectangle((140,57,181,62),fill='#34566b')
# boss
for x in (198,235):d.rectangle((x,46,x+13,62),fill=INK)
d.rounded_rectangle((195,13,251,51),radius=8,fill=INK);d.rounded_rectangle((198,16,248,48),radius=7,fill='#63849a');d.rectangle((204,23,242,32),fill='#243348')
for x in (210,230):d.rectangle((x,25,x+7,29),fill='#f78591')
d.rectangle((211,38,237,42),fill='#e5c86b');d.line((222,14,222,4),fill=INK,width=3);d.ellipse((219,1,225,7),fill=PINK)
im.save(out/'props.png')
im=Image.new('RGB',(960,540));d=ImageDraw.Draw(im)
for y in range(540):t=y/540;d.line((0,y,960,y),fill=(int(54+100*t),int(143+62*t),int(184+33*t)))
d.ellipse((690,45,776,131),fill='#fff1b1')
for x,y in [(70,60),(270,100),(470,40),(820,145)]:
 for dx,dy,r in [(0,0,18),(24,-8,25),(52,1,17)]:d.ellipse((x+dx-r,y+dy-r,x+dx+r,y+dy+r),fill='#d6efe4')
for x,y in [(-100,285),(190,260),(510,295),(780,245)]:d.polygon([(x,360),(x+145,y-90),(x+320,360)],fill='#5aa8a4');d.polygon([(x+145,y-90),(x+205,y+12),(x+153,y)],fill='#95cbb6')
d.rectangle((0,350,960,540),fill='#398faf')
for y in range(364,540,15):
 for x in range((y*13)%60,960,80):d.line((x,y,x+35,y),fill='#7cc6cb',width=2)
im.save(out/'background.png')
# synthesized original audio
RATE=22050
def wav(name,notes,duration,volume=.2):
 samples=[]
 for freq in notes:
  for i in range(int(duration*RATE)):
   t=i/RATE;env=min(1,t*60)*max(0,1-t/duration);v=math.sin(2*math.pi*freq*t)+.22*math.sin(4*math.pi*freq*t);samples.append(int(32767*volume*env*v))
 with wave.open(str(out/(name+'.wav')),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(struct.pack('<'+'h'*len(samples),*samples))
for name,notes in {'jump':[440,660,880],'ring':[1108,1661],'hurt':[220,150,90],'death':[440,330,220,110],'charge':[220,330,440],'spring':[330,660,990,1320],'checkpoint':[523,659,784],'hit':[160,80],'win':[523,659,784,1046,784,1046]}.items():wav(name,notes,.075)
wav('music',[261,330,392,523,392,330,294,392,440,587,440,392,330,440,523,659,523,440,392,494,587,784,587,494]*4,.17,.12)
print('Assets, sprites de 16 quadros, áudio e GIF gerados.')
