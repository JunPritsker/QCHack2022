pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- main

function _init()
	state = "menu"
	game_over=false
	init_menu()
	choose_items()
	make_player()
	make_ground()
end

function _update()
	if state=="menu" then
        update_menu()
    elseif state=="game" then
        update_game()
    end
	move_player()
end

function _draw()
	cls()
	if state=="menu" then
        draw_menu()
    elseif state=="game" then
		draw_ground()
		draw_player()
    end
end

function rndb(low,high)
	return flr(rnd(high-low+1)+low)
end
-->8
-- player

function make_player()	
	player={}
	player.x=24 --position
	player.y=60
	player.dy=0 --fall speed
	player.rise=1 --sprites
	player.fall=2
	player.dead=3
	player.speed=2 --fly speed
	player.score=0
end
function draw_player()
	if (game_over) then
		spr(player.dead,player.x,player.y)
	elseif (player.dy<0) then
		spr(player.rise,player.x,player.y)
	else
		spr(player.fall,player.x,player.y)
	end
end

function move_player()
	gravity=0.2 --bigger means more gravity!
	player.dy+=gravity --add gravity

	--jump
	if (btnp(2)) then
		player.dy-=5
	end

	--move to new position
	player.y+=player.dy
end
-->8

function make_ground()
	--create the ground
	gnd={}
	local top=96 --highest point
	local btm=120 --lowest point

	--set up the landing pad
	pad={}
	pad.width=15
	pad.x=rndb(0,126-pad.width)
	pad.y=rndb(top,btm)
	pad.sprite=2
	
	--create ground at pad
	for i=pad.x,pad.x+pad.width do
		gnd[i]=pad.y
	end
	
	--create ground right of pad
	for i=pad.x+pad.width+1,127 do
		local h=rndb(gnd[i-1]-3,gnd[i-1]+3)
		gnd[i]=mid(top,h,btm)
	end
	
	--create ground left of pad
	for i=pad.x-1,0,-1 do
		local h=rndb(gnd[i+1]-3,gnd[i+1]+3)
		gnd[i]=mid(top,h,btm)
	end
end

function draw_ground()
	for i=0,127 do
		line(i,gnd[i],i,127,5)
	end
end
-->8
--menu

function lerp(startv,endv,per)
	return(startv+per*(endv-startv))
end

function init_menu()
	state="menu"
	m={}
	m.x=8
	m.y=40
	m.options={"sword","shield",
			"toe ring"}
	m.amt=count(m.options)
	m.sel=1
	cx=m.x
	col1=7
	col2=3
end

function update_menu()
	update_cursor()
	if btnp(4) then
		if m.options[m.sel]=="start" then
			state="game"
		end
	end
	if btnp(❎) then
    	state="game"
    end
end

function update_cursor()
	if (btnp(2)) m.sel-=1 cx=m.x
	if (btnp(3)) m.sel+=1 cx=m.x
	if (btnp(4)) cx=m.x
	if (m.sel>m.amt) m.sel=1
	if (m.sel<=0) m.sel=m.amt

	cx=lerp(cx,m.x+5,0.5)
end

function draw_options()
	frame_width = 32
	gap = 0
	lsw = 4-1 -- large sprite width
	lsh = 4-1 -- large sprite height
	lsoff = 16 -- large sprite number offset
	si = 64-- sprite index
	spr(64, 10+((32*1)-32)+(gap*1), 20, 4, 4)
	spr(68, 10+((32*2)-32)+(gap*2), 20, 4, 4)
	spr(72, 10+((32*3)-32)+(gap*3), 20, 4, 4)
	for i=1, m.amt do
		
		if i==1 then
			gap = 0
		else
			gap = 5
		end
  		if i==m.sel then
  			-- rectfill(cx,m.y+offset-1,cx+36,m.y+offset+5,col1)
			rect(10-1+((32*i)-32)+(gap*i),20-1,10+32+1+((32*i)-32)+(gap*i),20+32+1,7)
			rect(10+((32*i)-32)+(gap*i),20,10+32+((32*i)-32)+(gap*i),20+32,7)
   			--print(m.options[i],cx+1,m.y+offset,col2)
  		else
		  	rect(10+((32*i)-32)+(gap*i),20,10+32+((32*i)-32)+(gap*i),20+32,7)
   			--print(m.options[i],m.x,m.y+offset,col1)
		end
	end
end

function draw_menu()
 --rectfill(m.x-8,m.y-8,m.x+32,m.y+40,3)
 draw_options()
 
 print("choose your weapon",m.x,m.y-4,col1)
 line(m.x,m.y+2,m.x+22,m.y+2,col1)
end

function choose_items()
	print("Choose your items", 37, 70, 14)
end

__gfx__
000000000000000000000000000000000001c0000100001000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa0000770000000000000111c00011001100089a900000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0000a000077000008888000011110001111110009a9800000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0770a000007000088888800011110001911910008a8900000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0000a00077777008888888001111000119911000044000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a7777a00000700008800888055555500191191000044000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00007070000000000000440000111111000066000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077077000000000000440000011110000044000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000008888aaa00000000000000000000000000000000000000000000
000000000000000001100000000000000000110000000000000000000011000000000000000008888aaa80000000000000000000000000000000000000000000
000000000000000011110000000000000000111000000000000000000011000000000000000088aa88aa80000000000000000000000000000000000000000000
000000000000000011110000000000000001111110000000000000001111000000000000000088aaaaaa80000000000000000000000000000000000000000000
0000000000000001111110000000000000011011110000000000000111110000000000000008888aaa8880000000000000000000000000000000000000000000
00000000000000011111100000000000000111011111000000000011111100000000000000088999988880000000000000000000000000000000000000000000
00000000000000111111110000000000000011000111111100011111101100000000000000088999989988000000000000000000000000000000000000000000
000000000000011111111100000000000000110000111111111111110011000000000000000899aa88aa88000000000000000000000000000000000000000000
000000000000111111111110000000000000110000000001111110000011000000000000000899aa899a88000000000000000000000000000000000000000000
00000000000011111111111000000000000011100000000000000000001100000000000000088998a99888000000000000000000000000000000000000000000
00000000000111111111111100000000000011100000000000000000011100000000000000088888aa9998000000000000000000000000000000000000000000
00000000000111111111111110000000000001110000000000000000011100000000000000008aa8aa99a8000000000000000000000000000000000000000000
00000000001111111111111110000000000001110000009900990999111000000000000000008aa9aaaaa8000000000000000000000000000000000000000000
00000000001111111111111110000000000001111000009900990999111000000000000000008aa9888880000000000000000000000000000000000000000000
00000000011111111111111110000000000000111100000000099000110000000000000000008888888800000000000000000000000000000000000000000000
00000000011111111111111111000000000000011100099000099001110000000000000000008844444000000000000000000000000000000000000000000000
00000000001111111111111111100000000000001110099000000011100000000000000000000444444000000000000000000000000000000000000000000000
00000000001111111111111111100000000000001110000009900011100000000000000000000444444000000000000000000000000000000000000000000000
00000000011111111111111111100000000000000111000009900111000000000000000000000444444000000000000000000000000000000000000000000000
00000000011111111111111111100000000000000111000000000111000000000000000000000444444000000000000000000000000000000000000000000000
00000001111111111111111111100000000000000011000000011110000000000000000000000444444000000000000000000000000000000000000000000000
00555555555555555555555555555550000000000011100000111100000000000000000000000444444000000000000000000000000000000000000000000000
00555555555555555555555555555550000000000001100001111000000000000000000000000444444000000000000000000000000000000000000000000000
00555555555555555555555555555550000000000001110011110000000000000000000000000555555000000000000000000000000000000000000000000000
00000000000000444440000000000000000000000000110111100000000000000000000000000555555000000000000000000000000000000000000000000000
00000000000000444440000000000000000000000000111111000000000000000000000000000444444000000000000000000000000000000000000000000000
00000000000000444440000000000000000000000000011110000000000000000000000000000444444000000000000000000000000000000000000000000000
00000000000000444440000000000000000000000000011100000000000000000000000000000444444000000000000000000000000000000000000000000000
00000000000000444440000000000000000000000000000000000000000000000000000000000444444000000000000000000000000000000000000000000000
00000000000000444440000000000000000000000000000000000000000000000000000000000444444000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
