extends "effect_20000.gd"

#炽援诱发技
#【炽援】大战场，诱发技。你非主将且已方主将被敌方使用火属性伤兵计成功的场合，你可消耗5点机动力发动。令敌方选择1名将领，与你进入白刃战。每回合限1次。

const EFFECT_ID = 20718
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const AP_COST = 5

func on_trigger_20012() -> bool:
	# 检查计策执行情况
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	# 检查是否为火属性计策
	if se.get_nature() != "火":
		return false

	# 获取施计者
	var fromId = se.get_action_id(actorId)
	if fromId < 0:
		return false

	# 检查机动力是否足够
	if me.action_point < AP_COST:
		return false

	# 检查目标是否为己方主将
	var leader = me.get_leader()
	if leader == null or leader.actorId != ske.actorId:
		return false

	return true

func effect_20718_AI_start() -> void:
	goto_step("start")
	return

func effect_20718_start() -> void:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	var enemy = DataManager.get_war_actor(fromId)

	var msg = "主公有难！\n{0}休得猖狂！\n（消耗{1}机动力发动【{2}】".format([
		DataManager.get_actor_naughty_title(fromId, actorId),
		AP_COST,
		ske.skill_name
	])
	play_dialog(actorId, msg, 0, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_choose_target")
	return

func effect_20718_choose_target() -> void:
	# 扣除机动力和设置CD
	ske.cost_ap(AP_COST)
	ske.cost_war_cd(1)

	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	var enemy = DataManager.get_war_actor(fromId)

	# 获取敌方所有可选目标
	var candidates = enemy.get_teammates(false, true)
	candidates.append(enemy)  # 施计者本身

	# 判断敌方是否为AI
	if enemy.get_controlNo() < 0:
		# AI选择最强的
		var selected = _ai_select_strongest(candidates)
		ske.set_war_skill_val(selected.actorId, 1)
		goto_step("battle_start")
		return

	# 玩家选择
	var msg = "选择应战【{0}】的武将".format([ske.skill_name])
	var targetIds = []
	for wa in candidates:
		targetIds.append(wa.actorId)
	wait_choose_actors(targetIds, msg)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_enemy_selected")
	return

func effect_20718_enemy_selected() -> void:
	var selected = DataManager.get_env_int("目标")
	ske.set_war_skill_val(selected, 1)
	goto_step("battle_start")
	return

func _ai_select_strongest(candidates: Array) -> int:
	var best = null
	var bestScore = 0

	for wa in candidates:
		# 计算得分：兵力 + power_score
		var soldiers = int(wa.get_soldiers() / 5)
		var power = wa.get_power_score()
		var score = soldiers + power

		if score > bestScore:
			bestScore = score
			best = wa

	return best

func effect_20718_battle_start() -> void:
	var targetId = ske.get_war_skill_val_int()
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)


	var msg = "{0}忠勇可嘉\n然败势已成\n{1}送尔一程！".format([
		DataManager.get_actor_honored_title(actorId, fromId),
		DataManager.get_actor_honored_title(targetId, fromId),
	])
	play_dialog(fromId, msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_battle_confirm")
	return

func effect_20718_battle_confirm() -> void:
	var targetId = ske.get_war_skill_val_int()
	var se = DataManager.get_current_stratagem_execution()

	# 如果原计策会自动结束回合，标记
	if se.will_auto_finish_turn():
		ske.mark_auto_finish_turn()

	# 发起白刃战
	start_battle_and_finish(targetId, actorId, ske.skill_name, actorId)
	return
