pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- main

#include MicroQiskit.lua

function _init()
	state = "start_menu"
	make_items()
	make_player()
	init_start_menu()
	init_inventory_complete()
end

function _update()
	if state=="start_menu" then
        update_start_menu()
	elseif state=="inventory_complete" then
		update_inventory_complete()
    elseif state=="game" then
		update_game()
    end
end

function _draw()
	cls()
	if state=="start_menu" then
    	draw_start_menu()
	elseif state=="inventory_complete" then
		draw_inventory_complete()
  	elseif state=="game" then
    	draw_player()
	elseif state=="game_over" then
		print("YOU DIED", 37, 70, 8)
  	end
end

function quantum_calculations(item, shots)
    local qc = QuantumCircuit()
    qc.set_registers(4)
    --check what items the player is holding and do the gate
    qc.h(0)
    qc.h(1)
    qc.h(2)
    qc.h(3)
    --qc.cx(0,1)
    --qc.cx(0,2)
    --qc.cx(0,3)

    w=0
    while w < count(player.items) do
        if (player.items[w] == "sword") then
            qc.h(w)
        elseif (player.items[w] == "shield") then
            qc.cx(w,3)
        elseif (player.items[w] == "toe ring") then
            qc.rx(pi/4,w)
        end
    end

    local meas = QuantumCircuit()
    meas.set_registers(4,4)
    meas.measure(0,0)
    meas.measure(1,1)
    meas.measure(3,3)
    meas.measure(2,2)

    qc.add_circuit(meas)
    result = simulate(qc,"counts",100)
end

function damage_calculations()
    --states = {0000=0, 0001=1, 0010=2, 0100=4, 1000=8, 0011=3, 0110=6, 1100=12, 0101=5, 1010=10, 1001=9, 0111=7, 1110=14, 1111=15, 1101=13, 1011=11}
    weight = 0
    for string, counts in pairs(result) do
        print(string.."="..counts)
        print(counts)
        if (string == "0000") then
            weight = weight + (0*(counts/100))
        elseif (string == "0001") then
            weight += 1*(counts/100)
        elseif (string == "0010") then
            weight = weight + (2*(counts/100))
        elseif (string == "0100") then
            weight += 4*(counts/100)
        elseif (string == "1000") then
            weight += 8*(counts/100)
        elseif (string == "0011") then
            weight += 3*(counts/100)
        elseif (string == "0110") then
            weight += 6*(counts/100)
        elseif (string == "1100") then
            weight += 12*(counts/100)
        elseif (string == "0101") then
            weight += 5*(counts/100)
        elseif (string == "1010") then
            weight += 10*(counts/100)
        elseif (string == "1001") then
            weight += 9*(counts/100)
        elseif (string == "0111") then
            weight += 7*(counts/100)
        elseif (string =="1110") then
            weight += 14*(counts/100)
        elseif (string == "1111") then
            weight += 15*(counts/100)
        elseif (string == "1101") then
            weight += 13*(counts/100)
        elseif (string == "1011") then
            weight += 11*(counts/100)
        end
    end
    print(weight)
end

function rndb(low,high)
	return flr(rnd(high-low+1)+low)
end

-->8
--game

function update_game()
	if btnp(5) then
		-- if user presses x while game is running, present menu to quit or something
	end
end

-->8
--items

function make_items()
	items = {}
	items[1]="sword"
	items[2]="shield"
	items[3]="toe ring"

	item_lookup = {}
	item_lookup[1]=false
	item_lookup[2]=false
	item_lookup[3]=false

	item_to_gate = {sword="h",shield="cx",ring="pi/4"}

	item_str_to_sprite_index = {}
	item_str_to_sprite_index["sword"] = 64
	item_str_to_sprite_index["shield"] = 68
	item_str_to_sprite_index["toe ring"] = 72

	item_num_to_sprite_index = {}
	item_num_to_sprite_index[1] = 64
	item_num_to_sprite_index[2] = 68
	item_num_to_sprite_index[3] = 72
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
	player.items={}
  
	player1={}
	player1.x=70 --position
	player1.y=60
	player1.dy=0 --fall speed
	player1.rise=1 --sprites
	player1.fall=2
	player1.dead=3
	player1.speed=2 --fly speed
	player1.score=0
	player1.items={}
  
end

function draw_player()
	if (game_over) then
		spr(player.dead,player.x,player.y)
		spr(player1.dead,player1.x,player1.y)
	elseif (player.dy<0) then
		spr(player.rise,player.x,player.y)
		spr(player1.rise,player1.x,player1.y)
	else
		spr(player.fall,player.x,player.y)
		spr(player1.fall,player1.x,player1.y)
	end


end

-->8
--menu

function lerp(startv,endv,per)
	return(startv+per*(endv-startv))
end

function init_start_menu()
	items_selected = 0
	m={}
	m.x=8
	m.y=10
	m.options={"sword","shield",
			"toe ring"}
	m.amt=count(m.options)
	m.sel=1
	col1=7
	col2=3
end

-- Init the options when inventory is complete
function init_inventory_complete()
	inv_c={}
	inv_c.x=8
	inv_c.y=40
	inv_c.options={"start!","reset",
			"exit"}
	inv_c.amt=count(inv_c.options)
	inv_c.sel=1
	cx=inv_c.x
	col1=7
	col2=3
end

function update_start_menu()
	update_start_menu_cursor()
	if btnp(4) then
		items_selected += 1
		player.items[items_selected] = items[m.sel]
		if count(player.items) == count(items) then
			state = "inventory_complete"
		end
	end
	if btnp(❎) then
    	state="inventory_complete"
    end
end

function update_start_menu_cursor()
	if (btnp(0)) m.sel-=1
	if (btnp(1)) m.sel+=1 
	if (m.sel>m.amt) m.sel=1
	if (m.sel<=0) m.sel=m.amt
end

function update_inventory_complete()
	update_inventory_complete_cursor()
	if btnp(4) then
		if inv_c.options[inv_c.sel] == "start!" then
			state = "game"
		elseif inv_c.options[inv_c.sel] == "reset" then
			state = "start_menu"
			init_start_menu() -- Reset start menu variables
			make_player() -- Reset players
		elseif inv_c.options[inv_c.sel] == "exit" then
			state = "game_over"
		end
	end
end

function update_inventory_complete_cursor()
	if (btnp(2)) inv_c.sel-=1 cx=inv_c.x
	if (btnp(3)) inv_c.sel+=1 cx=inv_c.x
	if (btnp(4)) cx=inv_c.x
	if (inv_c.sel>inv_c.amt) inv_c.sel=1
	if (inv_c.sel<=0) inv_c.sel=inv_c.amt

 	cx=lerp(cx,inv_c.x+5,0.5)
end

function draw_weapon_options()
	frame_width = 32
	gap = 5
	lsw = 4-1 -- large sprite width
	lsh = 4-1 -- large sprite height
	lsoff = 16 -- large sprite number offset
	si = 64 -- large sprite first index
	for i=1, 3, 1 do
		spr(si+((i-1)*4), 10-gap+((32*i)-32)+(gap*i), 20, 4, 4)
	end
	for i=1, m.amt do
  		if i==m.sel then
			rect((10-1)-gap+((32*i)-32)+(gap*i),20-1,10-gap+32+1+((32*i)-32)+(gap*i),20+32+1,7)
			rect(10-gap+((32*i)-32)+(gap*i),20,10-gap+32+((32*i)-32)+(gap*i),20+32,7)
  		else
		  	rect(10-gap+((32*i)-32)+(gap*i),20,10-gap+32+((32*i)-32)+(gap*i),20+32,7) -- Item Options
   			--print(m.options[i],m.x,m.y+offset,col1)
		end
	end
end

-- Update the inventory as player picks items
function draw_inventory()
	-- Draw placeholder boxes for inventory
	for i=1, count(items), 1 do
		rect(4+((32*i)-32)+(gap*i),80,4+32+((32*i)-32)+(gap*i),80+32,7) -- Inventory
	end
	-- Draw sprites for items as they're selected in their boxes
	for i=1, count(player.items), 1 do
		spr(item_str_to_sprite_index[player.items[i]], 10-gap+((32*i)-32)+(gap*i), 80, 4, 4)
	end
end

-- When all inventory slots are assigned a weapon or the player presses x ask them what they want to do
-- User can start the game or reset inventory and re-select
function draw_inventory_complete()
	rectfill(inv_c.x-8,inv_c.y-8,inv_c.x+32,inv_c.y+40,3)
	draw_proceed_options()
	
	print("what next?",inv_c.x,inv_c.y-4,col1)
	line(inv_c.x,inv_c.y+2,inv_c.x+22,inv_c.y+2,col1)
end

-- Draw the options for the user to start a game, reset inventory selection, or exit
function draw_proceed_options()
	for i=1, inv_c.amt do
		offset=i*8
		if i==inv_c.sel then
			rectfill(cx,inv_c.y+offset-1, cx+36, inv_c.y+offset+5, col1)
   			print(inv_c.options[i], cx+1, inv_c.y+offset, col2)
  		else
   			print(inv_c.options[i], inv_c.x, inv_c.y+offset, col1)
  		end
 	end
end

function draw_start_menu()
	--rectfill(m.x-8,m.y-8,m.x+32,m.y+40,3)
	draw_weapon_options()
	draw_inventory()

	print("choose your weapon",m.x,m.y-4,col1)
	line(m.x,m.y+2,m.x+70,m.y+2,col1)

	print("inventory",m.x,m.y+60,col1)
	line(m.x,m.y+66,m.x+35,m.y+66,col1)
end

-->8
--helpers

function print_5(messge)
	for i=1, 30, 1 do
		for i=1, 500, 1 do
			print(message, 37, 70, 14)
		end
		yield()
	end
end

__gfx__
000000000000000000000000000000000001c0000100001000089800000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa0000770000000000000111c00011001100089a900000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0000a000077000008888000011110001111110009a9800000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0770a000007000088888800011110001911910008a8000000000000000000000000000000000000000000000000000000000000000000000000000
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
