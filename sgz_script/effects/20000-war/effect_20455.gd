extends "effect_20000.gd"

#私掠主动技
#【私掠】大战场，锁定技。战争开始，你选择1名双方场上除自己之外的任意1名武将获得“私掠”标记。“私掠”武将「白刃战败」或「被用伤兵计损兵」的场合，你可获得其1半机动力。每回合仅触发1次。

const ACTIVE_EFFECT_ID = 20454

func on_trigger_20012()->bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	if targetId < 0:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_soldier_damage_for(targetId) <= 0:
		return false
	var wa = DataManager.get_war_actor(targetId)
	if wa == null or wa.disabled:
		return false
	var ap = int(wa.action_point / 2)
	if ap <= 0:
		return false
	ske.cost_war_cd(1)
	ske.change_actor_ap(targetId, -ap)
	ske.change_actor_ap(actorId, ap)
	ske.war_report()
	var msg = "{0}中计，趁火打劫\n（【{1}】夺取{2} {3}机动力".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
		ske.skill_name, wa.get_name(), ap,
	])
	me.attach_free_dialog(msg, 1)
	return false

func on_trigger_20020()->bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	if targetId < 0:
		return false
	var bf = DataManager.get_current_battle_fight()
	if bf.loserId != targetId:
		return false
	var wa = DataManager.get_war_actor(targetId)
	if wa == null or wa.disabled:
		return false
	var ap = int(wa.action_point / 2)
	if ap <= 0:
		return false
	ske.cost_war_cd(1)
	ske.change_actor_ap(targetId, -ap)
	ske.change_actor_ap(actorId, ap)
	ske.war_report()
	var msg = "{0}兵败，趁火打劫\n（【{1}】夺取{2} {3}机动力".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
		ske.skill_name, wa.get_name(), ap,
	])
	me.attach_free_dialog(msg, 1)
	return false
