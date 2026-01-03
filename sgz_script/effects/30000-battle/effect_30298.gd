extends "effect_30000.gd"

# 威断效果
#【威断】小战场，锁定技。白刃战初始，若对方武将拥有小战场技能的场合。令敌方选择一项：1.本次战斗禁用自己的小战场技能；2.本次战斗禁用自己的战术（不含主动技）。

const EFFECT_ID = 30298
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30005() -> bool:
	var battleSkills = []
	for skill in SkillHelper.get_actor_skills(enemy.actorId):
		for effect in skill.effects:
			if effect.sceneId == 30000:
				battleSkills.append(skill.name)
				break
	if battleSkills.empty():
		return false
	ske.set_battle_skill_val(battleSkills)
	return true

func effect_30298_AI_start() -> void:
	goto_step("start")
	return
	
func effect_30298_start() -> void:
	var msg = "我军威势，{0}知否\n鱼与熊掌，尔可自决\n（【{1}】发动".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		ske.skill_name,
	])
	if enemy.get_controlNo() < 0:
		# 敌方为 AI 控制，仅通知，自动选择
		SceneManager.show_confirm_dialog(msg, actorId, 0)
		LoadControl.set_view_model(2000)
	else:
		# 敌方为玩家控制，玩家选择
		msg += "，请选择："
		var options = ["放弃战术", "放弃技能"]
		SceneManager.show_yn_dialog(msg, actorId, 0, options)
		LoadControl.set_view_model(2001)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_decide")
	return

func effect_30298_decide() -> void:
	if enemy.get_controlNo() < 0:
		# 敌方为 AI 控制，自动选择
		if enemy.battle_tactic_point < 8:
			goto_step("tactic")
		else:
			goto_step("skill")
		return
	return

func on_view_model_2001() -> void:
	match wait_for_skill_option():
		0:
			goto_step("tactic")
		1:
			goto_step("skill")
	return

func effect_30298_skill() -> void:
	var battleSkills = ske.get_battle_skill_val_array()
	for skill in battleSkills:
		ske.ban_battle_skill(enemy.actorId, skill, 99999)
	ske.battle_report()
	var msg = "……\n（{0}选择禁用技能：\n【{1}】".format([
		enemy.get_name(), "】【".join(battleSkills)
	])
	enemy.attach_free_dialog(msg, 0, 30000)
	skill_end_clear()
	return

func effect_30298_tactic() -> void:
	ske.set_battle_buff(enemy.actorId, "战术禁用", 99999)
	ske.battle_report()
	var msg = "……\n（{0}选择禁用战术".format([
		enemy.get_name(),
	])
	enemy.attach_free_dialog(msg, 0, 30000)
	skill_end_clear()
	return
