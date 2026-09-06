extends "effect_20000.gd"

#龙骧锁定效果部分
#【龙骧】大战场&小战场，主动技。①你方存在<虎翼>队友时，你的机动力上限+10。②白刃战中，若你有士兵单位，你可以消耗50金发动：你的战术值+3，兵力恢复200，该增援兵力均摊到你方存活的士兵单位中，每个大战场回合限1次。

func on_trigger_20013() -> bool:
	var extra = 0
	if SkillRangeBuff.max_val_for_war_vstate("虎翼", me.wvId) > 0:
		extra = 10
	ske.set_actor_extra_ap_limit(actorId, extra)
	ske.war_report()
	return false
