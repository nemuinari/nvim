# Neovim config overview

## Structure & Boot

- Entry: `init.lua` → `lua/config/bootstrap.lua`
	- Bootstraps `lazy.nvim` if missing.
	- Initializes `lazy` first, then defers `options`/`keybinds` to `VimEnter` for faster startup.
	- `languages` are no longer loaded at boot; they are applied via LSP setup in `lua/plugins/mason.lua`.
- OS helpers: `lua/config/platform.lua`
	- Provides clipboard, shell, and clang-format style path helpers.
	- Memoized detection (cache) to avoid repeated checks at startup.
- Options: `lua/config/options.lua`
	- Core editor options; clipboard/shell resolved via `platform`.
- Keymaps: `lua/config/keybinds.lua`
	- Leader keys are defined in `lua/config/leader.lua`.
	- Terminal navigation and path copy helpers.
	- Telescope keymaps are now defined in plugin spec (`keys`) for lazy loading.
- Languages: `lua/config/languages.lua`
	- Unified `FileType` autocmd sets indentation per language.
	- C/C++ family: clang-format on save using detected/explicit style.
- Plugins index: `lua/plugins/init.lua`
	- Aggregates plugin specs for `lazy.nvim`.
- LSP/format: `lua/plugins/mason.lua`
	- LSP servers initialized on `BufReadPre`.
	- Integrates language tweaks (formatting).
	- Inlay hints: shown in Normal mode, hidden in Insert mode; toggle auto behavior per buffer with `<leader>ih`.

## Performance

- `lazy.nvim` performance tuning in `lua/config/lazy.lua`:
	- `performance.cache.enabled = true`
	- `reset_packpath = true`
	- Disable some runtime plugins: `gzip`, `matchit`, `matchparen`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`.
	- Note: `netrwPlugin` is enabled, so `:Lex` (netrw Lexplore) works.
- Autocmd consolidation: single `FileType` handler with patterns reduces overhead.
- Plugin lazy loading:
	- LSP (`nvim-lspconfig`) loads on `BufReadPre`.
	- Telescope keymaps declared in `keys` to load on demand.
	- Copilot provides inline suggestions; `nvim-cmp` is not used.
	- ToggleTerm loads on key press (`<C-t>`, `<leader>cc`/`<leader>cx`).
- Platform memoization: clipboard/shell detection cached in `platform.lua`.

## Telescope

- Base setup in `lua/plugins/telescope.lua`.
- Keymaps are declared via `keys` (lazy), avoiding eager `require` at startup.

## Netrw

- `netrwPlugin` is active; `:Lex` / `:Lexplore` are available.
- You can still integrate Telescope/Oil-based browsers; current config prefers keeping netrw available.

## Measure Startup

Use Neovim builtin startup profiler to compare timings:

```bash
nvim --startuptime /tmp/nvim-startup.txt +qall
sed -n '1,120p' /tmp/nvim-startup.txt
```

## Windows tips

- Ensure `clang-format` is on `PATH`; if not, set `vim.g.clang_format_cmd` to its absolute path.
- Fallback style: `%LocalAppData%/nvim/lua/plugins/.clang-format`
- Clipboard: win32yank on WSL; shell prefers `pwsh`/`powershell` if available.

## 日本語概要

### 構成と起動

- エントリ: `init.lua` → `lua/config/bootstrap.lua`
	- `lazy.nvim` を必要ならブートストラップ。
	- まず `lazy` を初期化し、`options`/`keybinds` は `VimEnter` で遅延読み込みして起動を高速化。
	- `languages` は起動時には読み込まず、`lua/plugins/mason.lua` の LSP 設定経由で適用。
- OS ヘルパー: `lua/config/platform.lua`
	- クリップボード/シェル/clang-format スタイルの検出を提供。
	- 起動時の負荷低減のためメモ化（キャッシュ）済み。
- オプション: `lua/config/options.lua`
	- 基本設定。クリップボード/シェルは `platform` から取得。
- キーマップ: `lua/config/keybinds.lua`
	- リーダーキーは `lua/config/leader.lua` に定義。
	- ターミナル移動、パスコピーなどの汎用マップ。
	- Telescope のキーマップはプラグイン側の `keys` で遅延定義。
- 言語設定: `lua/config/languages.lua`
	- 1 つの `FileType` autocmd で言語別インデントを設定。
	- C/C++ 系は保存時に `clang-format` を適用。
- プラグイン索引: `lua/plugins/init.lua`
	- lazy 用のプラグイン一覧。
- LSP/フォーマット: `lua/plugins/mason.lua`
	- LSP は `BufReadPre` で初期化。
	- フォーマット連携などの設定を含む。
	- インレイヒント: ノーマルモードで表示、挿入モードで非表示。バッファ単位で `<leader>ih` で自動制御 ON/OFF を切替可能。

### パフォーマンス

- `lua/config/lazy.lua` の最適化:
	- `performance.cache.enabled = true`
	- `reset_packpath = true`
	- ランタイムプラグインの一部を無効化: `gzip`, `matchit`, `matchparen`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`。
	- 備考: `netrwPlugin` は有効（`:Lex` が動作）。
- autocmd の集約とプラグイン遅延ロードで起動時間を短縮。
- `platform.lua` による検出結果のキャッシュで再計算を削減。

 - Copilot はインライン提案を利用し、`nvim-cmp` は使用していません。
 - ToggleTerm はキー押下でロード（`<C-t>` や `<leader>cc`/`<leader>cx`）。

### Telescope

- 基本設定は `lua/plugins/telescope.lua`。
- キーマップは `keys` 経由で遅延読み込みされます。

### Netrw

- `netrwPlugin` を有効にしており、`:Lex`/`:Lexplore` が利用可能です。

### 起動時間の計測

```bash
nvim --startuptime /tmp/nvim-startup.txt +qall
sed -n '1,120p' /tmp/nvim-startup.txt
```

### Windows メモ

- `clang-format` が `PATH` にない場合は `vim.g.clang_format_cmd` に絶対パスを設定。
- フォールバックスタイル: `%LocalAppData%/nvim/lua/plugins/.clang-format`
- クリップボード: WSL は `win32yank`、シェルは `pwsh`/`powershell` を優先。

## Keymaps Quick Reference

- Leader: Space (`<Space>`)
- Search (Telescope):
	- `<leader>ff`: Find files
	- `<leader>fg`: Live grep
	- `<leader>fb`: Buffers
	- `<leader>fh`: Help tags
- Highlight:
	- `<Esc><Esc>`: Clear search highlight
- Paths:
	- `<leader>cr`: Copy relative path
	- `<leader>ca`: Copy absolute path
	- `<leader>cw`: Copy Windows-style path (\)
- Terminal:
	- `<C-t>`: ToggleTerm open (horizontal)
	- In terminal mode:
		- `<Esc>`: Exit to Normal
		- `<C-h>/<C-j>/<C-k>/<C-l>`: Window navigation
		- `<C-j>`: Resize -1 (shrink) [toggleterm]
		- `<C-k>`: Resize +1 (grow) [toggleterm]
- LSP (on LspAttach):
	- `gd`: Go to definition
	- `K`: Hover
	- `<space>f`: Format (async)
	- `<space>rn`: Rename symbol
	- `<leader>ih`: Toggle inlay hints auto behavior (Normal=on, Insert=off)
- Copilot CLI:
	- `<leader>cc`: Toggle Copilot CLI tab
	- `<leader>cx`: Close Copilot CLI session
	- Note: If standalone `copilot` is available, it runs directly; otherwise falls back to `gh copilot` extension.
- Netrw:
	- `:Lex` / `:Lexplore`: File explorer

## 基本ショートカット（日本語）

- リーダーキー: スペース（`<Space>`）
- 検索（Telescope）:
	- `<leader>ff`: ファイル検索
	- `<leader>fg`: ライブグレップ
	- `<leader>fb`: バッファ一覧
	- `<leader>fh`: ヘルプタグ検索
- ハイライト:
	- `<Esc><Esc>`: 検索ハイライト解除
- パスコピー:
	- `<leader>cr`: 相対パスをコピー
	- `<leader>ca`: 絶対パスをコピー
	- `<leader>cw`: Windows形式のパスをコピー（\）
- ターミナル:
	- `<C-t>`: ToggleTerm を開く（水平分割）
	- 端末モード:
		- `<Esc>`: ノーマルモードへ
		- `<C-h>/<C-j>/<C-k>/<C-l>`: ウィンドウ移動
		- `<C-j>`: 高さを縮小（toggleterm）
		- `<C-k>`: 高さを拡大（toggleterm）
- LSP（接続時）:
	- `gd`: 定義へ移動
	- `K`: ホバー
	- `<space>f`: フォーマット（非同期）
	- `<space>rn`: リネーム
	- `<leader>ih`: インレイヒントの自動制御トグル（ノーマル=表示、挿入=非表示）
- Copilot CLI:
	- `<leader>cc`: Copilot CLI をタブ表示/非表示
	- `<leader>cx`: Copilot CLI セッションを終了
	- 備考: スタンドアロンの `copilot` があればそれを起動、無ければ `gh copilot` 拡張へフォールバックします。
- Netrw:
	- `:Lex` / `:Lexplore`: ファイルブラウザ

 - 終了:
 	- `:q`: 通常終了。失敗時は自動で `:quit!` にフォールバックするラッパーを用意。
