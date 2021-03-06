pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--labrynth
--by atomicxistence

--todo
--bug: items go off the board
--menu screen
--player # selection
--change indicator of unavailable tile move
--sprite upgrade/enchance color contrast
--music

function _init()
	cls()
	setup_vars()
	--labrynth setup
	local _starting_pos=positions[1]
	free_tile={sprite=16,x=_starting_pos.x,y=_starting_pos.y,pos_key=1}
	lab=setup_lab()
	--player setup
	players=player_setup()
	cplayer=players[1]
	--item setup
	items=item_setup()
end

function _update()
	if task_running() then
		--continue running
	else
		update()
	end
end

function _draw()
	cls()
	draw()
end	

function draw_game()
	--draw labrynth
	for column in all(lab) do
		foreach(column,draw_tile)
	end
	draw_tile(free_tile)
	--draw items
	foreach(items,draw_tile)
	--draw players
	foreach(players,draw_tile)
	draw_gui()
end

function draw_borders()
	color(cplayer.color)
	rect(origin.x+6,origin.y+6,origin.x+80,origin.y+80)
end

function draw_lab()
	for _row=1,9 do
		for _col=1,9 do
			local _tile=lab[_row][_col]
			spr(_tile,origin.x+8*_row,origin.y+8*_col)
		end
	end
end

function draw_tile(_tile)
	local _x,_y=flr(_tile.x*8+origin.x),flr(_tile.y*8+origin.y)
	spr(_tile.sprite,_x,_y)
end

function draw_instructions()
	cursor(origin.x+6,origin.y+84)
	color(cplayer.color)
	print(instructions[1])
	color(5)
	print("-------------------")
	for i=2,#instructions do
		print(instructions[i])
	end
	color()
end

function draw_scores()
	cursor(2,origin.y+10)
	for _player in all(players) do
		color(_player.color)
		--print("p"..(_player.sprite-4))
		print("keys")
		color(6)
		print(_player.items.."/"..goal)
		color(5)
		print("----")
	end
end

function draw_gui()
	draw_borders()
	draw_instructions()
	draw_scores()
end

function draw_menu()
	cursor(48,30,9)
	print("labrynth")

	cursor(24,120,5)
	print("press ❎ to continue")
end

function task_running()
	for _task in all(task_pool) do
		if costatus(_task)=="suspended" then
			assert(coresume(_task))
		else
			del(task_pool,_task)
		end
	end
	return #task_pool>0
end

function update_menu()
	if btnp(❎) then
		draw=draw_game
		update=update_tile
	end
end

function update_tile()
	instructions[1]="  player "..(cplayer.sprite-4).."'s turn"
	instructions[2]="❎: rotate tile"
	instructions[3]="🅾️: shift labrynth"
	if btnp(❎) then 
		--rotate tile
		free_tile.sprite=rotate_tile(free_tile.sprite)
		sfx(0)
	end
	if btnp(🅾️) then
		--make sure its not invalid_space
		if same_space(invalid_space,free_tile) then
			--do not push tile in
			sfx(4)
		else
			--push tile in
			push_tiles()
			update=update_player
			sfx(2)
		end
	end
	if btnp(⬅️) then 
		free_tile=move_freetile(free_tile,left) 
		sfx(1)
	end
	if btnp(➡️) then 
		free_tile=move_freetile(free_tile,right)
		sfx(1) 
	end
	if btnp(⬆️) then 
		free_tile=move_freetile(free_tile,up) 
		sfx(1)
	end
	if btnp(⬇️) then 
		free_tile=move_freetile(free_tile,down) 
		sfx(1)
	end
end

function update_player()
	instructions[1]="  player "..(cplayer.sprite-4).."'s turn"
	instructions[2]="❎: end turn"
	instructions[3]=nil
	local _ctile=lab[cplayer.x][cplayer.y]
	item_pickup()
	if btnp(❎) then
		next_player_turn()
	end
	if btnp(⬅️) then
		move_player(_ctile,left)
	end
	if btnp(➡️) then 
		move_player(_ctile,right)
	end
	if btnp(⬆️) then 
		move_player(_ctile,up)
	end
	if btnp(⬇️) then 
		move_player(_ctile,down)
	end
end

function gameover()
	if btnp(❎) then _init() end
end

function move_player(_tile,_dir)
	if is_path(_tile,_dir) then 
		move_direction(cplayer,_dir)
		sfx(1)
	else
		sfx(4)
	end
end

function win_check()
	for player in all(players) do
		if player.items >= goal then
			--game over, player wins
			instructions={"  player "..(player.sprite-4).." wins!","❎: play again"}
			update=gameover
			return false
		end
		return true
	end
end	
-->8
--setup

function setup_vars()
	--variables
	ani_speed=8
	goal=5
	--tables
	origin={x=19,y=10}
	up={x=0,y=-1,flag=2}
	down={x=0,y=1,flag=3}
	right={x=1,y=0,flag=1}
	left={x=-1,y=0,flag=0}
	positions={{x=3,y=1},{x=5,y=1},{x=7,y=1},{x=9,y=3},{x=9,y=5},{x=9,y=7},{x=7,y=9},{x=5,y=9},{x=3,y=9},{x=1,y=7},{x=1,y=5},{x=1,y=3}}
	invalid_space={x=0,y=0}
	task_pool={}
	instructions={}
	debug={}
	--game states
	update=update_menu
	draw=draw_menu
end

function setup_lab()
	local _lab=initial_lab()
	local _tiles={}
	--add 13 straight tiles (spr 33-36)
	_tiles=add_tiles(33,13,_tiles)
	--add 9 corner tiles (spr 17-20)
	_tiles=add_tiles(17,9,_tiles)
	--add 12 t tiles (spr 49-52)
	_tiles=add_tiles(49,12,_tiles)
	_tiles=shuffle_tiles(_tiles)
	--place the shuffled tiles and
	--get back the extra tile
	_lab,free_tile.sprite=place_tiles(_lab,_tiles)
	return _lab
end

function initial_lab()
	--returns a 2d array of tiles
	--tiles are an array of sprite, x & y
	local _lab={}
	local _index=1	
	for _x=1,9 do
		local _row={}
		for _y=1,9 do
			local _i=place_indicator(_x,_y)
			if _i==nil then 
				_i=place_default_tile(_x,_y,_index) 
				if _i==nil then
					_i=16
				else 
					_index+=1
				end	
			end
			local _tile={sprite=_i,x=_x,y=_y}	
			add(_row,_tile)
		end
		add(_lab,_row)
	end
	return _lab
end

function place_indicator(_x,_y)
	--down
	if _y==1 and mid(2,_x,8)%2==1 then return 1 end
	--left
	if _x==9 and mid(2,_y,8)%2==1 then return 2 end
	--up
	if _y==9 and mid(2,_x,8)%2==1 then return 3 end
	--right
	if _x==1 and mid(2,_y,8)%2==1 then return 4 end
	--not an indicator
	return nil
end

function place_default_tile(_x,_y,_index)
	--default tile sequence
	local _tiles={17,49,49,20,50,49,52,52,50,50,51,52,18,51,51,19}
	--inside spaces
	if is_inside_space(_x,_y) then 
		 if _x%2==0 and _y%2==0 then
		 	return _tiles[_index]
		 end
	end
	return nil
end

function add_tiles(_spr,_count,_tiles)
	for i=1,_count do
		add(_tiles,flr(rnd(4)+_spr))
	end
	return _tiles
end

function shuffle_tiles(_tiles)
	for i=#_tiles, 2, -1 do
  		local j=max(flr(rnd(i)),1)
  		_tiles[i],_tiles[j]=_tiles[j],_tiles[i]
 	end
	return _tiles
end

function place_tiles(_lab,_tiles)
	--place tiles on empty spots
	local _tindex=1
	for i=1,#_lab do
		for j=1,#_lab[i] do
			if is_inside_space(i,j) then
				local _tile=_lab[i][j]
				if _tile.sprite==16 then
					_lab[i][j]={sprite=_tiles[_tindex],x=i,y=j}
					_tindex+=1
				end
			end
		end
	end
	return _lab,_tiles[_tindex]
end

function player_setup()
	local _players={}
	_players[1]={sprite=5,x=2,y=2,items=0,color=8}
	_players[2]={sprite=6,x=8,y=8,items=0,color=12}
	_players[3]={sprite=7,x=8,y=2,items=0,color=11}
	_players[4]={sprite=8,x=2,y=8,items=0,color=14}
	return _players
end

function item_setup()
	local _items,_invalidspaces={},{}
	for i=1,#players do
		local _invalidspaces=flatten_tables(_items,players)
		add(_items,new_item(i,_invalidspaces))
	end
	return _items
end
-->8
--logic

function next_player_turn()
	cplayer=next_circular(players,get_key(players,cplayer)) 
	update=update_tile
	sfx(3)
end

function item_pickup()
	for item in all(items) do
		if same_space(cplayer,item) then
			debug[cplayer.sprite-4]=(item.sprite-1)%4+1
			if cplayer.sprite-4==(item.sprite-1)%4+1 then
				cplayer.items+=1
				sfx(5)
				if win_check() then
					local _invalidspaces=flatten_tables(items,players)
					item.x,item.y=rnd_place_item(_invalidspaces)
					next_player_turn()
				end
			end
		end
	end
end

function new_item(_pnum,_invalidspaces)
	--returns a randomly placed item
	local _item={sprite=20+_pnum,x=0,y=0}
	_item.x,_item.y=rnd_place_item(_invalidspaces)
	return _item
end

function rnd_place_item(_invalidspaces)
	local _pos={x=flr(rnd(6)+2),y=flr(rnd(6)+2)}
	for _space in all(_invalidspaces) do
		if same_space(_space,_pos) then 
			return rnd_place_item(_invalidspaces) 
		end
	end
	return _pos.x,_pos.y
end

function is_inside_space(_x,_y)
	return _x==mid(2,_x,8) and _y==mid(2,_y,8)
end

function rotate_tile(_sprite)
	if _sprite%4==0 then
		_sprite-=3
	else	
		_sprite+=1
	end
	return _sprite
end

function move_freetile(_spr,_dir)
	if _dir.x==-1 or _dir.y==-1 then
		_v2,_spr.pos_key=previous_circular(positions,_spr.pos_key)
	else
		_v2,_spr.pos_key=next_circular(positions,_spr.pos_key)
	end
	_spr.x,_spr.y=_v2.x,_v2.y
	--skips the invalid space
	if same_space(_spr,invalid_space) then return move_freetile(_spr,_dir) end
	return _spr
end

function tile_limit(_a,_b,_dest)
	if _b==1 or _b==9 then
		_a=mid(1,_a+_dest,9)
		if _a==1 or _a==9 then
			_b=_b==1 and 3 or 7
		end
	end
	return _a,_b
end

function next_circular(_list,_key)
	--returns next in table, circular
	_key=_key%#_list+1
	return _list[_key],_key
end

function previous_circular(_list,_key)
	--returns previous in table, circular
	_key=(_key-2)%#_list+1
	return _list[_key],_key
end

function get_key(_table,_value)
	--shallow search for table contents
	for k,v in pairs(_table) do
		if v==_value then return k end
	end
	--deep search for value comparison
	for k,v in pairs(_table) do
		if v.x==_value.x and v.y==_value.y then return k end
	end
	return nil
end

--refactor!!!!!!!!!
function push_tiles()
	--get location of free_tile
	local _x,_y,_temp=free_tile.x,free_tile.y,free_tile
	if _x==1 or _x ==9 then --free tile is on the left or right
		local _row={}
		for i=1,9 do
			add(_row,lab[i][_y])
		end
		if _x==1 then --push right
			for i=2,#_row-1 do
				--swap tiles
				_row[i],_temp=_temp,_row[i]
				--change the tile's x,y v2s
				move_direction(_row[i],right)
			end
			shift_objects(players,right,_y)
			shift_objects(items,right,_y)
			invalid_space={x=9,y=_y}
		else  --push left
			for i=#_row-1,2,-1 do
				_row[i],_temp=_temp,_row[i]
				move_direction(_row[i],left)
			end
			shift_objects(players,left,_y)
			shift_objects(items,left,_y)
			invalid_space={x=1,y=_y}
		end
		--change labrynth row
		for i=1,9 do
			lab[i][_y]=_row[i]
		end
	else --free tile is on top or bottom
		local _column=lab[_x]
		if _y==1 then --push down
			for i=2,#_column-1 do
				_column[i],_temp=_temp,_column[i]
				move_direction(_column[i],down)
			end
			shift_objects(players,down,_x)
			shift_objects(items,down,_x)
			invalid_space={x=_x,y=9}
		else --push up
			for i=#_column-1,2,-1 do
				_column[i],_temp=_temp,_column[i]
				move_direction(_column[i],up)
			end
			shift_objects(players,up,_x)
			shift_objects(items,up,_x)
			invalid_space={x=_x,y=1}
		end
		--change labrynth column
		lab[_x]=_column
	end
	--reassign free_tile
	free_tile={
		sprite=_temp.sprite,
		x=invalid_space.x,
		y=invalid_space.y,
		pos_key=get_key(positions,invalid_space)}
end

function shift_objects(_objects,_dir,_ref)
	local _newpos
	if _dir.x == 0 then --shifting vertically
		for _obj in all(_objects) do
			if _obj.x==_ref then 
				_newpos=move_direction(_obj,_dir)
				_obj.y=wrap_item(_newpos.y,_dir.y)				 
			end
		end
	else --shifting horizontally
		for _obj in all(_objects) do
			if _obj.y==_ref then 
				_newpos=move_direction(_obj,_dir) 
				_obj.x=wrap_item(_newpos.x,_dir.x)
			end
		end
	end
end

function wrap_item(_axis,_dir)
	if _axis%9<2 then --obj is outside
		--move to other side
		_axis+=8*-(_dir)
	end
	return flr(_axis)
end

function move_direction(_obj,_dir)
	local _task=cocreate(function() move_animate(_obj,_dir) end)
	add(task_pool,_task)
	return {x=_obj.x+_dir.x,y=_obj.y+_dir.y}
end

function move_animate(_obj,_dir)
	local _offset=1/ani_speed
	for i=1,ani_speed do
		_obj.x+=_offset*_dir.x
		_obj.y+=_offset*_dir.y
		yield()
	end
end

function same_space(_a,_b)
	return _a.x==_b.x and _a.y==_b.y
end

function is_path(_tile,_dir)
	if fget(_tile.sprite,_dir.flag) then
		--get tile in desired direction
		local _dtile,_dflag=lab[_tile.x+_dir.x][_tile.y+_dir.y],_dir.flag%2==0 and _dir.flag+1 or _dir.flag-1
		if is_inside_space(_dtile.x,_dtile.y) then
			return fget(_dtile.sprite,_dflag)		
		end
	end
	return false
end

function flatten_tables(...)
	local _new_table,_tables={},{...}
	for table in all(_tables) do
		for item in all(table) do
			add(_new_table,item)
		end
	end
	return _new_table
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000a0000000a00000000a00000080000000c0000000b0000000e000000000000000000000000000000000000000000000000000000000000
007007000000000000aa000000aaa0000000aa000088800000ccc00000bbb00000eee00000000000000000000000000000000000000000000000000000000000
00077000000000000aaa00000aaaaa000000aaa000080000000c0000000b0000000e000000000000000000000000000000000000000000000000000000000000
000770000aaaaa0000aa0000000000000000aa000080800000c0c00000b0b00000e0e00000000000000000000000000000000000000000000000000000000000
0070070000aaa000000a0000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505555555055666550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505555555055666550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055666660666665506666655055666660000088000000cc000000bb000000ee0000000000000000000000000000000000000000000000000000000000
0000000055666660666665506666655055666660088808000ccc0c000bbb0b000eee0e0000000000000000000000000000000000000000000000000000000000
00000000556666606666655066666550556666600080880000c0cc0000b0bb0000e0ee0000000000000000000000000000000000000000000000000000000000
00000000556665505566655055555550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556665505566655055555550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505566655055555550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505566655055555550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666605566655066666660556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666605566655066666660556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666605566655066666660556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505566655055555550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505566655055555550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556665505555555055666550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556665505555555055666550556665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556666606666666066666550666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556666606666666066666550666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556666606666666066666550666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556665505566655055666550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556665505566655055666550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
00000000000000000000000000000000000a090506000000000000000000000000030c030c0000000000000000000000000e0b0d07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000110032003200120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000310031003200330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000310034003300330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000140034003400130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000300030003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000600001762017620206200060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0006000004140041400c1400c14000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000600001f1501f15019150191501f1501f1501c1501c150151501515015150151501015010150101501015000100001000010000100001000010000100001000010000100001000010000100001000010000100
000400000645004450014500040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000600000515005150001500015000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0005000033750337503d7503d7503d7503d7500070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
