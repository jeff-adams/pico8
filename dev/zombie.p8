pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--horde
--by jeff adams

--…………work items………………

--◆juices
--animate card movement

--◆fixes
--background music

--◆extras
--way to refresh scavenge
--hard mode with events
--add more action cards

function _init()
	music(0)
	globals()
	timers()
	init_player()
	init_scavenge()	
	change_state(update_menu,draw_menu)
end

function _update()
	update_state()
end

function _draw()
	if fading>0 then 
		fadeout() 
	else
		draw_state()
		draw_debug()
	end
end
-->8
--initialize

function globals()
	shuffle_cards=shuffle
	turns=20
	horde=200
	messages=nil
	messi=1
	selector={frames={32,33},speed=4}
	debug={}
	previous={update=update_menu,draw=draw_menu}
	b={pressed=❎,start=0,action=nil}
	cardicons={survivor=3,weapon=4,action=5}
	numbers={}
	drips={}
	puddles={{x=26,size=0},{x=46,size=0},{x=66,size=0},{x=80,size=0},{x=96,size=0}}
end

function timers()
	discarding=0
	fading=0
	messaging=0
	turning=0
	animessage=0
	trashing=0
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
			desc="+30 attack",
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
			desc="+1 action and draw 1 card",
			actions=
			{
				{
					action=draw_action,
					val=1
				},
				{
					action=action_action,
					val=1
				}
			},
			qty=5
		},
		{
			cost=5,
			title="2nd wind",
			ctype="action",
			desc="+2 actions and +2 survivors",
			actions=
			{
				{
					action=surv_action,
					val=2
				},
				{
					action=action_action,
					val=2
				}
			},
			qty=4
		}
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
 scavenge={}
 deck=shuffle_cards(create_deck())
 for i=1,7 do
 	refresh_scavenge()
 end
end

function init_player()
	discard={}
	hand={}
	played={}
	current={card={},sel=1,cards=hand}
	draw=shuffle_cards(create_draw())
	reset_player()
	win=nil
end

function reset_player()
	draw_cards(5)
	acts=1
	atk=0
	surv=0
	is_player_turn=true
	showncards_start=0
	current.cards=hand
end
-->8
--utilities

function shuffle(objs)
	for i=#objs,2,-1 do
		local j=flr(rnd(i))+1
		objs[i],objs[j]=objs[j],objs[i]
	end
	return objs
end

function printc(_text,_y,_c,_oc)
	local _x=(127-#_text/2*8)/2
	if _oc then
		printo(_text,_x,_y,_c,_oc)
	else
		print(_text,_x,_y,_c)
	end
end

function printo(_text,_x,_y,_c,_oc)
	print(_text,_x+1,_y-1,_oc)
	print(_text,_x+1,_y,_oc)
	print(_text,_x+1,_y+1,_oc)
	print(_text,_x,_y+1,_oc)
	print(_text,_x-1,_y+1,_oc)
	print(_text,_x-1,_y,_oc)
	print(_text,_x-1,_y-1,_oc)
	print(_text,_x,_y-1,_oc)
	print(_text,_x,_y,_c)
end

--function by dw817 on bbs
function fadeout()
local _fadespeed=4
local _fade,_c,_p={[0]=0,17,18,19,20,16,22,6,24,25,9,27,28,29,29,31,0,0,16,17,16,16,5,0,2,4,0,3,1,18,2,4}
  fading+=1
  if fading%_fadespeed==1 then
    for i=0,15 do
      _c=peek(24336+i)
      if (_c>=128) _c-=112
      _p=_fade[_c]
      if (_p>=16) _p+=112
      pal(i,_p,1)
    end
    if fading==7*_fadespeed+1 then
      cls()
      pal()
      fading=0
    end
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
	selector.frames={34,35}
	change_state(update_trash,draw_trash)
end

function action_action(_amount)
	acts+=_amount
	add(numbers,{t="+".._amount,x=121,y=94,c=2,oc=0,life=30})
end

function surv_action(_amount)
	surv+=_amount
	add(numbers,{t="+".._amount,x=38,y=98,c=11,oc=0,life=30})
end

function scavenge_action(_amount)
	scvng+=_amount
end

function attack_action(_amount)
	atk+=_amount
	add(numbers,{t="+".._amount,x=76,y=98,c=8,oc=0,life=30})
end

function trash_card()
	deli(hand,current.sel)
	if current.sel!=1 then
		previous_card()
	else
		current.card=hand[current.sel]
	end
	previous_state()
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

function end_turn()
	atking=0
	change_state(update_turn,draw_turn)
	freeze=time()+2.5
	change_state(update_freeze,draw_turn)
	is_player_turn=false
	turns-=1
	if win==nil then sfx(2) end
end

function attack_horde()
	horde-=atk
	add(numbers,{t="-"..atk,x=28,y=56,c=6,oc=0,life=45})
	sfx(9)
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
	if _card.ctype=="survivor" then
		surv+=_card.val
		add(numbers,{t="+".._card.val,x=38,y=98,c=11,oc=0,life=30})
		card_played(_card)
	elseif _card.ctype=="weapon" then
		atk+=_card.dmg
		add(numbers,{t="+".._card.dmg,x=76,y=98,c=8,oc=0,life=30})
		card_played(_card)
	elseif acts>0 then
		acts-=1
		add(numbers,{t="-1",x=121,y=94,c=2,oc=0,life=30})
		card_played(_card)
		for _c in all(_card.actions) do
			_c.action(_c.val)
		end
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
		discarding=time()+.5
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
	sfx(1)
end

function change_current_card()
	local _sel=current.sel
	if _sel>#current.cards then
		_sel=#current.cards
	end
	if _sel<=0 then
		freeze=time()+0.75
		change_state(update_freeze,draw_game)
		current.cards=scavenge
		_sel=1
	end
	current.sel=_sel
	current.card=current.cards[_sel]
end

function cards_contain(_cards,_ctype)
	local _result=false
	for _c in all(_cards) do
		if _c.ctype==_ctype then
			_result=true
		end
	end
	return _result
end

function cheapest_card()
	local _lowest_price=100
	for _c in all(scavenge) do
		_lowest_price=_c.cost<=_lowest_price and _c.cost or _lowest_price
	end
	return _lowest_price
end
-->8
--update

function update_game()
	if is_player_turn then
		turning+=1
		game_btns()
		if current.card != nil then
			game_messages()
		end
	else
		discard_hand()
		reset_player()
		turning=0
	end
end

function game_messages()
	if current.cards==hand then
		local _ctype=current.card.ctype
		messages={"❎ play ".._ctype.." card"}
		if _ctype == "action" and acts<0 then
			messages={"+actions to play card"}
		end
	elseif current.card.cost<=surv then
		messages={"❎ scavenge card"}
	elseif current.card.cost>surv then
		messages={"+survivors to scavenge card"}
	end
	if turning>=600 then
		add(messages,"🅾️ attack horde and end turn")
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
		showncards_start=0
		current.card=scavenge[1]
		sfx(10)
	end
	if btnp(⬅️) and current.cards==scavenge and #hand>0 then
		current.cards=hand
		current.sel=1
		showncards_start=0
		current.card=hand[1]
		sfx(10)
	end
	if btnp(❎) then
		if current.cards==hand then
			play_card(current.card)
		elseif current.cards==scavenge then
			scavenge_card(current.card)
		end
	end
	if btnp(🅾️) then
		--prompt if player has actions
		if cards_contain(hand,"action") and acts>0 then
			cmessage="you still have actions"
			current.sel=1
			change_state(update_confirm,draw_confirm)
		elseif cards_contain(hand,"survivor") or cards_contain(hand,"attack") then
			cmessage="you still have cards"
			current.sel=1
			change_state(update_confirm,draw_confirm)
		elseif surv>=cheapest_card() then
			cmessage="you still can scavenge"
			current.sel=1
			change_state(update_confirm,draw_confirm)
		else
			end_turn()
		end
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
			fadeout()
			change_state(update_game,draw_game)
		else
			fadeout()
			change_state(update_tutorial,draw_tutorial)	
		end
	end
end

function update_turn()
	if btnp(❎) then
		sfx(8)
		messi=1	
		change_state(update_game,draw_game)
		win_check()
	end
end

function update_trash()
	if #hand<=0 then
		change_state(update_game,draw_game)
		current.cards=scavenge
		current.sel=1
		selector.frames={32,33}
		current.card=scavenge[1]
	end
	if btnp(❎) then
		b={pressed=❎,start=time(),action=trash_card}
		sfx(6)
		change_state(update_btnhold,draw_state)
	end
	if btnp(🅾️) then
		sfx(8)
		selector.frames={32,33}
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
		fadeout()
		globals()
		init_player()
		init_scavenge()
		change_state(update_menu,draw_menu)
	end
end

function update_btnhold()
	if btn(b.pressed) then
		trashing+=1
		if time()-b.start>=1 then
			b.action()
			trashing=0
		end
	else
		sfx(-1)
		trashing=0
		previous_state()
	end
end

function update_tutorial()
	if btnp(🅾️) then
		sfx(8)
		fadeout()
		change_state(update_menu,draw_menu)
	end
end

function update_freeze()
	if freeze<time() then
		previous_state()
	end
end

function update_confirm()
	if btnp(⬆️) or btnp(⬇️) then
		current.sel=current.sel==1 and 2 or 1
		sfx(1)
	end
	if btnp(❎) then
		sfx(8)
		if current.sel==1 then
			previous_state()
		else
			end_turn()
		end
	end
end

-->8
--draw

function draw_game()
	cls()
	draw_outlines()
	draw_stats()
	draw_hand()
	draw_pile()
	draw_scavenge()
	draw_horde()
	draw_turnmeter()
	if current.card != nil then
		draw_card_desc()
		local _x=current.cards==hand and 0 or 62
		draw_selector(_x,22,8,showncards_start)
	end
	draw_message()
	draw_numbers()
end

function draw_outlines()
	--hand/scavenge divider to box
	line(60,24,60,96,5)
	rect(0,96,127,104,5)
	--top of card for description
	line(8,106,120,106,6)
	line(0,114,0,127,6)
	line(127,114,127,127,6)
	rectfill(1,107,126,127,5)
	spr(16,0,106)
	spr(17,120,106)
	--nav buttons
	print("⬅️  ➡️",49,88,5)
end

function draw_stats()
	print("survivors:",2,98,6)
	print(surv,42,98,11)
	print("attack:",52,98,6)
	print(atk,80,98,8)
	print("actions:"..acts,91,98,6)
	print(acts,123,98,2)
end

function draw_hand()
	print("current hand:",2,24,13)
	if current.sel>showncards_start+7 then
		showncards_start=current.sel-7
	end
	if (#hand-7)<showncards_start then
		showncards_start=max(0,showncards_start-1)
	end
	if current.sel<showncards_start+1 then
		showncards_start=max(0,current.sel-1)
	end
	local _limit=mid(0,#hand-showncards_start,7)
	for i=1,_limit do
		local _o=showncards_start+i
		local _card,_x=hand[_o],2
		if current.sel==_o and current.cards==hand then
			_x+=6-trashing
			clip(_x+trashing,i*8+24,60,6)
			print(_card.title,_x,i*8+24,12)
			clip()	
		else
			print(_card.title,_x,i*8+24,12)	
		end
		pal(15,13)
		spr(cardicons[_card.ctype],#_card.title*4+_x,i*8+22)
	end
	--scroll bar
	if #hand>7 then
		local _x,_y,_w,_h=56,32,1,52
		local _ch=_h/#hand
		rectfill(_x,_y,_x+_w,_y+_h,1)
		rectfill(_x,_y+showncards_start*_ch,_x+_w,_y+showncards_start*_ch+7*_ch,13)
	end
end

function draw_pile()
	local _c=1
	if discarding>time() then
		local _xoff=flr(#discard/10)>0 and 4 or 0
		rectfill(19,15,31+_xoff,21,9)
		_c=10
	end
	print("▤"..#draw,2,16,1)
	print("▤"..#discard,20,16,_c)
end

function draw_scavenge()
	print("scavenge for:",66,24,9)
	for i=1,#scavenge do
		local _card,_x=scavenge[i],66	
		if current.sel==i and current.cards==scavenge then	
			_x+=4
			print(_card.title,_x,i*8+24,10)
		else
			print(_card.title,_x,i*8+24,10)
		end
		pal(15,9)
		spr(cardicons[_card.ctype],#_card.title*4+_x,i*8+22)
		print(_card.cost,120,i*8+24,11)
	end
	pal()
end

function draw_horde()	
	--draw horde count
	printo(horde,112,17,8,0)
	--draw zombie
	draw_zombie()
end

function draw_zombie()
	palt(0,false)
	palt(11,true)
	local _s=flr(time()/1.1)%2==0 and 6 or 8
	spr(_s,111,1,2,2)
	palt()
end

function draw_player()
	palt(11,true)
	palt(0,false)
	--player
	spr(38,2,1,2,2,true)
	--gun
	spr(36,2,6,2,2)
	palt()
end

function draw_turnmeter()
	local _xs,_xe=10,112
	local _w=_xe-_xs
	rectfill(_xs-1,9,_xe+1,13,5)
	rectfill(_xs,10,_xe,12,8)
	rectfill(_xs,10,_w/20*turns+_xs,12,6)
	local _tx=turns<10 and 4 or 0
	print(turns,_tx,9,5)
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
	if messages!=nil and is_player_turn then
		messaging+=1
		local _nextmess=messages[messi]
		--alternate messages
		if messaging>60 then
			messi+=1
			messi=(messi-1)%#messages+1
			lastmess=_nextmess
			_nextmess=messages[messi]
			messaging=0
			animessage=0
		end
		if #messages>1 and animessage<3*30 then
			--animate message change
			animate_messages(_nextmess)
		else
			--only one message
			print(_nextmess,1,2,7)
		end
	end
end

function draw_gameover()
	draw_game()
	rectfill(26,33,96,78,0)
	if win then
		rect(25,32,97,79,11)
		print("congratulations",32,35,11)
		print("you have defeated",28,50,11)
		print("the zombie horde!",28,58,11)
		print("❎ main menu",37,70,5)
	else
		rect(25,32,97,79,8)
		print("game over man!",34,35,8)
		print("the zombie horde",30,50,8)
		print("has overrun you!",30,58,8)
		print("❎ main menu",37,70,5)	
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
	cls(5)
	--background
	rectfill(0,0,128,82,13)
	for i=0,30 do
		local _y=82+i*0.25*i
		line(0,_y,128,_y,0)
	end
	rectfill(1,1,126,37,5)
	rectfill(3,3,124,35,6)
	rectfill(4,4,123,34,0)
	--image
	palt(0,false)
	palt(11,true)
	sspr(48,0,16,16,86,50,32,32)
	sspr(48,16,16,16,6,50,32,32,true,false)
	sspr(32,16,16,16,6,60,32,32)
	--title
	for i=0,4 do
		spr(64+2*i,23+16*i,8,2,2)
	end
	printc("a survival deckbuilding game",28,2,0)
	pal()
	--menu
	rectfill(27,84,96,110,6)
	rectfill(28,85,95,109,0)
	print("start",40,90,6)
	print("instructions",40,100,6)
	draw_selector(32,78,10)
	printc("code/art/audio by jeff adams",121,0,5)
	--dripping blood
	local _bspawn={26,46,66,80,96}
	if flr(time()*10)%10==0 then
		local _d={x=_bspawn[flr(rnd(5)+1)],y=23}
		add(drips,_d)
	end
	draw_drips()
	draw_puddles()
end

function draw_drips()
	for d in all(drips) do
		pset(d.x,d.y,8)
		d.y+=1
		if d.y>=34 then
			for p in all(puddles) do
				if p.x==d.x then
					p.size+=1
				end
			end
			del(drips,d)
		end
	end
end

function draw_puddles()
	clip(4,33,120,35)
	for p in all(puddles) do
		if p.size>0 then
			line(p.x-p.size,34,p.x+p.size,34,8)
		end	
	end
end

function draw_turn()
	draw_game()
	atking=atking and atking or 0
	
	if atking>=0 then
		atking+=1
		local _h=atking*2
		rectfill(0,64-_h-1,128,64+_h+1,6)
		clip(0,64-_h,128,_h*2+1)
		atking=_h>64 and -1 or atking
	end
		
	rectfill(0,0,128,128,0)
	printc(turns.." turns remaining",40,12)
	printc(horde.." zombies continue",58,8)
	printc("to stumble toward you",64,8)
	if atk<1 or atking<-30 then 
		printc("❎ to continue",80,6) 
	end
	draw_zombie()
	draw_player()
	draw_numbers()
	
	if atking<0 then
		--attack animation
		if atk>0 then
			if atking*-1<=atk then
				--gunfire
					sfx(11)
			end
			--bullet
			local _bx,_by=min(16-atking*6,118),12
			clip(0,0,118,20)
			line(_bx,_by,_bx+3,_by,7)
			clip()
			if atking==-30 then
				attack_horde()
			end
			atking-=1
		else
			change_state(update_turn,draw_turn)
		end
	end
end

function draw_trash()
	draw_game()
	messages={"hold ❎ trash card","🅾️ to finish trashing"}
end

function draw_selector(_x,_yoffset,_space,_shown_start)
	if not _shown_start then
		_shown_start=0
	end
 local _y=(current.sel-_shown_start)*_space+_yoffset
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
	print("some interactions may require",2,104)
	print("holding down the button.",2,110)
	
	printc("🅾️ return to menu",120,5)
end

function draw_popup(_h,_c,_oc)
	rectfill(9,64-_h/2-1,117,64+_h/2+1,_oc)
	rectfill(10,64-_h/2,116,64+_h/2,_c)	
end

function draw_confirm()	
	draw_popup(40,0,9)
	printc(cmessage,50,9)
	print("return",42,62,5)
	print("confirm end turn",42,70,5)
	draw_selector(34,52,8)
end

function draw_numbers()
	for _k,_v in pairs(numbers) do
		printo(_v.t,_v.x,_v.y,_v.c,_v.oc)
		_v.y-=0.5
		_v.life-=1
		if _v.life<=0 then
			deli(numbers,_k)
		end
	end
end
-->8
--animations

function animate_messages(_nmess)
	clip(0,0,120,8)
	local _y=animessage/3
	local _lmess=lastmess and lastmess or " "
	print(_lmess,1,2-_y,7)
	print(_nmess,1,max(2,2-_y+7),7)
	clip()
	animessage+=1
end
__gfx__
000000000008880000088800000000000000000000000000bbbbb0000000bbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
000000000008880000088800000000000000000000000000bbbb0333333322bbbbbbb0000000bbbb000000000000000000000000000000000000000000000000
00700700000088000000880000ffff0000f000000f000f00bbb033333333228bbbbb0333333322bb000000000000000000000000000000000000000000000000
00077000888888008888880000ffff0000ffffff0ff00ff0bbb033333333322bbbb033333333228b000000000000000000000000000000000000000000000000
00077000000088000000880000ffff000ffffff00fff0fffbbb033333333322bbbb033333333322b000000000000000000000000000000000000000000000000
007007000000880000008800000ff0000ff0f0000ff00ff0bbb033333333330bbbb033333333322b000000000000000000000000000000000000000000000000
0000000000008080000080800ffffff00ff000000f000f00bbb063333663330bbbb033333333330b000000000000000000000000000000000000000000000000
000000000008800800088008000000000000000000000000bbb063333663330bbbb063333663330b000000000000000000000000000000000000000000000000
000666666666600000000007000000000000000000000000bbb033003333330bbbb063333663330b000000000000000000000000000000000000000000000000
066555555555566000070077000000000000000000000000bbbb0300333330bbbbb033333333330b000000000000000000000000000000000000000000000000
655555555555555600770770000000000000000000000000b00000880000040bb00003003333300b000000000000000000000000000000000000000000000000
655555555555555607777700000000000000000000000000b033444844444330b033448800000330000000000000000000000000000000000000000000000000
655555555555555677077000000000000000000000000000b000004444444030b000004444444030000000000000000000000000000000000000000000000000
655555555555555670070000000000000000000000000000bbbbbbb011111000bbbbbbb011111000000000000000000000000000000000000000000000000000
655555555555555600000000000000000000000000000000bbbbbbb010b010bbbbbbbbb010b010bb000000000000000000000000000000000000000000000000
655555555555555600000000000000000000000000000000bbbbbbbb00bb00bbbbbbbbbb00bb00bb000000000000000000000000000000000000000000000000
00000000000000000000000000066600bbbbbbbbbbbbbbbbbbbb0000000000bb0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006600000bbbbbbbbbbbbbbbbbb0044444444440b0000000000000000000000000000000000000000000000000000000000000000
66000000066000006666666066666600bbbbbbbbbbbbbbbbbb444444444444400000000000000000000000000000000000000000000000000000000000000000
67600000067600000656560006565600bbbbbbbbbbbbbbbbbbb0ffffffff44400000000000000000000000000000000000000000000000000000000000000000
67760000067760000656560006565600bbbbbbbbbbbbbbbbbbb0fffffffff4400000000000000000000000000000000000000000000000000000000000000000
66500000066500000656560006565600bbbbbbbbbbbbbbbbbbb0ffffffffff000000000000000000000000000000000000000000000000000000000000000000
65000000065000000656560006565600bbb566666666666bbbb00ffff00ffff00000000000000000000000000000000000000000000000000000000000000000
000000000000000006666600066666004b45544444bbbbbbbbb00ffff00ffff00000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000004bbb5bbbbbbbbbbbbbb0ffffffffff0b0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbb0ffffffff0bb0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbb00000000c0b0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbb0cccccccccc00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbb0f0ccccc00c00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbb000011110f0b0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb010b010bb0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbb00bb00bb0000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
bb8888bbbb888bbbbbb8888888888bbbbb8888888888bbbbbb888888888bbbbbbb88888888888bbb000000000000000000000000000000000000000000000000
b8ee888bb88888bbbbee8888888888bbb8ee888888888bbbb8ee88888888bbbbb8ee8888888888bb000000000000000000000000000000000000000000000000
b8e8888bb88888bbb8e888888888888bb8e88888888888bbb8e8888888888bbbb8e8888888888bbb000000000000000000000000000000000000000000000000
b888888bb88888bbb8888888bbb8888bb888888bbb8888bbb888888bb88888bbb888888bbbbbbbbb000000000000000000000000000000000000000000000000
b888888bb88888bbb8888888bbb8888bb888888bbb8888bbb888888bbb8888bbb888888bbbbbbbbb000000000000000000000000000000000000000000000000
b8888888888888bbb8888888bbb8888bb8888888888888bbb888888bbb8888bbb888888888888bbb000000000000000000000000000000000000000000000000
b8888888888888bbb8888888bbb8888bb888888888888bbbb888888bbb8888bbb8888888888888bb000000000000000000000000000000000000000000000000
b8888888888888bbb8888888bbb8888bb88888888888bbbbb888888bbb8888bbb888888888888bbb000000000000000000000000000000000000000000000000
b888888bb88888bbb8888888bbb8888bb888888888888bbbb888888bbb8888bbb888888bbbbbbbbb000000000000000000000000000000000000000000000000
b888888bb88888bbb8888888bbb8888bb8888888888888bbb888888bbb8888bbb888888bbbbbbbbb000000000000000000000000000000000000000000000000
b888888bb88888bbb88888888888888bb888888b888888bbb888888bb88888bbb888888888888bbb000000000000000000000000000000000000000000000000
b888888bb88888bbb88888888888888bb888888bb88888bbb8888888888888bbb8888888888888bb000000000000000000000000000000000000000000000000
b888888bb88888bbbb888888888888bbb888888bbb8888bbb888888888888bbbb8888888888888bb000000000000000000000000000000000000000000000000
bb8888bbbb888bbbbbb8888888888bbbbb8888bbbbb88bbbbb8888888888bbbbbb88888888888bbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d
d555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d
d556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000888800008880000008888888888000008888888888000000888888888000000088888888888000000000000000000000000655d
d556000000000000000000008ee88800888880000ee88888888880008ee88888888800008ee88888888000008ee888888888800000000000000000000000655d
d556000000000000000000008e888800888880008e888888888888008e888888888880008e888888888800008e8888888888000000000000000000000000655d
d556000000000000000000008888880088888000888888800088880088888800088880008888880088888000888888000000000000000000000000000000655d
d556000000000000000000008888880088888000888888800088880088888800088880008888880008888000888888000000000000000000000000000000655d
d556000000000000000000008888888888888000888888800088880088888888888880008888880008888000888888888888000000000000000000000000655d
d556000000000000000000008888888888888000888888800088880088888888888800008888880008888000888888888888800000000000000000000000655d
d556000000000000000000008888888888888000888888800088880088888888888000008888880008888000888888888888000000000000000000000000655d
d556000000000000000000008888880088888000888888800088880088888888888800008888880008888000888888000000000000000000000000000000655d
d556000000000000000000008888880088888000888888800088880088888888888880008888880008888000888888000000000000000000000000000000655d
d556000000000000000000008888880088888000888888888888880088888808888880008888880088888000888888888888000000000000000000000000655d
d556000000000000000000008888880088888000888888888888880088888800888880008888888888888000888888888888800000000000000000000000655d
d556000000000000000000008888880088888000088888888888800088888800088880008888888888880000888888888888800000000000000000000000655d
d556000000000000000000000888800008880000008888888888000008888000008800000888888888800000088888888888000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000222000000220202022202020222020202220200000002200222002202020222020202220200022002220220002200000022022202220222000000655d
d556000202000002000202020202020020020202020200000002020200020002028202020200200200020200200202020000000200020202220200000000655d
d556000222000002220202022002020020020202220200800002020220020002200220020200200200020200200202020000000200022202020220000000655d
d556000202000000020202020202220020022202020200800002020200020002020202020200200200020200200202020200000202020202020200000000655d
d556000202000002200022020280200222002002020222000002220222002202020222002202220222022202220202022200000222020202020222000000655d
d556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655d
d556000000000000000008888888888800000000000088888000000000000000888880000000000888000000888888888888888880000000000000000000655d
d556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666655d
d555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d
d555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddd00000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000dddddddddddddddddd
dddddddddd00000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000dddddddddddddddddd
dddddddd00444444444444444444440000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00333333333333332222dddddddddddddd
dddddddd00444444444444444444440000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00333333333333332222dddddddddddddd
dddddd0044444444444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333222288dddddddddddd
dddddd0044444444444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333222288dddddddddddd
dddddd00444444ffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333332222dddddddddddd
dddddd00444444ffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333332222dddddddddddd
dddddd004444ffffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333332222dddddddddddd
dddddd004444ffffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333332222dddddddddddd
dddddd0000ffffffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333333300dddddddddddd
dddddd0000ffffffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333333333333333333300dddddddddddd
dddddd00ffffffff0000ffffffff0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd006633333333666633333300dddddddddddd
dddddd00ffffffff0000ffffffff0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd006633333333666633333300dddddddddddd
dddddd00ffffffff0000ffffffff0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd006633333333666633333300dddddddddddd
dddddd00ffffffff0000ffffffff0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd006633333333666633333300dddddddddddd
dddddddd00ffffffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333000033333333333300dddddddddddd
dddddddd00ffffffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd003333000033333333333300dddddddddddd
dddddddddd00ffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00330000333333333300dddddddddddddd
dddddddddd00ffffffffffffffff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00330000333333333300dddddddddddddd
dddddddd00cc0000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000888800000000004400dddddddddddd
dddddddd00cc0000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000888800000000004400dddddddddddd
dddddd00cccc556666666666666666666666dddddddddddddddddddddddddddddddddddddddddddddddddddd003333444444884444444444333300dddddddddd
dddddd00cccc556666666666666666666666dddddddddddddddddddddddddddddddddddddddddddddddddddd003333444444884444444444333300dddddddddd
dddddd44cc4455554444444444ff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000000000044444444444444003300dddddddddd
dddddd44cc4455554444444444ff00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000000000044444444444444003300dddddddddd
dddddd4400ff005511111100000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd001111111111000000dddddddddd
dddddd4400ff005511111100000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd001111111111000000dddddddddd
dddddddddd001100dd001100dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd001100dd001100dddddddddddddd
dddddddddd001100dd001100dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd001100dd001100dddddddddddddd
dddddddddd0000dddd0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddd0000dddddddddddddd
dddddddddd0000dddd0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddd0000dddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000066666666666666666666666666666666666666666666666666666666666666666666660000000000000000000000000000000
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
00000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
00000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555560000660000000660666066606660666000000000000000000000000000000000000065555555555555555555555555555555
00000000000000000000000000060000676000006000060060606060060000000000000000000000000000000000000060000000000000000000000000000000
55555555555555555555555555560000677600006660060066606600060000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555560000665000000060060060606060060000000000000000000000000000000000000065555555555555555555555555555555
00000000000000000000000000060000650000006600060060606060060000000000000000000000000000000000000060000000000000000000000000000000
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
00000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555560000000000006660660006606660666060600660666066600660660006600000000065555555555555555555555555555555
55555555555555555555555555560000000000000600606060000600606060606000060006006060606060000000000065555555555555555555555555555555
00000000000000000000000000060000000000000600606066600600660060606000060006006060606066600000000060000000000000000000000000000000
55555555555555555555555555560000000000000600606000600600606060606000060006006060606000600000000065555555555555555555555555555555
55555555555555555555555555560000000000006660606066000600606006600660060066606600606066000000000065555555555555555555555555555555
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
00000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000065555555555555555555555555555555
55555555555555555555555555566666666666666666666666666666666666666666666666666666666666666666666665555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555005500500550005550500050005000555050005050500550005500555550005050555550005000500050005555500050055000500055005555555555
55555550555050505050555505505050505505550550505050505055055050555550505050555555055055505550555555505050505050500050555555555555
55555550555050505050055505500050055505550550005050505055055050555550055000555555055005500550055555500050505000505050005555555555
00000050555050505050555505505050505505550550505050505055055050500050505550500055055055505550550000505050505050505055505000000000
55555555005005500050005055505050505505505550505500500050005005555550005000555550055000505550555555505050005050505050055555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

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
000300002d6102d6102d6102a6103f6203f6203f62000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00020000257302273025730287301e700207002270000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100003965039650226402263022620226102261022610226102261022610226102261022610226100060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100001103007010270102a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001800200101301012195030361500010195030d5030361500015000150c0140d200000100d200036150361500010000131950303615000100d503195030361500010000130c0140d200000100d2000361503615
011800200701407014070140701407014070140a0140a014130041b0141b0131b01316013110130f0130a0130701407014070140701407014070140a0140a014050001100011000070001000010000070000e000
011800001540402404004040a104071041b0121d012180121b012061050a1050a1050a105071051b012180121601213012071040a1040a1040a104071041301216012180121b012071050a1050a105014050d405
00180000050140a0140c014050140a0140c014050140a0140c0141b0041b0031b003160030c0130c0130a0130a01407014070140501405014030140301400014000100301005013070130a0130c0130c0130c010
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800200071400715000100201000714007150001002010007140071500010020100071400715000100201000714007150001002010007140071500010020100071400715000100201000714007150001002010
011800201b0121d012180121b0121b1141d115181141b1151b0121801216012130121b1141811516114131151301216012180121b0121311416115181141b11516000180001b000071050a1050a105014050d405
011800000472004700047200470004723047200472007710047200470004720047000472304720047200771004720047000472004700047230472004720077100472004700047200470004723047200472007710
011800000272002700027200270002723027200272005710027200270002720027000272302720027200571002720027000272002700027230272002720057100272002700027200270002723027200272005710
__music__
00 2a695644
01 2b695644
01 2a2c6a44
02 2b566b44

