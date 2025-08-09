extends "effect_20000.gd"

# 闪避诱发技
#【闪避】大战场，诱发技。你被指定为攻击目标时，若你周围距离1格存在空位，才能发动：闪避至你指定的区域，每回合限1次。

const EFFECT_ID = 20625
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015() -> bool:
	if bf.targetId != actorId:
		return false
	if me.get_controlNo() < 0 and map.get_blockCN_by_position(me.position) in StaticManager.CITY_BLOCKS_CN:
		# AI 城地形不闪
		return false
	var positions = get_valid_positions()
	return positions.size() > 0

func effect_20625_AI_start() -> void:
	var positions = get_valid_positions()
	positions.shuffle()
	DataManager.set_target_position(positions[0])
	goto_step("selected")
	return

func effect_20625_start() -> void:
	var positions = get_valid_positions()
	if positions.size() == 1:
		DataManager.set_target_position(positions[0])
		goto_step("selected")
		return

	var msg = "向何处【闪避】？"
	wait_choose_positions(positions, msg, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected", false)
	return

func effect_20625_selected() -> void:
	var pos = DataManager.get_target_position()
	ske.change_war_actor_position(actorId, pos)
	ske.cost_war_cd(1)
	ske.war_report()
	cancel_attack()
	var msg = "我闪 ……"
	play_dialog(actorId, msg, 1, 2990)
	return

func get_valid_positions() -> Array:
	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if not me.try_move(pos):
			continue
		positions.append(pos)
	return positions
