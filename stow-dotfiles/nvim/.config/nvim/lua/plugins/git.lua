local function keymapOptions(desc, opt)
	local default = {
		noremap = true,
		silent = true,
		nowait = true,
		desc = desc,
	}
	if opt then
		for k, v in pairs(opt) do
			default[k] = v
		end
	end
	return default
end

local keymap = vim.keymap.set

return {
	"lewis6991/gitsigns.nvim",
	config = function()
		local gs = require('gitsigns')
		gs.setup {}
		keymap('n', ']c', function()
			if vim.wo.diff then return ']c' end
			vim.schedule(function() gs.next_hunk() end)
			return '<Ignore>'
		end, keymapOptions("Next Hunk", { expr = true }))
		keymap('n', '[c', function()
			if vim.wo.diff then return '[c' end
			vim.schedule(function() gs.prev_hunk() end)
			return '<Ignore>'
		end, keymapOptions("Prev Hunk", { expr = true }))
		keymap('n', '<leader>hs', gs.stage_hunk, keymapOptions("Stage Hunk"))
		keymap('n', '<leader>hr', gs.reset_hunk, keymapOptions("Reset Hunk"))
		keymap('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
			keymapOptions("Stage Hunk"))
		keymap('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
			keymapOptions("Reset Hunk"))
		keymap('n', '<leader>hS', gs.stage_buffer, keymapOptions("Stage Buffer"))
		keymap('n', '<leader>hu', gs.undo_stage_hunk, keymapOptions("Undo Stage Hunk"))
		keymap('n', '<leader>hR', gs.reset_buffer, keymapOptions("Reset Buffer"))
		keymap('n', '<leader>hp', gs.preview_hunk, keymapOptions("Preview Hunk"))
		keymap('n', '<leader>hb', function() gs.blame_line { full = true } end, keymapOptions("Blame Line"))
		keymap('n', '<leader>hB', gs.toggle_current_line_blame, keymapOptions("Toggle Blame"))
		keymap('n', '<leader>hd', gs.diffthis, keymapOptions("Diff This"))
		keymap('n', '<leader>hD', function() gs.diffthis('HEAD') end, keymapOptions("Diff HEAD~"))
		keymap('n', '<leader>hP', gs.toggle_deleted, keymapOptions("Toggle Deleted"))
		keymap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
	end
}
