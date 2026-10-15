local M={length=8800,platforms={{1060,300,180},{1340,245,170},{2200,285,220},{3940,285,180},{4260,230,180},{4700,290,180},{6380,255,210}},springs={1780,3300,4930,6680}}
function M.ground(x)
 if x>2720 and x<2890 or x>5110 and x<5290 then return 800 end
 if x<700 then return 410 elseif x<1300 then return 410-90*math.sin((x-700)/600*math.pi) elseif x<1900 then return 410 elseif x<2500 then return 410-110*math.sin((x-1900)/600*math.pi) elseif x<3400 then return 410 elseif x<3900 then return 410-(x-3400)*.18 elseif x<4400 then return 320+(x-3900)*.18 elseif x<5600 then return 410 elseif x<6200 then return 410-105*math.sin((x-5600)/600*math.pi) else return 410 end
end
function M.new()
 local s={p={x=100,y=370,vx=0,vy=0,face=1,grounded=false},rings={},enemies={},particles={},boss={x=8060,y=335,hp=6,hit=0,phase=0},time=0,score=0,count=0,lives=3,checkpoint=100,checkpointActive=false,invincible=0,charge=0,camera=0,status='playing',events={}}
 for x=300,7500,230 do for i=0,4 do local rx=x+i*26;if M.ground(rx)<700 then table.insert(s.rings,{x=rx,y=M.ground(rx)-35-18*math.sin(i/4*math.pi)}) end end end
 for _,f in ipairs(M.platforms) do for i=0,4 do table.insert(s.rings,{x=f[1]+25+i*28,y=f[2]-35}) end end
 for _,x in ipairs({920,1570,2060,2500,3150,3600,4530,4840,5500,6110,6800,7190}) do table.insert(s.enemies,{x=x,home=x,y=M.ground(x)-16,alive=true}) end
 return s
end
local function emit(s,e) s.events[#s.events+1]=e end
function M.burst(s,x,y,kind,n)
 for i=1,n or 12 do table.insert(s.particles,{x=x,y=y,vx=(math.random()-.5)*6,vy=-math.random()*6,t=35,kind=kind}) end
end
function M.respawn(s)
 s.lives=s.lives-1;emit(s,'death')
 if s.lives<=0 then s.status='over';return end
 local p=s.p;p.x=s.checkpoint;p.y=M.ground(p.x)-40;p.vx=0;p.vy=0;p.grounded=false;s.count=0;s.charge=0;s.invincible=150;s.camera=math.max(0,p.x-240)
end
function M.hurt(s,x)
 if s.invincible>0 then return end
 if s.count>0 then M.burst(s,s.p.x,s.p.y,'gold',math.min(30,s.count));s.count=0;s.p.vx=s.p.x<x and -6 or 6;s.p.vy=-7;s.p.grounded=false;s.invincible=130;emit(s,'hurt') else M.respawn(s) end
end
function M.step(s,input)
 s.events={};if s.status~='playing' then return end
 s.time=s.time+1/60;s.invincible=math.max(0,s.invincible-1)
 local p=s.p;local oldY=p.y;local dir=(input.right and 1 or 0)-(input.left and 1 or 0)
 if dir~=0 then p.face=dir end
 if p.grounded then
  if input.down and math.abs(p.vx)<1.6 then p.vx=p.vx*.8;if input.jump then s.charge=math.min(12,s.charge+3);emit(s,'charge') end
  else
   p.vx=p.vx+dir*.24;if dir==0 then p.vx=p.vx*(input.down and .993 or .96) end
   p.vx=p.vx+(M.ground(p.x+3)-M.ground(p.x-3))*.027
   if input.jump then p.vy=-10.8;p.grounded=false;emit(s,'jump') end
  end
  if s.charge>0 and not input.down then p.vx=p.face*(8+s.charge*.65);s.charge=0;emit(s,'charge') end
 else p.vx=p.vx+dir*.11;p.vy=p.vy+.44;if not input.jumpHeld and p.vy< -4 then p.vy=p.vy+.4 end end
 p.vx=math.max(-15,math.min(15,p.vx));p.rolling=input.down or not p.grounded
 p.x=math.max(20,math.min(M.length-30,p.x+p.vx));p.y=p.y+p.vy
 local floor=M.ground(p.x)
 for _,f in ipairs(M.platforms) do if p.x>f[1]-10 and p.x<f[1]+f[3]+10 and oldY+18<=f[2]+3 and p.vy>=0 then floor=math.min(floor,f[2]) end end
 if p.y+18>=floor and p.vy>=0 and oldY+18<=floor+math.max(24,math.abs(p.vx)*.4) then p.y=floor-18;p.vy=0;p.grounded=true else p.grounded=false end
 if p.y>650 then M.respawn(s);return end
 for _,r in ipairs(s.rings) do if not r.taken and (p.x-r.x)^2+(p.y-r.y)^2<900 then r.taken=true;s.count=s.count+1;s.score=s.score+100;M.burst(s,r.x,r.y,'gold',3);emit(s,'ring') end end
 for _,e in ipairs(s.enemies) do if e.alive then
  e.x=e.home+math.sin(s.time*1.5+e.home)*45;e.y=M.ground(e.x)-16
  if math.abs(p.x-e.x)<30 and math.abs(p.y-e.y)<30 then
   if p.vy>1 and oldY<e.y-12 or p.rolling and math.abs(p.vx)>4 then e.alive=false;p.vy=-7;p.grounded=false;s.score=s.score+500;M.burst(s,e.x,e.y,'pink');emit(s,'hit') else M.hurt(s,e.x) end
  end
 end end
 for _,x in ipairs(M.springs) do if math.abs(p.x-x)<20 and p.y+18>=M.ground(x)-8 and p.vy>=0 then p.vy=-16;p.grounded=false;emit(s,'spring') end end
 if not s.checkpointActive and p.x>4400 then s.checkpointActive=true;s.checkpoint=4470;s.score=s.score+1000;emit(s,'checkpoint') end
 local b=s.boss
 if b.hp>0 then
  b.phase=b.phase+.025;b.x=8060+math.sin(b.phase)*125;b.y=335+math.sin(b.phase*2)*22;b.hit=math.max(0,b.hit-1)
  if math.abs(p.x-b.x)<51 and math.abs(p.y-b.y)<48 then
   if p.vy>0 and oldY<b.y-22 and b.hit==0 then b.hp=b.hp-1;b.hit=65;p.vy=-12;p.grounded=false;s.score=s.score+1000;M.burst(s,b.x,b.y,'pink',20);emit(s,'hit') elseif b.hit==0 then M.hurt(s,b.x) end
  end
  if p.x>8370 then p.x=8370;p.vx=math.min(0,p.vx) end
 end
 if p.x>8650 and b.hp==0 then s.score=s.score+math.max(0,math.floor(300-s.time)*10);s.status='win';emit(s,'win') end
 for i=#s.particles,1,-1 do local q=s.particles[i];q.x=q.x+q.vx;q.y=q.y+q.vy;q.vy=q.vy+.2;q.t=q.t-1;if q.t<=0 then table.remove(s.particles,i) end end
 s.camera=s.camera+(math.max(0,math.min(M.length-960,p.x-960*.33))-s.camera)*.12
end
return M
