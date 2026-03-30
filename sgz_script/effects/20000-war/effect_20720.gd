extends "effect_20000.gd"

# 甘露主动技（吴国太专属）
#【甘露】主动技。指定全场任意1名具有主动技能的武将为目标发动。你发动目标身上一个可以被你发动的主动技；该目标是敌将时，至己方第3回合结束前，己方将领不能将目标作为攻击和主动技能的目标。每5回合限一次。

const EFFECT_ID = 20720
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const CD_TURNS = 5
const BUFF_NAME = "借露"
const BUFF_TURNS = 3

# 收集全场可借用主动技的武将
func _get_borrowable_targets() -> Array:
	# ret = [[targetId, [skillName, ...]]]
	var ret = []
	# wf.get_war_actors 包含全场所有势力的武将
	for wa in wf.get_war_actors(false, true):
		if wa.actorId == actorId:
			continue
		var skills = _get_borrowable_skills(wa.actorId)
		if not skills.empty():
			ret.append([wa.actorId, skills])
	return ret

# 获取指定武将身上可被甘露借用的主动技列表
func _get_borrowable_skills(targetId:int) -> PoolStringArray:
	var ret = []
	for skillStatus in SkillHelper.get_actor_war_skills(targetId):
		if not skillStatus["主动"]:
			# 是主动技就行，目标是不是可用，反而不重要
			continue
		if _can_borrow_skill(skillStatus["名称"]):
			ret.append(skillStatus["名称"])
	return ret

# 检查一个技能是否可被借用
func _can_borrow_skill(skillName:String) -> bool:
	var skill = StaticManager.get_skill(skillName)
	if skill == null:
		return false
	if skill.has_feature("限定"):
		return false
	var st = SkillHelper.get_actor_war_skill_status(wf, me, skill)
	if not st["主动"] or not st["可用"]:
		return false
	return true

func effect_20720_start() -> void:
	var targets = _get_borrowable_targets()
	if targets.empty():
		play_dialog(actorId, "没有可借用主动技的目标", 3, 2999)
		return
	# 存储完整的目标数据供后续使用
	var targetIds = []
	var targetData = {}
	for t in targets:
		targetIds.append(t[0])
		targetData[t[0]] = t[1]
	DataManager.set_env("甘露.目标数据", targetData)
	if not wait_choose_actors(PoolIntArray(targetIds), "对何人发动{0}?", true, false):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_target_selected")
	return

func effect_20720_target_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetData = DataManager.get_env_dict("甘露.目标数据")
	var skills = Global.arrval(targetData[targetId])
	if skills.size() == 1:
		# 只有一个技能，直接进入确认
		set_env("甘露.选中技能", skills[0])
		_show_confirm()
		return
	# 多个技能，显示选择菜单
	var items = PoolStringArray(skills)
	var values = skills
	bind_menu_items(items, values)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_skill(FLOW_BASE + "_skill_selected", true, true)
	return

func effect_20720_skill_selected() -> void:
	var selectedSkill = DataManager.get_env_str("目标项")
	set_env("甘露.选中技能", selectedSkill)
	_show_confirm()
	return

func _show_confirm() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var selectedSkill = get_env_str("甘露.选中技能")
	var targetWA = DataManager.get_war_actor(targetId)
	var isEnemy = me.is_enemy(targetWA)
	var msg = "借用{0}的【{1}】？".format([
		targetActor.get_name(), selectedSkill,
	])
	if isEnemy:
		msg += "\n（目标为敌将\n（将附加{0}回合[{1}]".format([
			BUFF_TURNS, BUFF_NAME,
		])
	play_dialog(actorId, msg, 2, 2002, true)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20720_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var selectedSkill = get_env_str("甘露.选中技能")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)

	# 消耗 CD
	ske.cost_war_cd(CD_TURNS)

	# 敌将时附加甘露保护
	if me.is_enemy(targetWA):
		ske.set_war_buff(targetId, BUFF_NAME, BUFF_TURNS)
		ske.war_report()
		var msg = "借君一枝，如见东海\n（借用{0}的【{1}】\n（附加{2}回合[{3}]".format([
			targetActor.get_name(), selectedSkill,
			BUFF_TURNS, BUFF_NAME,
		])
		play_dialog(actorId, msg, 0, 2003)
	else:
		ske.war_report()
		var msg = "借君一枝，如见东海\n（借用{0}的【{1}】".format([
			targetActor.get_name(), selectedSkill,
		])
		play_dialog(actorId, msg, 0, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_execute")
	return

func effect_20720_execute() -> void:
	var selectedSkill = get_env_str("甘露.选中技能")
	# 清理环境变量
	DataManager.unset_env("甘露.目标数据")
	DataManager.unset_env("甘露.选中技能")
	# 直接构造借用技能的执行流程，绕过 player_choose_skill 中的专属/性别检查
	var skill = StaticManager.get_skill(selectedSkill)
	if skill == null:
		return
	for effect in skill.effects:
		if effect.sceneId != 20000:
			continue
		if effect.type != "主动":
			continue
		ske.add_war_skill(actorId, skill.name, 1, false, true)
		var newSke = effect.create_ske_for(actorId)
		SkillHelper.save_skill_effectinfo(newSke)
		DataManager.player_choose_skill = skill.name
		LoadControl.end_script()
		LoadControl.load_script(effect.path)
		FlowManager.add_flow("effect_{0}_start".format([effect.id]))
		return
	return

func check_AI_perform_20000() -> bool:
	return false
