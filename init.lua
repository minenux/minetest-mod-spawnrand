random_spawn = {}

function random_spawn(player)
   local elevation = 15
   local radius = 5
   local posx = math.random(-radius, radius)
   local posz = math.random(-radius, radius)
   local new_spawn = {x = -174 + posx, y = elevation, z = 178 + posz}
   local node = minetest.get_node_or_nil(new_spawn)
   if not node or node.name == 'ignore' then
      minetest.emerge_area({x = new_spawn.x, y = new_spawn.y+30, z = new_spawn.z}, {x = new_spawn.x, y = new_spawn.y-30, z = new_spawn.z})
      minetest.after(.5, find_ground, new_spawn, player)
   else
      find_ground(new_spawn, player)
   end
end

function find_ground(pos, player)
   local node = minetest.get_node({x = pos.x, y = pos.y, z = pos.z})
   if node.name == 'air' or node.name == 'ignore' then --Theoretically above ground
      local i = 1
      local finished = false
      repeat
         local node = minetest.get_node({x = pos.x, y = pos.y - i, z = pos.z})
         i = i-1
         if i == -40 then
            random_spawn(player)
         end
         if node.name ~= 'air' and node.name ~= 'ignore' then
            local protection = minetest.is_protected({x = pos.x, y = pos.y - i + 2, z = pos.z}, player)
            if protection then
               random_spawn(player)
            else
               player:setpos({x = pos.x, y = pos.y - i + 2, z = pos.z})
               minetest.set_node({x = pos.x, y = pos.y + i +1, z = pos.z}, {name = 'default:torch', param2 = 1})
               finished = true
            end
         end
      until finished == true or i < -40
   elseif node.name ~= 'air' or node.name ~= 'ignore' then --Theoretically below ground
      local i = 1
      repeat
         local node = minetest.get_node({x = pos.x, y = pos.y + i, z = pos.z})
         i = i + 1
         if i == 40 then
            random_spawn(player)
         end
         if node.name == 'air' then
           local protection = minetest.is_protected({x = pos.x, y = pos.y + i, z = pos.z}, player)
            if protection then
               random_spawn(player)
            else
               player:setpos({x = pos.x, y = pos.y + i, z = pos.z})
               minetest.set_node({x = pos.x, y = pos.y + i -1, z = pos.z}, {name = 'default:torch', param2 = 1})
               i = 45
            end
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
      random_spawn(player)
   end
})
