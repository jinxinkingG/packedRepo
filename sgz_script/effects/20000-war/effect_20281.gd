extends "effect_20000.gd"

#智援攻击效果
#【智援】大战场，诱发技。与你相邻的你方武将，使用计策或者被用计的场合，你可以消耗3点机动力发动：你代替该武将执行本次计策结算。每个回合限3次。

const EFFECT_ID = 20281
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const LIMIT = 3
const COST_AP = 3

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.actionId != se.fromId:
		# 已有替代执行者
		return false
	if me == null or me.disabled:
		return false
	if actorId == ske.actorId:
		return false
	if me.action_point < COST_AP:
		return false
	var teammate = DataManager.get_war_actor(ske.actorId)
	if teammate == null or teammate.disabled:
		return false
	if Global.get_distance(teammate.position, me.position) != 1:
		return false
	if ske.get_war_limited_times() >= LIMIT:
		return false
	# 可以发动，替代用计
	return true

func effect_20281_start():
	# 替代用计
	ske.cost_war_limited_times(LIMIT)
	ske.cost_ap(COST_AP)
	ske.war_report()
	var se = DataManager.get_current_stratagem_execution()
	se.set_replaced_actioner(actorId, ske.skill_name)
	se.message = se.get_message() + "\n（{0}替代{1}用计".format([
		me.get_name(), ActorHelper.actor(ske.actorId).get_name(),
	])
	# 规避摧克
	if se.name in ["火计", "要击", "乱水"]:
		se.rangeRadius = 0
		# 隐藏范围覆盖, SE-TODO
		# SceneManager.current_scene().war_map.show_color_block_by_position([])
	# 防止回退
	se.goback_disabled = 1
	skill_end_clear()
	return
