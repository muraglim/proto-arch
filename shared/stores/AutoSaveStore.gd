class_name AutoSaveStore
extends PersistentStore

func set_value(key: String, value: Variant) -> void:
	super.set_value(key, value)
	save()
