extends "effect_30000.gd"

#长啸主动技
#【长啸】小战场，主动技。发动后视为你使用[挑衅]，并对敌方每个士兵单位造成X点伤害(X=4+你的等级*2)。每个大战场回合限1次。

const EFFECT_ID = 30228
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const YANYU_EFFECT_ID = 30189

# AI 是否可发动
func check_AI_perform()->bool:
	# 只要体力够就发动
	return actor.get_hp() >= 50

# AI 发动
func effect_30228_AI_start():
	_process_skill_cd()
	var msg = _get_skill_msg()
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(3000)
	return

func on_view_model_3000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2", false)
	return

func effect_30228_AI_2():
	var damaged = _damage_to_enemy_soldiers()
	if damaged <= 0:
		goto_step("3")
		return
	var msg = "{0}部心胆俱裂\n损兵 {1}".format([
		enemy.get_name(), damaged,
	])
	SceneManager.show_confirm_dialog(msg, me.actorId, 1)
	LoadControl.set_view_model(2001)
	return

func effect_30228_start():
	var msg = _get_skill_msg()
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func effect_30228_2():
	_process_skill_cd()
	var damaged = _damage_to_enemy_soldiers()
	if damaged <= 0:
		goto_step("3")
		return
	var msg = "{0}部心胆俱裂\n损兵 {1}".format([
		enemy.get_name(), damaged
	])
	SceneManager.show_confirm_dialog(msg, me.actorId, 1)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3", false)
	return

func effect_30228_3():
	if bf.solo_disabled():
		tactic_end()
		return
	if enemy.get_controlNo() < 0:
		var enemyActor = ActorHelper.actor(enemy.actorId)
		#新挑衅成功率=体%武%胆%
		DataManager.set_env(KEY_RESULTS, 1)
		var rate = max(0, enemyActor.get_hp() * enemyActor.get_power() * enemyActor.get_courage() / 10000)
		if not Global.get_rate_result(rate):
			DataManager.set_env(KEY_RESULTS, 0)
		ske.battle_set_skill_val({}, 99999, YANYU_EFFECT_ID, actorId)
		LoadControl.end_script()
		DataManager.set_env("当前武将", me.actorId)
		FlowManager.add_flow("load_script|battle/player_tactic.gd");
		FlowManager.add_flow("tactic_impact_1");
	else:
		var msg = "{0}挑衅，是否应战？".format([me.get_name()])
		SceneManager.show_yn_dialog(msg, enemy.actorId, 0)
		# 禁用玩家正常响应，技能处理
		# 有点 trick, FIXME later
		DataManager.set_env("白兵战-玩家-步骤", -1)
		ske.battle_set_skill_val({}, 99999, YANYU_EFFECT_ID, actorId)
		LoadControl.set_view_model(3002)
	return

func on_view_model_3002()->void:
	var option = wait_for_skill_option()
	match option:
		0:
			LoadControl.end_script()
			FlowManager.add_flow("go_to_solo");
		1:
			LoadControl.set_view_model(-1)
			goto_step("rejected")
	return

func effect_30228_rejected():
	var bf = DataManager.get_current_battle_fight()
	bf.reject_solo_request(enemy.actorId, "")
	LoadControl.end_script()
	FlowManager.add_flow("unit_action")
	return

func _damage_to_enemy_soldiers()->int:
	var damaged = 0
	var level = actor.get_level()
	var affected = []
	var x = 4 + level * 2
	for unit in DataManager.battle_units:
		if unit == null or unit.disabled:
			continue
		if unit.leaderId != enemy.actorId:
			continue
		if unit.get_unit_type() in ["将", "城门"]:
			continue
		#每个敌方士兵受到 X 伤害
		damaged += -ske.battle_change_unit_hp(unit, -x)
	ske.battle_report()
	return damaged

func _process_skill_cd()->void:
	var info = ske.battle_get_skill_val_dic(YANYU_EFFECT_ID, actorId)
	if info.empty():
		# 正常发动
		ske.battle_cd(99999)
		ske.cost_war_cd(1)
	else:
		# 燕语发动
		# 只处理自己的 CD 重置
		if ske.skill_name in info["cd"]:
			for setting in info["cd"][ske.skill_name]:
				var sceneId = setting[0]
				var effectId = setting[1]
				var cd = setting[2]
				SkillHelper.set_skill_cd(sceneId, effectId, actorId, cd, ske.skill_name)
	return

func _get_skill_msg()->String:
	var msg = "{0}在此!\n谁敢与我大战三百回合!".format([
		DataManager.get_actor_self_title(actorId)
	])
	var info = ske.battle_get_skill_val_dic(YANYU_EFFECT_ID, actorId)
	var yanyuActorId = Global.dic_val_int(info, "actorId")
	if yanyuActorId >= 0:
		msg += "\n（{0}【燕语】触发【{1}】".format([
			ActorHelper.actor(yanyuActorId).get_name(),
			ske.skill_name,
		])
	return msg
