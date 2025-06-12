extends "effect_30000.gd"

#暴威效果
#【暴威】大战场,主将锁定技。你方武将主动进入小战场时，该武将的士气+（51-你的德）/5。

func on_trigger_30005():
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_attacker_id():
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa.get_main_actor_id() != me.actorId:
		return false
	var x = int((51 - actor.get_moral()) / 5)
	if x <= 0:
		return false
	x = ske.battle_change_morale(x, wa)
	ske.battle_report()
	var msg = "怀德不若畏威！\n（因{0}【{1}】\n（{2}士气上升{3}".format([
		me.get_name(), ske.skill_name, wa.get_name(), x,
	])
	append_free_dialog(me, msg, 0, wa)
	return false
