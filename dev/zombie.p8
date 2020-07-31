pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--horde
--by jeff adams

--…………work items………………

--◆juices
--animate ui
--particles
--animate turn end
--sfx for attacking
--splash page pixel art

--◆fixes
--played action card not del
--confirm menu for turn end
--balance cards

--◆extras
--hard mode with events
--dpad support
--music

function _init()
	globals()
	init_scavenge()
	init_player()
	change_state(update_menu,draw_menu)
end

function _update()
	update_state()
end

function _draw()
	draw_state()
	draw_debug()
end
-->8
--initialize

function globals()
	shuffle_cards=shuffle
	draw=shuffle_cards(create_draw())
	deck=shuffle_cards(create_deck())
	discard={}
	hand={}
	scavenge={}
	trash={}
	acts=0
	surv=0
	atk=0
	turns=20
	horde=200
	current={card={},sel=1,cards=hand}
	message=nil
	is_player_turn=true
	played={}
	selector={frames={32,33},speed=4}
	debug={}
	win=nil
	previous={update=update_menu,draw=draw_menu}
	b={pressed=❎,start=0,action=nil}
	showncards_start=0
end

function create_draw()
	local _cards=
	{
		{
			cost=0,
			title="pistol",
			ctype="weapon",
			dmg=1,
			qty=3
		},
		{
			cost=0,
			title="lone wolf",
			ctype="survivor",
			val=1,
			qty=7
		}
	}
	
	return enumerate_cards(_cards)
end

function create_deck()
	local _cards=
	{
		{
			cost=3,
			title="uzi",
			ctype="weapon",
			dmg=5,
			qty=5
		},
		{
			cost=10,
			title="bazooka",
			ctype="weapon",
			dmg=25,
			qty=1
		},
		{
			cost=6,
			title="rifle",
			ctype="weapon",
			dmg=10,
			qty=4
		},
		{
			cost=5,
			title="shotgun",
			ctype="weapon",
			dmg=8,
			qty=5
		},
		{
			cost=3,
			title="couple",
			ctype="survivor",
			val=2,
			qty=5
		},
		{
			cost=5,
			title="trio",
			ctype="survivor",
			val=3,
			qty=4
		},
		{
			cost=8,
			title="party",
			ctype="survivor",
			val=5,
			qty=2
		},
		{
			cost=3,
			title="dumpster",
			ctype="action",
			desc="trash any cards from hand",
			actions=
			{
				{
					action=trash_action,
					val=0
				}
			},
			qty=3
		},
		{
			cost=4,
			title="reload",
			ctype="action",
			desc="draw 2 cards",
			actions=
			{
				{
					action=draw_action,
					val=2
				}
			},
			qty=5
		},
		{
			cost=12,
			title="mortars",
			ctype="action",
			desc="attack +30",
			actions=
			{
				{
					action=attack_action,
					val=30
				}
			},
			qty=3
		},
		{
			cost=4,
			title="caffeine",
			ctype="action",
			desc="action +2 and draw 1 card",
			actions=
			{
				{
					action=draw_action,
					val=2
				},
				{
					action=action_action,
					val=1
				}
			},
			qty=5
		},
	}
	
	return enumerate_cards(_cards)
end

function enumerate_cards(_cards)
	local _stack={}
	for _card in all(_cards) do
		for i=1,_card.qty do
			local _card=_card
			add(_stack,_card)
		end
	end
	
	return _stack
end

function init_scavenge()
 for i=1,7 do
 	refresh_scavenge()
 end
end

function init_player()
	acts=1
	atk=0
	surv=0
	hand={}
	current.card={}
	draw_cards(5)
	current.cards=hand
	is_player_turn=true
	showcards_start=0
end
-->8
--logic

function shuffle(objs)
	for i=#objs,2,-1 do
		local j=flr(rnd(i))+1
		objs[i],objs[j]=objs[j],objs[i]
	end
	return objs
end

function attack_horde()
	horde-=atk
end

function printc(_text,_y,_c)
	print(_text,(128-#_text/2*8)/2,_y,_c)
end

function win_check()
	if horde<=0 then
		sfx(5)
		win=true
		change_state(update_gameover,draw_gameover)
	elseif turns <=0 then
		sfx(4)
		win=false
		change_state(update_gameover,draw_gameover)
	end
end

function change_state(_update,_draw)
	previous={update=update_state,draw=draw_state}
	update_state=_update
	draw_state=_draw
end

function previous_state()
	local _p=previous
	change_state(_p.update,_p.draw)
end
-->8
--actions

function draw_action(_amount)
	draw_cards(_amount)
end

function trash_action(_amount)
	current.sel=1
	change_state(update_trash,draw_trash)
end

function action_action(_amount)
	acts+=_amount
end

function surv_action(_amount)
	surv+=_amount
end

function scavenge_action(_amount)
	scvng+=_amount
end

function attack_action(_amount)
	atk+=_amount
end

function trash_card()
	del(hand,hand[current.sel])
	if current.sel!=1 then
		previous_card()
	end
	previous_state()
end

function end_turn()
	attack_horde()
	change_state(update_turn,draw_turn)
	is_player_turn=false
	turns-=1
	win_check()
	if win==nil then sfx(2) end
end

-->8
--cards

function draw_cards(_amount)
	local _drawn_cards={}
	local _count=_amount
	local _remain=0
	if #draw < _amount then
		_count=#draw
		_remain=_amount-_count
	end
	for i=1,_count do
		local _card=draw[1]
		add(_drawn_cards,_card)
		del(draw,draw[1])
	end
	if _remain > 0 and #discard > 0 then
		draw=shuffle(discard)
		discard={}
		draw_cards(_remain)
	end
	add_cards(hand,_drawn_cards)
	current.sel=1
	current.card=hand[1]
end

function discard_hand()
	for c in all(hand) do
		add(discard,c)
	end
	hand={}
	for c in all(played) do
		add(discard,c)
	end
	played={}
end

function discard_card()
	add(discard,current.card)
	del(hand,hand[current.sel])
	current.card=current.cards[1]
end

function add_cards(_to,_cards)
	for _c in all(_cards) do
		add(_to,_c)
	end
end

function refresh_scavenge()
	add(scavenge,deck[1])
	del(deck,deck[1])
end

function play_card(_card)
	if _card.ctype == "survivor" then
		surv+=_card.val
		card_played(_card)
	elseif _card.ctype == "weapon" then
		atk+=_card.dmg
		card_played(_card)
	elseif acts>0 then
		acts-=1
		for _c in all(_card.actions) do
			_c.action(_c.val)
		end
		card_played(_card)
	end
end

function card_played(_card)
	sfx(7)
	deli(hand,current.sel)
	add(played,_card)
	change_current_card()
end

function scavenge_card(_card)
	if surv >= _card.cost then
		surv-=_card.cost
		add(discard,_card)
		del(scavenge,_card)
		refresh_scavenge()
		current.card=scavenge[current.sel]
		sfx(3)
	end
end

function next_card()
	card_selection(1)
end

function previous_card()
	card_selection(-1)
end

function card_selection(_dir)
	local _sel=current.sel
	_sel=((_sel+_dir-1)%#current.cards)+1
	current.card=current.cards[_sel]
	current.sel=_sel
	sfx(0)
end

function change_current_card()
	local _sel=current.sel
	if _sel>#current.cards then
		_sel=#current.cards
	end
	current.sel=_sel
	current.card=current.cards[_sel]
end

function card_icon(_card)
	if _card.ctype=="survivor" then
		return 3
	end
	if _card.ctype=="weapon" then
		return 4
	end
	if _card.ctype=="action" then
		return 5
	end
	return 6
end
-->8
--update

function update_game()
	if is_player_turn then
		game_btns()
		if current.card != nil then
			game_messages()
		end
	else
		discard_hand()
		init_player()
	end
end

function game_messages()
	if current.cards==hand then
		local _ctype=current.card.ctype
		message="❎ play ".._ctype.." card"
		if _ctype == "action" and acts<0 then
			message="need +actions to play"
		end
	elseif current.card.cost<=surv then
		message="❎ scavenge card"
	elseif current.card.cost>surv then
		message="need +survivors to scavenge card"
	else
		message="🅾️ attack zombies and end turn"
	end
end

function game_btns()
	if btnp(⬇️) then
		next_card()
	end
	if btnp(⬆️) then
		previous_card()
	end
	if btnp(➡️) and current.cards==hand then
		current.cards=scavenge
		current.sel=1
		showncards_start=0
		current.card=scavenge[1]
		sfx(1)
	end
	if btnp(⬅️) and current.cards==scavenge and #hand>0 then
		current.cards=hand
		current.sel=1
		showncards_start=0
		current.card=hand[1]
		sfx(1)
	end
	if btnp(❎) then
		if current.cards==hand then
			play_card(current.card)
		end
		if current.cards==scavenge then
			scavenge_card(current.card)
		end
	end
	if btnp(🅾️) then
		b={pressed=🅾️,start=time(),action=end_turn}
		sfx(6)
		change_state(update_btnhold,draw_state)
	end	
end

function update_menu()
	if btnp(⬆️) or btnp(⬇️) then
		current.sel=current.sel==1 and 2 or 1
		sfx(1)
	end
	if btnp(❎) then
		sfx(8)
		if current.sel==1 then
			change_state(update_turn,draw_turn)
		else
			change_state(update_tutorial,draw_tutorial)	
		end
	end
end

function update_turn()
	if btnp(❎) then
		change_state(update_game,draw_game)
		sfx(8)
	end
end

function update_trash()
	if #hand<=0 then
		change_state(update_game,draw_game)
		current.cards=scavenge
		current.sel=1
		current.card=scavenge[1]
	end
	if btnp(❎) then
		b={pressed=❎,start=time(),action=trash_card}
		sfx(6)
		change_state(update_btnhold,draw_state)
	end
	if btnp(🅾️) then
		sfx(8)
		change_state(update_game,draw_game)
	end
	if btnp(⬇️) then
		next_card()
	end
	if btnp(⬆️) then
		previous_card()
	end
end

function update_gameover()
	if btnp(❎) then
		_init()
	end
end

function update_btnhold()
	if btn(b.pressed) then
		if time()-b.start>=1 then
			b.action()
		end
	else
		sfx(-1)
		previous_state()
	end
end

function update_tutorial()
	if btnp(🅾️) then
		b={pressed=🅾️,start=time(),action=function() change_state(update_menu,draw_menu) end}
		sfx(6)
		change_state(update_btnhold,draw_tutorial)
	end
end

-->8
--draw

function draw_game()
	cls()
	draw_outlines()
	draw_stats()
	draw_hand()
	draw_scavenge()
	draw_horde()
	if current.card != nil then
		draw_card_desc()
		local _x=current.cards==hand and 0 or 62
		draw_selector(_x,22,8)
	end
	draw_message()
end

function draw_outlines()
	line(60,24,60,96,5)
	rect(0,96,127,104,5)
	
	line(8,106,120,106,6)
	line(0,114,0,127,6)
	line(127,114,127,127,6)
	rectfill(1,107,126,127,5)
	spr(16,0,106)
	spr(17,120,106)
end

function draw_stats()
	print("survivors:"..surv,2,98,6)
	print("attack:"..atk,52,98,6)
	print("actions:"..acts,91,98,6)
end

function draw_hand()
	print("▤"..#draw.."  ▤"..#discard,2,16,1)
	print("current hand:",2,24,13)
	if current.sel>showncards_start+7 then
		showncards_start=current.sel-7
	end
	if current.sel<showncards_start+1 then
		showncards_start=max(0,current.sel-1)
	end
	for i=1,min(7,#hand) do
		local _o=showncards_start+i
		local _card,_x=hand[_o],2
		if current.sel==_o and current.cards==hand then
			_x+=4
			print(_card.title,_x,i*8+24,12)
		else
			print(_card.title,_x,i*8+24,12)
		end
		pal(15,13)
		spr(card_icon(_card),#_card.title*4+_x,i*8+22)
	end
end

function draw_scavenge()
	print("scavenge for:",66,24,9)
	for i=1,#scavenge do
		local _card,_x=scavenge[i],66	
		if current.sel==i and current.cards==scavenge then	
			_x+=2
			print(_card.title,_x,i*8+24,10)
		else
			print(_card.title,_x,i*8+24,10)
		end
		pal(15,9)
		spr(card_icon(_card),#_card.title*4+_x,i*8+22)
		print(_card.cost,120,i*8+24,11)
	end
	pal()
end

function draw_horde()	
	--draw turns meter
	rectfill(2,10,112,12,8)
	rectfill(2,10,112/20*turns,12,6)
	--draw zombie
	palt(15)
	spr(6,111,1,2,2)
	palt()
end

function draw_card_desc()
	local _card=current.card
	local _col1=current.cards==hand and 13 or 9
	local _col2=current.cards==hand and 12 or 10
	print(_card.title,4,110,_col2)
	print(_card.ctype,4,116,_col1)
	if _card.dmg != nil then
		print("attack +".._card.dmg,4,122,_col1)
	end
	if _card.val != nil then
		print("survivors +".._card.val,4,122,_col1)
	end
	if _card.desc != nil then
		print(_card.desc,4,122,_col1)
	end
	print(_card.cost,118,110,11)
end

function draw_message()
	if message!=nil and is_player_turn then
		printc(message,2,7)
	end
	print("⬅️  ➡️",49,88,5)
end

function draw_gameover()
	draw_game()
	rectfill(26,33,96,66,0)
	if win then
		rect(25,32,97,67,11)
		print("congratulations",30,35,11)
		print("you have defeated",28,50,11)
		print("the zombie horde!",28,58,11)
	else
		rect(25,32,97,67,8)
		print("game over man!",34,35,8)
		print("the zombie horde",30,50,8)
		print("has overrun you!",30,58,8)
	end
end

function draw_debug()
	if debug[1] != nil then
		rect(19,59,101,#debug*8+71,11)
		rectfill(20,60,100,#debug*8+70,0)
		print("debug",22,62,3)
		for i=1,#debug do
			print(debug[i],22,i*6+62,11)
		end
	end
end

function draw_menu()
	cls()
	printc("horde",40,8)
	printc("a survival deckbuilding game",48,2)
	print("start",40,90,6)
	print("instructions",40,100,6)
	draw_selector(32,78,10)
	printc("code/art/audio by jeff adams",120,5)
end

function draw_turn()
	draw_game()
	rect(19,33,107,91,6)
	rectfill(20,34,106,90,0)
	printc(turns.." turns remaining",40,12)
	printc(horde.." zombies continue",58,8)
	printc("to stumble toward you",64,8)
	printc("❎ to continue",80,6)
end

function draw_trash()
	draw_game()
	message="hold ❎ trash card / 🅾️ finish"
end

function draw_selector(_x,_yoffset,_space)
 local _y=(current.sel-showncards_start)*_space+_yoffset
	local frame=((flr(time()*selector.speed)-1)%#selector.frames)+1
	spr(selector.frames[frame],_x,_y)
end

function draw_tutorial()
	cls()
	color(12)
	print("you start with a deck of 10",2,2)
	print("cards. each turn you draw",2,8)
	print("5 cards from your deck.",2,14)
 
 color(10)
	print("add new cards to your deck by",2,22)
	print("scavenging them with your",2,28)
	print("survivor cards.",2,34)
	pal(15,9)
	color(10)
	spr(3,2,40)
	print("= survivor card",13,42)
	spr(4,2,46)
	print("= weapon card",13,48)
	spr(5,2,52)
	print("= action card",13,54)
	
	color(8)
	print("the goal of the game is to",2,64)
	print("gain enough firepower to kill",2,70)
	print("the entire zombie horde before",2,76)
	print("your 20 turns run out.",2,82)
	
	color(6)
	print("messages about controls will",2,92)
	print("appear at the top of the screen.",2,98)
	print("some interactions will require",2,104)
	print("holding down the button.",2,110)
	
	printc("hold 🅾️ return to menu",120,5)
end
__gfx__
000000000008880000088800000000000000000000000000ffff00000000ffff0000000000000000000000000000000000000000000000000000000000000000
000000000008880000088800000000000000000000000000fff03333333322ff0000000000000000000000000000000000000000000000000000000000000000
00700700000088000000880000ffff0000f000000f000f00ff0333333333328f0000000000000000000000000000000000000000000000000000000000000000
00077000888888008888880000ffff0000ffffff0ff00ff0ff0333333333322f0000000000000000000000000000000000000000000000000000000000000000
00077000000088000000880000ffff000ffffff00fff0fffff0333333333332f0000000000000000000000000000000000000000000000000000000000000000
007007000000880000008800000ff0000ff0f0000ff00ff0ff0333333333330f0000000000000000000000000000000000000000000000000000000000000000
0000000000008080000080800ffffff00ff000000f000f00ff0633333663330f0000000000000000000000000000000000000000000000000000000000000000
000000000008800800088008000000000000000000000000ff0633333663330f0000000000000000000000000000000000000000000000000000000000000000
000666666666600000000000000000000000000000000000ff0330033333330f0000000000000000000000000000000000000000000000000000000000000000
066555555555566000000000000000000000000000000000fff03000333330ff0000000000000000000000000000000000000000000000000000000000000000
655555555555555600000000000000000000000000000000f0220888800000ff0000000000000000000000000000000000000000000000000000000000000000
65555555555555560000000000000000000000000000000003022228222222ff0000000000000000000000000000000000000000000000000000000000000000
655555555555555600000000000000000000000000000000f0000222222022ff0000000000000000000000000000000000000000000000000000000000000000
655555555555555600000000000000000000000000000000fffff011111002ff0000000000000000000000000000000000000000000000000000000000000000
655555555555555600000000000000000000000000000000fffff010f01003ff0000000000000000000000000000000000000000000000000000000000000000
655555555555555600000000000000000000000000000000ffffff00ff00f0ff0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67600000067600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67760000067760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66500000066500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65000000065000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000008880088088808880888088800000808008808880880088800000000000000000000000000000000000000000
00000000000000000000000000000000000000000080808088808080080080000000808080808080808080000000000000000000000000000000000000000000
00000000000000000000000000000000000000000800808080808800080088000000888080808800808088000000000000000000000000000000000000000000
00000000000000000000000000000000000000008000808080808080080080000000808080808080808080000000000000000000000000000000000000000000
00000000000000000000000000000000000000008880880080808880888088800000808088008080888088800000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000222000000220202022202020222020202220200000002200222002202020222020202220200022002220220002200000022022202220222000000000
00000000202000002000202020202020020020202020200000002020200020002020202020200200200020200200202020000000200020202220200000000000
00000000222000002220202022002020020020202220200000002020220020002200220020200200200020200200202020000000200022202020220000000000
00000000202000000020202020202220020022202020200000002020200020002020202020200200200020200200202020200000202020202020200000000000
00000000202000002200022020200200222002002020222000002220222002202020222002202220222022202220202022200000222020202020222000000000
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
00000000000000000000000000000000000000000000066666000000666006600000066066606660666066600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000660606600000060060600000600006006060606006000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000666066600000060060600000666006006660660006000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000660606600000060060600000006006006060606006000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066666000000060066000000660006006060606006000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000055005505500555000505550555055500000555050500000555055505550555000005550550055505550055000000000000000000000
00000000000000000000500050505050500005005050505005000000505050500000050050005000500000005050505050505550500000000000000000000000
00000000000000000000500050505050550005005550550005000000550055500000050055005500550000005550505055505050555000000000000000000000
00000000000000000000500050505050500005005050505005000000505000500000050050005000500000005050505050505050005000000000000000000000
00000000000000000000055055005550555050005050505005000000555055500000550055505000500000005050555050505050550000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00030000086100b6101a6200060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001c7301e730207302273000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c7500c750197502575000000097500575000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003171036710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000505005050050500005000050000500005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a000017050190501b0501d05020050200102005020010200502001020050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000c7200d7200e7200f72010720117201272013720147500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000012130101300d1301515017150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000165501655019550195501b5501b5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
