-- Universal Object/Dict/Map Property Sorter using Tree-sitter
-- Supports JavaScript, TypeScript, Python, Lua, JSON, YAML, TOML, Rust, Go, and more

local M = {}

-- Language-specific configurations
local LANG_CONFIG = {
    javascript = {
        queries = {
            object = "(object) @object",
            property = "(pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    },
    typescript = {
        queries = {
            object = "(object) @object",
            property = "(pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    },
    tsx = {
        queries = {
            object = "(object) @object",
            property = "(pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    },
    jsx = {
        queries = {
            object = "(object) @object",
            property = "(pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    },
    json = {
        queries = {
            object = "(object) @object",
            property = "(pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^"(.+)"$', '%1') end
    },
    python = {
        queries = {
            object = "(dictionary) @object",
            property = "(pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    },
    lua = {
        queries = {
            object = "(table_constructor) @object",
            property = "(field name: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    },
    yaml = {
        queries = {
            object = "(block_node) @object",
            property = "(block_mapping_pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key end
    },
    toml = {
        queries = {
            object = "(table) @object",
            property = "(pair key: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    },
    rust = {
        queries = {
            object = "(struct_expression) @object",
            property = "(field_initializer field: (_) @key value: (_) @value) @property"
        },
        key_cleanup = function(key) return key end
    },
    go = {
        queries = {
            object = "(composite_literal) @object",
            property = "(keyed_element (_) @key (_) @value) @property"
        },
        key_cleanup = function(key) return key:gsub('^["\'](.+)["\']$', '%1') end
    }
}

-- Add aliases for similar languages
LANG_CONFIG.javascriptreact = LANG_CONFIG.jsx
LANG_CONFIG.typescriptreact = LANG_CONFIG.tsx

local function get_node_text(node, bufnr)
    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)

    if #lines == 0 then return "" end

    if #lines == 1 then
        return string.sub(lines[1], start_col + 1, end_col)
    else
        lines[1] = string.sub(lines[1], start_col + 1)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
        return table.concat(lines, "\n")
    end
end

local function sort_object_properties()
    local ts = vim.treesitter
    local parsers = require('nvim-treesitter.parsers')

    -- Get current language
    local lang = parsers.get_buf_lang()
    if not lang then
        vim.notify("Could not determine file language", vim.log.levels.WARN)
        return
    end

    -- Check if we support this language
    local config = LANG_CONFIG[lang]
    if not config then
        vim.notify(string.format("Language '%s' not supported. Supported: %s",
            lang, table.concat(vim.tbl_keys(LANG_CONFIG), ", ")), vim.log.levels.WARN)
        return
    end

    local parser = ts.get_parser(0, lang)
    if not parser then
        vim.notify("No tree-sitter parser available for " .. lang, vim.log.levels.ERROR)
        return
    end

    local tree = parser:parse()[1]
    local root = tree:root()

    -- Get cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    -- Find object containing cursor
    local object_query = ts.query.parse(lang, config.queries.object)
    local bufnr = vim.api.nvim_get_current_buf()
    local found_object = nil

    for _, node in object_query:iter_captures(root, bufnr, 0, -1) do
        local start_row, start_col, end_row, end_col = node:range()
        if row >= start_row and row <= end_row then
            if (row == start_row and col >= start_col) or
               (row == end_row and col <= end_col) or
               (row > start_row and row < end_row) then
                found_object = node
                break
            end
        end
    end

    if not found_object then
        vim.notify("Cursor not inside a supported object structure", vim.log.levels.WARN)
        return
    end

    -- Extract properties
    local property_query = ts.query.parse(lang, config.queries.property)
    local properties = {}

    for id, node, _ in property_query:iter_captures(found_object, bufnr, 0, -1) do
        local name = property_query.captures[id]
        if name == "property" then
            local start_row, start_col, end_row, end_col = node:range()
            local property_text = get_node_text(node, bufnr)

            -- Find the key node
            local key_text = ""
            for key_id, key_node in property_query:iter_captures(node, bufnr, 0, -1) do
                local key_name = property_query.captures[key_id]
                if key_name == "key" then
                    key_text = get_node_text(key_node, bufnr)
                    break
                end
            end

            -- Clean up key for sorting
            if config.key_cleanup then
                key_text = config.key_cleanup(key_text)
            end

            table.insert(properties, {
                key = key_text,
                text = property_text,
                start_row = start_row,
                start_col = start_col,
                end_row = end_row,
                end_col = end_col
            })
        end
    end

    if #properties == 0 then
        vim.notify("No properties found in object", vim.log.levels.WARN)
        return
    end

    -- Sort properties by key (case-insensitive)
    table.sort(properties, function(a, b)
        return a.key:lower() < b.key:lower()
    end)

    -- Handle comma logic based on language
    ---@diagnostic disable-next-line: redefined-local
    local needs_comma = function(lang, is_last, line)
        if lang == "python" or lang == "lua" then
            return not is_last -- Python/Lua don't need trailing comma
        elseif lang == "yaml" or lang == "toml" then
            return false -- YAML/TOML don't use commas
        else
            return not is_last or not line:match(",$") -- JS/JSON/etc need commas except possibly last
        end
    end

    -- Build sorted content
    local sorted_lines = {}
    for i, prop in ipairs(properties) do
        local prop_lines = vim.split(prop.text, "\n")
        for j, line in ipairs(prop_lines) do
            if j == #prop_lines and needs_comma(lang, i == #properties, line) and not line:match(",$") then
                line = line .. (lang == "python" and "," or (lang == "yaml" or lang == "toml") and "" or ",")
            end
            table.insert(sorted_lines, line)
        end
    end

    -- Replace properties
    if #properties > 0 then
        local first_prop = properties[1]
        local last_prop = properties[#properties]

        vim.api.nvim_buf_set_lines(bufnr, first_prop.start_row, last_prop.end_row + 1, false, sorted_lines)
        vim.notify(string.format("Sorted %d %s properties", #properties, lang), vim.log.levels.INFO)
    end
end

-- Create user command
vim.api.nvim_create_user_command('SortObjectProperties', sort_object_properties, {
    desc = 'Sort object/dict/map properties using tree-sitter'
})

-- Universal keymapping
vim.keymap.set('n', '<leader>so', sort_object_properties, {
    desc = 'Sort object properties',
    silent = true
})

-- Auto-command for all supported languages  
vim.api.nvim_create_autocmd({'FileType'}, {
    pattern = vim.tbl_keys(LANG_CONFIG),
    callback = function()
        vim.keymap.set('n', '<leader>so', sort_object_properties, {
            desc = 'Sort object properties',
            buffer = true,
            silent = true
        })
    end
})

-- Export for manual extension
M.sort_object_properties = sort_object_properties
M.LANG_CONFIG = LANG_CONFIG

return M
