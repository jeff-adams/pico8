pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	globals()
	init_scavenge()
	init_player()
	update_state=update_game
	draw_state=draw_game
end

function _update()
	sec=flr(time())
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
	sec=flr(time())
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
			qty=10
		},
		{
			cost=10,
			title="bazooka",
			ctype="weapon",
			dmg=25,
			qty=2
		},
		{
			cost=6,
			title="rifle",
			ctype="weapon",
			dmg=10,
			qty=5
		},
		{
			cost=5,
			title="shotgun",
			ctype="weapon",
			dmg=8,
			qty=8
		},
		{
			cost=3,
			title="couple",
			ctype="survivor",
			val=2,
			qty=10
		},
		{
			cost=5,
			title="trio",
			ctype="survivor",
			val=3,
			qty=8
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
			qty=5
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
 for i=1,6 do
 	refresh_scavenge()
 end
end

function init_player()
	act=1
	draw_cards(5)
	current.card=hand[current.sel]
end
-->8
--tools

function shuffle(objs)
	for i=#objs,2,-1 do
		local j=flr(rnd(i))+1
		objs[i],objs[j]=objs[j],objs[i]
	end
	return objs
end
-->8
--actions

function draw_action(_amount)
	--draw an amount of cards to hand
	draw_cards(_amount)
end

function trash_action(_amount)
	--trash an amount of cards from hand	
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
end

function discard_card(_card)
	add(discard,_card)
	del(hand,_card)
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
	act-=1
	for _c in all(_card.actions) do
		_c.action(_c.val)
	end
end

function scavenge_card(_card)
	if surv >= _card.cost then
		surv-=_card.cost
		scvng-=1
		add(discard,_card)
		del(scavenge,_card)
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
	if btnp(⬇️) then
		next_card()
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
		draw_cards(5)
	end
	if btnp(🅾️) then
		if #hand > 0 then
			discard_card(hand[1])
		end
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
end

function draw_outlines()
	line(60,24,60,108,5)
	rect(0,108,127,128,5)
end

function draw_stats()
	print("survivors:"..surv,1,2,6)
	print("attack:"..atk,52,2,6)
	print("actions:"..act,92,2,6)
	for i=20,1,-1 do
		print("█",i*6-6,9,8)
	end
	for i=turns,1,-1 do
		print("█",i*6-6,9,6)
	end
	spr(1,120,8)
end

function draw_hand()
	print("current hand",2,24,1)
	for i=1,#hand do
		if current.cards==hand and i==current.sel then
			if sec%2==0 then
				print(">",2,i*8+24,13)
			else
				print(">",0,i*8+24,13)
			end
			print(hand[i].title,6,i*8+24,13)
		else
			print(hand[i].title,2,i*8+24,12)
		end
	end
end

function draw_scavenge()
	print("scavenge for...",66,24,9)
	for i=1,#scavenge do
		if current.cards==scavenge and i==current.sel then
			if sec%2==0 then
				print(">",64,i*8+24,15)
			else
				print(">",66,i*8+24,15)
			end
			print(scavenge[i].title,72,i*8+24,15)
		else
			print(scavenge[i].title,66,i*8+24,10)
		end
	end
end

function draw_horde()
	print("zombie horde:"..horde,58,15,8)
end

function draw_card_desc()
	local _card=current.card
	local _col1=current.cards==hand and 1 or 9
	local _col2=current.cards==hand and 12 or 10
	print(_card.title,2,110,_col2)
	print(_card.ctype,2,116,_col1)
	if _card.dmg != nil then
		print("attack:".._card.dmg,2,122,_col1)
	end
	if _card.val != nil then
		print("scavengers:".._card.val,2,122,_col1)
	end
	if _card.desc != nil then
		print(_card.desc,2,122,_col1)
	end
	print(_card.cost,119,110,11)
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
