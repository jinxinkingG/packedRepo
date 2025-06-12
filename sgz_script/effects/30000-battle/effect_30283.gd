extends "effect_30000.gd"

# 复难小战场效果
#【复难】大战场，锁定技。非城地形，你被攻击时，自动消耗5点机动力，抵消那次攻击。若机动力不足，则无法抵消，并使白刃战中的对方士气+X。(X=本回合你以此法抵消攻击的次数*5)

const FUNAN_EFFECT_ID = 20579

func on_trigger_30005() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if actorId != bf.targetId:
		return false
	var morale = 5 * ske.get_war_skill_val_int(FUNAN_EFFECT_ID)
	if morale <= 0:
		return false
	morale = ske.battle_change_morale(morale, enemy)
	ske.battle_report()

	var msg = "{0}，逃得一世么！\n（【{1}】令{2}士气 +{3}".format([
		DataManager.get_actor_naughty_title(actorId, enemy.actorId),
		ske.skill_name, enemy.get_name(), morale,
	])
	enemy.attach_free_dialog(msg, 0, 30000)
	return false
