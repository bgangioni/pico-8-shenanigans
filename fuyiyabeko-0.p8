pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--by creatorbyte

-------------------------------
--game constants

cols = 8
rows = 4
stardel = 0.5
numstars = 10
reloadt = 0.5
a_reloadt = 0.05
extra_bullets = 2

adr = 1
lastab = 0
lastb = 0
gameover = false

shaketime = 0
sh_power = 0
shake = false

a_clrs = { 8, 14, 11, 12, 10, 9 }
title_clrs = { 1, 13, 6, 7 }
titlescreen = true

move_tick = 10
move_step = 1
tick_counter = 0
anim_frame = 0

score = 0
killcount = 0
bonus_sprt = 7
bonus_speed = 1.5
bonus_points = 100
bonus_clr = 13
bonus_kills = 25

function fmt_score(s)
	local str = tostr(s)
	while #str < 4 do
		str = "0" .. str
	end
	return str
end

-------------------------------
--player

ships = {}

function make_player(xp, yp)
	player = {
		x = xp, --64,
		y = yp, --116,
		v = 2,
		cw = 7, --sprite is 7 pixels wide

		update = function(self)
			if btn(⬅️) then
				if (self.x <= 0) then
					self.x = 0
				else
					self.x -= self.v
				end
			end

			if btn(➡️) then
				if (self.x >= 121) then
					self.x = 121
				else
					self.x += self.v
				end
			end

			if btn(🅾️) then
				--player:shoot
				-- only fire if no player bullets on screen
				local can_fire = true
				for b in all(bullets) do
					if b.enemy == false then
						can_fire = false
						break
					end
				end
				if can_fire then --if (t() >= lastb + reloadt) then
					sfx(3)
					for i = 0, extra_bullets do
						bx = flr(rnd(9) - (8 / 2))
						by = flr(rnd(5) - (5 / 2))
						makebullet(bx + self.x + 3, by + self.y, -5, 1, false)
						--lastb = t()
					end
				end
			end
		end,

		draw = function(self)
			spr(0, self.x, self.y)
		end
	}
	add(ships, player)
end
-------------------------------
-- aliens

aliens = {}

function make_alien(xp, yp, sprt)
	alien = {
		x = xp,
		y = yp,
		lfe = 1,
		cw = 8,
		s = flr(sprt),
		base_s = flr(sprt),
		clr = a_clrs[flr(sprt)],

		draw = function(self)
			spr(self.s, self.x, self.y)
		end,

		update = function(self)
			if tick_counter % move_tick == 0 then
				self.x += move_step * adr
				self.s = self.base_s + anim_frame * 16
			end
		end
	}
	add(aliens, alien)
end

-------------------------------
-- stars

stars = {}

function newstar(xp, yp, sp, col)
	star = {
		x = xp,
		y = yp,
		c = col,
		v = sp,

		draw = function(self)
			circfill(self.x, self.y, 0, self.c)
		end,

		update = function(self)
			self.y += self.v

			--	if(self.y>131) then
			--		 self.y=-2
			--		elseif(self.y<-3) then
			--			self.y=130
			--		end
		end
	}
	add(stars, star)
end

-- pre-populate stars for title screen
function prepop_stars()
	for i = 0, numstars do
		newstar(rnd(130), rnd(130), 0.5, 1)
		newstar(rnd(130), rnd(130), 0.6, 1)
		newstar(rnd(130), rnd(130), 0.75, 12)
		newstar(rnd(130), rnd(130), 1, 12)
	end
end

prepop_stars()

--------------------------------
-- bullets

bullets = {}

function makebullet(xp, yp, sp, sz, eb)
	bullet = {
		x = xp,
		y = yp,
		col = 10,
		v = sp,
		size = sz,
		tc = 1,
		enemy = eb,

		update = function(self)
			self.y += self.v
		end,

		draw = function(self)
			--	bcs = {8,12,14,2,11}

			bcs = { 8, 9, 10, 11, 7 }
			c = bcs[flr((t() * 30) % 5) + 1]

			//	circfill(self.x,self.y,self.size,bcs[self.tc])
			//	circ(self.x,self.y+(-2),0,bcs[self.tc])
			// circ(self.x,self.y+(-1),0,bcs[self.tc])

			if (self.enemy == false) then
				line(self.x, self.y, self.x, self.y - self.v / 1.5, c)
			else
				circ(self.x, self.y, self.size * abs(2 * cos(2 * t())), c)
			end
		end
	}
	add(bullets, bullet)
end

-------------------------------
--make particles
prtcls = {}

function mk_prtcl(x, y, velx, vely, r, clr, lftme, dmp)
	prtcl = {
		xp = x,
		yp = y,
		vx = velx,
		vy = vely,
		lt = lftme,
		damp = dmp, --1.1
		grav = 0.25,
		c = clr,

		update = function(self)
			self.xp += self.vx
			self.yp += self.vy + self.grav

			if (sqrt((self.vx * self.vx) + (self.vy * self.vy)) >= 0.01) then
				self.vx /= self.damp
				self.vy /= self.damp
			end
		end,

		draw = function(self)
			circ(self.xp, self.yp, r, self.c)
		end
	}

	add(prtcls, prtcl)
end

function mk_exp(xp, yp, force, num, clr)
	if (clr >= 0) then
		cl = clr
	else
		cl = rnd(16)
	end
	--	bcs = {8,9,10,11,7}

	for i = 0, num do
		a = rnd(1)
		f1 = (rnd(force) - (force / 2)) * cos(a)
		f2 = (rnd(force) - (force / 2)) * sin(a)

		mk_prtcl(xp, yp, f1, f2, rnd(2), cl, rnd(5), 1.25)
	end
end

-------------------------------
--main program loop

function init()
	tick_counter = 0
	anim_frame = 0
	make_player(64, 112)

	for i = 0, numstars do
		newstar(rnd(130), rnd(130), 0.5, 1)
		newstar(rnd(130), rnd(130), 0.6, 1)
		newstar(rnd(130), rnd(130), 0.75, 12)
		newstar(rnd(130), rnd(130), 1, 12)
	end

	for i = 0, cols do
		for j = 0, rows do
			make_alien(i * 12, 8 + j * 12, rnd(6) + 1)
		end
	end
end

------------------------------
--collision detection

function collide(aa, bb)
	if (aa.x <= (bb.x + 8)) and (aa.x >= bb.x) and (aa.y <= bb.y + 8) and (aa.y >= bb.y) then
		return true
	else
		return false
	end
end

------------------------------
--update loop

laststar = 0
lastdir = 0
function _update()
	tick_counter += 1
	if tick_counter % move_tick == 0 then
		anim_frame = 1 - anim_frame
	end

	if (t() >= laststar + stardel) then
		newstar(rnd(130), -2, 0.5, 1)
		newstar(rnd(130), -2, 0.6, 1)
		newstar(rnd(130), -2, 0.75, 12)
		newstar(rnd(130), -2, 1, 12)
		laststar = t()
	end

	cls(0)

	-- bonus enemy
	if (bonus == nil and titlescreen == false and gameover == false and killcount >= bonus_kills) then
		bonus = { x = 132, y = 2, s = bonus_sprt }
		killcount = 0
	end

	if (bonus ~= nil) then
		bonus.x -= bonus_speed
		if tick_counter % move_tick == 0 then
			bonus.s = bonus_sprt + anim_frame * 16
		end
		if (bonus.x < -8) then
			bonus = nil
		end
	end

	if (bonus ~= nil) then
		for bullet in all(bullets) do
			if (bullet.enemy == false and collide(bullet, bonus) == true) then
				score += bonus_points
				del(bullets, bullet)
				sfx(2)
				camshake(2, 0.25)
				mk_exp(bonus.x, bonus.y, rnd(10) + 5, rnd(60) + 10, bonus_clr)
				bonus = nil
				break
			end
		end
	end

	for star in all(stars) do
		if (star.y >= 131) then
			del(stars, star)
		end
		star:update()
	end

	for bullet in all(bullets) do
		bullet:update()
		if (bullet.y >= 131 or bullet.y <= -2) then
			del(bullets, bullet)
		end
	end

	for alien in all(aliens) do
		if (t() >= a_reloadt + lastab and rnd(100) > 99) then
			makebullet(alien.x, alien.y, 2, 1, true)
			sfx(5)
			lastab = t()
		end

		for bullet in all(bullets) do
			if (collide(bullet, alien) == true) then
				if (bullet.enemy == false) then
					score += 1
					killcount += 1
					del(aliens, alien)
					del(bullets, bullet)
					sfx(flr(rnd(2)))
					camshake(2, 0.25)
					mk_exp(alien.x, alien.y, rnd(10) + 5, rnd(60) + 10, alien.clr)
				end
			end

			if (player ~= nil and collide(bullet, player) == true and gameover ~= true) then
				if (bullet.enemy == true) then
					gameover = true
					del(ships, player)
					del(bullets, bullet)
					sfx(4)
					camshake(1, 1)
					mk_exp(player.x, player.y, rnd(20) + 5, rnd(100) + 10, 7)
				end
			end
		end

		if (player ~= nil and collide(player, alien) == true) then
			del(ships, player)
		end
		alien:update()
	end

	for alien in all(aliens) do
		if (adr < 0 and alien.x <= 0) then
			alien.x = 0
			adr *= -1
		elseif (adr > 0 and alien.x >= 120) then
			alien.x = 120
			adr *= -1
		end
	end

	for player in all(ships) do
		player:update()
	end

	-------------------------------
	-- respawn wave

	if (gameover == false and titlescreen == false and #aliens == 0) then
		local enemy_bullets = false
		for bullet in all(bullets) do
			if (bullet.enemy == true) then
				enemy_bullets = true
			end
		end
		if (enemy_bullets == false) then
			for i = 0, cols do
				for j = 0, rows do
					make_alien(i * 12, 8 + j * 12, rnd(6) + 1)
				end
			end
		end
	end

	-------------------------------
	-- game reset

	if (gameover == true and btn(❎)) then
		gameover = false
		shake = false
		stars = {}
		ships = {}
		aliens = {}
		bullets = {}
		prtcls = {}
		tick_counter = 0
		anim_frame = 0
		score = 0
		killcount = 0
		adr = 1
		lastab = 0
		lastb = 0
		bonus = nil
		prepop_stars()
		titlescreen = true
	end

	for prtcl in all(prtcls) do
		prtcl:update()
		--	bcs = {8,9,10,11,7}
		-- clr=bcs[flr(t()*30%5)+1]
		-- prtcl.c = clr

		if (prtcl.lt <= 0) then
			del(prtcls, prtcl)
		else
			prtcl.lt -= rnd(0.5)
		end
	end
end

------------------------------
--draw loop

function _draw()
	cls(0)

	for star in all(stars) do
		star:draw()
	end

	for alien in all(aliens) do
		alien:draw()
	end

	if (bonus ~= nil) then
		spr(bonus.s, bonus.x, bonus.y)
	end

	for bullet in all(bullets) do
		bullet:draw()
	end

	for player in all(ships) do
		player:draw()
	end

	for prtcl in all(prtcls) do
		prtcl:draw()
	end

	if (titlescreen == false) then
		print(fmt_score(score), 2, 122, 7)
	end

	if (gameover == true) then
		bcs = {1, 2, 8, 2}--{ 8, 9, 10, 11, 7 }
		c = bcs[flr(t() * 10 % 4) + 1]

		doffx = 2 * cos(t() / 2)
		doffy = 2 * sin(t() / 2)

		pal(7, c)
		local skull_anim = anim_frame * 32
		spr(10 + skull_anim, 56 + doffx, 64 + doffy)
		spr(11 + skull_anim, 64 + doffx, 64 + doffy)
		spr(26 + skull_anim, 56 + doffx, 72 + doffy)
		spr(27 + skull_anim, 64 + doffx, 72 + doffy)
		print("game over!", 45 + doffx, 85 + doffy, c)
		print("score: " .. fmt_score(score), 40 + doffx, 92 + doffy, c)
		print("press ❎ to restart", 30 + doffx, 100 + doffy, c)
		pal(7, 7)
	end

	if (titlescreen == true and gameover == false) then
		--int("inv★ders",45,64,7)

		for i = 0, 7 do
			line(24 + (9 * i), 40, 32 + (9 * i) + 8, 40, 7)
			spr(33 + i, 28 + (9 * i), 48)
			line(24 + (9 * i), 63, 32 + (9 * i) + 8, 63, 7)
		end

		print("press 🅾️ to start", 30, 95, title_clrs[flr((t() * 10) % 5)])
		if btn(🅾️) then
			lastb = t()
			titlescreen = false
			init()
		end
	end

	if (shake == true and shaketime >= 0) then
		shaketime -= (1 / 30)
		for i = 0, sh_power do
			camera(rnd(sh_power) - (sh_power / 2), rnd(sh_power) - (sh_power / 2))
		end
	else
		camera(0, 0)
	end
end

function camshake(intensity, duration)
	shake = true
	sh_power = intensity
	shaketime = duration
end
__gfx__
000700008000000800ffff0000b00300000000000000000000999000000000000000000000000000000077777777000000000000000000000000000000000000
00070000880000880fffffe000bbb30000cccc000a000090099294000076660000ddd50000000000007777777777770000000000000000000000000000000000
00777000088888800f2ff2e00bbbbb300cccccd00aaaaa9009929400077666600dd9955000000000077777777777777000000000000000000000000000000000
007b7000081881800f2ff2e00b1bb1300c1cc1d0aa4aa4a9099994007768666d0d97a95000000000077770777707777000000000000000000000000000000000
07737700881881820ffffee00b1bb130cc1cc1ddaa4aa4a909090400766266dd0d9a795000000000077700077000777000000000000000000000000000000000
777777d088888882ff0fe0ee00bbb300ccccccdd0aaaaa909909044006666dd00dd9955000000000077700077000777000000000000000000000000000000000
77070dd088000022f00ee00ebbb00333c0cccd0d00a00900900400400006d00000d5550000000000077700077000777000000000000000000000000000000000
700000d0088002200e0000e0bb00003300c00d000000000090040040000000000000000000000000077700077000777000000000000000000000000000000000
000700000000000000ffff000b0000300000000000000000009990000000000000ddd50000000000077770777707777000000000000000000000000000000000
00070000888008880fffffe000bbb30000cccc0000a0090009999400007666000dd9955000000000007777700777770000000000000000000000000000000000
00777000088888800fffffe00b1bb1300cccccd00aaaaa9009929400077666600d97a95000000000000777777777700000000000000000000000000000000000
007b7000888888820f2ff2e00b1bb1300cccccd00aaaaa90099294007762666d009a790000000000000707077070700000000000000000000000000000000000
07737700811881120f2ff2e00bbbb3300c1cc1d0a44aa44909994400766866dd009aa90000000000000000000000000000000000000000000000000000000000
777777d0888888820fffeee000bbb3000c1cc1d0aaaaaaa90999440006666dd00d9a795000000000000070700707000000000000000000000000000000000000
77070dd0088882200f0ee0e000bb33000ccccdd000aaa9000094400000600d000dd9955000000000000077777777000000000000000000000000000000000000
700000d00000000000e00e0000bb330000ccdd0000000000000000000000000000d5550000000000000007777770000000000000000000000000000000000000
00070000777777777700007777000077000770007777770007777777777777700777777700000000000077777777000000000000000000000000000000000000
00070000777777777770007777000077007777007777777077777777777777777777777700000000007777777777770000000000000000000000000000000000
00777000007777007777007777700777077777707700077777700000770007777770000000000000077770777707777000000000000000000000000000000000
007b7000000770007777707707700770077007707700007777777770770007777777777000000000077700077000777000000000000000000000000000000000
07737700000770007707777707700770777007777700007777777770777777700777777700000000077700077000777000000000000000000000000000000000
777777d0007777007700777700777700777777777700077777700000777777700000077700000000077700077000777000000000000000000000000000000000
77070dd0777777777700077700777700777777777777777077777777770007777777777700000000077700077000777000000000000000000000000000000000
700000d0777777777700007700077000770000777777770007777777770007777777777000000000077770777707777000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007777700777770000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777700000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000707077070700000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000070700707000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000007777770000000000000000000000000000000000000
__sfx__
00010000201502115022150231502515026150271502715028150291502a1502a1502a1502b1502b1502b1502b1502b1502a1501d1501c1501b1501b1501a1501a1501a150191501815018150181501715016150
0001000024150251502615027150281502a1502b1502c1502e1502f1502f1503015030150311503115032150311502f1502e1502d1502c1502b1502a150291502915028150271502615025150241502315022150
0001000014550145501b55024550145500e5500c55018550145502c550245501c55027550165502f550365501d5500d55006550055500f550175501f55022550225500c55001550025500e5501a5502855023550
000100003935037350323502f3502d350293502735023350213501f3501e3501d3501c3501a3501935018350173501635015350143501335012350113500e3500d3500c3500b3500b3500a350093500835007350
000100002665029650316503765039650386503765034650326502f6502a650296502665025650216501e6501b6501a650176501565012650106500f6500d6500c6500a650076500665005650046500265001650
000100002a0301703017030170301b030280302d03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
