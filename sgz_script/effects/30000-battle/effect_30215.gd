extends "effect_30000.gd"

#义徒锁定技
#【义徒】小战场，锁定技。你死亡/被俘虏时，当次白刃战不结束，剩余士兵继续战斗，直至所有士兵消灭，若你方获胜，你可免疫那次死亡/俘虏。战争中限一次。

func on_trigger_30013() -> bool:
	var bu = me.battle_actor_unit()
	if bu == null or not bu.disabled:
		# 未找到，或未被砍死，忽略
		return false
	var hurtId = get_env_int("白兵.受伤单位")
	if hurtId != bu.unitId:
		return false
	if ske.get_war_skill_val_int() > 0:
		# 第二次被打死了，认了吧
		ske.set_war_skill_val(0, 0)
		ske.cost_war_cd(99999)
		return false
	# 武将被打死了，开始表演
	ske.set_war_skill_val(1, 99999)
	bu.init_combat_info("骑(化身)")
	bu.set_hp(0, true)
	bu.disabled = true
	var msg = "将军急难！我等当拼一死！\n（{0}暂时获救\n（士兵继续战斗".format([
		me.get_name()
	])
	append_free_dialog(null, msg, 0, me)
	return false

func on_trigger_30098() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		return false
	if enemy == null or enemy.disabled:
		return false
	if bf.loserId == actorId:
		# 义徒战败
		actor.set_hp(-1)
		var wv = me.war_vstate()
		me.actor_capture_to(enemy.wvId, "白兵", enemy.actorId)
		bf.lostType = BattleFight.ResultEnum.ActorDead
		return false
	me.disabled = false
	actor.set_hp(1)
	return false
