extends "effect_20000.gd"

#焚城
#【焚城】大战场,锁定技。回合结束后，本回合内被你使用火类计策成功的所有敌人，你分别对其造成50点的火属性技能伤害。

const EFFECT_ID = 20172
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const STRATAGEM = "火计"

# 计策发动后，记录火计对象
func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	if se.succeeded <= 0:
		return false
	# 火类计策不能用 get_nature 判断，因为有火箭
	if not se.name in ["火计", "火箭", "劫火"]:
		return false

	for targetId in se.get_all_damaged_targets():
		var targetWA = DataManager.get_war_actor(targetId)
		if targetWA == null or targetWA.disabled:
			continue
		if targetWA.get_soldiers() <= 0:
			continue
		# 标记计策指定的对象
		ske.set_war_skill_val(1, 1, -1, targetId)
	return false

# 回合结束，检查是否发动
func on_trigger_20016()->bool:
	if ske.actorId != me.actorId:
		# 如果不是自己回合触发，则需要记录和检查触发对象
		# 避免敌方回合多人重复触发
		var triggerEnemyId = ske.get_war_skill_val_int(-1, -1, -1)
		if triggerEnemyId < 0:
			ske.set_war_skill_val(ske.actorId, 1)
		elif triggerEnemyId != ske.actorId:
			return false
	unset_env(_get_targets_key())
	var targets = []
	for targetId in get_enemy_targets(me, true, 999):
		if ske.get_war_skill_val_int(-1, targetId) == 1:
			ske.set_war_skill_val(0, 0, -1, targetId)
			targets.append(targetId)
	if targets.empty():
		return false
	set_env(_get_targets_key(), targets)
	return true

func effect_20172_AI_start():
	goto_step("start")
	return

# 锁定技发动
func effect_20172_start() -> void:
	var targets = DataManager.get_env_array(_get_targets_key())
	if targets.empty():
		LoadControl.end_script()
		return
	var name = ActorHelper.actor(targets[0]).get_name()
	var msg = "烈焰焚城，末世景象！"
	
	if targets.size() > 1:
		msg += "\n（对{0}等{1}人发动【焚城】".format([name, targets.size()])
	else:
		msg += "\n（对{0}发动【焚城】".format([name])
	map.show_can_choose_actors(targets)

	var se = DataManager.new_stratagem_execution(ske.skill_actorId, STRATAGEM, ske.skill_name)
	se.set_target(targets[0])
	ske.play_se_animation(se, 2000, msg, 0)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_perform")
	return

func effect_20172_perform():
	var targets = DataManager.get_env_int_array(_get_targets_key())
	DataManager.unset_env(_get_targets_key())
	var se = DataManager.get_current_stratagem_execution()

	var total = 0
	# 直接扣兵，不结算计策
	for targetId in targets:
		total += int(DataManager.damage_sodiers(actorId, targetId, 50))

	var msg = "敌军损兵{0}".format([total])
	play_dialog(actorId, msg, 1, 2990)
	return

func _get_targets_key()->String:
	return "技能.焚城.目标.{0}".format([ske.skill_actorId])
