local M = {}

function M.parse_tests(file)
  local test_titles = {}
  local nesting_levels = {} -- A stack to keep track of nesting levels
  local line_number = 1

  for line in file:lines() do
    local indent = line:match '^%s*'
    local block_type, block_name = line:match '(%a+)%s*%([\'"]([^\'"]+)[\'"],'

    if block_type == 'describe' then
      nesting_levels[#nesting_levels + 1] = #indent / 2 -- Assuming 2 spaces for each indentation level
      table.insert(
        test_titles,
        {
          line = line_number,
          description = 'Describe: ' .. block_name,
          nesting_level = #nesting_levels - 1,
          block_type = block_type,
        }
      )
    elseif block_type == 'it' or block_type == 'test' then
      table.insert(
        test_titles,
        { line = line_number, description = 'Test: ' .. block_name, nesting_level = #nesting_levels, block_type = 'test' }
      )
    end

    -- Look for a closing brace at the same indentation level as the last describe block
    if #nesting_levels > 0 and line:match '^%s*%}' then
      local closing_brace_indent = line:match('^%s*'):len()
      local last_describe_indent = nesting_levels[#nesting_levels] * 2 -- Multiply by 2 to account for 2 spaces per indentation level
      if closing_brace_indent == last_describe_indent then
        nesting_levels[#nesting_levels] = nil
      end
    end

    line_number = line_number + 1
  end

  -- Determine if a test is the last at its nesting level
  for i = 1, #test_titles do
    if i == #test_titles or test_titles[i].nesting_level > test_titles[i + 1].nesting_level then
      test_titles[i].is_last_at_level = true
    else
      test_titles[i].is_last_at_level = false
    end

    -- Determine if a test is the final entry of all tests
    if i == #test_titles then
      test_titles[i].is_final_entry = true
    else
      test_titles[i].is_final_entry = false
    end
  end

  return test_titles
end

return M
