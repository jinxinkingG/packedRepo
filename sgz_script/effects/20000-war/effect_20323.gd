extends "effect_20000.gd"

#伏策被动效果触发
#【伏策】大战场，主动技。每个回合限1次。选择1个你已掌握的计策，再选择1名队友，你消耗该计策所需机动力发动。为该队友附加记录所选计策的“伏”标记，有效期一个敌方回合。敌方对拥有“伏”标记的队友用计时，若计策与“伏”标记所记录的计策相同，计策无条件失败。

const EFFECT_ID = 20323

func on_trigger_20010()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId == me.actorId:
		# 不能对自己发动
		return false
	if se.targetId != ske.actorId:
		# 触发者不是用计目标
		return false
	var marked = _get_marked_schemes(se.targetId)
	if not se.name in marked:
		return false
	if int(marked[se.name]) != me.actorId:
		return false
	# 限制三次
	if not ske.cost_war_limited_times(3):
		return false
	# 强令失败
	se.set_must_fail(me.actorId, ske.skill_name)
	var targetWA = DataManager.get_war_actor(se.targetId)
	var msg = "果不出{0}所料\n{1}雕虫小技，何损于我？".format([
		DataManager.get_actor_honored_title(me.actorId, se.targetId),
		se.name
	])
	append_free_dialog(targetWA, msg, 1)
	return false

func _get_marked_schemes(targetId:int)->Dictionary:
	var ret = {}
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null or targetWA.disabled:
		return ret
	if targetWA.get_buff_label_turn(["计防"]) <= 0:
		ske.set_war_skill_val({}, 0, -1, targetId)
		return ret
	var dic = ske.get_war_skill_val_dic(-1, targetId)
	var limit = 0
	for item in dic:
		var scheme = str(item)
		var fromId = int(dic[item])
		if fromId >= 0:
			ret[scheme] = fromId
	return ret
