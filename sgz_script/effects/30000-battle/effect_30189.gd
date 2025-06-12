extends "effect_30000.gd"

#燕语小战场队友效果
#【燕语】大战场，锁定技，你方拥有<咆哮>技能的武将进入白刃战的场合，其发动战术挑衅时也触发<咆哮>效果。

const EFFECT_ID = 30189
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const SKILL_NAME = "咆哮"

const CD_SETTINGS = [
	[30000, 30001, "咆哮"],
	[20000, 30228, "长啸"],
	[30000, 30228, "长啸"],
	[30000, 30229, "巨喝"],
]

func effect_30189_AI_start():
	goto_step("start")
	return

func effect_30189_start():
	LoadControl.end_script()
	if not SkillHelper.player_choose_skill(ske.actorId, SKILL_NAME):
		ske.battle_set_skill_val({}, 99999, -1, ske.actorId)
		LoadControl.end_script()
	else:
		var st = SkillHelper.get_current_skill_trigger()
		if st != null:
			if me.get_controlNo() >= 0:
				st.next_flow = "tactic_end"
			else:
				st.next_flow = "unit_action"
	return

func on_trigger_30008()->bool:
	if not SkillHelper.actor_has_skills(ske.actorId, ["咆哮"]):
		return false
	# 重置默认变量
	ske.battle_set_skill_val({}, 99999, -1, ske.actorId)
	var tacticName = DataManager.get_env_str("值")
	if tacticName != "挑衅":
		return false
	var info = {"actorId": actorId, "cd":{}}
	info["cd"] = {}
	for setting in CD_SETTINGS:
		var sceneId = setting[0]
		var effectId = setting[1]
		var skillName = setting[2]
		var cd = SkillHelper.get_skill_cd(sceneId, effectId, ske.actorId, skillName)
		if cd <= 0:
			continue
		# 记录当前 CD
		if not skillName in info["cd"]:
			info["cd"][skillName] = []
		info["cd"][skillName].append([sceneId, effectId, cd])
	# 特殊判断，长啸是否可用，取决于是否「本场战斗」刚发动
	# 如果是「本场战斗」刚发动，那么大小战场 CD 应该都有值
	if "长啸" in info["cd"]:
		if info["cd"]["长啸"].size() < 2:
			# 只有一个 CD，那么长啸不应该被重置
			info["cd"].erase("长啸")
		for setting in info["cd"]["长啸"]:
			if setting[0] == 30000 and setting[2] == 1:
				info["cd"].erase("长啸")
				break
	for skillName in info["cd"]:
		for setting in info["cd"][skillName]:
			# 清除 CD
			var sceneId = setting[0]
			var effectId = setting[1]
			SkillHelper.set_skill_cd(sceneId, effectId, ske.actorId, 0, skillName)
	# 燕语自身 CD
	ske.battle_cd(99999)
	# 标记变量
	ske.battle_set_skill_val(info, 99999, -1, ske.actorId)
	return true
