print("Lua VERSION:", _VERSION)

local function WeakTable(table, mode)
  return setmetatable(table or {}, {
    __mode = mode or "kv"
  })
end

local function getfenv(f)
  if type(f) == "function" then
    local name, value = debug.getupvalue(f, 1)
    if "_ENV" == name then
      return value
    else
      return _ENV
    end
  end
end

local function setfenv(f, Env)
  if type(f) == "function" then
    local name, value = debug.getupvalue(f, 1)
    if "_ENV" == name then
      debug.setupvalue(f, 1, Env)
    end
  end
end

debug.setfenv = setfenv
local OriRequire = require
local print = Log.Debug
local HotFix = {}
HotFix.loadedFileList = {}
HotFix.IsAutoUpdateUpvalue = true
HotFix.AutoHotFixFileInjectFunction = nil
HotFix.UpdatedFunctions = {}
WeakTable(HotFix.UpdatedFunctions)
HotFix.IsEnableHotFix = true
HotFix.IsEnableReload = true
HotFix.SkipTable = {}
HotFix.SkipFunction = {}

function HotFix.InitSkipTable()
  HotFix.SkipTable[debug] = true
end

function HotFix.InitSkipFunction()
  HotFix.SkipFunction.__index = true
  HotFix.SkipFunction.__newindex = true
  HotFix.SkipFunction.dofile = true
  HotFix.SkipFunction.load = true
  HotFix.SkipFunction.pcall = true
  HotFix.SkipFunction.tostring = true
  HotFix.SkipFunction.rawset = true
  HotFix.SkipFunction.assert = true
  HotFix.SkipFunction.coroutine = true
  HotFix.SkipFunction.getmetatable = true
  HotFix.SkipFunction.tonumber = true
  HotFix.SkipFunction.xpcall = true
  HotFix.SkipFunction.setmetatable = true
  HotFix.SkipFunction.collectgarbage = true
  HotFix.SkipFunction.require = true
  HotFix.SkipFunction.pairs = true
  HotFix.SkipFunction.InstanceOf = true
  HotFix.SkipFunction.SubclassOf = true
  HotFix.SkipFunction.New = true
  HotFix.SkipFunction.Extend = true
  HotFix.SkipFunction.__call = true
  HotFix.SkipFunction.type = true
  HotFix.SkipFunction.math = true
end

HotFix.InitSkipTable()
HotFix.InitSkipFunction()

function HotFix.IsNeedSkipTable(tab)
  local needSkip = HotFix.SkipTable[tab]
  if needSkip then
    return true
  else
    return false
  end
end

function HotFix.IsNeedSkipFunc(func)
  local needSkip = HotFix.SkipFunction[func]
  if needSkip then
    return true
  else
    return false
  end
end

function HotFix.ToLuaFullPath(filePath)
  local fullName = string.gsub(filePath, "%.", "/")
  if RocoEnv and RocoEnv.LUA_ROOT_PATH then
    fullName = string.format("%s%s.lua", RocoEnv.LUA_ROOT_PATH, fullName)
  end
  return fullName
end

function HotFix.GetLuaFileModifyTime(filePath)
  local fullName = HotFix.ToLuaFullPath(filePath)
  return UEGetFileDateTime and UEGetFileDateTime(fullName) or -1
end

function HotFix.RequireFile(filePath, donntAddToLoadedLst)
  return HotFix.DoLoadFile(filePath, donntAddToLoadedLst)
end

function HotFix.IsMouduleInPackage(strname)
  if package.loaded[strname] ~= nil then
    return true
  end
  for i, loader in ipairs(package.searchers) do
    if 2 ~= i then
      local f, extra = loader(strname)
      local t = type(f)
      if "function" == t then
        return true
      end
    end
  end
  return false
end

function HotFix.ReloadFile(filePath)
  if HotFix.IsEnableReload then
    HotFix.loadedFileList[filePath] = nil
    package.loaded[filePath] = nil
  end
  return HotFix.RequireFile(filePath, true)
end

function HotFix.AutoHotFixFile()
  if not HotFix.IsEnableHotFix then
    return
  end
  for k, v in pairs(HotFix.loadedFileList) do
    local isExpire, newTime = HotFix.CheckFileIsExpire(k)
    if isExpire then
      if HotFix.AutoHotFixFileInjectFunction then
        Log.Debug("AutoHotFixFileInjectFunction:", k)
        HotFix.AutoHotFixFileInjectFunction(k)
      end
      if HotFix.GetLoadedFile(k) then
        HotFix.Update(k)
      else
        HotFix.RequireFile(k)
      end
      HotFix.loadedFileList[k] = newTime
    end
  end
end

function HotFix.UpdateGlobal()
  local visited = {}
  visited[HotFix] = true
  local UpdateGlobalIterator = function(t, name)
    if type(t) ~= "function" and type(t) ~= "table" or visited[t] then
      return
    end
    visited[t] = true
    if type(t) == "function" then
      if HotFix.IsNeedSkipFunc(name) then
        return
      end
      for i = 1, math.huge do
        local name, value = debug.getupvalue(t, i)
        if not name then
          break
        end
        if type(value) == "function" then
          for _, funcs in ipairs(HotFix.ChangedFuncList) do
            if value == funcs[1] then
              debug.setupvalue(t, i, funcs[2])
            end
          end
        end
        UpdateGlobalIterator(value)
      end
    elseif type(t) == "table" then
      if HotFix.IsNeedSkipTable(t) then
        return
      end
      UpdateGlobalIterator(debug.getmetatable(t))
      local changeIndexs = {}
      for k, v in pairs(t) do
        UpdateGlobalIterator(k)
        UpdateGlobalIterator(v, k)
        if type(v) == "function" then
          for _, funcs in ipairs(HotFix.ChangedFuncList) do
            if v == funcs[1] then
              t[k] = funcs[2]
            end
          end
        end
        if type(k) == "function" then
          for index, funcs in ipairs(HotFix.ChangedFuncList) do
            if k == funcs[1] then
              changeIndexs[#changeIndexs + 1] = index
            end
          end
        end
      end
      for _, index in ipairs(changeIndexs) do
        local funcs = HotFix.ChangedFuncList[index]
        t[funcs[2]] = t[funcs[1]]
        t[funcs[1]] = nil
      end
    elseif type(t) == "userdata" then
      local mt = getmetatable(t)
      if mt then
        UpdateGlobalIterator(mt)
      end
      local UserValue = debug.getuservalue(t)
      if UserValue then
        if ChangeValueMap then
          local nv = ChangeValueMap[UserValue]
          if nv then
            debug.setuservalue(t, UserValue)
            UpdateGlobalIterator(nv)
          else
            UpdateGlobalIterator(UserValue)
          end
        else
          Log.Error("[HotFix.UpdateGlobal] ChangeValueMap is nil")
        end
      end
    end
  end
  UpdateGlobalIterator(_G)
  UpdateGlobalIterator(debug.getregistry())
end

function HotFix.Update(filePath)
  local oldFile = package.loaded[filePath]
  if type(oldFile) == "function" then
    Log.Error("oldFile is function")
    return
  end
  filePath = string.gsub(filePath, "%.", "/")
  if RocoEnv.IS_EDITOR then
    filePath = filePath .. ".lua"
  else
    filePath = filePath .. ".luac"
  end
  Log.Debug("[HotFix.Update] filePath:", filePath)
  local func = loadfile(filePath)
  local isSucc, newFile = xpcall(func, function(error)
    Log.Error("Lua\231\188\150\232\175\145\229\164\177\232\180\165:", filePath, error)
  end)
  if not isSucc then
    return
  end
  HotFix.ResetUpdateTablesENV()
  HotFix.UpdateTable(oldFile, newFile)
  if #HotFix.ChangedFuncList > 0 then
    HotFix.UpdateGlobal()
  end
end

function HotFix.ResetUpdateTablesENV()
  HotFix.ChangedFuncList = {}
  HotFix.UpdatedFunctions = {}
  HotFix.ENV = _G
end

function HotFix.ReloadByList(toReloadFiles)
  HotFix.ResetUpdateTablesENV()
  for LuaPath, SysPath in pairs(toReloadFiles) do
    Log.Debug(string.format("[HotFix.ReloadByList] to reload LuaPath = %s, SysPath = %s", LuaPath, SysPath))
    local oldFile = package.loaded[LuaPath]
    if type(oldFile) ~= "table" then
      Log.Error("oldFile is not table:", type(oldFile))
      return
    end
    LuaPath = string.gsub(LuaPath, "%.", "/")
    LuaPath = LuaPath .. ".lua"
    Log.Debug("[HotFix.Update] filePath:", LuaPath)
    local func = loadfile(LuaPath)
    local isSucc, newFile = xpcall(func, function(error)
      Log.Error("Lua\231\188\150\232\175\145\229\164\177\232\180\165:", LuaPath, error)
    end)
    if not isSucc then
      return
    end
    if type(newFile) ~= "table" then
      Log.Error("newFile is not table")
      return
    end
    HotFix.UpdateAllFunction(oldFile, newFile, LuaPath, "ReloadByList")
  end
  if #HotFix.ChangedFuncList > 0 then
    HotFix.UpdateGlobal()
  end
  return true
end

function HotFix.UpdateTable(oldFile, newFile)
  for k, v in pairs(oldFile) do
    if type(v) == "function" then
      HotFix.UpdateOneFunction(v, newFile[k], k, nil)
      oldFile[k] = newFile[k]
    elseif type(v) == "table" then
      if newFile[k] then
        HotFix.UpdateAllFunction(v, newFile[k], k)
      else
        Log.Debug("HotFixOnion wtf is nil:", k)
      end
    else
      if newFile[k] then
        oldFile[k] = newFile[k]
      end
      Log.Debug(string.format("[HotFix.UpdateTable] k=%s type(v)=%s", k, type(v)))
    end
  end
end

function HotFix.DoLoadFile(filePath, donntAddToLoadedLst)
  local file = HotFix.GetLoadedFile(filePath)
  if file then
    return file
  else
    if RocoEnv.IS_EDITOR then
      local loadTime = HotFix.GetLuaFileModifyTime(filePath)
      Log.Debug("HotFix DoLoadFile 2:", filePath, loadTime)
      if not donntAddToLoadedLst then
        HotFix.loadedFileList[filePath] = loadTime
      end
    end
    return OriRequire(filePath)
  end
end

function HotFix.GetLoadedFile(filePath)
  return package.loaded[filePath]
end

function HotFix.IsFileLoaded(filePath)
  return UEIsLuaLoaded(filePath)
end

function HotFix.CheckFileIsExpire(filePath)
  local newCheckTime = HotFix.GetLuaFileModifyTime(filePath)
  return newCheckTime ~= HotFix.loadedFileList[filePath], newCheckTime
end

function HotFix.UpdateUpvalue(OldFunction, NewFunction, Name)
  if not OldFunction then
    Log.Error("HotFix.UpdateUpvalue OldFunction is nil:", Name)
    return
  end
  if not NewFunction then
    Log.Error("HotFix.UpdateUpvalue NewFunction is nil:", Name)
    return
  end
  local OldUpvalueMap = {}
  local OldExistName = {}
  for i = 1, math.huge do
    local name, value = debug.getupvalue(OldFunction, i)
    if not name then
      break
    end
    OldUpvalueMap[name] = value
    OldExistName[name] = true
  end
  for i = 1, math.huge do
    local name, value = debug.getupvalue(NewFunction, i)
    if not name then
      break
    end
    if OldExistName[name] then
    else
      HotFix.ResetENV(value, name, "UpdateUpvalue")
    end
  end
end

function HotFix.ResetENV(object, name, From)
  local visited = {}
  local f = function(object, name, func)
    if not object or visited[object] then
      return
    end
    visited[object] = true
    if type(object) == "function" then
      xpcall(function()
        setfenv(object, HotFix.ENV)
      end, function(e)
        Log.Error("xpcall fail")
      end)
    elseif type(object) == "table" then
      for k, v in pairs(object) do
        f(k, tostring(k) .. "__key", nil)
        f(v, tostring(k), nil)
      end
    end
  end
  f(object, name)
end

function HotFix.UpdateOneFunction(OldObject, NewObject, FuncName, OldTable, From)
  if HotFix.IsNeedSkipFunc(FuncName) then
    return
  end
  if OldObject == NewObject then
    return
  end
  if HotFix.IsUpdatedFunction(OldObject, NewObject) then
    return
  end
  HotFix.UpdatedFunctions[OldObject] = NewObject
  if pcall(debug.setfenv, NewObject, getfenv(OldObject)) then
    HotFix.UpdateUpvalue(OldObject, NewObject, FuncName)
    table.insert(HotFix.ChangedFuncList, {
      OldObject,
      NewObject,
      FuncName,
      OldTable
    })
  end
end

function HotFix.UpdateAllFunction(OldTable, NewTable, Name, From)
  local IsSame = getmetatable(OldTable) == getmetatable(NewTable)
  IsSame = IsSame and OldTable == NewTable
  if true == IsSame then
    return
  end
  if HotFix.IsUpdatedFunction(OldTable, NewTable) then
    return
  end
  HotFix.UpdatedFunctions[OldTable] = NewTable
  for ElementName, Element in pairs(NewTable) do
    local OldElement = OldTable[ElementName]
    if nil == OldElement then
      if type(Element) == "function" then
        if pcall(setfenv, Element, HotFix.ENV) then
          OldTable[ElementName] = Element
        end
      else
        OldTable[ElementName] = Element
      end
      Log.Debug("[HotFix.UpdateAllFunction] add ElementName ", ElementName)
    elseif type(Element) == type(OldElement) then
      if type(Element) == "function" then
        HotFix.UpdateOneFunction(OldElement, Element, ElementName, OldTable, "HotFix.UpdateAllFunction")
        OldTable[ElementName] = NewTable[ElementName]
      elseif type(Element) == "table" then
        HotFix.UpdateAllFunction(OldElement, Element, ElementName, "HotFix.UpdateAllFunction")
      elseif OldTable[ElementName] ~= NewTable[ElementName] then
        Log.Error(string.format("[HotFix.UpdateAllFunction] ElementName:%s, OldType:%s, NewType:%s", ElementName, type(OldElement), type(Element)))
      end
    else
      OldTable[ElementName] = Element
      Log.Debug(string.format("[HotFix.UpdateAllFunction] ElementName:%s, OldType:%s, NewType:%s", ElementName, type(OldElement), type(Element)))
    end
  end
end

function HotFix.IsUpdatedFunction(old, new)
  return HotFix.UpdatedFunctions[old] and HotFix.UpdatedFunctions[old] == new
end

return HotFix
