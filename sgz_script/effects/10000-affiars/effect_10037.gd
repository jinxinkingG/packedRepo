extends "effect_10000.gd"

#治典主动技
#【治典】内政，主动技。使用后，你可选择一本1~4级的书类道具进行撰写，写完存放到你方装备库。每4个月限1次。

const EFFECT_ID = 10037
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10037_start() -> void:
	var books = []
	var ids = []
	for book in clEquip.all_equips("道具"):
		if book.subtype() != "书":
			continue
		if book.level_score() < 1:
			continue
		if book.level_score() > 4:
			continue
		books.append(book.name())
		ids.append(book.id)
	SceneManager.bind_top_menu(books, ids)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func effect_10037_2() -> void:
	var id = DataManager.get_env_int("目标项")
	print(id)
	var book = clEquip.equip(id, "道具")
	print(book)
	var city = clCity.city(get_working_city_id())
	var vs = clVState.vstate(city.get_vstate_id())
	vs.add_stored_equipment(book)
	ske.affair_cd(4)
	var msg = "皓首穷经难免虚妄\n治典传世方为实务\n已抄录《{0}》一部".format([
		book.name()
	])
	play_dialog(actorId, msg, 1, 2999)
	return
