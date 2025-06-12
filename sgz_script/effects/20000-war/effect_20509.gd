extends "effect_20000.gd"

#筹谋锁定技
#【筹谋】大战场，锁定技。己方武将每次用计，为你添加1个[筹]标记。[筹]标记达到3个时（[筹]标记，最多为3个），下次己方人员用计，将消耗你所有的[筹]标记，使那次计策对士兵造成伤害增加50%。

const FLAG_NAME = "筹"
const TRIGGER_TIMES = 3
const DAMAGE_RAISE = 50

func on_trigger_20009() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	# 队友用计
	ske.add_skill_flags(10000, ske.effect_Id, FLAG_NAME, 1)
	var flags = ske.get_skill_flags(10000, ske.effect_Id, FLAG_NAME)
	if flags >= TRIGGER_TIMES:
		ske.set_war_skill_val(1)
	var msg = "{0}获得一个「{1}」".format([
		actor.get_name(), FLAG_NAME,
	])
	se.append_result(ske.skill_name, msg, 1, actorId, true)
	return false

func on_trigger_20011() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		return false
	change_scheme_damage_rate(DAMAGE_RAISE)
	ske.set_war_skill_val(0)
	ske.clear_skill_flags(10000, ske.effect_Id, FLAG_NAME)
	return false
