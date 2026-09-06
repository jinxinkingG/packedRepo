extends Resource

#牵制攻击
func _init() -> void:
	FlowManager.bind_import_flow("solo_light_attack", self)
	return

#牵制
func solo_light_attack() -> void:
	var sf = DataManager.get_current_solo_fight()
	var scene_solo = SceneManager.current_scene()

	var wa = sf.current()
	var node = scene_solo.get_actor_node(wa.actorId)

	DataManager.set_env("单挑.是否命中", 1)
	var baseDamage = wa.get_solo_base_damege()
	var damage = int(baseDamage/3)
	DataManager.set_env("单挑.伤害数值", damage)
	# 在 get_solo_base_damage 时计算
	var criticalChance = DataManager.get_env_int("单挑.暴击率")
	DataManager.set_env("单挑.反伤", 0)

	SceneManager.show_unconfirm_dialog("{0}之牵制攻击\n命中率：100%\n暴击率：{1}%".format([
		wa.get_name(), criticalChance,
	]))
	SceneManager.dialog_msg_complete(true)
	node.action_light_attack("solo_before_say_hurt")
	return
