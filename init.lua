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

-- enalbe random only if radio are enought in game
local enable_rand = true

-- send notification to players only if enabled
local notice_pos = minetest.settings:get_bool("spawnrand.notification_position") or true

-- detect limits of maps to do not spawn close to borders
local mapgen_limit = tonumber(minetest.settings:get("mapgen_limit")) or 30000

-- set the radio of the spawn area to search
local radius_area = tonumber(minetest.settings:get("spawnrand.radius_area")) or math.abs(mapgen_limit)

-- now autodetection of the area and limits
radius_area = math.abs(radius_area)

if ( radius_area >= mapgen_limit ) then
    radius_area = mapgen_limit -- too big or invalid
end
if ( radius_area < 100 ) then
    radius_area = 300  -- too small will hit performance in big servers
end
if ( radius_area >= 20000 ) then
    radius_area = radius_area - mapgen_limit * 0.2 -- avoid borders
end
if ( radius_area < 3 ) then
    enable_rand = false -- this area is nonsense disable then
end

-- spawnrand function invocation, it uses internat "find_ground" to fid valid position from initial one
function spawnrand(player)
   local elevation = 20
   local radius = ratio_area
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
               finished = true
                  name = player:get_player_name()
                  pos = player:getpos()
                  if notice_pos then 
                      minetest.chat_send_player(name, "spawnrand: "..pos.x..","..pos.y..","..pos.z )
                  end
                  minetest.log("action", "[spawnrand] position for "..name.. ", "..pos.x..","..pos.y..","..pos.z)
                return true
            end
         end
      until finished == true or i <= -20
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
               i = 25
                  name = player:get_player_name()
                  pos = player:getpos()
                  if notice_pos then 
                      minetest.chat_send_player(name, "spawnrand: "..pos.x..","..pos.y..","..pos.z )
                  end
                  minetest.log("action", "[spawnrand] position for "..name.. ", "..pos.x..","..pos.y..","..pos.z)
                return true
            end
         end
      until node.name == 'air' or i >= 20
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
      if not enable_rand then
            minetest.chat_send_player(player:get_player_name( ), "WARNING radio is 1, current position : ".. pos.x ..","..pos.y..","..pos.z )
      end
      spawnrand(player)
   end
})


-- newspam in new player join, if radio 1 disable rand due performance, new players do not have bed rest yet
minetest.register_on_newplayer(function(player)

    local pos
    if player ~= nil and enable_rand then
        pos = player:getpos()
        if notice_pos then 
            minetest.chat_send_player(player:get_player_name( ), "...awaiting new spawn from : ".. pos.x ..","..pos.y..","..pos.z )
        end
        spawnrand(player)
    end

end)

-- newspam in payer dead, but doe snot remain with same position.. take care of bed but not of home yet
minetest.register_on_respawnplayer(function(player)

    local name, pos

    if player ~= nil and enable_rand then
        name = player:get_player_name()
        pos = player:getpos()
        if notice_pos then 
            minetest.chat_send_player(player:get_player_name( ), "...awaiting new spawn from : ".. pos.x ..","..pos.y..","..pos.z )
        end
        if bed_respawn then
            pos = beds.spawn[name]
            if pos then
                player:setpos(pos)
            else
                minetest.log("error", "[spawnrand] fails to determine bed position for "..name.. ", new spawn will be used")
                spawnrand(player)
            end
        else
            spawnrand(player)
        end
        return true
    end

end)
