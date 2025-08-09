extends "effect_20000.gd"

# 夙守锁定技
#【夙守】大战场，主将锁定技。你是战争守方的场合：同一回合中，对方进行过攻击宣言的武将，不能再发动主动技能；对方发动过主动技能的武将，不可再进行攻击宣言。

func on_trigger_20020() -> bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null:
		return false
	var bf = DataManager.get_current_battle_fight()
	if wa.actorId != bf.get_attacker_id():
		return false
	if wa.get_buff_label_turn(["禁用主动技"]) > 0:
		return false
	ske.set_war_buff(wa.actorId, "禁技", 1)
	ske.war_report()

	# 第一次触发时有对话
	var flag = ske.get_war_skill_val_int_array()
	if flag.size() < 2:
		flag = [0, 0]
	if flag[0] <= 0:
		flag[0] = 1
		ske.set_war_skill_val(flag)
		var msg = "{0}无谋，力终有穷！\n（因【{1}】效果\n（{2}本回合禁用主动技".format([
			DataManager.get_actor_naughty_title(wa.actorId, actorId),
			ske.skill_name, wa.get_name(),
		])
		me.attach_free_dialog(msg, 0)
	return false

func on_trigger_20040() -> bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null:
		return false
	if wa.get_buff_label_turn(["禁止攻击"]) > 0:
		return false
	ske.set_war_buff(wa.actorId, "禁兵", 1)
	ske.war_report()

	# 第一次触发时有对话
	var flag = ske.get_war_skill_val_int_array()
	if flag.size() < 2:
		flag = [0, 0]
	if flag[1] <= 0:
		flag[1] = 1
		ske.set_war_skill_val(flag)
		var msg = "{0}弄巧，不敢战尔！\n（因【{1}】效果\n（{2}本回合禁止攻击".format([
			DataManager.get_actor_naughty_title(wa.actorId, actorId),
			ske.skill_name, wa.get_name(),
		])
		me.attach_free_dialog(msg, 0)
	return false
