spawnrand = {}

-- autodetection of beds support (only oficial mod)
local bed_respawn = minetest.settings:get_bool("enable_bed_respawn")
if bed_respawn == nil then
    bed_respawn = true
end
local bed_availav = minetest.get_modpath("beds")
if bed_availav == nil then
    bed_respawn = false
end
if beds == nil then
    bed_respawn = false
end

-- spawnrand function invocation, it uses internat "find_ground" to fid valid position from initial one
function spawnrand(player)
   local elevation = 20
   local radius = 600
   local posx = math.random(-radius, radius)
   local posz = math.random(-radius, radius)
   local new_spawn = {x = -174 + posx, y = elevation, z = 178 + posz}
   local node = minetest.get_node_or_nil(new_spawn)
   if not node or node.name == 'ignore' then
      minetest.emerge_area({x = new_spawn.x, y = new_spawn.y+30, z = new_spawn.z}, {x = new_spawn.x, y = new_spawn.y-30, z = new_spawn.z})
      minetest.after(.1, find_ground, new_spawn, player)
   else
      find_ground(new_spawn, player)
   end
end

-- find valid position from the player given
function find_ground(pos, player)
   local node = minetest.get_node({x = pos.x, y = pos.y, z = pos.z})
   if node.name == 'air' or node.name == 'ignore' then --Theoretically above ground
      local i = 1
      local finished = false
      repeat
         local node = minetest.get_node({x = pos.x, y = pos.y - i, z = pos.z})
         i = i-1
         if i == -20 then
            spawnrand(player)
         end
         if node.name ~= 'air' and node.name ~= 'ignore' then
            local protection = minetest.is_protected({x = pos.x, y = pos.y - i + 1, z = pos.z}, player)
            if protection then
               spawnrand(player)

            else
               player:setpos({x = pos.x, y = pos.y - i + 2, z = pos.z})
               minetest.set_node({x = pos.x, y = pos.y + i +1, z = pos.z}, {name = 'default:torch', param2 = 1})
               finished = true
            end
         end
      until finished == true or i < -30
   elseif node.name ~= 'air' or node.name ~= 'ignore' then --Theoretically below ground
      local i = 1
      repeat
         local node = minetest.get_node({x = pos.x, y = pos.y + i, z = pos.z})
         i = i + 1
         if i == 20 then
            spawnrand(player)
         end
         if node.name == 'air' then
           local protection = minetest.is_protected({x = pos.x, y = pos.y + i, z = pos.z}, player)
            if protection then
               spawnrand(player)
            else
               player:setpos({x = pos.x, y = pos.y + i, z = pos.z})
               minetest.set_node({x = pos.x, y = pos.y + i -1, z = pos.z}, {name = 'default:torch', param2 = 1})
               i = 25
            end
         end
      until node.name == 'air' or i >= 30
   end
end

-- api and usage in game
minetest.register_node('spawnrand:node', {
   description = 'tests the spawn function',
   inventory_image = 'default_gold_lump.png',
   tiles = {'default_gold_lump.png'},
   groups = {oddly_breakable_by_hand = 1},
   paramtype = 'light',
   light_source = 10,
   on_punch = function(pos, node, player)
      spawnrand(player)
   end
})


-- newspam in new player join
minetest.register_on_newplayer(function(player)

    if player ~= nil then
        spawnrand(player)
    end

end)


-- if joins again and are yet registered
minetest.register_on_joinplayer(function(player)

    local name

    if player ~= nil then
        name = player:get_player_name( )
        if bed_respawn then
            local pos = beds.spawn[name]
            if pos then
                player:setpos(pos)
            else
                spawnrand(player)
            end
        else
            spawnrand(player)
        end
    end

end)

-- newspam in payer dead, but doe snot remain with same position.. take care of bed but not of home yet
minetest.register_on_respawnplayer(function(player)

    local name

    if player ~= nil then
        name = player:get_player_name( )
        if bed_respawn then
            local pos = beds.spawn[name]
            if pos then
                player:setpos(pos)
            else
                spawnrand(player)
            end
        else
            spawnrand(player)
        end
    end

    return true

end)
