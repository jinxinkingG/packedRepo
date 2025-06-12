extends "effect_20000.gd"

#冠懿主动技
#【冠懿】大战场，主动技。指定一名你方武将为目标才能发动。目标的主属性提升至在场所有武将中同属性的最大数值，直到回合结束。每回合限1次。这个效果发动的回合，目标之外的武将不能用计/攻击。

const EFFECT_ID = 20498
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20498_start()->void:
	var targets = get_teammate_targets(me)
	targets.append(actorId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_go")
	return

func effect_20498_go()->void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var actor = wa.actor()
	var mainAttr = ""
	var mainVal = -1
	for attr in actor.LEVELUP_ATTRS:
		var val = actor._get_attr_int(attr)
		if val > mainVal:
			mainAttr = attr
			mainVal = val
	var wf = DataManager.get_current_war_fight()
	var another = null
	for other in wf.get_war_actors(false, true):
		if other.actorId == wa.actorId:
			continue
		var val = other.actor()._get_attr_int(mainAttr)
		if val > mainVal:
			another = wa
			mainVal = val
	if another == null:
		var msg = "{0}之{1}，固天所纵\n不可复加矣\n（已为全场最高，无须【{2}】".format([
			DataManager.get_actor_honored_title(wa.actorId, actorId),
			mainAttr, ske.skill_name,
		])
		play_dialog(actorId, msg, 1, 2999)
		return
	var diff = mainVal - actor._get_attr_int(mainAttr)
	ske.change_war_attr(wa.actorId, mainAttr, diff)
	for teammate in wa.war_vstate().get_war_actors(false, true):
		if teammate.actorId == wa.actorId:
			continue
		ske.set_war_buff(teammate.actorId, "禁止攻击用计", 1)
	# 记录 buff
	ske.set_war_skill_val([wa.actorId, mainAttr, diff], 1)
	ske.cost_war_cd(1)
	ske.war_report()
	var msg = "{0}之{1}，当冠世之懿\n（本回合，{2}的{1}提升至{3}\n（其他武将不可用计/攻击".format([
		DataManager.get_actor_honored_title(wa.actorId, actorId),
		mainAttr, wa.get_name(), actor._get_attr_int(mainAttr)
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
