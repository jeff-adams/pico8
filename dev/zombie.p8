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
	can_scavenge=true
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
		surv-= _card.cost
		add(discard,_card)
		del(scavenge,_card)
		can_scavange=false
	end
end
-->8
--update

function update_game()
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
	print("draw: "..#draw,80,1,10)
	print("discard: "..#discard,80,8,10)
	print("deck: "..#deck,80,24,9)
	print("▤scavenge▤",80,32,5)
	for i=1,#scavenge do
		print(scavenge[i].title,80,i*8+32,5)
	end
	print("▤▤player▤▤",1,1,12)
	print("attack: "..atk,1,8,1)
	print("survivors: "..surv,1,16,1)
	for i=1,#hand do
		print(hand[i].title,1,i*8+16,14)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
