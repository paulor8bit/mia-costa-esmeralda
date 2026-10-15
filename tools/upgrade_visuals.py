from pathlib import Path
p=Path(__file__).resolve().parents[1]/'game/main.lua'
s=p.read_text()
s=s.replace("local palette={ink={.04,.10,.19},white={1,.96,.86},mint={.66,.96,.72},pink={1,.56,.65}}", "local palette={ink={.13,.11,.23},white={1,.96,.84},mint={.62,.94,.72},pink={1,.58,.70}}")
s=s.replace("{'cat','tiles','props','background','icon'}", "{'cat','tiles','props','background','background-reverse','icon','flowers','ring','checkpoint'}")
s=s.replace("local function resize()", "local function panel(x,y,w,h)\n rect(x+4,y+5,w,h,{.10,.08,.20,.55},5)\n rect(x,y,w,h,{.16,.16,.29,.95},5)\n g.setColor(.96,.80,.55);g.setLineWidth(2);g.rectangle('line',x+2,y+2,w-4,h-4,4)\n g.setColor(.45,.51,.58);g.setLineWidth(1);g.rectangle('line',x+6,y+6,w-12,h-12,2)\nend\nlocal function resize()",1)
s=s.replace("cw/2,ch*.76)", "cw/2,ch*.875)")
a=s.index('local function prop(');b=s.index('local function drawWorld()',a)
s=s[:a]+'''local function prop(index,x,y,scale)
 local cell=assets.props:getHeight()
 local q=g.newQuad((index-1)*cell,0,cell,cell,assets.props:getDimensions())
 local k=(scale or 1)*64/cell
 g.setColor(1,1,1);g.draw(assets.props,q,math.floor(x),math.floor(y),0,k,k,cell/2,cell*.875)
end
local function decor(name,x,y,size,squash)
 local im=assets[name];local k=size/im:getWidth()
 g.setColor(1,1,1);g.draw(im,math.floor(x),math.floor(y),0,k*(squash or 1),k,im:getWidth()/2,im:getHeight()*.875)
end
local function turf(x,y,width,seed)
 rect(x,y,width,12,{.10,.34,.28})
 rect(x,y,width,7,{.21,.55,.31});rect(x,y,width,3,{.60,.80,.37})
 for dx=0,width-2,2 do
  local n=(seed+dx*7)%11
  rect(x+dx,y-2-n%4,2,3+n%4,n<5 and {.70,.87,.43} or {.35,.66,.32})
  if n<3 then rect(x+dx,y+7,2,4,{.34,.62,.28}) end
 end
end
''' +s[b:]
s=s.replace("local bgw=assets.background:getWidth();local shift=(s.camera*.14)%bgw\n image('background',-shift,0);image('background',bgw-shift,0)", "local bgw=assets.background:getWidth();local scroll=s.camera*.14;local tile=math.floor(scroll/bgw);local shift=scroll%bgw\n image(tile%2==0 and 'background' or 'background-reverse',-shift,0)\n image(tile%2==0 and 'background-reverse' or 'background',bgw-shift,0)")
s=s.replace("-- Smooth surface geometry; the soil uses a repeated raster checker tile.", "-- Raster soil follows the collision surface; turf adds a lit grassy edge.\n local tw,th=assets.tiles:getDimensions()")
s=s.replace("g.newQuad(x%64,gy%64,8,math.max(1,H-gy),64,64)", "g.newQuad(x%tw,gy%th,8,math.max(1,H-gy),tw,th)")
s=s.replace("rect(x-camera,gy,8,7,{.16,.48,.28});rect(x-camera,gy,8,3,{.63,.87,.43})", "turf(x-camera,gy,8,x)")
s=s.replace("for x=400,world.length,590 do", "for x=400,world.length,740 do").replace("prop(1,x-camera,gy,1.6)", "prop(1,x-camera,gy,2.6)")
s=s.replace(" for _,p in ipairs(world.platforms) do\n  rect(p[1]-camera,p[2],p[3],22,{.47,.29,.24});rect(p[1]-camera,p[2],p[3],7,{.47,.78,.37})\n  for x=0,p[3]-16,24 do rect(p[1]+x-camera,p[2]+12,12,5,{.68,.43,.29}) end\n end", " for x=245,world.length,173 do local gy=world.ground(x);if gy<700 and x-camera> -50 and x-camera<W+50 then decor('flowers',x-camera,gy+2,32+(x%3)*5) end end\n for _,p in ipairs(world.platforms) do\n  local q=g.newQuad(p[1]%tw,0,p[3],26,tw,th);g.setColor(1,1,1);g.draw(assets.tiles,q,p[1]-camera,p[2]);turf(p[1]-camera,p[2],p[3],p[1])\n end")
s=s.replace("local xx=r.x-camera;g.setColor(1,.83,.32);g.setLineWidth(3);g.ellipse('line',xx,r.y,math.max(2,math.abs(math.cos(s.time*4))*7),10);rect(xx-3,r.y-7,3,4,{1,1,.78})", "decor('ring',r.x-camera,r.y+12+math.sin(s.time*3+r.x)*2,28,math.max(.20,math.abs(math.cos(s.time*4))))")
s=s.replace("local cx=4470-camera;rect(cx,world.ground(4470)-80,5,80,{.86,.89,.86});rect(cx+5,world.ground(4470)-80,38,24,s.checkpointActive and palette.mint or palette.pink)", "local cx=4470-camera;decor('checkpoint',cx,world.ground(4470),100)\n if s.checkpointActive then decor('ring',cx+22,world.ground(4470)-75,24) end")
s=s.replace("elseif s.charge>0 or p.rolling then frame=12", "elseif s.charge>0 or p.rolling then frame=12+math.floor(s.time*14)%2")
s=s.replace("drawCat(p.x-camera,p.y+18,64/(assets.cat:getWidth()/4),frame,p.face)", "if p.grounded then g.setColor(.08,.14,.21,.24);g.ellipse('fill',p.x-camera,p.y+17,23,5) end\n  drawCat(p.x-camera,p.y+18,84/(assets.cat:getWidth()/4),frame,p.face)")
a=s.index('local function button(');b=s.index('local function hud()',a)
s=s[:a]+'''local function button(x,y,w,h,t,active)
 local fill=active and {.94,.64,.69,.98} or {.13,.17,.27,.83}
 rect(x+2,y+3,w,h,{.08,.08,.17,.42},6);rect(x,y,w,h,fill,6)
 g.setLineWidth(2);g.setColor(active and 1 or .69,active and .88 or .77,active and .72 or .68,.85);g.rectangle('line',x+2,y+2,w-4,h-4,4)
 rect(x+8,y+5,w-16,2,active and {1,.86,.78,.7} or {.69,.83,.78,.25})
 g.setFont(fonts[18]);color(active and palette.ink or palette.white);g.printf(t,x,y+h/2-11,w,'center')
end
''' +s[b:]
s=s.replace("rect(18,15,225,103,{.025,.10,.18,.9},9)", "panel(18,15,225,103)")
s=s.replace("rect(0,0,W,H,{.02,.07,.14,.79})\n rect(225,80,510,356,{.035,.12,.20,.96},18)", "rect(0,0,W,H,{.08,.12,.21,.34})\n panel(225,80,510,356)")
s=s.replace("label('VELOCITY',262,106,16,palette.mint)", "label('MIA / COSTA ESMERALDA',262,106,16,palette.mint)\n decor('flowers',259,438,74);decor('flowers',706,438,74)")
s=s.replace("78/(assets.cat:getWidth()/4)", "98/(assets.cat:getWidth()/4)")
p.write_text(s)
