extends "effect_20000.gd"

#儒帅被动效果部分
#【儒帅】大战场，主将主动技。你可以消耗8点机动力，指定一个己方武将，并记录该武将所在格。本回合结束后，记录格为空，则该武将回到记录格，每个回合限1次。

func on_trigger_20016() -> bool:
	var flags = ske.get_war_skill_val_str().split("|")
	if flags.size() != 3:
		return false
	var targetId = int(flags[0])
	var pos = Vector2(int(flags[1]), int(flags[2]))
	var targetWA = DataManager.get_war_actor(targetId)
	if not me.is_teammate(targetWA) or not targetWA.has_position():
		return false
	var cur = DataManager.get_war_actor_by_position(pos)
	if cur != null:
		return false
	targetWA.move(pos, true, true)
	map.draw_actors()

	var msg = "{0}妙算无双\n{1}后顾无忧矣".format([
		DataManager.get_actor_honored_title(actorId, targetId),
		DataManager.get_actor_self_title(targetId),
	])
	targetWA.attach_free_dialog(msg, 1)
	return false
