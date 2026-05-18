local JsonUtils = require("Common.JsonUtils")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabHistory = Base:Extend("DebugTabHistory")

function DebugTabHistory:Ctor()
  Base.Ctor(self)
end

function DebugTabHistory:SetupTabs()
end

function DebugTabHistory:SaveBtnInfo(name, Path, Instruction, UseType, Order)
  local SaveButtonInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
  local CollectData = {}
  local CurButtonData = {}
  if nil == SaveButtonInfos[1] then
    table.insert(CollectData, Path)
    table.insert(CollectData, name)
    table.insert(CurButtonData, CollectData)
    Log.Dump(CurButtonData, 2, "UMG_DebugPanel_C:OutPutExcel")
    JsonUtils.DumpSaved("DebugTabHistory", CurButtonData)
  end
  SaveButtonInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
  for i = 1, #SaveButtonInfos do
    if SaveButtonInfos[i][2] == name then
      Log.Dump("\229\183\178\231\187\143\230\156\137\232\175\165\230\140\137\233\146\174\228\186\134\239\188\129\239\188\129\239\188\129", 6, "DebugTabCollect:SaveBtnInfo")
      local Button = SaveButtonInfos[i]
      table.remove(SaveButtonInfos, i)
      table.insert(SaveButtonInfos, 1, Button)
      JsonUtils.DeleteFile("DebugTabHistory")
      JsonUtils.DumpSaved("DebugTabHistory", SaveButtonInfos)
      return
    end
  end
  SaveButtonInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
  table.insert(CollectData, Path)
  table.insert(CollectData, name)
  table.insert(SaveButtonInfos, 1, CollectData)
  JsonUtils.DumpSaved("DebugTabHistory", SaveButtonInfos)
end

function DebugTabHistory:DeleteBtnInfo(name)
  local SaveButtonInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
  for i = 1, #SaveButtonInfos do
    local InnerButtonInfos = SaveButtonInfos[i]
    for j = 1, #InnerButtonInfos do
      if InnerButtonInfos[j] == name then
        table.removeValue(SaveButtonInfos, InnerButtonInfos)
        JsonUtils.DumpSaved("DebugTabHistory", SaveButtonInfos)
        return
      end
    end
  end
end

return DebugTabHistory
