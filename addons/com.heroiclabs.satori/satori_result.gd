# Copyright 2026 The Satori Authors
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

class_name SatoriResult
extends RefCounted
## The outcome of a client call: value on success, error on failure.

## The response message, a SatoriSession for authenticate, refresh and identify calls, or null for calls without output.
var value: Variant
## Null on success.
var error: SatoriError


func _init(p_value: Variant = null, p_error: SatoriError = null) -> void:
	value = p_value
	error = p_error
