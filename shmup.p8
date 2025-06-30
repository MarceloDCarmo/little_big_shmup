pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main
function _init()
	cls(0)
	mode="start"	
	blinkt=0
	
	set_start()
end

function _update()
	blinkt+=1
	
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="load" then
		update_load()
	elseif mode=="over" then
		update_over()
	end
end	

function _draw()
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="load" then
		draw_load()
	elseif mode=="over" then
		draw_over()
	end
	
	if (debug) print(debug)
end

function start_game()
	score=30000
	lives=4
	tlives=4
	mbombs=3
	bombs=3

	shipspr=2
	shipx=60
	shipy=60
	shipsx=0
	shipsy=0
	
	flmspr=17
	
	bullets={{x=-1,y=-1,s=1,spd=5}}
	enemies={{x=64,y=8,s=34,spd=2}}
	
	muzzle=0
	
	planets={}
	--gen_stars(120)
	mode="game"
end
-->8
--animation
function animate_ship()
	shipx+=shipsx
	shipy+=shipsy
end

function animate_bullets()
	for b in all(bullets) do
		if (b.y<0) del(bullets,b)
		
		b.y-=b.spd
		if b.s<12 then
			b.s+=0.75
			if b.s>9 then
				b.s=5
			end
		else
			b.s+=0.25
			if b.s>15 then
				b.s=12
			end
		end
	end
end

function animate_flame()
	flmspr+=1
	if flmspr>20 then
		flmspr=17
	end
end

function animate_muzzle()
	if muzzle>0 then
		muzzle-=1
	end
end

function animate_stars()
	for i=1,#stars do
		local spd=2
	
		if stars[i].col==1 then
			spd=0.5
		elseif stars[i].col==13 then
			spd=1
		end	
	
		stars[i].y+=spd

		if stars[i].y>128 then
			stars[i].y=0
		end
	end
end

function animate_planets()
	if flr(rnd(500)) < 1 then
		add(planets,
		{
			x=flr(rnd(120)),
			y=0,
			s=flr(rnd(2)+22)
		})
	end
	
	for p in all(planets) do
		if (p.y>128) del(planets,p)
		p.y+=0.5
	end
end

function amimate_enemies()
	for e in all(enemies) do
		e.y+=e.spd
		e.x+=1-rnd(2)
		
		if e.s>=41 then
			e.s=34
		end
		e.s+=0.5
		
		if e.y>128 then
			e.y=0
		end
	end
end

function blink()
	local banim={5,6,7,6,5}

	if blinkt>#banim then
		blinkt=1
	end
	
	return banim[blinkt]
end
-->8
--update

function update_game()
		--controls
	shipspr=2
	shipsx=0
	shipsy=0
	if btn(⬆️) then
		shipsy=-2
	end
	if btn(⬇️) then
		shipsy=2
	end
	if btn(⬅️) then
		shipspr=1
		shipsx=-2
	end
	if btn(➡️) then
		shipspr=3
		shipsx=2
	end
	if btnp(❎) then
		muzzle=4
		sfx(0)
		add(bullets,
			{x=shipx,y=shipy-4,s=5,spd=5}
		)
	end
	if btnp(🅾️) and bombs>0 then
		muzzle=4
		sfx(1)
		add(bullets,
			{x=shipx,y=shipy-4,s=12,spd=3}
		)
		bombs-=1
	end

	animate_ship()	
	animate_bullets()
	animate_flame()
	animate_muzzle()
	amimate_enemies()
	animate_stars()
	animate_planets()
	
	--check for edges
	speedy=0
 if shipx>120 then
 	shipx=120
 	lives-=1
 end
 if shipx<0 then
 	shipx=0
 	lives-=1
 end
 if shipy>120 then
 	shipy=120
 end
 if shipy<8 then
 	shipy=8
 end
 
 if (lives<=0) mode="over" 
end

function update_start()
	animate_stars()
	if btnp(❎) or btnp(🅾️) then
	 set_load()
	 mode="load"
	end
end

function update_over()
	if btnp(❎) or btnp(🅾️) then
		set_start()
	 mode="start"
	end
end

function update_load()
	if shipy>60 then
		space+=2
		animate_ship()
		animate_flame()
		animate_stars()
	else
		start_game()
	end
end
-->8
--draw
function draw_game()
	cls(0)
	
	starfield()
	
	if bullets then
		for b in all(bullets) do
			spr(b.s,b.x,b.y)
		end
	end
	
	if enemies then
		for e in all(enemies) do
			spr(e.s,e.x,e.y)
		end
	end
	
	spr(shipspr,shipx,shipy)
	spr(flmspr,shipx,shipy+8)
	
	if muzzle>0 then
		circfill(shipx+3,shipy-1,muzzle,7)
		circfill(shipx+4,shipy-1,muzzle,7)
	end
	
	rectfill(0,0,128,7,0)
	print("score:"..score,42,0,6)
	
	--draw lives
	for i=0,tlives-1 do
		if i<=lives then
			spr(11,i*8)
		else
			spr(10,i*8)
		end	
	end
	
	--draw bombs
	for i=0,bombs-1 do
			spr(12,i*-8+120)
	end
end

function draw_start()
	cls(1)
	starfield()
	for bs in all(big_stars) do
		spr(33,bs.x,bs.y)
	end
	print("a little great shmup",24,40,12)
	print("press ❎/🅾️ to start",24,80,blink())
end


function draw_over()
	cls(2)
	print("game",56,40,8)
	print("over",56,48,8)
	print("press ❎/🅾️ to continue",18,80,blink())
end

function draw_load()
	cls(1)
	rectfill(0,0,128,space,0)
	starfield()
	spr(shipspr,shipx,shipy)
	spr(flmspr,shipx,shipy+8)
end

function starfield()
	for p in all(planets) do
		spr(p.s,p.x,p.y)
	end

	for s in all(stars) do
		pset(s.x,s.y,s.col)
		if s.col==7 then
			line(s.x,s.y-1,
			s.x,s.y-1,6)
		end
	end	
end
-->8
--tools
function gen_stars(n)
	for i=1,n do
		add(stars,
		{
			x=flr(rnd(128)),
			y=flr(rnd(128)),
			col=scolors[flr(rnd(3)+1)]
		})
	end
end

function rnd_spr_pos(n)
	local coord={}
	for i=1,n do
		add(coord,{x=rnd(120),y=rnd(120)})
	end
	return coord
end
-->8
--setups
function set_start()
	stars={}
	planets={}
	scolors={1,13,7}
	gen_stars(120)
	big_stars=rnd_spr_pos(5)
end

function set_load()
	space=0
	shipspr=2
	shipx=60
	shipy=128
	shipsx=0
	shipsy=-1
	flmspr=17
end
__gfx__
00000000000220000002200000022000000990000009900000099000000990000009900000099000088088000880880000094000000940000009400000094000
00000000000e2000002e820000028000009aa9000097790000977900009779000097790000977900800800808778888000999400009994000099940000999400
0000000000e88200002e8200002e820009a77a900097a900009a7900009a79000097a9000097a9008000008087888880009a04000099a00000099a0000a09400
000000000088820002e8882000e8880009aa7a900009a000009a9900009a99000099a9000009a00008000800088888000060a60000660a0000a66000000a6600
00000000027c88202e87c88202887c200097a9000000900000099000000990000009900000009000008080000088800000066000000660000006600000066000
0000000008cc8880888cc8880888cc80000a90000009900000099000000900000009900000099000000800000008000000555500005555000055550000555500
00000000058582505285582505285850000900000009000000009000000000000009000000090000000000000000000000000000000000000000000000000000
00000000090990909029920909099090000090000000900000000000000000000000000000009000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000005550000000000000000000000000000000000000000000000000000000000
000000000c7777c0000770000c7777c0cc7777cc0c7777c000155100001150000555405000055500000000000000000000000000000000000000000000000000
000000000cc77cc000c77c000cc77cc0ccc77ccc0cc77cc001511110011115005044455005515525000000000000000000000000000000000000000000000000
0000000000c77c0000c77c0000c77c000cccccc000c77c0001111110015111105540554405d25515000000000000000000000000000000000000000000000000
0000000000cccc0000c77c0000cccc0000cccc0000cccc0001111510011111105055555555551550000000000000000000000000000000000000000000000000
00000000000cc00000cccc00000cc00000000000000cc000005111100111151005504055551d5550000000000000000000000000000000000000000000000000
0000000000000000000cc00000000000000000000000000000051100001551000554455005550000000000000000000000000000000000000000000000000000
0000000000000000000cc00000000000000000000000000000000000000000000054500000000000000000000000000000000000000000000000000000000000
00000000000000004033330440333304403333044033330440333304403333044033330440333304000000000000000000000000000000000000000000000000
000000000000000044bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb44000000000000000000000000000000000000000000000000
00000000006060003b7777b33b7777b33bbbbbb33bbbbbb33bbbbbb33bbbbbb33b7777b33b7777b3000000000000000000000000000000000000000000000000
00000000000700003b7117b33b7117b33b7117b33bb33bb33bb33bb33b7117b33b7117b33b7117b3000000000000000000000000000000000000000000000000
000000000060600003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb30000000000000000000000000000000000000000000000000
00000000000000000072270000722700007227000072270000777700007227000072270000722700000000000000000000000000000000000000000000000000
00000000000000000300003003000030037007300037730000300300003773000370073003000030000000000000000000000000000000000000000000000000
00000000000000000700007003700730000000000000000000000000000000000000000003700730000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000000003b0503705034050310502d0502a0502705024050210501f0501d0501b0501905017050150501405012050100500f0500e0500d0500000000000000000000000000000000000000000000000000000000
0001000038650306502d650296502665023650226501e650196501a65016650126500e6500e6500b6500a65006650046500265000650000000000000000000000000000000000000000000000000000000000000
