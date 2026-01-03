extends "effect_20000.gd"

#离魂被动触发判断
#【离魂】大战场,限定技。指定1名男性武将为目标，消耗你10点机动力发动。你与目标同时定止8~10回合。若你或目标其中一个离开战场，留下的另一人解除定止状态。

const ACTIVE_EFFECT_ID = 20177

func on_trigger_20027() -> bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	match ske.actorId:
		actorId:
			# 自身离开战场
			pass
		targetId:
			# 离魂目标离开战场
			pass
		_:
			return false
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA != null and targetWA.get_buff("定止")["回合数"] > 0:
		ske.remove_war_buff(targetId, "定止")
		var msg = "{0} ……".format([
			DataManager.get_actor_honored_title(actorId, targetId)
		])
		targetWA.attach_free_dialog(msg, 3)
	if me.get_buff("定止")["回合数"] > 0:
		ske.remove_war_buff(actorId, "定止")
	map.draw_actors()
	ske.set_war_skill_val(-1, 0)
	ske.war_report()
	return false
