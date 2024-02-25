---@diagnostic disable: lowercase-global
count_em_table = { 1, 2, 5, 10, 100, 1000 }
size_em_table = { {"small"}, {"medium"}, {"large"} }

-- # Создали интерфейс ядра мода с последующими страницами дополнений
remote.add_interface("chat_emoji_core", {

  -- # Инициализация вкладок меню
  informatron_menu = function(data)
    return emojis_menu(data.player_index)
  end,

  -- # Инициализация внутреннего контента меню
  informatron_page_content = function(data)
    return emojidescription(data.page_name, data.player_index, data.element)
  end
})

-- # Инициализация пустой таблицы для последующего использования
local ModsTable = {}

-- # Заполнение таблицы страницами отдельных модов
for ModNameForModsTable, _ in pairs(script.active_mods) do
  if string.find(ModNameForModsTable, "chat_emojis_") then
    ModsTable[ModNameForModsTable] = 1
  end
end
  
-- @ log(serpent.block(ModsTable))

-- # Передали таблицу с отдельными модами в интерфейс
function emojis_menu(player_index)
  return ModsTable
end

MOD_LIST = {}

-- # Инициализируем новые таблицы от отдельных модов с содержащими в себе ссылками на эмодзи таблицами
for ModName, version in pairs(script.active_mods) do
  -- = for Example: chat_emojis_ArsStels

  -- # Проверяем, является ли мод отдельным модом с условием по наличию слов "chat_emojis_" в названии
  if string.find(ModName, "chat_emojis_") then
    -- log(ModName .. " version " .. version)

    -- # Импортируем таблицу с содержащими в себе ссылками на эмодзи
    -- = for Example: __chat_emojis_ArsStels__/emotes_list.lua
    require("__" .. ModName .. "__/emotes_list")

    -- # Создаём новую динамическую таблицу от других модов и сортируем их
    table.sort(Emojis, function(a, b) return a.name < b.name end)
    _G[ModName] = Emojis

    table.insert(MOD_LIST, ModName)
  end
end

local function _getElement(tableCollection, add, element)
  local found = nil
  for _, value in ipairs(tableCollection) do
    if value == element or value .. add == element then
      found = value
      break
    end
  end
  return found
end

local function _isAnyElement(tableCollection, element)
  local found = false
  for _, value in ipairs(tableCollection) do
    if value == element then
      found = true
      break
    end
  end
  return found
end

local function _isAnyString(tableCollection, add, element)
  local found = false
  for _, value in ipairs(tableCollection) do
    if value .. add == element then
      found = true
      break
    end
  end
  return found
end

function on_gui_click(event)
  -- Validation of data
  local gui = event.element
  if not (gui and gui.valid and gui.name) then return end
  local player = game.get_player(event.player_index)

  if not (player and player.valid) then return end
  local parent = gui.parent

  if not parent then return end
  local parent_name = parent.name

  r = _isAnyString(MOD_LIST, "_emote_table", parent_name)
  if not r then return end

  ModName = _getElement(MOD_LIST, "_emote_table", parent_name)

  local parent = parent.parent.parent

  if not parent then return end

  local color = player.color
  local text = ""

  local emojis_list_size = parent["chat_emoji_core.emote_size"]["emojis_list_size"]

  --local size = size_em_table[emojis_list_size.selected_index]
  local size = emojis_list_size.items[emojis_list_size.selected_index]

  local emojis_list_count = parent["chat_emoji_core.emote_count"]["emojis_list_count"]

  --local count = count_em_table[emojis_list_count.selected_index]
  local count = emojis_list_count.items[emojis_list_count.selected_index]

  local checkbocks_autosend = parent["chat_emoji_core.text_label"]["to_chat_checkbox"]
  log(checkbocks_autosend.name)
  local checkbocks = checkbocks_autosend.state
  log(checkbocks)

  local text_field = parent["chat_emoji_core.text_field"]

  if not size then
    error(
      "\n\nThe 'emojis_list_size' parameter cannot be nil.\nERROR_CODE: 3\n\nPlease, report it to the author modification @arsstels in discord/github/factorio.com\n")
  end

  if not count then
    error(
      "\n\nThe 'emojis_list_count' parameter cannot be nil.\nERROR_CODE: 3\n\nPlease, report it to the author modification @arsstels in discord/github/factorio.com\n")
  end

  if size == "small" then
    if checkbocks == false then
      text_field.text = text_field.text .. ("[img=" .. gui.name .. "]"):rep(count)
    else
      text = ("[img=" .. gui.name .. "]"):rep(count)
      game.print(player.name .. ": " .. text, color)
    end
  else
    if size == "large" then
      local selectedEmoji = nil
      for i, emojiData in ipairs(_G[ModName]) do
        if emojiData.name == gui.name or emojiData.style == gui.style then
          selectedEmoji = emojiData
          break
        end
      end
      if selectedEmoji then
        local widthFragmentCount = math.ceil(selectedEmoji.width / 60)
        local heightFragmentCount = math.ceil(selectedEmoji.height / 60)
        local fragments = widthFragmentCount * heightFragmentCount
        for k = 1, fragments do
          text = text .. ("[img=" .. gui.name .. "_f" .. k .. "]")
          -- if (function emojis_menu(player_index)
          --   return ModsTable
          -- end ) then
          --   -- code here
        end
      end
    end
  end
end

-- # Инициализация внутреннего контента
function emojidescription(page_name, player_index, element)
  -- # Инициализация внутреннего контента главной страницы
  if page_name == "chat_emoji_core" then
    element.add { type = "label", name = "chat_emoji_core_element", caption = { "chat_emoji_core.page_text" } }
  end

  -- # Инициализация внутреннего контента для отдельных модов
  for ModName, _ in pairs(ModsTable) do
    if page_name == ModName then
      -- # Добавление новых элементов, строки взаимодействия и текстового поля
      local head_text_label = element.add { type = "flow", name = "chat_emoji_core.text_label" }
      head_text_label.add { type = "checkbox", name = "to_chat_checkbox" , state = true }
      head_text_label.add { type = "label", name = "label_checkbox", caption = "chat_emoji_core.label_checkbox" }

      local text_label = element.add { type = "text-box", name = "chat_emoji_core.text_field" }
      text_label.read_only = false
      text_label.style.width = 1000
      text_label.style.height = 40

      -- # Добавляем кнопку для выбора размера эмодзи
      local emote_size = element.add { type = "flow", name = "chat_emoji_core.emote_size" }
      emote_size.add { type = "drop-down", name = "emojis_list_size", items = size_em_table, selected_index = 1 }
      emote_size.add { type = "label", caption = { "chat_emoji_core.description_size" } }

      -- # Добавляем кнопку для настройки количества эмодзи
      local emote_count = element.add { type = "flow", name = "chat_emoji_core.emote_count" }
      emote_count.add { type = "drop-down", name = "emojis_list_count", items = count_em_table, selected_index = 1 }
      emote_count.add { type = "label", caption = { "chat_emoji_core.description_count" } }

      -- # Получаем персональные настройки игрока для оформления таблицы
      -- = Настройки количества столбцов
      local player_table_count = settings.get_player_settings(player_index)
          ["chat_emoji_gui_emoji_table_count"].value

      -- = Настройки горизонтальных отступов
      local player_table_horizontal = settings.get_player_settings(player_index)
          ["chat_emoji_gui_emoji_table_horizontal_spacing"].value

      -- = Настройки вертикальных отступов
      local player_table_vertical = settings.get_player_settings(player_index)
          ["chat_emoji_gui_emoji_table_vertical_spacing"].value

      local player_scroll_pane_height_max = settings.get_player_settings(player_index)
          ["chat_emoji_gui_emoji_scroll_pane_height_max"].value

      local player_scroll_pane_height_min = settings.get_player_settings(player_index)
          ["chat_emoji_gui_emoji_scroll_pane_height_min"].value

      -- # Инициализируем скролл-бокс для того, чтобы таблица внутри прокручивалась, а сама страница - нет
      scroll_pane = element.add
          {
            type = "scroll-pane",
            name = ModName .. "_scroll_pane",
            vertical_scroll_policy = "auto-and-reserve-space",
            horizontal_scroll_policy = "auto-and-reserve-space",
          }

      -- # Присваиваем ограничения по высоте скролл-бокса
      scroll_pane.style.maximal_height = player_scroll_pane_height_max
      scroll_pane.style.minimal_height = player_scroll_pane_height_min

      -- # Инициализируем таблицу с эмодзи внутри скролл-бокса
      local tableEmojis = scroll_pane.add
          {
            type = "table",
            name = ModName .. "_emote_table",
            column_count = player_table_count,
            draw_horizontal_lines = false,
            draw_vertical_lines = false,
            vertical_centering = true,
            children = { scroll_pane }
          }

      -- # Присваиваем горизонтальные и вертикальные отступы внутри таблицы с эмодзи
      tableEmojis.style.horizontal_spacing = player_table_horizontal
      tableEmojis.style.vertical_spacing = player_table_vertical

      -- # Добавляем кнопки-эмодзи в таблицу
      for i = 1, #_G[ModName], 1 do
        local name = _G[ModName][i].name

        -- # Получаем для удобства строку названия мода без "chat_emojis_"
        local NewModName = string.gsub(ModName, "chat_emojis_", "")

        -- # Добавляем в таблицу кнопки-эмодзи, вызываемые из интерфейса, в описание (tooltip) вписываем название мода и название эмодзи
        tableEmojis.add { type = "button", name = name, style = name, tooltip = { "emote_" .. NewModName .. "." .. _G[ModName][i].name } }
      end
    end
  end
end

script.on_event(defines.events.on_gui_click, on_gui_click)

--[[
    ---@diagnostic disable: lowercase-global
    remote.add_interface(ModName .. "_emojis", {
      informatron_menu = function(data)
        return emojis_menu(data.player_index)
      end,
      informatron_page_content = function(data)
        return emojiselect(data.page_name, data.player_index, data.element)
      end
    })

    function emojis_menu(player_index)
      return { nil }
    end

    function emojiselect(page_name, player_index, element)
      local player_table_count = settings.get_player_settings(player_index)
        ["chat_emoji_gui_emoji_table"].value
      local player_table_horizontal = settings.get_player_settings(player_index)
        ["chat_emoji_gui_emoji_table_horizontal_spacing"].value
      local player_table_vertical = settings.get_player_settings(player_index)
        ["chat_emoji_gui_emoji_table_vertical_spacing"].value
      --big page content
      if page_name == ModName .. "_emojis" then
        local emote_label = element.add { type = "flow", name = ModName .. "_emote_label" }
        emote_label.add { type = "label", caption = { ModName .. "_emojis_main_label" } }

        local emote_count = element.add { type = "flow", name = "emote_count" }
        emote_count.add { type = "drop-down", name = ModName .. "_emojis_list_count", items = { 1, 5, 10, 20, 30 }, selected_index = 1 }
        emote_count.add { type = "label", caption = { ModName .. "_emojis_count_label" } }

        local emote_size = element.add { type = "flow", name = ModName .. "_emote_size" }
        emote_size.add { type = "drop-down", name = ModName .. "_emojis_list_size", items = { "small", "big" }, selected_index = 1 }
        emote_size.add { type = "label", caption = { ModName .. "_emojis_size_label" } }

        local table                    = element.add { type = "table", name = ModName .. "_emotelist", column_count = player_table_count, draw_horizontal_lines = false, draw_vertical_lines = false, vertical_centering = true }
        table.style.horizontal_spacing = player_table_horizontal
        table.style.vertical_spacing   = player_table_vertical

        for i = 1, #_G[ModName], 1 do
          local name = _G[ModName][i].name
          local tooltip = "[color=#FFA042][font=compilatron-message-font]" ..
            _G[ModName][i].name .. "[/font][/color]\n" .. _G[ModName][i].tooltip
          table.add { type = "button", name = name, style = name, tooltip = tooltip }
          log(serpent.block(tooltip))
        end
      end
    end

    local function on_gui_click(event)
      -- Validation of data
      local gui = event.element
      if not (gui and gui.valid and gui.name) then return end
      local player = game.get_player(event.player_index)
      if not (player and player.valid) then return end
      local parent = gui.parent
      if not parent then return end

      local parent_name = parent.name
      if parent_name ~= ModName .. 'emotelist' then return end
      local parent = parent.parent
      if not parent then return end

      local emojis_list_count = parent.emote_count.emojis_list_count
      local count = emojis_list_count.items[emojis_list_count.selected_index]

      if not emojis_list_count then
        error(
          "\n\nThe 'emojis_list_count' parameter cannot be nil.\nERROR_CODE: 3\n\nPlease, report it to the author modification @arsstels in discord/github/factorio.com\n")
      end

      local emojis_list_size = parent.emote_size.emojis_list_size
      local size = emojis_list_size.items[emojis_list_size.selected_index]

      local color = player.color
      local text = ""

      if size == "small" then
        text = ("[img=" .. gui.name .. "]"):rep(count)
        game.print(player.name .. ": " .. text, color)
      else
        if size == "big" then
          local selectedEmoji = nil
          for i, emojiData in ipairs(_G[ModName]) do
            if emojiData.name == gui.name or emojiData.style == gui.style then
              selectedEmoji = emojiData
              break
            end
          end
          if selectedEmoji then
            local widthFragmentCount = math.ceil(selectedEmoji.width / 60)
            local heightFragmentCount = math.ceil(selectedEmoji.height / 60)
            local fragments = widthFragmentCount * heightFragmentCount
            for k = 1, fragments do
              text = text .. ("[img=" .. gui.name .. "_f" .. k .. "]")
              if (function emojis_menu(player_index)
  return { nil }
end

function emojidescription(page_name, player_index, element)
  if page_name == "emojis_menu" then
    local emote_label = element.add { type = "flow", name = "chat_emoji_core_emote_label" }
    emote_label.add { type = "label", caption = { "chat_emoji_core_main_label" } }
    emote_label.add { type = "label", caption = { "chat_emoji_core_description_label" } }
    game.print("[color=#FFD33A][font=default-large]The selected emoji is not available in the table.[/font][/color]")
    game.print("[color=#FF2A23][font=default-large-bold]ERROR_CODE: 2[/font][/color]")
    game.print("[color=#B2B2B2][font=default-large]Please, report it to the author modification @arsstels in discord/github/factorio.com[/font][/color]")

    script.on_event(defines.events.on_gui_click, on_gui_click)
  end
end
]]
