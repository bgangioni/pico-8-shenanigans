pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()

  scene = 2
  counter = 0
  
  texto = {}
  texto[1] = "lo tienes en tu adn"
  texto[2] = "arde en tu interior"
  tx = 4
  ty = 4
  tspeed = 1
  txd = 1
  tyd = 1
  
  centerframe = 16
  debug_counter = 0
  angv = 0
  testpoint2d = {}
  testpoint2d.x = 0
  testpoint2d.y = 0

  testpoint3d = {}
  testpoint3d.x = 0
  testpoint3d.y = (-0.5)
  testpoint3d.z = 1

  initx1 = 0
  inity1 = 0
  initz1 = 0
  initx2 = 0
  inity2 = 0
  initz2 = 0
  
  pulse_repeat = 0
  pulse = -0.01
  adn_z = 2

  adn_nodes = 10
  adn ={}
  for i =1, adn_nodes do
    local a = (i*2)-1
    local b = i*2

    adn[a] ={}
    adn[a].x = -0.1
    adn[a].y = 0.2 - (i-1)*0.05
    adn[a].z = 0
	
    adn[b] = {}
    adn[b].x = 0.1
    adn[b].y = adn[a].y
    adn[b].z = 0

    adn[a] = rotate_xz(adn[a],0.05*(i-1))
    adn[b] = rotate_xz(adn[b],0.05*(i-1))

  end
  ambientbw ={7,6,13,5,1}
  ambientcolor ={8,9,10,11,12}
  ambient= ambientbw

  numstars = 100
  starfield ={}
  for i = 1 , numstars do
    starfield[i] = {}
    starfield[i].x = rnd(8)-4
    starfield[i].y = rnd(8)-4
    starfield[i].z = rnd(10)-4
  end

-- SCENE 2 

	particles = {}
	colors = {7,10,9,8,2}
	for p = 1, 50 do
	  particles[p] = {}
	  particles[p].x = 60+flr(rnd(9))
	  particles[p].y = 70-flr(rnd(3))
	  particles[p].col = 1
      particles[p].life = 20-flr(rnd(3))
	  particles[p].speed = 1+flr(rnd(3))
	end

end

function copypoint2d(point2d)
  local newp = {}
  for k,v in pairs(point2d) do
    newp[k] = v
  end
  return newp
end

function translate_z(point3d, dz)
  local newpoint3d = copypoint2d(point3d)
  newpoint3d.z += dz
  return newpoint3d
end

function normalize(point2d)
  local newpoint2d = copypoint2d(point2d)

  newpoint2d.x = flr((point2d.x * 64) + 64)
  newpoint2d.y = flr((point2d.y * 64 * (-1)) + 64)
  return newpoint2d
end

function psetnorm(point2d)
  local normalp = normalize(point2d)
  pset(normalp.x,normalp.y,point2d.color)
end

function project3to2(point3d)
  local point2d = {}
  point2d.x = point3d.x / point3d.z
  point2d.y = point3d.y / point3d.z
  point2d.color = point3d.color
  return point2d

end

function pset3d(point3d)
  psetnorm(project3to2(point3d))
end

function rotate_xz(point3d,angle)
  local newpoint3d = copypoint2d(point3d)
  local s = sin(angle)
  local c = cos(angle)

  newpoint3d.x = point3d.x*c - point3d.z*s
  newpoint3d.z = point3d.x*s + point3d.z*c

  return newpoint3d
end

function closest(pointa, pointb)
	if pointa.z > pointb.z then return pointb else return pointa end
end
function furthest(pointa,pointb)
	if pointa.z < pointb.z then return pointb else return pointa end
end

function draw_adn(x,y,z,angle)
  for i = 1, adn_nodes do
    local a = (i*2)-1
    local b = (i*2)
    local newa = rotate_xz(copypoint2d(adn[a]),angle)
    local newb = rotate_xz(copypoint2d(adn[b]),angle)

    newa.x = newa.x + x
    newb.x = newb.x + x
	
    newa.y = newa.y + y
    newb.y = newb.y + y
	
	newa.z = newa.z + z
    newb.z = newb.z + z

    local cl = normalize(project3to2(closest(newa,newb)))
    local fr = normalize(project3to2(furthest(newa,newb)))
	
	circfill(fr.x,fr.y,1,5)
    line(fr.x,fr.y,cl.x, cl.y, 3)
	circfill(cl.x,cl.y,1,13)
  end
end

function _update()
  tx += (txd * tspeed)
  ty += (tyd * tspeed)
  if tx > 50 or tx < 2 then txd = txd * (-1) end
  if ty > 122 or ty < 2 then tyd = tyd * (-1) end
  
  for i = 1, numstars  do
    if starfield[i].z > (-5.1) then
      starfield[i].z -= 0.1
      starfield[i].color = ambient[flr((starfield[i].z+4)/2.5)+1]
    else
      starfield[i].z = 5
      starfield[i].x = rnd(8)-4
      starfield[i].y = rnd(8)-4
      starfield[i].color = ambient[1]
    end
  end
  
 if scene == 1 then
 --  debug_counter += 1
  angv -= 0.01
  if angv < (-1) then angv += 1 end

  if adn_z == 0 then adn_z += pulse
  else adn_z = adn_z + (pulse * adn_z * adn_z) end
  
  pulse_repeat += 1
  if pulse_repeat > 100 then
	pulse = pulse * (-1)
	pulse_repeat = 0
  end
  counter += 1
  if counter > 200 then
    counter = 0
	scene = 2
  end
 elseif scene == 2 then
 	for p in all(particles) do
	  p.col = 1+flr(5-p.life/4)
--	  if p.life < 6 then p.col = 5
--	  elseif p.life < 10 then p.col = 4
--	  elseif p.life < 14 then p.col = 3
--	  elseif p.life < 18 then  p.col = 2
--	  end
      p.life -= 1+flr(rnd(2))
	  p.y -= p.speed
	  if p.life < 1 then
	  p.x = 62+flr(rnd(4))
	  p.y = 70-flr(rnd(3))
	  p.col = 1
      p.life = 20
	  p.speed = 1+flr(rnd(3))
		
	  end
	end
 end
end

function _draw()
 cls()
 
   for i = 1 , numstars do
    pset3d(translate_z(starfield[i],5))
  end
  
 if scene == 1 then
  print(texto[1],tx-1+rnd(2),ty-1+rnd(2),flr(11+adn_z*12))
  print(texto[1],tx+rnd(2),ty+rnd(2),flr(11+adn_z*12)+1)
  print(texto[1],tx,ty,7)
  
  rect(64-centerframe+1,64-centerframe+1,64+centerframe+1,64+centerframe+1,1)
  rect(64-centerframe,64-centerframe,64+centerframe,64+centerframe, 2)
  draw_adn(0,0,adn_z,angv)
  
 elseif scene == 2 then
  print(texto[2],tx-1+rnd(2),ty-1+rnd(2),flr(11+adn_z*12))
  print(texto[2],tx+rnd(2),ty+rnd(2),flr(11+adn_z*12)+1)
  print(texto[2],tx,ty,7)
  
  rect(64-centerframe+1,64-centerframe+1,64+centerframe+1,64+centerframe+1,1)
  rect(64-centerframe,64-centerframe,64+centerframe,64+centerframe, 2)
  
  --- HERE
  	for p in all(particles) do
	  circfill(p.x,p.y,1+flr(p.life/5),colors[p.col])
	end
 end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000101010000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010100000101000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001000001000000010101010100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001000000010000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001000000000101010101010001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010101000100000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000001000100010000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
