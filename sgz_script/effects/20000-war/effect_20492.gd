extends "effect_20000.gd"

#战令主动技
#【战令】大战场，主将主动技。你可以指定一个己方武将，最多令其移动2步，所需机动力由你代为消耗。每个回合限1次。

const EFFECT_ID = 20492
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const STEPS = 2

func effect_20492_start()->void:
	if me.action_point <= 0:
		var msg = "机动力不足\n无法发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	DataManager.set_env("战争.战令步数", STEPS)
	var targets = get_teammate_targets(me)
	var msg = "选择队友发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_go")
	return

func effect_20492_go()->void:
	var steps = DataManager.get_env_int("战争.战令步数")
	if steps <= 0:
		goto_step("end")
		return
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	map.set_cursor_location(wa.position, true)
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if not wa.try_move(pos):
			continue
		targets.append(pos)
	if targets.empty():
		var msg = "没有可移动的位置"
		play_dialog(wa.actorId, msg, 3, 2999)
		return

	map.set_cursor_location(targets[0], true)
	map.show_color_block_by_position(targets)
	SceneManager.show_unconfirm_dialog("请指定位移地点\n「B」键取消")
	DataManager.set_env("可选目标", targets)
	DataManager.set_target_position(targets[0])
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_choose_position(FLOW_BASE + "_move", true, FLOW_BASE + "_end")
	return

func effect_20492_move():
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var targetPosition = DataManager.get_target_position()

	var ap = DataManager.get_move_cost(targetId, targetPosition)["机"]
	if me.action_point < ap:
		var msg = "{0}机动力不足\n无法移动至此处".format([actor.get_name()])
		SceneManager.show_unconfirm_dialog(msg)
		LoadControl.set_view_model(2001)
		return
	ske.change_actor_ap(actorId, -ap)
	ske.change_war_actor_position(targetId, targetPosition)
	map.show_color_block_by_position([])
	map.draw_actors()

	var steps = DataManager.get_env_int("战争.战令步数")
	DataManager.set_env("战争.战令步数", steps - 1)
	goto_step("go")
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_20492_end()->void:
	var steps = DataManager.get_env_int("战争.战令步数")
	if steps < STEPS:
		ske.cost_war_cd(1)
	ske.war_report()
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
