local BitSwitch = {}
BitSwitch.__index = BitSwitch
local StringCache = require("Utils.StringCache")

function BitSwitch.new(name)
  local self = setmetatable({}, BitSwitch)
  self._name = StringCache.intern(name or "UnnamedBitSwitch")
  self._state = 0
  self._label_to_bit = {}
  self._bit_to_label = {}
  self._available_bits = {}
  self._next_bit = 0
  for i = 0, 31 do
    table.insert(self._available_bits, i)
  end
  return self
end

function BitSwitch:get_name()
  return self._name
end

function BitSwitch:set_name(name)
  if type(name) ~= "string" then
    error("Name must be a string")
  end
  self._name = StringCache.intern(name)
end

function BitSwitch:_get_available_bit()
  if 0 == #self._available_bits then
    error("No available bits (maximum 32 switches supported)")
  end
  return table.remove(self._available_bits, 1)
end

function BitSwitch:_release_bit(bit_index)
  table.insert(self._available_bits, bit_index)
  table.sort(self._available_bits)
end

function BitSwitch:open(label)
  if type(label) ~= "string" then
    error("Label must be a string")
  end
  local cached_label = StringCache.intern(label)
  local bit_index = self._label_to_bit[cached_label]
  if bit_index then
    if 0 ~= self._state & 1 << bit_index then
      return false
    else
      self._state = self._state | 1 << bit_index
      return true
    end
  else
    bit_index = self:_get_available_bit()
    self._label_to_bit[cached_label] = bit_index
    self._bit_to_label[bit_index] = cached_label
    self._state = self._state | 1 << bit_index
    return true
  end
end

function BitSwitch:close(label)
  if type(label) ~= "string" then
    error("Label must be a string")
  end
  local cached_label = StringCache.intern(label)
  local bit_index = self._label_to_bit[cached_label]
  if not bit_index then
    return false
  end
  if 0 == self._state & 1 << bit_index then
    return false
  end
  self._state = self._state & ~(1 << bit_index)
  self._label_to_bit[cached_label] = nil
  self._bit_to_label[bit_index] = nil
  self:_release_bit(bit_index)
  return true
end

function BitSwitch:is_open(label)
  if not label then
    return self._state > 0
  end
  if type(label) ~= "string" then
    error("Label must be a string")
  end
  local cached_label = StringCache.intern(label)
  local bit_index = self._label_to_bit[cached_label]
  if not bit_index then
    return false
  end
  return 0 ~= self._state & 1 << bit_index
end

function BitSwitch:get_open_labels()
  local open_labels = {}
  for bit_index = 0, 31 do
    if 0 ~= self._state & 1 << bit_index then
      local label = self._bit_to_label[bit_index]
      if label then
        table.insert(open_labels, {label = label, bit_index = bit_index})
      end
    end
  end
  table.sort(open_labels, function(a, b)
    return a.bit_index < b.bit_index
  end)
  return open_labels
end

function BitSwitch:get_open_label_names()
  local names = {}
  local open_labels = self:get_open_labels()
  for _, info in ipairs(open_labels) do
    table.insert(names, string.format("[%s]", info.label))
  end
  return names
end

function BitSwitch:get_open_count()
  local count = 0
  for bit_index = 0, 31 do
    if 0 ~= self._state & 1 << bit_index then
      count = count + 1
    end
  end
  return count
end

function BitSwitch:get_allocated_count()
  local count = 0
  for _ in pairs(self._label_to_bit) do
    count = count + 1
  end
  return count
end

function BitSwitch:get_available_count()
  return #self._available_bits
end

function BitSwitch:has_any_open()
  return 0 ~= self._state
end

function BitSwitch:reset()
  local name = self._name
  self._state = 0
  self._label_to_bit = {}
  self._bit_to_label = {}
  self._available_bits = {}
  self._next_bit = 0
  for i = 0, 31 do
    table.insert(self._available_bits, i)
  end
  self._name = name
end

function BitSwitch:get_stats()
  return {
    name = self._name,
    state_value = self._state,
    open_count = self:get_open_count(),
    allocated_count = self:get_allocated_count(),
    available_count = self:get_available_count(),
    open_labels = self:get_open_label_names()
  }
end

function BitSwitch:get_detailed_stats()
  local basic_stats = self:get_stats()
  local cache_stats = StringCache.get_stats()
  return {
    bitswitch = basic_stats,
    string_cache = {
      cached_strings = cache_stats.cached_strings,
      memory_optimized = true
    }
  }
end

function BitSwitch:_debug_get_internal_state()
  return {
    name = self._name,
    state = self._state,
    label_to_bit = self._label_to_bit,
    bit_to_label = self._bit_to_label,
    available_bits = self._available_bits,
    next_bit = self._next_bit
  }
end

function BitSwitch:__tostring()
  local open_names = self:get_open_label_names()
  if #open_names > 0 then
    return string.format("[%s]:%s", self._name, table.concat(open_names, ", "))
  else
    return string.format("[%s]:Empty", self._name)
  end
end

return BitSwitch
