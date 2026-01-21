# Neovim Configuration (2026.01)

## keymaps

### 共通

| Key         | Action                |
| :---------- | :-------------------- |
| `<Space>`   | Leader Key            |
| `<leader>e` | Oil (Floating) を開く |
| `-`         | Oil (Normal) を開く   |

### Oil.nvim 内 (explorer)

| Key         | Action                              |
| :---------- | :---------------------------------- |
| `<CR>`      | ファイルを開く / ディレクトリに入る |
| `_`         | カレントディレクトリ (CWD) を開く   |
| `g.`        | 隠しファイルの表示/非表示           |
| `<leader>g` | このディレクトリ内を Grep 検索      |

### Telescope (History/Buffer)

| Key          | Action                      |
| :----------- | :-------------------------- |
| `<leader>fr` | 最近開いたファイル (Recent) |
| `<leader>fb` | バッファ一覧                |
| `<leader>fh` | ヘルプ検索                  |

### パスコピー

| Key          | Action                  |
| :----------- | :---------------------- |
| `<leader>cr` | 相対パスをコピー        |
| `<leader>ca` | 絶対パスをコピー        |
| `<leader>cw` | Windows形式パスをコピー |

---

## External Dependencies

```powershell
# Windows (PowerShell)
winget install BurntSushi.ripgrep.MSVC
```
