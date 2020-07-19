pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--zombie horde
--by jeff adams

--todo
<<<<<<< HEAD
--improve ui
--balance scavenge
=======
--bug: too many cards in hand
--card graphic
>>>>>>> baac4ffebb8d9034931e5242d6e1951365b9e3c9
--menu
--balance cards
--sfx/music
--graphics for card types
--animate ui

function _init()
	globals()
	init_scavenge()
	init_player()
	update_state=update_menu
	draw_state=draw_menu
end

function _update()
	time_is_even=flr(time())%2==0
	sec=flr(time()*10)
	update_state()
end

function _draw()
	draw_state()
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
	scvng=1
	turns=20
	horde=200
	current={card={},sel=1,cards=hand}
	sec=flr(time()*10)
	message=nil
	time_is_even=flr(time())%2==0
	is_player_turn=true
	actioned={}
	debug={}
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
			cost=4,
			title="weakest link",
			ctype="action",
			desc="trash any cards from hand",
			actions=
			{
				{
					action=trash_action,
					val=0
				}
			},
			qty=0
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
			desc="attack+30",
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
			cost=3,
			title="caffeine",
			ctype="action",
			desc="action+2, draw 1 card",
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
-->8
--actions

function draw_action(_amount)
	draw_cards(_amount)
end

function trash_action(_amount)
	--trash an amount of cards from hand	
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
		update_player(_card)
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
	for c in all(actioned) do
		add(discard,c)
	end
	actioned={}
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
	del(hand,hand[current.sel])
	acts-=1
	for _c in all(_card.actions) do
		_c.action(_c.val)
	end
	add(actioned,_card)
end

function scavenge_card(_card)
	if surv >= _card.cost then
		surv-=_card.cost
		scvng-=1
		add(discard,_card)
		del(scavenge,_card)
		refresh_scavenge()
		current.card=scavenge[current.sel]
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
end
-->8
--update

function update_game()
	if is_player_turn then
		game_btns()
		game_messages()
	else
		win_check()
		discard_hand()
		init_player()
		turns-=1
	end
end

function update_player(_card)
	if _card.ctype == "survivor" then
		surv+=_card.val
	end
	if _card.ctype == "weapon" then
		atk+=_card.dmg
	end
end

function game_messages()
	if current.cards==hand then
		message="🅾️ to attack the zombie horde"
		if time_is_even then
			message="❎ to play an action card"
		end
	else
		message="❎ to scavenge card"
	end
end

function game_btns()
	if btnp(⬇️) then
		next_card()
		debug={}
	end
	if btnp(⬆️) then
		previous_card()
	end
	if btnp(➡️) and current.cards==hand then
		current.cards=scavenge
		current.sel=1
		current.card=scavenge[1]
	end
	if btnp(⬅️) and current.cards==scavenge then
		current.cards=hand
		current.sel=1
		current.card=hand[1]
	end
	if btnp(❎) then
		if current.card.ctype == "action"
		and current.cards==hand 
		and acts>0 then
			play_card(current.card)
			current.card=current.cards[1]
		end
		if current.cards==scavenge then
			scavenge_card(current.card)
		end
	end
	if btnp(🅾️) then
		attack_horde()
		is_player_turn=false
	end
end

function win_check()
	if horde<=0 or turns <=0 then
		draw_state=game_over_draw
	end
end

function update_menu()
	if btnp(❎) then
		update_state=update_game
		draw_state=draw_game
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
	draw_card_desc()
	draw_message()
	
	draw_debug()
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
	for i=1,#hand do
		if current.cards==hand and i==current.sel then
			if sec%5==0 then
				print(">",2,i*8+24,6)
			else
				print(">",0,i*8+24,6)
			end
			print(hand[i].title,6,i*8+24,6)
		else
			print(hand[i].title,2,i*8+24,12)
		end
	end
end

function draw_scavenge()
	print("scavenge for:"..#deck,66,24,9)
	for i=1,#scavenge do
		if current.cards==scavenge and i==current.sel then
			if sec%5==0 then
				print(">",64,i*8+24,15)
			else
				print(">",66,i*8+24,15)
			end
			print(scavenge[i].title,72,i*8+24,15)
		else
			print(scavenge[i].title,66,i*8+24,10)
		end
		print(scavenge[i].cost,120,i*8+24,11)
	end
end

function draw_horde()
	for i=20,1,-1 do
		print("█",i*6-6,9,8)
	end
	for i=turns,1,-1 do
		print("█",i*6-6,9,6)
	end
	spr(1,120,8)
	print("zombie horde:"..horde,58,15,8)
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
	if message!=nil then
		local _x=(128-(#message/2*8))/2
		print(message,_x,2,7)
	end
	print("⬅️  ➡️",49,88,5)
end

function game_over_draw()
	draw_game()
	rectfill(26,33,96,66,0)
	if horde<=199 then
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
	printc("zombie horde",40,8)
	printc("a survival deckbuilding game",48,2)
	printc("❎ to start",110,6)
	printc("code/art/audio by jeff adams",120,5)
end
__gfx__
00000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06655555555556600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
