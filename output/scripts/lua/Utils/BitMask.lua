local Bitmask = {}
Bitmask.__index = Bitmask

function Bitmask.new(value)
  value = value or 0
  return setmetatable({value = value}, Bitmask)
end

function Bitmask:mark(bit)
  self.value = self.value | 1 << bit
  return self
end

function Bitmask:clear(bit)
  self.value = self.value & ~(1 << bit)
  return self
end

function Bitmask:set(bit, IsTrue)
  if IsTrue then
    return self:mark(bit)
  else
    return self:clear(bit)
  end
end

function Bitmask:toggle(bit)
  self.value = self.value ~ 1 << bit
  return self
end

function Bitmask:check(bit)
  return 0 ~= self.value & 1 << bit
end

function Bitmask:any()
  return 0 ~= self.value
end

function Bitmask.__eq(a, b)
  if type(a) == "table" and getmetatable(a) == Bitmask then
    return 0 ~= a.value
  else
    return false
  end
end

function Bitmask:__tostring()
  local parts = {}
  for i = 31, 0, -1 do
    table.insert(parts, self:check(i) and "1" or "0")
  end
  return "Bitmask(" .. table.concat(parts) .. ")"
end

function Bitmask:toCustomString()
  local names = {
    [0] = "FLAG_A",
    [1] = "FLAG_B",
    [2] = "FLAG_C",
    [3] = "FLAG_D"
  }
  local active_flags = {}
  for bit, name in pairs(names) do
    if self:check(bit) then
      table.insert(active_flags, name)
    end
  end
  if 0 == #active_flags then
    return "NO_FLAGS"
  else
    return table.concat(active_flags, " | ")
  end
end

function Bitmask:bits()
  local bits_set = {}
  for i = 0, 31 do
    if self:check(i) then
      table.insert(bits_set, i)
    end
  end
  return bits_set
end

return setmetatable(Bitmask, {
  __call = function(_, value)
    return Bitmask.new(value)
  end
})
