--[[---------------------------------------------------------------------------------------

	Wraith ARS 2X 警用雷达系统
	原作者: WolfKnight
	汉化修改: xiaoha_realplate 真实车牌系统

	原版讨论、更新信息等，请加入原作者Discord: https://discord.gg/fD4e6WD

	MIT 开源协议

	版权所有 (c) 2020-2021 WolfKnight

	特此免费授予任何获得本软件及相关文档文件（"软件"）副本的人
	不受限制地处理本软件的权利，包括但不限于使用、复制、修改、
	合并、发布、分发、再许可和/或出售本软件副本的权利，
	并允许向其提供本软件的人这样做，但须符合以下条件：

	上述版权声明和本许可声明应包含在本软件的所有副本或主要部分中。

	本软件按"原样"提供，不提供任何形式的明示或暗示保证，
	包括但不限于对适销性、特定用途适用性和非侵权性的保证。
	在任何情况下，作者或版权持有人均不对因本软件或本软件的使用
	或其他交易而产生的任何索赔、损害或其他责任承担责任。

---------------------------------------------------------------------------------------]]--

-- 启动标识 (ASCII艺术字)
local label =
[[ 
  //
  ||       __      __        _ _   _        _   ___  ___   _____  __
  ||       \ \    / / _ __ _(_) |_| |_     /_\ | _ \/ __| |_  ) \/ /
  ||        \ \/\/ / '_/ _` | |  _| ' \   / _ \|   /\__ \  / / >  < 
  ||         \_/\_/|_| \__,_|_|\__|_||_| /_/ \_\_|_\|___/ /___/_/\_\
  || 
  ||              xiaoha_realplate  兼容wk_wars2x 版本   真实车牌系统 汉化版
  || 				后续更新请关注 xiaoha-6 GitHub https://github.com/xiaoha-6?tab=repositories  地址  自行关注 不会提示更新哈 或者加xiaoha 售后群 会在群内通知QQ售后群 863407368
  ||					xiaoha qq 2065345911  
  ||]]
function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end
PerformHttpRequest( "https://wolfknight98.github.io/wk_wars2x_web/version.txt", function( err, text, headers )
	Citizen.Wait( 2000 )
	print( label )
	local curVer = GetCurrentVersion()
	print( "  ||    当前版本: " .. curVer )
	if ( text ~= nil ) then
		print( "  ||    最新推荐版本: " .. text .."\n  ||" )
		if ( text ~= curVer ) then
			print( "  ||    ^1您的 Wraith ARS 2X 版本已过时，请访问 FiveM 论坛获取最新版本。\n^0  \\\\\n" )
		else
			print( "  ||    ^2Wraith ARS 2X 已是最新版本！\n^0  ||\n  \\\\\n" )
		end
	else
		print( "  ||    ^1获取最新版本信息时发生错误。\n^0  ||\n  \\\\\n" )
	end
	if ( GetCurrentResourceName() ~= "wk_wars2x" ) then
		print( "^1错误: 资源名称不是 wk_wars2x，这可能导致资源功能异常。为确保正常运行，请保持资源名称为 wk_wars2x^0\n\n" )
	end
end )