extends "effect_20000.gd"

#连袭被动效果
#【连袭】大战场，主动技。你可以指定一个对方武将，本回合结束前，你对其发起攻击宣言无需耗费机动力。每3个回合限一次。

const EFFECT_ID = 20292

func on_trigger_20014() -> bool:
	if me == null or me.disabled:
		return false
	var dic = get_env_dict("战争.攻击消耗")
	if dic.empty() or not "攻击目标" in dic:
		return false
	var markedId = ske.get_war_skill_val_int()
	if markedId != int(dic["攻击目标"]):
		return false
	dic["固定"] = 0
	set_env("战争.攻击消耗", dic)
	return false
