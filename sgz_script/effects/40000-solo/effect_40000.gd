extends "res://script/effects_base.gd"

# 初始化局部变量，应在 _init() 中调用
func init_vars():
	ske = SkillHelper.read_skill_effectinfo()
	if ske != null:
		actorId = ske.skill_actorId
		triggerId = ske.trigger_Id
		actor = ActorHelper.actor(actorId)
		me = ske.get_war_actor()
		if me != null:
			enemy = me.get_battle_enemy_war_actor()
			if enemy != null:
				enemyActor = ActorHelper.actor(enemy.actorId)
	wf = DataManager.get_current_war_fight()
	bf = DataManager.get_current_battle_fight()
	return

#获取单挑行为
func get_solo_action():
	return int(DataManager.common_variable["单挑.行为"]);

#获取当前单挑经过的回合数
func _get_solo_turn():
	if(!DataManager.common_variable.has("单挑.回合数")):
		DataManager.common_variable["单挑.回合数"]=0;
	return int(DataManager.common_variable["单挑.回合数"]);

# 信息发动后的结果确认
func wait_for_skill_result_confirmation(nextFlow:String="player_ready"):
	if Global.is_action_pressed_AX():
		if not SceneManager.dialog_msg_complete(true):
			return
		LoadControl.set_view_model(-1)
		if nextFlow == "":
			LoadControl.end_script()
		else:
			FlowManager.add_flow(nextFlow)
	return
