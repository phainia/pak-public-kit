local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_BezCircularPlot = Class()

function BP_BezCircularPlot:Ctor()
  self.caller = nil
  self.callback = nil
end

function BP_BezCircularPlot:OnGenerateEnd()
  if self.caller ~= nil then
    self.callback(self.caller, self:Abs_K2_GetActorLocation())
    self:ClearDelegate()
  end
end

function BP_BezCircularPlot:SetSizeAndGenerate(Radius, InnerRadius, MaxCircularHeight, BeginPos, caller, callback)
  if nil ~= caller then
    self.caller = caller
    self.callback = callback
  end
  BeginPos = SceneUtils.ConvertAbsoluteToRelative(BeginPos)
  self.Overridden.SetSizeAndGenerate(self, Radius, InnerRadius, MaxCircularHeight, BeginPos)
end

function BP_BezCircularPlot:ClearDelegate()
  self.caller = nil
  self.callback = nil
end

local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")

function BP_BezCircularPlot:StartDebug()
  a.task(function()
    while true do
      if not GlobalConfig.DebugBezCircularPlot then
        return
      end
      a.wait(au.NextTick())
    end
  end)()
end

return BP_BezCircularPlot
