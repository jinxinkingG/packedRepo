extends "effect_10000.gd"

# 选嫡主动技
#【选嫡】内政，主动技。你可指定本势力除自己和君主之外的一名武将，附加「选嫡」标记。游戏中限1次。（已选：<未指定>）

const EFFECT_ID = 10119
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10119_start() -> void:
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float) -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targets = get_target_city_ids(city.ID)
	DataManager.twinkle_citys = targets
	var cityId = wait_for_choose_city(delta, "player_ready", targets)
	if cityId < 0:
		return
	if not cityId in targets:
		SceneManager.show_unconfirm_dialog("请选择自势力城市")
		return
	DataManager.set_env("目标", cityId)
	goto_step("selected")
	return

func effect_10119_selected() -> void:
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var actorIds = targetCity.get_actor_ids()
	actorIds.erase(targetCity.get_lord_id())
	actorIds.erase(actorId)
	var msg = "请选择【{0}】目标".format([ske.skill_name])
	SceneManager.show_actorlist_develop(actorIds, false, msg)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	if not wait_for_choose_actor():
		return
	var targetId = SceneManager.actorlist.get_select_actor()
	DataManager.set_env("目标", targetId)
	goto_step("actor_selected")
	return

func effect_10119_actor_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "【{0}】{1}\n不可更改\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2002, true)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10119_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}英武，必能克承大业\n{1}竭诚拥戴，万死不辞".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		actor.get_short_name(),
	])
	ske.affair_set_skill_val(targetId)
	ske.affair_cd(99999)
	play_dialog(actorId, msg, 0, 2999)
	return

func get_target_city_ids(cityId:int)->PoolIntArray:
	var city = clCity.city(cityId)
	var targets = []
	for c in clCity.all_cities([city.get_vstate_id()]):
		var actorIds = c.get_actor_ids()
		actorIds.erase(c.get_lord_id())
		actorIds.erase(actorId)
		if actorIds.empty():
			continue
		targets.append(c.ID)
	targets.sort()
	return targets
