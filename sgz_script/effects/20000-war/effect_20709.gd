extends "effect_20000.gd"

# 横锁触发效果
#【横锁】大战场，主动技。你为守方时才能使用：你可消耗6点机动力，指定1格水地形，标记或撤销 {横锁} 地形。每回合限1次。

const EFFECT_ID = 20709
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const ACTIVE_EFFECT_ID = 20702

func on_trigger_20042() -> bool:
	# 确认一下位置，位置有效就触发
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled or not wa.has_position():
		return false
	if not map.is_water_locked_against(wa):
		return false
	# 去除此位置标记
	map.switch_water_lock(wa.actorId, wa.position)
	ske.set_war_buff(ske.actorId, "定止", 1)
	map.draw_actors()
	return true

func effect_20709_AI_start() -> void:
	goto_step("start")
	return

func effect_20709_start() -> void:
	play_dialog(ske.actorId, "水路被阻，速速转舵！", 3, 2990)
	return
