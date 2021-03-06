pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- [ m v ]
-- matheus mortatti

-- global variables --
----------------------

objects = {}	-- all the objects active in the game
shake=0			-- camera shake
pause=false
current_id=0
message=""

has_walljump=true
has_bullet=true
has_ray=true

k_left=0
k_right=1
k_up=2
k_down=3
k_jump=4
k_shoot=5
k_change=4		-- second player button

player = 
{
	init=function(this)
		this.is_standing=false
		this.p_input=0
		this.hitbox={x=2, y=1, w=5, h=7}
		this.spd = {x=2,y=0}
		this.dir={x=0, y=0}
		this.p_jump = false
		this.is_jumping=false
		this.can_jump=false
		this.spr=1
		this.anim_timer=0
		this.wall_touching=false

		-- init weapon obj
		w=init_obj(weapon, this.x, this.y)
		del(objects, w)
	end,
	update=function(this)

		if pause then return end

		local input = btn(k_right) and 1 or (btn(k_left) and -1 or 0)
		local shoot = btn(k_shoot)
		local jump = btn(k_jump) and not this.p_jump
		this.p_jump = btn(k_jump)


		-- if the player is touching the walls
		this.wall_touching=solid_at(this.x+this.hitbox.x+input, this.y+this.hitbox.y, this.hitbox.w, this.hitbox.h)
		-- if the player is standing
		this.is_standing = solid_at(this.x+this.hitbox.x, this.y+this.hitbox.y+1, this.hitbox.w, this.hitbox.h)


		-- movement --
		--------------

		if input!=0 then this.p_input= input end
		this.can_jump = (this.is_standing or (this.wall_touching and has_doublejump))

		-- detects if player is jumping or not
		if not this.is_jumping then
			this.is_jumping=jump
		else
			this.is_jumping = not this.is_standing
		end

		-- set jump speed (doublejump)
		if this.can_jump and jump then
			this.spd.y = -4
		end

		local accel=0.6
		local deaccel=0.15
		local maxrun=2

		-- movement on the x axis
		if abs(this.spd.x) > maxrun then
			this.spd.x=appr(this.spd.x, sign(this.spd.x)*maxrun, deaccel)
		else
			this.spd.x=appr(this.spd.x, input*maxrun, accel)
		end

		--movement on the y axis
		local maxfall = 4
		local gravity=0.4

		-- wall jump!
		if has_walljump then 
			local wall_dir=(this.is_solid(-3*sign(abs(input)),0) and -1 or
				this.is_solid(3*sign(abs(input)), 0) and 1 or 0)
			if wall_dir!=0 and jump and not this.is_standing then
				this.spd.y=-4
				this.spd.x=-wall_dir*(maxrun+1)
			end
		end
		

		if input!=0 and this.wall_touching then maxfall=0.4  end

		if not this.is_standing then
			this.spd.y=appr(this.spd.y, maxfall, gravity)
		end

		if this.is_solid(0, sign(this.spd.y)) then this.spd.y=0 end

		-- move
		this.move(this.spd.x, this.spd.y)

		this.dir.x=0 this.dir.y=0
		if btn(k_down) then this.dir.y=1 elseif btn(k_up) then this.dir.y=-1 end
		this.dir.x=input
		
		-- animation --
		---------------

		if input!=0 then this.flip.x = input==-1 end

		if this.wall_touching and not this.is_standing then
			this.spr=5
		elseif (input != 0) then
			if not this.is_jumping then this.spr=1+this.anim_timer%4 else this.spr=3 end
		elseif (btn(k_down)) then
			this.spr = 6
		elseif btn(k_up)  then
			this.spr=7
		else
			this.spr=1
			this.anim_timer=0
		end
		this.anim_timer += 0.25

		w.type.update(w)

	end,
	draw=function(this)

		-- wall glitch (take this off of here)
		if this.wall_touching and has_walljump then
			local input = btn(k_right) and 1 or (btn(k_left) and -1 or 0)
			local x_off=7
			local x_off2=1

			if input==1 then x_off=14 x_off2=-7 end
			if rnd(1) < 0.5 then
				for i=this.x+x_off*input, this.x-input*x_off2, -input do
					for j=this.y+1, this.y+7 do
						local col = 2
						if rnd(1) < 0.5 then col=14 end
						if rnd(1) < 0.5 and solid_at(i, j, 1, 1) then pset(i, j, col) end
					end
				end
			end
		end

		spr(this.spr,this.x,this.y,1,1, this.flip.x, this.flip.y)
		w.type.draw(w)
	end
}

player_spawn={
	init=function ( this )
		this.state=0
		this.distance=10
		this.times=0
		sfx(0)
	end,

	update=function ( this )
		if this.state==1 then
			p=init_obj(player, this.x, this.y)
			del(objects, this)
		end
	end,

	draw=function ( this )
		if this.state==0 then
			local nparticles=10
			for i=0, nparticles do
				pset(this.distance*cos(i/nparticles)+this.x+4, this.distance*sin(i/nparticles)+this.y+4, 8+this.times)
			end

			this.distance -= 2
			if this.distance<=0 then this.times+=1 this.distance=10 if this.times == 4 then this.state=1 end end
		end
	end
}

player_death={
	init=function( this )
		-- this.pixels={}
		-- for i=this.y, this.y+8 do
		-- 	for j=this.x, this.x+8 do
		-- 		add(this.pixels, pget(j,i))
		-- 	end
		-- end		
		end_object(p.id)
		this.state=0
		this.distance=1
		this.time=0
		shake=10
	end,

	update=function( this )
			
		if this.state==1 then 
			this.time+=1

			if this.time>=10 then this.state=2 end
		elseif this.state==2 then

			
			init_obj(player_spawn, this.x, this.y)
			del(objects, this)

		end
	end,

	draw=function( this )
		if this.state==0 then 
			local nparticles=20
			for i=0, nparticles do
				local col=11
				if rnd(1)<0.2 then col = 13 end
				pset(this.distance*cos(i/nparticles)+this.x+4, this.distance*sin(i/nparticles)+this.y+4, col)
			end

			this.distance += 6
			if this.distance>40 then this.state=1 end

			-- for i=this.y, this.y+8 do
			-- 	for j=this.x, this.x+8 do
			-- 		pset(j, i, this.pixels[i*8+j])
			-- 	end
			-- end

		end
	end
}

weapon =
{
	init=function(this)
		this.spr_offx=0
		this.spr_offy=0
		this.spr=16
		this.x=0
		this.y=0
		this.hitbox={x=0, y=2, w=6, h=5}
		this.dir={x=0, y=0}
		this.p_inputx=1
		this.p_shoot=false
		this.p_change=false
		this.w_type=nil
	end,

	update=function(this)
		local inputx=btn(k_right) and 1 or (btn(k_left) and -1)
		local shoot=btn(k_shoot) and not this.p_shoot
		this.p_shoot=btn(k_shoot)
		local change=btn(k_change, 1) and not this.p_change
		this.p_change=btn(k_change, 1)
		local inputy=btn(k_down) and 1 or (btn(k_up) and -1 or 0)
		this.p_inputx=inputx or this.p_inputx
		 
		local collided=this.is_solid(1, 0) or this.is_solid(-1, 0) or this.is_solid(0, 1) or this.is_solid(0, -1)

		--follows player
		this.x=p.x
		this.y=p.y

		this.dir.x = 0
		this.dir.y = 0

		if inputy==1 then
			this.x=this.x
			this.y=this.y+8
			this.flip.x=false
			this.flip.y=true
			this.spr=17

			this.dir.y=1
			
		elseif inputy==-1 then
			this.x=this.x
			this.y=this.y-7
			this.flip.x=true
			this.flip.y=false
			this.spr=17
			
			this.dir.y=-1

		else
			if (inputx==-1 and p.wall_touching) then
				this.x=this.x + 7
				this.y=this.y
				this.flip.x=false
				this.flip.y=false
				this.spr=16
				
				this.dir.x = 1

			elseif (inputx==1 and p.wall_touching) then
				this.x=this.x-7
				this.y=this.y
				this.flip.x=true
				this.flip.y=false
				this.spr=16

				this.dir.x=-1
				
			elseif inputx==1 or this.p_inputx==1  then 
				this.x=this.x+7
				this.y=this.y
				this.flip.x=false
				this.flip.y=false
				this.spr=16

				this.dir.x=1
				
			elseif inputx==-1 or this.p_inputx==-1 then
				this.x=this.x-7
				this.y=this.y+0
				this.flip.x=true
				this.flip.y=false
				this.spr=16

				this.dir.x=-1
				
			end
		end


		-- shoot --
		-----------
		if change then if (this.w_type==bullet or this.w_type==nil) and has_ray then this.w_type=ray elseif (this.w_type==ray or this.w_type==nil) and has_bullet then this.w_type=bullet end end
		if shoot and this.w_type~=nil then init_obj(this.w_type, this.x, this.y, this.dir.x*8, this.dir.y*8) end
		-----------

		
	end,

	draw=function(this)
		spr(this.spr,this.x+this.spr_offx,this.y+this.spr_offy,1,1, this.flip.x, this.flip.y)
	end
}

-- one of the weapon shots
bullet={
	init=function(this)
		this.spr=18
		this.hitbox={x=0, y=0, w=8, h=3}
		this.time=0
		this.maxtime=30
		this.anim_timer=0
		this.length=3
		this.state=0 -- normal bullet state. 1 = exploding state

		if w.dir.y==1 then 
				this.x=w.x+4 this.y=w.y-2
				this.hitbox.w=3 this.hitbox.h=this.length
			elseif w.dir.y==-1 then 
				this.x=w.x+4 this.y=w.y+10
				this.hitbox.w=3 this.hitbox.h=this.length this.y-=this.hitbox.h
			elseif w.dir.x==1 then 
				this.x=w.x-3 this.y=w.y+4
				this.hitbox.w=this.length this.hitbox.h=3
			elseif w.dir.x==-1 then 
				this.x=w.x+10 this.y=w.y+4
				this.hitbox.w=this.length this.x-=this.hitbox.w this.hitbox.h=3
		end
	end,

	update=function(this)

		if this.state==0 then this.move(this.spd.x, this.spd.y) end

		if this.state==0 and (this.is_solid(sign(this.spd.x), 0) or this.is_solid(0, sign(this.spd.y)) or this.time>this.maxtime) then
			--del(objects, this)
			this.state=1
			shake=10
			this.time=0
		end

		if this.state==1 and this.time>3 then del(objects, this) end

		this.time+=0.75
	end,

	draw=function(this)
		if this.state==0 then 
			circfill(this.x, this.y, 2, 9)
			circ(this.x, this.y, 2, 7)
		else
			circfill(this.x, this.y, this.time%3, this.time%4 + 4)
		end
	end
}

ray={
	init=function(this)
		this.hitbox={x=0, y=0, w=16, h=3}
		this.length=16
		this.collided=false
	end,

	update=function(this)
		this.length=16
		for i=1, this.length do
			if w.dir.y==1 then 
				this.x=w.x+2 this.y=w.y+6
				this.hitbox.w=3 this.hitbox.h=i
			elseif w.dir.y==-1 then 
				this.x=w.x+2 this.y=w.y+2
				this.hitbox.w=3 this.hitbox.h=i this.y-=this.hitbox.h
			elseif w.dir.x==1 then 
				this.x=w.x+5 this.y=w.y+3
				this.hitbox.w=i this.hitbox.h=3
			elseif w.dir.x==-1 then 
				this.x=w.x+2 this.y=w.y+3
				this.hitbox.w=i this.x-=this.hitbox.w this.hitbox.h=3
			end

			if this.is_solid(0, 0) then this.length=i-1 break end
		end

		if this.length<16 then this.collided=true shake=10 else this.collided=false shake=0 end
		
		if w.dir.y==1 then 
			this.x=w.x+2 this.y=w.y+6
			this.hitbox.w=3 this.hitbox.h=this.length
		elseif w.dir.y==-1 then 
			this.x=w.x+2 this.y=w.y+2
			this.hitbox.w=3 this.hitbox.h=this.length this.y-=this.hitbox.h
		elseif w.dir.x==1 then 
			this.x=w.x+5 this.y=w.y+3
			this.hitbox.w=this.length this.hitbox.h=3
		elseif w.dir.x==-1 then 
			this.x=w.x+2 this.y=w.y+3
			this.hitbox.w=this.length this.x-=this.hitbox.w this.hitbox.h=3
		end

		if not btn(k_shoot) then shake = 0 del(objects, this) end
	end,

	draw=function(this)
		for i=0, 16, 4 do
			local y=clamp(this.y+i*abs(w.dir.y)+rnd(2), this.y, this.y+this.hitbox.h)
			local y_off=clamp(this.y+i*abs(w.dir.y)+rnd(4), this.y, this.y+this.hitbox.h)
			local x_off=clamp(this.x+i*abs(w.dir.x)+rnd(4), this.x, this.x+this.hitbox.w)
			local x=clamp(this.x+i*abs(w.dir.x)+rnd(2), this.x, this.x+this.hitbox.w)

			--rectfill(this.x, this.y, this.x+this.hitbox.w, this.y+this.hitbox.h, 8)
				rectfill(x, y, x_off, y_off, 8)
				rect(x, y, x_off, y_off, 7)
		end
	end
}

rock={
	init=function( this )
		this.spr=39
		this.timer=0
		this.state=0
		this.distance=0
	end,

	update=function( this )
		if this.state==0 and this.check_overlap_actor(ray, 1, 0) or this.check_overlap_actor(ray, -1, 0) or this.check_overlap_actor(ray, 0, 1) or this.check_overlap_actor(ray, 0, -1) then
			this.spr=39+this.timer%4
			this.timer+=0.10

			if this.spr>=42 then this.state=1 end
		end
	end,

	draw=function( this )
		if this.state==0 then 
			spr(this.spr, this.x, this.y)
		elseif this.state==1 then
			local nparticles=15
			for i=0, nparticles do
				local col=6
				pset(this.distance*cos(i/nparticles)+this.x+4, this.distance*sin(i/nparticles)+this.y+4, col)
			end

			this.distance+=2.5
			if this.distance>15 then del(objects, this) end
		end
	end
}

bullet_pickup={
	init=function( this )
		this.has_pickedup=false
		this.ridid=false
		this.hitbox={x=1, y=3, w=6, h=8}
	end,

	update=function( this )
		if this.check_overlap_actor(player, 0, 1) or this.check_overlap_actor(player, 0, -1) or this.check_overlap_actor(player, 1, 0) or this.check_overlap_actor(player, -1, 0) then
			this.has_pickedup=true
			pause=true
			has_bullet=true
			message="you've got the bullet!"
		end

		if btn(k_shoot) and this.has_pickedup==true then pause=false message="" del(objects, this) end
		
	end,

	draw=function( this )
		circfill(this.x+3, this.y+5, 2, 9)
		circ(this.x+3, this.y+5, 2, 7)
	end
}

ray_pickup={
	init=function( this )
		this.has_pickedup=false
		this.ridid=false
		this.hitbox={x=1, y=3, w=6, h=8}
	end,

	update=function( this )
		if this.check_overlap_actor(player, 0, 1) or this.check_overlap_actor(player, 0, -1) or this.check_overlap_actor(player, 1, 0) or this.check_overlap_actor(player, -1, 0) then
			this.has_pickedup=true
			pause=true
			has_ray=true
			message="you've got the ray!"
		end

		if btn(k_shoot) and this.has_pickedup==true then pause=false message="" del(objects, this) end
		
	end,

	draw=function( this )
		circfill(this.x+3, this.y+5, 2, 9)
		circ(this.x+3, this.y+5, 2, 7)
	end
}

walljump_pickup={
	init=function( this )
		this.has_pickedup=false
		this.ridid=false
		this.hitbox={x=1, y=3, w=6, h=8}
	end,

	update=function( this )
		if this.check_overlap_actor(player, 0, 1) or this.check_overlap_actor(player, 0, -1) or this.check_overlap_actor(player, 1, 0) or this.check_overlap_actor(player, -1, 0) then
			this.has_pickedup=true
			pause=true
			has_walljump=true
			message="you've got wall jump!"
		end

		if btn(k_shoot) and this.has_pickedup==true then pause=false message="" del(objects, this) end
		
	end,

	draw=function( this )
		circfill(this.x+3, this.y+5, 2, 9)
		circ(this.x+3, this.y+5, 2, 7)
	end
}

door={
	init=function(this)
		this.spr=36
		this.hitbox={x=3, y=0, w=12, h=16}
		this.anim_timer=0
		this.open=false
		this.time=0
		this.p_collide=false
	end,

	update=function(this)
		if pause then return end

		if this.check_overlap_actor(this.weapon, 1, 0) or this.check_overlap_actor(this.weapon, -1, 0) then this.open=true end

		if this.check_overlap_actor(player, 0, 0) or this.check_overlap_actor(player, 0, 0) then 
			this.p_collide=true
			this.open=true
		else 
			this.p_collide=false
		end

		if this.open and this.spr~=38 then 
			this.anim_timer+=0.25 
			this.spr=36+this.anim_timer%3
		elseif not this.open and this.spr~=36 then 
			this.anim_timer+=0.25 
			this.spr=38-this.anim_timer%3 
		end

		if this.spr==38 then 
			this.rigid=false 
			if this.time>50 and not this.p_collide then 
				this.open=false 
			end 
			this.time+=1 
			this.anim_timer=0
		elseif this.spr==36 then 
			this.rigid=true this.time=0 
			this.anim_timer=0
		end
	end,

	draw=function(this)
		spr(this.spr, this.x+8, this.y, 1, 2, this.flip.x, this.flip.y)
		spr(this.spr, this.x, this.y, 1, 2, not this.flip.x, this.flip.y)

		-- changes color to the matching weapon's color
		for i=this.x, this.x+16 do
			for j=this.y, this.y+16 do
				local c=pget(i, j)
				if c==12 then pset(i, j, this.col) end
			end
		end
	end
}

cam={
	init=function(this)
		this.x=0
		this.y=0
		
	end,

	update=function(this)

		if shake>0 then 
			this.x=0+rnd(2)-1
			this.y=0+rnd(2)-1
			shake-=1
		else
			this.y=0
			this.x=0
		end

	end,

	draw=function(this)
		camera(this.x, this.y)

		
	end
}

room={
	init=function(this)
		this.state=0	-- still state
		this.target={x=0, y=0}
		this.index={x=48, y=48}
		this.room_start=true
	end,

	update=function(this)
		

		-- if p~=nil and this.state==0 then
		-- 	if p.x<this.x then 
		-- 		this.state=1	-- transition state
		-- 		pause=true
		-- 		this.target.x=this.x-128
		-- 		this.target.y=this.y
		-- 	elseif p.x>this.x+128 then 
		-- 		this.state=1	-- transition state
		-- 		pause=true
		-- 		this.target.x=this.x+128
		-- 		this.target.y=this.y
		-- 	elseif p.y<this.y then 
		-- 		this.state=1	-- transition state
		-- 		pause=true
		-- 		this.target.y=this.y-128
		-- 		this.target.x=this.x
		-- 	elseif p.y>this.y+128 then 
		-- 		this.state=1	-- transition state
		-- 		pause=true
		-- 		this.target.y=this.y+128
		-- 		this.target.x=this.x
		-- 	end
		-- end

		if this.state==1 then
			pause=false
			this.state=0
			this.room_start=true;
		end

		if p~= nil and this.state==0 then
			if p.x<0 then
				this.state=1
				pause=true
				p.x=120
				p.y-=1

				--this.target.x=120
				--this.target.y=p.y
				this.index.x-=16
			elseif p.x>126 then
				this.state=1
				pause=true
				p.x=0
				p.y-=1
				--this.target.x=0
				--this.target.y=p.y
				this.index.x+=16
			elseif p.y+8<0 then
				this.state=1
				pause=true
				p.y=128
				--this.target.y=128
				--this.target.x=p.x
				this.index.y-=16
			elseif p.y>128 then
				this.state=1
				pause=true
				p.y=8
				--this.target.y=8
				--this.target.x=p.x
				this.index.y+=16
			end
		end

		

		-- 	pause=false
		-- 	this.state=0
		-- 	p.x=this.target.x
		-- 	p.y=this.target.y
		-- 	if p~=nil then
		-- 		if p.x!=this.target.x then p.x=appr(p.x, this.target.x, 5) end
		-- 		if p.y!=this.target.y then p.y=appr(p.y, this.target.y, 5) end
		-- 	end

		-- 	if p.x==this.target.x and p.y==this.target.y then this.state=0 pause=false end
		--end
	end,

	draw=function(this)
		map(this.index.x, this.index.y, 0, 0, 16, 16, 1)
		if this.room_start then
			map(this.index.x, this.index.y, 0, 0, 16, 16)
			spawn_objects()
			map(this.index.x, this.index.y, 0, 0, 16, 16, 1)
			this.room_start=false
		elseif room.state==0 then
			
		end
	end
}

hud={
	init=function( this )
		this.message={x=0, y=100}
		this.weapon={x=100, y=5}
		this.weapon_spr=32
	end,

	update=function( this )
		
	end,

	draw=function( this )
		print(message, this.message.x, this.message.y)
		
		if w~=nil then 
			if w.w_type==bullet then
				rectfill(this.weapon.x, this.weapon.y, this.weapon.x+8, this.weapon.y+8, 6)
				circfill(this.weapon.x+4, this.weapon.y+4, 2, 9)
				circ(this.weapon.x+4, this.weapon.y+4, 2, 7)
			elseif w.w_type==ray then
				spr(32, this.weapon.x, this.weapon.y)
			end
		end

	end
}


-- initiates object
function init_obj(type, x, y, spdx, spdy)
	local obj={}

	obj.type=type
	obj.x=x
	obj.y=y
	obj.spd={x=0, y=0}
	obj.hitbox={x=0, y=0, w=8, h=8}
	obj.rigid=true
	obj.id=current_id
	current_id+=1

	obj.flip={x=false, y=false}
	obj.spr=0

	if type~=nil and (type==bullet or type==ray) then
		obj.spd.x=spdx
		obj.spd.y=spdy
	end

	obj.is_solid=function(ox, oy)
		return solid_at(obj.x+obj.hitbox.x+ox, obj.y+obj.hitbox.y+oy, obj.hitbox.w, obj.hitbox.h) or obj.check_collision(ox, oy)
	end

	obj.overlap_actor=function(ox, oy)
		for other in all(objects) do
			if other~=nil and other!=obj and
				other.x+other.hitbox.x+other.hitbox.w > obj.x+obj.hitbox.x+ox and
				other.y+other.hitbox.y+other.hitbox.h > obj.y+obj.hitbox.y+oy and
				other.x+other.hitbox.x < obj.x+obj.hitbox.x+obj.hitbox.w+ox and
				other.y+other.hitbox.y < obj.y+obj.hitbox.y+obj.hitbox.h+oy then

				return other
			end
		end
		return nil
	end

	obj.check_collision=function(ox, oy)
		local collided = obj.overlap_actor(ox, oy)
		return collided~=nil and collided.rigid and not ignored_collision(collided)
	end

	obj.check_overlap_actor=function(type, ox, oy)
		local collided = obj.overlap_actor(ox, oy)
		return collided~=nil and collided.type==type
	end

	obj.move_x=function(amount)
		for i=0, abs(amount) do
			if (not obj.is_solid(sign(amount), 0)) then
				obj.x += sign(amount)
			end
		end
	end

	obj.move_y=function(amount)
		for i=0, abs(amount) do
			if (not obj.is_solid(0, sign(amount))) then
				obj.y += sign(amount)
			end
		end
	end

	obj.move=function ( ox, oy )
		obj.move_x(ox)
		obj.move_y(oy)
	end

	obj.draw=function()
		spr(obj.spr, obj.x, obj.y, 1, 1, obj.flip.x, obj.flip.y)
	end

	-- adds and initiates object
	add(objects, obj)
	if obj.type.init~=nil then
		obj.type.init(obj)
	end
	return obj
end

function end_object(id)
	for i=1, #objects do
		if objects[i].id==id then
			del(objects, objects[i])
			return
		end
	end
end

function destroy_objects()
	foreach(objects, function(obj)
				if obj.type==door then del(objects, obj) end
		end)
end

function spawn_objects()
	destroy_objects()
	for tx=0, 15 do
		for ty=0,15 do
			local tile=mget(room.index.x+tx, room.index.y+ty)
			if tile==39 then init_obj(rock, tx*8, ty*8)
			elseif tile==36 then spawn_door(tx*8, ty*8, ray, 8) 
			elseif tile==37 then spawn_door(tx*8, ty*8, bullet, 10) end
		end
	end
end

-- spawn door with specific weapon unlock
function spawn_door(x, y, weapon, col)
	local obj = {}
	obj.x=x
	obj.y=y
	obj.weapon=weapon
	obj.col=col
	obj.hitbox={x=0, y=0, w=8, h=8}
	obj.rigid=true
	obj.flip={x=false, y=false}
	obj.spr=0
	obj.id=current_id
	current_id+=1
	obj.type=door
	add(objects, obj)

	obj.overlap_actor=function(ox, oy)
		for other in all(objects) do
			if other~=nil and other!=obj and
				other.x+other.hitbox.x+other.hitbox.w > obj.x+obj.hitbox.x+ox and
				other.y+other.hitbox.y+other.hitbox.h > obj.y+obj.hitbox.y+oy and
				other.x+other.hitbox.x < obj.x+obj.hitbox.x+obj.hitbox.w+ox and
				other.y+other.hitbox.y < obj.y+obj.hitbox.y+obj.hitbox.h+oy then

				return other
			end
		end
		return nil
	end

	obj.check_overlap_actor=function(type, ox, oy)
		local collided = obj.overlap_actor(ox, oy)
		return collided~=nil and collided.type==type
	end

	if obj.type.init~=nil then
		obj.type.init(obj)
	end
	return obj
end

-- list of actors to be ignored when colliding with themselves
function ignored_collision(obj)
	return obj.type==weapon or obj.type==bullet or obj.type==ray or obj.type==player
end

-- returns if the cel has the collision flag set
function solid_at(x, y, w, h)
	return tile_flag_at(x, y, w, h, 1)
end	

function tile_flag_at(x,y,w,h,flag)
 for i=max(0,flr(x/8)),min(15,(x+w-1)/8) do
 	for j=max(0,flr(y/8)),min(15,(y+h-1)/8) do
 		if fget(tile_at(i,j),flag) then
 			return true
 		end
 	end
 end
	return false
end

function tile_at(x,y)
 return mget(room.index.x+x, room.index.y+y)
end

-- effects --
-------------

-- gets the odds of drawing a line, the height of the line
function glitch(odds, h_strp)
	for i=0,flr((8127-64)/64)do
		local h = flr(rnd(h_strp))+1
		if flr(rnd(odds))==0 then
			for j=i*64,clamp(i*64+63*h,0,8127) do
				o=0x6000+j
				v=peek(o)
				if flr(rnd(2))==1 then
				poke(o, 13)
				else
					poke(o,5)
				end
			end
		end
	end
end

-- put player at front of the list
function sort_player()
	if objects[1] ~= nil and objects[1].type ~= player then
		for i=#objects, 1, -1 do 
			if objects[i].type == player then 
				local obj=objects[1]
				objects[1]=objects[i]
				objects[i]=obj
				return
			end
		end
	end
end	

-- helper functions --
----------------------

function clamp(val,a,b)
	if b>a then 
		return max(a, min(b, val))
	else
		return max(b, min(a, val))
	end
end

function appr(val, target, amount)
	return val > target and max(val-amount, target) or min(val+amount, target)
end

function sign(val)
	return (val>0 and 1) or (val<0 and -1) or 0
end

-- pico-8 game functions --
---------------------------

function _draw()
	cls()


	room.draw(room)
	cam.draw(cam)
	--camera()

	-- sort player so he's in front of the list and is drawn first
	--sort_player()
	
	foreach(objects, function(obj)
				--if obj.type != player then obj.type.draw(obj) end
				obj.type.draw(obj)
		end)

	if p~=nil then
		print(p.x .. "  " .. p.y, 25, 0)
	end


	hud.draw(hud)
	--print(#objects .. "  " .. stat(0) .. "  " .. stat(1), 0, 0)


	--glitch(player.x, flr((128-player.x)/10))

end
p=nil
w=nil
function _init()
	--init_obj(bullet_pickup, 0, 0)
	hud.init(hud)
	room.init(room)
	cam.init(cam)
	init_obj(player_spawn, 50, 100)
	-- init_obj(bullet_pickup, 2*8, 58*8)
	-- init_obj(walljump_pickup, 94*8, 61*8)
	-- init_obj(rock, 51*8, 62*8)
	
end

function _update()
	room.update(room)
	cam.update(cam)
	foreach(objects, function(obj)
				obj.type.update(obj)
		end)
	
	hud.update(hud)
end
__gfx__
000000000000000000000000000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000bbbb0000bbbb000b33330000bbbb000bbbb0000000000000bbbb00000000000000000000000000000000000000000000000000000000000000000
0070070000b3333000b333300037766000b33330003333b00000000000b776600000000000000000000000000000000000000000000000000000000000000000
000770000037766000377660003666600037766000667730000bbbb0003666600000000000000000000000000000000000000000000000000000000000000000
00077000003666600036666000333330003666600066663000b33330003333300000000000000000000000000000000000000000000000000000000000000000
00700700003333300033333000555500003333300033333000366660003333300000000000000000000000000000000000000000000000000000000000000000
00000000005555000055550006000060065555000055556000377660005555000000000000000000000000000000000000000000000000000000000000000000
00000000006006000060006000000000000006000000600000655600006006000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000770070007000007000000000000000000000000000000000000000000000000000000000000000000000000
0000dd000d0000d00000000000000000080000800777000000000000000000000000000000000000000000000000000000000000000000000000000000000000
055dd0000dddddd0000880000080080000c00c000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55bbd00000dbbd00008cc800000cc000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000
55bbd000005bb500008cc800000cc000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000
055dd00000555500000880000080080000c00c000007077007000070000000000000000000000000000000000000000000000000000000000000000000000000
0000dd00000550000000000000000000080000807000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666660e0e22002eee2e22e20e2220111150001111500011110000066666600666665000066650000000000000000000000000000000000000000000000000
66666666e220e22002e2eeee202e2222111150001111500011110000666566665556655655006506000000000000000000000000000000000000000000000000
77667777e220e222002ee22200e22222111155001111500011110000665555666655556666500066000000000000000000000000000000000000000000000000
66667887e2000e22202e22200ee00222111155001111550011110000666556666665566566600665000000000000000000000000000000000000000000000000
87667887000200022022222020000022dddd6600dddd6600dddd0000665556665655565650000006000000000000000000000000000000000000000000000000
776677770e2220000000200000e22000dddd6660dddd6600dddd0000655665666556656660500560000000000000000000000000000000000000000000000000
66666666eeee222200ee00220e2e2220cccc7770cccc0000cccc0000666665566566655600660556000000000000000000000000000000000000000000000000
6666666600eee22202e222220ee22200cccc7770cccc0000cccc0000066666600566556005660560000000000000000000000000000000000000000000000000
66666666200ee22202ee2200000e200ecccc7770cccc0000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000
66666666e20e22000ee2220eee000ee2cccc7770cccc0000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000
66677666ee000002022e200ee2220e22dddd6660dddd6600dddd0000000000000000000000000000000000000000000000000000000000000000000000000000
667aa766e2200e22000000202e2200e2dddd6600dddd6600dddd0000000000000000000000000000000000000000000000000000000000000000000000000000
667aa766e200e2e20e2e2e20022200e2111155001111550011110000000000000000000000000000000000000000000000000000000000000000000000000000
66677666200e2e2202e2e2220000e000111155001111500011110000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600e2e2000e2e2e22002e2e20111150001111500011110000000000000000000000000000000000000000000000000000000000000000000000000000
666666660e2e2202e2e2e2222002e220111150001111500011110000000000000000000000000000000000000000000000000000000000000000000000000000
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
12121212121212121212121212121212121212121200000012121212121212121212121212121212121212121212121212000000121212120000000000000012
12121212121212121212121212121212121212121212121212121212121212121200000000000000000000000000001212000000000000000000000000000012
12121212121200000000720000000012120000000000000012121212121212121212121212121212121212121212121212000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000012121200000000720000000012120000000000000000121212000012121200121212121200121212120012121212000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000121200000000720000000012120000000000000000001212120012000000121212001200001212120012121212000000000000000012121200000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000001200000000720000000012120000000000000000001212000012120000121200000000001212000012121212000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000001200000012121212121212120000000000000000121212000012120000121200000000000012000000121212000012120000000000000000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000012000000000012120000000000000000001200000012000000120000000000000000000000001212000012120000000000000000000012
12000000000000000000000000000000000000000000000000000000000000520000000000000000000000000000001212000000000000000000000000000012
12000000000000000012000012000012120000000000000000000000000000000000000000000000000000000000001212000012120000000000000000000012
12000000000000000000000000000000000000000000000000000000000000530000000000000000000000000000001212000000000000000000000000000012
12000000000000000000001212000012120000000000000000000000000000000000000000000000000000000000001212000012120000000012120000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000012121200000000001212000012120000000000000000000000000000000000000000000000000000000000001212000000000000000012120000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000001212000012120000000000000000000000000000001212121200000000000000000000001212000000000000000012120000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000012120000000000000000000000000000000000000000000000000000000000001212000000000000000012120000121212
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000012120000000000000000000012121200000000000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000052000000000000000000000012121200000000001212121200000000000000005200000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000053000000000000000000121212121200000000001212121212121200000000005300000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212120000000012121212121212
12121212121212121212121212121212121212121212121212121212121212121212121212121212000000121212121212000000000000000000000000000012
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212120000000012121212121212
12121212121212121212121212121212121212121212121212121212121212121212121212121212000000121212121212000000000000000000000000000012
12000012121212121200000000001212121200000000121212121212121212121212001212120000001212121212121212120000000000000000000000000012
12121212120000001212120000000012120000121212120000001212121200121200000000000000000000000000001212000000000000000000000000000012
12000000001212120000000000001212121200000000001212121200001212121212000012121200001212121212001212120000000000000000000000000012
12121212121200000012120000000052000000001212120000001212120000121200000000000000000000000000001212000000000000000000000000000012
12000000001200000000000000000012120000000000000012120000001212120000000000121200000012121200000012120000121200000000000000000012
12121212121200000000000000000053000000001212120000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000012120000000000000012000000000012000000000000001212000012121200000012120000121200000012120000000012
12000012001200000000000000000012120000000012120000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000000120000000000000000000000000000000000000000000000000000121200000012120000121200000012120000000012
12000012000000000000000012120012120000000012120000001212000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000000120000000000000000000000000000000000000000000000000000001200001212120000000000000012120000000012
12000000000000001212120000120012120000000000120000001212121212121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000000121212121212121212121212121212121212121200000000000000001200121212000000000000000012120000000012
12000000000000000000120000000012120000000000120000001200000000121200000000000000000000000000001212000000000000000000000000000012
12121212000000000000000000000000000000000000000000000000000000000000000000120000000000000000121212000000000000000012120000000012
12000000001212120000000000000012120000000000120000001200000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121212000000121200000000000000000012
12000000001212000000000000000012120000000000120000001200000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000000000000000000000000000000000000000000000000001212000000000000001212000000121200000000000000121212
12000000001200001212120000000012120000000000120000001200000000121200000000000000000000000000001212000000000000000000000000000012
12121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000001212000000121200000000001212121212
12000000000000001212000000120012121200000000120000001200000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121212121212
12000000000000001200000012120012121200000000120000001200000000121200000000000000000000000000005200000000000000000000000000000012
12000000000012121200000000000000000000000000000012121200000000000000000000001212121200000000000000000000000000000000000000000052
00000000000000000000001212000012121212000000000000001200000000121200000000000000000000000000005300000000000000000000000000000012
12000000121212121212121212000012121212000000121212121200000000000000000012121212121212120000000000000000000000000000000000000053
00000000000000000000000000000012121212120000000000000000000012121212121212121212121212121212121212000000000000000000000000000012
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
__gff__
0000000000000000000000000000000000000000000000000000000000000000030303030404020400000000000000000303030300000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121
2121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000021212121212121212121000000000000002121212121210021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2121212100002121212121212121000021210000212121212121212100002121210021212121212121210021212121212100000000000000000021212121212100000000212100000000212121000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2121212100000000002121210000000000000000000021212100000000000021210000002121212121000000002121212100002100000000000000002121000000002121212121000000002100000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2121210000000000002121210000000000000000000000210000000000000000000000000021212100000000000021212100002121000000000000000000000000212121212121210000000000000021210000000000000000002121212121212100000000000000000000000000002121000000000000000000000000000021
2121000000000000000021000000000000000000000000000000000000000000000000000000212100000000000000212100002121212121212121212121212121212121212121212121212121212121210000000000000000000000000000212100000000000000000000000000000000000000000000000000000000000021
2100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212100002121210000212121212121212121212121000000000000000000000021212121212100000000000000000000212100000000000000000000000000000000000000000000000000000000000021
2100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212100002121210000002121210000212121212121210000000000000000000021210021212100000000002121000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212100002121000000002121000000002121212100000000000000000000000024000021212100000000002121000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000000000000000000000000000000000000000000000210000000000000000000000000000212100002100000000002100000000000000212100000000212121210000000034000000212100000000002121000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000000000000000000000000021000000000000000021210000000000000000000000000000250000000000000000000000000000000000000000000000000000000000002221210000212100000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000210000212100000000002121000000000000002121212100000000000000000000000000350000000000000000000000000000000000000000000000000000000022222221210000002100000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000212121212100000000212121000000000000212121212121000000000000000000000000212100000000000000000000000000210000000000000021212100000000000021210000002100000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000021212121212121000021212121000000002121212121212121210000000000000000000021212100000000000000000000000000212121000000002121212121000000000021210000000000000000212100000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000002121212121212121212121212121210021212121212121212121212121000000000000002121212100000000000000000000212121212121210000212121212121210000000021210000000000002121212100000000212100000000000000000000000000002121000000000000000000000000000021
2100002121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121000000002121212121212121212121212121212121212121212121210000000000002121212100000000212121212121212121212121212121212121000000000000000000000000000021
2100002121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121000000002121212121212100000000000000000000000000000000210000000000000000000000000000212121212121212121212121212121212121000000000000000000000000000021
2100000000002121210000000000002121212121212121212100000000212121212121000000000021212121000000212100000000000000000021000000002100000000000000000000000000000000210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000021210000000000002121212121212121212121000000000021212121000000000021212100000000212100000000000000000021000000002100000000000000000000000000000000210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000210000002100002100002121212100212121000000000021212121000000002121212100000000212100002100000021212121000000002100000000000000000000000000000000210000000000000000000000000000240000000000000000000000000000002121000000000000000000000000000021
2100000000000000210000002100002700000021212100002121210000000000212121000000002121210000000000212100002100000000000000000000002100000000000000000000000000000000210000000000000000000000000000340000000000000000000000000000002121000000000000000000000000000021
2100000000000000000000002100002700000000212100000000210000000000002121000000002121000000000000212100002100000000000000000000002100000000000000000000000000000000210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000002100002700000000212100000000210000000000000021000000002100000000000000212100002100000000000000000000002100000000000000000000000000000000210000000000002121212100000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000021212100002700000000002100000000000000000000000000000000000000000021212121212121212100000000000000000000002100000000000000000000000000000000210000210000002121210000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000212121212121000000000000000000000000000000000000000000000000000000000000212100000000000000212100000000002100000000000000000000000000000000210000210000002121000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000000000000002121212121000000000000000000000000000021212121000000000000000000000000212100000000000000212100000000002100000000000000000000000000000000210000210000002100000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000000021210000000000212121000000000000000000000000002100000000000000002121210000000000212100000000000000212100000000002100000000000000000000000000000000210000210000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
2100000000002121212100000000002121000000000000000000000000000000000000000000000000000000000021212100000000000000000000000000002100000000000000000000000000000000210000000000000000000000000021212100000000000000000000000000002121000000000000000000000000000021
2100000000212121212121000000002121000000000000000000000000000000000000002100000000000000000021212100000000000000000000000000002100000000000000000000000000000000210000000000000000000000002121212100000000000000000000000000002121000000000000000000000000000021
2100000021212121212121210000002121000000000000000000002121210000000000002121000000000000002121212100000000000000000000212121002100000000000000000000000000000000212100000000000000000000212121212100000000000000000000000000002121000000000000000000000000000021
2100212121212121212121212121002121000000000000000021212121212121210000002121212100000000212121212100000000000000000000000000002100000000000000000000000000000000212121000000000000000021212121212100000000000000000000000000002121000000000000000000000000000021
2121212121212121212121212121212121212121210000002121212121212121212121212121212121212121212121212100000021212121000000000000002100000000000000000000000000000000212121212121212121212121212121212100000000000000000000000000002121000000000000000000000000000021
__sfx__
010a00000137401375013740137501374013750137401375013040130501304013050130401305013040130511704137001570017700127000c7000e7001070011700137001370015700187001a7001c70018701
0110000009770097700a7700a770077700777005770057700477004770037700377002770027700277001770007700b7700b7700b770097700a77007770087700577006770047700a77009770087700777006770
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

