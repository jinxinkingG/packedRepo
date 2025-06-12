extends "effect_10000.gd"

#困锁效果，除主将限制外在这里实现
#【困锁】内政,锁定技。每月你的经验+600，非君主时，你无法作为主将出征。若你是君主，永久转为阳面，若你不是君主，永久转为阴面

func on_trigger_10001()->bool:
	actor.add_exp(600)
	if actor.get_loyalty() == 100:
		for vs in clVState.all_vstates():
			if vs.get_lord_id() == actorId:
				actor.set_face(true)
				return false
	actor.set_face(false)
	return false

func on_trigger_10022()->bool:
	if actor.get_loyalty() == 100:
		return false
	var wf = DataManager.get_current_war_fight()
	if wf.sendActors.empty():
		return false
	return wf.sendActors[0] == actorId

func effect_10016_start():
	SceneManager.hide_all_tool()
	SceneManager.show_confirm_dialog("朕……并无掌军之意\n公勿相疑，请另派主将", actorId, 3)
	var st = SkillHelper.get_current_skill_trigger()
	var wf = DataManager.get_current_war_fight()
	if wf.sendActors.size() == 1:
		# 仅选择刘协出征的情况
		st.next_flow = "barrack_enter_menu"
	else:
		# 多人出征，选择刘协为主将的情况
		st.next_flow = "attack_choose_main_actor"
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("enter_barrack_menu")
	return
