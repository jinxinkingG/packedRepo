extends "effect_20000.gd"

#虎翼锁定效果部分
#【虎翼】大战场&小战场，主动技。①你方存在<龙骧>队友时，你的体力上限+10。②白刃战中，你可以消耗5点机动力发动：你的体力恢复30点，每个大战场回合限1次。

func on_trigger_20013() -> bool:
	var extra = 0
	if SkillRangeBuff.max_val_for_war_vstate("龙骧", me.wvId) > 0:
		extra = 10
	ske.set_actor_extra_max_hp(actorId, extra)
	ske.war_report()
	return false
