pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main
function _init()
	cls(0)
	mode="start"	
	blinkt=0
	en_tps={
		{s=32,spd=2,hp=1},
		{s=48,spd=3,hp=2}
	}
	cntr=0
	
	invnrbl=0
	starspd=2
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
	score=0
	lives=4
	tlives=4
	mbombs=3
	bombs=3
	starspd=2
	invnrbl=0
	bullt=0
	
	ship={
		x=60,
		y=60,
		sx=0,
		sy=0,
		s=2
	}

	flmspr=17
	
	bullets={}
	enemies={}
	muzzle=0
	xplsns={}
	prtcls={}
		
	planets={}
	mode="game"
end
-->8
--animation
function animate_ship()
	ship.x+=ship.sx
	ship.y+=ship.sy
	
	if invnrbl>0 and invnrbl%2==0 then
		ship.s=0
	end
end

function animate_bullets()
	for b in all(bullets) do
		if (b.y<0) del(bullets,b)
		
		b.y-=b.spd
		if b.s<12 then
			b.s+=0.75
			if b.s>=10 then
				b.s=5
			end
		else
			b.s+=0.25
			if b.s>=16 then
				b.s=12
			end
		end
	end
end

function animate_flame()
	flmspr+=1
	if flmspr>=21 then
		flmspr=17
	end
end

function animate_muzzle()
	if (muzzle>0)	muzzle-=1
end

function animate_xplsn()
	for ex in all(xplsns) do
		if (ex.r>0) ex.r-=1
		if (ex.r<=0) del(xplsns,ex)
	end
end

function animate_stars()
	for i=1,#stars do
		local spd=starspd
	
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
		
		if flr(e.x)>ship.x then
			e.x-=0.7
		elseif flr(e.x)<ship.x then
			e.x+=0.7
		end

		e.s+=0.4
		if e.s>=e.ini_s+7 then
			e.s=tonum(e.ini_s)
		end
		
		if e.y>128 then
			del(enemies,e)
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

function animate_prtcls()
	for p in all(prtcls) do
		p.x+=p.sx
		p.y+=p.sy
		p.age+=1
		p.sx*=0.85
		p.sy*=0.75
		
		if p.age>p.mxage then
			p.size-=0.5
			if (p.size<0) del(prtcls,p)
		end
	end
end
-->8
--update

function update_game()
	cntr+=1
	if (cntr>=1800) cntr=0
	
		--controls
	ship.s=2
	ship.sx=0
	ship.sy=0
	if btn(⬆️) then
		ship.sy=-2
	end
	if btn(⬇️) then
		ship.sy=2
	end
	if btn(⬅️) then
		ship.s=1
		ship.sx=-2
	end
	if btn(➡️) then
		ship.s=3
		ship.sx=2
	end
	if btn(❎) and bullt<=0 then
		bullt=4
		muzzle=4
		sfx(0)
		add(bullets,
			{x=ship.x,y=ship.y-4,s=5,spd=5}
		)
	end
	bullt-=1
	if btnp(🅾️) and bombs>0 then
		muzzle=4
		sfx(1)
		add(bullets,
			{x=ship.x,y=ship.y-4,s=12,spd=3}
		)
		bombs-=1
	end

	animate_ship()	
	check_edges()
	animate_bullets()
	animate_xplsn()
	animate_prtcls()
	animate_flame()
	animate_muzzle()
	amimate_enemies()
	chk_ene_col()
	animate_stars()
	animate_planets()
	
	if invnrbl>0 then
		invnrbl-=1
	end
 
 if (lives<=0) then
 	mode="over" 
		return
	end
	
	if cntr%90==0 then
		gen_ene(2)
	elseif cntr%20==0 then
		gen_ene(1)
	end
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
	if ship.y>60 then
		space+=2
		animate_ship()
		animate_flame()
		animate_stars()
		txtoffset+=1
	else
		start_game()
	end
end
-->8
--draw
function draw_game()
	cls(0)
	
	starfield()
	draw_spr(bullets)
	draw_spr(enemies)
	draw_xplsns()
	draw_prtcls()
		
	spr(ship.s,ship.x,ship.y)
	spr(flmspr,ship.x,ship.y+8)
	
	if muzzle>0 then
		circfill(ship.x+3,ship.y-1,muzzle,7)
		circfill(ship.x+4,ship.y-1,muzzle,7)
	end
	
	rectfill(0,0,128,7,0)
	print("score:"..score,42,0,6)
	
	--draw lives
	for i=1,tlives do
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
		spr(26,bs.x,bs.y)
	end
	print("a little big shmup",28,txtoffset,12)
	print("press ❎/🅾️ to start",24,txtoffset*2,blink())
end


function draw_over()
	cls(2)
	print("game",56,40,8)
	print("over",56,48,8)
	print("press ❎/🅾️ to continue",18,80,blink())
end

function draw_load()
	cls(1)
	print("a little big shmup",28,txtoffset,12)
	print("press ❎/🅾️ to start",24,txtoffset+40,blink())
	rectfill(0,0,128,space,0)
	starfield()
	spr(ship.s,ship.x,ship.y)
	spr(flmspr,ship.x,ship.y+8)
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

function draw_xplsns()
	for ex in all(xplsns) do
		circfill(ex.x,ex.y,ex.r,6)
		circfill(ex.x+1,ex.y+1,ex.r-1,9)
		circfill(ex.x+2,ex.y+2,ex.r-2,10)
	end
end


function draw_prtcls()
	for p in all(prtcls) do
		local pc=7
		if (p.age>5) pc=9
		if (p.age>7)	pc=10
		if (p.age>10) pc=8
		if (p.age>12) pc=2
		if (p.age>15) pc=5
		
		circfill(p.x,p.y,p.size,pc)
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

function draw_spr(t)
	if t then
		for i in all(t) do
			spr(i.s,i.x,i.y)
		end
	end
end

function gen_ene(t)
	add(enemies,{
		x=rnd(120),
		y=0,
		spd=en_tps[t].spd,
		s=en_tps[t].s,
		ini_s=en_tps[t].s,
		hp=en_tps[t].hp
	})
end

function check_edges()
	if ship.x>120 then
 	ship.x=120
 end
 if ship.x<0 then
 	ship.x=0
 end
 if ship.y>120 then
 	ship.y=120
 end
 if ship.y<8 then
 	ship.y=8
 end
end

function col(a,b)
	local a_l=a.x
	local a_r=a.x+7
	local a_t=a.y
	local a_b=a.y+7

	local b_l=b.x
	local b_r=b.x+7
	local b_t=b.y
	local b_b=b.y+7
	
	if (a_t>b_b) then return false end
	if (b_t>a_b) then return false end
	if (a_l>b_r) then return false end
	if (b_l>a_r) then return false end
	
	return true
end

function chk_ene_col()
	for e in all(enemies) do
		for b in all(bullets) do
			if col(b,e) then
				sfx(2)
				del(bullets,b)
				e.hp-=1
				if e.hp<=0 then
					explode(e.x,e.y)
				 del(enemies,e) 
					score+=1
					if score%50==0 and lives<tlives then
						sfx(3)
						lives+=1
					end
				end
			end
		end
		
		 
		if invnrbl<=0 then
			if col(e,ship) then
				sfx(1)
				lives-=1
				invnrbl=100
				del(enemies,e)
			end
		end
	end
end

function explode(x,y)
	--add(xplsns,{x=x,y=y,r=r})	
	local spdadj=6
	for i=1,20 do
		add(prtcls,{
			x=x,
			y=y,
			sx=(rnd()-0.5)*spdadj,
			sy=(rnd()-0.5)*spdadj,
			age=rnd(3),
			mxage=10+rnd(10),
			size=1+rnd(4)
		})
	end
end
-->8
--setups
function set_start()
	stars={}
	planets={}
	txtoffset=40
	scolors={1,13,7}
	gen_stars(120)
	big_stars=rnd_spr_pos(5)
end

function set_load()
	starspd=3
	space=0
	shipspr=2
	shipx=60
	shipy=128
	shipsx=0
	shipsy=-1
	flmspr=17
	ship={
		x=60,
		y=128,
		sx=0,
		sy=-1,
		s=2
	}
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
000000000cc77cc000c77c000cc77cc0ccc77ccc0cc77cc001511110011115005044455005515525006060000000000000000000000000000000000000000000
0000000000c77c0000c77c0000c77c000cccccc000c77c0001111110015111105540554405d25515000700000000000000000000000000000000000000000000
0000000000cccc0000c77c0000cccc0000cccc0000cccc0001111510011111105055555555551550006060000000000000000000000000000000000000000000
00000000000cc00000cccc00000cc00000000000000cc000005111100111151005504055551d5550000000000000000000000000000000000000000000000000
0000000000000000000cc00000000000000000000000000000051100001551000554455005550000000000000000000000000000000000000000000000000000
0000000000000000000cc00000000000000000000000000000000000000000000054500000000000000000000000000000000000000000000000000000000000
00333300003333000033330000333300003333000033330000333300003333000000000000000000000000000000000000000000000000000000000000000000
03bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb300000000000000000000000000000000000000000000000000000000000000000
3b7777b33b7777b33bbbbbb33bbbbbb33bbbbbb33bbbbbb33b7777b33b7777b30000000000000000000000000000000000000000000000000000000000000000
3b7117b33b7117b33b7117b33bb33bb33bb33bb33b7117b33b7117b33b7117b30000000000000000000000000000000000000000000000000000000000000000
03bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb300000000000000000000000000000000000000000000000000000000000000000
00722700007227000072270000722700007777000072270000722700007227000000000000000000000000000000000000000000000000000000000000000000
03000030030000300370073000377300003003000037730003700730030000300000000000000000000000000000000000000000000000000000000000000000
07000070037007300000000000000000000000000000000000000000037007300000000000000000000000000000000000000000000000000000000000000000
40300304403333044030030440300304403003044030030440300304403003040000000000000000000000000000000000000000000000000000000000000000
44b33b4444b33b4444b33b4444b33b4444b33b4444b33b4444b33b4444b33b440000000000000000000000000000000000000000000000000000000000000000
3b7777b33b7777b33bbbbbb33bbbbbb33bbbbbb33bbbbbb33b7777b33b7777b30000000000000000000000000000000000000000000000000000000000000000
3b7887b33b7887b33b7887b33bb33bb33bb33bb33b7887b33b7887b33b7887b30000000000000000000000000000000000000000000000000000000000000000
03bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb3003bbbb300000000000000000000000000000000000000000000000000000000000000000
00722700007227000072270000722700007777000072270000722700007227000000000000000000000000000000000000000000000000000000000000000000
03000030030000300370073000377300003003000037730003700730030000300000000000000000000000000000000000000000000000000000000000000000
07000070037007300000000000000000000000000000000000000000037007300000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000000003b0503705034050310502d0502a0502705024050210501f0501d0501b0501905017050150501405012050100500f0500e0500d0500000000000000000000000000000000000000000000000000000000
0001000038250302502d250292502625023250222501e250192501a25016250122500e2500e2500b2500a25006250042500225000250002000020000200002000020000200002000020000200002000020000200
00020000316502d6502965024650216501d6501965017650156501365013650126501265012650116501165000600006000060000600006000060000600006000060000600006000060000600006000060000600
00030000207501a7501775017750197501b7501d7501f75022750277502d75033750397503f700107001170014700177001a7001e70025700317003b7003b7003b7003b7003b7003b7003b700007000070000700
