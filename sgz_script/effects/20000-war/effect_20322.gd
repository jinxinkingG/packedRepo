extends "effect_20000.gd"

#伏策主动技
#【伏策】大战场，主动技。每个回合限1次。选择1个你已掌握的计策，再选择1名队友，你消耗该计策所需机动力发动。为该队友附加记录所选计策的“伏”标记，有效期一个敌方回合。敌方对拥有“伏”标记的队友用计时，若计策与“伏”标记所记录的计策相同，计策无条件失败。

const EFFECT_ID = 20322
const PASSIVE_EFFECT_ID = 20323
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_choose_actor(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func effect_20322_start():
	var msg = "选择哪个计策？"
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	var items = []
	var values = []
	for scheme in me.get_stratagems():
		var setting = [scheme.name, scheme.get_cost_ap(self.actorId)]
		items.append("{0}({1})".format(setting))
		values.append("{0}|{1}".format(setting))
	bind_menu_items(items, values)
	LoadControl.set_view_model(2000)
	return

func effect_20322_2():
	var targets = get_teammate_targets(me)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2001)
	return

func effect_20322_3():
	var chosen = get_env_str("目标项").split("|")
	var schemeName = chosen[0]
	var ap = int(int(chosen[1]) * 2 / 3)
	var targetId = get_env_int("目标")
	if schemeName in _get_marked_schemes(targetId):
		var msg = "已为{0}预防[{1}]\n无须重复发动".format([
			ActorHelper.actor(targetId).get_name(), schemeName,
		])
		play_dialog(me.actorId, msg, 2, 2009)
		return
	if not assert_action_point(me.actorId, ap):
		return
	var msg = "消耗{0}机动力发动【{1}】\n为{2}预防敌方{3}\n可否？".format([
		ap, ske.skill_name, ActorHelper.actor(targetId).get_name(), schemeName,
	])
	play_dialog(me.actorId, msg, 2, 2002, true)
	return

func effect_20322_4():
	var chosen = get_env_str("目标项").split("|")
	var schemeName = chosen[0]
	var ap = int(int(chosen[1]) * 2 / 3)
	var targetId = get_env_int("目标")
	
	ske.cost_war_cd(1)
	ske.cost_ap(ap, true)
	_mark_scheme(me, targetId, schemeName)
	var msg = "{0}不难破也\n{1}留心，只须如此…".format([
		schemeName,
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	ske.war_report()
	play_dialog(me.actorId, msg, 2, 2009)
	return

func _get_marked_schemes(targetId:int)->Dictionary:
	var ret = {}
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null or targetWA.disabled:
		return ret
	if targetWA.get_buff_label_turn(["计防"]) <= 0:
		ske.set_war_skill_val({}, 0, PASSIVE_EFFECT_ID, targetId)
		return ret
	var dic = ske.get_war_skill_val_dic(PASSIVE_EFFECT_ID, targetId)
	for item in dic:
		var scheme = str(item)
		var fromId = int(dic[item])
		if fromId >= 0:
			ret[scheme] = fromId
	return ret

func _mark_scheme(me:War_Actor, targetId:int, schemeName:String):
	var marked = _get_marked_schemes(targetId)
	marked[schemeName] = me.actorId
	var turns = 1
	if me.side() == "防守方":
		turns = 2
	ske.set_war_skill_val(marked, turns, PASSIVE_EFFECT_ID, targetId)
	ske.set_war_buff(targetId, "计防", 1)
	return
