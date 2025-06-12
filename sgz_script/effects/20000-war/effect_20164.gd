extends "effect_20000.gd"

#无言
#【无言】大战场,锁定技。你无法使用伤兵计，你无法被计策伤兵。同时，若你与“初次加入的势力”对阵，你无法使用任何计策

func on_trigger_20002()->bool:
	change_scheme_damage_rate(-100)
	return false

func on_trigger_20004()->bool:
	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")
	var replaced = DataManager.get_env_dict("战争.计策替换")

	var kept = []
	for scheme in schemes:
		var name = str(scheme[0])
		var schemeInfo = StaticManager.get_stratagem(name)
		if schemeInfo.may_damage_soldier():
			for k in replaced:
				if replaced[k] == name:
					replaced[k] = ""
			replaced[name] = ""
			continue
		kept.append(scheme)
	var msgs = []
	msgs.append_array(msg.split("\n"))
	var extra = "（因【{0}】计策受限".format([ske.skill_name])
	if msgs.size() >= 3:
		msgs[2] = extra
	else:
		msgs.append(extra)
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(me.actorId, kept, msg)
	DataManager.set_env("战争.计策替换", replaced)
	return false

func on_trigger_20024()->bool:
	var key = "战争.计策.允许.{0}".format([me.actorId])
	if DataManager.get_env_int(key) != 1:
		return false
	if me.get_enemy_war_vstate().vstate().id == actor.get_initial_vstate_id():
		var msg = "…… ……\n（因【无言】效果\n（不能使用计策"
		DataManager.set_env(key, msg)
	return false

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	if not se.damage_soldier():
		return false
	# 发动计策时，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("己方", "诱发")
	return false

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	if not se.damage_soldier():
		return false
	# 计策完成后，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("己方", "诱发")
	return true

func on_trigger_20038()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	if not se.damage_soldier():
		return false
	# 发动计策时，自己触发总是在所有其他武将之前
	# 可以通过临时跳过 skill buff 的方式实现
	ske.disable_skill_buff_type("己方", "诱发")
	return false

func effect_20164_AI_start():
	goto_step("start")
	return

func effect_20164_start():
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
	LoadControl.end_script()
	return
