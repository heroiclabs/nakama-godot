extends "res://base_test.gd"

const COLLECTION = "ACollection"
const K1 = "Question"
const K2 = "Answer"
const V1 = {"question": "Ultimate question"}
const V2 = {"answer": "42"}

func setup() -> void:
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)

	var auth: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null):
		return
	var session: NakamaSession = auth.value

	var objs: Array[NakamaTypes.WriteStorageObject] = []
	for pair: Array in [[K1, V1], [K2, V2]]:
		var key: String = pair[0]
		var obj := NakamaTypes.WriteStorageObject.new(COLLECTION, key, JSON.stringify(pair[1]), "", 1, 1)
		objs.append(obj)
	var write: NakamaResult = await client.write_storage_objects_async(session, objs)
	if assert_cond(write.error == null):
		return

	var read_ids: Array[NakamaTypes.ReadStorageObjectId] = []
	var delete_ids: Array[NakamaTypes.DeleteStorageObjectId] = []
	var acks: NakamaTypes.StorageObjectAcks = write.value
	for a: NakamaTypes.StorageObjectAck in acks.acks:
		var read_id := NakamaTypes.ReadStorageObjectId.new(a.collection, a.key, a.user_id)
		read_ids.append(read_id)
		var delete_id := NakamaTypes.DeleteStorageObjectId.new(a.collection, a.key, a.version)
		delete_ids.append(delete_id)

	var read: NakamaResult = await client.read_storage_objects_async(session, read_ids)
	if assert_cond(read.error == null):
		return
	var objects: NakamaTypes.StorageObjects = read.value
	if assert_equal(objects.objects.size(), 2):
		return
	var first: NakamaTypes.StorageObject = objects.objects[0]
	if assert_equal(first.collection, COLLECTION):
		return
	if assert_cond(first.key in [K1, K2]):
		return
	if assert_cond(JSON.stringify(JSON.parse_string(first.value)) in [JSON.stringify(V1), JSON.stringify(V2)]):
		return

	var del: NakamaResult = await client.delete_storage_objects_async(session, [delete_ids[0]])
	if assert_cond(del.error == null):
		return

	var read2: NakamaResult = await client.read_storage_objects_async(session, read_ids)
	if assert_cond(read2.error == null):
		return
	var objects2: NakamaTypes.StorageObjects = read2.value
	if assert_equal(objects2.objects.size(), 1):
		return
	var remaining: NakamaTypes.StorageObject = objects2.objects[0]
	if assert_equal(remaining.collection, COLLECTION):
		return
	if assert_equal(remaining.key, read_ids[1].key):
		return
	if assert_cond(JSON.stringify(JSON.parse_string(remaining.value)) in [JSON.stringify(V1), JSON.stringify(V2)]):
		return
	done()
	return

func _process(_delta: float) -> void:
	assert_time(3)
