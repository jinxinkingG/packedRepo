extends Resource
const view_model_name = "单挑-玩家-步骤";

#攻击
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	FlowManager.bind_import_flow("solo_attack",self,"solo_attack");

func _input_key(delta: float):
	return

#攻击
func solo_attack():
	var scene_solo = SceneManager.current_scene()
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
	var actorId = DataManager.solo_actor_by_side(side)
	var v_name = "战争.{0}命中".format([actorId])
	var node = scene_solo.get_actor_node(actorId)
	
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()

	var rate = wa.get_solo_accuracy_rate()
	var rateShow = wa.get_solo_accuracy_rate();#显示的命中率
	
	if wa.get_controlNo() >= 0:
		rate = DataManager.get_fix_v_rate(rate, v_name)
	elif enemy.get_controlNo() >= 0:
		if enemy.actor().get_hp() < 40 and wa.actor().get_power() < enemy.actor().get_power():
			rate /= 2;
	
	#玩家对AI攻击，保底命中率70%
	if wa.get_controlNo() >= 0 and wa.actor().get_power() > enemy.actor().get_power():
		if enemy.get_controlNo() < 0:
			rate = max(70, rate)

	var result = 1
	if not Global.get_rate_result(rate):
		result = 0
	DataManager.set_env("单挑.是否命中", 1)
	if wa.get_controlNo() >= 0:
		DataManager.set_fix_rate_v(v_name, result > 0)

	var damage = wa.get_solo_base_damege()
	DataManager.set_env("单挑.伤害数值", damage)
	# 在 get_solo_base_damage 时计算
	var criticalChance = DataManager.get_env_int("单挑.暴击率")
	DataManager.set_env("单挑.反伤", 0)

	SceneManager.show_unconfirm_dialog("{0}之攻击\n命中率：{1}%\n暴击率：{2}%".format([
		wa.get_name(), rateShow, criticalChance
	]))
	SceneManager.dialog_msg_complete(true)
	node.action_attack("solo_before_say_hurt")
	LoadControl.set_view_model(100)
	return
