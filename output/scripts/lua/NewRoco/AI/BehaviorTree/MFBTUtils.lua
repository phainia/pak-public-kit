local MFBTUtils = {}
_G.MFBTUtils = MFBTUtils
require("Utils.Extend")

function MFBTUtils.ModifyParamData(Node)
  local Param = Node.LuaFileParamData
  if Param.LuaFileSelectPathStruct.LuaFilePath == "Battle/SvrActionPerform" then
    local check1 = false
    local check2 = false
    for _, info in tpairs(Param.LuaParamInfos) do
      if info.LuaParamValue.LuaParamName == "PerformType" and 1 == info.LuaParamValue.ParamInt then
        check1 = true
      end
      if info.LuaParamValue.LuaParamName == "NumParam" and 19 == info.LuaParamValue.ParamInt then
        check2 = true
      end
    end
    if check1 and check2 then
      local idx = UE.UMFBTAssetLibrary.EnsureLuaParamInfoIndexByName(Node, "CastMoment")
      local info = Param.LuaParamInfos[idx + 1]
      if info then
        info.LuaParamValue.ParamInt = 7
        Param.LuaParamInfos[idx + 1] = info
        return true
      end
    end
  end
end

return MFBTUtils
