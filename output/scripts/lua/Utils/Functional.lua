local functional = {}

function functional.partial(func, ...)
  local call_args = {
    ...
  }
  if #call_args < 1 then
    error("partial arguments count could not be 0")
  end
  return function(...)
    local args = {
      table.unpack(call_args)
    }
    for k, v in ipairs({
      ...
    }) do
      table.insert(args, #args + 1, v)
    end
    return func(table.unpack(args))
  end
end

return functional
