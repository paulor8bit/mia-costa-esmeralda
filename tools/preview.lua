-- Record the game's actual draw calls for an offline art preview (no GPU required).
package.path='velocity-love/game/?.lua;'..package.path
local capture=false
local function json(v)
 if type(v)=='table' then local a={};for _,x in ipairs(v) do a[#a+1]=json(x) end;return '['..table.concat(a,',')..']' end
 if type(v)=='string' then return string.format('%q',v) end
 return tostring(v)
end
local function emit(...) if capture then print(json({...})) end end
local noop=function()end
local dummy=setmetatable({},{__index=function()return noop end})
local gr=setmetatable({},{__index=function()return noop end})
local sizes={cat={384,384},tiles={128,128},background={960,540},['background-reverse']={960,540},props={384,96},icon={192,192},flowers={96,96},ring={96,96},checkpoint={96,96}}
function gr.newImage(path)local n=path:match('/(.-)%.png');local size=assert(sizes[n]);return setmetatable({path=path,getDimensions=function()return unpack(size)end,getWidth=function()return size[1]end,getHeight=function()return size[2]end},{__index=dummy})end
function gr.newQuad(x,y,w,h)return {quad=true,x,y,w,h}end
function gr.getDimensions()return 960,540 end
function gr.newFont(size)return size end
function gr.setFont(size)emit('font',size)end
function gr.setColor(r,g,b,a)if type(r)=='table' then r,g,b,a=unpack(r) end;emit('color',r,g,b,a or 1)end
function gr.setLineWidth(w)emit('width',w)end
function gr.rectangle(mode,x,y,w,h,r)emit('rect',mode,x,y,w,h,r or 0)end
function gr.ellipse(mode,x,y,rx,ry)emit('ellipse',mode,x,y,rx,ry)end
function gr.print(t,x,y)emit('text',t,x,y,0,'left')end
function gr.printf(t,x,y,w,align)emit('text',t,x,y,w,align)end
function gr.draw(im,q,...)
 local args={...};local quad
 if type(q)=='table' then quad=q else table.insert(args,1,q);quad={0,0,im:getWidth(),im:getHeight()} end
 emit('image',im.path,quad[1],quad[2],quad[3],quad[4],args[1],args[2],args[4] or 1,args[5] or args[4] or 1,args[6] or 0,args[7] or 0)
end
love={graphics=gr,window=dummy,audio={newSource=function()return dummy end},filesystem={getInfo=function()return nil end,write=noop},touch={getTouches=function()return {}end},system={getOS=function()return 'Android'end},timer={getTime=function()return 0 end}}
dofile('velocity-love/game/main.lua');love.load()
if arg[1]~='menu' then love.keypressed('return');love.keypressed('right');for i=1,70 do love.update(1/60)end end
capture=true;love.draw()
