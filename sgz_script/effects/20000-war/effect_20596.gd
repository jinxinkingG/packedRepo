extends "effect_20000.gd"

# 断归限定技
#【断归】大战场，限定技。你非主将，可选择一名身侧敌方武将，隐藏埋伏下来。下个回合，如果该武将移动，立刻占据该武将移动前的位置。若未触发，你在其回合结束时显形。

const ACTIVE_EFFECT_ID = 20595

func on_trigger_20003() -> bool:
	var pos = me.get_ambush_position()
	if pos.x < 0 or pos.y < 0:
		return false
	var flags = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID)
	if flags.size() != 3:
		return false
	var targetId = flags[0]
	var targetPos = Vector2(flags[1], flags[2])
	var target = DataManager.get_war_actor(ske.actorId)
	if target == null or target.disabled:
		return false
	if target.position == targetPos:
		return false
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	me.ambush_out(targetPos)
	map.draw_actors()
	var msg = "{0}轻动，断其归路！".format([
		target.get_name(),
	])
	me.attach_free_dialog(msg, 0)
	return false

func on_trigger_20016() -> bool:
	var pos = me.get_ambush_position()
	if pos.x < 0 or pos.y < 0:
		return false
	var flags = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID)
	if flags.size() != 3:
		return false
	var targetId = flags[0]
	var targetPositions = [pos]
	for x in 4:
		for y in 4:
			targetPositions.append(pos + Vector2(x, y))

	for targetPos in targetPositions:
		var existed = DataManager.get_war_actor_by_position(targetPos)
		if existed == null:
			me.ambush_out(targetPos)
			break
	pos = me.get_ambush_position()
	if map.is_valid_position(pos):
		# 仍在埋伏中，说明位置都被占据了，直接放到屏幕外待布阵
		me.ambush_out(Vector2(-1, -1))
	map.draw_actors()
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	var msg = "惜哉，{0}并未妄动".format([
		ActorHelper.actor(targetId).get_name(),
	])
	me.attach_free_dialog(msg, 2)
	return false
