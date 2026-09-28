-- Central low-power-mode flag for Raspberry Pi / slow ARM boards.
-- On: aarch64/armv7l Linux (Pi), or NVIM_PROFILE=pi, or NVIM_PI=1.
-- Off: everything else (your Mac keeps full UX).
-- Usage in a plugin spec: `enabled = not require("is_pi").is_pi`
local M = {}

local machine = vim.uv.os_uname().machine or ""
local sysname = vim.uv.os_uname().sysname or ""
local profile = vim.env.NVIM_PROFILE or ""
local flag = vim.env.NVIM_PI or ""

M.is_pi = profile == "pi"
	or flag == "1"
	or (
		sysname == "Linux"
		and (machine == "aarch64" or machine == "armv7l" or machine:match("^arm"))
	)

return M
