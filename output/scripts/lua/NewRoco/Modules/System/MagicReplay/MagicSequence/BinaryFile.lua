local BinaryFile = _G.Class("BinaryFile")

function BinaryFile:Ctor(path, mode)
  local bin_mode = mode:gsub("r", "rb"):gsub("w", "wb"):gsub("a", "ab")
  self.path = path
  self.mode = bin_mode
  self.file = nil
end

function BinaryFile:CreateFile()
  self.file = UE4.File()
  local bSuccess = self.file:Open(self.path, self.mode)
  if not bSuccess then
    Log.Error("[MagicSequence][BinaryFile] open file error,", self.path, self.mode)
    return false
  end
  return true
end

function BinaryFile:InWriteMode()
  if self.mode and (self.mode:find("w") or self.mode:find("a")) then
    return true
  end
  return false
end

function BinaryFile:InReadMode()
  if self.mode and self.mode:find("r") then
    return true
  end
  return false
end

function BinaryFile:GetSize()
  if self.file then
    return self.file:TotalSize()
  end
  return 0
end

function BinaryFile:WriteRaw(bin_data)
  if self.file then
    self.file:Write(bin_data)
  end
  return 0
end

function BinaryFile:ReadRaw(len)
  if self.file then
    return self.file:Read(len)
  end
  return nil
end

function BinaryFile:WriteNumber(num)
  if self.file and type(num) == "number" then
    return self.file:Write(num)
  end
  return 0
end

function BinaryFile:ReadNumber()
  if self.file then
    return self.file:Read("n")
  end
  return nil
end

function BinaryFile:WriteString(str)
  if self.file and type(str) == "string" then
    local len = #str
    local totalSize = self.file:Write(len)
    totalSize = totalSize + self.file:Write(str)
    return totalSize
  end
  return 0
end

function BinaryFile:ReadString()
  if self.file then
    local len = self.file:Read("n")
    local str = self.file:Read(len)
    return str
  end
  return nil
end

function BinaryFile:Seek(offset)
  if self.file then
    self.file:Seek(self.mode, offset or 0)
    return true
  end
  return false
end

function BinaryFile:Flush()
  if self.file then
    self.file:Flush()
  end
end

function BinaryFile:Close()
  if self.file then
    self.file:Close()
    self.file = nil
  end
end

function BinaryFile:__gc()
  self:Close()
end

return BinaryFile
