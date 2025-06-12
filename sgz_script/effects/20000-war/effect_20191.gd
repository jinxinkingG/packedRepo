extends "effect_20000.gd"

#智救主动技
#【智救】大战场,主动技。先选择一个机动力＜4的己方武将，再选择一个距离你1以内非城地形的空格，你消耗5点机动力，该武将移动到该空格。每回合限一次。

const EFFECT_ID = 20191
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const TARGET_MAX_AP = 3
const COST_AP = 5

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_choose_position(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

# 发动主动技
func effect_20191_start():
	if not assert_action_point(me.actorId, COST_AP):
		return

	var targets = []
	map.show_color_block_by_position([])
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if not map.is_valid_position(pos):
			continue
		var blockCN = map.get_blockCN_by_position(pos)
		if blockCN in StaticManager.CITY_BLOCKS_CN:
			# 不能选城地形
			continue
		var existed = DataManager.get_war_actor_by_position(pos)
		if existed != null:
			# 不能有别人
			continue
		targets.append(pos)
	if targets.empty():
		var msg = "无可用位置\n不能发动【{0}】".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2009)
		return

	set_env("战争.技能.智救位置", targets)

	var teammates = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.action_point > TARGET_MAX_AP:
			continue
		teammates.append(targetId)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(teammates, msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20191_2():
	var targetId = get_env_int("目标")
	var positions = get_env_array("战争.技能.智救位置")
	set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])

	map.set_cursor_location(positions[0], true)
	map.show_color_block_by_position(positions)
	var msg = "请指定【{0}】位移地点".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg)
	LoadControl.set_view_model(2001)
	return

func effect_20191_3():
	var targetId = get_env_int("目标")
	var msg = "消耗{0}机动力\n对{1}发动【智救】\n可否".format([
		COST_AP, ActorHelper.actor(targetId).get_name()
	])
	play_dialog(me.actorId, msg, 2, 2002, true)
	return

func effect_20191_4():
	var targetId = get_env_int("目标")
	var targetPos = DataManager.get_target_position()
	
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.change_war_actor_position(targetId, targetPos)
	ske.war_report()
	
	var msg = "强弩之末，势不能穿鲁缟\n{0}不可用强".format([
		DataManager.get_actor_honored_title(targetId, me.actorId)
	])
	play_dialog(me.actorId, msg, 2, 2009)
	return
