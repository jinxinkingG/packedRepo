extends "effect_20000.gd"

#承义诱发技 #胜利触发 #追击
#【承义】大战场，诱发技。你白刃战获胜的场合才能发动。朝任意方向移动一步；若以此法移动后，周围存在相邻的敌将，你必须与之进入白刃战。每回合限1次。


const EFFECT_ID = 20624
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or winner.actorId != actorId:
		# 不是胜利方
		return false

	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if not me.try_move(pos):
			continue
		positions.append(pos)
	return positions.size() > 0

func effect_20624_start() -> void:
	var bf = DataManager.get_current_battle_fight()

	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if not me.try_move(pos):
			continue
		positions.append(pos)
	if positions.empty():
		LoadControl.end_script()
		return
	map.clear_can_choose_actors()
	map.show_color_block_by_position(positions)
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	var msg = "向哪里移动？".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20624_selected() -> void:
	var pos = DataManager.get_target_position()
	if not me.move(pos):
		LoadControl.end_script()
		return

	ske.cost_war_cd(1)

	map.draw_actors()
	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		pos = me.position + dir
		var wa = DataManager.get_war_actor_by_position(pos)
		if me.is_enemy(wa):
			targetIds.append(wa.actorId)
	targetIds = check_combat_targets(targetIds)
	if targetIds.empty():
		LoadControl.end_script()
		return

	wait_choose_actors(targetIds, "选择攻击目标")
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_attack")

func effect_20624_attack() -> void:
	var targetId = DataManager.get_env_int("目标")

	var msg = "青锋不折，天义不堕！\n{0}纳命来！".format([
		DataManager.get_actor_naughty_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 0, 2002)
	map.next_shrink_actors = [me.actorId, targetId]
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")

func effect_20624_fight() -> void:
	map.next_shrink_actors = []
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return
