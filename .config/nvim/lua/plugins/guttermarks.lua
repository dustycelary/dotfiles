-- guttermarks.nvim — shows vim marks (a-z, A-Z) as indicators in the sign column.
-- No config needed; marks appear automatically as you set them with m{letter}.
return {
  "dimtion/guttermarks.nvim",
  event = { "BufReadPost", "BufNewFile", "BufWritePre", "FileType" },
}
