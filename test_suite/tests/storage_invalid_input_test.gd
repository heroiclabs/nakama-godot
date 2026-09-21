extends "res://base_test.gd"

# The storage calls take a plain Array, so an element of the wrong type can only be
# caught at runtime. They used to skip one and carry on, which answered a batch the
# caller never asked for with a success - this checks they refuse it instead.
#
# Nothing here reaches the server. The check runs before the session is read or a
# request is built, which is the point of it: a mistake in the arguments is answered
# locally rather than by Nakama. The session below is never signed in for the same
# reason - an invalid one refreshes nothing, so it is only there for the call to hold.
#
# That is also why the exception message is asserted and not merely the exception: a
# call that let the bad element through would reach the server and come back with an
# error of its own, and that must not read as a pass.

const COLLECTION = "ACollection"
const KEY = "Question"
const NOT_AN_ID = "this is not a storage object id"
const NOT_AN_OBJECT = "this is not a write storage object"

var _session := NakamaSession.new()
var _client

func setup():
	_client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)

	# A batch with nothing of the right type in it.
	var deleted = await _client.delete_storage_objects_async(_session, [NOT_AN_ID])
	if assert_refused(deleted, NOT_AN_ID):
		return

	var read = await _client.read_storage_objects_async(_session, [NOT_AN_ID])
	if assert_cond(read is NakamaAPI.ApiStorageObjects):
		return
	if assert_refused(read, NOT_AN_ID):
		return

	var written = await _client.write_storage_objects_async(_session, [NOT_AN_OBJECT])
	if assert_cond(written is NakamaAPI.ApiStorageObjectAcks):
		return
	if assert_refused(written, NOT_AN_OBJECT):
		return

	# The case the skipping hid: a good element beside a bad one. The good one must not
	# be sent on its own and acknowledged as though it were the whole batch.
	var valid_id := NakamaStorageObjectId.new(COLLECTION, KEY)
	var valid_obj := NakamaWriteStorageObject.new(COLLECTION, KEY, 1, 1, "{}", "")

	var mixed_read = await _client.read_storage_objects_async(_session, [valid_id, NOT_AN_ID])
	if assert_refused(mixed_read, NOT_AN_ID):
		return

	var mixed_delete = await _client.delete_storage_objects_async(_session, [valid_id, NOT_AN_ID])
	if assert_refused(mixed_delete, NOT_AN_ID):
		return

	var mixed_write = await _client.write_storage_objects_async(_session, [valid_obj, NOT_AN_OBJECT])
	if assert_refused(mixed_write, NOT_AN_OBJECT):
		return

	done()

## The call was refused here, and said which element it refused. Returns true when
## it was not, so it reads like the assert_* helpers in base_test.gd.
func assert_refused(result, offender : String) -> bool:
	if assert_cond(result.is_exception()):
		return true
	return assert_cond(result.get_exception().message.contains(offender))

func _process(_delta):
	assert_time(3)
