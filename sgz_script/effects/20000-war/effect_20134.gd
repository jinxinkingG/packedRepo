extends "effect_20000.gd"

#幕后效果实现
#【幕后】大战场,锁定技。① 与你相邻的己方武将计策列表和你一样，且其使用计策时，以你的“知”代替进行命中率和伤害的结算。② 你方回合结束时，若你没有相邻己方武将，直到你方回合开始前，你临时获得<智破>。

func on_trigger_20004() -> bool:
	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")

	var who = brother_behind_you()
	if who == null:
		return false

	var replaced = DataManager.get_env_dict("战争.计策替换")
	var costRequired = true
	var learned = {}
	for scheme in schemes:
		var name = str(scheme[0])
		var ext = ""
		if scheme.size() > 2:
			ext = str(scheme[2])
		learned[name] = ext
	schemes = []
	for scheme in me.get_stratagems():
		var name = scheme.name
		if name in replaced:
			name = replaced[name]
			if not name in StaticManager.stratagemDic:
				continue
		var ext = ""
		if name in learned:
			ext = learned[name]
		schemes.append([name, 0, ext])
	var msgs = Array(msg.split("\n"))
	msgs.append("已复刻{0}的计策".format([
		actor.get_name()
	]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(ske.actorId, schemes, msg)
	return false

func on_trigger_20017() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(ske.actorId) != ske.actorId:
		return false
	var who = brother_behind_you()
	if who == null:
		return false
	var diff = actor.get_wisdom() - who.actor().get_wisdom()
	change_scheme_chance(actorId, ske.skill_name, diff)
	return false

func on_trigger_20029() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(ske.actorId) != ske.actorId:
		return false
	var who = brother_behind_you()
	if who == null:
		return false
	var diff = actor.get_wisdom() - who.actor().get_wisdom()
	change_scheme_chance(actorId, ske.skill_name, diff)
	return false

func on_trigger_20016() -> bool:
	if not get_teammate_targets(me, 1, true).empty():
		return false
	ske.add_war_skill(actorId, "智破", 1, true)
	return false

# 判断触发技能的武将是否符合幕后的条件
# 同时完成取武将对象的功能
# @return 返回符合条件的触发武将，null 表示不符合
func brother_behind_you() -> War_Actor:
	var who = DataManager.get_war_actor(ske.actorId)
	if who == null or who.disabled:
		return null
	if not me.is_teammate(who):
		return null
	if Global.get_distance(who.position, me.position) != 1:
		return null
	return who
