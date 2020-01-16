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

const codeTemplate string = `### Code generated by codegen/main.go. DO NOT EDIT. ###

extends Reference
class_name NakamaAPI
{{- range $defname, $definition := .Definitions }}
{{- $classname := $defname | title }}

### <summary>
### {{ $definition.Description | stripNewlines }}
### </summary>
class {{ $classname }} extends NakamaAsyncResult:

	const _SCHEMA = {
		{{- range $propname, $property := $definition.Properties }}
		{{- $fieldname := $propname }}
		{{- $_field := printf "_%s" $fieldname }}
		{{- $gdType := godotType $property.Type $property.Ref $property.Items.Type $property.Items.Ref }}
		"{{ $propname }}": {"name": "{{ $_field }}", "type": {{ $gdType | godotSchemaType }}, "required": false
		{{- if eq $property.Type "array" -}}
			, "content": {{ (godotType $property.Items.Type $property.Items.Ref "" "") | godotSchemaType }}
		{{- else if eq $property.Type "object" -}}
		            {{- else if eq $property.Type "object"}}{{/* Only base types here. */}}
			, "content": {{ (godotType $property.AdditionalProperties.Type "" "" "") | godotSchemaType  }}
		{{- end -}}
		},
		{{- end }}
	}

        {{- range $propname, $property := $definition.Properties }}
        {{- $fieldname := $propname }}
        {{- $_field := printf "_%s" $fieldname }}
        {{- $gdType := godotType $property.Type $property.Ref $property.Items.Type $property.Items.Ref }}
	{{- $gdDef := $gdType | godotDef }}

	### <summary>
	### {{ $property.Description }}
	### </summary>
	var {{ $fieldname }} : {{ $gdType }} setget , _get_{{ $fieldname }}
	var {{ $_field }} = null
	func _get_{{ $fieldname }}() -> {{ $gdType }}:
        {{- if $property.Ref }}{{/* Object reference */}}
		return _{{ $fieldname }} as {{ $gdType }}
        {{- else if eq $property.Type "object"}}{{/* Dictionaries */}}
		return Dictionary() if not {{ $_field }} is Dictionary else {{ $_field }}.duplicate()
        {{- else }}{{/* Simple type */}}
		return {{ $gdDef }} if not {{ $_field }} is {{ $gdType }} else {{ $gdType }}({{ $_field }})
        {{- end }}
        {{- end }}

	func _init(p_exception = null).(p_exception):
		pass

	static func create(p_ns : GDScript, p_dict : Dictionary) -> {{ $classname }}:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "{{ $classname }}", p_dict), {{ $classname }}) as {{ $classname }}

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string() -> String:
		if is_exception():
			return get_exception()._to_string()
		var output : String = ""
            {{- range $fieldname, $property := $definition.Properties }}
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

### <summary>
### The low level client for the Nakama API.
### </summary>
class ApiClient extends Reference:

	var _base_uri : String
	var _timeout : int

	var _http_adapter
	var _namespace

	func _init(p_base_uri : String, p_http_adapter, p_namespace : GDScript, p_timeout : int = 10):
		_base_uri = p_base_uri
		_timeout = p_timeout
		_http_adapter = p_http_adapter
		_namespace = p_namespace

        {{- range $url, $path := .Paths }}
        {{- range $method, $operation := $path}}

	### <summary>
	### {{ $operation.Summary | stripNewlines }}
	### </summary>
        {{- if $operation.Responses.Ok.Schema.Ref }}
	func {{ $operation.OperationId | pascalToSnake }}_async(
        {{- else }}
	func {{ $operation.OperationId | pascalToSnake }}_async(
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
		p_bearer_token : String
        {{- end }}

        {{- range $parameter := $operation.Parameters }}
        {{- $camelcase := $parameter.Name | prependParameter }}
	{{- if not $parameter.Required }}{{/* Godot does not support typed optional parameters yet. */}}
		, {{ $camelcase }} = null # : {{ $parameter.Type }}
        {{- else if eq $parameter.In "body" }}
            {{- if eq $parameter.Schema.Type "string" }}
		, {{ $camelcase }} : String
            {{- else }}
		, {{ $camelcase }} : {{ $parameter.Schema.Ref | cleanRef }}
            {{- end }}
        {{- else }}
		, {{ $camelcase }} : {{ godotType $parameter.Type $parameter.Schema.Ref $parameter.Items.Type "" }}
        {{- end }}
	{{- end }}
	)
	{{- if $operation.Responses.Ok.Schema.Ref }} -> {{ $operation.Responses.Ok.Schema.Ref | cleanRef }}
	{{- else }} -> NakamaAsyncResult
	{{- end }}:
		var urlpath : String = "{{- $url }}"
            {{- range $parameter := $operation.Parameters }}
            {{- $camelcase := $parameter.Name | prependParameter }}
            {{- if eq $parameter.In "path" }}
		urlpath = NakamaSerializer.escape_http(urlpath.replace("{{- print "{" $parameter.Name "}"}}", {{ $camelcase }}))
            {{- end }}
            {{- end }}
		var query_params = ""
            {{- range $parameter := $operation.Parameters }}
            {{- $camelcase := $parameter.Name | prependParameter}}
            {{- if eq $parameter.In "query"}}
            {{- if $parameter.Required }}
		if true: # Hack for static checks
            {{- else }}
		if {{ $camelcase }} != null:
            {{- end }}
                {{- if eq $parameter.Type "integer" }}
			query_params += "{{- $parameter.Name }}=%d&" % {{ $camelcase }}
                {{- else if eq $parameter.Type "string" }}
			query_params += "{{- $parameter.Name }}=%s&" % NakamaSerializer.escape_http({{ $camelcase }})
                {{- else if eq $parameter.Type "boolean" }}
			query_params += "{{- $parameter.Name }}=%s&" % str(bool({{ $camelcase }})).to_lower()
                {{- else if eq $parameter.Type "array" }}
			for elem in {{ $camelcase }}:
				query_params += "{{- $parameter.Name }}=%s&" % elem
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
		var header = "Bearer %s" % p_bearer_token
		headers["Authorization"] = header
            {{- end }}

		var content : PoolByteArray
            {{- range $parameter := $operation.Parameters }}
            {{- $camelcase := $parameter.Name | prependParameter }}
            {{- if eq $parameter.In "body" }}
                {{- if eq $parameter.Schema.Type "string" }}
		content = JSON.print(p_body).to_utf8()
                {{- else }}
		content = JSON.print(p_body.serialize()).to_utf8()
                {{- end }}
            {{- end }}
            {{- end }}

            {{- if $operation.Responses.Ok.Schema.Ref }}
                {{- $classname := $operation.Responses.Ok.Schema.Ref | cleanRef }}
		var result = yield(_http_adapter.send_async(method, uri, headers, content, _timeout), "completed")
		if result is NakamaException:
			return {{ $classname }}.new(result)
		var out : {{ $classname }} = NakamaSerializer.deserialize(_namespace, "{{ $classname }}", result)
		return out
            {{- else }}
		var result = yield(_http_adapter.send_async(method, uri, headers, content, _timeout), "completed")
		if result is NakamaException:
			return NakamaAsyncResult.new(result)
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
	output = "p_" + input
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

func godotType(p_type string, p_ref string, p_item_type string, p_extra string) (out string) {

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
			out = convertRefToClassName(p_ref)
	}

	if is_array {
		switch p_item_type {
			case "integer":
				out = "PoolIntArray"
				return
			case "string":
				out = "PoolStringArray"
				return
			case "boolean":
				out = "PoolIntArray"
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
		case "PoolIntArray": out = "PoolIntArray()"
		case "PoolStringArray": out = "PoolStringArray()"
		case "Array": out = "Array()"
		case "Dictionary": out = "Dictionary()"
	}
	return
}

func godotLooseType(p_type string) (out string) {
	switch(p_type) {
		case "PoolStringArray", "PoolIntArray":
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
		case "PoolIntArray": out += "ARRAY"
		case "PoolStringArray": out += "ARRAY"
		case "Array": out += "ARRAY"
		case "Dictionary": out += "DICTIONARY"
		default: out = "\"" + p_type + "\""
	}
	return
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
		Definitions map[string]struct {
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
			Description string
		}
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
		"godotType": godotType,
		"godotLooseType": godotLooseType,
		"godotSchemaType": godotSchemaType,
		"godotDef": godotDef,
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
