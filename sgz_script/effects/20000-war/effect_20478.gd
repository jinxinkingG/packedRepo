extends "effect_20000.gd"

#跃马锁定效果部分
#【跃马】大战场，主动技。消耗5点机动力，选择一个非城地形的马走日目标位置跳进。目标位置如果有敌军，对其发起战斗；目标位置如果是空地，或战斗结束后成为空地，则移动到目标位置。每回合限1次。

const ACTIVE_EFFECT_ID = 20477

func on_trigger_20020()->bool:
	var vals = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID)
	if vals.size() != 3 or vals[0] < 0:
		return false
	var pos = Vector2(vals[1], vals[2])
	if not map.is_valid_position(pos):
		return false
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		return false
	if loser.actorId == actorId:
		return false
	# 胜利者是我
	if not me.can_move_to_position(pos):
		return false
	ske.change_war_actor_position(actorId, pos)
	ske.war_report()
	return false
