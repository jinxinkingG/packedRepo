extends "effect_20000.gd"

# 秘筹锁定技
#【秘筹】大战场，锁定技。对方每回合至多发动X次主动技(X=你方场上的武将总数-1)。

func on_trigger_20040() -> bool:
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	if prevSke.effect_type != "主动":
		return false

	var x = ske.get_war_skill_val_int()
	if x < 0:
		# 已经禁用过了
		return false

	x += 1
	ske.set_war_skill_val(x, 1)
	if x < me.get_teammates(false, true).size():
		return false

	# 设为负值标记已禁用
	ske.set_war_skill_val(-1, 1)
	for wa in me.get_enemy_war_actors(true):
		ske.set_war_buff(wa.actorId, "禁技", 1)
	ske.war_report()
	
	var msg = "筹谋亦以正合\n（因{0}【{1}】\n（本回合{2}军禁用主动技".format([
		actor.get_name(), ske.skill_name,
		me.get_enemy_leader().get_name(),
	])
	me.attach_free_dialog(msg, 0)
	return false
