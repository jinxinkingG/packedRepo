extends "effect_20000.gd"

#增援主动技 #后备兵 #补充士兵
#【增援】大战场,主动技。指定两个己方武将，将城中的后备兵抽调给他们，使每个武将兵力至多+500。每4回合限1次
#（防守时，从防守城池调取后备兵。进攻时，从出征城调取后备兵。后备兵不够1000时，平分完。后备兵为0时，提示没有后备兵，无法发动。）

const EFFECT_ID = 20410
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_TROOPS = 1000
const EFFECT_CHOOSE_NAME = "战争."+str(EFFECT_ID)+".目标"
const EFFECT_CHOOSE_ACTOR = "战争."+str(EFFECT_ID)+".武将"

func effect_20410_start():
	DataManager.unset_env(EFFECT_CHOOSE_NAME)
	DataManager.unset_env(EFFECT_CHOOSE_ACTOR)
	goto_step("go")
	return

func effect_20410_go():
	var city = me.war_vstate().from_city()
	var troops = city.get_backup_soldiers()
	var cost = min(troops, COST_TROOPS)
	if troops <= 0:
		var msg = "{0}已无后备兵可用".format([city.get_full_name()])
		play_dialog(me.actorId, msg, 3, 2999)
		return
	var candidates = get_teammate_targets(me)
	candidates.append(me.actorId)
	var targets = []
	for targetId in candidates:
		var wa = DataManager.get_war_actor(targetId)
		if wa.actor().get_soldiers() >= 2500:
			continue
		targets.append(targetId)
	var selected = DataManager.get_env_int_array(EFFECT_CHOOSE_NAME)
	var msg = "选择至多两名武将，补充兵力（{0}/2）".format([selected.size()])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true, true, FLOW_BASE + "_3")
	return

func effect_20410_2():
	var targetId = DataManager.get_env_int("目标")
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	if targetId in selected:
		selected.erase(targetId)
	elif selected.size() < 2:
		selected.append(targetId)
	DataManager.set_env(EFFECT_CHOOSE_ACTOR, targetId)
	DataManager.set_env(EFFECT_CHOOSE_NAME, selected)
	_update_select_color()
	FlowManager.add_flow("draw_actors")
	goto_step("go")
	return

func effect_20410_3():
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	if selected.empty():
		back_to_skill_menu()
		return
	var city = me.war_vstate().from_city()
	var troops = city.get_backup_soldiers()
	var cost = min(troops, COST_TROOPS)
	var msg = "{0}现有后备兵{1}\n调度至多{2}人增援\n可否？".format([
		city.get_full_name(), troops, cost,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func effect_20410_4():
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	if selected.empty():
		back_to_skill_menu()
		return
	var city = me.war_vstate().from_city()
	var troops = city.get_backup_soldiers()
	var cost = min(troops, COST_TROOPS)
	var remaining = cost
	var costed = 0
	ske.cost_war_cd(4)
	while not selected.empty() and remaining > 0:
		var recover = int(ceil(remaining * 1.0 / selected.size()))
		recover = min(500, recover)
		var targetId = selected.pop_front()
		recover = ske.add_actor_soldiers(targetId, recover, 2500)
		remaining -= recover
		costed += recover
	ske.change_city_property(city.ID, "后备兵", -costed)
	ske.war_report()
	var msg = "{0}尚有余力，必挫{1}！".format([
		city.get_full_name(), me.get_war_enemy_leader().get_name(),
	])
	report_skill_result_message(ske, 2002, msg, 1)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_5")
	return

func effect_20410_5():
	report_skill_result_message(ske, 2002)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func _update_select_color():
	var positions = []
	for targetId in get_env_int_array(EFFECT_CHOOSE_NAME):
		var wa = DataManager.get_war_actor(targetId)
		positions.append(wa.position)
	map.show_color_block_by_position(positions)
	return
