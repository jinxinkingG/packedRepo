extends "effect_20000.gd"

#转袭诱发技和族锋效果
#【转袭】大战场，诱发技。你的队友白刃战获胜时，才能发动。你可不消耗机动力移动1步；以此法移动至可攻击的敌将周围时，你必须选择其中一名敌将进行白刃战，若如此，该回合不能再次发动此技能。
#【族锋】大战场，锁定技。你发动<转袭>时，可指定一名同姓氏的队友代替你执行其中的移动及后续效果。

const EFFECT_ID = 20486
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20020() -> bool:
	if ske.actorId == actorId:
		# 自己不发动
		return false
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		return false
	if ske.actorId == loser.actorId:
		return false
	return true

func effect_20486_start()->void:
	var candidates = []
	if SkillHelper.actor_has_skills(actorId, ["族锋"]):
		for targetId in get_teammate_targets(me, 999):
			var teammate = DataManager.get_war_actor(targetId)
			if teammate.actor().get_first_name() == actor.get_first_name():
				candidates.append(teammate.actorId)
	if candidates.empty():
		DataManager.set_env("目标", actorId)
		goto_step("fire")
		return
	candidates.insert(0, actorId)
	var msg = "选择同族队友发动【{0}】"
	if not wait_choose_actors(candidates, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_fire", false)
	return

func effect_20486_fire()->void:
	var fromId = DataManager.get_env_int("目标")
	DataManager.set_env("战争.转袭武将", fromId)
	var wa = DataManager.get_war_actor(fromId)

	map.set_cursor_location(wa.position, true)
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if not wa.try_move(pos):
			continue
		targets.append(pos)
	if targets.empty():
		var msg = "没有可移动的位置"
		play_dialog(wa.actorId, msg, 3, 2999)
		return

	map.set_cursor_location(targets[0], true)
	map.show_color_block_by_position(targets)
	SceneManager.show_unconfirm_dialog("请指定位移地点\n「B」键取消")
	DataManager.set_env("可选目标", targets)
	DataManager.set_target_position(targets[0])
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_choose_position(FLOW_BASE + "_move", false, FLOW_BASE + "_end", true)
	return

func effect_20486_move():
	var fromId = DataManager.get_env_int("战争.转袭武将")
	if fromId != actorId and check_combat_targets([fromId]).empty():
		ske.war_report()
		goto_step("end")
		return

	var wa = DataManager.get_war_actor(fromId)
	var targetPosition = DataManager.get_target_position()

	ske.change_war_actor_position(fromId, targetPosition)
	map.show_color_block_by_position([])
	map.draw_actors()

	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = targetPosition + dir
		var target = DataManager.get_war_actor_by_position(pos)
		if wa.is_enemy(target):
			targetIds.append(target.actorId)
	targetIds = check_combat_targets(targetIds)
	if targetIds.empty():
		ske.war_report()
		goto_step("end")
		return

	var msg = "须选择身邻接军发起攻击"
	if not wait_choose_actors(targetIds, msg):
		return
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002()->void:
	wait_for_choose_actor(FLOW_BASE + "_fight", false, false)
	return

func effect_20486_fight()->void:
	var fromId = DataManager.get_env_int("战争.转袭武将")
	var wa = DataManager.get_war_actor(fromId)
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(1)
	ske.war_report()
	start_battle_and_finish(fromId, targetId)
	return
	
func on_view_model_2999()->void:
	goto_step("end")
	return

func effect_20486_end()->void:
	skill_end_clear()
	return
