local HotAllReloadMark = "_Hot_All_Reload_Mark_"
local HotFix = {
  UseNewModuleWhenHotifx = false,
  DelOldAddedValue = false,
  Loaded = setmetatable({}, {__mode = "v"}),
  HotFixCount = 0,
  WhiteList = {},
  PrintLog = false
}

function HotFix.print(...)
  if HotFix.PrintLog then
    Log.Debug("[HotFix DEBUG]: ", ...)
  end
end

function HotFix.simplePrint(...)
  Log.Debug("[HotFix DEBUG]: ", ...)
end

local table = _ENV.table
local debug = _ENV.debug
local OriRequire = require
local strexmsg

local function errorHandler(err)
  Log.Error(strexmsg .. "  " .. err .. "  " .. debug.traceback())
end

local function TableToString(t, intent)
  if intent then
    return _G.TableToString(t, {
      indent = string.rep(" ", intent)
    })
  else
    return _G.TableToString(t)
  end
end

local filesLoadRecordTime = {}
local SandBox = {
  loadedDummy = setmetatable({}, {__mode = "kv"}),
  isHotfixing = false
}

function SandBox.Init(loadedListName, loadedListModule)
  SandBox.isHotfixing = true
  SandBox.loadedDummy = setmetatable({}, {__mode = "kv"})
  if loadedListName then
    for index, name in ipairs(loadedListName) do
      local mod = loadedListModule[index]
      SandBox.loadedDummy[name] = mod
      SandBox.loadedDummy[mod] = name
    end
  end
end

function SandBox.Clear()
  SandBox.isHotfixing = false
  SandBox.loadedDummy = setmetatable({}, {__mode = "kv"})
end

function SandBox.Requrie(filename)
  local fnv
  if SandBox.isHotfixing and SandBox.loadedDummy[filename] ~= nil then
    return SandBox.loadedDummy[filename]
  end
  fnv = HotFix.RequireFile(filename)
  if SandBox.isHotfixing then
    SandBox.loadedDummy[filename] = fnv
    SandBox.loadedDummy[fnv] = filename
  end
  return fnv
end

function SandBox.IsDummy(obj)
  return SandBox.loadedDummy[obj] ~= nil
end

local sandbox_mt = {}

function sandbox_mt:__index(k)
  if "require" == k then
    return SandBox.Requrie
  end
  return _G[k]
end

local function GetClassModuleEnv(classname)
  local env = {}
  setmetatable(env, sandbox_mt)
  return env
end

local function SelfLoadFile(strname, bnotprinterr)
  local env = GetClassModuleEnv(strname)
  local func, err = loadfile(strname, "bt", env)
  if not func and not bnotprinterr then
    print("SelfLoadFile : loadfile failed : ", strname, err)
  end
  return func, err, env
end

local function IsMouduleInPackage(strname)
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

local function SelfLoadFileAndRecord(strName)
  local print = HotFix.print
  if not strName then
    print(debug.traceback())
    error("load nil")
    return
  end
  if HotFix.Loaded[strName] ~= nil then
    if nil == package.loaded[strName] then
      package.loaded[strName] = HotFix.Loaded[strName]
    end
    return HotFix.Loaded[strName]
  end
  print("SelfLoadFileAndRecord : " .. tostring(strName))
  local isRequire = false
  local filename = strName
  if not string.find(strName, "/") then
    if IsMouduleInPackage(strName) then
      print(" find " .. strName .. "in package. use ori require")
      return OriRequire(strName)
    end
    filename = string.gsub(strName, "%.", "/")
    filename = filename .. ".lua"
    isRequire = true
  end
  local func, err, _fileenv = SelfLoadFile(filename, isRequire)
  if not func then
    Log.Debug("not hotfix write:", filename)
    local rf = OriRequire(strName)
    if nil == rf then
      print("orir require load failed : ", strName)
    else
      print("use ori require success : ", strName)
    end
    return rf, true
  else
    strexmsg = filename
    local _x, _newModlue = xpcall(func, errorHandler)
    if nil ~= _newModlue then
    else
      print("file : " .. filename .. " not return table. use env")
      _newModlue = _fileenv
    end
    if HotFix.Loaded[strName] == nil then
      HotFix.Loaded[strName] = _newModlue
      package.loaded[strName] = _newModlue
      filesLoadRecordTime[strName] = GetFileModifyTime(filename)
      return _newModlue
    end
  end
  return _fileenv
end

local function FindUpvalue(func, name)
  if not func then
    return
  end
  local i = 1
  while true do
    local n, v = debug.getupvalue(func, i)
    if nil == n or "" == name then
      return
    end
    if n == name then
      return i
    end
    i = i + 1
  end
end

local function GetTableName(mv)
  for k, v in pairs(HotFix.Loaded) do
    if mv == v then
      return k
    end
  end
end

local function MergeObjects(ModuleRes)
  local print = HotFix.print
  for _, m in ipairs(ModuleRes) do
    assert(m.old_module ~= nil)
    for index, v in ipairs(m.tValueMap) do
      for name, ValueMap in pairs(v) do
        for OldOne, NewOne in pairs(ValueMap) do
          if nil == OldOne and not SandBox.IsDummy(NewOne) then
            m.old_module[name] = NewOne
            if type(NewOne) == "function" then
              print("ADD NEW FUNCTION : ", GetTableName(m.old_module), name)
              if nil ~= UnLua_OnAddNewFunction then
                UnLua_OnAddNewFunction()
              end
            end
          elseif type(NewOne) == "table" and not SandBox.IsDummy(NewOne) then
            if print then
              print("COPY", tostring(NewOne), tostring(OldOne))
            end
            for k, nv in pairs(NewOne) do
              OldOne[k] = nv
            end
          elseif type(NewOne) == "function" then
            local i = 1
            while true do
              local name, v = debug.getupvalue(NewOne, i)
              if nil == name or "" == name then
                break
              end
              local id = debug.upvalueid(NewOne, i)
              local uv = m.tUpvalueMap[id]
              if uv then
                if print then
                  print("SET UV :", tostring(NewOne), name, tostring(uv.ReplaceUV))
                end
                debug.setupvalue(NewOne, i, uv.ReplaceUV)
              end
              i = i + 1
            end
          end
        end
      end
    end
  end
end

local fileLoadCallBack = {}
local hotfixCallBack = {}
local preHotfixCallback = {}
local postHotfixCallback = {}

function HotFix.RegistedFileLoadCallback(fun)
  if type(fun) ~= "function" then
    print("RegistedFileLoadCallback error : need function ")
    return
  end
  fileLoadCallBack[#fileLoadCallBack + 1] = fun
end

function HotFix.RegistedPreHotfixCallback(fun)
  if type(fun) ~= "function" then
    print("RegistedPreHotfixCallback error : need function ")
    return
  end
  preHotfixCallback[#preHotfixCallback + 1] = fun
end

function HotFix.RegistedPostHotfixCallback(fun)
  if type(fun) ~= "function" then
    print("RegistedPostHotfixCallback error : need function ")
    return
  end
  postHotfixCallback[#postHotfixCallback + 1] = fun
end

function HotFix.RegistedHotfixCallback(FileName, Fun)
  print("RegistedHotfixCallback", FileName, Fun)
  if type(Fun) ~= "function" then
    print("RegistedHotfixCallback error : need function ")
    return
  end
  if nil == hotfixCallBack[FileName] then
    hotfixCallBack[FileName] = {}
  end
  hotfixCallBack[FileName][#hotfixCallBack[FileName] + 1] = Fun
end

function HotFix.RequireFile(strFileName)
  if package.loaded[strFileName] ~= nil then
    return package.loaded[strFileName]
  end
  local fevn, IsRequire = SelfLoadFileAndRecord(strFileName)
  if not IsRequire then
    for _, callback in ipairs(fileLoadCallBack) do
      callback(fevn, strFileName, false)
    end
  end
  return fevn
end

function HotFix.ClearLoadedModuleByName(strFileName)
  HotFix.Loaded[strFileName] = nil
  filesLoadRecordTime[strFileName] = nil
  package.loaded[strFileName] = nil
end

function HotFix.ClearLoadedModule()
  for filename, _ in pairs(HotFix.Loaded) do
    HotFix.ClearLoadedModuleByName(filename)
  end
end

function HotFix.HotFixModifyFile(bKeepUpvalues)
  local print = HotFix.print
  local needHotFixFile = {}
  local newFilename = {}
  if GetFileModifyTime == nil then
    print("can not get file modify time. return")
    return
  end
  for sourceFile, mtime in pairs(filesLoadRecordTime) do
    if not HotFix.WhiteList[sourceFile] then
      local fileFullname = sourceFile
      if not string.find(fileFullname, "/") then
        fileFullname = string.gsub(fileFullname, "%.", "/")
        fileFullname = fileFullname .. ".lua"
      end
      local curmtime = GetFileModifyTime(fileFullname)
      if curmtime ~= mtime then
        needHotFixFile[#needHotFixFile + 1] = sourceFile
        newFilename[#newFilename + 1] = fileFullname
        filesLoadRecordTime[sourceFile] = curmtime
      end
    end
  end
  print("need hotfix :", TableToString(needHotFixFile))
  if #needHotFixFile > 0 then
    HotFix.HotFixFile(needHotFixFile, newFilename, bKeepUpvalues)
  end
end

local function EnumModuleUpvalue(moudule)
  local print = HotFix.print
  local GetFunctionUpValue = function(fun, resTable)
    assert(type(fun) == "function")
    local i = 1
    while true do
      local name, value = debug.getupvalue(fun, i)
      if nil == name or "" == name then
        break
      end
      if not name:find("^[_%w]") then
        error("Invalid upvalue : " .. table.concat(path, "."))
      end
      if not resTable[name] then
        resTable[name] = value
        if type(value) == "function" then
          GetFunctionUpValue(value, resTable)
        end
      end
      i = i + 1
    end
  end
  local allUpvalue = {}
  for k, v in pairs(moudule) do
    if type(v) == "function" then
      GetFunctionUpValue(v, allUpvalue)
    end
  end
  return allUpvalue
end

local function EnumModule(TargetModule)
  local ModuleValue = {}
  if SandBox.IsDummy(TargetModule) then
    return ModuleValue
  end
  for k, v in pairs(TargetModule) do
    if SandBox.IsDummy(v) then
    elseif type(v) == "function" then
      table.insert(ModuleValue, {name = k, value = v})
    end
  end
  return ModuleValue
end

local function MatchModule(NewModuleInfo, OldModule)
  local MapMatch = {}
  local print = HotFix.print
  for index, v in ipairs(NewModuleInfo) do
    local oldFun = rawget(OldModule, v.name)
    if oldFun and oldFun ~= v.value then
      table.insert(MapMatch, {
        [v.name] = {
          [oldFun] = v.value
        }
      })
    end
  end
  return MapMatch
end

local function MatchUpvalues(ValueInfoMap, OldModuleUpvalues)
  local print = HotFix.print
  local UpValueMatchMap = {}
  for index, v in ipairs(ValueInfoMap) do
    for name, ValueMap in pairs(v) do
      for OldFun, NewFun in pairs(ValueMap) do
        if type(NewFun) == "function" then
          local i = 1
          while true do
            local name, uValue = debug.getupvalue(NewFun, i)
            if nil == name or "" == name then
              break
            end
            local id = debug.upvalueid(NewFun, i)
            if not UpValueMatchMap[id] then
              local ValueUV
              if nil ~= OldModuleUpvalues[name] then
                ValueUV = OldModuleUpvalues[name]
              else
                print("ADD NEW UPVALUE : ", tostring(NewFun), name, tostring(uValue))
                if (type(uValue) == "table" or type(uValue) == "function") and nil ~= ValueInfoMap[uValue] then
                  ValueUV = ValueInfoMap[uValue]
                else
                  ValueUV = uValue
                end
              end
              if ValueUV then
                UpValueMatchMap[id] = {ReplaceUV = ValueUV}
              end
            end
            i = i + 1
          end
        end
      end
    end
  end
  return UpValueMatchMap
end

local function UpdateGlobal(ChangeValueMap)
  local print = HotFix.print
  local RunningState = coroutine.running()
  local Exclude = {
    [debug] = true,
    [coroutine] = true,
    [io] = true
  }
  Exclude[Exclude] = true
  Exclude[HotFix] = true
  Exclude[SandBox] = true
  Exclude[ChangeValueMap] = true
  Exclude[HotFix.UpdateModule] = true
  if HotFix.UseNewModuleWhenHotifx == false then
    Exclude[package] = true
    Exclude[package.loaded] = true
    Exclude[HotFix.Loaded] = true
  end
  local ReplaceCount = 0
  local UpdateGlobalIterate
  local UpdateRuningStack = function(co, level)
    local info = debug.getinfo(co, level + 1, "f")
    if nil == info then
      return
    end
    local f = info.func
    info = nil
    UpdateGlobalIterate(f)
    local i = 1
    while true do
      local name, v = debug.getlocal(co, level + 1, i)
      if nil == name then
        if i > 0 then
          i = -1
        else
          break
        end
      end
      local nv = ChangeValueMap[v]
      if nv then
        debug.setlocal(co, level + 1, i, nv)
        UpdateGlobalIterate(nv)
      else
        UpdateGlobalIterate(v)
      end
      if i > 0 then
        i = i + 1
      else
        i = i - 1
      end
    end
    return UpdateRuningStack(co, level + 1)
  end
  
  function UpdateGlobalIterate(root)
    if nil == root or Exclude[root] then
      return
    end
    Exclude[root] = true
    local t = type(root)
    if "table" == t then
      local mt = getmetatable(root)
      if mt then
        UpdateGlobalIterate(mt)
      end
      local ReplaceK = {}
      for key, value in pairs(root) do
        local nv = ChangeValueMap[value]
        if nv then
          ReplaceCount = ReplaceCount + 1
          rawset(root, key, nv)
          UpdateGlobalIterate(nv)
        else
          UpdateGlobalIterate(value)
        end
        nv = ChangeValueMap[key]
        if nv then
          ReplaceK[key] = nv
        end
      end
      for key, value in pairs(ReplaceK) do
        ReplaceCount = ReplaceCount + 1
        root[key], root[value] = nil, root[key]
        UpdateGlobalIterate(value)
      end
    elseif "userdata" == t then
      local mt = getmetatable(root)
      if mt then
        UpdateGlobalIterate(mt)
      end
      local UserValue = debug.getuservalue(root)
      if UserValue then
        local nv = ChangeValueMap[UserValue]
        if nv then
          ReplaceCount = ReplaceCount + 1
          debug.setuservalue(root, UserValue)
          UpdateGlobalIterate(nv)
        else
          UpdateGlobalIterate(UserValue)
        end
      end
    elseif "function" == t then
      local i = 1
      while true do
        local name, v = debug.getupvalue(root, i)
        if nil == name then
          break
        end
        do
          local nv = ChangeValueMap[v]
          if nv then
            if HotFix.UseNewModuleWhenHotifx then
              ReplaceCount = ReplaceCount + 1
              debug.setupvalue(root, i, nv)
            end
            UpdateGlobalIterate(nv)
          else
            UpdateGlobalIterate(v)
          end
        end
        i = i + 1
      end
    end
  end
  
  UpdateRuningStack(RunningState, 2)
  UpdateGlobalIterate(_G)
  UpdateGlobalIterate(debug.getregistry())
  print("ReplaceGlobalCount : ", ReplaceCount)
end

function HotFix.UpdateModule(listoldmodule, listnewmudule, listnewmuduleenv, bKeepUpvalues)
  local print = HotFix.print
  local simplePrint = HotFix.simplePrint
  local result = {}
  simplePrint("HOT FIX START")
  for i, OldModule in ipairs(listoldmodule) do
    local NewModule = listnewmudule[i]
    local newmuduleenv = listnewmuduleenv[i]
    if NewModule[HotAllReloadMark] then
      if print then
        print("Module Use Reload", tostring(NewModule))
      end
      local moduleres = {
        tValueMap = {},
        old_module = OldModule
      }
      table.insert(moduleres.tValueMap, {
        [NewModule] = {
          [OldModule] = NewModule
        }
      })
      print("--------------Print ValueMap--------------")
      print(TableToString(moduleres.tValueMap, 6))
      result[i] = moduleres
    else
      local NewModuleInfo = EnumModule(NewModule)
      print("--------------Print NewModuleInfo--------------")
      print(TableToString(NewModuleInfo))
      local oldModuleUpvalues = EnumModuleUpvalue(OldModule)
      print("--------------Print OldModuleUpValue--------------")
      print(TableToString(oldModuleUpvalues, 6))
      local moduleres = {
        tValueMap = {},
        tUpvalueMap = {},
        old_module = OldModule
      }
      moduleres.tValueMap = MatchModule(NewModuleInfo, OldModule)
      if HotFix.UseNewModuleWhenHotifx then
        for oldk, oldv in pairs(OldModule) do
          if type(oldv) ~= "function" then
            NewModule[oldk] = oldv
          end
        end
        setmetatable(NewModule, getmetatable(OldModule))
        table.insert(moduleres.tValueMap, {
          [NewModule] = {
            [OldModule] = NewModule
          }
        })
      else
        if HotFix.DelOldAddedValue then
          for oldk, okdv in pairs(OldModule) do
            if nil == NewModule[oldk] then
              OldModule[oldk] = nil
            end
          end
        end
        for newk, newv in pairs(NewModule) do
          if type(newv) == "function" then
            OldModule[newk] = newv
          end
          if nil == OldModule[newk] then
            OldModule[newk] = newv
          end
        end
      end
      print("--------------Print ValueMap--------------")
      print(TableToString(moduleres.tValueMap))
      if bKeepUpvalues then
        MatchUpvalues(moduleres.tValueMap, moduleres.tUpvalueMap)
      end
      print("--------------Print UVMap--------------")
      print(TableToString(moduleres.tUpvalueMap, 10))
      result[i] = moduleres
    end
  end
  MergeObjects(result)
  local AllValueMap = {}
  for _, rv in ipairs(result) do
    for _, v in ipairs(rv.tValueMap) do
      for name, ValueMap in pairs(v) do
        for key, value in pairs(ValueMap) do
          AllValueMap[key] = value
        end
      end
    end
  end
  print("--------------Print AllValueMap--------------")
  print(TableToString(AllValueMap))
  UpdateGlobal(AllValueMap)
  simplePrint("HOT FIX END")
  return true
end

function HotFix.HotFixOneFile(strOldFile, strNewFile)
  if nil == strNewFile then
    strNewFile = strOldFile
    if not string.find(strNewFile, "/") then
      strNewFile = string.gsub(strNewFile, "%.", "/")
      strNewFile = strNewFile .. ".lua"
    end
  end
  if nil == HotFix.Loaded[strOldFile] then
    print("file not loaded : ", strOldFile, "new load file : ", strNewFile)
    HotFix.RequireFile(strNewFile)
    return true
  end
  for _, callback in ipairs(preHotfixCallback) do
    callback({strOldFile})
  end
  local tmploaded = {}
  local tmploadedmod = {}
  for k, v in pairs(HotFix.Loaded) do
    if k ~= strOldFile then
      table.insert(tmploaded, k)
      table.insert(tmploadedmod, v)
    end
  end
  SandBox.Init(tmploaded, tmploadedmod)
  local _f, err, _fileenv = SelfLoadFile(strNewFile)
  if nil ~= _f then
    strexmsg = strNewFile
    local _x, _newModlue = xpcall(_f, errorHandler)
    if not _x then
      return _x, _newModlue
    end
    if nil ~= _newModlue then
    else
      print("file : " .. strNewFile .. " not return table. use env")
      _newModlue = _fileenv
    end
    HotFix.UpdateModule({
      HotFix.Loaded[strOldFile]
    }, {_newModlue}, {_fileenv})
    if HotFix.UseNewModuleWhenHotifx then
      HotFix.Loaded[strOldFile] = _newModlue
      package.loaded[strOldFile] = _newModlue
    end
  end
  SandBox.Clear()
  if nil == _f then
    return
  end
  HotFix.HotFixCount = HotFix.HotFixCount + 1
  for _, callback in ipairs(fileLoadCallBack) do
    callback(HotFix.Loaded[strOldFile], strOldFile, true)
  end
  if nil ~= hotfixCallBack[strOldFile] then
    for _, hotfixcb in ipairs(hotfixCallBack[strOldFile]) do
      hotfixcb(HotFix.HotFixCount, strOldFile, HotFix.Loaded[strOldFile])
    end
  end
  for _, callback in ipairs(postHotfixCallback) do
    callback({strOldFile})
  end
end

local print = HotFix.print

function HotFix.HotFixFile(listOldFile, listNewFile, bKeepUpvalues)
  if nil == listNewFile then
    listNewFile = listOldFile
  end
  if nil == listOldFile or 0 == #listOldFile or #listOldFile ~= #listNewFile then
    print("nothing to hotfix")
    return
  end
  for _, callback in ipairs(preHotfixCallback) do
    callback(listOldFile)
  end
  local tmploaded = {}
  local tmploadedmod = {}
  for k, v in pairs(HotFix.Loaded) do
    if nil ~= listOldFile[k] then
      table.insert(tmploaded, k)
      table.insert(tmploadedmod, v)
    end
  end
  SandBox.Init(tmploaded, tmploadedmod)
  local listOldModule = {}
  local listNewModule = {}
  local listInitModule = {}
  local listFileEnv = {}
  for i, strOldFile in ipairs(listOldFile) do
    local strNewFile = listNewFile[i]
    if nil == HotFix.Loaded[strOldFile] then
      print("file not loaded : ", strOldFile, "load file for new : ", strNewFile, HotFix.Loaded, TableToString(HotFix.Loaded, 62))
      HotFix.RequireFile(strNewFile)
    else
      local _f, err, _fileenv = SelfLoadFile(strNewFile)
      if nil ~= _f then
        strexmsg = strNewFile
        local succ, _newModlue = xpcall(_f, errorHandler)
        if false == succ then
          SandBox.Clear()
          return
        end
        if _newModlue then
          for k, v in pairs(_fileenv) do
            _newModlue[k] = v
          end
        else
          _newModlue = _fileenv
        end
        listOldModule[#listOldModule + 1] = HotFix.Loaded[strOldFile]
        listNewModule[#listNewModule + 1] = _newModlue
        listFileEnv[#listFileEnv + 1] = _fileenv
      else
        SandBox.Clear()
        return
      end
    end
  end
  HotFix.UpdateModule(listOldModule, listNewModule, listFileEnv, bKeepUpvalues)
  SandBox.Clear()
  HotFix.HotFixCount = HotFix.HotFixCount + 1
  for i, strOldFile in ipairs(listOldFile) do
    if HotFix.UseNewModuleWhenHotifx then
      HotFix.Loaded[strOldFile] = listNewModule[i]
      package.loaded[strOldFile] = listNewModule[i]
    end
    for _, callback in ipairs(fileLoadCallBack) do
      callback(HotFix.Loaded[strOldFile], strOldFile, true)
    end
    if nil ~= hotfixCallBack[strOldFile] then
      for _, hotfixcb in ipairs(hotfixCallBack[strOldFile]) do
        hotfixcb(HotFix.HotFixCount, strOldFile, HotFix.Loaded[strOldFile])
      end
    end
  end
  for _, callback in ipairs(postHotfixCallback) do
    callback(listOldFile)
  end
end

function HotFix.ReloadFile(filename)
  HotFix.ClearLoadedModuleByName(filename)
  return HotFix.RequireFile(filename)
end

function HotFix.IsMouduleInPackage(filename)
  return IsMouduleInPackage(filename)
end

function HotFix.AddWhiteList(whitelist)
  HotFix.WhiteList = whitelist
end

return HotFix
