extends "effect_30000.gd"

#德服效果
#【德服】大战场,主将锁定技。你方武将进入小战场时，该武将的士气+（你的德-50）/6。

func on_trigger_30005():
	var wa = DataManager.get_war_actor(ske.actorId)
	var x = int((actor.get_moral() - 50) / 6)
	if x <= 0:
		return false
	x = ske.battle_change_morale(x, wa)
	ske.battle_report()
	var msg = "畏威何如怀德？\n（因{0}【{1}】\n（{2}士气上升{3}".format([
		me.get_name(), ske.skill_name, wa.get_name(), x,
	])
	append_free_dialog(me, msg, 2, wa)
	return false
