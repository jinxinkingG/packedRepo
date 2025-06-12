extends "effect_30000.gd"

# 烈歌和力激效果
#【烈歌】小战场，锁定技。白刃战初始，你披发叫天、抗音而歌，大幅度提升你方士气，士气+4。
#【力激】小战场，锁定技。双方每次使用延迟战术的场合，你额外触发1次<烈歌>。

const VERSES = [
	"百战灭敌，天威助我！",
	"丈夫出阵，不死不回！",
	"魂兮归来，佑我江东！",
]
const MORALE_UP = 4

func on_trigger_30005() -> bool:
	shout()
	return false

func on_trigger_30008() -> bool:
	shout_on_buff()
	return false

func on_trigger_30018() -> bool:
	shout_on_buff()
	return false

func shout() -> void:
	var msg = "{0}\n（【{1}】士气 +{2}".format([
		VERSES[randi() % VERSES.size()],
		ske.skill_name, MORALE_UP,
	])
	ske.battle_change_morale(MORALE_UP)
	ske.battle_report()
	me.attach_free_dialog(msg, 0, 30000)
	return

func shout_on_buff() -> bool:
	var tacticName = DataManager.get_env_str("值")
	if not tacticName in StaticManager.CONTINUOUS_TACTICS:
		return false
	if SkillRangeBuff.max_val_for_actor("战术烈歌", actorId) <= 0:
		return false
	shout()
	return true
