local M = {}

M.options = {}

M.LspStatus = function()
	local clients = vim.lsp.get_clients()
	local buf_clients = {}

	for _, client in ipairs(clients) do
		if client.attached_buffers[vim.api.nvim_get_current_buf()] then
			if client.name ~= "GitHub Copilot" then
				table.insert(buf_clients, client.name)
			end
		end
	end

	if #buf_clients == 0 then
		return nil
	end

	return "LSP: " .. table.concat(buf_clients, ", ")
end

M.FormatterStatus = function()
	local conform = require("conform")
	local bufnr = vim.api.nvim_get_current_buf()
	local formatters, _ = conform.list_formatters_to_run(bufnr)

	if #formatters > 0 then
		local formatter_names = {}
		for _, formatter in ipairs(formatters) do
			table.insert(formatter_names, formatter.name)
		end
		return "FMT: " .. table.concat(formatter_names, ", ")
	else
		return nil
	end
end

M.Display = function()
	local lsp = M.LspStatus()
	local formatter = M.FormatterStatus()

	if lsp == nil and formatter then
		return formatter
	elseif formatter == nil and lsp then
		return lsp
	elseif formatter == nil and lsp == nil then
		return ""
	else
		return lsp .. " " .. formatter
	end
end

M._options = nil

M.setup = function(options)
	local hidden_filetypes = {
		Avante = true,
		AvanteInput = true,
		AvanteSelectedFiles = true,
	}

	vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "WinEnter", "BufEnter" }, {
		callback = function()
			if hidden_filetypes[vim.bo.filetype] then
				vim.opt.laststatus = 3
			else
				vim.opt.laststatus = 2
			end
		end,
	})

	vim.o.statusline = "%f" -- File name
		.. " %m" -- Modified flag
		.. " %r" -- Read-only flag
		-- .. " %y" -- File type
		.. " %= " -- Right-aligned section
		.. '%{v:lua.require("statusbar").Display()}' -- Custom Display function
		.. " | %p%%" -- Percentage through the file
		.. " %l:%c" -- Line and column
end

return M
