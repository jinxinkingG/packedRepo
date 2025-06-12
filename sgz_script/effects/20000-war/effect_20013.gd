extends "effect_20000.gd"

#骁勇主动技部分
#【骁勇】大战场,主动技。1回合1次，消耗1机动力发动：你可选择回到前3~10步之内的任意位置。以此效果进行位移后，若你相邻存在可攻击的敌将，你必须与其中一名敌将进入白兵，并在本次白兵结束之前，禁用对手所有技能。

const XIAOYONG_HISTORY_EFFECT_ID = 20012
const EFFECT_ID = 20013
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 1

func effect_20013_start():
	var activeCall = true
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.next_flow == "FORCED_CALL":
		activeCall = false
	if activeCall and not assert_action_point(actorId, COST_AP):
		return
	map.cursor.show();
	var dic = ske.get_war_skill_val_dic(XIAOYONG_HISTORY_EFFECT_ID)
	if not dic.has("骁勇-历史坐标"):
		play_dialog(actorId, "当前没有可回置的位置！", 3, 2009)
		return
	var skill_array = Array(dic["骁勇-历史坐标"]).duplicate()
	if skill_array.size() < 3:
		play_dialog(actorId, "当前没有可回置的位置！", 3, 2009)
		return

	#var array = []
	skill_array.invert()
	var pos_array:PoolVector2Array = [];
	for i in skill_array.size():
		if i<2 or i>9:
			continue;
		var pos = Vector2(int(skill_array[i]["x"]),int(skill_array[i]["y"]))
		var wa = DataManager.get_war_actor_by_position(pos)
		if wa != null:
			continue
		pos_array.append(pos)
	if pos_array.empty():
		play_dialog(actorId, "当前没有可回置的位置！", 3, 2009)
		return
	DataManager.set_env("可选目标", pos_array)
	DataManager.set_target_position(pos_array[0])
	map.set_cursor_location(pos_array[0], true)
	map.show_color_block_by_position(pos_array)
	
	SceneManager.show_unconfirm_dialog("请指定骁勇位移地点")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_position(FLOW_BASE + "_2", true, FLOW_BASE + "_6")
	return

func effect_20013_2():
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.next_flow == "FORCED_CALL":
		goto_step("3")
		return
	var current = DataManager.get_target_position()
	map.show_color_block_by_position([current])
	var msg = "消耗{0}点机动力\n可否？".format([COST_AP])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20013_3():
	var position = DataManager.get_target_position()
	var activeCall = true
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.next_flow == "FORCED_CALL":
		activeCall = false
	if activeCall:
		ske.cost_ap(COST_AP, true)
		ske.cost_war_cd(1)
	ske.change_war_actor_position(actorId, position)
	map.show_color_block_by_position([])
	SceneManager.show_confirm_dialog("铁马金戈，挡无可挡！", actorId, 0)
	map.camer_to_actorId(actorId, "draw_actors")
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20013_4():
	var iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	var targets:PoolIntArray = iwa.get_can_attack_actors(actorId, true)[0]
	
	if targets.empty():
		goto_step("6")
		return

	map.cursor.show()
	var current = targets[0]
	var wa = DataManager.get_war_actor(current)
	map.set_cursor_location(wa.position, true)
	DataManager.set_env("武将", current)
	DataManager.set_env("可选目标", targets)
	map.show_can_choose_actors(targets)
	var msg = "必须选择1名目标攻击!"
	SceneManager.show_actor_info(wa.actorId, true, msg)
	map.next_shrink_actors = [current]
	LoadControl.set_view_model(2003)
	return

func on_view_model_2003()->void:
	wait_for_choose_actor(FLOW_BASE + "_5", true, false)
	return

func effect_20013_5():
	var targetId = DataManager.get_env_int("目标")
	ske.set_war_skill_val(1, 1)
	start_battle_and_finish(actorId, targetId)
	return

func on_view_model_2009()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_6")
	return

func effect_20013_6():
	var activeCall = true
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.next_flow == "FORCED_CALL":
		activeCall = false
	map.show_color_block_by_position([])
	map.cursor.hide()
	SkillHelper.remove_all_skill_trigger()
	LoadControl.end_script()
	if activeCall:
		FlowManager.add_flow("player_skill_end_trigger")
	else:
		FlowManager.add_flow("back_to_war_clear")
	return
