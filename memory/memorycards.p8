pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()

	gamestatus = "playing"
	gridw,gridh = 5,3
	suits = {1,2,3,4}
 card = {
 	x = 48,
 	y = 48,
 	revealed = true,
 	suit = 1,
 	col = 5,
 	value = 1,
 	w = 20, -- h = w * 1.4
 }
end

function flipcard(card)
	card.revealed = not card.revealed
end

function _update()
	if btnp(0) or btnp(1) then flipcard(card) end
end

function drawcard(card)
	local rad = flr(card.w/8)
	local h = card.w*1.4
	fillp(0b1010010110100101)
	rrectfill(card.x+2,card.y+2,card.w,h,rad,0x12)
	fillp()
	if(card.revealed) then
		fillp(0b0000010000000010)
		rrectfill(card.x,card.y,card.w,h,rad,0x67)
		fillp()
		rrect(card.x,card.y,card.w,h,rad,0)
		spr(card.suit,card.x+card.w/2-8,card.y+card.w*0.7-6)
		print(card.value,card.x+card.w/2+2,card.y+card.w*0.7-4,6)
		print(card.value,card.x+card.w/2+1,card.y+card.w*0.7-5,1)
	else
--		fillp(0b0001001001001000)
		fillp(0b0000000101101000)
		rrectfill(card.x,card.y,card.w,h,rad,0xe8)
		fillp()
		rrect(card.x,card.y,card.w,h,rad,0)
	end
end

function _draw()
	if gamestatus == "intro" then
	elseif gamestatus == "playing" then
		fillp(0b1001010101101010)
		rectfill(0,0,127,127,0x24)
		fillp()
		print("\^w\^t\^=test game!",25,10,1)
		print("\^w\^t\^=test game!",25,9,2)
		print("\^w\^ttest game!",24,8,7)
		local val = card.value
		for i = 0, (gridw*gridh)-1 do
			card.x = (card.w+3) * (i % gridw) + 8
			card.y = 32 + (card.w*1.4+3)*flr(i/gridw)
			drawcard(card)
			card.value +=1
			card.suit = i%4+1
		end
		card.value = val
	end
end
__gfx__
0000000000aaaa0000a9990000046000035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a4444900ccdd220000860008a3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a4aaa9a4aa9a99449445552089a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000a4a994a4998282820c6dcd00089300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000a4a994a40898282000c6d000008a30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a49444a400a94200006dc000000850000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009aaaa4000092000000c0000000095000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004444000a944220000d0000000009500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
