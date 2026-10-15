"""Build/sign the embedded LÖVE APK with the existing local development key."""
from pathlib import Path
import io, shutil, struct, subprocess, zipfile
root=Path(__file__).resolve().parents[1];release=root/'releases';release.mkdir(exist_ok=True)
def run(*args):subprocess.run([str(a) for a in args],check=True,cwd=root)
# Sync the launcher icons to the new kitten art.
from PIL import Image
icon=Image.open(root/'game/assets/icon.png')
for p in (root/'android/res').glob('drawable*/love.png'):
 with Image.open(p) as old:size=old.size
 icon.resize(size,Image.Resampling.NEAREST).save(p)
with zipfile.ZipFile(release/'Mia-Costa-Esmeralda.love','w',zipfile.ZIP_DEFLATED) as z:
 for p in sorted((root/'game').rglob('*')):
  if p.is_file():z.write(p,p.relative_to(root/'game'))
shutil.copy2(release/'Mia-Costa-Esmeralda.love',root/'android/assets/game.love')
run('java','-jar',root/'tools/apktool.jar','b','-f',root/'android','--aapt',shutil.which('aapt2'),'-o',release/'mia-unsigned.apk')
with zipfile.ZipFile(release/'mia-unsigned.apk') as src,zipfile.ZipFile(release/'mia-aligned.apk','w') as dst:
 for info in src.infolist():
  data=src.read(info.filename);info.extra=b''
  if info.compress_type==zipfile.ZIP_STORED:
   pad=(-(dst.fp.tell()+30+len(info.filename.encode())+4))%4
   info.extra=b'\xfe\xca'+pad.to_bytes(2,'little')+b'\0'*pad
  dst.writestr(info,data)
final=release/'Mia-Costa-Esmeralda.apk'
run('/data/data/com.termux/files/usr/bin/apksigner','sign','--ks',Path.home()/'.android/debug.keystore','--ks-key-alias','androiddebugkey','--ks-pass','pass:android','--key-pass','pass:android','--out',final,release/'mia-aligned.apk')
subprocess.run(['/data/data/com.termux/files/usr/bin/apksigner','verify',str(final)],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
with zipfile.ZipFile(final) as z:
 assert z.testzip() is None
 with zipfile.ZipFile(io.BytesIO(z.read('assets/game.love'))) as game:
  assert game.testzip() is None
  for p in (root/'game').rglob('*'):
   if p.is_file():assert game.read(str(p.relative_to(root/'game')))==p.read_bytes()
 data=final.read_bytes()
 for info in z.infolist():
  if info.compress_type==zipfile.ZIP_STORED:
   n,e=struct.unpack_from('<HH',data,info.header_offset+26);assert (info.header_offset+30+n+e)%4==0
print('APK assinado e verificado:',final)
