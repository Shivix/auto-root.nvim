-- This first version requires the project to be a git repo. (git init all the things)
local function root_dir()
    local current_dir = vim.fn.expand("%:p:h")
    local home_dir = os.getenv("HOME")

    if not current_dir:find(home_dir) then
        return
    end

    while current_dir ~= home_dir do
        local file = io.open(current_dir .. "/.git", "r")
        if file ~= nil then
            io.close(file)
            vim.api.nvim_set_current_dir(current_dir)
            return
        end
        -- set to parent directory
        current_dir = current_dir:sub(1, current_dir:match(".*/()") - 2)
    end
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = root_dir,
    group = "main_group",
})

-- A second version that doesn't require the project to be a git repo. Personally I prefer the
-- first option so i'm not reading a bunch of files everytime I switch buffer, but I'm sure many
-- will prefer so I have included it also.
local root_patterns = {
    ".git",
    "Makefile",
    "CMakeLists.txt",
    "go.mod",
    "Cargo.toml",
    -- etc... add whichever works for your languages
}

local function flexible_root_dir()
    local current_dir = vim.fn.expand("%:p:h")
    local home_dir = os.getenv("HOME")
    local best_dir = nil

    if not current_dir:find(home_dir) then
        return
    end

    while current_dir ~= home_dir do
        for _, dir in pairs(root_patterns) do
            local file_name = current_dir .. "/" .. dir
            local file = io.open(file_name, "r")
            if file ~= nil then
                io.close(file)
                best_dir = current_dir
            end
        end
        -- set to parent directory
        current_dir = current_dir:sub(1, current_dir:match(".*/()") - 2)
    end
    if best_dir ~= nil then
        vim.api.nvim_set_current_dir(best_dir)
    end
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = flexible_root_dir,
    group = "main_group",
})
