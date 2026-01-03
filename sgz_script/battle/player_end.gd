extends Resource

const view_model_name = "白兵战-玩家-步骤";

func _init() -> void:
	LoadControl.view_model_name = view_model_name
	FlowManager.bind_import_flow("battle_player_end", self)
	FlowManager.bind_import_flow("battle_player_end_retreat", self)
	FlowManager.bind_import_flow("battle_player_end_retreat_2", self)
	FlowManager.bind_import_flow("battle_player_end_capture", self)
	FlowManager.bind_import_flow("battle_player_end_surrent", self)
	return

func _input_key(delta: float):
	match LoadControl.get_view_model():
		11:#确认逃跑
			Global.wait_for_confirmation("battle_player_end_retreat_2")
		12:#确认逃跑掉血
			if not Global.wait_for_confirmation(""):
				return
			var bf = DataManager.get_current_battle_fight()
			if bf.lostType == BattleFight.ResultEnum.ActorDead:
				FlowManager.add_flow("battle_player_end_capture")
			else:
				FlowManager.add_flow("battle_over")
		13:#确认被俘虏
			Global.wait_for_confirmation("battle_over")
		14:#确认投降
			Global.wait_for_confirmation("battle_over")
	return

func battle_player_end():
	var bf = DataManager.get_current_battle_fight()
	# 战斗结束前技能触发，不支持回调
	SkillHelper.auto_trigger_skill(bf.get_attacker_id(), 30098, "")
	SkillHelper.auto_trigger_skill(bf.get_defender_id(), 30098, "")
	match bf.lostType:
		BattleFight.ResultEnum.ActorDead:
			FlowManager.add_flow("battle_player_end_capture")
		BattleFight.ResultEnum.ActorRetreat:
			# 撤退损兵逻辑放在这里处理
			FlowManager.add_flow("battle_player_end_retreat")
		BattleFight.ResultEnum.ActorSurrend:
			FlowManager.add_flow("battle_player_end_surrent")
		BattleFight.ResultEnum.NoMind:
			FlowManager.add_flow("battle_over")
	LoadControl.set_view_model(10)
	return

#白兵逃跑
func battle_player_end_retreat():
	var bf = DataManager.get_current_battle_fight()
	bf.clear_pending_actions()
	var loser = bf.get_loser()
	var msg = "{0}逃跑了！".format([loser.get_name()])
	bf.retreat_cost_soldiers()
	if bf.retreatLostSoldier > 0:
		msg += "\n士兵逃亡{0}人！".format([bf.retreatLostSoldier])
	var extra = bf.get_env_str("撤退损兵说明.{0}".format([loser.actorId]))
	if extra != "":
		msg += "\n" + extra
	if bf.lostRice > 0:
		var winner = loser.get_battle_enemy_war_actor()
		msg += "\n{0}趁势掩杀，焚粮{1}".format([
			winner.get_name(), bf.lostRice
		])
	SoundManager.play_se2("res://resource/sounds/se/horse_run.ogg")
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(11)
	return

#白兵逃跑扣血
func battle_player_end_retreat_2():
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		FlowManager.add_flow("battle_over")
		return
	# 逃跑减体，简单复用损兵的判断，如果不损粮，就不损体
	var hp = bf.retreat_lost_hp()
	if hp > 0:
		var msg = "{0}于被追击时\n受到{1}点伤害".format([loser.get_name(), hp])
		SceneManager.show_confirm_dialog(msg)
		LoadControl.set_view_model(12)
		return
	FlowManager.add_flow("battle_over")
	return

#白兵武将被俘虏收监(原为死亡)
func battle_player_end_capture():
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		FlowManager.add_flow("battle_over")
		return
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		FlowManager.add_flow("battle_over")
		return
	var msg = loser.get_name() + loser.actor_capture_to(winner.wvId, "白兵", winner.actorId)
	SceneManager.current_scene().bgm = false
	SoundManager.play_anim_bgm("res://resource/sounds/bgm/solo_dead.ogg")
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(13)
	return

#白兵武将投降（保留方块）
func battle_player_end_surrent():
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		FlowManager.add_flow("battle_over")
		return
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		FlowManager.add_flow("battle_over")
		return
	loser.actor_surrend_to(winner.wvId)
	var msg = loser.get_name() + "投降了"
	SceneManager.current_scene().bgm = false
	SoundManager.play_anim_bgm("res://resource/sounds/bgm/solo_surrend.ogg")
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(14)
	return
