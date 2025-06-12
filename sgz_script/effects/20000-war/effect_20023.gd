extends "effect_20000.gd"

#酒计锁定部分
#【酒计】大战场，诱发技。你被使用伤兵计的场合，若施计者不在太守府，你可以发动：本次计策必中，施计者与你进入白刃战，若本次白刃战你取得胜利，你恢复本回合被计策伤害的全部兵力，回合外限1次。

func on_trigger_20037()->bool:
	var targetId = DataManager.get_env_int("计策.ONCE.伤害武将")
	if targetId != actorId:
		return false
	var damage = DataManager.get_env_int("计策.ONCE.伤害")
	if damage <= 0:
		return false
	var total = ske.get_war_skill_val_int()
	ske.set_war_skill_val(total + damage, 1)
	return false

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.source != ske.skill_name:
		return false
	var loser = bf.get_loser()
	if loser == null or loser.actorId == actorId:
		return false
	var total = ske.get_war_skill_val_int()
	if total <= 0:
		return false
	var recovered = ske.change_actor_soldiers(actorId, total)
	ske.set_war_skill_val(0, 1)
	if recovered <= 0:
		return false
	ske.war_report()
	var msg = "{0}以为得计\n皆愚之也！疑兵归队\n（【{1}】恢复计策伤兵{2}".format([
		DataManager.get_actor_naughty_title(loser.actorId, actorId),
		ske.skill_name, recovered,
	])
	me.attach_free_dialog(msg, 1)
	return false
