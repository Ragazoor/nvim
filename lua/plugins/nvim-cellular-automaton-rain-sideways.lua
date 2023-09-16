local M = {
  fps = 50,
  name = "rain-sideways",
  side_noise = false,
  disperse_rate = 3,
}

local frame

local cell_empty = function(grid, x, y)
  if x > 0 and x <= #grid and y > 0 and y <= #grid[x] and grid[x][y].char == " " then
    return true
  end
  return false
end

local swap_cells = function(grid, xOld, yOld, xNew, yNew)
  if xNew > #grid then
    local loopedX = xNew % #grid
    if yNew > 0 and yNew <= #grid[loopedX] and grid[loopedX][yNew].char == " " then
      grid[xOld][yOld], grid[loopedX][yNew] = grid[loopedX][yNew], grid[xOld][yOld]
    end
  elseif xNew > 0 and xNew <= #grid and yNew > 0 and yNew <= #grid[xNew] then
    grid[xOld][yOld], grid[xNew][yNew] = grid[xNew][yNew], grid[xOld][yOld]
  end
end

local getAbsoluteXY = function(grid, x, y)
  local xNew = x
  local yNew = y
  if x > #grid then
    xNew = x % #grid
  elseif x > #grid then
    xNew = #grid - x
  end

  if y < 1 then
    yNew = 1
  elseif y > #grid[xNew] then
    yNew = #grid[xNew]
  end
  return {xNew, yNew}
end

M.init = function(grid)
  frame = 1
end

M.update = function(grid)
  frame = frame + 1
  -- reset 'processed' flag
  for i = 1, #grid, 1 do
    for j = 1, #grid[i] do
      grid[i][j].processed = false
    end
  end
  local was_state_updated = false
  for x0 = #grid, 1, -1 do
    for i = 1, #grid[x0] do
      -- iterate through grid from bottom to top using snake move
      -- >>>>>>>>>>>>
      -- ^<<<<<<<<<<<
      -- >>>>>>>>>>>^
      local y0
      if (frame + x0) % 2 == 0 then
        y0 = i
      else
        y0 = #grid[x0] + 1 - i
      end
      local cell = grid[x0][y0]

      -- skip spaces and comments or already proccessed cells
      if cell.char == " " or string.find(cell.hl_group or "", "comment") or cell.processed == true then
        goto continue
      end

      cell.processed = true

      -- to introduce some randomness sometimes step aside
      if M.side_noise then
        local random = math.random()
        local side_step_probability = 0.05
        if random < side_step_probability then
          was_state_updated = true
          if cell_empty(grid, x0, y0 + 1) then
            swap_cells(grid, x0, y0, x0, y0 + 1)
          end
        elseif random < 2 * side_step_probability then
          was_state_updated = true
          if cell_empty(grid, x0, y0 - 1) then
            swap_cells(grid, x0, y0, x0, y0 - 1)
          end
        end
      end

      -- either go one down
      if cell_empty(grid, x0 + 1, y0) then
        swap_cells(grid, x0, y0, x0 + 1, y0)
        was_state_updated = true
      else
        -- or to the side
        local disperse_direction = cell.disperse_direction or ({ -1, 1 })[math.random(1, 2)]
        local last_pos = { x0, y0 }
        for d = 1, M.disperse_rate do
          local y = y0 + disperse_direction * d
          -- prevent teleportation
          if not cell_empty(grid, x0, y) then
            cell.disperse_direction = disperse_direction * -1
            break
          elseif last_pos[1] == x0 then
            swap_cells(grid, last_pos[1], last_pos[2], x0, y)
            was_state_updated = true
            last_pos = { x0, y }
          end
          if cell_empty(grid, x0 + 1, y) then
            swap_cells(grid, last_pos[1], last_pos[2], x0 + 1, y)
            was_state_updated = true
            last_pos = getAbsoluteXY(grid, x0 + 1, y)
          end
        end
      end
      ::continue::
    end
  end
  return was_state_updated
end

require("cellular-automaton").register_animation(M)
