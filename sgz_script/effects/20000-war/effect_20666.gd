extends "effect_20000.gd"

# 留柴主动技 #撤退 #兵力分配
#【留柴】大战场，主动技。你体力小于25时，才能发动：你撤离大战场，你的兵力平分给你方场上剩余武将。（每个武将，兵力不超过2000）

const EFFECT_ID = 20666
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_LIMIT = 25

func check_AI_perform_20000()->bool:
	# 体力不足
	if actor.get_hp() >= HP_LIMIT:
		return false
	# 有路可退
	var cityId = me.get_retreat_city_id()
	if cityId < 0:
		return false
	# 仍有队友
	if me.get_teammates(false, true).empty():
		return false
	# AI 满足条件，一定发动
	return true

func effect_20666_AI_start() -> void:
	DataManager.set_env("目标项", me.get_retreat_city_id())
	goto_step("selected")
	return

func effect_20666_start() -> void:
	if actor.get_hp() >= HP_LIMIT:
		var msg = "气力尚足，何故先怯？".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	if me.get_teammates(false, true).empty():
		var msg = "无人可托，【{0}】于谁？".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var items = []
	var values = []
	for cityId in me.war_vstate().get_all_retreat_city_ids():
		var c = clCity.city(cityId)
		items.append("{0} ({1})".format([
			c.get_name(), c.get_actors_count(),
		]))
		values.append(c.ID)
	if items.empty():
		var msg = "无路可退 ……".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "撤往何处？"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, values, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected")
	return

func effect_20666_selected() -> void:
	var cityId = DataManager.get_env_int("目标项")
	var city = clCity.city(cityId)

	var target = "诸公"
	if actorId == me.get_main_actor_id():
		# 是主将，随便委托一个
		var teammates = me.get_teammates(false, true)
		me.war_vstate().main_actorId = teammates[0].actorId
		ske.set_war_skill_val(teammates[0].actorId)
		target = DataManager.get_actor_honored_title(teammates[0].actorId, actorId)
	var msg = "战事就拜托{0}了\n后方不可失\n{1}先回{2}坐镇".format([
		target, actor.get_short_name(), city.get_full_name(),
	])
	
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_notified")
	return

func effect_20666_notified() -> void:
	var cityId = DataManager.get_env_int("目标项")
	var city = clCity.city(cityId)
	var replacedLeaderId = ske.get_war_skill_val_int()

	var soldiers = actor.get_soldiers()
	soldiers = ske.sub_actor_soldiers(actorId, soldiers)

	var teammates = me.get_teammates(false, true)
	me.retreat_to(city.ID)
	var msg = "{0}撤退".format([
		actor.get_name(),
	])
	if replacedLeaderId > 0:
		msg += "，{0}成为主将".format([
			ActorHelper.actor(replacedLeaderId).get_name(),
		])

	var remaining = soldiers
	while not teammates.empty() and remaining > 0:
		var recover = int(ceil(remaining * 1.0 / teammates.size()))
		var wa = teammates.pop_front()
		recover = ske.add_actor_soldiers(wa.actorId, recover, 2000)
		remaining -= recover

	report_skill_result_message(ske, 2002, msg, 2, -2)
	return

func on_view_model_2002()->void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20666_report() -> void:
	report_skill_result_message(ske, 2002)
	return
