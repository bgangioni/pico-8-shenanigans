pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
  --additional colors
  poke( 0x5f2e, 1 )
  
  pal( {[0]=0,136,137,9,10,135,6,7,8,9,10,11,12,13,14,15} ,1 )
--  pal( {[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15} ,1 )

  counter = {}
  counter [1] = 0

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

  counter[1]+=1

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
  
  if life > 0 then life -=0.1 end
  if bombready < 99 then bombready +=0.3 end
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
  spr(38,96,1)

  rectfill(0,100,127,127,1)
  line(0,100,127,100,2)
  if counter[1]< 50 then
    print("atencion",79,106,2)
    print("atencion",78,105,4)

  elseif counter[1]<150 then
    print("atencion",79,106,2)
    print("atencion",78,105,4)
    print("la base",79,113,2)
    print("la base",78,112,4)
  elseif counter[1] < 250 then
    print("esta en",79,106,2)
    print("esta en",78,105,4)
    print("peligroo",79,113,2)
    print("peligroo",78,112,4)
  elseif counter[1]< 350 then
    print(" ...",79,113,2)
    print(" ...",78,112,4)
  else
    print(":rango:",81,105,2)
    print(":rango:",80,104,4)
    print((rango[1+flr(points / 1000)] or "\\*/"),85,113,2)
    print((rango[1+flr(points / 1000)] or "\\*/"),84,112,4)
  end
  
  pcount +=1
  draw_panel(10,109,flr(pcount/20))
  draw_panel(26,109,flr(sin(1/pcount)))
  draw_panel(42,109,flr(pcount/10))
  
  draw_bombcharge(bombready,27,121)

  draw_life(life,116,114)

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

function static(x1,y1,x2,y2)
  for i = x1, x2 do
    for j = y1, y2 do
      pset(i,j,1+rnd(5))
    end
  end
end

function draw_comm(x,y)
  rectfill(x-10,y-10,x+9,y+8,4)
  rectfill(x-8,y-8,x+11,y+10,2)
  rectfill(x-9,y-9,x+10,y+9,2)
  for i = 9, 0, -1 do
    line(x-9,y-i,x+9,y-i,5-i/2)
    line(x-9,y+i,x+9,y+i,5-i/2)
  end
  if bombready > 98 then
    static(x-8,y-8,x+9,y+8)
    spr(19,x-7,y-4,2,1)
  elseif counter[1] < 150 then
    spr(8+rnd(2),x-4,y-4)
  elseif counter[1] < 250 then
    spr(10,x-4,y-4)
  else
    static(x-8,y-8,x+9,y+8)
  end

  rect(x-9,y-9,x+10,y+9,3)
  pset(x+10,y-9,3)
  pset(x-9,y+9,4)
  pset(x+9,y-9,2)
  pset(x+10,y-8,2)
  pset(x-8,y+9,2)
  pset(x-9,y+8,2)

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
00000000000000000000000022222200000022220002000000222000000000000122112001221120012211200000000000000000000000000000000000000000
00000000333300000000000002333320002233200020000202333000000000001222211212222112122221120000000000000000000000000000000000000000
00700700033333000000000003344332223333320230002023343222000000001333221213332212155355120000000000000000000000000000000000000000
00077000003443300000000023433232033444332332220023443330000000001153151211531512115315120000000000000000000000000000000000000000
00077000002332200000000012122121022333221221110012332220000000001333221213332212155355120000000000000000000000000000000000000000
00700700022222000000000002211221112222210120001012232111000000001311122213111222131112220000000000000000000000000000000000000000
00000000222200000000000001222210001122100010000101222000000000001311121213322212131112120000000000000000000000000000000000000000
00000000000000000000000011111100000011110001000000111000000000000132212001322120013221200000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777000000000044000400445404400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070555700000000041504150455504140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555570000000054104050411405410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555540000000051405040500405140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000040555400000000040505040400505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444000000000055101410500405410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011000100100101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000220022000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000
00000000000000000022220000000000000000000222222000000000000400002244422000000000000000000000000000000000000000000000000000000000
00000000033003300332233000000000033333300000000000040000224442200224220000000000000000000000000000000000000000000000000000000000
04400440003333000033330004444440000000000333333022444220022422003322233000000000000000000000000000000000000000000000000000000000
00444400044334400443344004444440044444400000000002242200332223300332330000000000000000000000000000000000000000000000000000000000
00044000004444000044440000000000044444400444444000222000033233004433344000000000000000000000000000000000000000000000000000000000
00000000000440000004400000000000000000000444444000020000003330000443440000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000300000044400000000000000000000000000000000000000000000000000000000000
