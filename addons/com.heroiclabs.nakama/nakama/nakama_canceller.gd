# Copyright 2026 The Nakama Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class_name NakamaCanceller
extends RefCounted
## Cancels the calls it is passed to: the request in flight and any retry wait stop, and the call returns a
## CANCELLED error. One canceller can cancel many calls.

signal cancelled

## Read-only: call cancel(), which also stops the calls in flight.
var is_cancelled: bool:
	get:
		return _is_cancelled
	set(_value):
		push_error("is_cancelled is read-only; call cancel()")

var _is_cancelled := false


func cancel() -> void:
	if not _is_cancelled:
		_is_cancelled = true
		cancelled.emit()
