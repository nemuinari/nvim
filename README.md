# Neovim 設定概要（2026年1月更新）

### 主なプラグイン

- **Nord/Lualine**: Nordテーマ＋lualineステータスライン
- **Telescope**: ファイル/バッファ/grep/ヘルプ検索（キーマップは遅延ロード）
- **Copilot**: インラインAI補完（nvim-cmp非使用、Tabで受け入れ）
- **Oil.nvim**: ファイラ（特殊バッファ管理）
- **Treesitter**: 高速構文ハイライト・インデント
- **Mason/Mason-tool-installer**: LSP/フォーマッタ自動管理
- **nvim-lspconfig**: LSPサーバ設定
- **conform.nvim**: 保存時自動フォーマット（多言語対応）
- **lazydev.nvim**: Lua開発支援
- **dashboard**: ダッシュボードデザイン

### キーマップ早見表

- **リーダーキー**: `<Space>`
- **Telescope**: `<leader>ff` (ファイル), `<leader>fg` (grep), `<leader>fb` (バッファ), `<leader>fh` (ヘルプ)
- **パスコピー**: `<leader>cr` (相対), `<leader>ca` (絶対), `<leader>cw` (Win形式)
- **Oil.nvim**: `-` でファイラ起動
- **LSP**: `gd` (定義), `K` (ホバー), `<space>f` (フォーマット), `<space>rn` (リネーム), インレイヒント自動切替
- **Copilot**: `<Tab>` で補完受け入れ、`<M-]>`/`<M-[>` で候補移動
- **終了**: `:Q` で未保存バッファ削除＋終了、失敗時は自動で `:quit!`
