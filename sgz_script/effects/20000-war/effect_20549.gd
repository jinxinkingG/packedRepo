extends "effect_20000.gd"

#千追锁定技部分
#【千追】大战场，限定技。你可指定1名武力>90的敌将为目标发动。直到战争结束前，你朝靠近目标的方向移动时，默认只需1点机动力；除非目标离开战场，否则你不能对其他武将攻击或用计。

const ACTIVE_EFFECT_ID = 20548

func on_trigger_20007() -> bool:
	var marked = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if marked < 0:
		return false
	var markedWA = DataManager.get_war_actor(marked)
	if markedWA == null or markedWA.disabled:
		return false
	var targetDic = DataManager.get_env_dict("行军目标")
	var targetPos = Vector2(int(targetDic["x"]), int(targetDic["y"]))
	if Global.get_distance(targetPos, markedWA.position) >= Global.get_distance(me.position, markedWA.position):
		return false
	DataManager.set_env("行军消耗机动力", 1)
	return false

func on_trigger_20015() -> bool:
	var marked = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if marked < 0:
		return false
	var markedWA = DataManager.get_war_actor(marked)
	if markedWA == null or markedWA.disabled:
		return false
	var bf = DataManager.get_current_battle_fight()
	if actorId != bf.get_attacker_id():
		return false
	if marked != bf.get_defender_id():
		return false
	var msg = "{0}匹夫，今日合死！".format([markedWA.get_name()])
	me.attach_free_dialog(msg, 0)
	return false

func on_trigger_20030() -> bool:
	var marked = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if marked < 0:
		return false
	var markedWA = DataManager.get_war_actor(marked)
	if markedWA == null or markedWA.disabled:
		return false
	var wf = DataManager.get_current_war_fight()
	var excluded = DataManager.get_env_dict("战争.攻击目标排除")
	for wa in wf.get_war_actors(false, true):
		if wa.actorId == marked:
			continue
		excluded[wa.actorId] = ske.skill_name
	DataManager.set_env("战争.攻击目标排除", excluded)
	return false

