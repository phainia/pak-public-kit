local GlobalTable = {ENABLE_REGISTE_GLOBAL_VAR = true}
local oldG = _G
oldG.SingletonMgr = require("Common.Singleton.SingletonMgr").Setup()
oldG.CreateSingleton = oldG.SingletonMgr.CreateSingleton
setmetatable(GlobalTable, {
  __index = function(t, k)
    local singleton = oldG.SingletonMgr.GetSingleton(k)
    if singleton then
      return singleton
    else
      return oldG[k]
    end
  end,
  __newindex = function(t, k, v)
    if GlobalTable.ENABLE_REGISTE_GLOBAL_VAR then
      oldG[k] = v
    else
      Log.Error("not allow register global var : ", k)
    end
  end
})

function GlobalTable:Dump(n)
  Log.Dump(oldG, n)
end

return GlobalTable
