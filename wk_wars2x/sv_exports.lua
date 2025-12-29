--[[---------------------------------------------------------------------------------------

	Wraith ARS 2X
	Created by WolfKnight
	
	For discussions, information on future updates, and more, join 
	my Discord: https://discord.gg/fD4e6WD 
	
	MIT License

	Copyright (c) 2020 WolfKnight

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

---------------------------------------------------------------------------------------]]--

-- Although there is only one export at the moment, more may be added down the line. 

--[[---------------------------------------------------------------------------------------
	Locks the designated plate reader camera for the given client. 

	Parameters:
		clientId:
			The id of the client
		cam:
			The camera to lock, either "front" or "rear"
		beepAudio:
			Play an audible beep, either true or false
		boloAudio:
			Play the bolo lock sound, either true or false
---------------------------------------------------------------------------------------]]--
function TogglePlateLock( clientId, cam, beepAudio, boloAudio )
	TriggerClientEvent( "wk:togglePlateLock", clientId, cam, beepAudio, boloAudio )
end

--[[---------------------------------------------------------------------------------
	xiaoha_realplate 车牌识别系统对接
	
	支持的框架:
	- ESX (es_extended)
	- QBCore (qb-core)
	- QBox (qbx_core)
	- ox_core
	- ND_Core
	
	支持的调度系统:
	- ps-dispatch
	- cd_dispatch  
	- qs-dispatch
	- ox_dispatch / ox_mdt / bub_mdt
	- core_dispatch (QBox常用)
	- linden_outlawalert
	- origen_police
	- Renewed-Lib
	
	事件说明:
	- wk:onPlateScanned: 扫描到车牌时触发 (cam, plate, index)
	- wk:onPlateLocked: 锁定车牌时触发 (cam, plate, index)
	- wk_wars2x:plateScanned: 通用扫描事件 (source, plate, index, cam)
	- wk_wars2x:plateLocked: 通用锁定事件 (source, plate, index, cam)
	- wk_wars2x:boloSet: BOLO设置事件 (plate, plateType, plateTypeName, senderName)
	- wk_wars2x:boloCleared: BOLO清除事件 (plate, senderName)
---------------------------------------------------------------------------------]]

-- 存储扫描到的车牌数据
local scannedPlates = {}

-- 车牌扫描事件 (xiaoha_realplate 对接)
RegisterNetEvent("wk:onPlateScanned")
AddEventHandler("wk:onPlateScanned", function(cam, plate, index)
	local source = source
	
	if not plate or plate == "" then return end
	
	-- 存储扫描数据
	scannedPlates[source] = {
		plate = plate,
		index = index,
		cam = cam,
		time = os.time()
	}
	
	-- 触发通用事件供其他资源监听
	TriggerEvent("wk_wars2x:plateScanned", source, plate, index, cam)
	
	-- ps-dispatch 对接
	if GetResourceState("ps-dispatch") == "started" then
		TriggerEvent("ps-dispatch:server:plateScanned", source, plate)
	end
	
	-- cd_dispatch 对接
	if GetResourceState("cd_dispatch") == "started" then
		TriggerEvent("cd_dispatch:plateScanned", source, plate)
	end
	
	-- qs-dispatch 对接
	if GetResourceState("qs-dispatch") == "started" then
		TriggerEvent("qs-dispatch:server:plateScanned", source, plate)
	end
	
	-- ox_dispatch / bub_mdt 对接
	if GetResourceState("ox_mdt") == "started" then
		TriggerEvent("ox_mdt:plateScanned", source, plate)
	end
	
	-- origen_police 对接
	if GetResourceState("origen_police") == "started" then
		TriggerEvent("origen_police:plateScanned", source, plate)
	end
end)

-- 车牌锁定事件 (xiaoha_realplate 对接)
RegisterNetEvent("wk:onPlateLocked")
AddEventHandler("wk:onPlateLocked", function(cam, plate, index)
	local source = source
	
	if not plate or plate == "" then return end
	
	-- 触发通用事件供其他资源监听
	TriggerEvent("wk_wars2x:plateLocked", source, plate, index, cam)
	
	-- ps-dispatch 对接
	if GetResourceState("ps-dispatch") == "started" then
		TriggerEvent("ps-dispatch:server:plateLocked", source, plate)
	end
	
	-- cd_dispatch 对接
	if GetResourceState("cd_dispatch") == "started" then
		TriggerEvent("cd_dispatch:plateLocked", source, plate)
	end
	
	-- qs-dispatch 对接
	if GetResourceState("qs-dispatch") == "started" then
		TriggerEvent("qs-dispatch:server:plateLocked", source, plate)
	end
end)

-- 导出函数: 获取玩家最近扫描的车牌
function GetLastScannedPlate(playerId)
	return scannedPlates[playerId]
end
exports("GetLastScannedPlate", GetLastScannedPlate)

-- 导出函数: 设置BOLO车牌 (从调度系统调用)
function SetBOLOPlate(playerId, plate)
	TriggerClientEvent("wk:setBOLOPlate", playerId, plate)
end
exports("SetBOLOPlate", SetBOLOPlate)

-- 客户端请求设置BOLO
RegisterNetEvent("wk:requestSetBOLO")
AddEventHandler("wk:requestSetBOLO", function(plate)
	local source = source
	TriggerClientEvent("wk:setBOLOPlate", source, plate)
end)

--[[---------------------------------------------------------------------------------
	通缉车牌广播系统
	
	支持:
	- 调度系统集成 (ps-dispatch, cd_dispatch, qs-dispatch等)
	- 原生blip显示 (无调度系统时)
	- 全警员通知
---------------------------------------------------------------------------------]]

-- 当前通缉车牌数据
local currentBOLO = {
	plate = nil,
	plateType = nil,
	plateTypeName = nil,
	sender = nil,
	time = nil
}

-- 警察职业列表 (可自定义)
local policeJobs = {
	["police"] = true,
	["sheriff"] = true,
	["lspd"] = true,
	-- ["bcso"] = true,
	-- ["sasp"] = true,
	-- ["sahp"] = true,
	-- ["fib"] = true,
	-- ["doj"] = true,
	-- ["leo"] = true,
	-- ["trooper"] = true,
	-- ["ranger"] = true,
	-- ["marshal"] = true,
}

-- 检查玩家是否是警察 (兼容多种框架)
local function IsPlayerPolice(playerId)
	-- ESX框架
	if GetResourceState("es_extended") == "started" then
		local success, xPlayer = pcall(function()
			return exports["es_extended"]:getSharedObject().GetPlayerFromId(playerId)
		end)
		if success and xPlayer then
			local job = xPlayer.getJob()
			if job and policeJobs[job.name] then
				return true
			end
		end
	end
	
	-- QBCore框架
	if GetResourceState("qb-core") == "started" then
		local success, result = pcall(function()
			local QBCore = exports["qb-core"]:GetCoreObject()
			local Player = QBCore.Functions.GetPlayer(playerId)
			return Player
		end)
		if success and result then
			local job = result.PlayerData.job
			if job and policeJobs[job.name] then
				return true
			end
		end
	end
	
	-- QBox框架 (qbx_core)
	if GetResourceState("qbx_core") == "started" then
		local success, result = pcall(function()
			return exports.qbx_core:GetPlayer(playerId)
		end)
		if success and result then
			local job = result.PlayerData.job
			if job and policeJobs[job.name] then
				return true
			end
		end
	end
	
	-- ox_core框架
	if GetResourceState("ox_core") == "started" then
		local success, result = pcall(function()
			local player = Ox.GetPlayer(playerId)
			if player then
				return player.getGroups()
			end
			return nil
		end)
		if success and result then
			if result.police or result.sheriff or result.leo then
				return true
			end
		end
	end
	
	-- ND_Core框架
	if GetResourceState("ND_Core") == "started" then
		local success, result = pcall(function()
			return exports.ND_Core:getPlayer(playerId)
		end)
		if success and result and result.job then
			if policeJobs[result.job] then
				return true
			end
		end
	end
	
	-- 如果没有检测到框架，默认允许所有人接收 (可以根据需要修改)
	return true
end

-- 获取玩家名称
local function GetPlayerDisplayName(playerId)
	local name = GetPlayerName(playerId)
	
	-- ESX框架
	if GetResourceState("es_extended") == "started" then
		local success, xPlayer = pcall(function()
			return exports["es_extended"]:getSharedObject().GetPlayerFromId(playerId)
		end)
		if success and xPlayer then
			local charName = xPlayer.getName()
			if charName then
				name = charName
			end
		end
	end
	
	-- QBCore框架
	if GetResourceState("qb-core") == "started" then
		local success, Player = pcall(function()
			local QBCore = exports["qb-core"]:GetCoreObject()
			return QBCore.Functions.GetPlayer(playerId)
		end)
		if success and Player then
			local charinfo = Player.PlayerData.charinfo
			if charinfo then
				name = charinfo.firstname .. " " .. charinfo.lastname
			end
		end
	end
	
	-- QBox框架 (qbx_core)
	if GetResourceState("qbx_core") == "started" then
		local success, Player = pcall(function()
			return exports.qbx_core:GetPlayer(playerId)
		end)
		if success and Player then
			local charinfo = Player.PlayerData.charinfo
			if charinfo then
				name = charinfo.firstname .. " " .. charinfo.lastname
			end
		end
	end
	
	-- ox_core框架
	if GetResourceState("ox_core") == "started" then
		local success, player = pcall(function()
			return Ox.GetPlayer(playerId)
		end)
		if success and player then
			local charName = player.get("firstName") .. " " .. player.get("lastName")
			if charName and charName ~= " " then
				name = charName
			end
		end
	end
	
	-- ND_Core框架
	if GetResourceState("ND_Core") == "started" then
		local success, player = pcall(function()
			return exports.ND_Core:getPlayer(playerId)
		end)
		if success and player then
			if player.firstname and player.lastname then
				name = player.firstname .. " " .. player.lastname
			end
		end
	end
	
	return name or ("玩家" .. playerId)
end

-- 广播通缉车牌
RegisterNetEvent("wk_wars2x:broadcastBOLO")
AddEventHandler("wk_wars2x:broadcastBOLO", function(plate, plateType, plateTypeName)
	local source = source
	local senderName = GetPlayerDisplayName(source)
	
	if not plate or plate == "" then return end
	
	-- 存储当前通缉
	currentBOLO = {
		plate = plate,
		plateType = plateType,
		plateTypeName = plateTypeName or "未知类型",
		sender = senderName,
		time = os.time()
	}
	
	print("[wk_wars2x] 🚨 通缉广播: " .. plate .. " (" .. (plateTypeName or "") .. ") 发布者: " .. senderName)
	
	-- 检查调度系统并触发
	local hasDispatch = false
	
	-- ps-dispatch
	if GetResourceState("ps-dispatch") == "started" then
		hasDispatch = true
		TriggerEvent("ps-dispatch:server:notify", {
			message = "通缉车牌: " .. plate,
			code = "10-29",
			icon = "fas fa-car",
			priority = 2,
			coords = nil,
			job = {"police", "sheriff", "lspd", "bcso"}
		})
	end
	
	-- cd_dispatch
	if GetResourceState("cd_dispatch") == "started" then
		hasDispatch = true
		TriggerEvent("cd_dispatch:AddNotification", {
			job_table = {"police", "sheriff", "lspd", "bcso"},
			coords = nil,
			title = "🚨 通缉车牌",
			message = "车牌号: " .. plate .. "\n类型: " .. (plateTypeName or "未知"),
			flash = 1,
			unique_id = "bolo_" .. plate,
			sound = 1,
			blip = {
				sprite = 326,
				scale = 1.2,
				colour = 1,
				flashes = true,
				text = "通缉: " .. plate,
				time = 300,
				radius = 0
			}
		})
	end
	
	-- qs-dispatch
	if GetResourceState("qs-dispatch") == "started" then
		hasDispatch = true
		TriggerEvent("qs-dispatch:server:CreateDispatch", {
			job = {"police", "sheriff"},
			callCode = "10-29",
			message = "通缉车牌: " .. plate .. " (" .. (plateTypeName or "") .. ")",
			flashes = true,
			image = nil,
			blip = {
				sprite = 326,
				scale = 1.2,
				colour = 1,
				flashes = true,
				text = "通缉: " .. plate,
				time = 300
			},
			isImportant = true
		})
	end
	
	-- origen_police / linden_outlawalert
	if GetResourceState("origen_police") == "started" then
		hasDispatch = true
		TriggerEvent("origen_police:dispatchAlert", {
			code = "10-29",
			message = "通缉车牌: " .. plate,
			coords = nil
		})
	end
	
	-- core_dispatch (常见于QBox)
	if GetResourceState("core_dispatch") == "started" then
		hasDispatch = true
		TriggerEvent("core_dispatch:addCall", 
			"10-29", 
			"通缉车牌",
			{{icon = "fa-car", info = plate}, {icon = "fa-tag", info = plateTypeName or "未知类型"}},
			{x = 0, y = 0, z = 0},
			"police",
			5000,
			1
		)
	end
	
	-- linden_outlawalert
	if GetResourceState("linden_outlawalert") == "started" then
		hasDispatch = true
		TriggerEvent("linden_outlawalert:CreateAlert", {
			alertCode = "10-29",
			alertTitle = "通缉车牌",
			alertDetails = "车牌号: " .. plate .. " | 类型: " .. (plateTypeName or "未知"),
		})
	end
	
	-- Renewed-Lib (qbox常用)
	if GetResourceState("Renewed-Lib") == "started" then
		hasDispatch = true
		-- 使用 ox_lib 通知
		exports["Renewed-Lib"]:notify({
			title = "🚨 通缉车牌",
			description = "车牌: " .. plate .. " (" .. (plateTypeName or "") .. ")",
			type = "error",
			duration = 10000
		})
	end
	
	-- 广播给所有在线警员
	local players = GetPlayers()
	for _, playerId in ipairs(players) do
		local pid = tonumber(playerId)
		if IsPlayerPolice(pid) then
			-- 发送BOLO通知
			TriggerClientEvent("wk_wars2x:receiveBOLO", pid, plate, plateType, plateTypeName or "未知类型", senderName)
			
			-- 如果没有调度系统，使用原生通知
			if not hasDispatch then
				-- 使用聊天通知
				TriggerClientEvent("chat:addMessage", pid, {
					color = {255, 0, 0},
					multiline = true,
					args = {"🚨 通缉警报", "车牌: " .. plate .. " | 类型: " .. (plateTypeName or "未知") .. " | 发布: " .. senderName}
				})
			end
		end
	end
	
	-- 触发通用事件供其他资源监听
	TriggerEvent("wk_wars2x:boloSet", plate, plateType, plateTypeName, senderName)
end)

-- 清除通缉广播
RegisterNetEvent("wk_wars2x:clearBOLOBroadcast")
AddEventHandler("wk_wars2x:clearBOLOBroadcast", function()
	local source = source
	local senderName = GetPlayerDisplayName(source)
	
	local oldPlate = currentBOLO.plate
	
	-- 清除当前通缉
	currentBOLO = {
		plate = nil,
		plateType = nil,
		plateTypeName = nil,
		sender = nil,
		time = nil
	}
	
	print("[wk_wars2x] ✅ 通缉清除: " .. (oldPlate or "无") .. " 操作者: " .. senderName)
	
	-- 广播给所有在线警员
	local players = GetPlayers()
	for _, playerId in ipairs(players) do
		local pid = tonumber(playerId)
		if IsPlayerPolice(pid) then
			TriggerClientEvent("wk_wars2x:clearBOLOReceived", pid, senderName)
			TriggerClientEvent("wk_wars2x:removeBOLOBlip", pid)
		end
	end
	
	-- 触发通用事件
	TriggerEvent("wk_wars2x:boloCleared", oldPlate, senderName)
end)

-- 导出: 获取当前通缉信息
function GetCurrentBOLO()
	return currentBOLO
end
exports("GetCurrentBOLO", GetCurrentBOLO)

-- 导出: 手动设置通缉 (供其他资源调用)
function BroadcastBOLO(plate, plateType, plateTypeName, senderName)
	currentBOLO = {
		plate = plate,
		plateType = plateType,
		plateTypeName = plateTypeName or "未知类型",
		sender = senderName or "系统",
		time = os.time()
	}
	
	local players = GetPlayers()
	for _, playerId in ipairs(players) do
		local pid = tonumber(playerId)
		if IsPlayerPolice(pid) then
			TriggerClientEvent("wk_wars2x:receiveBOLO", pid, plate, plateType, plateTypeName, senderName or "系统")
		end
	end
end
exports("BroadcastBOLO", BroadcastBOLO)