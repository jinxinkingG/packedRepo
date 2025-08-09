extends "effect_10000.gd"

# 佯退锁定技
#【佯退】内政，锁定技。你方在战争中撤退致战争失败的场合，同个月内，下次出征不消耗命令书。每月限1次。

func on_trigger_10013() -> bool:
	var wf = DataManager.get_current_war_fight()
	var wvId = DataManager.get_env_int("内政.战后.wvId")
	var wv = wf.get_war_vstate(wvId)
	if wv == null:
		return false
	if not wv.is_attacker():
		# 非主动攻击
		return false
	var cityId = get_working_city_id()
	if cityId == wf.target_city().ID:
		# 所在城是战争目标城
		return false
	var city = clCity.city(cityId)
	if city.get_vstate_id() != wv.vstateId:
		# 所在城不属于我方
		return false
	ske.affair_set_skill_val(1, 1)
	return false

func on_trigger_10022() -> bool:
	if ske.affair_get_skill_val_int() != 1:
		return false
	ske.affair_set_skill_val(0, 0)
	ske.affair_cd(1)
	var wf = DataManager.get_current_war_fight()
	var fromCity = wf.from_city()

	var messages = wf.get_env_array("攻击宣言")
	var msg = "越固守之險，击空虛之地\n掩其不备，必克敌而还\n（【{0}】后出征无须命令书".format([
		ske.skill_name,
	])
	messages.append([msg, actorId, 0])
	wf.set_env("攻击宣言", messages)
	wf.set_env("不消耗命令书", 1)
	return false
