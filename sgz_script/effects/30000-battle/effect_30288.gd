extends "effect_30000.gd"

# 决阵小战场效果
#【决阵】大战场，诱发技。你进行攻击宣言时才能发动。你可消耗任意点数的机动力，令被敌将在那次白刃战中减少同样点数的战术值。

const JUEZHEN_EFFECT_ID = 20594

func on_trigger_30005() -> bool:
	if bf.get_attacker_id() != actorId:
		return false
	var ap = ske.get_war_skill_val_int(JUEZHEN_EFFECT_ID)
	ske.set_war_skill_val(0, 0, JUEZHEN_EFFECT_ID)
	if ap <= 0:
		return false
	var target = bf.get_defender()
	ap = abs(ske.battle_change_tactic_point(-ap, target))
	var msg = "{0}，筹算无用\n真刀真枪，一决胜负吧\n（【{1}】令{2}战术值 -{3}".format([
		DataManager.get_actor_naughty_title(target.actorId, actorId),
		ske.skill_name, target.get_name(), ap,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
