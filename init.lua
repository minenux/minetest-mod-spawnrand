random_spawn = {}

function random_spawn(player)
   local elevation = 5
   local radius = 600
   local posx = math.random(-radius, radius)
   local posz = math.random(-radius, radius)
   local new_spawn = {x = posx, y = elevation, z = posz}
   minetest.log("action",  (new_spawn.x..' is the X location and '..new_spawn.z..' is the Z location.'))
   local node = minetest.get_node_or_nil(new_spawn)
   if not node or node.name == 'ignore' then
      minetest.log("action", 'area is not loaded.')
      minetest.emerge_area({x = new_spawn.x, y = new_spawn.y+30, z = new_spawn.z}, {x = new_spawn.x, y = new_spawn.y-30, z = new_spawn.z})
      minetest.after(3, find_ground, new_spawn, player)
   end
   find_ground(new_spawn, player)
end

function find_ground(pos, player)
   minetest.log("action", 'area has been loaded.')
   local node = minetest.get_node({x = pos.x, y = pos.y, z = pos.z})
   if node.name == 'air' or node.name == 'ignore' then --Theoretically above ground
      local i = 1
      local finished = false
      minetest.log("action", 'heading underground.')
      repeat
         local node = minetest.get_node({x = pos.x, y = pos.y - i, z = pos.z})
         i = i-1
         if i == -40 then
            minetest.log("action", 'unable to find solid ground for player.')
--            random_spawn(player)
         end
         if node.name ~= 'air' and node.name ~= 'ignore' then
            player:setpos({x = pos.x, y = pos.y - i + 2, z = pos.z})
            minetest.log("action", 'like a mole, we find air.')
            finished = true
         end
      until finished == true or i < -40
   elseif node.name ~= 'air' or node.name ~= 'ignore' then --Theoretically below ground
      local i = 1
      repeat
         local node = minetest.get_node({x = pos.x, y = pos.y + i, z = pos.z})
         i = i + 1
         if i == 40 then
            minetest.log("action", 'unable to find air for player, trying again.')
--            random_spawn(player)
         end
         if node.name == 'air' then
            minetest.log("action", 'horray, everything worked out.')
            player:setpos({x = pos.x, y = pos.y + i, z = pos.z})
            minetest.set_node({x = pos.x, y = pos.y + i -1, z = pos.z}, {name = 'default:torch', param2 = 1})
            i = 45
         end
      until node.name == 'air' or i >= 40
   end
end

minetest.register_node('random_spawn:node', {
   description = 'tests the spawn function',
   inventory_image = 'default_gold_lump.png',
   tiles = {'default_gold_lump.png'},
   groups = {oddly_breakable_by_hand = 1},
   paramtype = 'light',
   light_source = 14,
   on_punch = function(pos, node, player)
--      local new_pos = {x = pos.x, y = pos.y + 3, z = pos.z}
      minetest.log("action", 'somebody punched a node, what a jerk.')
      random_spawn(player)
--      player:setpos(new_pos)
   end
})
