local script=debug.getinfo(1,'S').source:sub(2)
local root=script:match('^(.*)/tools/[^/]+$') or '.'
package.path=root..'/game/?.lua;'..package.path
for _,f in ipairs({'main','world','conf'}) do assert(loadfile(root..'/game/'..f..'.lua')) end
-- During configuration, optional LÖVE modules have not been loaded yet.
love={}
dofile(root..'/game/conf.lua')
local config={window={},modules={}}
love.conf(config)
assert(config.window.fullscreen==false and config.window.width==960,'configuration before modules load')
local w=require('world')
local function step(s,input,n) for i=1,n or 1 do w.step(s,input or {}) end end
local s=w.new();step(s,{},60);assert(s.p.grounded,'spawn settles')
local x=s.p.x;step(s,{right=true},30);assert(s.p.x>x+50,'acceleration')
step(s,{jump=true,jumpHeld=true});assert(s.p.vy<0,'jump')
s=w.new();step(s,{},60);step(s,{down=true,jump=true},4);assert(s.charge==12,'charge');step(s,{});assert(s.p.vx>10,'release boost')
s=w.new();s.count=4;w.hurt(s,s.p.x+10);assert(s.count==0 and s.lives==3 and s.invincible>0,'rings absorb damage');s.invincible=0;w.hurt(s,200);assert(s.lives==2,'death respawns')
s=w.new();s.p.x=4471;s.p.y=350;step(s,{});assert(s.checkpointActive and s.checkpoint==4470,'checkpoint')
s=w.new();s.boss.hp=0;s.p.x=8660;s.p.y=380;step(s,{});assert(s.status=='win','finish')
s=w.new();for i=1,3 do w.respawn(s) end;assert(s.status=='over','game over')
-- Exercise resource loading, drawing, controls and update using a headless LÖVE stub.
local dummy={};setmetatable(dummy,{__index=function(_,k) return function() end end})
local gr={};setmetatable(gr,{__index=function(_,k) return function() end end})
function gr.getDimensions() return 960,540 end
function gr.newImage(p) local sizes={cat={384,384},tiles={128,128},background={960,540},['background-reverse']={960,540},props={384,96},icon={192,192},flowers={96,96},ring={96,96},checkpoint={96,96}};local name=p:match('/(.-)%.png');local size=assert(sizes[name]);return setmetatable({getWidth=function()return size[1]end,getHeight=function()return size[2]end,getDimensions=function()return unpack(size)end},{__index=dummy}) end
function gr.newFont()return dummy end
function gr.newQuad()return dummy end
love={graphics=gr,window=dummy,audio={newSource=function()return dummy end},filesystem={getInfo=function()return nil end,write=function()end},touch={getTouches=function()return {}end},system={getOS=function()return 'Android'end},timer={getTime=function()return 1 end}}
dofile(root..'/game/main.lua');love.load();love.draw();love.keypressed('return');love.keypressed('right');for i=1,120 do love.update(1/60);love.draw() end;love.keyreleased('right');love.touchpressed(1,900,70);love.keypressed('p');love.draw();love.keypressed('p');love.focus(false);love.draw()
print('OK: Lua, movimento, pulo, impulso, dano, checkpoint, fim de jogo, carregamento e desenho com stub.')
