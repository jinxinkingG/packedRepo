extends "effect_20000.gd"

#绝策被动效果
#【绝策】大战场，锁定技。对方大战场回合限1次。对方第一个兵力>0的武将，移动到你六格以内的位置时，你对之使用必中的火计。

const EFFECT_ID = 20332
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const STRATAGEM = "火计"

func on_trigger_20003() -> bool:
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	if moveType != 0 or moveStopped != 1:
		return false
	# 这里特殊判断一下，如果是玩家，需要确认确实移动了
	# AI 暂无历史移动记录，未来可能需要加
	# TODO
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa.get_controlNo() >= 0:
		var history = DataManager.get_env_array("历史移动记录")
		if history.empty():
			return false
	# 没兵的忽略
	if wa.get_soldiers() <= 0:
		return false
	if Global.get_range_distance(wa.position, me.position) > get_choose_distance():
		return false
	ske.cost_war_cd(1)
	var se = DataManager.new_stratagem_execution(actorId, STRATAGEM, ske.skill_name)
	se.set_target(wa.actorId)
	# 强制命中
	se.perform_to_targets([se.targetId], true)
	# 考虑到多个绝策连续发动，互相冲掉信息的情况，在此记录 damage
	var damage = se.get_soldier_damage_for(se.targetId)
	var key = "战争.绝策.伤害.{0}.{1}".format([actorId, wa.actorId])
	DataManager.set_env(key, damage)
	return true

func effect_20332_AI_start() -> void:
	goto_step("start")
	return

func effect_20332_start() -> void:
	map.camer_to_actorId(ske.actorId, "")
	var se = DataManager.get_current_stratagem_execution()
	var msg = "{0}，先来送死吗\n（{1}发动【{2}】".format([
		DataManager.get_actor_naughty_title(se.targetId, actorId),
		me.get_name(), ske.skill_name,
	])
	ske.play_se_animation(se, 2000, msg, 0)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20332_2() -> void:
	var se = DataManager.get_current_stratagem_execution()
	var key = "战争.绝策.伤害.{0}.{1}".format([me.actorId, se.targetId])
	var damage = DataManager.get_env_int(key)
	var msg = "我军兵力下降{0}".format([damage])
	map.draw_actors()
	play_dialog(se.targetId, msg, 3, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

# 模拟计策事件回调
func effect_20332_end() -> void:
	# 20009 不支持 flow，仅触发，嵌套是安全的
	SkillHelper.auto_trigger_skill(me.actorId, 20009, "")
	var se = DataManager.get_current_stratagem_execution()
	se.report()
	skill_end_clear()
	return
