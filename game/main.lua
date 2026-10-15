local world=require('world')
local s,screen='title','title'
local g=love.graphics
local assets,quads,fonts,sounds={},{},{},{}
local W,H=960,540
local view={scale=1,x=0,y=0}
local held,touchKeys={},{}
local pendingJump=false
local accumulator=0
local muted=false
local best=0
local music
local palette={ink={.13,.11,.23},white={1,.96,.84},mint={.62,.94,.72},pink={1,.58,.70}}
local function color(c) g.setColor(c) end
local function rect(x,y,w,h,c,r) color(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h,r or 0) end
local function label(t,x,y,size,c) g.setFont(fonts[size] or fonts[16]);color(c or palette.white);g.print(t,x,y) end
local function center(t,y,size,c) g.setFont(fonts[size] or fonts[16]);color(c or palette.white);g.printf(t,0,y,W,'center') end
local function clock(t) return string.format('%d:%02d',math.floor(t/60),math.floor(t%60)) end
local function image(name,x,y,sx,sy) color({1,1,1});g.draw(assets[name],math.floor(x),math.floor(y),0,sx or 1,sy or sx or 1) end
local function sound(name) if not muted and sounds[name] then sounds[name]:stop();sounds[name]:play() end end
local function panel(x,y,w,h)
 rect(x+4,y+5,w,h,{.10,.08,.20,.55},5)
 rect(x,y,w,h,{.16,.16,.29,.95},5)
 g.setColor(.96,.80,.55);g.setLineWidth(2);g.rectangle('line',x+2,y+2,w-4,h-4,4)
 g.setColor(.45,.51,.58);g.setLineWidth(1);g.rectangle('line',x+6,y+6,w-12,h-12,2)
end
local function resize() local w,h=g.getDimensions();view.scale=math.min(w/W,h/H);view.x=(w-W*view.scale)/2;view.y=(h-H*view.scale)/2 end
local function localXY(x,y) return (x-view.x)/view.scale,(y-view.y)/view.scale end
local function inside(x,y,a,b,w,h) return x>=a and x<=a+w and y>=b and y<=b+h end
local function fresh() s=world.new();screen='playing';pendingJump=false;held={};touchKeys={};accumulator=0;if music and not muted then music:play() end end
local function pause() if screen=='playing' then screen='paused';if music then music:pause() end elseif screen=='paused' then screen='playing';if music and not muted then music:play() end end end
local function saveBest() if s.score>best then best=s.score;love.filesystem.write('best.txt',tostring(best)) end end
function love.load()
 if love.system.getOS()=='Android' then love.window.setFullscreen(true,'desktop') end
 g.setDefaultFilter('nearest','nearest');love.window.setTitle('Velocity: Aventura da Mia')
 for _,size in ipairs({12,14,16,18,22,28,40,56}) do fonts[size]=g.newFont(size) end
 for _,name in ipairs({'cat','tiles','props','background','background-reverse','icon','flowers','ring','checkpoint'}) do assets[name]=g.newImage('assets/'..name..'.png') end
 assets.tiles:setWrap('repeat','repeat')
 local sw,sh=assets.cat:getDimensions();for row=0,3 do for col=0,3 do quads[#quads+1]=g.newQuad(col*sw/4,row*sh/4,sw/4,sh/4,sw,sh) end end
 for _,name in ipairs({'jump','ring','hurt','death','charge','spring','checkpoint','hit','win'}) do sounds[name]=love.audio.newSource('assets/'..name..'.wav','static') end
 music=love.audio.newSource('assets/music.wav','stream');music:setLooping(true);music:setVolume(.28)
 if love.filesystem.getInfo('best.txt') then best=tonumber(love.filesystem.read('best.txt')) or 0 end
 s=world.new();resize()
end
function love.resize() resize() end
local function down(name) return held[name] or touchKeys[name] end
local function refreshTouch()
 local before=touchKeys.jump;touchKeys={}
 for _,id in ipairs(love.touch.getTouches()) do local x,y=love.touch.getPosition(id);x,y=localXY(x,y)
  if y>435 then if x<112 then touchKeys.left=true elseif x<220 then touchKeys.right=true elseif x<332 then touchKeys.down=true elseif x>780 then touchKeys.jump=true end end
 end
 if touchKeys.jump and not before then pendingJump=true end
end
function love.touchpressed(id,x,y) x,y=localXY(x,y);if screen~='playing' then
 if inside(x,y,310,335,340,58) then if screen=='paused' then pause() else fresh() end end
 elseif inside(x,y,850,12,96,40) then pause() elseif inside(x,y,850,60,96,32) then muted=not muted;if muted then music:pause() else music:play() end else refreshTouch() end end
function love.touchreleased() refreshTouch() end
function love.touchmoved() refreshTouch() end
function love.mousepressed(x,y,button,istouch)
 if istouch or button~=1 then return end
 x,y=localXY(x,y)
 if screen~='playing' and inside(x,y,310,335,340,58) then if screen=='paused' then pause() else fresh() end
 elseif screen=='playing' and inside(x,y,850,12,96,40) then pause()
 elseif inside(x,y,850,60,96,32) then muted=not muted;if muted then music:pause() else music:play() end end
end
function love.keypressed(key,scancode,isrepeat)
 if key=='escape' or key=='p' or key=='acback' then pause();return end
 if key=='m' then muted=not muted;if muted then music:pause() elseif screen=='playing' then music:play() end;return end
 if screen~='playing' and (key=='return' or key=='space') then if screen=='paused' then pause() else fresh() end;return end
 held[key]=true
 if not isrepeat and (key=='space' or key=='up' or key=='w') then pendingJump=true end
end
function love.keyreleased(key) held[key]=nil end
function love.focus(f) if not f then held={};touchKeys={};pendingJump=false;if screen=='playing' then pause() end end end
function love.update(dt)
 if screen~='playing' then return end
 accumulator=accumulator+math.min(dt,.1)
 while accumulator>=1/60 do
  world.step(s,{left=down('left') or held.a,right=down('right') or held.d,down=down('down') or held.s,jump=pendingJump,jumpHeld=down('jump') or held.space or held.up or held.w});pendingJump=false
  local heard={};for _,e in ipairs(s.events) do if not heard[e] then sound(e);heard[e]=true end end
  if s.status=='win' or s.status=='over' then screen=s.status;saveBest();music:pause() end
  accumulator=accumulator-1/60
 end
end
local function drawCat(x,y,scale,frame,face)
 local cw,ch=assets.cat:getWidth()/4,assets.cat:getHeight()/4
 g.setColor(1,1,1);g.draw(assets.cat,quads[frame],math.floor(x),math.floor(y),0,scale*(face or 1),scale,cw/2,ch*.875)
end
local function prop(index,x,y,scale)
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
local function drawWorld()
 rect(0,0,W,H,{.18,.51,.72})
 local bgw=assets.background:getWidth();local scroll=s.camera*.14;local tile=math.floor(scroll/bgw);local shift=scroll%bgw
 image(tile%2==0 and 'background' or 'background-reverse',-shift,0)
 image(tile%2==0 and 'background-reverse' or 'background',bgw-shift,0)
 local camera=s.camera
 -- Raster soil follows the collision surface; turf adds a lit grassy edge.
 local tw,th=assets.tiles:getDimensions()
 for x=math.floor(camera/8)*8,camera+W+8,8 do
  local gy=world.ground(x+4)
  if gy<700 then
   local q=g.newQuad(x%tw,gy%th,8,math.max(1,H-gy),tw,th)
   g.setColor(1,1,1);g.draw(assets.tiles,q,math.floor(x-camera),math.floor(gy))
   turf(x-camera,gy,8,x)
  end
 end
 for x=400,world.length,740 do local gy=world.ground(x);if gy<700 and x-camera> -70 and x-camera<W+70 then prop(1,x-camera,gy,2.6) end end
 for x=245,world.length,173 do local gy=world.ground(x);if gy<700 and x-camera> -50 and x-camera<W+50 then decor('flowers',x-camera,gy+2,32+(x%3)*5) end end
 for _,p in ipairs(world.platforms) do
  local q=g.newQuad(p[1]%tw,0,p[3],26,tw,th);g.setColor(1,1,1);g.draw(assets.tiles,q,p[1]-camera,p[2]);turf(p[1]-camera,p[2],p[3],p[1])
 end
 for _,r in ipairs(s.rings) do if not r.taken and r.x-camera> -20 and r.x-camera<W+20 then
  decor('ring',r.x-camera,r.y+12+math.sin(s.time*3+r.x)*2,28,math.max(.20,math.abs(math.cos(s.time*4))))
 end end
 for _,e in ipairs(s.enemies) do if e.alive and math.abs(e.x-camera-W/2)<W/2+50 then prop(2,e.x-camera,e.y+18,1) end end
 for _,x in ipairs(world.springs) do prop(3,x-camera,world.ground(x),.65) end
 local cx=4470-camera;decor('checkpoint',cx,world.ground(4470),100)
 if s.checkpointActive then decor('ring',cx+22,world.ground(4470)-75,24) end
 local b=s.boss
 if b.hp>0 and not(b.hit>0 and math.floor(b.hit/4)%2==1) then prop(4,b.x-camera,b.y+40,1.5) end
 local fx=8660-camera;rect(fx,300,6,110,{.93,.95,.84});for a=0,5 do for b2=0,3 do rect(fx+6+a*9,300+b2*9,9,9,(a+b2)%2==0 and palette.white or palette.ink) end end
 for _,q in ipairs(s.particles) do rect(q.x-camera,q.y,4,4,q.kind=='gold' and {1,.85,.35} or palette.pink) end
 local p=s.p
 if not(s.invincible>0 and math.floor(s.invincible/5)%2==1) then
  local frame=math.floor(s.time*4)%4+1
  if not p.grounded then frame=p.vy< -2 and 9 or p.vy<2 and 10 or 11 elseif s.charge>0 or p.rolling then frame=12+math.floor(s.time*14)%2 elseif math.abs(p.vx)>1 then frame=5+math.floor(s.time*math.max(7,math.abs(p.vx)*1.6))%4 end
  if p.grounded then g.setColor(.08,.14,.21,.24);g.ellipse('fill',p.x-camera,p.y+17,23,5) end
  drawCat(p.x-camera,p.y+18,84/(assets.cat:getWidth()/4),frame,p.face)
 end
 if s.charge>0 then center('IMPULSO '..math.floor(s.charge/12*100)..'%',398,18,palette.mint) end
 if p.x>7520 and b.hp>0 then
  center('GUARDIAO MECANICO',70,14)
  for i=1,6 do rect(400+(i-1)*28,92,23,6,i<=b.hp and palette.pink or palette.ink) end
 end
end
local function button(x,y,w,h,t,active)
 local fill=active and {.94,.64,.69,.98} or {.13,.17,.27,.83}
 rect(x+2,y+3,w,h,{.08,.08,.17,.42},6);rect(x,y,w,h,fill,6)
 g.setLineWidth(2);g.setColor(active and 1 or .69,active and .88 or .77,active and .72 or .68,.85);g.rectangle('line',x+2,y+2,w-4,h-4,4)
 rect(x+8,y+5,w-16,2,active and {1,.86,.78,.7} or {.69,.83,.78,.25})
 g.setFont(fonts[18]);color(active and palette.ink or palette.white);g.printf(t,x,y+h/2-11,w,'center')
end
local function hud()
 panel(18,15,225,103)
 label('MIA / COSTA ESMERALDA',30,24,12,palette.mint)
 label(string.format('%07d',s.score),30,44,22)
 label('ANEIS '..s.count..'   VIDAS '..s.lives,30,77,14,{1,.85,.42})
 label(clock(s.time),272,24,18)
 rect(354,32,280,4,{.05,.23,.29});rect(354,32,280*s.p.x/world.length,4,palette.mint)
 button(850,12,96,40,'II  PAUSA')
 button(850,60,96,32,muted and 'SEM SOM' or 'SOM')
 if love.system.getOS()=='Android' or #love.touch.getTouches()>0 then
  button(18,446,86,76,'<',down('left'));button(120,446,86,76,'>',down('right'));button(226,446,94,76,'ROLAR',down('down'));button(798,440,140,82,'PULAR',down('jump'))
 else label('A D / SETAS   ESPACO: PULO   BAIXO + PULO: IMPULSO   P: PAUSA',180,514,12) end
end
local function menu()
 rect(0,0,W,H,{.08,.12,.21,.34})
 panel(225,80,510,356)
 label('MIA / COSTA ESMERALDA',262,106,16,palette.mint)
 decor('flowers',259,438,74);decor('flowers',706,438,74)
 local title,desc,cta='Aventura da Mia','Uma gatinha. Um litoral inteiro para explorar.','JOGAR AGORA'
 if screen=='paused' then title='Hora do cochilo';desc='A corrida continua quando voce quiser.';cta='CONTINUAR'
 elseif screen=='win' then title='Miau! Voce venceu!';desc='Pontos: '..s.score..'   Tempo: '..clock(s.time);cta='CORRER DE NOVO'
 elseif screen=='over' then title='Mais uma chance?';desc='Mia ainda tem muitas aventuras pela frente.';cta='TENTAR NOVAMENTE' end
 center(title,161,40)
 center(desc,222,16,{.73,.83,.85})
 drawCat(480,322,98/(assets.cat:getWidth()/4),screen=='win' and 14 or (math.floor(love.timer.getTime()*3)%4+1),1)
 button(310,335,340,58,cta,true)
 center('Recorde: '..best..'  |  Enter para jogar',407,12,{.64,.77,.8})
 if screen=='title' then center('Colete aneis, pule nos robos e derrote o guardiao.',464,16) end
end
function love.draw()
 g.clear(.02,.05,.09);g.push();g.translate(view.x,view.y);g.scale(view.scale)
 g.setScissor(view.x,view.y,W*view.scale,H*view.scale)
 drawWorld()
 if screen=='playing' then hud() else menu() end
 g.setScissor();g.pop()
end
