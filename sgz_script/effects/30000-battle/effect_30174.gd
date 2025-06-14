extends "effect_30000.gd"

#破军锁定技 #禁用技能 #士气
#【破军】小战场，锁定技。若你为战争守方，你进入白刃战时，士气+X。且战斗中，敌方主将技能无效。（X=你的等级）

func on_trigger_30005():
	if ske.get_battle_skill_val_int() <= 0:
		return false
	ske.battle_change_morale(actor.get_level())
	ske.battle_report()

	var msg = "{0}必击而破之！\n（{1}发动【破军】\n（{2}主将技被禁用".format([
		actor.get_short_name(),
		me.get_name(), enemy.get_leader().get_name(),
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false

func on_trigger_30050():
	if me.side() != "防守方":
		# 非守方
		return false
	var enemyLeaderId = enemy.get_main_actor_id()
	for skill in SkillHelper.get_actor_skill_names(enemyLeaderId, 30000):
		ske.ban_battle_skill(enemyLeaderId, skill, 99999)
	# TODO,
	# DataManager.actor_skill_buff 已经移除
	# 未实现，需要重新实现去主将光环技方式
	ske.set_battle_skill_val(1)
	ske.battle_report()
	return false
