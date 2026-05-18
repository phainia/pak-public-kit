local function BinDataParserUnboxing(_binParser, recursion)
  local _properties = UE4.FBinDataUtils.GetPropertiesInBinDataParser(_binParser)
  
  if not _properties then
    return _binParser
  end
  local ret = {}
  for _, _propertyName in ipairs(_properties) do
    local _propertyValue = _binParser[_propertyName]
    if recursion then
      if type(_propertyValue) == "table" then
        local _propertyValueParser = BinDataUtils.GetParserFromBinData(_propertyValue)
        if not _propertyValueParser then
          local _propertyValueTable = {}
          for _, _itemV in ipairs(_propertyValue) do
            local _unboxingValue = BinDataUtils.BinDataUnboxing(_itemV, true)
            table.insert(_propertyValueTable, _unboxingValue)
          end
          ret[_propertyName] = _propertyValueTable
        else
          ret[_propertyName] = BinDataUtils.BinDataUnboxing(_propertyValue, true)
        end
      else
        ret[_propertyName] = _propertyValue
      end
    else
      ret[_propertyName] = _propertyValue
    end
  end
  return ret
end

local BinDataUtils = {}

function BinDataUtils.GetParserFromBinData(binData)
  if binData then
    local binDataType = type(binData)
    if "table" == binDataType then
      if _G.GlobalBinDataGetParser then
        return _G.GlobalBinDataGetParser(binData)
      end
      local GetDataParser = binData.GetDataParser
      if GetDataParser then
        return GetDataParser()
      end
    elseif "userdata" == binDataType then
      return binData
    end
  end
end

function BinDataUtils.BinDataUnboxing(binData, recursion)
  local _binParser = BinDataUtils.GetParserFromBinData(binData)
  if _binParser then
    return BinDataParserUnboxing(_binParser, recursion)
  end
  return binData
end

function BinDataUtils.IsPropertyExist(binData, propertyName)
  if not binData or not propertyName then
    return false
  end
  local _binParser = BinDataUtils.GetParserFromBinData(binData)
  if _binParser then
    local _properties = UE4.FBinDataUtils.GetPropertiesInBinDataParser(_binParser)
    if _properties then
      for _, _propertyName in ipairs(_properties) do
        if _propertyName == propertyName then
          return true
        end
      end
    end
  elseif rawget(binData, propertyName) then
    return true
  end
  return false
end

return BinDataUtils
