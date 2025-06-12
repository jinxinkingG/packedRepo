extends "effect_20000.gd"

#刚直效果实现
#【刚直】大战场，锁定技。你被攻击时，你方其他武将无法发动诱发技；你使用计策时，对方武将无法发动诱发技。

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("")
	return

func effect_20361_AI_start():
	goto_step("start")
	return

func effect_20361_start():
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
		"run_battle":
			var msg = "{0}何曾落于人后？\n吾自迎敌！\n（【{1}】禁友军诱发计".format([
				DataManager.get_actor_self_title(me.actorId),
				ske.skill_name,
			])
			play_dialog(me.actorId, msg, 0, 2000)
			return
	LoadControl.end_script()
	return

func on_trigger_20015()->bool:
	if bf.get_defender_id() != me.actorId:
		return false
	# 被攻击时，自己触发总是在对方武将之后，友方其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("己方", "诱发")
	ske.war_report()
	return true

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	se.induce_disabled = 1
	# 发动计策时，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("敌方", "诱发")
	# 找敌方最聪明的
	var enemyId = -1
	var maxWisdom = -1
	for targetId in get_enemy_targets(me, true, 999):
		var target = ActorHelper.actor(targetId)
		if target.get_wisdom() > maxWisdom:
			maxWisdom = target.get_wisdom()
			enemyId = target.actorId
	#se.message = se.get_message() +
	var skillMessage = "".format([])
	se.message = "{0}施为，皆阳谋也\n{1}可能破得？\n（【{2}】禁反制诱发计".format([
		DataManager.get_actor_self_title(me.actorId),
		DataManager.get_actor_naughty_title(enemyId, me.actorId),
		ske.skill_name,
	])
	ske.war_report()
	return false

func on_trigger_20012()->bool:
	# 计策完成后，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("敌方", "诱发")
	ske.war_report()
	return true
