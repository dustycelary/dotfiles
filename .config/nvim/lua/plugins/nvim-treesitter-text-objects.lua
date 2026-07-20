return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")

    -- Select keymaps
    local select_maps = {
      ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
      ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
      ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
      ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

      ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
      ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
      ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
      ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },

      ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
      ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

      ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
      ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

      ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
      ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

      ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
      ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

      ["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
      ["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

      ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
      ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
    }

    for key, map in pairs(select_maps) do
      vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(map.query, "textobjects")
      end, { desc = map.desc })
    end

    -- Swap keymaps
    local swap_next_maps = {
      ["<leader>na"] = { query = "@parameter.inner", desc = "Swap parameter with next" },
      ["<leader>n:"] = { query = "@property.outer", desc = "Swap object property with next" },
      ["<leader>nm"] = { query = "@function.outer", desc = "Swap function with next" },
    }

    local swap_prev_maps = {
      ["<leader>pa"] = { query = "@parameter.inner", desc = "Swap parameter with prev" },
      ["<leader>p:"] = { query = "@property.outer", desc = "Swap object property with prev" },
      ["<leader>pm"] = { query = "@function.outer", desc = "Swap function with prev" },
    }

    for key, map in pairs(swap_next_maps) do
      vim.keymap.set("n", key, function()
        swap.swap_next(map.query, "textobjects")
      end, { desc = map.desc })
    end

    for key, map in pairs(swap_prev_maps) do
      vim.keymap.set("n", key, function()
        swap.swap_previous(map.query, "textobjects")
      end, { desc = map.desc })
    end

    -- Move keymaps
    local move_next_start = {
      ["]f"] = { query = "@call.outer", desc = "Next function call start" },
      ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
      ["]c"] = { query = "@class.outer", desc = "Next class start" },
      ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
      ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
      ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
      ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
    }

    local move_next_end = {
      ["]F"] = { query = "@call.outer", desc = "Next function call end" },
      ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
      ["]C"] = { query = "@class.outer", desc = "Next class end" },
      ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
      ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
    }

    local move_prev_start = {
      ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
      ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
      ["[c"] = { query = "@class.outer", desc = "Prev class start" },
      ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
      ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
    }

    local move_prev_end = {
      ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
      ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
      ["[C"] = { query = "@class.outer", desc = "Prev class end" },
      ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
      ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
    }

    for key, map in pairs(move_next_start) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        move.goto_next_start(map.query, map.query_group or "textobjects")
      end, { desc = map.desc })
    end

    for key, map in pairs(move_next_end) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        move.goto_next_end(map.query, map.query_group or "textobjects")
      end, { desc = map.desc })
    end

    for key, map in pairs(move_prev_start) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        move.goto_previous_start(map.query, map.query_group or "textobjects")
      end, { desc = map.desc })
    end

    for key, map in pairs(move_prev_end) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        move.goto_previous_end(map.query, map.query_group or "textobjects")
      end, { desc = map.desc })
    end

    -- Repeatable moves
    local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

    vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  end,
}
