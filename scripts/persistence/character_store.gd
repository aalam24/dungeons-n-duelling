class_name CharacterStore
extends RefCounted

const DIR:= "user://characters/"

static func save(sheet: CharacterSheet) -> Error:
	DirAccess.make_dir_recursive_absolute(DIR)
	if sheet.uid == "":
		sheet.uid = "%d_%06d" % [int(Time.get_unix_time_from_system()), randi() % 1000000]
	var f:= FileAccess.open(DIR + sheet.uid + ".json", FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(sheet.to_dict(), "\t"))
	return OK

static func load_all() -> Array[CharacterSheet]:
	var out: Array[CharacterSheet] = []
	if not DirAccess.dir_exists_absolute(DIR):
		return out
	for file in DirAccess.get_files_at(DIR):
		if not file.ends_with(".json"):
			continue
		var data = JSON.parse_string(FileAccess.get_file_as_string(DIR + file))
		if data is Dictionary:
			out.append(CharacterSheet.from_dict(data))
		else:
			push_warning("Skipping unreadable character file: %s" % file)
	return out
	
static func delete(sheet: CharacterSheet) -> void:
	DirAccess.remove_absolute(DIR + sheet.uid + ".json")
