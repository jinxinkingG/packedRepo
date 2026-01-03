extends "effect_20000.gd"

# 虚望锁定技
#【虚望】大战场，锁定技。你优先消耗等量的[望]标记数进行攻击、用计，你消耗普通机动力进行这些动作时消耗量翻倍。战争开始时，你获得50个[望]标记。

const INITIAL_WATCH_COUNT = 50
const FLAG_NAME = "望"

func on_trigger_20013()->bool:
	# 兼容 FLAG 就只能用 dict
	var setting = ske.get_war_skill_val_dic()
	if not "INIT" in setting:
		setting["INIT"] = INITIAL_WATCH_COUNT
		ske.set_war_skill_val(setting)
		ske.add_skill_flags(20000, -1, FLAG_NAME, INITIAL_WATCH_COUNT)
	# var cnt = ske.get_skill_flags(20000, -1, FLAG_NAME)
	return false

func on_trigger_20004() -> bool:
	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")

	var flags = ske.get_skill_flags(20000, -1,  FLAG_NAME)
	#for scheme in schemes:
	#	if scheme[1] <= flags:
	#		scheme[2] = "[望]"
	var msgs = Array(msg.split("\n"))
	msgs[0] = "计策优先消耗[望]"
	msgs[1] = "（当前{0}: {1}".format([FLAG_NAME, flags])
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(actorId, schemes, msg)
	return false

func on_trigger_20005() -> bool:
	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	var flags = ske.get_skill_flags(20000, -1,  FLAG_NAME)
	if flags >= cost:
		# 无须消耗机动力用计
		set_scheme_ap_cost(name, cost)
	else:
		# 用计所需机动力翻倍
		raise_scheme_ap_cost(name, cost * 2)
	return false

func on_trigger_20006() -> bool:
	var flags = ske.get_skill_flags(20000, -1,  FLAG_NAME)
	var settings = DataManager.get_env_int_array("计策.扣减")
	var cost = settings[0]
	var prev = settings[1]
	var current = settings[2]
	if cost <= flags:
		ske.cost_skill_flags(20000, -1, FLAG_NAME, cost)
		# 恢复机动力
		settings[2] = prev
		DataManager.set_env("计策.扣减", settings)
	return false

func on_trigger_20014() -> bool:
	var setting = DataManager.get_env_dict("战争.攻击消耗")
	var iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	var ap = iwa.calculate_attack_ap()
	var flags = ske.get_skill_flags(20000, -1, FLAG_NAME)
	if flags < ap:
		setting["增加"] = ap
	DataManager.set_env("战争.攻击消耗", setting)
	return false

func on_trigger_20035() -> bool:
	var cost = bf.get_env_int("机动力扣减")
	var flags = ske.get_skill_flags(20000, -1, FLAG_NAME)
	if flags >= cost:
		ske.cost_skill_flags(20000, -1, FLAG_NAME, cost)
		bf.set_env("机动力扣减", 0)
		ske.append_message("攻击不消耗机动力")
		ske.war_report()
	else:
		ske.append_message("攻击消耗更多机动力")
		ske.war_report()
	return false
