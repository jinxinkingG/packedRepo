extends "effect_20000.gd"

#急袭主动技 #额外回合
#【急袭】大战场，主将限定技。你可以指定最多3个队友发动。回合结束阶段，你与被指定己方武将体力下降20%、附加获得<急功>、<胜志>，并一起进入额外回合。

const EFFECT_ID = 20041
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TEAM_SIZE_LIMIT = 3
const EFFECT_CHOOSE_NAME = "战争."+str(EFFECT_ID)+"目标";
const EFFECT_CHOOSE_ACTOR = "战争."+str(EFFECT_ID)+"武将";
const DIALOGS = [
	"存亡之分，在此一举！"
]

func effect_20041_start():
	if DataManager.is_extra_war_round():
		var msg = "当前已是额外回合\n【{0}】可另择良机".format([ske.skill_name])
		play_dialog(me.actorId, msg, 2, 2999)
		return

	if actor.get_hp() < int(actor.get_max_hp() / 5):
		play_dialog(me.actorId, "体力过低，无法发动", 3, 2999)
		return

	#先清空选择列表
	set_env(EFFECT_CHOOSE_NAME, [])
	set_env(EFFECT_CHOOSE_ACTOR, -1)
	_update_select_color()
	goto_step("go")
	return

func effect_20041_go():
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.actor().get_hp() <= int(wa.actor().get_max_hp() / 5):
			continue
		targets.append(targetId)
	if targets.empty():
		goto_step("confirm")
		return

	# 修改默认目标，光标总指向最后选的那个
	var lastTargetId = get_env_int(EFFECT_CHOOSE_ACTOR)
	if lastTargetId >= 0 && lastTargetId in targets:
		targets.erase(lastTargetId)
		targets.insert(0, lastTargetId)

	var status = "({0}/{1})".format([selected.size(), TEAM_SIZE_LIMIT])
	var msg = "对何人发动{0}?" + status
	if not wait_choose_actors(targets, msg):
		goto_step("confirm")
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	if Input.is_action_just_pressed("EMU_START"):
		goto_step("cancel")
		return
	wait_for_choose_actor(FLOW_BASE + "_selected", true, true, FLOW_BASE + "_confirm")
	return

func effect_20041_cancel():
	DataManager.set_env(EFFECT_CHOOSE_NAME, [])
	_update_select_color()
	goto_step("go")
	return

func effect_20041_selected():
	var targetId = get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	if targetId in selected:
		selected.erase(targetId)
	elif selected.size() < TEAM_SIZE_LIMIT:
		selected.append(targetId)
	set_env(EFFECT_CHOOSE_ACTOR, targetId)
	set_env(EFFECT_CHOOSE_NAME, selected)
	_update_select_color()
	FlowManager.add_flow("draw_actors")
	goto_step("go")
	return

func effect_20041_confirm():
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	var msg = "独自进入额外回合吗？"
	if not selected.empty():
		var names = []
		for targetId in selected:
			names.append(ActorHelper.actor(targetId).get_name())
		msg = "与{0}\n一起进入额外回合吗？".format(["、".join(names)])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_perform")
	return

func effect_20041_perform():
	DataManager.add_actor_to_extra_round(me.actorId)
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	for selectedId in selected:
		DataManager.add_actor_to_extra_round(selectedId)
	selected.erase(actorId)
	selected.append(actorId)
	ske.set_war_skill_val(selected, 1)
	var dialogs = DIALOGS.duplicate()
	dialogs.shuffle()
	var msg = dialogs[0]+"\n(结束后进入额外回合)"
	ske.cost_war_cd(99999)
	ske.war_report()
	unset_env(EFFECT_CHOOSE_NAME)
	unset_env(EFFECT_CHOOSE_ACTOR)
	play_dialog(me.actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func _update_select_color():
	var positions = []
	for targetId in get_env_int_array(EFFECT_CHOOSE_NAME):
		var wa = DataManager.get_war_actor(targetId)
		positions.append(wa.position)
	map.show_color_block_by_position(positions)
	return
