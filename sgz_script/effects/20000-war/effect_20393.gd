extends "effect_20000.gd"

#锐轻效果实现
#【锐轻】大战场，锁定技。你发起攻击宣言时，目标之外的敌将不能发动诱发技；你被用计时，你以外的队友不能发动诱发技。

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("")
	return

func effect_20393_AI_start():
	goto_step("start")
	return

func effect_20393_start():
	# 这里比较特殊，需要判断 st 的来源决定做什么
	var st = SkillHelper.get_current_skill_trigger()
	if st == null:
		LoadControl.end_script()
	match st.next_flow:
		"AI_strategem_end_2_trigger":
			# 跳过被用计者的触发
			st.next_flow = "AI_stratagem_done"
		"stratagem_trigger_2":
			# 跳过被用计者的触发
			st.next_flow = "ask_for_continue_strategem"
		"before_battle_2":
			var msg = "{0}骁锐，谁可当之？\n（【{1}】禁敌军诱发计".format([
				DataManager.get_actor_self_title(me.actorId),
				ske.skill_name,
			])
			play_dialog(me.actorId, msg, 0, 2000)
			return
	LoadControl.end_script()
	return

func on_trigger_20015()->bool:
	if bf.get_attacker_id() != me.actorId:
		return false
	# 20015 攻方和守方会分别触发
	# 所以 disable_skill_buff_type 目前的机制不好使
	# TODO
	# DataManager.actor_skill_buff 已经移除
	# 未实现，需要重新实现
	return true

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	# 发动计策时，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("己方", "诱发")
	ske.war_report()
	if me.get_controlNo() < 0:
		se.message = "{0}锐而轻敌，破之易尔\n（因【{1}】效果，友军诱发计无效".format([
			me.get_name(), ske.skill_name,
		])
	return false

func on_trigger_20038()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	# 发动计策时，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("己方", "诱发")
	ske.war_report()
	return false

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	# 计策完成后，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("己方", "诱发")
	ske.war_report()
	return true
