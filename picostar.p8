pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
  --additional colors
  poke( 0x5f2e, 1 )
  
  pal( {[0]=0,136,137,9,10,135,6,7,8,9,10,11,12,13,14,15} ,1 )
--  pal( {[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15} ,1 )

  px = 64
  py = 64
  minx,miny,maxx,maxy = 5,16,124,96
  pcount = 0
  life = 99
  bombready = 0

  bx = nil
  by = nil
  bframe = nil
  
  rx = nil
  ry = nil  

-- rank handling
  rango = {
  "> ", ">> ", ">>>",
  "x ", "x>", "x>>",
  "* ", "** ", "***",
  }
  points = 0

  starspeed = 1
  countstars = 50
  starfield = {}
  for i  = 1 , countstars do
    starfield[i] = {}
    starfield[i].x = flr(rnd(128))
    starfield[i].y = flr(rnd(128))
    starfield[i].z = flr(rnd(4))
  end

  enemies ={}
  for i=1, 4 do
    enemies[i] = {}
    enemies[i].sprite = i +2
    enemies[i].x = 96
    enemies[i].y = 16+16*i
    enemies[i].hp = 1
    enemies[i].dead = false
  end
end

function _update()
--- REPLACE THIS

  points += 10
--- END REPLACE

  if btnp(🅾️) then
    if not rx then
      rx = {}
      rx[1] = px+flr(rnd(5))-2
      rx[2] = px
      rx[3] = px-flr(rnd(5))+2
      rx[4] = py-flr(rnd(3))
      rx[5] = py
      rx[6] = py+flr(rnd(3))
    end
  end
  
  if btnp(❎) then
    if not bx and bombready > 98 then
      bx = px
      by = py
      bombready = 0
    end
  end
  
  if btn(⬆️) and py >   miny then py -=1 end
  if btn(⬇️) and py < maxy then py +=1 end
  if btn(➡️) and px < maxx then px +=1 end
  if btn(⬅️) and px >   minx then px -=1 end
  
  if bframe == 0 then bframe = nil end
  if bframe then bframe -=1 end
  if bx then
    bx += (2+flr(bx/16))
    if bx > 129 then bx = nil bframe = 7 end
  end
  
  if rx then
    local rxspeed = 10 --(2+flr(rx[1]/16))
    rx[1] += rxspeed 
    rx[2] += rxspeed 
    rx[3] += rxspeed 
    if rx[1] > 129 then rx = nil end
  end
  
  for i = 1, countstars do
    starfield[i].x -= flr(starspeed*starfield[i].z)
    if starfield[i].x < 0 then starfield[i].x = 129 starfield[i].y = flr(rnd(129)) end
  end
  
end

function _draw()
  cls()
  for i = 1, countstars do
    pset(starfield[i].x,starfield[i].y,starfield[i].z)
  end
  
  if rx then
    line(rx[1],rx[4],rx[1]+5,rx[4],7)
    line(rx[2],rx[5],rx[2]+5,rx[5],4)
    line(rx[3],rx[6],rx[3]+5,rx[6],3)
  end

  for i = 1, 4 do
    spr(enemies[i].sprite,enemies[i].x,enemies[i].y)
  end
  
  if bframe then
    rectfill(0,0,128,128,bframe)
    for i = 1, 100 do
      pset(rnd(129),rnd(129),flr(rnd(8)))
    end
  end

  if bx then
    spr(17,bx-4,by-4)
  end  

  spr(1,px-4,py-4)
  
-- cockpit and stats
  rectfill(0,0,128,11,1)
  line(0,11,127,11,2)
  print("picostar 0.1",5,5,2)
  print("picostar 0.1",4,4,4)

  rectfill(0,100,127,127,1)
  line(0,100,127,100,2)
  print(":rango:",81,105,2)
  print(":rango:",80,104,4)
  print((rango[1+flr(points / 1000)] or "\\*/"),85,113,2)
  print((rango[1+flr(points / 1000)] or "\\*/"),84,112,4)

  pcount +=1
  draw_panel(10,109,flr(pcount/20))
  draw_panel(26,109,flr(sin(1/pcount)))
  draw_panel(42,109,flr(pcount/10))
  
  draw_bombcharge(bombready,27,121)
  if bombready < 99 then bombready +=0.5 end

  draw_life(life,116,114)
  life -=0.1

  draw_comm(64,114)
end

function draw_bombcharge(brdy,x,y)
  rectfill(x-20,y-2,x+18,y,4)
  rectfill(x-18,y,x+20,y+2,2)
  rectfill(x-19,y-1,x+19,y+1,1)
  for i = 1, flr(brdy/5) do
    pset(x-20+(2*i),y,2+flr(brdy/100*4))
  end
end

function draw_comm(x,y)
  rectfill(x-10,y-10,x+8,y+8,4)
  rectfill(x-8,y-8,x+10,y+10,3)
  rectfill(x-9,y-9,x+9,y+9,0)
  pset(x+9,y-9,3)
  pset(x-9,y+9,4)
  pset(x+8,y-9,2)
  pset(x+9,y-8,2)
  pset(x-8,y+9,2)
  pset(x-9,y+8,2)

  if bombready > 98 then
    circ(x,y,7,1+flr(rnd(6)))
    spr(17,x-4,y-4)
  else
    spr(3+flr(rnd(4)),x-4,y-4)
  end
end

function draw_life(life,x,y)
  rectfill(x-5,y-10,x+3,y+8,4)
  rectfill(x-3,y-8,x+5,y+10,2)
  rectfill(x-4,y-9,x+4,y+9,1)

  for i = 1, flr(life/10) do
    line(x-3,y+10-(2*i),x+3,y+10-(2*i), 2+flr(life/100*4))
  end

end

function draw_panel(px,py,ind)
  local indicators={{},{},{},{},{},{},{},{}}
  indicators[1].x = px
  indicators[1].y = py+3
  indicators[2].x = px-2
  indicators[2].y = py+2
  indicators[3].x = px-3
  indicators[3].y = py
  indicators[4].x = px-2
  indicators[4].y = py-2
  indicators[5].x = px
  indicators[5].y = py-3
  indicators[6].x = px+2
  indicators[6].y = py-2
  indicators[7].x = px+3
  indicators[7].y = py
  indicators[8].x = px+2
  indicators[8].y = py+2

  circfill(px-1,py-1,4,4)
  circfill(px+1,py+1,4,2)
  circfill(px,py,4,1)
  line(px,py,indicators[1+ind%8].x,indicators[1+ind%8].y,4)

  pset(px,py-3,2)
  pset(px-3,py,2)
  pset(px+3,py,2)
  pset(px,py+3,2)
  pset(px+2,py+2,2)
  pset(px-2,py-2,2)
  pset(px-2,py+2,2)
  pset(px+2,py-2,2)
  
end


__gfx__
00000000000000000000000022222200000022220002000000222000000000000433333333333333333333200000000000000000000000000000000000000000
00000000333300000000000002333320002233200020000202333000000000000433333333333333333333200000000000000000000000000000000000000000
00700700033333000000000003344332223333320230002023343222000000000433333333333333333333200000000000000000000000000000000000000000
00077000003443300000000023433232033444332332220023443330000000000043333333333333333332000000000000000000000000000000000000000000
00077000002332200000000012122121022333221221110012332220000000000043333333333333333332000000000000000000000000000000000000000000
00700700022222000000000002211221112222210120001012232111000000000004333333333333333320000000000000000000000000000000000000000000
00000000222200000000000001222210001122100010000101222000000000000000223333333333332200000000000000000000000000000000000000000000
00000000000000000000000011111100000011110001000000111000000000000000002222222222220000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000040555400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
