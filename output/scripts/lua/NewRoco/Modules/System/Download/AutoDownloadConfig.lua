local MBSize = 1048576
local AutoDownloadConfig = {
  MaxDownloadTaskCount = 1,
  MaxDownloadsPerTask = 1,
  MaxDownloadSpeedLowLevel = 1 * MBSize,
  MaxDownloadSpeedMediumLevel = 5 * MBSize,
  MaxDownloadSpeedHighLevel = 20 * MBSize
}
return AutoDownloadConfig
