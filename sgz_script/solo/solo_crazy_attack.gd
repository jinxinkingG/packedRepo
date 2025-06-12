extends Resource
const view_model_name = "单挑-玩家-步骤";

#舍命一击
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	FlowManager.bind_import_flow("solo_crazy_attack",self,"solo_crazy_attack");
	
func _input_key(delta: float):
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		100:
			pass

#舍命一击
func solo_crazy_attack():
	var scene_solo = SceneManager.current_scene()
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
	var actorId = DataManager.solo_actor_by_side(side)
	var node = scene_solo.get_actor_node(actorId)
	
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()

	var rate = 30
	var rateShow = rate
	if wa.get_controlNo() < 0:
		if enemy.actor().get_hp() < 40:
			rate /= 2

	var result = 0
	if Global.get_rate_result(rate):
		result = 1
	DataManager.set_env("单挑.是否命中", result)
	var baseDamage = wa.get_solo_base_damege()
	var damage = baseDamage * 2
	DataManager.set_env("单挑.伤害数值", damage)
	# 在 get_solo_base_damage 时计算
	var criticalChance = DataManager.get_env_int("单挑.暴击率")

	var selfDamage = 0
	if result == 0 and not Global.get_rate_result(30):
		# 舍命一击失败要扣血
		selfDamage = Global.get_random(0, 20) + 10
	DataManager.set_env("单挑.反伤", selfDamage)

	SceneManager.show_unconfirm_dialog("{0}之舍命一击\n命中率：{1}%\n暴击率：{2}%".format([
		wa.get_name(), rateShow, criticalChance,
	]));
	SceneManager.dialog_msg_complete(true)
	node.action_crazy_attack("solo_before_say_hurt")
	LoadControl.set_view_model(100)
	return
