extends "effect_30000.gd"

# 诓令主动技
#【诓令】小战场，主动技。你通过战前派出的细作，假传军令。“替”对方使用一个战术（限咒缚、强弩、士气向上、火矢），白刃战限1次。

const EFFECT_ID = 30277
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TACTICS = {
	"咒缚": 3,
	"强弩": 3,
	"士气向上": 3,
	"火矢": 3,
}

func effect_30277_start()->void:
	if not enemy.can_use_tactic():
		var msg = "{0}目前不能发动战术".format([
			enemy.get_name()
		])
		me.attach_free_dialog(msg, 2, 30000)
		tactic_end()
		return

	var itactic = Global.load_script("battle/ITactic.gd")
	var options = []
	for tactic in itactic.get_actor_tactic(enemy.actorId):
		if not tactic in TACTICS:
			continue
		var cost = itactic.get_tactic_cost(enemy, tactic)
		if cost > enemy.battle_tactic_point:
			continue
		options.append(tactic)
	if options.empty():
		var msg = "{0}无战术可以发动".format([
			enemy.get_name()
		])
		me.attach_free_dialog(msg, 2, 30000)
		tactic_end()
		return

	if options.size() == 1:
		var msg = "兵不厌诈\n令{0}发动{1}\n可否？".format([
			enemy.get_name(), options[0],
		])
		ske.set_battle_skill_val(options[0])
		SceneManager.show_yn_dialog(msg, actorId, 2)
		LoadControl.set_view_model(2000)
		return
	var msg = "选择战术，令{0}发动：".format([enemy.get_name()])
	var tacticCtrl = SceneManager.current_scene().battle_tactic
	tacticCtrl.lblTitle.text = msg
	tacticCtrl.tacticList = options
	tacticCtrl.lsc.items = options
	tacticCtrl.lsc._set_data()
	tacticCtrl.hide_description()
	LoadControl.set_view_model(2001)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", FLOW_BASE + "_cancel")
	return

func effect_30277_confirmed() -> void:
	var tactic = ske.get_battle_skill_val_str()
	ske.battle_cd(99999)
	# 模拟 AI 战术发动
	DataManager.set_env("值", tactic)
	DataManager.set_env("当前武将", enemy.actorId)
	tactic_end("before_AI_tactic")
	var msg = "何人乱我军令！？"
	enemy.attach_free_dialog(msg, 0, 30000)
	return

func effect_30277_cancel() -> void:
	tactic_end()
	return

func on_view_model_2001() -> void:
	var tacticCtrl = SceneManager.current_scene().battle_tactic
	var lsc = tacticCtrl.lsc
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		lsc.move_right()
	if Input.is_action_just_pressed("ANALOG_UP"):
		lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		lsc.move_down()
	if Global.is_action_pressed_BY():
		goto_step("cancel")
		return
	if not Global.is_action_pressed_AX():
		return
	ske.set_battle_skill_val(tacticCtrl.get_select_tactic_name())
	goto_step("confirmed")
	return
