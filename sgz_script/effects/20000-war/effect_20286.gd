extends "effect_20000.gd"

#儒帅被动效果部分
#【儒帅】大战场，主将主动技。你可以消耗8点机动力，指定一个己方武将，并记录该武将所在格。本回合结束后，记录格为空，则该武将回到记录格，每个回合限1次。

const EFFECT_ID = 20286

func check_trigger_correct()->bool:
	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
	if skv["turn"] < 0 or typeof(skv["value"]) != TYPE_STRING:
		return false
	var flags = str(skv["value"]).split("|")
	if flags.size() != 3:
		return false
	var targetId = int(flags[0])
	var pos = Vector2(int(flags[1]), int(flags[2]))
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null or targetWA.disabled or not targetWA.has_position():
		return false
	var cur = DataManager.get_war_actor_by_position(pos)
	if cur != null:
		return false
	targetWA.move(pos, true, true)

	var d = War_Character.DialogInfo.new()
	d.text = "{0}妙算无双\n{1}后顾无忧矣".format([
		DataManager.get_actor_honored_title(self.actorId, targetId),
		DataManager.get_actor_self_title(targetId),
	])
	d.actorId = targetId
	d.mood = 1
	targetWA.add_dialog_info(d)
	FlowManager.add_flow("draw_actors")
	return false
