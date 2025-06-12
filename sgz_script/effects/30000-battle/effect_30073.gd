extends "effect_30000.gd"

#昭烈效果
#【昭烈】大战场，主将锁定技。你方武将进入白兵时，初始战术值+X（X=你的等级）。

func on_trigger_30005()->bool:
	# 战斗武将
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false

	var x = actor.get_level()
	ske.battle_change_tactic_point(x, wa)
	ske.battle_report()
	var source = me.get_name()
	var target = wa.get_name()
	if actorId == wa.actorId:
		source = ""
		target = ""
	var msg = "讨贼兴汉，诸公奋发！"
	if actorId == ske.actorId:
		msg = "讨贼兴汉，吾当奋发！"
	msg += "\n（因{0}【{1}】\n（{2}战术增加{3}".format([
		source, ske.skill_name, target, x,
	])
	wa.attach_free_dialog(msg, 0, 30000, actorId)
	return false
