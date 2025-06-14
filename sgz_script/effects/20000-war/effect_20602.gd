extends "effect_20000.gd"

# 潜行主动技
#【潜行】大战场，主动技。若你已处于｛潜行｝状态，可消耗2点机动力提前解除；否则，可消耗6点机动力，进入3回合｛潜行｝状态。解除 {潜行} 状态时，此技能 CD 2回合。

const EFFECT_ID = 20602
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 6
const BUFF = "潜行"
const TURNS = 3

func on_trigger_20003() -> bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	var isPlayer = wa.get_controlNo() >= 0
	if isPlayer:
		if moveType != 1:
			return false
	else:
		if moveType != 0 or moveStopped != 1:
			return false
	if actorId != ske.actorId:
		# 敌军移动发现我的情况
		if me.get_buff(BUFF)["回合数"] > 0 \
			and Global.get_range_distance(me.position, wa.position) <= 2:
			# 我潜行被发现
			ske.remove_war_buff(actorId, BUFF)
			ske.cost_war_cd(2)
			map.draw_actors()
			var msg = "{0}竟潜伏于此！".format([
				DataManager.get_actor_naughty_title(actorId, wa.actorId)
			])
			wa.attach_free_dialog(msg, 0)
	# 无论谁移动，移动者被发现的情况
	if wa.get_buff(BUFF)["回合数"] > 0:
		var positions = []
		var radius = 2
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				positions.append(wa.position + Vector2(x, y))
		var sorter = Global.VectorSorter.new()
		sorter.center = wa.position
		positions.sort_custom(sorter, "by_distance")

		var ignoreCity = false
		var noticedBy = null
		if wa.side() == "防守方":
			ignoreCity = true
		for pos in positions:
			if not ignoreCity:
				var terrian = map.get_blockCN_by_position(pos)
				if terrian in StaticManager.CITY_BLOCKS_CN:
					noticedBy = wa.get_enemy_leader()
					break
			var target = DataManager.get_war_actor_by_position(pos)
			if wa.is_enemy(target):
				noticedBy = target
				break
		if noticedBy == null:
			return false
		ske.remove_war_buff(wa.actorId, BUFF)
		# 这不一定是我自己 CD
		SkillHelper.set_skill_cd(20000, ske.effect_Id, wa.actorId, 2, ske.skill_name)
		DataManager.set_env("移动中止", 1)
		map.draw_actors()
		var msg = "{0}！\n竟能潜入此地！".format([
			DataManager.get_actor_naughty_title(wa.actorId, noticedBy.actorId)
		])
		noticedBy.attach_free_dialog(msg, 0)
	return false

func on_trigger_20009() -> bool:
	ske.remove_war_buff(actorId, BUFF)
	ske.cost_war_cd(2)
	map.draw_actors()
	ske.war_report()
	return false

func on_trigger_20015() -> bool:
	ske.remove_war_buff(actorId, BUFF)
	ske.cost_war_cd(2)
	ske.war_report()
	map.draw_actors()
	ske.war_report()
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() == actorId:
		var msg = "战机已现！"
		me.attach_free_dialog(msg, 0)
	return false

func on_trigger_20013() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		return false
	if me.get_buff(BUFF)["回合数"] <= 0:
		ske.set_war_skill_val(0)
		# BUFF 被动消失
		ske.cost_war_cd(2)
	return false

func effect_20602_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var msg = "消耗 {0} 机动力\n进入「{1}」状态 {2} 回合\n可否？".format([
		COST_AP, BUFF, TURNS,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20602_confirmed() -> void:
	ske.cost_ap(COST_AP, true)
	ske.set_war_buff(actorId, BUFF, 3)
	# 设置标记，用以辅助判断被动 BUFF 消失后的 CD
	ske.set_war_skill_val(1)
	ske.war_report()

	var msg = "人衔枚，马束口\n敛息速行！"
	map.draw_actors()
	play_dialog(actorId, msg, 2, 2999)
	return
