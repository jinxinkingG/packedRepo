extends "effect_30000.gd"

#虎豹锁定技 #骑兵强化
#【虎豹】小战场,锁定技。非城战，白刃战初始，你可以选择<虎骑>和<豹骑>其中之一，并发动。

const OPTIONS = ["虎骑", "豹骑"]

func on_view_model_2000()->void:
	match wait_for_skill_option():
		0:
			DataManager.common_variable["虎豹选项"] = 0
			perform_tiger()
			LoadControl.end_script()
		1:
			DataManager.common_variable["虎豹选项"] = 1
			perform_leopard()
			LoadControl.end_script()
	return

func on_trigger_30005()->bool:
	if DataManager.battle_unit_type_hp(me.actorId, "骑") <= 0:
		return false
	if not SkillHelper.actor_has_skills(actorId, ["倾袭"]):
		# 进入选择
		return true

	# 同时发动
	perform_leopard()
	perform_tiger()
	# 标记虎豹已经同时发动
	ske.set_battle_skill_val(1)
	var d = War_Character.DialogInfo.new()
	d.text = "虎豹天下骁骑\n唯吾尽得其妙！\n（同时获得虎骑豹骑效果"
	d.actorId = me.actorId
	d.mood = 0
	d.sceneId = 30000
	me.add_dialog_info(d)
	return false

func on_trigger_30099()->bool:
	SkillHelper.remove_scene_actor_skill(30000, me.actorId, "虎骑")
	SkillHelper.remove_scene_actor_skill(30000, me.actorId, "豹骑")
	return false

func effect_30115_AI_start():
	# 随机二选一
	if Global.get_random(0, 10) % 2 == 0:
		perform_leopard()
		LoadControl.end_script()
	else:
		perform_tiger()
		LoadControl.end_script()
	return

func effect_30115_start():
	var options = OPTIONS.duplicate()
	DataManager.common_variable["列表值"] = options
	SceneManager.show_yn_dialog("选择【虎豹】发动形态", me.actorId, 2, ["虎骑", "豹骑"])
	if DataManager.common_variable.has("虎豹选项"):
		var lastOption = get_env_int("虎豹选项")
		if lastOption == 0 or lastOption == 1:
			SceneManager.actor_dialog.lsc.cursor_index = lastOption
	LoadControl.set_view_model(2000)
	return

func perform_leopard():
	SkillHelper.add_actor_scene_skill(30000, me.actorId, "豹骑", 99999)
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != ske.skill_actorId:
			continue
		if bu.get_unit_type() != "骑":
			continue
		bu.init_combat_info()
	return

func perform_tiger():
	SkillHelper.add_actor_scene_skill(30000, me.actorId, "虎骑", 99999)
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != ske.skill_actorId:
			continue
		if bu.get_unit_type() != "骑":
			continue
		bu.init_combat_info()
	return
