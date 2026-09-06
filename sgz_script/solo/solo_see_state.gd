extends Resource
const view_model_name = "单挑-玩家-步骤";

#查看信息
func _init() -> void:
	LoadControl.view_model_name = view_model_name
	FlowManager.bind_import_flow("solo_see_state", self)
	return

func _input_key(delta: float):
	var sf = DataManager.get_current_solo_fight()
	if not sf.running():
		return
	var scene_solo:Control = SceneManager.current_scene()
	var bottom = SceneManager.lsc_menu
	match LoadControl.get_view_model():
		100:#上下调整查看人
			var current = DataManager.get_env_int("武将")
			var actor = ActorHelper.actor(current)
			var conEquipInfo = SceneManager.conEquipInfo
			conEquipInfo.rect_position.y = 289
			conEquipInfo.show()
			var equipTypeIdx = DataManager.get_env_int("装备信息.类型号")
			var equipType = StaticManager.EQUIPMENT_TYPES[equipTypeIdx]
			conEquipInfo.show_equipinfo(actor.get_equip(equipType), "info")

			# 切换查看的装备类型
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				equipTypeIdx -= 1
				if equipTypeIdx < 0:
					equipTypeIdx = StaticManager.EQUIPMENT_TYPES.size() - 1
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				equipTypeIdx = (equipTypeIdx + 1) % StaticManager.EQUIPMENT_TYPES.size()
			DataManager.set_env("装备信息.类型号", equipTypeIdx)

			# 切换武将
			if Input.is_action_just_pressed("ANALOG_UP") \
				or Input.is_action_just_pressed("ANALOG_DOWN"):
				for actorId in [sf.leftId, sf.rightId]:
					if actorId == current:
						continue
					DataManager.set_env("武将", actorId)
					SceneManager.show_actor_info(actorId)
					return

			if Global.is_action_pressed_BY():
				FlowManager.add_flow("solo_player_ready")
	return

#查看武将状态
func solo_see_state():
	var sf = DataManager.get_current_solo_fight()
	DataManager.set_env("武将", sf.currentId)
	DataManager.set_env("装备信息.类型号", 0)
	SceneManager.show_actor_info(sf.currentId)
	LoadControl.set_view_model(100)
	return

