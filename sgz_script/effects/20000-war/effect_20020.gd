extends "effect_20000.gd"

#曲顾效果
#【曲顾】大战场，锁定技。你的队友用计失败时，你获得其用计消耗的一半机动力。同一回合，每位队友仅限触发一次。

const EFFECT_ID = 20020

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var se = DataManager.get_current_stratagem_execution()
	# 计策成功不触发
	if se.succeeded > 0:
		return false
	if se.fromId == self.actorId:
		# 自己不触发
		return false
	var ap = int(se.cost / 2)
	if ap <= 0:
		return false
	if not _set_triggered_actor(self.actorId, ske.actorId):
		return false
	var me = DataManager.get_war_actor(self.actorId)
	me.action_point += ap
	var msg = "因【{0}】效果\n{1}回复{2}机动力".format([
		ske.skill_name, me.get_name(), ap
	])
	se.append_result(ske.skill_name, msg, ap, self.actorId)
	SceneManager.current_scene().war_map.update_ap()
	return false

func _get_triggered_actors(actorId:int)->PoolIntArray:
	var ret = []
	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, actorId)
	if skv["turn"] <= 0 or skv["value"] == null:
		return ret
	if typeof(skv["value"]) != TYPE_ARRAY:
		return ret
	for id in Array(skv["value"]):
		ret.append(int(id))
	return ret

func _set_triggered_actor(actorId:int, targetId:int)->bool:
	var triggered = _get_triggered_actors(actorId)
	if targetId in triggered:
		return false
	triggered.append(targetId)
	SkillHelper.set_skill_variable(20000, EFFECT_ID, actorId, triggered, 1)
	return true
