require ("fikolis.remap")
require ("fikolis.set")
require ("fikolis.packer")


-- Set file type for YAML files with .yaml and .yml extensions
vim.api.nvim_exec([[
    augroup FileTypeYAML
        autocmd!
        autocmd BufNewFile,BufRead */ansible/*.yaml,*/ansible/*.yml setl ft=yaml.ansible
    augroup END
]], false)
