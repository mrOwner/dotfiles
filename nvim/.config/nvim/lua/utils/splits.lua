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

return M
