--[[
  Copyright 2025 Matthew Wilbern (Fatboychummy)

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation
  files (the “Software”), to deal in the Software without
  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall
  be included in all copies or substantial portions of the
  Software.

  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY
  KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

--- 3x3 stripmining script for ComputerCraft

---@class stripmine.Position
---@field x integer The X coordinate of the position.
---@field y integer The Y coordinate of the position.
---@field z integer The Z coordinate of the position.


--#region Turtle Mining Utilities

--- The current facing of the turtle, north being `-Z` (0).
--- Note that this is relative to the turtle's starting facing (i.e: The starting direction of the turtle is considered to be 'north').
local facing = 0

--- The possible facings for the turtle, represented as integers.
--- Using integers here allows for more easily calculating the turtle's facing when it turns.
---@enum stripmine.Facing
local FACINGS = {
  NORTH = 0, -- -Z
  EAST = 1,  -- +X
  SOUTH = 2, -- +Z
  WEST = 3,  -- -X

  NEGZ = 0, -- -Z
  POSX = 1, -- +X
  POSZ = 2, -- +Z
  NEGX = 3, -- -X
}

--- The current position of the turtle in the world.
--- This is a relative position, starting at (0, 0, 0).
---@type stripmine.Position
local position = {x = 0, y = 0, z = 0}



--- Simulates a movement in the given direction, returns the new position.
---@param direction "forward"|"back" The direction to simulate the movement in.
---@param n integer? The number of blocks to move in the given direction. Defaults to 1.
---@return stripmine.Position new_position The new position after the simulated movement.
local function simulate_movement(direction, n)
  local new_position = {x = position.x, y = position.y, z = position.z}
  n = n or 1

  if direction == "forward" then
    if facing == 0 then -- North, -Z
      new_position.z = new_position.z - n
    elseif facing == 1 then -- East, +X
      new_position.x = new_position.x + n
    elseif facing == 2 then -- South, +Z
      new_position.z = new_position.z + n
    elseif facing == 3 then -- West, -X
      new_position.x = new_position.x - n
    end
  elseif direction == "back" then
    if facing == 0 then -- North, -Z
      new_position.z = new_position.z + n
    elseif facing == 1 then -- East, +X
      new_position.x = new_position.x - n
    elseif facing == 2 then -- South, +Z
      new_position.z = new_position.z - n
    elseif facing == 3 then -- West, -X
      new_position.x = new_position.x + n
    end
  end

  return new_position
end



--- Updates the turtle's position based on the current facing, and movement direction.
---@param direction "forward"|"back" The direction to update the position in.
local function update_position(direction)
  if direction == "forward" then
    if facing == 0 then -- North, -Z
      position.z = position.z - 1
    elseif facing == 1 then -- East, +X
      position.x = position.x + 1
    elseif facing == 2 then -- South, +Z
      position.z = position.z + 1
    elseif facing == 3 then -- West, -X
      position.x = position.x - 1
    end
  elseif direction == "back" then
    if facing == 0 then -- North, -Z
      position.z = position.z + 1
    elseif facing == 1 then -- East, +X
      position.x = position.x - 1
    elseif facing == 2 then -- South, +Z
      position.z = position.z - 1
    elseif facing == 3 then -- West, -X
      position.x = position.x + 1
    end
  end
end



--- Moves the turtle forward, keeping track of its position. Returns the output of `turtle.forward()`.
---@return boolean success Whether or not the turtle successfully moved forward.
---@return string? reason The reason for failure, if any.
local function forward()
  local success, reason = turtle.forward()
  if success then
    update_position("forward")
  end

  return success, reason
end



--- Moves the turtle back, keeping track of its position. Returns the output of `turtle.back()`.
---@return boolean success Whether or not the turtle successfully moved back.
---@return string? reason The reason for failure, if any.
local function back()
  local success, reason = turtle.back()
  if success then
    update_position("back")
  end

  return success, reason
end



--- Turns the turtle left, updating its facing direction.
---@return boolean success Whether or not the turtle successfully turned left.
---@return string? reason The reason for failure, if any.
local function turn_left()
  local success, reason = turtle.turnLeft()
  if success then
    facing = (facing - 1) % 4 -- Update facing direction, wrap around using modulo
  end

  return success, reason
end



--- Turns the turtle right, updating its facing direction.
---@return boolean success Whether or not the turtle successfully turned right.
---@return string? reason The reason for failure, if any.
local function turn_right()
  local success, reason = turtle.turnRight()
  if success then
    facing = (facing + 1) % 4 -- Update facing direction, wrap around using modulo
  end

  return success, reason
end



--- Moves the turtle up, keeping track of its position. Returns the output of `turtle.up()`.
---@return boolean success Whether or not the turtle successfully moved up.
---@return string? reason The reason for failure, if any.
local function up()
  local success, reason = turtle.up()
  if success then
    position.y = position.y + 1
  end

  return success, reason
end



--- Moves the turtle down, keeping track of its position. Returns the output of `turtle.down()`.
---@return boolean success Whether or not the turtle successfully moved down.
---@return string? reason The reason for failure, if any.
local function down()
  local success, reason = turtle.down()
  if success then
    position.y = position.y - 1
  end

  return success, reason
end



--- Face a specific direction.
---@param direction stripmine.Facing The direction to face, represented as an integer.
---@return boolean success Whether or not the turtle successfully turned to face the direction.
---@return string? reason The reason for failure, if any.
local function face(direction)
  direction = direction % 4 -- Ensure the direction is within the range of 0-3

  -- If already facing the direction, do nothing.
  if facing == direction then
    return true
  end

  -- If it's quickest to turn left, do so.
  if (facing - 1) % 4 == direction then
    return turn_left()
  end

  -- Otherwise, turn right until facing the direction.
  -- This will either turn us once to the right, or two times to be facing rear.
  repeat
    local success, reason = turn_right()
    if not success then
      return false, reason
    end
  until facing == direction

  return true
end



--- Moves to a position relative to the turtle's starting position, moving along the Y axis first, then the X and Z axes.
---@param offset stripmine.Position The offset to move to.
---@param move_callback fun(pos:stripmine.Position):nil The callback function to call before each move.
---@param move_fail_callback nil|fun(pos:stripmine.Position, reason:string):boolean The callback function to call if a move fails. If no callback is present, the function will return immediately. If the callback returns a falsey value, the function will return immediately.
---@return boolean success Whether or not the turtle successfully moved to the position.
---@return string? reason The reason for failure, if any.
---@return stripmine.Position? final_position The final position of the turtle after the move, if failed.
local function move_to_yxz(offset, move_callback, move_fail_callback)
  --- Move using the given function `f` (i.e: forward, etc), calling the callbacks as needed.
  local function move(f)
    move_callback(position)

    local success, reason = f()
    if not success and move_fail_callback then ---@cast reason -nil
      return move_fail_callback(position, reason)
    end

    return success, reason
  end

  -- # Handle Y movement.
  -- 1 - Move up if below the target.
  while position.y < offset.y do
    local ok, err = move(up)
    if not ok then
      return false, err, position
    end
  end
  -- 2 - Move down if above the target.
  while position.y > offset.y do
    local ok, err = move(down)
    if not ok then
      return false, err, position
    end
  end

  -- # Handle X movement.
  -- 1 - Move +x if 'below' the target.
  while position.x < offset.x do
    face(FACINGS.POSX)
    local ok, err = move(forward)
    if not ok then
      return false, err, position
    end
  end
  -- 2 - Move -x if 'above' the target.
  while position.x > offset.x do
    face(FACINGS.NEGX)
    local ok, err = move(forward)
    if not ok then
      return false, err, position
    end
  end

  -- # Handle Z movement.
  -- 1 - Move +z if 'below' the target.
  while position.z < offset.z do
    face(FACINGS.POSZ)
    local ok, err = move(forward)
    if not ok then
      return false, err, position
    end
  end
  -- 2 - Move -z if 'above' the target.
  while position.z > offset.z do
    face(FACINGS.NEGZ)
    local ok, err = move(forward)
    if not ok then
      return false, err, position
    end
  end

  -- Great success!
  return true
end



--- Digs around the turtle.
local function dig_around()
  turtle.dig()
  turtle.digUp()
  turtle.digDown()
end



--- Digs up and down, but not forward.
local function dig_up_down()
  turtle.digUp()
  turtle.digDown()
end



--- Finds an item in the turtle's inventory.
---@param item_name string The name of the item to find.
---@return integer? slot The slot number of the item, or nil if not found.
local function find_item(item_name)
  for i = 1, 16 do
    local item = turtle.getItemDetail(i)
    if item and item.name == item_name then
      return i
    end
  end
end



--- Places a torch.
local function place_torch()
  local torch_slot = find_item("minecraft:torch")
  if not torch_slot then
    return
  end

  turtle.select(torch_slot)
  turtle.placeDown()
  turtle.select(1) -- Reset to the first slot after placing the torch.
end



--- Moves to a position, mining along its way (gravity-block protected).
---@param offset stripmine.Position The position to move to.
---@param place_torches boolean? Whether or not to place torches in the tunnel. Defaults to false.
---@param torch_interval integer? The interval at which to place torches. Defaults to 10
---@return boolean success Whether or not the turtle successfully moved to the position.
local function mine_to(offset, place_torches, torch_interval)
  torch_interval = torch_interval or 10

  --- Counts the number of failed movements. If we fail to move too many times, we give up so we don't infinitely loop.
  local fail_count = 0
  local mined = 0

  --- Called before the turtle moves in each position.
  --- 1. Digs around the turtle.
  --- 2. Places a torch if needed.
  local function mine_move_callback()
    dig_around()

    if place_torches and (mined - 1) % torch_interval == 0 then
      place_torch()
    end

    mined = mined + 1
  end


  --- Called when the turtle fails to move.
  --- 1. Digs the block in front of the turtle.
  --- 2. If it fails, it increments the fail count and checks if it should continue.
  local function mine_move_fail_callback(pos, reason)
    -- On fail, increment the fail count.
    fail_count = fail_count + 1

    -- However, if we're able to dig, reset the fail count.
    -- This stops us from erroring out when there's a bunch of gravel or sand in the way.
    if turtle.dig() then
      fail_count = 0
    end

    -- If we fail too many times, give up.
    if fail_count > 5 then
      return false, "Failed to move to position after too many attempts: " .. reason
    end

    -- Otherwise, we can try to move again.
    return true
  end

  -- Move to the given position, digging as we go.
  if not move_to_yxz(offset, mine_move_callback, mine_move_fail_callback) then
    return false
  end

  -- Dig the last position's up and down to finish the tunnel.
  dig_up_down()

  return true
end



--- Digs a 3x3 tunnel in the direction the turtle is facing, to the right.
---@param length integer The length of the tunnel to dig.
---@param place_torches boolean? Whether or not to place torches in the tunnel. Defaults to false.
---@param torch_interval integer? The interval at which to place torches. Defaults to 10
---@return boolean success Whether or not the turtle successfully dug the tunnel.
---@return string? reason The reason for failure, if any.
local function dig_tunnel(length, place_torches, torch_interval)
  local turn_f = turn_right

  --- Turns the turtle around, lining up for the next section of the tunnel.
  ---@return boolean success Whether or not the turtle successfully turned around.
  local function turn()
    turn_f()
    if not mine_to(simulate_movement("forward")) then
      return false
    end
    turn_f()

    turn_f = turn_f == turn_right and turn_left or turn_right
    return true
  end

  -- For each row of the tunnel, mine forward, then turn around.
  for i = 1, 3 do
    -- Dig to the end of the row.
    if not mine_to(
      -- Mine to the simulated position
      simulate_movement("forward", i == 1 and length or length - 1),

      -- Place torches if needed, and if this is the middle row.
      place_torches and i == 2,
      torch_interval
    ) then
      return false, "Failed to mine to position at row " .. i
    end

    -- If this isn't the last row, turn around.
    if i < 3 then
      if not turn() then
        return false, "Failed to turn around after mining row " .. i
      end
    end
  end

  return true
end



--- Digs a stripmine tunnel, with branches.
---@param length integer The length of the main tunnel.
---@param branch_length integer The length of the branches.
---@param branch_distance integer? The distance between branches. This includes the width of each branch. Defaults to 5 (one block gap between branches).
---@param place_torches boolean? Whether or not to place torches in the tunnel. Defaults to false.
---@param torch_interval integer? The interval at which to place torches. Defaults to 10.
---@return boolean success Whether or not the turtle successfully dug the stripmine.
---@return string? reason The reason for failure, if any.
local function dig_stripmine(length, branch_length, branch_distance, place_torches, torch_interval)
  branch_distance = branch_distance or 5
  torch_interval = torch_interval or 10

  -- Dig the main tunnel.
  local success, reason = dig_tunnel(length, place_torches, torch_interval)
  if not success then
    return false, "Failed to dig main tunnel: " .. (reason or "unknown error")
  end

  -- Dig the branches.

  -- First, calculate the number of branches based on the length and distance.
  local branch_count = math.floor(length / branch_distance)
  -- The branches are only 3 wide, so we can fit an extra branch even if we don't have enough length to fit the entire branch gap.
  if length % branch_distance >= 3 then
    branch_count = branch_count + 1
  end

  -- The turtle starts at the end of the main tunnel on its right side.
  -- We can be a bit more efficient by mining the first branch immediately at the end of the main tunnel.
  -- But we need to know how far the turtle is from the start of the main tunnel, so we can offset the 
  -- branch positions correctly.

  -- Since we consider the turtle's start facing to be north (-Z), we know that the branches on the right side of the tunnel
  -- are at X = 2, and the branches on the left side are at X = 0.
  -- We start the branches at Z = -4, and move deeper into the tunnel as we go.
  -- Thus, the formula for position.z should be `branch[n].z = -(4 + (n - 1) * branch_distance)`.
  --
  -- However, note that we are starting at the left side of the branch each time, so we need to
  -- adjust the starting Z position to -2 when on the left side.

  --- Calculate the position of a branch given its index and side.
  ---@param index integer The index of the branch (1-based).
  ---@param side integer The side of the branch (0 for left, 2 for right).
  ---@return stripmine.Position branch_pos The position of the branch.
  local function get_branch_pos(index, side)
    return {
      x = side,
      y = position.y,
      z = -((side == 2 and 4 or 2) + (index - 1) * branch_distance)
    }
  end

  -- And now, we can dig the branches.

  -- First, the right side, deep to shallow.
  for i = branch_count, 1, -1 do
    local branch_pos = get_branch_pos(i, 2) -- Right side is +X (2)
    if not move_to_yxz(branch_pos, function() end, function() return false end) then
      return false, "Failed to move to branch position at index " .. i .. " on the right side"
    end
    face(FACINGS.POSX) -- Face into the branch.

    -- Dig the branch.
    if not dig_tunnel(branch_length, place_torches, torch_interval) then
      return false, "Failed to dig branch at index " .. i .. " on the right side"
    end
  end

  -- Mine the left side, shallow to deep.
  for i = 1, branch_count do
    local branch_pos = get_branch_pos(i, 0) -- Left side is -X
    if not move_to_yxz(branch_pos, function() end, function() return false end) then
      return false, "Failed to move to branch position at index " .. i .. " on the left side"
    end
    face(FACINGS.NEGX) -- Face into the branch.

    -- Dig the branch.
    if not dig_tunnel(branch_length, place_torches, torch_interval) then
      return false, "Failed to dig branch at index " .. i .. " on the left side"
    end
  end

  -- Return home.
  return move_to_yxz({x=0, y=0,z=0}, function() end, function() return false end)
end

--#endregion Turtle Mining Utilities



-- Testing

local function lazy_moveto(pos)
  move_to_yxz(pos, function(pos) print(textutils.serialize(pos, {compact = true})) end, function(pos, reason)
    print("Failed to move to position: " .. textutils.serialize(pos, {compact = true}) .. ", reason: " .. reason)
    return false
  end)
end

--lazy_moveto({x=-1, y=0,z=-1})

--sleep(1)

local function lazy_mineto(pos)
  local success = mine_to(pos)
  if not success then
    print("Failed to mine to position: " .. textutils.serialize(pos, {compact = true}))
  else
    print("Successfully mined to position: " .. textutils.serialize(pos, {compact = true}))
  end
end

dig_stripmine(17, 10, 4, true, 5)

-- Return home
lazy_moveto({x=0, y=0,z=0})
face(FACINGS.NORTH)