-- my_looper.lua
-- A looper script with pages for navigation and basic functionality

-- Required libraries
local Pages = require("ui/pages") -- Import the ui.pages library
local sc = require("softcut") -- Use softcut for audio processing

-- Globals
local screen_is_dirty = true -- Flag to track when the screen needs updating
local pages

-- Looper State
local loop = {
  recording = false, -- Is the looper recording?
  playing = false,   -- Is the looper playing?
  length = 4,        -- Length of the loop in seconds
  position = 1       -- Playback position
}

-- Initialize script
function init()
  -- Setup pages
  pages = Pages.new({
    "Main",
    "Settings",
    "Info"
  })

  -- Initialize softcut
  audio.level_cut(1.0)
  audio.level_adc_cut(1)
  audio.level_eng_cut(0)

  for i = 1, 1 do
    sc.enable(i, 1)
    sc.buffer(i, 1)
    sc.loop(i, 1)
    sc.loop_start(i, 0)
    sc.loop_end(i, loop.length)
    sc.level(i, 1.0)
    sc.play(i, 0)
    sc.rec(i, 0)
    sc.position(i, 0)
    sc.rate(i, 1.0)
    sc.fade_time(i, 0.1)
  end

  clock.run(redraw_clock) -- Start the clock for periodic redraw checks
end

-- Redraw the screen based on the current page
function redraw()
  screen.clear()
  screen.move(64, 10)

  if pages.index == 1 then
    redraw_main_page()
  elseif pages.index == 2 then
    redraw_settings_page()
  elseif pages.index == 3 then
    redraw_info_page()
  end

  screen.update()
end

-- Write header for pages
function write_header(txt)
  screen.move(64, 5)
  screen.text_center(txt)
end

-- Redraw Main page
function redraw_main_page()
  write_header("Loops")
  screen.move(10, 20)
  screen.text("Recording: " .. (loop.recording and "Yes" or "No"))
  screen.move(10, 30)
  screen.text("Playing: " .. (loop.playing and "Yes" or "No"))
  screen.move(10, 40)
  screen.text("Length: " .. loop.length .. "s")
end

-- Redraw Settings page
function redraw_settings_page()
  write_header("Settings")
  screen.move(10, 20)
  screen.text("Loop Length: " .. loop.length .. "s")
end

-- Redraw Info page
function redraw_info_page()
  write_header("Info")
  screen.move(10, 20)
  screen.text("Loop Status:")
  screen.move(10, 30)
  screen.text("Recording: " .. (loop.recording and "Yes" or "No"))
  screen.move(10, 40)
  screen.text("Playing: " .. (loop.playing and "Yes" or "No"))
end

-- Redraw clock loop
function redraw_clock()
  while true do
    clock.sleep(1 / 45)
    if screen_is_dirty then
      redraw()
      screen_is_dirty = false -- Reset the dirty flag
    end
  end
end

-- Mark the screen as dirty
function screen_dirty()
  screen_is_dirty = true
end

-- Handle key presses
function key(n, z)
  if z == 1 then -- Only handle key press, not release
    if pages.index == 1 then
      if n == 2 then
        toggle_recording()
      elseif n == 3 then
        toggle_playing()
      end
    end

    if pages.index == 2 and n == 2 then
      loop.length = util.clamp(loop.length - 1, 1, 60) -- Decrease loop length
    elseif pages.index == 2 and n == 3 then
      loop.length = util.clamp(loop.length + 1, 1, 60) -- Increase loop length
    end

    screen_dirty()
  end
end

-- Handle encoder rotation
function enc(n, delta)
  if n == 2 then
    pages:set_index_delta(delta)
    screen_dirty()
  end
end

-- Toggle recording state
function toggle_recording()
  loop.recording = not loop.recording
  sc.rec(1, loop.recording and 1 or 0)
end

-- Toggle playback state
function toggle_playing()
  loop.playing = not loop.playing
  sc.play(1, loop.playing and 1 or 0)
end
