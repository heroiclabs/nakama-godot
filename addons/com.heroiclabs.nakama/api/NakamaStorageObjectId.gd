extends Reference
class_name NakamaStorageObjectId

### <summary>
### The collection which stores the object.
### </summary>
var collection : String

### <summary>
### The key of the object within the collection.
### </summary>
var key : String

### <summary>
### The user owner of the object.
### </summary>
var user_id : String

### <summary>
### The version hash of the object.
### </summary>
var version : String

func _init(p_collection, p_key, p_user_id = "", p_version = ""):
	collection = p_collection
	key = p_key
	user_id = p_user_id
	version = p_version

func as_delete():
	return NakamaAPI.ApiDeleteStorageObjectId.create(NakamaAPI, {
		"collection": collection,
		"key": key,
		"version": version
	})

func as_read():
	return NakamaAPI.ApiReadStorageObjectId.create(NakamaAPI, {
		"collection": collection,
		"key": key,
		"user_id": user_id
	})
