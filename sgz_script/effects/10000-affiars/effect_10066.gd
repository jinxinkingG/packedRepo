extends "effect_10000.gd"

# 邀虎锁定效果
#【邀虎】内政，君主锁定技。其他势力，可以选择向「与你方相邻的任意敌城」发起攻击。若其如此，下次你方回合开始时，你方命令书+1。

const EFFECT_ID = 10066
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EVENT_KEY = "邀虎.触发"

func effect_10066_start() -> void:
	var row = Array(get_env(EVENT_KEY))
	unset_env(EVENT_KEY)
	var fromVstateId = int(row[5])
	var targetVstateId = int(row[6])
	var msg = "{0}果然对{1}动手\n吾可高枕无忧矣\n（因邀虎效果，命令书+1".format([
		clVState.vstate(fromVstateId).get_lord_name(),
		clVState.vstate(targetVstateId).get_lord_name(),
	])
	SceneManager.show_confirm_dialog(msg, self.actorId, 1)
	DataManager.orderbook += 1
	LoadControl.set_view_model(2999)
	return

func on_trigger_10001()->bool:
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
		if targetCity.get_connected_city_ids([myVstateId]).empty():
			# 目标城市与我方并不相邻
			continue
		# 比较触发标记，检查是不是新的战争记录
		var prev = _get_prev_trigger()
		if prev.size() == 2 and prev[0] >= timing and prev[1] >= vstateIndex:
			continue
		# 触发技能
		set_env(EVENT_KEY, row)
		break
	# 更新触发标记
	_update_prev_trigger()
	return check_env([EVENT_KEY])

func _get_prev_trigger() -> Array:
	return ske.affair_get_skill_val_int_array()

func _update_prev_trigger() -> void:
	var tm = DataManager.year * 12 + DataManager.month
	var idx = DataManager.vstate_no
	ske.affair_set_skill_val([tm, idx])
	return
