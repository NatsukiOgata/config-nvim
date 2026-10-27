local diff_source_path = nil

return {
  --------------------------------------------------
  -- UI / 基本プラグイン (旧 dein.toml)
  --------------------------------------------------
  {
    "keaising/im-select.nvim",
    event = "InsertEnter",
    config = function()
      require("im_select").setup({
        default_im_select = "0",
        default_command = "zenhan.exe",
        set_default_events = { "InsertLeave" },
      })
    end,
  },
  {
    'fuenor/qfixhowm',
    init = function()
      vim.g.QFix_Height = 6
      vim.g.QFix_PreviewHeight = 24
      vim.g.QFixHowm_Key = ','
      vim.g.QFixHowm_KeyB = 'h'
      vim.g.QFixHowm_CalendarWinCmd = 'vertical botright'
      -- ripgrepを使う（PATHは通してある前提）
      vim.g.mygrepprg = 'rg'
      -- 実行時のオプションをripgrep用に変更（GNU Grepと同じ出力になるように）
      vim.g.MyGrepcmd_useropt = '-nH --no-heading --color never'
      vim.g.MyGrepcmd_regexp = ''
      vim.g.MyGrepcmd_regexp_ignore = '-i'
      vim.g.MyGrepcmd_fix = '-F'
      vim.g.MyGrepcmd_fix_ignore = '-F -i'
      vim.g.MyGrepcmd_recursive = ''
      -- gipgrepにファイルパターンとして「*」「*.*」を渡したらエラーになったのでその対策
      vim.g.MyGrep_GrepFilePattern = '.'
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = false,
    opts = {},
    config = function(_, opts)
      require("mini.icons").setup(opts)
      -- これで lualine や diffview が内部で nvim-web-devicons を探しても、
      -- mini.icons が代わりに超高速で身代わり処理してくれます
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      -- 相対ディレクトリを取得する Lua 関数
      local function show_relative_dir()
        local dir = vim.fn.expand("%:h")
        return dir ~= "" and dir or "[Empty Dir]"
      end

      require("lualine").setup({
        options = {
          theme = "sonokai",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = false,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch",
            { "filename", file_status = true, path = 0 } -- 0: ファイル名のみ
          },
          lualine_c = {
            show_relative_dir -- 関数をそのままコンポーネントとして渡せます
          },
          lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
  { 'AndreM222/copilot-lualine' },
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.sonokai_disable_italic_comment = 1
      vim.g.sonokai_enable_italic = 0
      vim.cmd.colorscheme('sonokai')

      vim.api.nvim_set_hl(0, "@attribute.negation", {
        fg = "#000000",
        bg = "#ffff00",
      })
    end,
  },
  {
    'jiangmiao/auto-pairs',
    init = function()
      -- 同じ行のペアのみジャンプしたい
      vim.g.AutoPairsMultilineClose = 0
    end,
  },
  'yuttie/comfortable-motion.vim',

  --------------------------------------------------
  -- 遅延読み込みプラグイン (旧 dein_lazy.toml)
  --------------------------------------------------

  -- ファイルマネージャー
  {
    'lambdalisue/fern.vim',
    cmd = { 'Fern' },
    dependencies = {
      'lambdalisue/nerdfont.vim',
      'lambdalisue/fern-renderer-nerdfont.vim',
      'lambdalisue/fern-bookmark.vim',
      'antoinemadec/FixCursorHold.nvim',
    },
    keys = {
      { ',f', '[fern]', remap = true },
      -- バッファディレクトリ
      { '[fern]d', ':<C-u>Fern . -reveal=%<CR>', silent = true },
      -- カレントディレクトリ
      { '[fern]c', ':<C-u>Fern .<CR>', silent = true },
      -- bookmark
      { ',bj', ':<C-u>Fern bookmark:///<CR>', silent = true },
    },
    init = function()
      vim.keymap.set('n', '[fern]', ':Fern', { noremap = true })
      vim.g['fern#renderer'] = 'nerdfont'
    end,
    config = function()
      -- Fern 画面から Oil へ遷移 (,to)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fern",
        callback = function()
          vim.keymap.set("n", ",to", function()
            -- Fern バッファが現在指しているディレクトリのパスを取得
            -- （b:fern#statusなどの内部変数や、現在開いているバッファのパスを利用）
            local success, current_path = pcall(function()
              return vim.b.fern.this.url
            end)

            local target_dir = nil
            if success and current_path then
              -- file:/// パスなどの場合はデコード、通常パスならそのまま
              target_dir = vim.fn.substitute(current_path, "^file:///", "", "")
            end

            -- 取得できなければカレントディレクトリをフォールバックに使う
            if not target_dir or target_dir == "" or vim.fn.isdirectory(target_dir) == 0 then
              target_dir = vim.fn.getcwd()
            end

            -- 現在のウィンドウを閉じて、同じディレクトリを Oil で開く
            require("oil").open(target_dir)
          end, { buffer = true, desc = "Switch from Fern to Oil" })
        end,
      })
    end,
  },
  {
    'stevearc/oil.nvim',
    config = function()
      require("oil").setup({
        columns = {
          "icon",
        },
        delete_to_trash = true,
        view_options = {
          show_hidden = true,
          sort = {
            { "type", "asc" },
            { "mtime", "desc" },
          },
          natural_order = true,
          is_always_hidden = function(name, bufnr)
            return name == ".." or name == ".git"
          end,
        },
        win_options = {
          wrap = true,
        },
        keymaps = {
          ["<C-t>"] = { "actions.select_tab", desc = "Open in new tab" },
          ["Y"] = {
            desc = "Copy full path and set as diff source",
            callback = function()
              local oil = require("oil")
              local entry = oil.get_cursor_entry()
              if not entry then return end

              local dir = oil.get_current_dir()
              local full_path = dir .. entry.name

              vim.fn.setreg("+", full_path)
              vim.fn.setreg('"', full_path)

              diff_source_path = full_path
              vim.notify("Diff comparison source set: " .. entry.name, vim.log.levels.INFO)
            end,
          },

          ["dif"] = {
            desc = "Diff cursor entry (B) with saved source (A)",
            callback = function()
              if not diff_source_path then
                vim.notify("最初に 'Y' で比較元（A）を選択してください", vim.log.levels.WARN)
                return
              end

              local oil = require("oil")
              local entry = oil.get_cursor_entry()
              if not entry then return end

              local dir = oil.get_current_dir()
              local target_path = dir .. entry.name

              local source_is_dir = vim.fn.isdirectory(diff_source_path) == 1
              local target_is_dir = vim.fn.isdirectory(target_path) == 1

              if source_is_dir and target_is_dir then
                local cmd = string.format("ZFDirDiff %s %s",
                  vim.fn.fnameescape(diff_source_path),
                  vim.fn.fnameescape(target_path)
                )
                vim.cmd(cmd)
              elseif not source_is_dir and not target_is_dir then
                vim.cmd("edit " .. vim.fn.fnameescape(diff_source_path))
                vim.cmd("botright vert diffsplit " .. vim.fn.fnameescape(target_path))
              else
                vim.notify("ファイルとディレクトリを比較することはできません", vim.log.levels.ERROR)
              end

              diff_source_path = nil
            end,
          },
        },
      })

      -- Oil バッファ専用のローカルキーマップ
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          -- 1. OSのエクスプローラーで開く
          vim.keymap.set("n", ",ode", function()
            local current_dir = require("oil").get_current_dir()
            if current_dir then
              local win_dir = current_dir:gsub("/", "\\")
              vim.cmd(string.format('silent !start explorer.exe "%s"', win_dir))
            else
              vim.notify("パスを取得できませんでした", vim.log.levels.WARN)
            end
          end, { buffer = true, desc = "Open in OS Explorer" })

          -- 2. Oil から Fern に切り替える (,tf)
          vim.keymap.set("n", ",tf", function()
            local current_dir = require("oil").get_current_dir()
            if current_dir then
              -- 確実にディレクトリとして Fern を起動
              vim.cmd("Fern " .. vim.fn.fnameescape(current_dir))
            else
              vim.notify("パスを取得できませんでした", vim.log.levels.WARN)
            end
          end, { buffer = true, desc = "Switch from Oil to Fern" })
        end,
      })
    end,
  },

  -- fzf 関連
  {
    "ibhagwan/fzf-lua",
    keys = {
      -- ファイル一覧 (サブディレクトリ対象)
      { ",fr", "<cmd>FzfLua files<CR>", silent = true },
      -- ファイル一覧 (Git)
      { ",fg", "<cmd>FzfLua git_files<CR>", silent = true },
      -- リアルタイム検索
      { ",rg", "<cmd>FzfLua live_grep<CR>", silent = true },
      -- スニペット (nvim-cmp / LuaSnip 等と連携)
      { ",sn", "<cmd>FzfLua snippets<CR>", silent = true },
      -- バッファ一覧
      { ",bl", "<cmd>FzfLua buffers<CR>", silent = true },
      -- 最近使用したファイル一覧 (fzf-mru の代替)
      { ",fm", "<cmd>FzfLua oldfiles<CR>", silent = true },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 1.00,
          width = 1.00,
          row = 0,
          col = 0,
          border = "none",
          preview = {
            layout = "flex",
          },
        },
        keymap = {
          builtin = {
            ["<c-e>"] = "preview-page-down",
            ["<c-y>"] = "preview-page-up",
          },
        },
        fzf_opts = {
          ["--layout"] = "default",
        },
        files = {
          git_icons = true,
          file_icons = true,
        },
        oldfiles = {
          file_ignore_patterns = {
            -- 開発・バージョン管理
            "node_modules",
            "%.git/",
            -- システム・隠しファイル
            "%.DS_Store",
            "Thumbs.db",
            -- 個人用メモ
            "howm",
            -- ビルド成果物・キャッシュ
            "dist/",
            "build/",
            "target/",
            "vendor/",
            "__pycache__/",
          },
        },
      })
    end,
  },

  -- Quickrun & Asyncrun
  {
    'skywind3000/asyncrun.vim',
    cmd = { 'AsyncRun' },
    keys = {
      { ',r', '[asyncrun]', remap = true },
    },
    init = function()
      vim.keymap.set('n', '[asyncrun]', ':AsyncRun ', { noremap = true })
      vim.cmd([[
        " Job終了時にquickfixを開く
        autocmd User AsyncRunStop call asyncrun#quickfix_toggle(8, 1)
      ]])
    end,
    config = function()
      vim.g.asyncrun_bell = 1
    end,
  },

  -- EasyMotion / EasyAlign
  {
    'easymotion/vim-easymotion',
    keys = {
      { 's', '<Plug>(easymotion-s2)', mode = 'n' },
    },
    config = function()
      -- デフォルトのキーマッピングを無効に
      vim.g.EasyMotion_do_mapping = 0
      -- 検索時、大文字小文字を区別しない
      vim.g.EasyMotion_smartcase = 1
    end,
  },
  {
    "echasnovski/mini.align",
    version = "*",
    config = function()
      require("mini.align").setup({
        mappings = {
          start = "",
          start_with_preview = "ga",
        },
      })
    end,
  },

  -- Git / Tools
  {
    'kyoh86/vim-ripgrep',
    cmd = { 'Rg' },
    config = function()
      vim.cmd('command! -nargs=+ -complete=file Rg :call ripgrep#search(<q-args>)')
    end,
  },
  { 'tpope/vim-fugitive', event = 'BufReadPost' },
  { 'buggo/gitv', cmd = { 'Gitv' } },

  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   tag = "v0.9.2", -- 従来の configs / :TS* コマンドがそのまま使えるバージョンに固定
  --   build = ":TSUpdate",
  --   config = function()
  --     require("nvim-treesitter.configs").setup({
  --       ensure_installed = {
  --         "c", "cpp", "c_sharp", "javascript", "typescript", "java", "go", "rust", "python", "lua"
  --       },
  --       auto_install = true,
  --       highlight = {
  --         enable = true,
  --       },
  --     })
  --   end,
  -- },

  -- Utility
  'kana/vim-operator-user',
  {
    'rhysd/vim-clang-format',
    dependencies = { 'kana/vim-operator-user' },
    event = 'BufReadPost',
    config = function()
      vim.g['clang_format#detect_style_file'] = 1
      vim.g['clang_format#command'] = 'clang-format-6.0'
    end,
  },
  { 'dhruvasagar/vim-table-mode', cmd = { 'TableModeToggle' } },
  {
    'kana/vim-altr',
    cmd = { 'A' },
    config = function()
      -- ヘッダファイルとソースファイルを切り替える
      vim.cmd('command! A call altr#forward()')
      vim.cmd("call altr#define('inc/%.h', 'src/%.cpp')")
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },
  {
    "ZSaberLv0/ZFVimDirDiff",
    dependencies = {
      "ZSaberLv0/ZFVimJob",
    },
    cmd = { "ZFDirDiff" },
  },
  { 'vim-scripts/copypath.vim', cmd = { 'CopyFileName', 'CopyPath' } },
  { 'vim-scripts/BlockDiff', cmd = { 'BlockDiff1', 'BlockDiff2' } },

  --------------------------------------------------
  -- GitHub Copilot (copilot.lua) & NES (Next Edit Suggestion)
  --------------------------------------------------
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = {
      -- NES機能のためにバックエンドとなるLSPを管理するプラグイン
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          -- デバウンス時間（ミリ秒）: 編集後にNESの提案を計算するまでの待機時間
          vim.g.copilot_nes_debounce = 500
        end,
      },
    },
    config = function()
      require("copilot").setup({
        -- 1. 通常のインラインコード補完（ゴーストテキスト形式）
        suggestion = {
          enabled = true,
          auto_trigger = true, -- 入力中に自動で候補を表示
          debounce = 75,
          keymap = {
            accept = "<C-y>",      -- Vim標準の補完確定と統一 (インサート移動 <C-l> との衝突回避)
            accept_word = "<C-f>", -- Forward 1 Word
            accept_line = "<C-j>", -- Down 1 Line
            next = "<M-]>",        -- 【Alt + ]】で次の候補へ
            prev = "<M-[>",        -- 【Alt + [】で前の候補へ
            dismiss = "<C-e>",     -- Vim標準の補完キャンセルと統一
          },
        },

        -- ポップアップパネルを無効化
        panel = {
          enabled = false,
        },

        -- 2. Next Edit Suggestion (NES: 次の編集提案) の設定
        nes = {
          enabled = true,
          keymap = {
            accept_and_goto = ",a", -- カンマ派生 (,a) でジャンプ＆適用
            accept = false,         -- 移動なしの適用は無効化
            dismiss = "<Esc><Esc>",
          },
        },

        -- 無効化したいファイルタイプを指定
        filetypes = {
          help = false,
          gitrebase = false,
          ["."] = false,
        },
      })
    end,
  },
}
