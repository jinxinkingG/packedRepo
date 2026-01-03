extends "effect_20000.gd"

# 遥援战后效果
#【遥援】大战场，诱发技。你方6格以外的武将被攻击的场合：你替代之进入白刃战。若本次白刃战你战败，你位移到该队友身边；若你获胜且你<烈袭>处于冷却状态时，你的<烈袭>冷却回合数-1。每回合限2次。

const INDUCE_EFFECT_ID = 20655
const LIEXI_EFFECT_ID = 20654

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	var key = "{0}.{1}".format([ske.skill_name, actorId])
	var skillInfo = bf.get_env_int_array(key)
	if skillInfo.size() != 3 or skillInfo[0] < 0:
		return false
	# 标记已触发过
	var teammateId = skillInfo[0]
	var winner = bf.get_winner()
	if winner != null and winner.actorId == actorId:
		# 取胜
		var attacker = bf.get_attacker()
		var msg = "{0}兵锋已挫！"
		if attacker.disabled:
			msg = "{0}自取死尔！"
		msg = msg.format([DataManager.get_actor_naughty_title(attacker.actorId, actorId)])
		var reduced = ske.reduce_actor_skill_cd(actorId, 1, [], [LIEXI_EFFECT_ID])
		if not reduced.empty():
			var skillName = reduced.keys()[0]
			var cd = int(reduced[skillName])
			msg += "\n（【{0}】冷却减为 {1}".format([skillName, cd])
		me.attach_free_dialog(msg, 0)
		ske.war_report()
		return false
	var pos = Vector2(skillInfo[1], skillInfo[2])
	if not map.is_valid_position(pos):
		return false
	if DataManager.get_war_actor_by_position(pos) != null:
		return false
	var teammate = DataManager.get_war_actor(teammateId)
	if teammate == null or teammate.disabled:
		ske.change_war_actor_position(actorId, pos)
	else:
		ske.change_war_actor_position(actorId, teammate.position)
		ske.change_war_actor_position(teammate.actorId, pos)
	var msg = "既不能胜 ……\n仍当为{0}屏障！".format([
		DataManager.get_actor_honored_title(teammateId, actorId)
	])
	me.attach_free_dialog(msg, 0)
	return false
