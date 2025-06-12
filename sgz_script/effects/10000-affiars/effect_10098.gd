extends "effect_10000.gd"

#谍网效果测试
#【谍网】内政，锁定技。随机刺探并汇报有价值的情况。（重要武将去向、太守忠诚度等敌方弱点，未来加战场随机事件的发现）

const EFFECT_ID = 10098
const FLOW_BASE = "effect_" + str(EFFECT_ID)

enum InfoType {
	COMMON = 0,
	HERO_RECRUIT = 1, # 可招揽武将
	LEADER_LOYALTY =  2, # 不忠的太守
	HERO_TRANSFER = 3, # 重要武将转换阵营
}

# 扫描的情报类型
const INFO_TYPES = [
	InfoType.HERO_RECRUIT,
	InfoType.LEADER_LOYALTY,
	InfoType.HERO_TRANSFER,
]

class DieWangInfo:
	var info:Dictionary = {}
	var history:Dictionary = {}

	func reset()->void:
		info = {}
		return

	func load_env()->void:
		var data = DataManager.get_env_dict("DieWang")
		if "info" in data:
			info = Global.dicval(data["info"])
		if "history" in data:
			history = Global.dicval(data["history"])
		return

	func save_env()->void:
		var data = {}
		data["info"] = info
		data["history"] = history
		DataManager.set_env("DieWang", data)
		return

	# 判断是否新情报（未提示过）
	func noticed_recently(type:int, actorId:int, monthPassed:int=3)->bool:
		var tk = "T" + str(type)
		if not tk in history:
			return false
		var ak = "A" + str(actorId)
		if not ak in history[tk]:
			return false
		var lastNoticed = int(history[tk][ak])
		var timing = DataManager.year * 12 + DataManager.month
		return timing < lastNoticed + monthPassed

	# 标记已提示
	# 已经提示过的事，别总是没完没了
	func mark_noticed(type:int, actorId:int)->void:
		var tk = "T" + str(type)
		if not tk in history:
			history[tk] = {}
		var ak = "A" + str(actorId)
		var timing = DataManager.year * 12 + DataManager.month
		history[tk][ak] = timing
		save_env()
		return

	# 记录扫描到的情报
	func note_information(type:int, actorId:int)->bool:
		var tk = "T" + str(type)
		if noticed_recently(type, actorId, 3):
			return false
		if not tk in info:
			info[tk] = []
		info[tk].append(actorId)
		save_env()
		return true

	# 是否有值得汇报的信息
	func something_new()->bool:
		for type in INFO_TYPES:
			var tk = "T" + str(type)
			if not tk in info:
				continue
			if info[tk].empty():
				continue
			return true
		return false

	# 选择最有价值的一条汇报
	# @return [组装好的消息、actorId、cityId、lordId], 没有则为空
	func get_most_valuable(markReported:bool=false)->Array:
		# 可招揽武将
		var msgGroup = [
			[InfoType.HERO_RECRUIT, "谍报：{0}{1}，英才也\n现对{2}心怀不满\n有隙可乘，或可招揽"],
			[InfoType.LEADER_LOYALTY, "谍报：{0}{1}，英才也\n似有脱离{2}自立之意\n推波助澜，利或在我"],
			[InfoType.HERO_TRANSFER, "谍报：{1}，英才也\n近转投于{0}\n{2}声势大张，不可不察"],
		]
		for msgPair in msgGroup:
			var tk = "T" + str(msgPair[0])
			if not tk in info:
				continue
			var msg = msgPair[1]
			var maxScore = 0
			var target = null
			for actorId in info[tk]:
				var actor = ActorHelper.actor(actorId)
				var score = actor.get_wisdom() + actor.get_power() + actor.get_leadership()
				if score > maxScore:
					maxScore = score
					target = actor
			if target == null:
				continue
			if markReported:
				mark_noticed(InfoType.HERO_RECRUIT, target.actorId)
			var cityId = DataManager.get_office_city_by_actor(target.actorId)
			var city = clCity.city(cityId)
			var lord = ActorHelper.actor(city.get_lord_id())
			msg = msg.format([
				city.get_full_name(), target.get_name(), lord.get_name(),
			])
			return [msg, target.actorId, cityId, lord.actorId]
		return []

func on_trigger_10001()->bool:
	var cityId = DataManager.get_office_city_by_actor(actorId)
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	
	# 每月只有一个人发动，避免来回抢戏
	# 支持多玩家了再考虑冲突问题
	var uniqueKey = "内政.MONTHLY." + ske.skill_name
	if DataManager.get_env_int(uniqueKey) > 0:
		return false
	DataManager.set_env(uniqueKey, 1)

	var dw = DieWangInfo.new()
	dw.load_env()
	dw.reset()
	# 开始扫描
	for a in ActorHelper.all_actors():
		if not a.is_status_officed():
			# 未出仕的不管
			continue
		var cid = DataManager.get_office_city_by_actor(a.actorId)
		if cid < 0:
			continue
		var c = clCity.city(cid)
		var currentVstateId = c.get_vstate_id()
		if currentVstateId == vstateId:
			# 自势力武将不管
			continue
		if a.is_top_actor():
			if a.get_loyalty() < 50:
				# 可考虑招揽
				dw.note_information(InfoType.HERO_RECRUIT, a.actorId)
			elif a.get_prev_vstate_id() != currentVstateId:
				# 转换阵营
				dw.note_information(InfoType.HERO_TRANSFER, a.actorId)
		if a.get_loyalty() < 40:
			var actorIds = c.get_actor_ids()
			if not actorIds.empty() and a.actorId == actorIds[0]:
				# 可考虑策反
				# 转换阵营
				dw.note_information(InfoType.LEADER_LOYALTY, a.actorId)
	return dw.something_new()

func effect_10098_start()->void:
	var dw = DieWangInfo.new()
	dw.load_env()
	var info = dw.get_most_valuable(true)
	if info.empty():
		skill_end_clear()
		return
	var msg = info[0]
	var targetCityId = info[2]
	var cityId = DataManager.get_office_city_by_actor(actorId)
	var city = clCity.city(cityId)
	var lordId = city.get_lord_id()
	if lordId == actorId:
		play_dialog(actorId, msg, 2, 2999)
	else:
		play_dialog(actorId, msg, 2, 2000)
	DataManager.twinkle_citys = [cityId, targetCityId]
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirm")
	return

func effect_10098_confirm()->void:
	var cityId = DataManager.get_office_city_by_actor(actorId)
	var city = clCity.city(cityId)
	var lordId = city.get_lord_id()
	var msg = "{0}劳苦\n知之矣，当定对策".format([
		DataManager.get_actor_honored_title(actorId, lordId)
	])
	play_dialog(lordId, msg, 2, 2999)
	DataManager.twinkle_citys = [cityId]
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
