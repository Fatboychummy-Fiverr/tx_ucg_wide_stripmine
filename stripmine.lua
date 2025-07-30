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
---@param move_fail_callback fun(pos:stripmine.Position, reason:string):boolean The callback function to call if a move fails. If no callback is present, the function will return immediately. If the callback returns a falsey value, the function will return immediately.
---@return boolean success Whether or not the turtle successfully moved to the position.
---@return string? reason The reason for failure, if any.
---@return stripmine.Position? final_position The final position of the turtle after the move, if failed.
local function move_to_yxz(offset, move_callback, move_fail_callback)
  ---@TODO Check over this function!
  ---@TODO Test this function!

  local function move(f)
    move_callback(position)
    local success, reason = f()
    if not success and move_fail_callback then
      return move_fail_callback(position, reason)
    end
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



--- Moves to a position, mining along its way (gravity-block protected).
---@param offset stripmine.Position The position to move to.
local function mine_to(offset)
  local fail_count = 0

  ---@TODO Check over this function!

  move_to_yxz(offset, dig_around, function()
    fail_count = fail_count + 1

    if turtle.dig() then
      fail_count = 0
    end

    if fail_count > 5 then
      return false
    end
    return true
  end)

  -- Dig the last position's up and down to finish the tunnel.
  dig_up_down()

  return true
end



--#endregion Turtle Mining Utilities