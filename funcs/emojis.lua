local flags = {
  "no-crop", "no-scale", "not-compressed", "mipmap", "linear-minification", "linear-mip-level", "group=icon"
}

for ModName, version in pairs(mods) do
  if string.find(ModName, "chat_emojis_") then   -- = for Example: chat_emojis_ArsStels
    require("__" .. ModName .. "__/emotes_list") -- = for Example: __chat_emojis_ArsStels__/emotes_list.lua
    _G[ModName] = Emojis

    -- # Переключение отображения логов эмодзи в зависимости от настроек
    if settings.startup["chat_emoji_startup_log_activate"].value == true then
      log(serpent.block(_G[ModName]))
      log(ModName .. " version " .. version)       -- = log mod name
    end

    for i = 1, #_G[ModName] do
      local emojiName = _G[ModName][i].name
      local width = _G[ModName][i].width
      local height = _G[ModName][i].height
      if width > 1620 or height > 2160 then
        error(
          "\nOver the limited image size.\nERROR_CODE: 1\nYou have exceeded the maximum image size. Emoji should not exceed a resolution of 1620x2160. Your resolution:\n" ..
          width .. "x" .. height .. " for " .. emojiName, 2)
      end

      data:extend({
        {
          type = "sprite",
          name = emojiName,
          filename = "__" .. ModName .. "__/emotes/" .. emojiName .. ".png",
          width = width,
          height = height,
          flags = flags,
          priority = "no-atlas"
        }
      })

      local widthFragmentCount = math.ceil(width / 60)
      local heightFragmentCount = math.ceil(height / 60)
      local fragments = widthFragmentCount * heightFragmentCount
      _G[ModName][i].widthFragmentCount = widthFragmentCount
      _G[ModName][i].heightFragmentCount = heightFragmentCount
      _G[ModName][i].fragments = fragments

      local x = 0
      local y = 0
      local ostatokWidth = width % 60
      local ostatokHeight = height % 60
      local actualWidth = 60
      local actualHeight = 60
      --local shiftX = 0
      --local shiftY = 0

      for k = 1, fragments do
        if ((k % widthFragmentCount) == 0) and (ostatokWidth ~= 0) then
          actualWidth = ostatokWidth
          --shiftX = (0 - math.ceil((60 - ostatokWidth) / 2)) / 1.85
        end
        if (k == (widthFragmentCount * (heightFragmentCount - 1) + 1)) and (ostatokHeight ~= 0) then
          actualHeight = ostatokHeight
          --shiftY = (0 - math.ceil((60 - ostatokHeight) / 2)) / 1.85
        end
        data:extend({
          {
            type = "sprite",
            name = emojiName .. "_f" .. k,
            filename = "__" .. ModName .. "__/emotes/" .. emojiName .. ".png",
            x = x,
            y = y,
            width = actualWidth,
            height = actualHeight,
            maximal_width = 60,
            maximal_height = actualHeight,
            --shift = {shiftX, shiftY},
            flags = { "icon" },
            priority = "no-atlas"
          }
        })

        if (k % widthFragmentCount) == 0 then
          x = 0
          y = y + 60
          actualWidth = 60
          --shiftX = 0
        else
          x = x + 60
        end
      end
    end

    local function make_button_style(name, filename, width, height, scale)
      local graphics_set = { filename = filename, natural_size = { width * scale, height * scale }, size = { width, height } }
      data.raw["gui-style"]["default"][name] = {
        type = "button_style",
        width = width * scale,
        height = height * scale,
        clicked_graphical_set = graphics_set,
        default_graphical_set = graphics_set,
        disabled_graphical_set = graphics_set,
        hovered_graphical_set = graphics_set,
      }
    end

    local button_scale = settings.startup["chat_emoji_gui_emoji_size"].value
    for _, emojiData in ipairs(_G[ModName]) do
      local emojiNaturalWidth = emojiData.width
      local emojiNaturalHeight = emojiData.height
      local emojiscale
      if emojiNaturalWidth > emojiNaturalHeight then
        emojiscale = button_scale / emojiNaturalWidth
      else
        if emojiNaturalHeight > emojiNaturalWidth then
          emojiscale = button_scale / emojiNaturalHeight
        else
          if emojiNaturalWidth == emojiNaturalHeight then
            emojiscale = button_scale / emojiNaturalWidth
          else
            error(
              "\nUnknown error.\nERROR_CODE: 0\nPlease, report it to the author modification @arsstels in discord/github/factorio.com",
              2)
          end
        end
      end
      make_button_style(emojiData.name, "__" .. ModName .. "__/emotes/" .. emojiData.name .. ".png", emojiNaturalWidth,
        emojiNaturalHeight, emojiscale)
    end
  end
end
