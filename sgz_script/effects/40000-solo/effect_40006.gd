extends "effect_40000.gd"

# 斧手单挑效果
#【斧手】小战场，锁定技。战争开始时，你有 500 {斧手}。白刃战主将被攻击，进入单挑时，若你的 {斧手} 数量大于 0，你率 {斧手} 掩护主将撤出战斗，并与敌将开始白刃战。每日限1次。\n现有斧手：<var:1:0>。

const EFFECT_ID = 40006
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const WAR_EFFECT_ID = 20688

func on_trigger_40011() -> bool:
	if ske.actorId != me.get_main_actor_id():
		return false
	if ske.actorId != bf.get_defender_id():
		return false
	var soldiers = ske.get_war_skill_val_int_array(WAR_EFFECT_ID)
	return soldiers.size() == 2 and soldiers[1] > 0

func effect_40006_AI_start() -> void:
	goto_step("start")
	return

func effect_40006_start() -> void:
	var leader = DataManager.get_war_actor(ske.actorId)
	var enemy = leader.get_battle_enemy_war_actor()
	var msg = "{0}！某在此久侯了\n{1}且退\n（【{2}】掩护撤出单挑".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		DataManager.get_actor_honored_title(leader.actorId, actorId),
		ske.skill_name,
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_40006_confirmed() -> void:
	var leader = DataManager.get_war_actor(ske.actorId)
	var enemy = leader.get_battle_enemy_war_actor()
	ske.cost_war_cd(1)
	# 清理掉后续流程，中断单挑处理
	skill_end_clear(true)

	SceneManager.black.show()

	FlowManager.clear_pre_history.clear()

	# 强制退出单挑
	FlowManager.clear_bind_method()
	var sf = DataManager.get_current_solo_fight()
	sf.finish()

	# 强制退出战斗
	# 以下是模拟战斗结果并复制 battle_over 逻辑
	# TODO 未来需要抽象出来共用
	# copy paste 不行
	bf.loserId = ske.actorId
	bf.lostType = BattleFight.ResultEnum.ActorRetreat

	bf.battle_over()
	wf.battle_over()
	SceneManager.hide_all_tool()

	# 强制回到大战场
	FlowManager.add_flow("go_to_scene|res://scene/scene_war/scene_war.tscn")
	# TODO, 非常恶心的实现，但好像没辙
	DataManager.set_env("战争.斧手.环境", ske.output_data())
	DataManager.set_env("战争.斧手.目标", enemy.actorId)
	var st = SkillHelper.get_current_skill_trigger()
	st.temp_code_gd.append(DataManager.mod_path + "sgz_script/war/war_auto_run.gd")
	st.next_flow = "back_to_war"
	return
