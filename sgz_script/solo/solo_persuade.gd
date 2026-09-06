extends Resource

const VIEW_MODEL_NAME = "单挑-玩家-步骤"

func get_view_model() -> int:
	return DataManager.get_env_int(VIEW_MODEL_NAME)

func set_view_model(vm:int) -> void:
	DataManager.set_env(VIEW_MODEL_NAME, vm)
	return

#说服
func _init() -> void:
	FlowManager.bind_import_flow("solo_persuade", self)
	FlowManager.bind_import_flow("solo_persuade_1", self)
	FlowManager.bind_import_flow("solo_persuade_2", self)
	FlowManager.bind_import_flow("solo_persuade_3_join_us", self)

	FlowManager.bind_signal_method("solo_persuade_result", self)
	return

func _input_key(delta: float):
	match get_view_model():
		101:
			Global.wait_for_confirmation("solo_persuade_2", VIEW_MODEL_NAME)
		102:
			Global.wait_for_confirmation("solo_persuade_result", VIEW_MODEL_NAME)
		103:#确认对方投降了
			Global.wait_for_confirmation("solo_run_end", VIEW_MODEL_NAME)
	return

func solo_persuade() -> void:
	var sf = DataManager.get_current_solo_fight()
	var result = sf.persuade_result()
	sf.set_env("说服结果", result)
	FlowManager.add_flow("solo_persuade_1")
	return

func solo_persuade_1() -> void:
	var sf = DataManager.get_current_solo_fight()
	var wa = sf.current()
	var target = sf.target()
	var msg = ""
	var mood = 2
	match sf.get_env_int("说服结果"):
		1:#休想
			msg = "汝等终将败于我军\n何不趁早投降？"
		2:#回到白兵
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "为此等君主赌上性命\n非明智之举\n将军不如早退"
			else:
				msg = "将军身躯已不可再战\n请勿做无谓的抵抗"
		3:#回到大战场
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "为此等君主赌上性命\n非明智之举\n将军不如早退"
			else:
				msg = "将军身躯已不可再战\n请勿做无谓的抵抗"
		4:#加入我方
			msg = "将军乃当世英雄\n不想与将军为敌\n何不与吾等共图大事"
	SceneManager.show_solo_dialog(msg, wa.actorId, mood)
	set_view_model(101)
	return

func solo_persuade_2() -> void:
	var sf = DataManager.get_current_solo_fight()

	var wa = sf.current()
	var target = sf.target()

	var msg = ""
	var mood = 2

	match sf.get_env_int("说服结果"):
		1:#休想
			msg = "一派胡言！\n杀了你这兔崽子！"
			mood = 0
		2:#回到白兵
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "……也有道理"
				mood = 3
			else:
				msg = "如此也好\n日后再分胜负"
		3:#回到大战场
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "……也有道理"
				mood = 3
			else:
				msg = "如此也好\n日后再分胜负"
		4:#加入我方
			msg = "此亦天命\n吾愿效犬马之劳"
	SceneManager.show_solo_dialog(msg, target.actorId, mood)
	set_view_model(102)
	return

func solo_persuade_result() -> void:
	var bf = DataManager.get_current_battle_fight()
	var sf = DataManager.get_current_solo_fight()
	var wa = sf.current()
	var target = sf.target()

	match sf.get_env_int("说服结果"):
		1:#休想
			FlowManager.add_flow("solo_turn_end")
		2:#回到白兵
			bf.set_unit_state(target.actorId, {"将": "后退"})
			FlowManager.add_flow("solo_run_end")
		3:#回到大战场
			bf.set_loser(target.actorId, BattleFight.ResultEnum.ActorRetreat)
			FlowManager.add_flow("solo_run_end")
		4:#加入我方
			if target.actor_surrend_to(wa.wvId):
				#下跪投降，算到主动投诚里，大战场保留方块
				var targetBu = target.battle_actor_unit()
				targetBu.is_surrend = true
				FlowManager.add_flow("solo_persuade_3_join_us")
			else:
				FlowManager.add_flow("solo_turn_end")
	return

func solo_persuade_3_join_us():
	var sf = DataManager.get_current_solo_fight()
	var wa = sf.current()
	var target = sf.target()

	var msg = "{0}加入我军"
	if wa.is_AI_use():
		#AI就显示加入敌军
		msg = "{0}加入敌军"
	msg = msg.format([target.get_name()])
	SceneManager.show_confirm_dialog(msg)
	set_view_model(103)
	return
