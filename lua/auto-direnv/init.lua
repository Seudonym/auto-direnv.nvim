local M = {}

--- @class AutoDirenvConfig
--- @field silent? boolean

--- @type AutoDirenvConfig
local default_config = {
    silent = false,
}

--- @enum RcStatus
local RcStatus = {
    ALLOWED = 0,
    BLOCKED = 1,
    DENIED = 2,
    ABSENT = 3,
}

local status_map = {
    [0] = RcStatus.ALLOWED,
    [1] = RcStatus.BLOCKED,
    [2] = RcStatus.DENIED,
}

--- Notify status of .envrc
---@param rc_status RcStatus
local notify_rc_status = function(rc_status)
    local message = nil
    if rc_status == RcStatus.ALLOWED then
        message = "envrc was found in this directory. Loading direnv"
    elseif rc_status == RcStatus.BLOCKED then
        message = ".envrc was found in this directory but it has not been allowed"
    elseif rc_status == RcStatus.DENIED then
        message = ".envrc was found in this directory but it has been explicity blocked"
    end
    vim.notify(message, vim.log.levels.INFO)
end

--- Checks direnv status and returns the corresponding enum value
---@param dir string: Directory to check in
---@return RcStatus
local function get_rc_status(dir)
    local _direnv_status_json = vim.system({ "direnv", "status", "--json" }, { cwd = dir }):wait()
    local direnv_status = vim.json.decode(_direnv_status_json.stdout)

    local found_rc = direnv_status.state.foundRC
    if found_rc == vim.NIL then
        return RcStatus.ABSENT
    end

    local _rc_status = found_rc.allowed
    return status_map[_rc_status] or RcStatus.ABSENT
end

--- Get env variables and update
---@param dir string: Directory to check in
local update_env = function(dir)
    local _direnv_export_json = vim.system({ "direnv", "export", "json" }, { cwd = dir }):wait()

    local stdout = _direnv_export_json.stdout
    if stdout == "" then
        return
    end

    local decoded = vim.json.decode(stdout)

    for key, value in pairs(decoded) do
        if value == "" or value == vim.NIL then
            vim.env[key] = nil
        else
            vim.env[key] = value
        end
    end
end

---@param opts? AutoDirenvConfig
M.setup = function(opts)
    local config = vim.tbl_deep_extend("force", default_config, opts or {})
    local group = vim.api.nvim_create_augroup("DirenvChecker", { clear = true })
    vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
        group = group,
        callback = function(args)
            local target_dir = args.event == "VimEnter" and vim.fn.getcwd() or args.file
            local rc_status = get_rc_status(target_dir)

            if not config.silent and rc_status ~= RcStatus.ABSENT then
                notify_rc_status(rc_status)
            end

            if rc_status == RcStatus.ABSENT or rc_status == RcStatus.ALLOWED then
                update_env(target_dir)
            end
        end,
    })
end

return M
