extends "effect_20000.gd"

#灵影锁定技
#【灵影】大战场，锁定技。敌方对你发起攻击宣言的场合，若敌将的四面存在其他空位，立刻暗置这些空位，你随机置于其中一个位置上，并令敌将猜测你的位置。若对方猜错，那次攻击宣言取消（机动力照扣），敌将移动至其指定的位置上。

const EFFECT_ID = 20273
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if actorId != bf.get_defender_id():
		# 自身非守方
		return false
	var enemy = bf.get_attacker()
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = enemy.position + dir
		if enemy.can_move_to_position(pos):
			targets.append(pos)
	return targets.size() > 1

func effect_20273_AI_start():
	var bf = DataManager.get_current_battle_fight()
	var enemy = bf.get_attacker()
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = enemy.position + dir
		if enemy.can_move_to_position(pos):
			targets.append(pos)
	map.show_color_block_by_position(targets)
	DataManager.set_env("可选目标", targets)
	targets.shuffle()
	DataManager.set_env("灵影AI位置", DataManager.vector_to_string(targets[0]))
	if enemy.get_controlNo() >= 0:
		targets.shuffle()
		DataManager.set_target_position(targets[0])
		map.set_cursor_location(targets[0], true)
		map.cursor.show()
		var msg = "{0}发动【灵影】\n需谨慎预测其暗置位置".format([
			me.get_name(),
		])
		SceneManager.show_unconfirm_dialog(msg, enemy.actorId)
		LoadControl.set_view_model(3000)
	else:
		goto_step("2")
	return

func on_view_model_3000():
	wait_for_choose_position(FLOW_BASE + "_AI_2", false, "", false)
	return

func effect_20273_AI_2():
	var bf = DataManager.get_current_battle_fight()
	var enemy = bf.get_attacker()
	var selected = DataManager.get_target_position()
	if selected == DataManager.vector_from_string(get_env("灵影AI位置")):
		var msg = "猜中【灵影】位置\n{0}机关算尽，何处遁形？".format([
			me.get_name(),
		])
		play_dialog(enemy.actorId, msg, 1, 3001)
		return
	var msg = "猜错【灵影】位置\n{0}好生狡诈，错失战机！".format([
		me.get_name(),
	])
	bf.skip_execution(actorId, ske.skill_name)
	bf.war_report()
	SkillHelper.remove_all_skill_trigger()
	map.show_color_block_by_position([])
	map.set_cursor_location(selected, true)
	map.cursor.hide()
	enemy.move(selected)
	play_dialog(enemy.actorId, msg, 3, 3002)
	return

func on_view_model_3001():
	wait_for_skill_result_confirmation("")
	return

func on_view_model_3002():
	wait_for_skill_result_confirmation()
	return

func effect_20273_start():
	var bf = DataManager.get_current_battle_fight()
	var enemy = bf.get_attacker()
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = enemy.position + dir
		if enemy.can_move_to_position(pos):
			targets.append(pos)
	map.show_color_block_by_position(targets)
	targets.shuffle()
	DataManager.set_target_position(targets[0])
	map.set_cursor_location(targets[0], true)
	map.cursor.show()
	var msg = "已暗置【灵影】于「{0}」".format([
		StaticManager.NEARBY_DIRECTION_NAMES[targets[0] - enemy.position],
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20273_2():
	var bf = DataManager.get_current_battle_fight()
	var enemy = bf.get_attacker()
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = enemy.position + dir
		if enemy.can_move_to_position(pos):
			targets.append(pos)
	map.show_color_block_by_position([])
	targets.shuffle()
	var enemyChoice = targets[0]
	if enemyChoice == DataManager.get_target_position():
		var msg = "{0}猜中【灵影】位置！".format([
			enemy.get_name(),
		])
		play_dialog(actorId, msg, 3, 2001)
		return
	map.set_cursor_location(enemyChoice, true)
	map.cursor.hide()
	var msg = "{0}小儿押「{1}」\n猜错【灵影】位置，白忙一场".format([
		enemy.get_name(),
		StaticManager.NEARBY_DIRECTION_NAMES[enemyChoice - enemy.position],
	])
	bf.skip_execution(actorId, ske.skill_name)
	bf.war_report()
	SkillHelper.remove_all_skill_trigger()
	enemy.move(enemyChoice)
	play_dialog(me.actorId, msg, 1, 2002)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation("AI_before_ready")
	return
