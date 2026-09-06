extends "effect_10000.gd"

#荐书主动技
#【荐书】内政，主动技。你可以指定一个本城忠＜70的己方武将，令其加入其他势力，每月限1次。（加入该其他势力君主所在城，加入后默认忠70。）。

const EFFECT_ID = 10063
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10063_start() -> void:
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var targets = []
	for targetId in city.get_actor_ids():
		if targetId == actorId:
			continue
		if ActorHelper.actor(targetId).get_loyalty() < 70:
			targets.append(targetId)
	if targets.empty():
		var msg = "本城并无怀才不遇的武将"
		play_dialog(actorId, msg, 2, 2999)
		return
	var props = ["体", "武", "知", "忠", "德", "兵力"]
	SceneManager.show_actorlist(targets, false, "请选择【荐书】目标", false, props)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	if not wait_for_choose_actor():
		return
	var targetId = SceneManager.actorlist.get_select_actor()
	if targetId < 0:
		return
	ske.affair_set_skill_val([targetId, -1], 1)
	goto_step("selected")
	return

func effect_10063_selected() -> void:
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标势力")
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001_delta(delta:float)->void:
	var settings = ske.affair_get_skill_val_int_array()
	if settings.size() != 2:
		goto_step("start")
		return
	var cityId = wait_for_choose_city(delta, "player_ready")
	if cityId < 0:
		return
	var city = clCity.city(cityId)
	if city.get_vstate_id() < 0:
		SceneManager.show_unconfirm_dialog("此为空城")
		return
	var fromCity = clCity.city(DataManager.player_choose_city)
	if fromCity.get_vstate_id() == city.get_vstate_id():
		SceneManager.show_unconfirm_dialog("请选择其他势力城市")
		return
	settings[1] = city.get_vstate_id()
	ske.affair_set_skill_val(settings, 1)
	goto_step("targeted")
	return

func effect_10063_targeted() -> void:
	var settings = ske.affair_get_skill_val_int_array()
	if settings.size() != 2:
		goto_step("start")
		return
	var targetId = settings[0]
	var vstateId = settings[1]
	var capital = clCity.get_capital_city(vstateId)
	if capital == null:
		var msg = "无法送达荐书"
		play_dialog(actorId, msg, 2, 2999)
		return
	SceneManager.hide_all_tool()
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [capital.ID]
	var msg = "修书一封\n推荐{0}至{1}麾下\n可否？".format([
		ActorHelper.actor(targetId).get_name(),
		capital.get_leader().get_name(),
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002()->void:
	wait_for_yesno(FLOW_BASE + "_go", "player_ready")
	return

func effect_10063_go() -> void:
	var settings = ske.affair_get_skill_val_int_array()
	if settings.size() != 2:
		goto_step("start")
		return
	var targetId = settings[0]
	var vstateId = settings[1]
	var capital = clCity.get_capital_city(vstateId)
	var msg = "{0}在此，志向难申\n{1}对将军心慕久矣\n凭某荐书往投，意下如何？".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		DataManager.get_actor_honored_title(capital.get_actor_ids()[0], actorId),
	])
	SceneManager.hide_all_tool()
	SceneManager.show_confirm_dialog(msg, actorId)
	LoadControl.set_view_model(2003)
	return

func on_view_model_2003()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_done")
	return

func effect_10063_done() -> void:
	var settings = ske.affair_get_skill_val_int_array()
	if settings.size() != 2:
		goto_step("start")
		return
	var targetId = settings[0]
	var vstateId = settings[1]
	var capital = clCity.get_capital_city(vstateId)
	var msg = "{0}真乃忠厚长者\n多承美意，吾当从之\n此情容后相报".format([
		DataManager.get_actor_honored_title(actorId, targetId),
	])
	SceneManager.show_confirm_dialog(msg, targetId)
	LoadControl.set_view_model(2004)
	return

func on_view_model_2004()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_report")
	return

func effect_10063_report() -> void:
	var settings = ske.affair_get_skill_val_int_array()
	if settings.size() != 2:
		goto_step("start")
		return
	var targetId = settings[0]
	var vstateId = settings[1]
	var capital = clCity.get_capital_city(vstateId)
	var targetActor = ActorHelper.actor(targetId)

	ske.affair_cd(1)
	clCity.transfer_to(targetId, capital.ID)
	targetActor.set_loyalty(70)
	var msg = "{0}转投{1}势力\n出仕于{2}".format([
		targetActor.get_name(),
		capital.get_leader().get_name(),
		capital.get_name(),
	])
	play_dialog(-1, msg, 2, 2999)
	return
