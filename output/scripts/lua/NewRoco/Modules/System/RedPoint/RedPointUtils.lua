local RedPointUtils = NRCClass()

local function _DefaultFuc(poinData)
  if not poinData or type(poinData) ~= "string" then
    Log.Error("pointDataStr\228\184\186\231\169\186")
    return nil
  end
  local delimiter = "."
  local subValues = {}
  for subValue in string.gmatch(poinData, "([^" .. delimiter .. "]+)") do
    table.insert(subValues, subValue)
  end
  return subValues
end

local function _PetNewSkill(poinData)
  local delimiter = "."
  local subValues = {}
  for subValue in string.gmatch(poinData, "([^" .. delimiter .. "]+)") do
    table.insert(subValues, subValue)
  end
  return subValues
end

local _ReasonPointDataSplitFuncDic = {
  [Enum.RedPointReason.RPR_PET_NEW_SKILL] = _PetNewSkill
}

function RedPointUtils.GetSplitFuncByReason(reason)
  local func
  if not reason then
    func = _DefaultFuc
  else
    func = _ReasonPointDataSplitFuncDic[reason]
    func = func or _DefaultFuc
  end
  return func
end

local function _AdvCheckInReasonDic(reasonDic, extraKey, isRoot)
  local function CheckDataHasNumInfo(splitPointData)
    local num
    
    for _, str in pairs(splitPointData) do
      local starIndex = str:find("%*[^%.]*$")
      if starIndex then
        local numberStr = str:sub(starIndex + 1)
        num = tonumber(numberStr)
      end
    end
    return num
  end
  
  local function CheckPointInfoMatchToExtraKey(pointInfoTable, extraKey, isRoot)
    local bMatch = true
    for i, value in ipairs(extraKey) do
      if value ~= pointInfoTable[i] then
        bMatch = false
        break
      end
    end
    if bMatch then
      if isRoot then
        local num = CheckDataHasNumInfo(pointInfoTable)
        return true, num
      else
        return true
      end
    end
    return false
  end
  
  local extraKeyIsNotTable = type(extraKey) ~= "table"
  for _, data in pairs(reasonDic) do
    if extraKeyIsNotTable then
      local oriPointData = data.oriPointData
      for _, p in ipairs(oriPointData) do
        if p == extraKey then
          return true
        end
      end
    else
      local hasCheckData = false
      if data.splitPointData == nil then
        hasCheckData = true
        data.splitPointData = {}
        local pointData = data.oriPointData
        local splitFunc = data.splitFunc
        local flag = false
        local num
        for i, v in pairs(pointData) do
          data.splitPointData[i] = splitFunc(v)
          local pointInfoTable = data.splitPointData[i]
          if true ~= flag then
            flag, num = CheckPointInfoMatchToExtraKey(pointInfoTable, extraKey, isRoot)
          end
        end
        if true == flag then
          return flag, num
        end
      end
      if false == hasCheckData then
        local splitPointData = data.splitPointData
        for _, pointInfoTable in pairs(splitPointData) do
          local flag, num = CheckPointInfoMatchToExtraKey(pointInfoTable, extraKey, isRoot)
          if true == flag then
            return flag, num
          end
        end
      end
    end
  end
  return false
end

function RedPointUtils.GetAdvRedCountInReasonData(data, extraKey)
  local count = 0
  if type(extraKey) ~= "table" then
    local oriPointData = data.oriPointData
    for _, p in ipairs(oriPointData) do
      if p == extraKey then
        count = count + 1
      end
    end
  else
    if data.splitPointData == nil then
      data.splitPointData = {}
      local pointData = data.oriPointData
      do
        local splitFunc = data.splitFunc
        for i, v in pairs(pointData) do
          data.splitPointData[i] = splitFunc(v)
        end
      end
    end
    local splitPointData = data.splitPointData
    for _, p in pairs(splitPointData) do
      local bMatch = true
      for i, value in ipairs(extraKey) do
        if value ~= p[i] then
          bMatch = false
          break
        end
      end
      if bMatch then
        count = count + 1
      end
    end
  end
  return count
end

function RedPointUtils.AdvCheckIsRed(rpNode, extraKey)
  local isRed, num = _AdvCheckInReasonDic(rpNode.litUpReasonDic, extraKey, true)
  isRed = isRed or _AdvCheckInReasonDic(rpNode.popReasonDic, extraKey, false)
  return isRed, num
end

function RedPointUtils.AdvCheckIsRedByExtraKeyTable(rpNode, extraKeyTable)
  local isRed = false
  for i, extraKey in ipairs(extraKeyTable) do
    if RedPointUtils.AdvCheckIsRed(rpNode, extraKey) then
      isRed = true
      break
    end
  end
  return isRed
end

return RedPointUtils
