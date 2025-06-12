extends "effect_20000.gd"

#勇进锁定技 #胜利触发 #免费移动
#【勇进】大战场,锁定技。你方回合，你白兵胜利后，你可以不消耗机动移动两步

const EFFECT_ID = 20115

func check_trigger_correct()->bool:
	match self.triggerId:
		20020:
			_after_battle()
		20003:
			_after_move()
		20007:
			_get_move_cost()
	return false

func _get_move_cost()->bool:
	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
	if skv["turn"] <= 0 or skv["value"] == null:
		return false

	if int(skv["value"]) > 0:
		set_env(KEY_MOVE_AP_COST, 0)

	return false

func _after_move()->bool:
	if not DataManager.common_variable.has("移动"):
		return false

	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
	if skv["turn"] <= 0 or skv["value"] == null:
		return false

	var freeSteps = int(skv["value"])
	match int(DataManager.common_variable["移动"]):
		1: # 尝试移动
			freeSteps -= 1
		-1: # 撤回移动
			freeSteps += 1
	freeSteps = min(2, freeSteps)
	SkillHelper.set_skill_variable(20000, EFFECT_ID, self.actorId, freeSteps, 1)

	return false

func _after_battle()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or winner.actorId != me.actorId:
		# 不是胜利方
		return false

	if me.get_controlNo() != DataManager.war_control_sort[DataManager.war_control_sort_no]:
		# 非我方回合
		return false
	# 白兵胜利，设置两步移动无消耗
	ske.set_war_skill_val(2, 1)
	return false

