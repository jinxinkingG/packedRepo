extends "effect_10000.gd"

# 驱虎锁定效果
#【驱虎】内政，锁定技。你所在势力相邻的两个势力之间发起战争的场合，下次你方回合开始，你方的命令书+1（不可叠加）。

const EFFECT_ID = 10067
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EVENT_KEY = "驱虎.触发"

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	return

func _input_key(delta:float):
	match LoadControl.get_view_model():
		2000:
			wait_for_skill_result_confirmation()
	return

func effect_10067_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var row = Array(get_env(EVENT_KEY))
	unset_env(EVENT_KEY)
	var fromVstateId = int(row[5])
	var targetVstateId = int(row[6])
	var msg = "{0}、{1}二虎相争\n我军势将游刃有余\n（因驱虎效果，命令书+1".format([
		clVState.vstate(fromVstateId).get_lord_name(),
		clVState.vstate(targetVstateId).get_lord_name(),
	])
	SceneManager.show_confirm_dialog(msg, self.actorId, 1)
	DataManager.orderbook += 1
	LoadControl.set_view_model(2000)
	return

func check_trigger_correct()->bool:
	unset_env(EVENT_KEY)
	if DataManager.get_scene_actor_control(actorId) < 0:
		# AI 不触发
		return false
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	var myVstateId = city.get_vstate_id()
	# 检查过去两个月的战争历史
	var cur = DataManager.year * 12 + DataManager.month
	var rows = DataManager.war_history.duplicate(true)
	rows.invert()
	for row in rows:
		if row.size() < 7:
			continue
		var year = int(row[0])
		var month = int(row[1])
		# 忽略旧记录
		var timing = year * 12 + month
		if timing <= cur - 2:
			continue
		var vstateIndex = int(row[2])
		var fromCityId = int(row[3])
		var targetCityId = int(row[4])
		var fromVstateId = int(row[5])
		var targetVstateId = int(row[6])
		if fromVstateId == myVstateId:
			# 我方出击，忽略
			continue
		if targetVstateId in [-1, myVstateId]:
			# 进攻空城或我方，忽略
			continue
		var targetCity = clCity.city(targetCityId)
		if not targetCity.get_connected_city_ids([myVstateId]).empty():
			# 目标城市与我相邻，即可触发
			set_env(EVENT_KEY, row)
			break
		# 目标城市不相邻，判断双方势力是否与我方相邻
		var fromConnected = false
		for fromVstateCity in clCity.all_cities([fromVstateId]):
			if not fromVstateCity.get_connected_city_ids([myVstateId]).empty():
				fromConnected = true
				break
		if not fromConnected:
			continue
		var targetConnected = false
		for targetVstateCity in clCity.all_cities([targetVstateId]):
			if not targetVstateCity.get_connected_city_ids([myVstateId]).empty():
				targetConnected = true
				break
		if not targetConnected:
			continue
		# 触发技能
		set_env(EVENT_KEY, row)
		break
	# 更新触发标记
	_update_prev_trigger()
	return check_env([EVENT_KEY])

func _get_prev_trigger()->Dictionary:
	var ret = {
		"tm": -1,
		"idx": -1
	}
	var skv = SkillHelper.get_skill_variable(10000, EFFECT_ID, self.actorId)
	if skv["turn"] <= 0 or skv["value"] == null:
		return ret
	if typeof(skv["value"]) != TYPE_DICTIONARY:
		return ret
	for k in ret:
		if k in skv["value"]:
			ret[k] = int(skv["value"][k])
	return ret

func _update_prev_trigger():
	var dic = {
		"tm": DataManager.year * 12 + DataManager.month,
		"idx": DataManager.vstate_no
	}
	SkillHelper.set_skill_variable(10000, EFFECT_ID, self.actorId, dic, 99999)
	return
