extends "effect_30000.gd"

# 知机小战场效果部分
#【知机】大战场，限定技。找出战场破局点，制定针对性的策略。你指定一个“知不高于你的敌方武将”发动，本场战争中对此目标武将：我方发动计策的成功率 +10%，主动攻击时白兵战士气 +8。被你指定的武将死亡或者脱离战场，重置本技能冷却。

const ACTIVE_EFFECT_ID = 20614
const MORALE_UP = 8

func on_trigger_30005() -> bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if targetId != bf.get_defender_id():
		return false
	if ske.actorId != bf.get_attacker_id():
		return false

	ske.battle_change_morale(MORALE_UP, bf.get_attacker())
	ske.battle_report()

	var msg = "{0}，军师面命\n先拿尔祭旗！\n（因{1}【{2}】士气 +{3}"
	if ske.actorId == actorId:
		msg = "{0}，先拿尔祭旗！\n（因【{2}】士气 +{3}"
	msg = msg.format([
		DataManager.get_actor_naughty_title(targetId, ske.actorId),
		actor.get_name(), ske.skill_name, MORALE_UP,
	])
	bf.get_attacker().attach_free_dialog(msg, 0, 30000)

	return false
