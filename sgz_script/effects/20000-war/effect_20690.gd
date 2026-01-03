extends "effect_20000.gd"

# 伐功效果
#【伐功】大战场，锁定技。你每发起过1次攻击宣言，你自身的组队经验倍率+1%，至多额外+30%，持续至战争结束。\n当前倍率：+<var:0:0>%

const LIMIT = 30

func on_trigger_20015() -> bool:
	if bf.get_attacker_id() != actorId:
		return false
	var rate = ske.get_war_skill_val_int()
	if rate < 0:
		rate = 0
	rate = min(LIMIT, rate + 1)
	ske.set_war_skill_val(rate)
	return false
