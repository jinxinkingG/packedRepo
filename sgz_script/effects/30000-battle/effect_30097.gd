extends "effect_30000.gd"

#魏武效果
#【魏武】小战场，主将锁定技。你方武将进入小战场时，对方武将士气-x。x＝(你的等级+武将等级)/2

func on_trigger_30005():
	# 战斗武将
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	enemy = wa.get_battle_enemy_war_actor()
	if enemy == null or enemy.disabled:
		return false

	var battleActor = ActorHelper.actor(ske.actorId)
	var x = int((actor.get_level() + battleActor.get_level()) / 2)
	ske.battle_change_morale(-x, enemy)
	ske.battle_report()
	var msg = "尔等冢中枯骨尔！\n（因{0}【{1}】\n{2}士气下降{3}".format([
		me.get_name(), ske.skill_name, enemy.get_name(), x,
	])
	append_free_dialog(me, msg, 0, wa)
	return false
