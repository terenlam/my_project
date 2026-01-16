local function unsnooze_tasks()
    -- new comment
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    -- Get today's date in YYYY-MM-DD format
    local today = os.date("%Y-%m-%d")

    local new_lines = {}
    local in_snoozed = false

    -- Parse the buffer
    for _, line in ipairs(lines) do
        if line:match("^# Snoozed") then
            in_snoozed = true
            table.insert(new_lines, line)
        elseif line:match("^#") then
            -- Other headers end the snoozed section
            in_snoozed = false
            table.insert(new_lines, line)
        elseif in_snoozed and line:match("%S") then
            -- Non-empty task line in Snoozed section
            local snoozed_date = line:match("%(@ ?(%d%d%d%d%-%d%d%-%d%d)%)")

            if snoozed_date and snoozed_date <= today then
                -- Remove the snoozed date pattern (with optional space and trailing space)
                local updated_line = line:gsub("%(@%s?%d%d%d%d%-%d%d%-%d%d%)%s*", "")
                table.insert(new_lines, updated_line)
            else
                -- Keep the line as is
                table.insert(new_lines, line)
            end
        else
            -- All other lines (empty lines, other sections, etc.)
            table.insert(new_lines, line)
        end
    end

    -- Set the buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
end

vim.api.nvim_create_user_command("UnsnoozeTasks", function()
    unsnooze_tasks()
end, {})

-- Produced by Claude (Extended thinking) using the prompt below.
--[[
Create a script that does the following.
- For each task under `# Snoozed`, check if the snoozed date `(@YYYY-MM-DD)` is ≤ today's date.
    - If true, remove the snoozed date.
    - If false, do nothing.
- For example, here is a sample task list.
```md
---
id: 14000000000001
title: task list sample 1
---

# To-do

2025-12-31 [20251105143022](20251105143022.md) Complete year-end documentation
2026-01-15 [20250920094511](20250920094511.md) PHA1850 Midterm exam
2026-01-20 Schedule follow-up appointments

# Snoozed

(@2025-12-06) PHA1920 Quiz preparation
(@2026-01-06) 2026-01-25 PHA1920 Quiz preparation
(@2026-06-01) Update project documentation
```
If today's date is 2026-01-06, running the second script on the block above should return the block below.
```md
---
id: 14000000000001
title: task list sample 1
---

# To-do

2025-12-31 [20251105143022](20251105143022.md) Complete year-end documentation
2026-01-15 [20250920094511](20250920094511.md) PHA1850 Midterm exam
2026-01-20 Schedule follow-up appointments

# Snoozed

PHA1920 Quiz preparation
2026-01-25 PHA1920 Quiz preparation
(@2026-06-01) Update project documentation
```
--]]
