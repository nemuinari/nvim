# Neovim 設定概要（2026年1月更新）

### 構成

- **エントリポイント**: [`init.lua`](nvim/init.lua) → [`lua/config/bootstrap.lua`](nvim/lua/config/bootstrap.lua)
  - `lazy.nvim` 自動ブートストラップ
  - Lua module loader cache有効化
  - プラグイン初期化後、`options`/`keybinds`/`languages`をロード
  - 言語設定はLSPセットアップ時に適用（[`lua/plugins/mason.lua`](nvim/lua/plugins/mason.lua)）

- **OS/プラットフォーム対応**: [`lua/config/platform.lua`](nvim/lua/config/platform.lua)
  - クリップボード/シェル/clang-formatスタイル自動検出（キャッシュ化）
  - Windows/WSL/Wayland/X11等の環境自動判別

- **エディタ設定**: [`lua/config/options.lua`](nvim/lua/config/options.lua)
  - 表示/インデント/検索/エンコーディング/診断/エディタ挙動等を一括管理
  - クリップボード/シェルは `platform` 依存

- **キーマップ**: [`lua/config/keybinds.lua`](nvim/lua/config/keybinds.lua)
  - リーダーキーは [`lua/config/leader.lua`](nvim/lua/config/leader.lua)
  - ターミナル操作/パスコピー/終了コマンド等の汎用マップ
  - Telescope等一部はプラグイン側で遅延定義

- **言語別設定**: [`lua/config/languages.lua`](nvim/lua/config/languages.lua)
  - 主要言語のインデント/保存時フォーマット（C/C++: clang-format, Rust: rustfmt, Python: black/isort, JS/TS: prettier等）
  - conform.nvim有効時はLSP/外部ツールで自動整形

- **プラグイン管理**: [`lua/plugins/init.lua`](nvim/lua/plugins/init.lua)
  - lazy.nvim用プラグイン一覧（下記参照）

- **LSP/フォーマット**: [`lua/plugins/mason.lua`](nvim/lua/plugins/mason.lua)
  - LSPサーバは`BufReadPre`で初期化
  - インレイヒントはノーマル時表示・挿入時非表示（自動切替/手動切替可）
  - Mason/ToolInstallerで各種フォーマッタ・LSP自動管理
  - WindowsはPATH自動調整

---

### パフォーマンス最適化

- [`lua/config/lazy.lua`](nvim/lua/config/lazy.lua) で `performance.cache.enabled = true` など高速化
- 一部ランタイムプラグイン無効化（gzip, matchit, matchparen, tarPlugin, tutor, zipPlugin, tohtml等）
- autocmd集約・プラグイン遅延ロード
- プラットフォーム検出はキャッシュ利用

---

### 主なプラグイン

- **Nord/Lualine**: Nordテーマ＋lualineステータスライン
- **Telescope**: ファイル/バッファ/grep/ヘルプ検索（キーマップは遅延ロード）
- **Copilot**: インラインAI補完（nvim-cmp非使用、Tabで受け入れ）
- **Oil.nvim**: ファイラ（Netrw代替、特殊バッファ管理）
- **Treesitter**: 高速構文ハイライト・インデント
- **Mason/Mason-tool-installer**: LSP/フォーマッタ自動管理
- **nvim-lspconfig**: LSPサーバ設定
- **conform.nvim**: 保存時自動フォーマット（多言語対応）
- **lazydev.nvim**: Lua開発支援
※ToggleTermは現状未導入、Oil.nvimがファイラ役割

---

### 起動時間計測

```bash
nvim --startuptime /tmp/nvim-startup.txt +qall
sed -n '1,120p' /tmp/nvim-startup.txt
```

---

### Windows/WSL Tips

- `clang-format`/`rustfmt` がPATHに無い場合は `vim.g.clang_format_cmd`/`vim.g.rustfmt_cmd` で絶対パス指定
- クリップボード: WSLは`win32yank`、Waylandは`wl-clipboard`、X11は`xclip`/`xsel`自動判別
- シェル: Windowsは`powershell`優先
- 今後、WezTermに移行予定

---

### キーマップ早見表

- **リーダーキー**: `<Space>`
- **Telescope**: `<leader>ff` (ファイル), `<leader>fg` (grep), `<leader>fb` (バッファ), `<leader>fh` (ヘルプ)
- **パスコピー**: `<leader>cr` (相対), `<leader>ca` (絶対), `<leader>cw` (Win形式)
- **ターミナル**: `<C-t>` で開閉（※現状未導入）
- **Oil.nvim**: `-` でファイラ起動
- **LSP**: `gd` (定義), `K` (ホバー), `<space>f` (フォーマット), `<space>rn` (リネーム), インレイヒント自動切替
- **Copilot**: `<Tab>` で補完受け入れ、`<M-]>`/`<M-[>` で候補移動
- **終了**: `:Q` で未保存バッファ削除＋終了、失敗時は自動で `:quit!`
- **Netrw**: 標準無効（Oil.nvim推奨）

---

### 終了

- `:Q` で未保存バッファ削除＋終了。失敗時は自動で `:quit!` にフォールバック

---
