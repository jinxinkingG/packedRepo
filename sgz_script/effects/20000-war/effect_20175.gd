extends "effect_20000.gd"

#狂言
#【狂言】大战场,锁定技。你使用的计策不作为计策处理，对自身之外的武将均作主动技能。

func on_trigger_20018()->bool:
	# 用计执行前
	var se = DataManager.get_current_stratagem_execution()
	se.work_as_skill = 1
	return false

func on_trigger_20009()->bool:
	# 执行完成
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded <= 0:
		return false
	var mainId = me.get_main_actor_id()
	var name = "诸公"
	if mainId != me.actorId:
		# 非主将
		name = DataManager.get_actor_naughty_title(mainId, me.actorId)
	var wf = DataManager.get_current_war_fight()
	var action = "克"
	if me.side() == "防守方":
		action = "保"
	var msg = "哈哈哈哈……{0}！\n无我{1}，焉能{2}此{3}！".format([
		name, actor.get_name(), action, wf.target_city().get_full_name(),
	])
	if me.get_controlNo() < 0:
		me.attach_free_dialog(msg, 1)
	else:
		# key="" 的意思是只对话不 log
		se.append_result("", msg, 0, me.actorId)
	return false
