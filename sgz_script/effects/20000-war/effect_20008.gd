extends "effect_20000.gd"

#漫卷效果
#启异效果合并
#【漫卷】大战场，锁定技。你每走1步，增加1个[卷]标记，上限20个。你用计时，消耗3个[卷]替代机动力。
#【启异】大战场，锁定技。战争结束时，你可以保留一半数量的[卷]存留到下次战争。若你方存在1名以上的武将同时拥有某个技能，每有1个相同的技能，你的卷标记上限+3。

const EFFECT_ID = 20008
const QIYI_EFFECT_ID = 20009
const INITIAL_FLAG_NAME = "卷*"
const FLAG_NAME = "卷"
const COST_FLAGS = 3
const FLAG_NAME_LIMIT = "异"

func check_trigger_correct()->bool:
	match triggerId:
		20003: # 移动时
			_on_movement()
		20004: # 计策列表
			_on_scheme_menu()
		20005: # 计策执行
			_on_scheme_cost()
	return false

func _on_movement():
	if not check_env(["移动", "对白"]):
		return
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
	var limit = get_max_flag_number()
	var initial = get_initial_flag_number()
	match get_env_int("移动"):
		0: #开始或结束移动
			if get_env_int("结束移动") != 1:
				# 开始移动，记录当前标记数
				set_initial_flag_number(flags)
		1: #移动1步
			flags = min(flags + 1, limit)
		-1: #撤销1步
			flags = max(initial, flags - 1)
	update_flags(flags)
	var msg = "（[{0}]:{1}/{2}".format([FLAG_NAME, flags, limit])
	var msgs = str(get_env("对白")).split("\n")
	if msgs.size() <= 2:
		msgs.append(msg)
	elif msgs.size() == 3:
		msgs[2] = msgs[2] + "，" + msg.right(1)
	set_env("对白", "\n".join(msgs))
	return

func _on_scheme_menu():
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return false
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))

	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
	var limit = get_max_flag_number()
	for scheme in schemes:
		scheme[1] = 0
	var msgs = Array(msg.split("\n"))
	msgs[0] = "任何计策均消耗{0}卷".format([COST_FLAGS])
	msgs[1] = "(当前{0}:{1}/{2})".format([FLAG_NAME, flags, limit])
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(self.actorId, schemes, msg)
	return

func _on_scheme_cost():
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
	if flags >= COST_FLAGS:
		# 无须消耗机动力用计
		set_scheme_ap_cost("ALL", 0)
	else:
		# 不能用计
		set_scheme_ap_cost("ALL", 9999)
	if get_env_int("计策.消耗.仅对比") == 0:
		# 非对比，实际消耗
		flags = max(0, flags - COST_FLAGS)
		update_flags(flags)
	return

func update_flags(flags:int):
	SkillHelper.set_skill_flags(20000, EFFECT_ID, self.actorId, FLAG_NAME, flags)
	if SkillHelper.actor_has_skills(actorId, ["启异"]):
		SkillHelper.set_skill_flags(10000, QIYI_EFFECT_ID, self.actorId, FLAG_NAME, int(flags / 2))
	return

# 获取标记上限，支持启异
func get_max_flag_number()->int:
	var limit = SkillHelper.get_skill_flags_number(20000, QIYI_EFFECT_ID, self.actorId, FLAG_NAME_LIMIT)
	return int(max(20, limit))

# 记录在一次移动开始时的标记数，一次移动过程中，无论如何回退，都不应减到比这个值更小
# 避免开始移动时就是满 flag，移动不增加，回退反而减少的情况
func get_initial_flag_number()->int:
	var val = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, INITIAL_FLAG_NAME)
	return int(max(0, val))

# 记录在一次移动开始时的标记数，一次移动过程中，无论如何回退，都不应减到比这个值更小
# 避免开始移动时就是满 flag，移动不增加，回退反而减少的情况
func set_initial_flag_number(flags:int)->void:
	SkillHelper.set_skill_flags(20000, EFFECT_ID, self.actorId, INITIAL_FLAG_NAME, flags)
	return
