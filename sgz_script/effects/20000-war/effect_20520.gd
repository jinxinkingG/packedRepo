extends "effect_20000.gd"

#当先锁定效果部分
#【当先】大战场，诱发技。你方回合开始阶段才能发动。你可不消耗机动力移动1-2格，若移动后，存在与你相邻的敌将，则你必须与之进入白刃战；若此白刃战最终战败，你主要阶段不能进行攻击和用计。

const EFFECT_ID = 20520
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20007() -> bool:
	var setting = ske.get_war_skill_val_int_array()
	if setting.size() != 2 or setting[0] <= 0:
		return false
	var limit = setting[0]
	var moved = setting[1]
	if moved < limit:
		DataManager.set_env("行军消耗机动力", 0)
	else:
		DataManager.set_env("行军消耗机动力", 99999)
	return false

func on_trigger_20003() -> bool:
	var setting = ske.get_war_skill_val_int_array()
	if setting.size() != 2 or setting[0] <= 0:
		return false
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	match moveType:
		1:
			setting[1] += 1
			var msg = "【{0}】可自由移动{1}步".format([ske.skill_name, setting[0] - setting[1]])
			DataManager.set_env("对白", msg)
		-1:
			setting[1] -= 1
			var msg = "【{0}】可自由移动{1}步".format([ske.skill_name, setting[0] - setting[1]])
			DataManager.set_env("对白", msg)
		0:
			if moveStopped > 0:
				if me.get_controlNo() >= 0:
					# 玩家要求历史移动记录，不允许原地触发
					if DataManager.get_env_array("历史移动记录").empty():
						ske.set_war_skill_val([], 1)
						return false
				var targetIds = get_nearby_enemies()
				if targetIds.empty():
					ske.set_war_skill_val([], 1)
					return false
				return true
	ske.set_war_skill_val(setting, 1)
	return false

func on_trigger_20020() -> bool:
	var setting = ske.get_war_skill_val_int_array()
	if setting.size() != 2 or setting[0] != 0:
		return false
	var targetId = setting[1]
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != actorId:
		return false
	if bf.targetId != targetId:
		return false
	var loser = bf.get_loser()
	if loser == null or loser.actorId != actorId:
		return false
	ske.set_war_buff(actorId, "禁止攻击用计", 1)
	ske.war_report()
	var msg = "初阵不利，惭愧 ……\n（已被禁止攻击、计策"
	me.attach_free_dialog(msg, 3)
	return false

func effect_20520_AI_start() -> void:
	var targetIds = Array(get_nearby_enemies())
	targetIds.shuffle()
	DataManager.set_env("目标", targetIds[0])
	goto_step("2")
	return

func effect_20520_start() -> void:
	var targetIds = get_nearby_enemies()
	var msg = "【{0}】攻击何人？".format([ske.skill_name])
	if not wait_choose_actors(targetIds, msg):
		msg = "没有可攻击的目标"
		play_dialog(actorId, msg, 3, 2990)
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true, false)
	return

func effect_20520_2():
	var targetId = DataManager.get_env_int("目标")

	var msg = "看{0}先下一阵！".format([
		DataManager.get_actor_self_title(actorId)
	])
	play_dialog(actorId, msg, 0, 2001)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20520_3():
	map.next_shrink_actors = []
	var targetId = DataManager.get_env_int("目标")
	# 设置对应变量以表示开战
	ske.set_war_skill_val([0, targetId], 1)
	start_battle_and_finish(actorId, targetId)
	return

func get_nearby_enemies() -> PoolIntArray:
	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		var target = DataManager.get_war_actor_by_position(pos)
		if not me.is_enemy(target):
			continue
		targetIds.append(target.actorId)
	return check_combat_targets(targetIds)
