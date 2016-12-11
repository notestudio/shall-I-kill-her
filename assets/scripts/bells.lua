local anim8 = require 'assets/scripts/vendor/anim8'
local tools = require 'assets/scripts/tools'
local HC = require 'assets/scripts/vendor/HC'

local bell = {}
local collision_debug = true
local collisions = {}
local cam_x, cam_y = nil

function bell.load(game, cam)
  	body = {
		img = love.graphics.newImage('assets/sprites/bells/bell_vibrate.png'),
		num_frames = 10,
		speed = 0.05,
		x = -game.canvas.width,
		y = -game.canvas.height
  	}
	g = anim8.newGrid(body.img:getWidth() / body.num_frames, body.img:getHeight(), body.img:getWidth(), body.img:getHeight())
  	body.animation = anim8.newAnimation(g('1-' .. body.num_frames, 1), body.speed, 'pauseAtEnd')
  	body.animation:pause()

  	cam_x, cam_y = cam.gcam:getVisible()
  	bell_1 = tools.clone_table(body)
  	bell_1.x = cam_x + (game.window.width / 4) - (bell_1.img:getWidth() / body.num_frames / 2)
  	bell_1.y = (game.window.height / 2) - (bell_1.img:getHeight() / 2)
  	bell_2 = tools.clone_table(body)
  	bell_2.x = cam_x + (game.window.width / 4 * 2) - (bell_1.img:getWidth() / body.num_frames / 2)
  	bell_2.y = bell_1.y
  	bell_3 = tools.clone_table(body)
  	bell_3.x = cam_x + (game.window.width / 4 * 3) - (bell_1.img:getWidth() / body.num_frames / 2)
  	bell_3.y = bell_1.y
  	bells = {bell_1, bell_2, bell_3}	

  	-- Collisions
  	collisions.size = 15
	collisions.positions = {}
	collisions.num = 15 
	collisions.correction = 45

	-- Make positions collisions
	for i = 1, collisions.num, 1 do
		local tem_x, tem_y = tools.cicle_positions(0, 0, bell_1.img:getHeight() / 2, 360 / collisions.num * i)
		collisions.positions[i] = {x=tem_x, y=tem_y}
	end

	-- Add collisions
	for key, bell in pairs(bells) do
		bell.collisions = {}
		bell.enable = {}
		for key, collision in pairs(collisions.positions) do
			bell.collisions[key] = HC.circle(bell.x + collision.x, collision.y, collisions.size)
			bell.enable[key] = false
		end
	end
end

function bell.update(dt, game, cam)
	-- Update cam position
  	cam_x, cam_y = cam.gcam:getVisible()
  	-- Ani bells
	bell_1.animation:update(dt)
	bell_2.animation:update(dt)
	bell_3.animation:update(dt)
	-- Bells fix pos
  	bell_1.x = cam_x + (game.window.width / 4) - (bell_1.img:getWidth() / body.num_frames / 2)
  	bell_2.x = cam_x + (game.window.width / 4 * 2) - (bell_1.img:getWidth() / body.num_frames / 2)
  	bell_3.x = cam_x + (game.window.width / 4 * 3) - (bell_1.img:getWidth() / body.num_frames / 2)
  	-- Collisions fix pos
	for key, bell in pairs(bells) do
		for key, collision in pairs(collisions.positions) do
			bell.collisions[key]:moveTo(collisions.positions[key].x + bell.x + (bell.img:getHeight() / 2) + collisions.correction, collisions.positions[key].y + bell.y + (bell.img:getHeight() / 2))
		end
	end
	-- Check collisions
	for key, bell in pairs(bells) do
		for key, collision in pairs(bell.collisions) do
    		for shape, delta in pairs(HC.collisions(bell.collisions[key])) do
				bell.enable[key] = true
    		end
		end
	end
	-- Logic
	local num_enable = 0
	for key, bell in pairs(bells) do
		for key, item in pairs(bell.enable) do
			-- Count enables
			num_enable = num_enable + 1
			-- if key == 1 and item and bell.enable[tools.table_length(bell.enable)] == false then
			-- end
		end
		if num_enable > 1 then
			-- Search emptys
			local count_singles = 0
			for key, item in pairs(bell.enable) do
				if key > 1 and bell.enable[key] and bell.enable[key - 1] == false then
					count_singles = count_singles + 1
				end
			end
			if count_singles >= 2 then
				for key, item in pairs(bell.enable) do
					bell.enable[key] = false
				end
			end
			count_singles = 0
		end
		num_enable = 0
	end
end

function bell.draw()
	if bells_enable then
		-- Bells
		for key, bell in pairs(bells) do
			bell.animation:draw(bell.img, bell.x, bell.y)
		end
		-- Collisions
		if collision_debug then
			for key, bell in pairs(bells) do
				for key, collision in pairs(collisions.positions) do
					if bell.enable[key] then
						bell.collisions[key]:draw('fill')	
					else
						bell.collisions[key]:draw('line')	
					end
				end
			end
		end
	end
end

return bell