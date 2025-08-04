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

---@alias stripmine.Actions
---| "startup" # The turtle is still starting up.
---| "forward" # The turtle was moving forward
---| "back" # The turtle was moving back
---| "up" # The turtle was moving up
---| "down" # The turtle was moving down
---| "left" # The turtle was turning left
---| "right" # The turtle was turning right
---| "done" # The turtle has confirmed finished its task.



--#region Libraries

local argparse = (function()
  -- Minified version of:
  -- https://github.com/Fatboychummy-CC/Libraries/blob/main/simple_argparse.lua
  ---@diagnostic disable-next-line Editor be lagging
  local a={{pattern="^%-%-(%w+)%=(.+)$",func=function(b,c,d,e)c.options[d]=e end},{pattern="^%-%-(%w+)$",func=function(b,c,d)c.flags[d]=true end},{pattern="^%-(%w+)$",func=function(b,c,d)for f=1,#d do for g,h in pairs(b)do if h.short==d:sub(f,f)then c.flags[h.name]=true;break end end end end},{pattern="^(.+)$",func=function(b,c,e)table.insert(c.arguments,e)end}}local i=require"cc.expect".expect;local j={}function j.new_parser(k,l)i(1,k,"string")i(2,l,"string")local m={program_name=k,program_description=l,flags={},options={},arguments={}}function m.add_flag(n,o,p)i(1,n,"string","nil")i(2,o,"string")i(3,p,"string")m.flags[o]={name=o,short=n,description=p}end;function m.add_option(o,p,q)i(1,o,"string")i(2,p,"string")m.options[o]={name=o,description=p,default=q}end;function m.add_argument(d,p,r,q)i(1,d,"string")i(2,p,"string")i(3,r,"boolean")if r and type(q)~="nil"then error("Required arguments cannot have a default value.",2)end;table.insert(m.arguments,{name=d,description=p,required=r,default=q})end;function m.parse(s)local t={options={},flags={},arguments={}}for g,u in ipairs(s)do for g,v in ipairs(a)do local w=table.pack(u:match(v.pattern))if w.n>0 and w[1]~=nil then v.func(m.flags,t,table.unpack(w,1,w.n))break end end end;return t end;function m.usage()local t=m.program_name.." - "..m.program_description.."\n\n"t=t.."Usage: "..m.program_name.." [options]"if next(m.arguments)then t=t.." "for g,x in ipairs(m.arguments)do if x.required then t=t.."<"..x.name.."> "else t=t.."["..x.name.."] "end end end;t=t.."\n\n"if next(m.arguments)then t=t.."Arguments:\n"for g,x in ipairs(m.arguments)do t=t.."  "..x.name..": "..x.description;if x.default then t=t.." Default: "..tostring(x.default)end;t=t.."\n"end;t=t.."\n"end;if next(m.options)then t=t.."Options:\n"for g,y in pairs(m.options)do t=t.."  "if y.short then t=t.."-"..y.short..", "else t=t.."    "end;t=t.."--"..y.name..": "..y.description;if y.default then t=t.." Default: "..tostring(y.default)end;t=t.."\n"end;t=t.."\n"end;if next(m.flags)then t=t.."Flags:\n"for g,h in pairs(m.flags)do t=t.."  "if h.short then t=t.."-"..h.short..", "else t=t.."    "end;t=t.."--"..h.name..": "..h.description.."\n"end;t=t.."\n"end;return t end;return m end;return j
end)() --[[@as argparse]]

local filesystem = (function()
  -- Minified version of:
  -- https://github.com/Fatboychummy-CC/Libraries/blob/main/filesystem.lua
  ---@diagnostic disable-next-line Editor be lagging
  local a=require"cc.expect".expect;local b={path="",__SENTINEL={}}local c;local function d(e)return setmetatable({path=e and tostring(e)or""},c)end;local function f(g)if g.__SENTINEL~=b.__SENTINEL then error("Filesystem objects use ':' syntax.",3)end end;local function h(i,g)if type(g)~="string"and(type(g)=="table"and g.__SENTINEL~=b.__SENTINEL)then error(("bad argument #%d (expected string or filesystem, got %s)"):format(i,type(g)),3)end end;c={__index=b,__tostring=function(self)return self.path end,__concat=function(self,j)h(2,j)return d(fs.combine(tostring(self),tostring(j)))end,__len=function(self)return#tostring(self)end}function b:at(e)f(self)h(1,e)return self..e end;function b:absolute(e)f(self)h(1,e)return d(e)end;function b:programPath()f(self)local k=fs.getDir(shell.getRunningProgram())return d(k)end;function b:file(e)f(self)h(1,e)e=e or""local l=self..e;function l:readAll()f(self)local m,n=fs.open(tostring(self),"r")if not m then return nil,n end;local o=m.readAll()m.close()return o end;function l:write(p)f(self)a(1,p,"string")local m,n=fs.open(tostring(self),"w")if not m then error(n,2)end;m.write(p)m.close()end;function l:append(p)f(self)a(1,p,"string")local m,n=fs.open(tostring(self),"a")if not m then error(n,2)end;m.write(p)m.close()end;function l:open(q)f(self)a(1,q,"string")return fs.open(tostring(self),q)end;function l:delete()f(self)fs.delete(tostring(self))end;function l:size()f(self)return fs.getSize(tostring(self))end;function l:attributes()f(self)return fs.attributes(tostring(self))end;function l:moveTo(e)f(self)h(1,e)fs.move(tostring(self),tostring(e))end;function l:copyTo(e)f(self)h(1,e)fs.copy(tostring(self),tostring(e))end;function l:touch()f(self)if not fs.exists(tostring(self))then local m,n=fs.open(tostring(self),"w")if m then m.close()return end;error(n,2)end end;function l:serialize(p,r)f(self)self:write(textutils.serialize(p,r))end;function l:unserialize(s)f(self)local o=self:readAll()if not o then return s end;return textutils.unserialize(o)end;function l:nullify()f(self)local m,n=fs.open(tostring(self),"w")if m then m.close()return end;error(n,2)end;return l end;function b:mkdir(e)f(self)h(1,e)if e then fs.makeDir(fs.combine(tostring(self),tostring(e)))else fs.makeDir(tostring(self))end end;function b:rm(e)f(self)h(1,e)if e then fs.delete(fs.combine(tostring(self),tostring(e)))else fs.delete(tostring(self))end end;function b:exists(e)f(self)h(1,e)if not e then return fs.exists(tostring(self))end;return fs.exists(fs.combine(tostring(self),tostring(e)))end;function b:isDirectory(e)f(self)h(1,e)if not e then return fs.isDir(tostring(self))end;return fs.isDir(fs.combine(tostring(self),tostring(e)))end;function b:isFile(e)f(self)h(1,e)if not e then return not fs.isDir(tostring(self))end;return not fs.isDir(fs.combine(tostring(self),tostring(e)))end;function b:list(e)f(self)h(1,e)local t;if e then t=fs.list(fs.combine(tostring(self),tostring(e)))else t=fs.list(tostring(self))end;local u={}for v,l in ipairs(t)do table.insert(u,self:file(l))end;return u end;function b:parent()f(self)return d(fs.getDir(tostring(self)))end;return d()
end)() --[[@as FS_Root]]
local program_path = filesystem:programPath()
package.loaded["filesystem"] = filesystem

local minilogger = (function()
  -- Minified version of:
  -- https://github.com/Fatboychummy-CC/Libraries/blob/main/minilogger.lua
  ---@diagnostic disable-next-line Editor be lagging
  local a=require"cc.expect".expect;local b=require("filesystem"):programPath():at("logs")local c=b:file("latest.log")local d=b:file("old.log")local e=colors;local function f()if c:exists()then if d:exists()then d:delete()end;c:moveTo(d)c:nullify()end end;f()local g={LOG_LEVELS={DEBUG=0,OKAY=1,INFO=2,WARN=3,ERROR=4,FATAL=5}}local h=g.LOG_LEVELS;local i=h.INFO;local j=1024*256;local k=term.current()local l={}for m,n in pairs(h)do l[n]=m end;local o={}local function p(q)local r={}for s in q:gmatch("([^\n]*)\n?")do table.insert(r,s)end;return r end;local function t(u,v,w)if c:exists()and c:size()>=j then f()end;local x=l[u]local y=("[%s]:%s: "):format(x,v)local z=("\n[%s]:%s| "):format(x,(" "):rep(#v))c:append(y..table.concat(p(w),z).."\n")end;local function A(u,v,...)a(1,u,"number")a(2,v,"string")if u<i then return end;if o[v]then return end;if u<0 or u>5 or u%1~=0 then error("Invalid log level",2)end;local B=table.pack(...)for C=1,B.n do local D=B[C]B[C]=tostring(D)end;local E=term.redirect(k)local F=u==h.DEBUG and e.gray or e.white;local G=u==h.DEBUG and e.gray or u==h.OKAY and e.green or u==h.INFO and e.white or u==h.WARN and e.yellow or u==h.ERROR and e.red or u==h.FATAL and e.white or e.white;local H=u==h.FATAL and e.red or e.black;term.setTextColor(F)term.setBackgroundColor(H)term.write("[")term.setTextColor(G)term.write(l[u])term.setTextColor(F)term.write("]: "..v..": ")local w=table.concat(B," ",1,B.n)print(w)t(u,v,w)term.redirect(E)end;local function I(u,v,J,...)a(1,u,"number")a(2,v,"string")a(3,J,"string")A(u,v,J:format(...))end;function g.new(v)a(1,v,"string")local K={debug=function(...)A(h.DEBUG,v,...)end,debugf=function(J,...)I(h.DEBUG,v,J,...)end,okay=function(...)A(h.OKAY,v,...)end,okayf=function(J,...)I(h.OKAY,v,J,...)end,info=function(...)A(h.INFO,v,...)end,infof=function(J,...)I(h.INFO,v,J,...)end,warn=function(...)A(h.WARN,v,...)end,warnf=function(J,...)I(h.WARN,v,J,...)end,error=function(...)A(h.ERROR,v,...)end,errorf=function(J,...)I(h.ERROR,v,J,...)end,fatal=function(...)A(h.FATAL,v,...)end,fatalf=function(J,...)I(h.FATAL,v,J,...)end}return K end;function g.set_log_level(u)a(1,u,"number")if u<0 or u>4 or u%1~=0 then error("Invalid log level",2)end;i=u end;function g.set_log_window(L)a(1,L,"table")k=L;L.setBackgroundColor(e.black)L.clear()end;function g.set_colors(colors)a(1,colors,"table")e=colors end;function g.disable(v)a(1,v,"string")o[v]=true end;function g.enable(v)a(1,v,"string")o[v]=nil end;return g
end)() --[[@as minilogger]]

--#endregion Libraries



--#region Argument handling

local parser = argparse.new_parser("stripmine", "A 3x3 stripmining turtle program.")
parser.add_flag("d", "debug", "Enable debug logging.")
parser.add_flag("r", "resume", "Resume a previously saved stripmine run.")
parser.add_flag("t", "torches", "Place torches in the tunnel.")
parser.add_flag("h", "help", "Show this help message and exit.")
parser.add_option("torchinterval", "The distance between torches placed in the tunnel.", 10)
parser.add_option("length", "The length of the main tunnel to dig.", 16)
parser.add_option("branchlength", "The length of the branches to dig.", 8)
parser.add_option("branchdistance", "The distance between branches.", 5)
local parsed = parser.parse(arg)
local _args = {...}

if parsed.flags.help then
  textutils.pagedPrint(parser.usage())
  return
end

if parsed.flags.debug then
  minilogger.set_log_level(minilogger.LOG_LEVELS.DEBUG)
end



--#endregion Argument handling


local SAVE_FILE = "stripmine_state.lson"
local OLD_SAVE_FILE = "old_stripmine_state.lson"
local data_dir = program_path:at("data")
local state_file = data_dir:file(SAVE_FILE)
local old_state_file = data_dir:file(OLD_SAVE_FILE)

local term_x, term_y = term.getSize()
local ui_win = window.create(term.current(), 1, 1, term_x, term_y - 9)
local log_win = window.create(term.current(), 1, term_y - 8, term_x, 9)
minilogger.set_log_window(log_win)

local orig_term = term.current()

local log = minilogger.new("stripmine")
local r_log = minilogger.new("recovery")



--#region Turtle Mining Utilities

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

  [0] = "NORTH",
  [1] = "EAST",
  [2] = "SOUTH",
  [3] = "WEST"
}

--- Saved data.
local saved_data = {}
local no_save = false

--- The current facing of the turtle, north being `-Z` (0).
--- Note that this is relative to the turtle's starting facing (i.e: The starting direction of the turtle is considered to be 'north').
saved_data.facing = 0

--- The current position of the turtle in the world.
--- This is a relative position, starting at (0, 0, 0).
---@type stripmine.Position
saved_data.position = {x = 0, y = 0, z = 0}

--- We need to keep track of whether or not we are returning home, so we don't run the `checks` again.
saved_data.returning = false

--- Locks out history tracking while returning home (and back to the mine).
saved_data.history_lock = false

--- The amount of moves completed. Since the shape is deterministic, this is the only information we
--- actually need to save in order to restore the turtle's state after a reset.
---
--- However, we do keep track of a little extra data (the turtle's current *actual* position, for example),
--- since the turtle may be returning home or back to the mine.
saved_data.moves_completed = 0

--- We keep track of what row we are on in the mine, so we can offset our position correctly when we return back to the mine.
saved_data.mine_row = 0

--- The side of the mine that we are currently on.
--- Main being the main tunnel before the branches.
---@type "left"|"right"|"main"
saved_data.mine_side = "main"

--- Store the fuel level, so if we were moving during a reset, we can determine if the move succeeded.
saved_data.fuel_level = turtle.getFuelLevel()

--- Stores the last action the turtle performed, aids restoration of data like fuel_level.
---@type stripmine.Actions
saved_data.last_action = "startup"

--- Stores the last position before returning home.
---@type stripmine.Position
saved_data.last_position = {x = 0, y = 0, z = 0}



--- Simulates a movement in the given direction, returns the new position.
---@param direction "forward"|"back" The direction to simulate the movement in.
---@param n integer? The number of blocks to move in the given direction. Defaults to 1.
---@return stripmine.Position new_position The new position after the simulated movement.
local function simulate_movement(direction, n)
  local new_position = {x = saved_data.position.x, y = saved_data.position.y, z = saved_data.position.z}
  n = n or 1

  if direction == "forward" then
    if saved_data.facing == 0 then -- North, -Z
      new_position.z = new_position.z - n
    elseif saved_data.facing == 1 then -- East, +X
      new_position.x = new_position.x + n
    elseif saved_data.facing == 2 then -- South, +Z
      new_position.z = new_position.z + n
    elseif saved_data.facing == 3 then -- West, -X
      new_position.x = new_position.x - n
    end
  elseif direction == "back" then
    if saved_data.facing == 0 then -- North, -Z
      new_position.z = new_position.z + n
    elseif saved_data.facing == 1 then -- East, +X
      new_position.x = new_position.x - n
    elseif saved_data.facing == 2 then -- South, +Z
      new_position.z = new_position.z - n
    elseif saved_data.facing == 3 then -- West, -X
      new_position.x = new_position.x + n
    end
  end

  return new_position
end



--- Updates the turtle's position based on the current facing, and movement direction.
---@param direction "forward"|"back" The direction to update the position in.
local function update_position(direction)
  if direction == "forward" then
    if saved_data.facing == 0 then -- North, -Z
      saved_data.position.z = saved_data.position.z - 1
    elseif saved_data.facing == 1 then -- East, +X
      saved_data.position.x = saved_data.position.x + 1
    elseif saved_data.facing == 2 then -- South, +Z
      saved_data.position.z = saved_data.position.z + 1
    elseif saved_data.facing == 3 then -- West, -X
      saved_data.position.x = saved_data.position.x - 1
    end
  elseif direction == "back" then
    if saved_data.facing == 0 then -- North, -Z
      saved_data.position.z = saved_data.position.z + 1
    elseif saved_data.facing == 1 then -- East, +X
      saved_data.position.x = saved_data.position.x - 1
    elseif saved_data.facing == 2 then -- South, +Z
      saved_data.position.z = saved_data.position.z - 1
    elseif saved_data.facing == 3 then -- West, -X
      saved_data.position.x = saved_data.position.x + 1
    end
  end
end



local sl_log = minilogger.new("saveload")

--- Saves the current state of the turtle.
---@param action stripmine.Actions The action the turtle is currently performing.
local function save_state(action)
  if no_save then return end
  saved_data.last_action = action
  saved_data.fuel_level = turtle.getFuelLevel()

  state_file:serialize(saved_data, {compact=true})
  sl_log.debugf("%db m%d %s", state_file:size(), saved_data.moves_completed, saved_data.last_action)
end



--- Loads the saved state of the turtle, restoring missing data if needed.
local function load_state()
  local data = state_file:unserialize()

  if not data then
    error("No saved state found.", 0)
  end

  -- Verify the data has the required fields.
  if type(data) ~= "table" then
    error("Invalid turtle state data, expected a table.", 0)
  end
  if type(data.position) ~= "table" or not (data.position.x and data.position.y and data.position.z) then
    error("Invalid position data in turtle state.", 0)
  end
  if type(data.moves_completed) ~= "number" then
    error("Invalid moves_completed data in turtle state.", 0)
  end
  if type(data.mine_row) ~= "number" then
    error("Invalid mine_row data in turtle state.", 0)
  end
  if type(data.mine_side) ~= "string" then
    error("Invalid mine_side data in turtle state.", 0)
  end
  if type(data.fuel_level) ~= "number" then
    error("Invalid fuel_level data in turtle state.", 0)
  end
  if type(data.last_action) ~= "string" then
    error("Invalid last_action data in turtle state.", 0)
  end

  r_log.debugf("State was: %s", textutils.serialize(data))

  -- All checks pass, so we can safely restore the state.
  saved_data = data

  -- However, we also need to check if the turtle was in the middle of a move, and if so, check if it succeeded
  -- by comparing the saved fuel level with the actual fuel level.

  if data.last_action == "forward"
  or data.last_action == "back"
  or data.last_action == "up"
  or data.last_action == "down" then
    if data.fuel_level > turtle.getFuelLevel() then
      sl_log.info("Fuel level is lower than expected, assuming last move succeeded.")
      if data.last_action == "forward" or data.last_action == "back" then
        update_position(data.last_action)
      elseif data.last_action == "up" then
        saved_data.position.y = saved_data.position.y + 1
      elseif data.last_action == "down" then
        saved_data.position.y = saved_data.position.y - 1
      end
      saved_data.moves_completed = saved_data.moves_completed + 1
    end
  end

  -- Assume turns succeed. We have no way to check if it failed anyways!
  if data.last_action == "left" then
    saved_data.facing = (saved_data.facing - 1) % 4 -- Turn left
  elseif data.last_action == "right" then
    saved_data.facing = (saved_data.facing + 1) % 4 -- Turn right
  end
end



--- Predeclared function so we can use it in the movement functions.
---@type fun()
local checks



--- Moves the turtle forward, keeping track of its position. Returns the output of `turtle.forward()`.
---@return boolean success Whether or not the turtle successfully moved forward.
---@return string? reason The reason for failure, if any.
local function forward()
  save_state("forward")
  local success, reason = turtle.forward()
  if success then
    update_position("forward")
    if not saved_data.history_lock then
      saved_data.moves_completed = saved_data.moves_completed + 1
    end
  end
  save_state("done")

  checks()

  return success, reason
end



--- Moves the turtle back, keeping track of its position. Returns the output of `turtle.back()`.
---@return boolean success Whether or not the turtle successfully moved back.
---@return string? reason The reason for failure, if any.
local function back()
  save_state("back")
  local success, reason = turtle.back()
  if success then
    update_position("back")
    if not saved_data.history_lock then
      saved_data.moves_completed = saved_data.moves_completed + 1
      save_state("done")
    end
  end

  checks()

  return success, reason
end



--- Turns the turtle left, updating its facing direction.
---@return boolean success Whether or not the turtle successfully turned left.
---@return string? reason The reason for failure, if any.
local function turn_left()
  save_state("left")
  local success, reason = turtle.turnLeft()
  if success then
    saved_data.facing = (saved_data.facing - 1) % 4 -- Update facing direction, wrap around using modulo
    if not saved_data.history_lock then
      saved_data.moves_completed = saved_data.moves_completed + 1
      save_state("done")
    end
  end

  return success, reason
end



--- Turns the turtle right, updating its facing direction.
---@return boolean success Whether or not the turtle successfully turned right.
---@return string? reason The reason for failure, if any.
local function turn_right()
  save_state("right")
  local success, reason = turtle.turnRight()
  if success then
    saved_data.facing = (saved_data.facing + 1) % 4 -- Update facing direction, wrap around using modulo
    if not saved_data.history_lock then
      saved_data.moves_completed = saved_data.moves_completed + 1
      save_state("done")
    end
  end

  return success, reason
end



--- Moves the turtle up, keeping track of its position. Returns the output of `turtle.up()`.
---@return boolean success Whether or not the turtle successfully moved up.
---@return string? reason The reason for failure, if any.
local function up()
  save_state("up")
  local success, reason = turtle.up()
  if success then
    saved_data.position.y = saved_data.position.y + 1
    if not saved_data.history_lock then
      saved_data.moves_completed = saved_data.moves_completed + 1
      save_state("done")
    end
  end

  checks()

  return success, reason
end



--- Moves the turtle down, keeping track of its position. Returns the output of `turtle.down()`.
---@return boolean success Whether or not the turtle successfully moved down.
---@return string? reason The reason for failure, if any.
local function down()
  save_state("down")
  local success, reason = turtle.down()
  if success then
    saved_data.position.y = saved_data.position.y - 1
    if not saved_data.history_lock then
      saved_data.moves_completed = saved_data.moves_completed + 1
      save_state("done")
    end
  end

  checks()

  return success, reason
end



--- Face a specific direction.
---@param direction stripmine.Facing The direction to face, represented as an integer.
---@return boolean success Whether or not the turtle successfully turned to face the direction.
---@return string? reason The reason for failure, if any.
local function face(direction)
  direction = direction % 4 -- Ensure the direction is within the range of 0-3

  -- If already facing the direction, do nothing.
  if saved_data.facing == direction then
    return true
  end

  -- If it's quickest to turn left, do so.
  if (saved_data.facing - 1) % 4 == direction then
    return turn_left()
  end

  -- Otherwise, turn right until facing the direction.
  -- This will either turn us once to the right, or two times to be facing rear.
  repeat
    local success, reason = turn_right()
    if not success then
      return false, reason
    end
  until saved_data.facing == direction

  return true
end



--- Locate the first empty slot in an inventory.
---@param list ccTweaked.peripheral.itemList The list of items in the inventory.
---@param inv ccTweaked.peripheral.Inventory The inventory to search in.
---@return integer? slot The slot number of the first empty slot, or nil if no empty slot is found.
local function find_empty_slot(list, inv)
  for slot = 1, inv.size() do
    if not list[slot] then
      return slot
    end
  end
end



--- Moves an item in a given inventory to the first slot, moving that item out of the way if needed.
---@param list ccTweaked.peripheral.itemList The list of items in the inventory.
---@param inv ccTweaked.peripheral.Inventory The inventory to move the item in.
---@param slot integer The slot of the item to move.
---@return boolean success Whether or not the item was successfully moved.
local function move_to_one(list, inv, slot)
  if not list[slot] then
    return false
  end

  -- If the item is already in the first slot, do nothing.
  if slot == 1 then
    return true
  end

  -- Check if an item is already in the first slot.
  if list[1] then
    -- If so, we need to move it out of the way.
    local empty_slot = find_empty_slot(list, inv)
    if not empty_slot then
      return false -- No empty slot found, can't move the item.
    end

    -- Move the item in the first slot to the empty slot.
    inv.pushItems(peripheral.getName(inv), 1, nil, empty_slot)
  end

  -- Now we can move the item to the first slot.
  inv.pushItems(peripheral.getName(inv), slot, nil, 1)
  return true
end



--- Grabs up to a 64 stack of torches.
---@return boolean success Whether or not the turtle successfully grabbed torches.
local function grab_torches()
  -- Check how many torches we have currently.
  local torch_count = 0
  for i = 1, 16 do
    local detail = turtle.getItemDetail(i)
    if detail and detail.name == "minecraft:torch" then
      torch_count = torch_count + detail.count
    end
  end

  if torch_count >= 32 then
    log.debug("Already have enough torches, skipping grab.")
    return true -- We already have enough torches, no need to grab more.
  end

  ---@return boolean success Whether or not the turtle successfully grabbed torches.
  local function _grab(dir)
    if not peripheral.hasType(dir, "inventory") then
      return false
    end

    local inv = peripheral.wrap(dir) --[[@as ccTweaked.peripheral.Inventory?]]
    if not inv then return false end
    local list = inv.list()
    for slot, item in pairs(list) do
      if item.name == "minecraft:torch" and item.count > 0 then
        move_to_one(list, inv, slot)
        if dir == "top" then
          turtle.suckUp()
        else
          turtle.suck()
        end
        log.infof("Grabbed %d torches from %s", item.count, dir)
        -- After grabbing, we can check if we have enough torches.
        torch_count = torch_count + item.count
        if torch_count >= 32 then
          log.debug("Grabbed enough torches, stopping.")
          return true -- We have enough torches now, so we can stop grabbing.
        end
      end
    end

    return false
  end

  -- Prefer grabbing from the top.
  if not _grab("top") then
    return _grab("front") -- Try to grab from the front if top is not available.
  end

  return true
end



--- Refuels the turtle from inventories at the home position (0,0,0).
---@param minimum_fuel integer The minimum amount of fuel the turtle should have after refueling.
---@return boolean can_continue Whether or not the turtle can continue after refueling.
local function refuel(minimum_fuel)
  if saved_data.position.x ~= 0 or saved_data.position.y ~= 0 or saved_data.position.z ~= 0 then
    return false
  end

  log.info("Refueling...")

  -- List of items that can be used as fuel, in order that we prefer them to be used.
  ---@type string[]
  local fuel_items = {
    "minecraft:coal_block",
    "minecraft:lava_bucket",
    "minecraft:blaze_rod",
    "minecraft:charcoal",
    "minecraft:coal",
    "minecraft:.*planks",
    "minecraft:.*log",
    "minecraft:stick",
  }
  local fuel_item_lookup = {}
  for _, item in ipairs(fuel_items) do
    fuel_item_lookup[item] = true
  end

  --- Attempts to refuel by 'eating' all fuel items in the turtle's inventory.
  local function eat()
    for i = 1, 16 do
      local detail = turtle.getItemDetail(i)
      if detail and fuel_item_lookup[detail.name] then
        turtle.select(i)
        turtle.refuel()
        log.infof("Refueled with %d %s", detail.count, detail.name)
      end
    end
    turtle.select(1)
  end


  --- Attempts to refuel the turtle from the given side.
  ---@param side "top"|"front" The side to refuel from.
  ---@return boolean success Whether or not the turtle successfully refueled.
  local function _refuel(side)
    -- If the given side is not a valid inventory, we can't refuel from it.
    if not peripheral.hasType(side, "inventory") then
      return false
    end

    -- Get the inventory on the given side.
    local inv = peripheral.wrap(side) --[[@as ccTweaked.peripheral.Inventory?]]
    if not inv then
      return false
    end

    -- Get the list, and find fuel items.
    local list = inv.list()
    for slot, item in pairs(list) do
      for _, fuel in ipairs(fuel_items) do
        if item.name:match(fuel) then
          -- Valid fuel item, move it to the first slot, then call `turtle.suck()` to pull it into the turtle's inventory.
          if move_to_one(list, inv, slot) then
            if side == "top" then turtle.suckUp() else turtle.suck() end
          end
        end
      end
    end

    -- Eat fuel items that were pulled into the turtle's inventory.
    eat()

    log.infof("Refueled from %s, current fuel level: %d", side, turtle.getFuelLevel())

    -- Check if we have enough fuel to continue.
    return turtle.getFuelLevel() >= minimum_fuel
  end

  -- Prefer refuelling from the top.
  if not _refuel("top") then
    return _refuel("front")
  end
  return true
end



--- Move using the given function `f` (i.e: forward, etc), calling the callbacks as needed.
---@param f fun():boolean, string The function to call to move the turtle.
---@param move_callback fun(pos:stripmine.Position):nil The callback function to call before each move.
---@param move_fail_callback nil|fun(pos:stripmine.Position, reason:string):boolean The callback function to call if a move fails. If no callback is present, the function will return immediately. If the callback returns a falsey value, the function will return immediately.
local function move(f, move_callback, move_fail_callback)
  move_callback(saved_data.position)

  local success, reason = f()
  if not success and move_fail_callback then ---@cast reason -nil
    return move_fail_callback(saved_data.position, reason)
  end

  return success, reason
end



--- Aligns the X axis of the turtle to the given position.
---@param offset integer The X coordinate to align to.
local function align_x(offset, move_callback, move_fail_callback)
  while saved_data.position.x < offset do
    face(FACINGS.POSX)
    local ok, err = move(forward, move_callback, move_fail_callback)
    if not ok then
      return false, err, saved_data.position
    end
  end
  while saved_data.position.x > offset do
    face(FACINGS.NEGX)
    local ok, err = move(forward, move_callback, move_fail_callback)
    if not ok then
      return false, err, saved_data.position
    end
  end
  return true
end



--- Aligns the Z axis of the turtle to the given position.
---@param offset integer The Z coordinate to align to.
local function align_z(offset, move_callback, move_fail_callback)
  while saved_data.position.z < offset do
    face(FACINGS.POSZ)
    local ok, err = move(forward, move_callback, move_fail_callback)
    if not ok then
      return false, err, saved_data.position
    end
  end
  while saved_data.position.z > offset do
    face(FACINGS.NEGZ)
    local ok, err = move(forward, move_callback, move_fail_callback)
    if not ok then
      return false, err, saved_data.position
    end
  end
  return true
end



--- Aligns the Y axis of the turtle to the given position.
---@param offset integer The Y coordinate to align to.
local function align_y(offset, move_callback, move_fail_callback)
  while saved_data.position.y < offset do
    local ok, err = move(up, move_callback, move_fail_callback)
    if not ok then
      return false, err, saved_data.position
    end
  end
  while saved_data.position.y > offset do
    local ok, err = move(down, move_callback, move_fail_callback)
    if not ok then
      return false, err, saved_data.position
    end
  end
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
  log.debugf("YXZ --> %d %d %d", offset.x, offset.y, offset.z)

  -- Align Y first, then X, then Z.
  local success, reason, final_pos = align_y(offset.y, move_callback, move_fail_callback)
  if not success then
    return false, reason, final_pos
  end

  success, reason, final_pos = align_x(offset.x, move_callback, move_fail_callback)
  if not success then
    return false, reason, final_pos
  end

  success, reason, final_pos = align_z(offset.z, move_callback, move_fail_callback)
  if not success then
    return false, reason, final_pos
  end

  -- Great success!
  return true
end



--- Moves to a position relative to the turtle's starting position, moving along the Y axis first, then the Z and X axes.
---@param offset stripmine.Position The offset to move to.
---@param move_callback fun(pos:stripmine.Position):nil The callback function to call before each move.
---@param move_fail_callback nil|fun(pos:stripmine.Position, reason:string):boolean The callback function to call if a move fails. If no callback is present, the function will return immediately. If the callback returns a falsey value, the function will return immediately.
---@return boolean success Whether or not the turtle successfully moved to the position.
---@return string? reason The reason for failure, if any.
---@return stripmine.Position? final_position The final position of the turtle after the move, if failed.
local function move_to_yzx(offset, move_callback, move_fail_callback)
  log.debugf("YZX --> %d %d %d", offset.x, offset.y, offset.z)

  -- Align Y first, then Z, then X.
  local success, reason, final_pos = align_y(offset.y, move_callback, move_fail_callback)
  if not success then
    return false, reason, final_pos
  end

  success, reason, final_pos = align_z(offset.z, move_callback, move_fail_callback)
  if not success then
    return false, reason, final_pos
  end

  success, reason, final_pos = align_x(offset.x, move_callback, move_fail_callback)
  if not success then
    return false, reason, final_pos
  end

  -- Great success!
  return true
end

--- Simple method to move the turtle to 0,0,0 and face south (towards the storage chest).
---@return boolean success Whether or not the turtle successfully moved to the home position.
---@return string? error_message If it failed.
---@return stripmine.Position? final_position The final position of the turtle after the move, if failed.
local function return_home()
  log.info("Returning home...")

  -- If we're digging the middle row (going towards the center), we need to move to the north.
  if saved_data.mine_row == 2 then
    if saved_data.mine_side == "right" then
      -- Move to the north of the current postion.
      local success, reason = move_to_yxz({x = saved_data.position.x, y = saved_data.position.y, z = saved_data.position.z - 1}, function() end)
      if not success then
        return false, reason, saved_data.position
      end
    else
      -- Move to the south of the current position.
      local success, reason = move_to_yxz({x = saved_data.position.x, y = saved_data.position.y, z = saved_data.position.z + 1}, function() end)
      if not success then
        return false, reason, saved_data.position
      end
    end
  end

  -- Move to the home position (0,0,0).
  local success, reason, final_pos = move_to_yxz({x = 0, y = 0, z = 0}, function() end, function() return false end)
  if not success then ---@cast reason -nil
    return false, reason, final_pos
  end

  log.okay("Returned home successfully.")

  -- Face south (towards the storage chest).
  return face(FACINGS.SOUTH)
end



--- Dumps the turtle's inventory into the storage chest at the home position (0,0,0).
local function dump_inventory()
  log.info("Dumping inventory...")
  -- Ensure we're at the home position.
  if saved_data.position.x ~= 0 or saved_data.position.y ~= 0 or saved_data.position.z ~= 0 then
    return false, "Turtle is not at the home position (0,0,0), cannot dump inventory."
  end

  while not peripheral.hasType("front", "inventory") do
    log.warn("No storage chest found in front of the turtle, waiting 5 seconds before trying again.")
    sleep(5)
  end

  -- For each slot with an item, drop it into the storage chest.
  for i = 1, 16 do
    local detail = turtle.getItemDetail(i)
    if detail and detail.name ~= "minecraft:torch" then
      turtle.select(i)
      -- Keep attempting to drop the item until it succeeds.
      while not turtle.drop() do
        log.error("Storage chest is likely full... Waiting 5 seconds before trying again.")
        sleep(5)
      end
    end
  end

  turtle.select(1)
end


--- Runs all checks, returns home for fuel or full inventory if needed.
checks = function()
  -- We don't need to run the inventory/fuel checks if we are already returning home.
  if saved_data.returning then return end
  -- We also don't need to run the checks if we are recovering history.
  if saved_data.history_lock then return end

  local manhattan_distance = math.abs(saved_data.position.x) + math.abs(saved_data.position.y) + math.abs(saved_data.position.z)
  local fuel = turtle.getFuelLevel()
  local current_facing = saved_data.facing
  local current_position = {x = saved_data.position.x, y = saved_data.position.y, z = saved_data.position.z}

  --- Returns the turtle back to the position it was at before returning home.
  local function go_back()
    if saved_data.mine_row == 2 then
      if saved_data.mine_side == "right" then
        -- We need to move one to the north of the current position, then return to the current position.
        assert(move_to_yzx({x = current_position.x, y = current_position.y, z = current_position.z - 1}, function() end))
      else
        -- We need to move one to the south of the current position, then return to the current position.
        assert(move_to_yzx({x = current_position.x, y = current_position.y, z = current_position.z + 1}, function() end))
      end
    end
    assert(move_to_yzx(current_position, function() end))
    assert(face(current_facing)) -- Face south (towards the storage chest).
  end

  --- Returns home, drops off items, refuels, collects torches, then returns back to the current position.
  local function home_trip()
    saved_data.returning = true
    saved_data.history_lock = true -- Lock out history tracking while returning home.
    assert(return_home(), "Failed to return home.")
    saved_data.returning = false
    dump_inventory() -- Dump the inventory into the storage chest.
    refuel(manhattan_distance + 100) -- Refuel to at least the distance we need to travel, plus a buffer of 100 fuel.
    while parsed.flags.torches and not grab_torches() do -- Grab torches from the storage chest.
      log.warn("Failed to grab torches, retrying in 5 seconds...")
      sleep(5)
    end
    go_back() -- Return to the position we were at before.
    saved_data.history_lock = false -- Unlock history tracking after returning home.
  end

  -- We keep a buffer of at least 10 extra fuel, in case we somehow miscalculated.
  if fuel <= manhattan_distance + 10 then
    log.warn("Low fuel level, returning home to refuel.")
    home_trip()
  end

  -- We also always make sure to select the first slot, so the presence of an item
  -- in the 16th slot means that the inventory is full (as the inventory fills `<selected_slot>`, then `<selected_slot> + 1`, and so on)
  if turtle.getItemCount(16) > 0 then
    log.warn("Inventory is full, returning home to dump items.")
    home_trip()
  end
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

  log.debugf("Mining to position: %d %d %d", offset.x, offset.y, offset.z)

  --- Counts the number of failed movements. If we fail to move too many times, we give up so we don't infinitely loop.
  local fail_count = 0
  local mined = 0
  local first = true

  --- Called before the turtle moves in each position.
  --- 1. Digs around the turtle.
  --- 2. Places a torch if needed.
  local function mine_move_callback()
    if first then
      first = false
      turtle.dig()
    else
      dig_around()
    end

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

  log.debugf("Digging tunnel of length %d", length)

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
    saved_data.mine_row = i
    log.debugf("Digging row %d", i)
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

  saved_data.mine_row = 0 -- Reset the mine row after digging the tunnel.

  return true
end



--- Digs a stripmine tunnel, with branches.
---@param length integer The length of the main tunnel.
---@param branch_length integer The length of the branches.
---@param branch_distance integer? The distance between branches. This includes the width of each branch. Defaults to 5 (one block gap between branches).
---@param place_torches boolean? Whether or not to place torches in the tunnel. Defaults to false.
---@param torch_interval integer? The interval at which to place torches. Defaults to 10.
local function dig_stripmine(length, branch_length, branch_distance, place_torches, torch_interval)
  branch_distance = branch_distance or 5
  torch_interval = torch_interval or 10

  log.debugf("Digging stripmine of length %d, branch length %d, branch distance %d", length, branch_length, branch_distance)
  log.debugf("Place torches: %s, Torch interval: %d", place_torches and "Yes" or "No", torch_interval)

  -- Dig the main tunnel.
  log.debugf("Digging main tunnel")
  local success, reason = dig_tunnel(length, place_torches, torch_interval)
  if not success then
    error("Failed to dig main tunnel: " .. (reason or "unknown error"), 0)
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
      y = saved_data.position.y,
      z = -((side == 2 and 4 or 2) + (index - 1) * branch_distance)
    }
  end

  -- And now, we can dig the branches.

  -- First, the right side, deep to shallow.
  saved_data.mine_side = "right"
  for i = branch_count, 1, -1 do
    log.debugf("Digging branch %d on the right side", i)
    local branch_pos = get_branch_pos(i, 2) -- Right side is +X (2)
    if not move_to_yxz(branch_pos, function() end, function() return false end) then
      error("Failed to move to branch position at index " .. i .. " on the right side", 0)
    end
    face(FACINGS.POSX) -- Face into the branch.

    -- Dig the branch.
    if not dig_tunnel(branch_length, place_torches, torch_interval) then
      error("Failed to dig branch at index " .. i .. " on the right side", 0)
    end
  end

  -- Mine the left side, shallow to deep.
  saved_data.mine_side = "left"
  for i = 1, branch_count do
    log.debugf("Digging branch %d on the left side", i)
    local branch_pos = get_branch_pos(i, 0) -- Left side is -X
    if not move_to_yxz(branch_pos, function() end, function() return false end) then
      error("Failed to move to branch position at index " .. i .. " on the left side", 0)
    end
    face(FACINGS.NEGX) -- Face into the branch.

    -- Dig the branch.
    if not dig_tunnel(branch_length, place_torches, torch_interval) then
      error("Failed to dig branch at index " .. i .. " on the left side", 0)
    end
  end

  -- Return home.
  success, reason = move_to_yxz({x=0, y=0,z=0}, function() end, function() return false end)
  if not success then
    error("Failed to return home after digging stripmine: " .. (reason or "unknown error"), 0)
  end
end



--#endregion Turtle Mining Utilities

--#region Main Program

--- Basic user interface to display simple data about the turtle's state.
local function ui()
  term.redirect(ui_win)
  ui_win.setVisible(false)
  ui_win.clear()

  local used_slots = 0
  local total_items = 0
  for i = 1, 16 do
    local detail = turtle.getItemDetail(i)
    if detail then
      used_slots = used_slots + 1
      total_items = total_items + detail.count
    end
  end

  term.setCursorPos(1, 1)
  if used_slots >= 14 then
    term.setTextColor(colors.red)
  elseif used_slots >= 9 then
    term.setTextColor(colors.yellow)
  end
  term.write(("Storage: %d (%d)"):format(used_slots, total_items))

  term.setCursorPos(1, 2)
  local manhattan_distance = math.abs(saved_data.position.x) + math.abs(saved_data.position.y) + math.abs(saved_data.position.z)
  local fuel = turtle.getFuelLevel()
  if fuel <= manhattan_distance + 30 then
    term.setTextColor(colors.red)
  elseif fuel <= manhattan_distance + 100 then
    term.setTextColor(colors.yellow)
  else
    term.setTextColor(colors.white)
  end
  term.write(("Fuel   : %d/%d"):format(turtle.getFuelLevel(), turtle.getFuelLimit()))

  term.setCursorPos(1, 3)
  term.setTextColor(colors.white)
  term.write(("Pos    : %d %d %d"):format(saved_data.position.x, saved_data.position.y, saved_data.position.z))

  local facing = ("Facing : %s"):format(FACINGS[saved_data.facing] or "Unknown")
  term.setCursorPos(term_x - #facing, 3)
  term.write(facing)

  local status_message = saved_data.returning and "Returning Home" or saved_data.history_lock and "Returning to Mine" or "Mining"
  term.setCursorPos(term_x - #status_message, 1)
  term.write(status_message)

  term.setCursorPos(1, 4)
  term.setTextColor(colors.gray)
  term.write(('\x8c'):rep(term_x))
  term.setTextColor(colors.white)

  ui_win.setVisible(true)
end



--- Loads the turtle's saved state, and prepares for simulation of movements until the turtle's internal state matches the loaded state.
local function prepare_load()
  load_state()
  local cached_position = {x = saved_data.position.x, y = saved_data.position.y, z = saved_data.position.z}
  local cached_facing = saved_data.facing

  local old_turtle = turtle
  _G.turtle = nil -- Remove the turtle from the global namespace to prevent accidental use.
  local was_locked = saved_data.history_lock -- Save the current history lock state.
  r_log.debug("History locked -- we were returning home or to the mine.")
  saved_data.history_lock = true -- Lock the history to prevent it from being modified while we simulate movements.
  no_save = true -- Disable saving while we simulate movements.

  local recover

  --- If we were in the process of returning home, we need to restore the turtle's actual state, so simulate returning home,
  --- then returning to the mine.
  local function extended_recover()
    r_log.info("Extended recovery active")
    parallel.waitForAny(
      return_home,
      function()
        while true do
          os.pullEvent("turtle_response")
          if saved_data.position.x == cached_position.x and
             saved_data.position.y == cached_position.y and
             saved_data.position.z == cached_position.z and
             saved_data.facing == cached_facing then
            r_log.okay("Returned to the mine successfully.")

            -- We need to recover mid return, so that the position is correct.
            recover(true)
          end
        end
      end
    )
  end

  recover = function(override)
    r_log.info("Recovering...")
    if was_locked and not override then
      -- We were returning home (or returning back from the mine)!
      return extended_recover()
    end

    saved_data.history_lock = was_locked -- Restore the history lock state.
    no_save = false -- Re-enable saving.

    turtle = old_turtle
    saved_data.moves_completed = saved_data.moves_completed - 1

    r_log.okay("Recovery complete.")
  end

  local fake_moves = 0
  local function fake_move()
    fake_moves = fake_moves + 1
    r_log.infof("sim: %d/%d", fake_moves, saved_data.moves_completed)
    if fake_moves >= saved_data.moves_completed then
      recover()
    end
    return true
  end

  -- Reset the turtle's data so it can simulate appropriately.
  saved_data.position.x = 0
  saved_data.position.y = 0
  saved_data.position.z = 0
  saved_data.facing = 0 -- Facing north by default.

  -- Overrides all turtle functions to just return true, simulating everything being successful.
  local _turtle = setmetatable({}, {
    __index = function()
      return function() return true end
    end
  })
  -- Override the turtle's movement functions to simulate movements without actually moving.
  _turtle.forward = fake_move
  _turtle.back = fake_move
  _turtle.up = fake_move
  _turtle.down = fake_move
  _turtle.turnLeft = fake_move
  _turtle.turnRight = fake_move

  _turtle.getItemDetail = function(i)
    if i == 1 then return {name = "minecraft:torch", count = 64} end
    if i == 16 then return nil end -- do not trigger a return home.
  end
  _turtle.getFuelLevel = function()
    return 10000 -- Simulate a high fuel level.
  end
  _turtle.getFuelLimit = function()
    return 10000
  end

  _G.turtle = _turtle

  r_log.info("Simulation needs", saved_data.moves_completed)
end



local startup_folder = filesystem:absolute("startup")
local recovery_file = startup_folder:file("99999_fatboychummy_stripmine_recovery.lua")

--- Builds the recovery program.
local function build_recovery_program()
  if not startup_folder:isDirectory() then
    startup_folder:mkdir()
  end

  recovery_file:write(("shell.run('%s %s -r')"):format(
    shell.getRunningProgram(),
    table.concat(_args, ' ')
  ))
end



--- Destroys the recovery program.
local function destroy_recovery_program()
  if recovery_file:exists() then
    recovery_file:delete()
  end
end



local function main()
  turtle.select(1) -- Ensure we start with the first slot selected.

  if turtle.getFuelLevel() == 0 then
    face(FACINGS.SOUTH)
    refuel(1)
    face(FACINGS.NORTH)
    saved_data.moves_completed = 0
  end

  log.info("Starting...")
  if parsed.flags.debug then
    log.info("Debug mode enabled")
  end
  log.infof("Length: %d", parsed.options.length or 16)
  log.infof("Branch length: %d", parsed.options.branchlength or 8)
  log.infof("Branch distance: %d", parsed.options.branchdistance or 4)
  if parsed.flags.torches then
    log.info("Torches enabled")
    log.infof("Torch interval: %d", parsed.options.torchinterval or 10)
  end
  sleep(2) -- Allow user to see the initial messages.

  if parsed.flags.resume then
    r_log.info("Preparing system for simulation of previous state...")
    prepare_load()
    r_log.info("Simulation of previous state prepared, starting recovery...")
  else
    build_recovery_program()
  end

  dig_stripmine(
    parsed.options.length or 16,
    parsed.options.branchlength or 8,
    parsed.options.branchdistance or 4,
    parsed.flags.torches,
    parsed.options.torchinterval or 10
  )
  --dig_stripmine(17, 10, 4, true, 5)

  -- After finishing, return home and dump the inventory.
  return_home()
  dump_inventory()
  face(FACINGS.NORTH)

  -- Destroy the recover program, as we no longer need it.
  destroy_recovery_program()
  state_file:delete() -- Delete the state file, as we no longer need it.
end

local function handle_ui()
  while true do
    ui()
    sleep(1)
  end
end


local ok, err = xpcall(
  parallel.waitForAny,
  debug.traceback,
    main,
    handle_ui
)

if not ok then ---@cast err -nil
  log.fatalf("An error occurred:\n%s", err)
  log.fatal("Please report this issue to the developer.")
  log.fatal("Attempting to return home...")
  pcall(return_home)
  pcall(destroy_recovery_program)
  pcall(old_state_file.delete, old_state_file)
  pcall(state_file.moveTo, state_file, old_state_file)

  term.redirect(orig_term)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  term.setCursorPos(1, 1)
  print("An error occurred while running the program:\n")
  printError(err:match("^(.-)\n"))
  print()
  print("Check", program_path .. "logs/latest.log", "for more details.")
end


--#endregion Main Program