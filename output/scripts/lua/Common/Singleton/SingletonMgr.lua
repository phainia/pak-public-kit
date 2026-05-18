local SingletonMgr = {}
SingletonMgr.singletonTable = {}
local this = SingletonMgr

function SingletonMgr.Setup()
  function this._AddSingleton(name, singleton)
    if this.singletonTable[name] then
      return
    end
    this.singletonTable[name] = singleton
  end
  
  function this._FreeSingleton(name)
    table.removeKey(this.singletonTable, name)
  end
  
  return this
end

function SingletonMgr.CreateSingleton(name, path)
  if not name or not path then
    return
  end
  local ins = SingletonMgr:GetSingleton(name)
  if ins then
    return ins
  end
  local singleton = require(path)
  if not singleton then
    Log.Error("require failed:", path)
    return
  end
  if type(singleton) == "string" then
    Log.Error("\229\136\155\229\187\186\229\141\149\228\190\139\229\164\177\232\180\165:", name, singleton)
    return nil
  end
  local newSingleton = singleton(name)
  return newSingleton
end

function SingletonMgr.GetSingleton(name)
  return SingletonMgr.singletonTable[name]
end

function SingletonMgr.Dump()
  Log.Warning("show all singletons:")
  Log.Dump(this.singletonTable)
end

return SingletonMgr
