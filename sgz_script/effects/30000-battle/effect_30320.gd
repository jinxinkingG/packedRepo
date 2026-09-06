extends "effect_30000.gd"

#急退效果
#【急退】小战场，锁定技。你小战场撤退时，若无阻挡，可以退2格。

func on_trigger_30003() -> bool:
	ske.battle_set_skill_val([me.position.x, me.position.y])
	return false

func on_trigger_30004() -> bool:
	var posInfo = ske.get_battle_skill_val_int_array()
	if posInfo.size() != 2:
		return false
	var pos = Vector2(int(posInfo[0]), int(posInfo[1]))
	if Global.get_distance(pos, me.position) != 1:
		return false
	var targetPos = me.position * 2 - pos
	if not me.can_move_to_position(targetPos):
		return false
	me.move(targetPos)
	return false
