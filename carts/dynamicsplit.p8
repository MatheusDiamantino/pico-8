pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- dynamic split screen
-- matheus mortatti

local p2,p1={x=512,y=256},{x=544,y=288}

function _update()
	if btn(0,0) then p1.x-=2 end
	if btn(1,0) then p1.x+=2 end
	if btn(2,0) then p1.y-=2 end
	if btn(3,0) then p1.y+=2 end

	if btn(0,1) then p2.x-=2 end
	if btn(1,1) then p2.x+=2 end
	if btn(2,1) then p2.y-=2 end
	if btn(3,1) then p2.y+=2 end
end


function _draw()
	cls()

	render(p1,p2)
end


--[[
	render two players in split screen mode
--]]
function render(player1, player2)
	if player1.x>=player2.x then player1,player2=player2,player1 end

	-- get angle between the two players and turn it 90 degrees
	local a = atan2(player1.x-player2.x,player1.y-player2.y) - 0.25

	-- wrap angle from 0 to 1
	if a<0 then a=1+a end

	-- if the two players are less than 64 pixels apart, draw them in a single screen
	if abs(player1.x-player2.x) <= abs(64*cos(a-0.25)) and abs(player1.y-player2.y) <= abs(64*sin(a-0.25)) then
		render_scene((player1.x+player2.x)/2-60, (player1.y+player2.y)/2-60)

	-- else, draw them separately
	else

		-- get two points to define the line on the screen
		local x1,y1=64+cos(a)*90,64+sin(a)*90
		local x2,y2=64-cos(a)*90,64-sin(a)*90

		-- get middle point between them
		local xm,ym=(x1+x2)/2,(y1+y2)/2

		-- define equation in the form of c = a*(x-xm) + b*(y-ym)
		local _a=y2-y1
		local _b=x1-x2
		local _c=_a*(x1-xm)+_b*(y1-ym)

		-- calculate an offset to make players be 32 units away from the line
		-- (used to offset the camera position properly)
		local offx,offy=32*cos(a-0.25),32*sin(a-0.25)

		-- render player 1's scene
		render_scene(player1.x-60+offx,player1.y-60+offy)

		local x3,y3,x4,y4

		--[[
			-------------------------------
			-- if the line is horizontal --
			-------------------------------
		--]]
		if (a>0.125 and a<=0.375) then
			-- calculate the points on the edge of the screen
			x3,y3=flr((_c+_b*ym+_a*xm)/_a),0
			x4,y4=128-x3,127

			local off,x,d

			-- copy to user space the proper half of player 1 screen
			off=0
			x=x3
			d=(x3-x4)/(y3-y4)
			for y=0,127 do
				off=screenline_to_usermem(x,y,off)
				x+=d
			end

			-- render player 2's scene
			render_scene(player2.x-60-offx,player2.y-60-offy)

			-- copy back player 1's scene back from user space
			off=0
			x=x3
			d=(x3-x4)/(y3-y4)
			for y=0,127 do
				off=usermem_to_screenline(x,y,off)
				x+=d
			end

		--[[
			-------------------------------
			-- if the line is horizontal --
			-------------------------------
		--]]
		else
			-- calculate the points on the edges of the screen
			x3,y3=0,flr((_c+_b*ym+_a*xm)/_b)
			x4,y4=128,127-y3

			-- make sure that (x3,y3) is on top of (x4,y4)
			-- since (0,0) is on the top-left, (x3,y3) is on top
			-- when y3 is smaller than y4
			if y3>y4 then x3,x4=x4,x3 y3,y4=y4,y3 end

			local off,x,d

			off=0
			d=(y3-y4==0) and 0 or (x3-x4)/(y3-y4)


			-- copy to user space the proper half of player 1 screen

			-- render portion of screen that is not
			-- part of the slope.
			x=player1.y<player2.y and 128 or 0
			for y=0,y3-1 do
				off=screenline_to_usermem(x,y,off)
			end
			x=player1.y<player2.y and 0 or 128
			for y=y4,127 do
				off=screenline_to_usermem(x,y,off)
			end

			-- render slope portion
			x=x3
			for y=y3,y4-1 do
				off=screenline_to_usermem(x,y,off)
				x+=d
			end

			render_scene(player2.x-60-offx,player2.y-60-offy)

			-- copy back player 1's scene back from user space

			off=0
			d= (y3-y4==0) and 0 or (x3-x4)/(y3-y4)

			x=player1.y<player2.y and 128 or 0
			for y=0,y3-1 do
				off=usermem_to_screenline(x,y,off)
			end
			x=player1.y<player2.y and 0 or 128
			for y=y4,127 do
				off=usermem_to_screenline(x,y,off)
			end

			x=x3
			for y=y3,y4-1 do
				off=usermem_to_screenline(x,y,off)
				x+=d
			end
		end

		-- draw center line
		camera()
		line(x1,y1,x2,y2,1)
	end
end

--[[
	render you scene using x,y as camera positions
--]]
function render_scene(x,y)
	camera(x,y)
	map(0,0,0,0,128,64)
	rectfill(p1.x,p1.y,p1.x+8,p1.y+8, 7)
	rectfill(p2.x,p2.y,p2.x+8,p2.y+8, 8)
end

--[[
	copy from user memory to screen memory

	xt = end of the line to be copied
	line = line number to be copied
	off = offset from user memory to start copying from
--]]
function usermem_to_screenline(xt,line,off)
	xt=flr(xt)
	local x2=flr(xt/2)
	local new_off=off

	-- copy an even portion of memory
	memcpy(0x6000 + 64*line, 0x4300 + off, x2)
	new_off+=x2

	-- since pico-8 stores 2 colors per byte,
	-- if we want to copy a single leftover pixel
	-- we have to copy the whole byte from the screen,
	-- get the same byte on user memory and finally
	-- apply a mask and combine each other

	-- ps: if we have 0b 1101 0110 as out byte,
	-- 1101 is the right pixel and 0110 is the left pixel
	if xt%2==1 then
		local ppair = peek(0x6000 + 64*line + x2)
		local p=peek(0x4300 + off + x2)

		ppair=band(ppair,0xf0)
		p=band(p,0x0f)

		poke(0x6000 + 64*line + x2,bor(p,ppair))
		new_off+=1
	end

	return new_off
end

--[[
	copy from screen memory to user memory

	xt = end of the line to be copied
	line = line number to be copied
	off = offset from user memory to start copying to
--]]
function screenline_to_usermem(xt,line,off)
	xt=flr(xt)
	local x2=flr(xt/2)
	local new_off=off

	-- copy an even portion of memory
	memcpy(0x4300 + off,0x6000 + 64*line, x2)
	new_off+=x2

	-- if we have a leftover pixel, copy the whole byte
	-- to user memory
	if xt%2==1 then
		local p=peek(0x6000 + 64*line + x2)
		poke(0x4300 + off + x2,p)
		new_off+=1
	end

	return new_off
end

__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22444422bbbbbbb22bbbbbbbbb5555bbbbbbbbbbbb5555bb
bbb00bbbbbb00bbbbbb000bbbbb000bbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbbbbbbbbbbbbbbb24244222bbbbb22e222bbbbbb57d7d5bbbb22bbbb57d7d5b
bb0440bbbb0440bbbb04440bbb04440bbb0440bbbb0440bbbb0440bbbb0440bbbbbbbbbbbbbbbbbb42442224bbb2277e24422bbb57000065bb2722bb57000065
bb0ff0bbbb0420bbbb024f0bbb024f0bb00ff0bbbb0ff00bb00420bbbb04200bbbb2222222221bbb44222244b2277e782424421b5d0000d1117e22115d0000d1
b0df950bb002200bb0d09f0bb0d09f0b0fdf950bb0df95f00fd2250bb0d225f0bb27eeeeeeee21bb42222424b27e78782422241b57111161d77e242d57111161
0fdd55f00fdd55f0b0fd550bb0fd550bb0dd5f0bb0fd550bb0dd5f0bb0fd550bb27e78888882221b22244244b2e8e8e82424241b15d655107e78244215d65510
b040040bb040040bbb04020bbb0040bbbb0400bbbb0040bbbb0400bbbb0040bb27e722222222212122424442b27888e82424241bb15511077ee824422155110b
bb0bb0bbbb0bb0bbbb00b00bbbb000bbbbb0bbbbbbbb0bbbbbb0bbbbbbbb0bbb277888888888821122242422b278e8e82424241bb11100177ee824242111001b
bb000bbbbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbb000bbb2782222222222821bbbbbbbbb278e8822222241bb1701517eee8242421d0151b
b04420bbb04420bbbb000bbbbb000bbbbb000bbbbb000bbbb04ff0bbb04ff0bb2888872288888881b3bbbbbbb2e882299222221bb1d01617e8e824242170161b
b042f00bb042f00bb0a940b0b0a9400bb04440bbb04440bbb0000000b000000021117e8211111111bbbbbbbbb2822ff77ff2221bb170151788e8242421d0151b
0d09f0400d09f040b094f007b094f07bb024f000b024f000b0245550b0245550b49411111420021bbbbbb3bbb21ff777777ff11bb1d01617e88e22242170161b
0fd554040fd554040d09f0400d09f40b0d09f0700d09f0700f4000000f400000b44490142220011bbbbbbbbbbb2f72277227f1bbb1111117e8e112222111111b
b0224200b02242000fd5540b0fd520bb0fd5570b0fd5570b000550bb000550bbb49490142422221bbbbbbbbbbb29724f900f91bbb57d7d57ee122122257d7d5b
0224440b0224440bb04020bbb0040bbbb04020bbb00400bbb04020bbbb040bbbb22290141111111bb3333b3bbb29724f999991bb570000651111111157000065
0214040b22004040b00b0bbbbb000bbbb00b0bbbbb000bbbb00b00bbbb000bbbbbbb2222bbbbbbbb32223333bb114224111111bb5d0000d17d7d7d7d5d0000d1
08200bbb08200bbbb070bbbbb070bbbbbb0e0bbbbb0e0bbbbbbbbbbbbbbbbbbbb222222bbbbbbbb3242444423bbbbbbbbbbbbbbb571111610000000057111161
b066d0bbb066d0bbb07000bbb07000bbb08000bbb08000bbbb000b0bbb000b0b15444451bbbbbbb3222242223abbbb3bbbbbbbbb15d655101111111115d65510
b065000bb065000bb070440bb070440bbb066d0bbb066d0bb0444040b044404016999961b3bbbb33423232323bbbbbbbbbbbbbbbb1551107565656565155110b
0706d0400706d040b0602f0bb0602f0bb0065000b0065000b024f002b024f00216944961bbbbb3322211222243bbbbbbbbbbbbbbb51100166dd77d555111001b
0dd004040dd0040404449f0b04449f0b0d506d070d506d070d0990020d09900215466451bbbbb3324343434343bbbbbb24442221b567d517d671051d516dd11b
b066d600b066d600b0f0dd0bb0f0dd0b0d5055700d5055700fd550020fd550021116d000bbbbbb324444444443abbbbb29994441b57d5d1665710d15517d151b
0224dd0b0224dd0bbb04020bbb0040bbb0060d0bb000600bb0402040b004004015221151bbb3bb323232323443abbbbb24222221b5d6d51555d1051111d6d11b
0214040b22004040bb00000bbbb000bbbb00b0bbbbb000bbb00b0b0bbb000b0b15211151bbbbbbb3222221123abb3bbb29444441bb1111bbb111111bbb1111bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222222b24444442334444332ab44ab222222221bbbb33bbb7bb7bbbbb7bbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbb0000bbbbbbbbbbbbbbbb1699996124b4b4b2ab3333abab33b31124444441bb33aa1bbb373bbbb7f7bb3b
bbbbb00bbbbbb00bbbbb02bbbbbb02bbb000e44eb000e44ebbb00000bbb000001546645142323232bbaabbbbb3123b3322222221b3a33b31bbb3bbebb373bbbb
bb000770bb000770b0b082bbb0b082bb044404200444042000b04a4200b04a42150650512b1b2b2bbbbbbbbb3ab3b311000000003abb3331bbbbbeaebb3bbcbb
b0776990b07769900200490b0200490b044404200444042009000940090009401000000143434343b3bbbbbb41313ab1122222203b313111bb7bbbebbbbbcacb
b0776990b0776990044420bb044420bb0422200b0422200bb0a9400bb0a9400011100000b4b4b4b4bbbbbbbba3b3bb332421124113130310b7f7bb3bb7bbbcbb
b076600bb076600bb04220bbb04220bb04ee442b04ee442bb094924b094492401522115132323234bbbbbb3b3313133124200241b1103103b373bbbbbb3bb3bb
b09090bb0920290bbb090bbbb09040bb0400402b0240042bb090924bb00009241521115122222112bbbbbbbb2121111211100111bb333333bb3bbbbbbbbbbbbb
ccccccccc76cc7cccccccc67ccccccccbbbbbbbbbbbbbbb555bbbb5555bbbbbbb31f95bbbbbbbbbbb31f93bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1bbbbbbbbb
cccccccc6cccd5655555dccccc6ccc7cb3b3bb3bb3bbbb57ab3b55abb15bbb3b331f933b33333333b31f93bbbbbbb3333333bbbbb3bbbb100bb0b16003bbbbbb
ccccccccccddf35fffff955555c76cc6bb3bbbbbbbbbb5ab13357b313bb1bbbb341f954311111111b31f93bbbb3b311111133bbbbbb0017650170765503033bb
ccccccccc5ff33333333399ff5ccc5ccbbbbbbbbbbb55b3b311a3313b1311bbb301f9503fffffff9b31ff3bbb3b31ffffff333bbbb065065107650551006033b
ccccccccc5f33b3b333333333355590cbbbb3b3bbb5ab51331b131b3b13131bbf022220f9f99f999b31f93bbbb319f999f9f33bbb10551011105510110075033
cccccccccc53b3bbb3333b33333ff90dbbbbb3bbb573b111b31311113313110b0244440033333333b31f93bbb31ff93339ff93bb306011001060110000751103
cccccccc6c533bbb3bbbb3bbb333ff0db3bbbbbb5ab3bb31313113b131b11310d022220dbbbbbbbbb31ff3bbb31f933b319f93bb305000030050003300550033
cccccccccdf33bbbbb3bbbbb3b333f0dbbbbbbbb5b31331111b3111111331110c244440cbbbbbbbbb31f93bbb31f93bbb31f93bbb00033bb3000333b330033bb
ccccccccc5f333bbbbbbbbbbbb33395dbbbbbbbb5ab31b31b1311b31b1311310c0222207bbbbbbbbb31f93bbb31f93bb331ff3bbbbbbbbbbbbbbbbbbbbbbbbbb
ccccc6cc659333bbbbbbbbbbbb3390dcbb3bbbbb5b31b3313111b311311131105244440c33333333331f93b3b31f9333331f93bbbbb3bb11b3b1bb3bbbb0b0bb
cc76cccc75933b3bbbbbbbbbb3b3f0d6bbbbbbbbb1b3331313b311311bb31110f02222051111111111ff93bbb31fff1111ff93bbbbbbb1750b170bbbb317050b
ccccccccc5f333bbbbbbbbbbbb33f0d7bbbbbbbbbb1b3b313111b313b131310b3244440fffffffffff9ff3bbbb33fffffff93bbbb3bb1765107510bb3176500b
ccccc7ccc5f33b3bbbbbbbbbb33330dcbbbbbb3bbb513313b13131b3b13110bb302222039f99f999999f93bbbbb339f99f93bbbbbbb106511665010b3165510b
ccccccccc75f33bbbbbbbbbbbb333f5dbbbbbbbbb5abb331331311113313110b34000043339f9933319f93b3bbbb3333333bbbbbbb1760151010500b17151103
c7ccccccc6df33bbbbbbbbbb3b333f0db3bbbbbb57b3333131b11b3131b1110b30199103b31ff3bbb31ff3bbbbbbbbbbbbbbbbbbb17755050175050b31707503
cccccccccdf33bbbbbbbbbbbbb333f0dbbbbbbbb5a313113113311111133110b3319933bb31f93bbb31f93bbbbbbbbbbbbbbbbbb177555101761011017650103
ccccccccc5f333bbbbbbbbbbb3b3f0dcbbbbbbbb5bb33b31b1311b31b131100bbbbb3bbbb31f93bbb31f93bbb31f93bbbbbbbbbb165070101507605016651003
cc55cccc65ff3b3bbbbb3b3b3b3390d6bbbbb3bb51bbb1313111bb313111110bb94bb94b331f9333b31f933b11ff933bbbb00bbb050751065070651031101650
c550ccccc54ff333b3b33333339990dcbb3bb3bbb41b33111bb311111310101b2441244111f99911b31f9f11fff99f11bb0760bbb006507607610003b3170510
75006ccccc00f3333333333339000dccbbbbbbbbb3113313113133101110043bb22bb22bffffffffb31fffff999fffffb1065103bb0007657651103331765010
c776cccc6ccd0ffff333399ff900dcc6bbbbbbbbbbb311010000110000013bbb242124219f99f999b31f999933ff999930601103bbbb3001555510333165510b
ccccc50cc7ccd0000fff90000090dc7cb3bbbbbbb3bb0000411200004112bbbbb42bb42b33333333b31f9933b31f993330500033bbbb07500111033b17151103
ccc75506cccccdddd0055dddd000dc6cb3bbbb3bbbbb4123bbb14123bbbbbb3bbbbbbbbbbbbbbbbbb31ff33bb31ff33bb00033bbb3bbb00b300033bb31707503
cccc776cccc6cc6ccddddccccdddc6ccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbb3b31f93bbb31f93bbbbbbbbbbbbbbbbbbb3333bbb17650103
b3bbbbbbbbbbbbbbbb33ff0fc5f3bbbbbbbbbbbbbb5555bbb33020202020203bbbb21bbbbbbbbbbbbbbbbbbbbbbbbbbbb31f93bbbbb33bbb1511015016651003
bbb33bbbbbb3bbbbbbb3f90c5f33bbbbb244442bb57b315b3332222222222033bbbf4bbb333bbbbbbbbbb333bb3bfbbbb31ff3bbbb3cccbb1155501031101650
bb3bb33bb3bbbbbbbb33f0d5f33b3bbbb499492b5ab131a11112424242424011b3b44bbb1113b3bbbb3b3111bb3fb3bbb31f93b3b3cc66cb15676500b3170510
b3b333333b3bb3bbbb33f059333bbbbbb244442b1b3313b3f9f24242424240ffbbb21bbbffff9fbbbbf9ffffb31ffbb3bb3f93bbb3cc66cb17111d0031761010
b3b333ff33bbbbbbb3b3ffff33b3bbbbb222222b11311b3099f2121212121099bbb21bbb999ffbfbbfbff999bb3f93bbb31ffbb3b33cccbb161005003165110b
bb333ff993b3bbbbbbb33ff3bb3bbb3bbbb42bbb301101033330101010101033bbbf4bbb33b3bfbbbbfb3b33b31f93b3bb3fb3bb3ccbb3bb1d100d0317151103
b3b33f90033bb3bbbb3b3333bbbbbbbbbbb42bbbb300002bbb3030d0c050313bbbb44b3bbbbbbbbbbbbbbbbbb31ff3bbbb3bfbbb3c6b3c6b1510050330300033
bb33390dd5933bbbbbb3bbbbbbbbbbbbbbbbbbbbbb4121bbbb33335dcc533bbbbbb21bbbb3bb3bbbbbb3bb3bb31f252525254625252525252525442545252525
25254425462545454545252525254545452546252525252525252525254444252525252525252544254425452525252525252525454425252525462525252525
25452525452525452525252525252525444425252544442546452525252546252545252525252525252525252525444425252525252525452525252525252525
25254425462525254425252525254525452525254646252525252525252525252525252525254425252525452525252544452525254545454525252525252525
25252525252525252525252525252525252525252544462525454525254525254625252525454525254544252525254525254444252525252525254625442525
25252525252525254444252525444425464525252525462525452525252525252525252525254444254425452525252525252545254525252546252525252525
25252544442525252525252525252525252525254644454545254545252525442545464625442525252545252525254525252544442525252525252525442525
25252525252525252525252525444625254545252545252546252525254545252545442525252545254425462545454545252525254545452546252525252525
25252525444425252525252525254425252525254444454525252545454645444525252546444425252545252525252525252525252525252525252544254544
25252525252525252525252546444545452545452525254425454646254425252525452525252545254425462525254425252525254525452525254646252525
25252525252525252525252525254625252525252525252525252525254645452525252525252525254545252525252525252525252525252525252544442545
25252525252544252525252544444545252525454546454445252525464444252525452525252525252525252525254444252525444425464525252525462525
45252525252525252525252544444646252525252525252525252525252546252525252525444425254525252544444425252545452525454425252525452545
25252525252546252525252525252525252525252546454525252525252525252545452525252525252525252525252525252525444625254545252545252546
25252525454525252525252525252525252525252525252525252525252544444646252525252546464625252525252546462544252525254525252525454545
25252525444446462525252525252525252525252525462525252525254444252545252525444444252525252525252525252546444545452545452525254425
45464625442525252525252525252525442525252525252525252525252525252525252525252525252525252525252525254644442525254525252525254525
25252525252525252525252525252525252525252525444446462525252525464646252525252525252525252544252525252544444545252525454546454445
25252546444425252525252525252525252525252525252525252525252525252525464545452545254525452545252525252525252525454525252525254625
25254425252525252525252525252525252525252525252525254646464625252525252525252525252525252546252525252525252525252525252546454525
25252525252525252525252525252525252525252525252544252525252525252544252525252525252525252525252525252525252525252525252525252525
25252525252525444425252525252525252525252525252525252525252525252525444425252525252525444446462525252525252525252525252525462525
25252525444425252525252544252525252525252525252525252525252525252525252525252525252525252525252525252546454545254525452545254525
25252525252525252525252525252544252525252525252525252525252525252525252525252525252525252525252525252525252525252525252525252525
25252525252525252525252525252525254545252545454525252525252525252525252525252525254444444444442525252544464625252525252525252525
25252525252525252525252525252525254444444444442525252544464625252525252525252525252525252525252525252525252525464545452545254525
45254525252525252525254625464625454544442525254525252525254425252525252525252525252525252525252525252525252544252525252525252544
44252525254425252525252525252525252525252525252525252525252544252525252525252544442525252544444444444425252525444646252525252525
25252525252525252525254625252546254425252525252525252525252525252525454525254545452544252525252525444425252525442525252525444425
25252525252525252525454525254545452544252525252525444425252525442525252525444425252525252525252525252525252525252525442525252525
25252544442525252525442525254544444625252525452545252525462546462545454444252525452545252525252525252544442525252525252525254646
25252525462546462545454444252525452545252525252525252544442525252525252525254646252545454525442525252525254444252525254425252525
25444425252525252525252525452544252525454545252525252525462525254625442525252525252545252525252525442525442525252525252525252525
25252525462525254625442525252525252545252525252525442525442525252525252525252525252525254525452525252525252525444425252525252525
25254646252525252525252525254425252525252544252525252544252525454444462525252545254525252525252525252525252525252525442525252525
25252544252525454444462525252545254525252525252525252525252525252525442525252525252525252525452525252525254425254425252525252525
25252525252525252525252525254425252525252525444525252525252545254425252545454525252545252525254525252525252525252525442525252544
25252525252545254425252545454525252545252525254525252525252525252525442525252544252525452545252525252525252525252525252525254425
25252525252525442525252546252525252525254425452525252525252525442525252525254425252525252525254525252525252525252525252525252544
44252525252525442525252525254425252525252525254525252525252525252525252525252544444545252525452525252545252525252525252525254425
25252544252525252525442545462525252525252545252525252525252525442525252525252544452525252525254525252525252525254625252525252525
25252525252525442525252525252544452525252525254525252525252525254625252525252525252544252525252525252545252525252525252525252525
25252544442525252525442546252525252525252545252525252525254625252525252525442545252525252525254525252544252525254646252525252525
25252525254625252525252525442545252525252525254525252544252525254646252525252525252525444525252525252545252525252525252546252525
25252525252525252525442545252525252525252545442525252544254546252525252525254525252525444444442545442525252525252546252525452525
25252544254546252525252525254525252525444444442545442525252525252546252525452525254425452525252525252545252525442525252546462525
25252525252525252525252545252525254445252525454545252544254625252525252525254525252525252525462525452525252525252525252525452525
25252544254625252525252525254525252525252525462525452525252525252525252525452525252545252525254444444425454425252525252525462525
25452525252525442525442545252525252525254525452525252544254525252525252525254544252525254625252525252545252545252545452546452525
25252544254525252525252525254544252525254625252525252545252545252545452546452525252545252525252525254625254525252525252525252525
25452525252525442525442546254545454525252525454545252525254525252525444525252545454545252525252525252525252525252525452525252525
25252525254525252525444525252545454545252525252525252525252525252525452525252525252545442525252546252525252525452525452525454525
46452525252525442525442546252525442525252525452545252544254525252525252525452545252525462525252525252525254444252525252525254625
44252544254525252525252525452545252525462525252525252525254444252525252525254625442525454545452525252525252525252525252525254525
25252525252525252525252525252525444425252544442546252544254625454545452525252545454525462525252525252525252544442525252525252525
44252544254625454545452525252545454525462525252525252525252544442525252525252525444525452525254625252525252525252544442525252525
25254625442525442525252525252525252525252544462525252544254625252544252525252545254525252546462525252525252525252525252525252544
25252544254625252544252525252545254525252546462525252525252525252525252525252544252525454545254625252525252525252525444425252525
25252525442525442525252525252525252525254644454545252525252525252544442525254444254645252525254625254525252525252525252525252544
44252525252525252544442525254444254645252525254625254525252525252525252525252544442525452545252525464625252525252525252525252525
25252544252525442525252525254425252525254444454525252525252525252525252525254446252545452525452525462525252545452525454425252525
45252525252525252525252525254446252545452525452525462525252545452525454425252525452544442546452525252546252545252525252525252525
25252544442525252525252525254625252525252525252525252525252525252525252525464445454525454525252544254546462544252525254525252525
45252525252525252525252525464445454525454525252544254546462544252525254525252525452544462525454525254525254625252525454525254544
25252525452525252525252544444646252525252525252525252525252525442525252525444445452525254545464544452525254644442525254525252525
__map__
5252525252525244525252525244445454525252545464544454525252644444525252545252525252644454545452545452525244525464645244525252525452525252545252525252525252525252525252525252525252525252525252645252525252525252525252525252645454525252525252525252545452525252
5252525252525264525252525252525252525252525264545452525252525252525254545252525252444454545252525454645444545252526444445252525452525252525252525252445252525252525252525252525252525252524444646452525252525252525252525252526452525252525244445252545252524444
4452525252444464645252525252525252525252525252645252525252524444525254525252444444525252525252525252645454525252525252525252545452525252525252525252525252525244445252525252525252525252525252525252525252525252525252525252524444646452525252526464645252525252
5252525252525252525252525252445252525252525252525252525252525252525252525252525252525252525252525252526452525252525244445252545252524444445252525252525252525252525252525252524452525244525252525252525252525252525252525252525252525264646464525252525252525252
5252524452525252525252525252525252525252525252525252525252525252645454545254525452545254525252525252524444646452525252526464645252525252525252525252525252525252525252525252525252525252525252524444525252525252525252525252525252525252525252525252524444525252
5252525252525252525252525252525252525252525244444444444452525252446464525252525252525252525252525252525252525264646464525252525252525252525252445252525252525252525252525252525252525252525252525252525252525252445252525252525252525252525252525252525252525252
5252525252525252525244525252525252525252525252525252525252525252525252445252525252525252444452525252525252525252525252525252524444525252525252525252525244445252525252525252525252525252524444646452525252525252525252525252526452525252525244445252545252524444
4452525444445252525252525252525454525254545452445252525252524444525252524452525252524444525252525252525252525252525252525252525252525252525252525252525252525252525252524452525252525252525252525252525252525252525252525252524444646452525252526464645252525252
5252545244525252526452646452545444445252525452545252525252525252444452525252525252525264645252444452525244445264545252525264525254525252525252525252525252444452525252525252525452525244525252525252525252525252525252525252525252525264646464525252525252525252
5252524452525252526452525264524452525252525252545252525252524452524452525252525252525252525252525252525244645252545452525452526452525252545452525444525252525452525252525252525252525252525252524444525252525252525252525252525252525252525252525252524444525252
5252524452525252445252525444446452525252545254525252525252525252525252525252524452525252525252525252526444545454525454525252445254646452445252525254525252525444525252525254526464525252525252525252525252525252445252525252525252525252525252525252525252525252
5264525252525252525252545244525252545454525252545252525254525252525252525252524452525252445252525252524444545452525254546454445452525264444452525254525252525252525252525252645252525252524452525252525252525244524452525252525252525252525252525252525252525252
5254645252525252525252524452525252525244525252525252525254525252525252525252525252525252444452525252525252525252525252526454545252525252525252525454525252525252525244525264525244525252525252525252525252525252524444525252525252525244525252525252525252525252
5264525252525252525252524452525252525252445452525252525254525252525252525264525252525252525264525252525252525252525252525264525252525252444452525252525252525252445252525252525252525252525252525252525252525252525252525252525252525252444444444444525252525252
5254525252525252525264525252525252524452545252525252525254525252445252525264645252525252525252525252525252525252525252525244446464525252525264645252525252525252525252525252525252525252525252525252645454545254525452545254525252525252525252525252525252525252
5252525252525252445254645252525252525254525252524444444452544452525252525252645252525452525252525252525252525252525252525252525252646464645252525252525252525252525252525252525244444444444452525252446464525252525252525252525252525252525252525252525252525252
5252525252525252445264525252525252525254525252525252526452525452525252525252525252525452525244445252525252525252525252525252525252525252525252525252525244525252525252525252525252525252525252525252525252445252525252525252444452525252525252645454545254525452
5252525252525252445254525252525252525254445252525264525252525252545252545252545452645452525252525252525252524452525252525252525252525252525252525252525252525252525454525254545452445252525252524444525252524452525252524444525252525252525252525252525252525252
5252525244525252525254525252524454525252545454545252525252525252525252525252525452525252525252445252525252525252525252525252525252525252525252525252526452646452545444445252525452545252525252525252444452525252525252525264645264545454525452545254525452525252
5252525252525252445254525252525252525452545252526452525252525252525244445252525252525264524452525252525252525252525252525252525252645454545254525252526452525264524452525252525252545252525252524452524452525252525252525252525244646452525252525252525252525252
5252526452645252445264525454545452525252545454526452525252525252525252444452525252525252524452525252525252525244444444444452525252446464525252525252445252525444446452525252545254525252525252525252525252525252524452525252525252525244525252525252525244445252
5252526452525252445264525252445252525252545254525252646452525252525252525252525252525252445252525252525252525252525252525252525252525252445252525252525252545244525252545454525252545252525254525252525252525252524452525252445252525252445252525252444452525252
5252445252525252525252525252444452525244445264545252525264525254525252525252525252525252444452525454525254545452445252525252524444525252524452525252525252524452525252525244525252525252525254525252525252525252525252525252444444445252525252525252526464524452
5252525252545252525252525252525252525244645252545452525452526452525252545452525444525252525452545444445252525452545252525252525252444452525252525252525252524452525252525252445452525252525254525252525252525264525252525252525252445252525252525252525252524452
5252525252525252525252525252525252526444545454525454525252445254646452445252525254525252525464524452525252525252545252525252524452524452525252525252525264525252525252524452545252525252525254525252445252525264645252525252525252525252525252445252525252525252
5252525252525252525252524452525252524444545452525254546454445452525264444452525254525252525244446452525252545254525252525252525252525252525252525252445254645252525252525254525252524444444452544452525252525252645252525452525252525252525252445252525244525252
5252525264525252525252526452525252525252525252525252526454545252525252525252525454525252525244525252545454525252545252525254525252525252525252525252445264525252525252525254525252525252526452525452525252525252525252525452525252525252525252525252525244445252
5252445254645252525244446464525252525252525252525252525264525252525252444452525452525244444452525252525244525252525252525254525252525252525252525252445254525252525252525254445252525264525252525252545252545252545452645452525252525252526452525252525252525252
5252445264525252525252525252525252525252525252525252525244446464525252525264646452525252525252525252525252445452525252525254525252525252525264525252525254525252524454525252545454545252525252525252525252525252525452525252525244525252526464525252525252525252
5252445254525252445252525252525252525252525252525252525252525252646464645252525252525252525252525252524452545252525252525254525252445252525264645252445254525252525252525452545252526452525252525252525244445252525252525264524452525252525264525252545252525452
5252525254525252525252525244445252525252525252525252525252525252525252525252525244445252525252525252525254525252524444444452544452525252525252645252445264525454545452525252545454526452525252525252525252444452525252525252524452525252525252525252545252525452
5252445254525252525252525252525252525252524452525252525252525252525252525252525252525252525252525252525254525252525252526452525452525252525252525252445264525252445252525252545254525252646452525252525252525252525252525252445254525254525254545264545252525252
