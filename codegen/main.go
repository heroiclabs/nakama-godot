// Copyright 2018 The Nakama Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"text/template"
)

var utilities = map[string]string {
	"ApiAccount":
`

	var _wallet_dict = null
	var wallet_dict : Dictionary:
		get:
			if _wallet_dict == null:
				if _wallet == null:
					return {}
				var json = JSON.new()
				if json.parse(_wallet) != OK:
					return {}
				_wallet_dict = json.get_data()
			return _wallet_dict as Dictionary
`,
}

const codeTemplate string = `### Code generated by codegen/main.go. DO NOT EDIT. ###

extends RefCounted
class_name NakamaAPI
{{- range $defname, $definition := .Definitions }}
{{- $classname := $defname | title }}
{{- if isRefToEnum $classname }}

# {{ enumSummary $definition | stripNewlines }}
{{- range $idx, $val := ($definition | enumDescriptions) }}
# {{ $val }}
{{- end -}}
# {{ $definition | enumDescriptions }}
enum {{ $classname | title }} { {{- range $idx, $enum := $definition.Enum }}{{ $enum }} = {{ $idx }},{{- end -}} }
{{- else }}

# {{ $definition.Description | stripNewlines }}
class {{ $classname }} extends NakamaAsyncResult:

	const _SCHEMA = {
		{{- range $propname, $property := $definition.Properties }}
		{{- $fieldname := $propname | pascalToSnake }}
		{{- $_field := printf "_%s" $fieldname }}
		{{- $gdType := godotType $property.Type $property.Ref $property.Items.Type $property.Items.Ref (isRefToEnum (cleanRef $property.Ref)) }}
		"{{ $fieldname }}": {"name": "{{ $_field }}", "type": {{ $gdType | godotSchemaType }}, "required": false
		{{- if eq $property.Type "array" -}}
			, "content": {{ (godotType $property.Items.Type $property.Items.Ref "" "" false) | godotSchemaType }}
		{{- else if eq $property.Type "object" -}}
			, "content": {{ (godotType $property.AdditionalProperties.Type "" "" "" false) | godotSchemaType  }}
		{{- end -}}
		},
		{{- end }}
	}

        {{- range $propname, $property := $definition.Properties }}
        {{- $fieldname := $propname | pascalToSnake }}
        {{- $_field := printf "_%s" $fieldname }}
        {{- $gdType := godotType $property.Type $property.Ref $property.Items.Type $property.Items.Ref (isRefToEnum (cleanRef $property.Ref)) }}
	{{- $gdDef := $gdType | godotDef }}

	# {{ $property.Description }}
	var {{ $_field }}
	var {{ $fieldname }} : {{ $gdType }}:
		get:
			{{- if $property.Ref }}
			{{- if isRefToEnum (cleanRef $property.Ref) }}{{/* Enums */}}
			return {{ cleanRef $property.Ref }}.values()[0] if not {{ cleanRef $property.Ref }}.values().has({{ $_field }}) else {{ $_field }}
			{{- else }}{{/* Object reference */}}
			return _{{ $fieldname }} as {{ $gdType }}
			{{- end }}
			{{- else if eq $property.Type "object"}}{{/* Dictionaries */}}
			return Dictionary() if not {{ $_field }} is Dictionary else {{ $_field }}.duplicate()
			{{- else }}{{/* Simple type */}}
			return {{ $gdDef }} if not {{ $_field }} is {{ $gdType }} else {{ $gdType }}({{ $_field }})
			{{- end }}
			{{- end }}

	{{- godotClassUtils $classname }}

	func _init(p_exception = null):
		super(p_exception)

	static func create(p_ns : GDScript, p_dict : Dictionary) -> {{ $classname }}:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "{{ $classname }}", p_dict), {{ $classname }}) as {{ $classname }}

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string() -> String:
		if is_exception():
			return get_exception()._to_string()
		var output : String = ""
            {{- range $propname, $property := $definition.Properties }}
            {{- $fieldname := $propname | pascalToSnake }}
            {{- $_field := printf "_%s" $fieldname }}
            {{- if eq $property.Type "array" }}
		output += "{{ $fieldname }}: %s, " % [{{ $_field }}]
            {{- else if eq $property.Type "object" }}
		var map_string : String = ""
		if typeof({{ $_field }}) == TYPE_DICTIONARY:
			for k in {{ $_field }}:
				map_string += "{%s=%s}, " % [k, {{ $_field }}[k]]
		output += "{{ $fieldname }}: [%s], " % map_string
            {{- else }}
		output += "{{ $fieldname }}: %s, " % {{ $_field }}
            {{- end }}
            {{- end }}
		return output
    {{- end }}
{{- end }}

# The low level client for the Nakama API.
class ApiClient extends RefCounted:

	var _base_uri : String

	var _http_adapter
	var _namespace : GDScript
	var _server_key : String
	var auto_refresh := true
	var auto_refresh_time := 300

	var auto_retry : bool:
		set(p_value):
			_http_adapter.auto_retry = p_value
		get:
			return _http_adapter.auto_retry

	var auto_retry_count : int:
		set(p_value):
			_http_adapter.auto_retry_count = p_value
		get:
			return _http_adapter.auto_retry_count

	var auto_retry_backoff_base : int:
		set(p_value):
			_http_adapter.auto_retry_backoff_base = p_value
		get:
			return _http_adapter.auto_retry_backoff_base

	var last_cancel_token:
		get:
			return _http_adapter.get_last_token()

	func _init(p_base_uri : String, p_http_adapter, p_namespace : GDScript, p_server_key : String, p_timeout : int = 10):
		_base_uri = p_base_uri
		_http_adapter = p_http_adapter
		_http_adapter.timeout = p_timeout
		_namespace = p_namespace
		_server_key = p_server_key

	func _refresh_session(p_session : NakamaSession):
		if auto_refresh and p_session.is_valid() and p_session.refresh_token and not p_session.is_refresh_expired() and p_session.would_expire_in(auto_refresh_time):
			var request = ApiSessionRefreshRequest.new()
			request._token = p_session.refresh_token
			return await session_refresh_async(_server_key, "", request)
		return null

	func cancel_request(p_token):
		if p_token:
			_http_adapter.cancel_request(p_token)

        {{- range $url, $path := .Paths }}
        {{- range $method, $operation := $path}}

	# {{ $operation.Summary | stripNewlines }}
        {{- if $operation.Responses.Ok.Schema.Ref }}
	func {{ $operation.OperationId | apiFuncName }}_async(
        {{- else }}
	func {{ $operation.OperationId | apiFuncName }}_async(
        {{- end}}

        {{- if $operation.Security }}
        {{- with (index $operation.Security 0) }}
            {{- range $key, $value := . }}
                {{- if eq $key "BasicAuth" }}
		p_basic_auth_username : String
		, p_basic_auth_password : String
                {{- else if eq $key "HttpKeyAuth" }}
		p_bearer_token : String
                {{- end }}
            {{- end }}
        {{- end }}
        {{- else }}
		p_session : NakamaSession
        {{- end }}

        {{- range $parameter := $operation.Parameters }}
        {{- $argument := $parameter.Name | prependParameter }}
	{{- if not $parameter.Required }}{{/* Godot does not support typed optional parameters yet. */}}
		, {{ $argument }} = null # : {{ $parameter.Type }}
        {{- else if eq $parameter.In "body" }}
            {{- if eq $parameter.Schema.Type "string" }}
		, {{ $argument }} : String
            {{- else }}
		, {{ $argument }} : {{ $parameter.Schema.Ref | cleanRef }}
            {{- end }}
        {{- else }}
		, {{ $argument }} : {{ godotType $parameter.Type $parameter.Schema.Ref $parameter.Items.Type "" (isRefToEnum (cleanRef $parameter.Schema.Ref)) }}
        {{- end }}
	{{- end }}
	)
	{{- if $operation.Responses.Ok.Schema.Ref }} -> {{ $operation.Responses.Ok.Schema.Ref | cleanRef }}
	{{- else }} -> NakamaAsyncResult
	{{- end }}:
        {{- $classname := "NakamaAsyncResult" }}
        {{- if $operation.Responses.Ok.Schema.Ref }}
          {{- $classname = $operation.Responses.Ok.Schema.Ref | cleanRef }}
        {{- end }}
        {{- if not $operation.Security }}
		var try_refresh = await _refresh_session.call(p_session)
		if try_refresh != null:
			if try_refresh.is_exception():
				return {{ $classname }}.new(try_refresh.get_exception())
			await p_session.refresh(try_refresh)
        {{- end }}
		var urlpath : String = "{{- $url }}"
            {{- range $parameter := $operation.Parameters }}
            {{- $argument := $parameter.Name | prependParameter }}
            {{- if eq $parameter.In "path" }}
		urlpath = urlpath.replace("{{- print "{" $parameter.Name "}"}}", NakamaSerializer.escape_http({{ $argument }}))
            {{- end }}
            {{- end }}
		var query_params = ""
            {{- range $parameter := $operation.Parameters }}
            {{- $argument := $parameter.Name | prependParameter }}
            {{- $snakecase := $parameter.Name | pascalToSnake }}
            {{- if eq $parameter.In "query"}}
            {{- if $parameter.Required }}
		if true: # Hack for static checks
            {{- else }}
		if {{ $argument }} != null:
            {{- end }}
                {{- if eq $parameter.Type "integer" }}
			query_params += "{{- $snakecase }}=%d&" % {{ $argument }}
                {{- else if eq $parameter.Type "string" }}
			# Work around issue #53115 / #56217
			var tmp = {{ $argument }}
			tmp = tmp
			query_params += "{{- $snakecase }}=%s&" % NakamaSerializer.escape_http(tmp)
			#query_params += "{{- $snakecase }}=%s&" % NakamaSerializer.escape_http({{ $argument }})
                {{- else if eq $parameter.Type "boolean" }}
			query_params += "{{- $snakecase }}=%s&" % str({{ $argument }}).to_lower()
                {{- else if eq $parameter.Type "array" }}
			for elem in {{ $argument }}:
				query_params += "{{- $snakecase }}=%s&" % elem
                {{- else }}
		{{ $parameter }} // ERROR
                {{- end }}
            {{- end }}
            {{- end }}
		var uri = "%s%s%s" % [_base_uri, urlpath, "?" + query_params if query_params else ""]
		var method = "{{- $method | uppercase }}"
		var headers = {}
            {{- if $operation.Security }}
            {{- with (index $operation.Security 0) }}
                {{- range $key, $value := . }}
                    {{- if eq $key "BasicAuth" }}
		var credentials = Marshalls.utf8_to_base64(p_basic_auth_username + ":" + p_basic_auth_password)
		var header = "Basic %s" % credentials
		headers["Authorization"] = header
                    {{- else if eq $key "HttpKeyAuth" }}
		if (p_bearer_token):
			var header = "Bearer %s" % p_bearer_token
			headers["Authorization"] = header
                    {{- end }}
                {{- end }}
            {{- end }}
            {{- else }}
		var header = "Bearer %s" % p_session.token
		headers["Authorization"] = header
            {{- end }}

		var content : PackedByteArray
            {{- range $parameter := $operation.Parameters }}
            {{- $argument := $parameter.Name | prependParameter }}
            {{- if eq $parameter.In "body" }}
                {{- if eq $parameter.Schema.Type "string" }}
		content = JSON.new().stringify(p_body).to_utf8_buffer()
                {{- else }}
		content = JSON.new().stringify(p_body.serialize()).to_utf8_buffer()
                {{- end }}
            {{- end }}
            {{- end }}

		var result = await _http_adapter.send_async(method, uri, headers, content)
		if result is NakamaException:
			return {{ $classname }}.new(result)

            {{- if $operation.Responses.Ok.Schema.Ref }}
		var out : {{ $classname }} = NakamaSerializer.deserialize(_namespace, "{{ $classname }}", result)
		return out
            {{- else }}
		return NakamaAsyncResult.new()
            {{- end}}
{{- end }}
{{- end }}
`

func convertRefToClassName(input string) (className string) {
	cleanRef := strings.TrimPrefix(input, "#/definitions/")
	className = strings.Title(cleanRef)
	return
}

func stripNewlines(input string) (output string) {
	output = strings.Replace(input, "\n", " ", -1)
	return
}

func prependParameter(input string) (output string) {
	output = "p_" + pascalToSnake(input)
	return
}

func pascalToSnake(input string) (output string) {
	output = ""
	prev_low := false
	for _, v := range input {
		is_cap := v >= 'A' && v <= 'Z'
		is_low := v >= 'a' && v <= 'z'
		if is_cap && prev_low {
			output = output + "_"
		}
		output += strings.ToLower(string(v))
		prev_low = is_low
	}
	return
}

func apiFuncName(input string) (output string) {
	output = pascalToSnake(input[7:])
	return
}

func godotType(p_type string, p_ref string, p_item_type string, p_extra string, p_is_enum bool) (out string) {

	is_array := false
	is_dict := false
	switch p_type {
		case "integer":
			out = "int"
		case "string":
			out = "String"
		case "boolean":
			out = "bool"
		case "array":
			is_array = true
		case "object":
			is_dict = true
		default:
			if p_is_enum {
				out = "int"
			} else {
				out = convertRefToClassName(p_ref)
			}
	}

	if is_array {
		switch p_item_type {
			case "integer":
				out = "PackedIntArray"
				return
			case "string":
				out = "PackedStringArray"
				return
			case "boolean":
				out = "PackedIntArray"
				return
			default:
				out = "Array"
		}
	}
	if is_dict {
		out = "Dictionary"
	}
	return
}

func godotDef(p_type string) (out string) {
	switch(p_type) {
		case "bool": out = "false"
		case "int": out = "0"
		case "String": out = "\"\""
		case "PackedIntArray": out = "PackedIntArray()"
		case "PackedStringArray": out = "PackedStringArray()"
		case "Array": out = "Array()"
		case "Dictionary": out = "Dictionary()"
	}
	return
}

func godotLooseType(p_type string) (out string) {
	switch(p_type) {
		case "PackedStringArray", "PackedIntArray":
			out = "Array"
		default:
			out = p_type
	}
	return
}

func godotSchemaType(p_type string) (out string) {
	out = "TYPE_"
	switch(p_type) {
		case "bool": out += "BOOL"
		case "int": out += "INT"
		case "String": out += "STRING"
		case "PackedIntArray": out += "ARRAY"
		case "PackedStringArray": out += "ARRAY"
		case "Array": out += "ARRAY"
		case "Dictionary": out += "DICTIONARY"
		default: out = "\"" + p_type + "\""
	}
	return
}

func pascalToCamel(input string) (camelCase string) {
	if input == "" {
		return ""
	}

	camelCase = strings.ToLower(string(input[0]))
	camelCase += string(input[1:])
	return camelCase
}

func camelToPascal(camelCase string) (pascalCase string) {

	if len(camelCase) <= 0 {
		return ""
	}

	pascalCase = strings.ToUpper(string(camelCase[0])) + camelCase[1:]
	return
}

func enumSummary(def Definition) string {
	// quirk of swagger generation: if enum doesn't have a title
	// then the title can be found as the first entry in the split description.
	if def.Title != "" {
		return def.Title
	}

	split := strings.Split(def.Description, "\n")

	if len(split) <= 0 {
		panic("No newlines in enum description found.")
	}

	return split[0]
}

func enumDescriptions(def Definition) (output []string) {

	split := strings.Split(def.Description, "\n")

	if len(split) <= 0 {
		panic("No newlines in enum description found.")
	}

	if def.Title != "" {
		return split
	}

	// quirk of swagger generation: if enum doesn't have a title
	// then the title can be found as the first entry in the split description.
	// so ignore for individual enum descriptions.
	return split[2:]
}

type Definition struct {
	Properties map[string]struct {
		Type  string
		Ref   string   `json:"$ref"` // used with object
		Items struct { // used with type "array"
			Type string
			Ref  string `json:"$ref"`
		}
		AdditionalProperties struct {
			Type string // used with type "map"
		}
		Format      string // used with type "boolean"
		Description string
	}
	Enum        []string
	Description string
	// used only by enums
	Title string
}

func godotClassUtils(p_name string) string {
	if val, ok := utilities[p_name]; ok {
		return val
	}
	return ""
}

func main() {
	// Argument flags
	var output = flag.String("output", "", "The output for generated code.")
	flag.Parse()

	inputs := flag.Args()
	if len(inputs) < 1 {
		fmt.Printf("No input file found: %s\n\n", inputs)
		fmt.Println("openapi-gen [flags] inputs...")
		flag.PrintDefaults()
		return
	}

	input := inputs[0]
	content, err := ioutil.ReadFile(input)
	if err != nil {
		fmt.Printf("Unable to read file: %s\n", err)
		return
	}

	var schema struct {
		Paths map[string]map[string]struct {
			Summary     string
			OperationId string
			Responses   struct {
				Ok struct {
					Schema struct {
						Ref string `json:"$ref"`
					}
				} `json:"200"`
			}
			Parameters []struct {
				Name     string
				In       string
				Required bool
				Type     string   // used with primitives
				Items    struct { // used with type "array"
					Type string
				}
				Schema struct { // used with http body
					Type string
					Ref  string `json:"$ref"`
				}
                Format   string // used with type "boolean"
			}
			Security []map[string][]struct {
			}
		}
		Definitions map[string]Definition
	}

	if err := json.Unmarshal(content, &schema); err != nil {
		fmt.Printf("Unable to decode input %s : %s\n", input, err)
		return
	}

	fmap := template.FuncMap{
		"cleanRef": convertRefToClassName,
		"stripNewlines": stripNewlines,
		"title": strings.Title,
		"uppercase": strings.ToUpper,
		"prependParameter": prependParameter,
		"pascalToSnake": pascalToSnake,
		"apiFuncName": apiFuncName,
		"godotType": godotType,
		"godotLooseType": godotLooseType,
		"godotSchemaType": godotSchemaType,
		"godotDef": godotDef,
		"isRefToEnum": func(ref string) bool {
			if len(ref) == 0 {
				return false
			}
			// swagger schema definition keys have inconsistent casing
			var camelOk bool
			var pascalOk bool
			var enums []string

			asCamel := pascalToCamel(ref)
			if _, camelOk = schema.Definitions[asCamel]; camelOk {
				enums = schema.Definitions[asCamel].Enum
			}

			asPascal := camelToPascal(ref)
			if _, pascalOk = schema.Definitions[asPascal]; pascalOk {
				enums = schema.Definitions[asPascal].Enum
			}

			if !pascalOk && !camelOk {
				fmt.Printf("no definition found: %v", ref)
				return false
			}

			return len(enums) > 0
		},
		"enumDescriptions": enumDescriptions,
		"enumSummary":      enumSummary,
		"godotClassUtils": godotClassUtils,
	}
	tmpl, err := template.New(input).Funcs(fmap).Parse(codeTemplate)
	if err != nil {
		fmt.Printf("Template parse error: %s\n", err)
		return
	}

	if len(*output) < 1 {
		tmpl.Execute(os.Stdout, schema)
		return
	}

	f, err := os.Create(*output)
	if err != nil {
		fmt.Printf("Unable to create file: %s\n", err)
		return
	}
	defer f.Close()

	writer := bufio.NewWriter(f)
	tmpl.Execute(writer, schema)
	writer.Flush()
}
