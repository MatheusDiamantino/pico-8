pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

 black=0  dark_blue=1  dark_purple=2 dark_green=3
 brown=4  dark_gray=5  light_gray=6  white=7
 red=8    orange=9     yellow=10     green=11
 blue=12  indigo=13    pink=14       peach=15

k_left=0
k_right=1
k_up=2
k_down=3

function _draw()
	cls()
	palt(7, true)
	palt(0, false)
	map(0, 0, 0, 0, 16, 16)
	player_draw()
	rectfill(0, 108, 128, 128, peach)
	
end

function _update60()
	player_update()
end

function _init()

end

player={}
player.x=64
player.y=64
player.speed=0.7
player.flip={x=false, y=false}
player.time=0
player.spr=0
player._spr=0

function player_update()
	
	if not btn(4) then
		if btn(k_up) then 
			player.y-=player.speed 
			player.spr=32 
			player.time+=0.1
			player.flip.x=false
		elseif btn(k_down) then 
			player.y+=player.speed 
			player.spr=0 
			player.time+=0.1
			player.flip.x=false
		elseif btn(k_left) then 
			player.x-=player.speed 
			player.spr=4 
			player.time+=0.1
			player.flip.x=false
		elseif btn(k_right) then 
			player.x+=player.speed 
			player.spr=4 
			player.flip.x=true 
			player.time+=0.1 
		end
		player._spr=player.spr+2*(flr(player.time)%2)
	else
		if player.spr==32 then
			player.spr=40
		elseif player.spr==0 then
			player.spr=36
		elseif player.spr==4 then
			player.spr=38
		end
		player._spr=player.spr
	end
	
end

function player_draw()
	spr(player._spr, player.x, player.y, 2, 2, player.flip.x)
end
__gfx__
77777000007777777777700000777777777777000007777777777777777777770000000000000000000000000000000000000000000000000000000000000000
77770bffbb07777777770bbffb077777777700bfbbb077777777700000077777009999999999990000000000000000000aaaaaaaaaaaaaa00aaaaaaaaaaaaaa0
77700b00bbb007777700bbb00b0077777770ff0bffbb077770700bffbbb007770099999999999900000000cccc0000000a999999999999a00a111111111111a0
770f00ffffb0f07770f0bffff00f07777700bff0bb0bb077700ff0bbffbbb077009999999999990000000ccfccc000000a999999999999a00a011111111110a0
770f0f0000f0f07770f0f0000f0f077770000bff00f0bb77700bff0bb0bbb07700999999999999000000ccfffccc00000a999999999999a00a001111111100a0
770f00000000f07770f00000000f07777777000b0bf0bb777700bff00f0bb07700999999999999000000cccf0ccc00000a999999999999a00a001111111100a0
770bb000000bb07770bb000000bb07777700f0f00ff0b077777000b0bf0b077700999999999999000000cc0000cc00000a999999999999a00a000111111000a0
7770ff0ff0ff0777770ff0ff0ff07777770ff0ff0ff00777700f0f00ff0b077700999999999999000000cc0000cc00000a999999999999a00a000000000000a0
7770bf0ff0fb0777770bf0ff0fb077777770bfff0fb0777770ff0ff0ff00777700aaaaaaaaaaaa00000f0cc00cc0f0000aaaaaaaaaaaaaa00aaaaaaaaaaaaaa0
770b0bffffb0b07770b0bffffb0b077777770bbb0b007777770bfff0fb0777770000000000000000000f00cccc00f00000000000000000000000000000000000
70fb00000000b07770b00000000bf0777777000000b0777777700000000777770044444444444400000cff0000ffc00008a000a00a000a8008a000a00a000a80
70f00bbbb0ffb07770bff0bbbb00f07777770b0ff0bb077777770ff0bb007777004444444444440000000cffffc0000008a000a00a000a8008a000a00a000a80
7700bffff0ff0777770ff0ffffb0077777770f0ff0bb077777770ff0bb0f07770044444444444400000fc000000cf00008a000aaaa000a8008a000aaaa000a80
7770000bbb00777777700bbb0000777777770b00000007777770000bb00f07770044444444444400000f00000000f00008a0000000000a8008a0000000000a80
7700bff00000077777000000ffb007777777000ffff07777770ffff000ff07770044444444444400000000000000000008aaaaaaaaaaaa8008aaaaaaaaaaaa80
77700000000077777770000000007777777000000000077777000000000007770000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777000007777777777777777777777700000007777777000000000000000000000000000000000000000000000000
777700000777777777777000007777777777700bfbb07777777770000007777770ff0ffff07777770e88888888888888888888888888888888888888888888e0
77770ffff077777777770ffff0777777777000bffb00077770700bfffbb000777000f0000f00777708e888008888800888880088888008888800888880088e80
7700f0000f0077777700f0000f007777770f0bbffbb0f077700ff0bbfffbbb0770f00bffb00f0777088e88888ee88888ee88888ee88888ee88888ee88888e880
70f00bffb00f077770f00bffb00f0777770f000b0000f077700bff0bb0bbbb0770f0bbffbb0f07770888eeeee88eeeee88eeeee88eeeee88eeeee88eeeee8880
70f0bbffbb0f077770f0bbffbb0f0777770f0ffffff0f0777700bff00f0bb07770b0bbfbbb0b07770888e00000000000000000000000000000000000000e8080
70f0b0bfbb0f077770f0bbfb0b0f0777700bb000000bb077770000b0bf0b07777700bbfb0b0077770808e0e8888888888888888888888888888888888e0e8080
70b00bbfbb0b077770b0bbfbb00b07770ff0fb0000bf0777700f0f00ff0b077777700bbfb00777770808e08e888888888ee8888ee8888ee888888888e80e8880
77000bbbb000777777000bbbb000777770f0bf0ff0fb077770ff0ff0ff007777770bb0bbb0b077770888e088e888888880088880088880088888888e8808e880
770b0bbb0b0b077770b0b0bbb0b0777777000bffffb07777770bfff0fb077777770bfb0bb0bb0777088e80888e8888888888888888888888888888e88808e880
70fb0bb0bb0b077770b0bb0bb0bf07777770b000000b07777000000000077777770bbfb000bff077088e8088886888ee8888ee8888ee8888ee888688880e8880
70f0b00bbfb00777700bfbb00b0f077777000bfbb0bb07770ff0bbb0bfb007777700bbffbb0ff0770888e08888868800888800888800888800886888880e8080
770bfffffbb07777770bbfffffb07777770bb0bff00007770ff0bb0ffbb0f07777700bbb000007770808e08888886888888888888888888888868888880e8080
7700bbbbb000777777000bbbbb0077777770000bb0ff07777000000bbb00f07777770000ff0777770808e088888886eeeeeeeeeeeeeeeeeeee688888880e8880
770000000ff00777700ff000000077777777770000ff07777770fff0000ff07777777000ff0077770888e08888e08e66666666666666666666e80e88880e8880
777000000000777777000000000777777777777000007777770000000000007777777770000077770888e08888e08e6eeeeeeeeeeeeeeeeee6e80e888808e880
00000000000000008888888888888888000000000000000000000000000000000000000000000000088e808888888e6eeeeeeeeeeeeeeeeee6e888888808e880
00000bbffbb000008eeeeeeeeeeeeee804a9999000aaaa000000090000900000000cc00000880880088e808e08888e6eeeeeeeeeeeeeeeeee6e88880e80e8880
00ff0bbffbb0ff008e022222200000e804a999900a9999a0000098000089000000c00d00008eee800888e08e08888e6eeeeeeeeeeeeeeeeee6e88880e80e8880
00b00bbbbbb00b008e02222220eee0e804a999900a9999a0000980888808900000c0dd000008e8000888e08888888e6eeeeeeeeeeeeeeeeee6e88888880e8080
0000bb0000bb00008e00000000eee0e804a999900a9999a0009808888880890000c0dd00000080000808e08888e08e6eeeeeeeeeeeeeeeeee6e80e88880e8080
000000ffff0000008e00000000eee0e804aaaaa009aaaa90098088088088089000c00d00000000000808e08888e08e6eeeeeeeeeeeeeeeeee6e80e88880e8880
000b0ff00ff0b0008e00008880eee0e804444440009999000000880880880000000dd000000000000888e08888888e6eeeeeeeeeeeeeeeeee6e888888808e880
0f0b0bb00bb0b0f08e00008880eee0e8000000000000000000008888888800000000000000000000088e808e08888e6eeeeeeeeeeeeeeeeee6e88880e808e880
0b0b00bffb00b0b08e00008880eee0e8002000000090090000008888888800000000000000000000088e808e08888e6eeeeeeeeeeeeeeeeee6e88880e80e8880
000bbb0000bbb0008e00008880eee0e80202200000911900000008888880000000000400000000000888e08888888e6eeeeeeeeeeeeeeeeee6e88888880e8080
0f0bbbbbbbbbb0f08e02208880eee0e802022000091990900980008888000890000044000000cc000808e08888e08e6eeeeeeeeeeeeeeeeee6e80e88880e8080
0ff0bbbffbbb0ff08e02208880eee0e80020000009100090009800000000890000099400000c0c000808e08888e08e6eeeeeeeeeeeeeeeeee6e80e88880e8880
000b00bbbb00b0008e02208880eee0e80002000000900900000980000008900000094000000ccd000888e08888888e6eeeeeeeeeeeeeeeeee6e88888880e8880
000fb000000bf0008e000000000000e80002000000090000000098000089000000049000000000000888e08e08888e6eeeeeeeeeeeeeeeeee6e88880e808e880
00fbbb00000bbf008eeeeeeeeeeeeee80002000000090000000009000090000000000000000ddd00088e808e08888e6eeeeeeeeeeeeeeeeee6e88880e808e880
00000000000000008888888888888888000022000009990000000000000000000000000000000000088e808888888e6eeeeeeeeeeeeeeeeee6e88888880e8880
00000000000000000000000000000000000000000000000011ccccc111dccc11bbb00bbbbbb00bbb0888e08888e08e6eeeeeeeeeeeeeeeeee6e80e88880e8880
0000000000000000011111111111111000aaa9a009999900c1dccc11111dd11c33000033330000330888e08888e08e66666666666666666666e80e88880e8080
0066ddddddddd0000166ddd00dddd6100aa88800a0888990c11dd111cc1111dc30000003300000030808e088888886eeeeeeeeeeeeeeeeeeee688888880e8080
00dd6ddddddd000001dd6ddddddd61100a8880a0aa088890c1111111dcc111dc00000000000000000808e08888886888888888888888888888868888880e8880
00dddcccccc0000001ddd666666611100a880aaa8aa0889011111cc11dcc111d00000000000000000888e088888688008888008888008888008868888808e880
00dddcddddc0000001ddd600006111100a880aa888a088901111cccc1dccc1110000000000000000088e8088886888ee8888ee8888ee8888ee8886888808e880
00dddcdccdc0000001dd0600006011100a880aa088a08890c11cc1cc11dcc1cc0000000000000000088e80888e8888888888888888888888888888e8880e8880
00dddcdccdc0000001d006d00d6001100aa880a00a088990cc1cccccc1dcc1cc00000000000000000888e088e888888880088880088880088888888e880e8080
00dddcddddc000000160d6d00d610d100aaaa9a999999990c11cccccc1dc1ccc00000000000000000808e08e888888888ee8888ee8888ee888888888e80e8080
00dddcccccc00000016dd66666611d1004aa9a9a99999940cc1dcc1cd11d1ccc00000000000000000808e0e8888888888888888888888888888888888e0e8880
00dd00000006000001dd6111111611100a444444444444901d11dccd11111dcc00000000000000000888e00000000000000000000000000000000000000e8880
00d000000000600001d61110011161100aaaaa9a99999990cd111dd111ccc1dc00000000000000000888eeeee88eeeee88eeeee88eeeee88eeeee88eeeee8880
0000000000000600016111100111161004aaa0a9a9099940d11c11111cccc11d0000000000000000088e88888ee88888ee88888ee88888ee88888ee88888e880
00000000000006000161111dd1111610004aaa0a90999400111ccc11cc11cc11000000000000000008e888008888800888880088888008888800888880088e80
00000000000000000111111111111110090444444444409011ccccc1cccccc1133000033330000330e88888888888888888888888888888888888888888888e0
00000000000000000000000000000000000000000000000011cc1cc111cc1c11bbb00bbbbbb00bbb000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000e6e88888880888800888808888888e6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0000000000000000000000000000000000000000000000000000000000000000e6e88888880888088088808888888e6ee666666666666666666666666666666e
0000000000000000000000000000000000000000000000000000000000000000e6e88880e80880888808808e08888e6ee6eeeeeeeeeeeeeeeeeeeeeeeeeeee6e
0000000000000000000000000000000000000000000000000000000000000000e6e88880e80808888880808e08888e6ee6e08888888888888888888888880e6e
0000000000000000000000000000000000000000000000000000000000000000e6e88888880088888888008888888e6ee6e80888800888888888800888808e6e
0000000000000000000000000000000000000000000000000000000000000000e6e80e88880000000000008888e08e6ee6e880888ee8888888888ee888088e6e
0000000000000000000000000000000000000000000000000000000000000000e6e80e88808888888888880888e08e6ee6e88808888888888888888880888e6e
0000000000000000000000000000000000000000000000000000000000000000e6e888880888ee8888ee888088888e6ee6e88880888800888800888808888e6e
0000000000000000000000000000000000000000000000000000000000000000e6e88880888800888800888808888e6ee6e888880888ee8888ee888088888e6e
0000000000000000000000000000000000000000000000000000000000000000e6e88808888888888888888880888e6ee6e80e88808888888888880888e08e6e
0000000000000000000000000000000000000000000000000000000000000000e6e880888ee8888888888ee888088e6ee6e80e88880000000000008888e08e6e
0000000000000000000000000000000000000000000000000000000000000000e6e80888800888888888800888808e6ee6e88888880088888888008888888e6e
0000000000000000000000000000000000000000000000000000000000000000e6e08888888888888888888888880e6ee6e88880e80808888880808e08888e6e
0000000000000000000000000000000000000000000000000000000000000000e6eeeeeeeeeeeeeeeeeeeeeeeeeeee6ee6e88880e80880888808808e08888e6e
0000000000000000000000000000000000000000000000000000000000000000e666666666666666666666666666666ee6e88888880888088088808888888e6e
0000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6e88888880888800888808888888e6e
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8c8d6c6d6c6d6c6d6c6d6c6d6c6d8e8f6c6d6c6d6c6d6c6d6c6d6c6d6c6d8e8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9c9d7c7d7c7d7c7d7c7d7c7d7c7d9e9f7c7d7c7d7c7d7c7d7c7d7c7d7c7d9e9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f6667666766676667666766674a4b66676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f7677767776777677767776775a5b76777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f6667666766676667666766674a4b66676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f7677767776777677767776775a5b76777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f6667666766676667666766674a4b66676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f7677767776777677767776775a5b76777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f6667666766676667666766674a4b66676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f7677767776777677767776775a5b76777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f6667666766676667666766674a4b66676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f7677767776777677767776775a5b76777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f6667666766676667666766674a4b66676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f7677767776777677767776775a5b76777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88892c2d2c2d2c2d2c2d2c2d2c2d8a8b66676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
98993c3d3c3d3c3d3c3d3c3d3c3d9a9b2c2d7677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
98993c3d3c3d3c3d3c3d3c3d3c3d9a9b3c3d6667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f767776777677767776777677767776777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f666766676667666766676667666766676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f767776777677767776777677767776777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f666766676667666766676667666766676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f767776777677767776777677767776777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f666766676667666766676667666766676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f767776777677767776777677767776777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f666766676667666766676667666766676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f767776777677767776777677767776777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f666766676667666766676667666766676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f767776777677767776777677767776777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4f666766676667666766676667666766676667666766676667666766674a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5f767776777677767776777677767776777677767776777677767776775a5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88892c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d8a8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
98993c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d9a9b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

