local StringCache = {}
local cache = setmetatable({}, {__mode = "v"})

function StringCache.intern(str)
  if type(str) ~= "string" then
    error("StringCache.intern expects a string argument")
  end
  local cached = cache[str]
  if cached then
    return cached
  end
  cache[str] = str
  return str
end

function StringCache.get_stats()
  local count = 0
  for _ in pairs(cache) do
    count = count + 1
  end
  return {cached_strings = count, cache_table = cache}
end

function StringCache.clear()
  for k in pairs(cache) do
    cache[k] = nil
  end
end

function StringCache.is_cached(str)
  if type(str) ~= "string" then
    return false
  end
  return nil ~= cache[str]
end

return StringCache
