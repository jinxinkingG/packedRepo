extends "effect_20000.gd"

#狼顾锁定技 #施加状态
#合并鹰视效果
#【狼顾】大战场，锁定技。你用伤兵计成功时，若目标未处于定止状态，则对其附加1回合定止。
#【鹰视】大战场，锁定技。你发动多目标伤兵计策时，对每个伤害的目标均可触发〈狼顾〉效果。

const EFFECT_ID = 20030
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != actorId:
		#必须是自己
		return false
	if not se.damage_soldier():
		#非伤兵计跳过
		return false
	if se.succeeded <= 0:
		#未成功跳过
		return false
	var targetIds = [se.targetId]
	if SkillHelper.actor_has_skills(actorId, ["鹰视"]):
		for damagedId in se.get_all_damaged_targets():
			if not damagedId in targetIds:
				targetIds.append(damagedId)
	var allStopped = true
	for targetId in targetIds:
		var wa = DataManager.get_war_actor(targetId)
		if wa == null or wa.disabled:
			continue
		if wa.get_buff_label_turn(["禁止移动"]) <= 0:
			allStopped = false
			break
	#都已经被定止，跳过
	if allStopped:
		return false
	se.skip_redo = 1
	return true

func effect_20030_AI_start():
	goto_step("start")
	return

func effect_20030_start():
	var se = DataManager.get_current_stratagem_execution()
	var targetIds = [se.targetId]
	if SkillHelper.actor_has_skills(actorId, ["鹰视"]):
		for damagedId in se.get_all_damaged_targets():
			if not damagedId in targetIds:
				targetIds.append(damagedId)
	var stopped = []
	for targetId in targetIds:
		if ske.set_war_buff(targetId, "定止", 1) > 0:
			stopped.append(targetId)
	var names = []
	for targetId in stopped:
		names.append(ActorHelper.actor(targetId).get_name())
	if names.size() >= 3:
		names = names.slice(0, 2)
		names[2] += "等{0}人".format([stopped.size()])
	# 仅记录日志
	ske.war_report()
	var who = "、".join(names)
	var dear = "小儿"
	if names.size() > 1:
		dear = "尔等"
	var msg = "{0}休想逃出我的掌心！\n（{1}被定止".format([dear, who])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("")
	return
