local JsonUtils = require("Common.JsonUtils")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabCollect = Base:Extend("DebugTabCollect")

function DebugTabCollect:Ctor()
  Base.Ctor(self)
end

function DebugTabCollect:SetupTabs(_name, _call, _Panel)
end

function DebugTabCollect:SaveBtnInfo(name, Path, Instruction, UseType, Order)
  local SaveButtonInfos = JsonUtils.LoadSaved("DebugTabCollect", {})
  local CollectData = {}
  local CurButtonData = {}
  if nil == SaveButtonInfos[1] then
    table.insert(CollectData, Path)
    table.insert(CollectData, name)
    table.insert(CurButtonData, CollectData)
    Log.Dump(CurButtonData, 2, "UMG_DebugPanel_C:OutPutExcel")
    JsonUtils.DumpSaved("DebugTabCollect", CurButtonData)
  end
  SaveButtonInfos = JsonUtils.LoadSaved("DebugTabCollect", {})
  for i = 1, #SaveButtonInfos do
    local InnerButtonInfos = SaveButtonInfos[i]
    for j = 1, #InnerButtonInfos do
      if InnerButtonInfos[j] == name then
        Log.Dump("\229\183\178\231\187\143\230\156\137\232\175\165\230\140\137\233\146\174\228\186\134\239\188\129\239\188\129\239\188\129", 6, "DebugTabCollect:SaveBtnInfo")
        return
      end
    end
  end
  for i = 1, #SaveButtonInfos do
    local InnerButtonInfos = SaveButtonInfos[i]
    for j = 1, #InnerButtonInfos do
      if InnerButtonInfos[j] == Path then
        table.insert(InnerButtonInfos, name)
        JsonUtils.DumpSaved("DebugTabCollect", SaveButtonInfos)
        return
      end
    end
  end
  SaveButtonInfos = JsonUtils.LoadSaved("DebugTabCollect", {})
  table.insert(CollectData, Path)
  table.insert(CollectData, name)
  table.insert(SaveButtonInfos, CollectData)
  JsonUtils.DumpSaved("DebugTabCollect", SaveButtonInfos)
end

function DebugTabCollect:DeleteBtnInfo(name)
  local SaveButtonInfos = JsonUtils.LoadSaved("DebugTabCollect", {})
  for i = 1, #SaveButtonInfos do
    local InnerButtonInfos = SaveButtonInfos[i]
    for j = 1, #InnerButtonInfos do
      if InnerButtonInfos[j] == name then
        table.removeValue(SaveButtonInfos, InnerButtonInfos)
        JsonUtils.DumpSaved("DebugTabCollect", SaveButtonInfos)
        return
      end
    end
  end
end

return DebugTabCollect
