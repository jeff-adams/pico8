pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	shuffle_cards=shuffle
	draw=shuffle_cards(create_draw())
	deck=shuffle_cards(create_deck())
	discard={}
	hand={}
end

function _update()

end

function _draw()
	cls()
	
end
-->8
--initialize

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
			act="trash",
			actd="trash any cards from hand",
			qty=5
		},
		{
			cost=4,
			title="reload",
			ctype="action",
			act="draw",
			actd="draw 2 cards",
			qty=5
		},
	}
	
	return enumerate_cards(_cards)
end

function enumerate_cards(_cards)
	local _deck={}
	
	for _card in all(_cards) do
		for i=1,_card.qty do
			add(_deck,_card)
		end
	end
	
	return _deck
end
-->8
--tools

function shuffle(objs)
	for i=#objs,2,-1 do
		local j=flr(rnd(i+1))
		objs[i],objs[j]=objs[j],objs[i]
	end
	return objs
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
