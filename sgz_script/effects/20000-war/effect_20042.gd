extends "effect_20000.gd"

#急袭被动部分 #额外回合
#【急袭】大战场，主将限定技。你可以指定最多3个队友发动。回合结束阶段，你与被指定己方武将体力下降20%、附加获得<急功>、<胜志>，并一起进入额外回合。

const ACTIVE_EFFECT_ID = 20041

func on_trigger_20016()->bool:
	var selected = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID)
	if selected.empty():
		return false
	selected.erase(actorId)
	selected.append(actorId)
	for targetId in selected:
		var wa = DataManager.get_war_actor(targetId)
		if wa == null or wa.disabled:
			continue
		ske.change_actor_hp(wa.actorId, -int(wa.actor().get_max_hp() / 5), 1)
		ske.add_war_skill(wa.actorId, "急功", 99999)
		ske.add_war_skill(wa.actorId, "胜志", 99999)
	ske.war_report()
	return false
