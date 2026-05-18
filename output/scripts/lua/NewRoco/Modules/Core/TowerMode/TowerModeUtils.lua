local TowerModeUtils = {}

function TowerModeUtils:findIndex(chapId, chapterItem)
  for i, item in ipairs(chapterItem) do
    if item.chapter_id == chapId then
      return i
    end
  end
  return 0
end

return TowerModeUtils
