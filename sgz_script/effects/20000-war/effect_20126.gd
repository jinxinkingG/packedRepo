extends "effect_20000.gd"

#锦囊效果实现
#【锦囊】大战场,主动技。你消耗2点机动力，指定一名队友发动。其获得1个[锦囊]标记，每回合限3次。拥有[锦囊]的武将用计时，消耗该标记，你替代之成为用计者。每位武将最多携带3个锦囊。

const EFFECT_ID = 20126
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const FLAG_NAME = "策"
const COST_AP = 2
const FLAG_RECHARGE_COUNT = 3
const FLAG_TAKE_LIMIT = 3

func on_trigger_20013()->bool:
	ske.add_skill_flags(20000, ske.effect_Id, FLAG_NAME, FLAG_RECHARGE_COUNT, FLAG_RECHARGE_COUNT)
	return false

func on_trigger_20004()->bool:
	# 己方计策列表信息提示
	if actorId == ske.actorId:
		return false
	var cnt = _total_marked_helps(ske.actorId)
	if cnt <= 0:
		return false
	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")
	var msgs = Array(msg.split("\n"))
	msgs.append("锦囊：{0}".format([cnt]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(actorId, schemes, msg)
	return false

func on_trigger_20018()->bool:
	# 己方用计时替代
	if actorId == ske.actorId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.actionId != se.fromId:
		# 已有别人替代用计
		return false
	var status = _get_marked_status(ske.actorId)
	var statusKey = str(actorId)
	if not status.has(statusKey) or int(status[statusKey]) <= 0:
		return false
	_mark_for_help(actorId, ske.actorId, -1)
	# 替代用计
	se.set_replaced_actioner(actorId, ske.skill_name)
	se.goback_disabled = 1
	se.message = se.get_message() + "\n（{0}替代{1}用计".format([
		me.get_name(), ske.actioner().get_name(),
	])
	# 规避摧克
	if se.name in ["火计", "要击", "乱水"]:
		se.rangeRadius = 0
	return false

func _get_marked_status(targetId:int)->Dictionary:
	return ske.get_war_skill_val_dic(-1, targetId)
	
func _mark_for_help(fromId:int, targetId:int, val:int)->void:
	var status = _get_marked_status(targetId)
	var statusKey = str(fromId)
	var marked = 0
	if status.has(statusKey):
		marked = int(status[statusKey])
	status[statusKey] = marked + val
	ske.set_war_skill_val(status, 99999, -1, targetId)
	return

func _total_marked_helps(targetId:int)->int:
	var status = _get_marked_status(targetId)
	var cnt = 0
	for k in status.keys():
		if k == "flags":
			continue
		cnt += int(status[k])
	return cnt

func effect_20126_start():
	if not assert_action_point(actorId, COST_AP):
		return false

	var flags = ske.get_skill_flags(20000, ske.effect_Id, FLAG_NAME)
	if flags <= 0:
		play_dialog(actorId, "锦囊尽矣", 3, 2999)
		return

	if not wait_choose_actors(get_teammate_targets(me), "将【{0}】交予何人"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20126_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetFlags = _total_marked_helps(targetId)
	if targetFlags >= FLAG_TAKE_LIMIT:
		var msg = "{0}已携带{1}个锦囊\n妙策在精不在多".format([
			targetWA.get_name(), targetFlags
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var flags = ske.get_skill_flags(20000, ske.effect_Id, FLAG_NAME)
	if flags > 1 and FLAG_TAKE_LIMIT - targetFlags > 1 and me.action_point >= COST_AP * 2:
		# 可以给多个
		var maxAmount = min(flags, int(me.action_point / COST_AP))
		maxAmount = min(FLAG_TAKE_LIMIT - targetFlags, maxAmount)
		var msg = "交予{0}几个锦囊？".format([targetWA.get_name()])
		SceneManager.show_input_numbers(msg, ["锦囊"], [maxAmount], [0], [0])
		SceneManager.input_numbers.show_actor(actorId)
		LoadControl.set_view_model(2001)
		return
	else:
		DataManager.set_env("数值", 1)
		goto_step("3")
	return

func on_view_model_2001()->void:
	wait_for_number_input(FLOW_BASE + "_3")
	return

func effect_20126_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetFlags = _total_marked_helps(targetId)

	var cnt = DataManager.get_env_int("数值")

	ske.cost_ap(COST_AP * cnt)
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
	flags = max(0, flags - cnt)
	ske.cost_skill_flags(20000, ske.effect_Id, FLAG_NAME, cnt)
	_mark_for_help(actorId, targetId, cnt)
	ske.war_report()

	var msg = "{0}，依计行事\n（交予{1}{2}个锦囊".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		targetWA.get_name(), cnt,
	])
	me.attach_free_dialog(msg)

	msg = "诺！"
	if targetId == me.get_main_actor_id():
		msg = "善！"
	msg += "\n（{1}的下次计策\n（将由{0}发动".format([
		me.get_name(), targetWA.get_name()
	])
	me.attach_free_dialog(msg, 2, 20000, targetId)
	FlowManager.add_flow("player_skill_end_trigger")
	return
