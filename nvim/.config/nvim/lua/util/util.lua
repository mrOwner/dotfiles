local M = {}

-- разбивает пареметры и возвращаемые значения на строки.
local function formatArguments(args)
    if string.len(args) == 0 then
        return {}
    end

    args = args:gsub("%s*%(?([^()]+)%)?%s*", "%1") -- Удаление боковых пробелов и скобок.

    if string.len(args) < 60 then
        return {"    " .. args .. ","}
    end

    local formattedArgs = {}
    local withoutType = {}

    for arg in args:gmatch("[^,]+") do
        arg = arg:gsub("%s*(.+)%s*", "%1") -- Удаление боковых пробелов.
        if not arg:match(".+ .+") then
            withoutType[#withoutType + 1] = arg
            goto continue
        end
        if #withoutType > 0 then
            arg = table.concat(withoutType, ", ") .. ", " .. arg
            withoutType = {}
        end
        formattedArgs[#formattedArgs + 1] = "    " .. arg .. ","
        ::continue::
    end
    for _, value in ipairs(withoutType) do
        table.insert("    " .. formattedArgs, value .. ",")
    end

    return formattedArgs
end

---@param bin_name string Имя бинарного файла, который будет проверяться через vim.fn.exepath
---@param install_cmd string Команда установки, которая будет выполнена, если бинарник не найден
function M.Install(bin_name, install_cmd)
  vim.schedule(function()
    local path = vim.fn.exepath(bin_name)
    if path == "" then
      vim.notify("Installing " .. bin_name, vim.log.levels.INFO)
      local args = vim.fn.split(install_cmd)
      vim.fn.jobstart(args, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_exit = function(_, code)
          if code == 0 then
            vim.notify(bin_name .. " installed successfully.", vim.log.levels.INFO)
          else
            vim.notify("Failed to install " .. bin_name, vim.log.levels.ERROR)
          end
        end,
      })
    end
  end)
end

function M.FormatGoFunction()
    local line = vim.api.nvim_get_current_line()
    local functionName, args, returns = line:match("(.*%s*func%s+%(?.-%)?%s-[a-zA-Z0-9-_]-)(%(.-%))%s-(%(?.-%)?)%s+{")
    if not functionName and not args then
        print("A function not found")
        return
    end

    vim.api.nvim_set_current_line(functionName .. "(")

    local lines = formatArguments(args)
    local rlines = formatArguments(returns)

    if #rlines > 0 then
        table.insert(lines, ") (")
        for _, value in ipairs(rlines) do
            table.insert(lines, value)
        end
    end
    table.insert(lines, "")
    lines[#lines] = lines[#lines] .. ") {"

    local bufnr = vim.api.nvim_get_current_buf()
    local currentLine = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(bufnr, currentLine, currentLine, false, lines)
end

-- Разбивает по точкам bilder pattern.
function M.FormatByDot()
    local line = vim.api.nvim_get_current_line()
    local lines = {}
    local row = ""

    local add = function(tbl, rw, chunk)
        if #tbl > 0 then
            tbl[#tbl] = tbl[#tbl] .. "."
        end

        local srw = ""
        if rw ~= "" then
            srw = rw .. "."
        end

        if string.len(rw .. chunk) > 120 then
            table.insert(tbl, srw)
            table.insert(tbl, chunk)
        else
            table.insert(tbl, srw .. chunk)
        end

        rw = ""
        return tbl, rw
    end

    local try = function(tbl, rw, chunk)
        if string.len(rw .. chunk) > 60 then
            tbl, rw = add(tbl, rw, chunk)
        else
            if rw ~= "" then
                rw = rw .. "."
            end
            rw = rw .. chunk
        end
        return tbl, rw
    end

    for chunk in line:gmatch("[^.]+") do
        local one, curly, two = chunk:match("^(.*)%{(.-)%}(.*)$")
        if curly then
            lines, row = add(lines, row, one .. "{")
            for value in curly:gmatch("[^,]+") do
                table.insert(lines, "    " .. value .. ",")
            end
            table.insert(lines, "}" .. two)
            goto continue
        end
        lines, row = try(lines, row, chunk)
        ::continue::
    end

    if row ~= "" then
        lines[#lines] = lines[#lines] .. "."
        table.insert(lines, row)
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local currentLine = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(bufnr, currentLine-1, currentLine, false, lines)
end

-- Разбивка по запятым.
function M.FormatByComma()
    local line = vim.api.nvim_get_current_line()
    local lines = {}

    for chunk in line:gmatch("[^,]+") do
        table.insert(lines, "    " .. chunk .. ",")
    end

    -- Удаляю последнюю запятую.
    lines[#lines] = string.sub(lines[#lines], 1, -2)

    local bufnr = vim.api.nvim_get_current_buf()
    local currentLine = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(bufnr, currentLine-1, currentLine, false, lines)
end

-- открывает neo-tree там где файл и пытается установить,
-- в качестве корневого каталога, каталог, который содрежит git репозитории
function M.Focus()
  local function find_root(path)
    local mod_index = path:find("/go/pkg/mod/")
    local vendor_index = path:find("/vendor/")
    local base_index, base_path

    if mod_index then
      base_index = mod_index
      base_path = "/go/pkg/mod/"
    elseif vendor_index then
      base_index = vendor_index
      base_path = "/vendor/"
    else
      return nil
    end

    -- Получаем остаток пути после base_path
    local rest = path:sub(base_index + #base_path)
    local parts = vim.split(rest, "/", { plain = true, trimempty = true })

    if #parts > 0 then
      local root = path:sub(1, base_index + #base_path - 1) .. "/" .. parts[1]
      return vim.fs.normalize(root)
    end

    return nil
  end

  local cwd = vim.fn.getcwd()
  local root = cwd
  local reveal_file = vim.fn.expand("%:p")
  if reveal_file == "" then
    reveal_file = cwd
  else
    local f = io.open(reveal_file, "r")
    if f then
      f.close(f)
      local getroot = find_root(reveal_file)
      if getroot then
        root = getroot
      end
    else
      reveal_file = cwd
    end
  end

  -- require("neo-tree.command").execute({
  --   action = "focus", -- OPTIONAL, this is the default value
  --   source = "filesystem", -- OPTIONAL, this is the default value
  --   position = "left", -- OPTIONAL, this is the default value
  --   reveal_file = reveal_file, -- path to file or folder to reveal
  --   reveal_force_cwd = true, -- change cwd without asking if needed
  --   -- toggle = true,
  --   dir = root,
  -- })
  Snacks.explorer.reveal({ file = reveal_file })
end

--- Opens the GitLab merge request page in the default browser.
function M.OpenGitlabMR()
  local cmd = "glab mr show -F json | jq -r .web_url"

  -- Запускаем команду и читаем результат
  local handle = io.popen(cmd)
  if not handle then
    vim.notify("Failed to run glab", vim.log.levels.ERROR)
    return
  end

  local result = handle:read("*a")
  handle:close()

  local url = vim.trim(result)

  if url == "" or url == "null" then
    vim.notify("No MR URL found", vim.log.levels.WARN)
    return
  end

  -- Открываем URL в браузере
  local open_cmd = vim.fn.has("mac") == 1 and "open" or
                   vim.fn.has("unix") == 1 and "xdg-open" or nil

  if open_cmd then
    vim.fn.jobstart({ open_cmd, url }, { detach = true })
  else
    vim.notify("Unsupported OS for opening browser", vim.log.levels.ERROR)
  end
end

-- открывает definition в новом окне
function M.gs_lsp_def_in_right()
  local cur = vim.api.nvim_get_current_win()
  local bufcur = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(cur)

  -- попробуем перейти вправо — если получилось, right ~= cur
  vim.cmd("wincmd l")
  local right = vim.api.nvim_get_current_win()

  if right == cur then
    -- справа нет окна — создаём вертикальный сплит, но остаёмся в исходном окне
    vim.cmd("vsplit")
    right = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur)
  else
    -- вернёмся в исходное окно (мы только проверяли существование окна)
    vim.api.nvim_set_current_win(cur)
  end

  -- вызываем fzf-lua с переопределённым действием
  require("fzf-lua").lsp_definitions({ jump1 = true, ignore_current_line = true, })

  vim.cmd("wincmd x")
  vim.api.nvim_set_current_buf(bufcur)
  vim.api.nvim_win_set_cursor(cur, cursor_pos)
end

return M
