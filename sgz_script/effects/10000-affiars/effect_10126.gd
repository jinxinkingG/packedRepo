extends "effect_10000.gd"

# 共乱主动技
#【共乱】内政，主动技。①“敌方君主与你方君主同姓时”或者“邻城太守与你方君主同姓时”，你可以发动：无需消耗命令书出征该势力或者该城。②以此法发动的战争中，若你方武将无人拥有<戈室>，你方主将获得<戈室>。

const EFFECT_ID = 10126
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "戈室"
const TARGET_EFFECT_ID = 20364

func effect_10126_start():
	var city = clCity.city(DataManager.player_choose_city)
	var candidates = get_target_city_ids(city)
	if candidates.empty():
		var msg = "没有可以发动的目标城市"
		play_dialog(actorId, msg, 3, 2999)
		return
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float)->void:
	var city = clCity.city(DataManager.player_choose_city)
	var targets = get_target_city_ids(city)
	DataManager.twinkle_citys = targets.keys()
	var cityId = wait_for_choose_city(delta, "enter_barrack_menu", targets.keys())
	if cityId < 0:
		return
	if clCity.city(cityId).get_vstate_id() == city.get_vstate_id():
		SceneManager.show_unconfirm_dialog("此为自势力城市")
		return
	if not cityId in targets:
		SceneManager.show_unconfirm_dialog("请选择【{0}】目标城市".format([ske.skill_name]))
		return
	DataManager.set_env("目标", cityId)
	goto_step("selected")
	return

func effect_10126_selected() -> void:
	var targetCityId = DataManager.get_env_int("目标")
	var msg = "【{0}】攻击{1}\n无须命令书\n可否？".format([
		ske.skill_name, clCity.city(targetCityId).get_name()
	])
	play_dialog(actorId, msg, 0, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10126_confirmed() -> void:
	var targetCityId = DataManager.get_env_int("目标")
	var wf = DataManager.new_war_fight(DataManager.player_choose_city, targetCityId)
	wf.source = ske.skill_name
	wf.set_env("不消耗命令书", 1)
	LoadControl.end_script()
	LoadControl.load_script("affiars/barrack_attack.gd")
	FlowManager.add_flow("attack_choose_actors")
	return

func on_trigger_10011()->bool:
	var wf = DataManager.get_current_war_fight()
	if wf.source != ske.skill_name:
		return false
	ske.affair_cd(1)
	var leader = ActorHelper.actor(wf.sendActors[0])
	var messages = wf.get_env_array("攻击宣言")
	var msg = "同宗不同心者，岂能坐视！"
	var appendSkill = true
	for attackerId in wf.sendActors:
		if SkillHelper.actor_has_skills(attackerId, ["戈室"], true):
			appendSkill = false
			break
	if appendSkill:
		var appendedSkills = wf.get_env_array("战前附加技能")
		appendedSkills.append([
			leader.actorId, TARGET_SKILL, 99999,
			actorId, ske.skill_name,
		])
		wf.set_env("战前附加技能", appendedSkills)
		var skillVars = wf.get_env_array("战前技能变量")
		skillVars.append([
			leader.actorId, TARGET_EFFECT_ID, [wf.from_city().get_lord_id()], 99999,
		])
		wf.set_env("战前技能变量", skillVars)
		msg += "\n（{0}获得【{1}】".format([
			leader.get_name(), TARGET_SKILL,
		])
	messages.append([msg, actorId, 0])
	wf.set_env("攻击宣言", messages)
	return false

func get_target_city_ids(city:clCity.CityInfo)->Dictionary:
	var ret = {}
	var fn = city.get_lord().get_first_name()
	var attackables = clCity.get_attackable_city_ids(city)
	for targetCityId in attackables:
		var targetCity = clCity.city(targetCityId)
		var leader = targetCity.get_leader()
		if leader.get_first_name() == fn:
			ret[targetCityId] = attackables[targetCityId]
			continue
		var lord = targetCity.get_lord()
		if lord.get_first_name() == fn:
			ret[targetCityId] = attackables[targetCityId]
			continue
	return ret
