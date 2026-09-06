extends Resource

const VIEW_MODEL_NAME = "单挑-玩家-步骤"

func get_view_model() -> int:
	return DataManager.get_env_int(VIEW_MODEL_NAME)

func set_view_model(vm:int) -> void:
	DataManager.set_env(VIEW_MODEL_NAME, vm)
	return

#撤退
func _init() -> void:
	FlowManager.bind_import_flow("solo_retreat", self)
	FlowManager.bind_import_flow("solo_retreat_1", self)
	FlowManager.bind_import_flow("solo_retreat_2", self)
	FlowManager.bind_import_flow("solo_retreat_3_chase", self)
	FlowManager.bind_import_flow("solo_retreat_4_chase", self)
	FlowManager.bind_import_flow("solo_retreat_5_chase", self)
	FlowManager.bind_import_flow("solo_retreat_6", self)
	FlowManager.bind_import_flow("solo_retreat_6_trigger", self)
	return

func _input_key(delta: float):
	match get_view_model():
		110:#撤退
			Global.wait_for_confirmation("solo_retreat_1", VIEW_MODEL_NAME)
		112:#对方对白
			Global.wait_for_confirmation("solo_retreat_6", VIEW_MODEL_NAME)
		114:#追击掉血
			Global.wait_for_confirmation("solo_retreat_5_chase", VIEW_MODEL_NAME)
		116:#不追击：确认已经逃掉了
			Global.wait_for_confirmation("solo_retreat_6_trigger", VIEW_MODEL_NAME)
	return

#撤退
func solo_retreat() -> void:
	var sf = DataManager.get_current_solo_fight()
	SceneManager.show_confirm_dialog("下次再分胜负", sf.currentId)
	set_view_model(110)
	return

#撤退：播放动画
func solo_retreat_1() -> void:
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()
	var node = scene.get_actor_node(sf.currentId)
	var bf = DataManager.get_current_battle_fight()
	SceneManager.show_unconfirm_dialog(" ")

	bf.set_unit_state(sf.currentId, {"将": "后退"})
	if bf.get_units_state(sf.target().actorId, "将") == "后退":
		bf.set_unit_state(sf.target().actorId, {"将": "待机"})

	node.action_retreat("solo_retreat_2")
	return

#撤退追击：对白
func solo_retreat_2() -> void:
	var sf = DataManager.get_current_solo_fight()
	SceneManager.show_confirm_dialog("无耻之徒！休走！", sf.target().actorId, 0)
	set_view_model(112)
	return
	
#撤退追击：动画
func solo_retreat_3_chase() -> void:
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()
	var node = scene.get_actor_node(sf.target().actorId)
	SceneManager.show_unconfirm_dialog(" ")
	node.action_chase("solo_retreat_4_chase")
	return

#撤退追击：扣血
func solo_retreat_4_chase() -> void:
	var sf = DataManager.get_current_solo_fight()
	var damage = Global.get_random(0, 9) + 5
	DataManager.set_env("单挑.伤害数值", damage)
	var msg = "{0}于被追击之时\n受到{1}点伤害".format([
		sf.current().get_name(), damage
	])
	SceneManager.show_confirm_dialog(msg)
	set_view_model(114)
	return

func solo_retreat_5_chase() -> void:
	var sf = DataManager.get_current_solo_fight()
	var wa = sf.current()
	var actor = wa.actor()
	var target = sf.target()
	var damage = DataManager.get_env_int("单挑.伤害数值")
	actor.set_hp(actor.get_hp() - damage)
	if actor.get_hp() <= 0:
		var msg = wa.actor_capture_to(target.wvId, "单挑", target.actorId)
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("solo_say_dead_2")
		return
	SkillHelper.auto_trigger_skill(sf.currentId, 40006)
	set_view_model(-1)
	FlowManager.add_flow("solo_run_end")
	return

#撤退不追击：对白
func solo_retreat_6() -> void:
	if Global.get_rate_result(50):
		FlowManager.add_flow("solo_retreat_3_chase")
		return

	var sf = DataManager.get_current_solo_fight()
	SceneManager.show_confirm_dialog("跑得倒是挺快!", sf.target().actorId, 0)
	set_view_model(116)
	return

func solo_retreat_6_trigger() -> void:
	var sf = DataManager.get_current_solo_fight()
	SkillHelper.auto_trigger_skill(sf.currentId, 40006)
	FlowManager.add_flow("solo_run_end")
	return
