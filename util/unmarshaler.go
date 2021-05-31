package util

import (
	"encoding/json"
	"fmt"
	"net/url"
	"reflect"
	"strconv"
	"strings"

	"github.com/Dreamacro/clash/log"
)

// unmarshalValues 解码为UrlValues
func unmarshalValues(str string) (subInfoMap url.Values, err error) {
	subInfoMap, err = url.ParseQuery(str)
	var trimField string
	for field, _ := range subInfoMap {
		trimField = strings.TrimSpace(field)
		if trimField != field {
			subInfoMap.Add(trimField, subInfoMap.Get(field))
			subInfoMap.Del(field)
		}
	}
	return subInfoMap, err
}

// UnmarshalByValues 解码为struct
func UnmarshalByValues(str string, v interface{}) error {
	return UnmarshalByValuesWithTag(str, "query", v)
}

// UnmarshalByValuesWithTag 解码为struct
func UnmarshalByValuesWithTag(str string, fieldTag string, v interface{}) error {
	rv := reflect.ValueOf(v)
	if rv.Kind() != reflect.Ptr {
		return fmt.Errorf("unmarshal non-pointer \"%s\"", rv.Type().String())
	}
	if rv.IsNil() {
		return fmt.Errorf("unmarshall by reflect failed, because the interface ptr is nil")
	}

	subInfoMap, err := unmarshalValues(str)
	if err != nil {
		return err
	}
	rv = rv.Elem()
	rvt := rv.Type()
	fieldNum := rv.NumField()

	for i := 0; i < fieldNum; i++ {
		rvf := rvt.Field(i)
		var tag string
		if len(fieldTag) > 0 {
			tag = rvf.Tag.Get(fieldTag)
		}
		fieldName := rvf.Name
		rfv := rv.Field(i)
		if len(tag) == 0 {
			tag = rvf.Name
		}
		fieldVal := subInfoMap[tag]
		log.Debugln("%s %s(%s)=%s\n", rfv.Kind(), fieldName, tag, fieldVal)
		if len(fieldVal) < 1 {
			continue
		}
		switch rfv.Kind() {
		case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
			intVal, err := strconv.ParseInt(fieldVal[0], 10, 64)
			if err != nil {
				return err
			}
			rfv.SetInt(intVal)
			break
		case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
			intVal, err := strconv.ParseUint(fieldVal[0], 10, 64)
			if err != nil {
				return err
			}
			rfv.SetUint(intVal)
			break
		case reflect.Bool:
			if fieldVal[0] != "true" && fieldVal[0] != "false" {
				return fmt.Errorf("unmarshall by reflect failed, field \"%s\" kind \"bool\" must be [true, false], but it's \"%s\"", fieldName, fieldVal)
			}
			rfv.SetBool(fieldVal[0] == "true")
			break
		case reflect.String:
			rfv.SetString(fieldVal[0])
			break
		case reflect.Struct:
			// TODO: use recursion
			return fmt.Errorf("unmarshall by reflect failed, field \"%s\" kind \"%s\" is not support", fieldName, rfv.Kind())
		case reflect.Array, reflect.Slice:
			// TODO: use recursion inside loop
			return fmt.Errorf("unmarshall by reflect failed, field \"%s\" kind \"%s\" is not support", fieldName, rfv.Kind())
		//	rfv.Set(reflect.ValueOf(fieldVal))
		default:
			rfv.Set(reflect.ValueOf(fieldVal))
		}
	}
	return nil
}

// ToJsonString struct转为JSON字符串
func ToJsonString(v interface{}) string {
	jsonBytes, _ := json.MarshalIndent(v, "", "\t")
	return string(jsonBytes)
}

// JsonUnmarshal JSON字节数组转struct
func JsonUnmarshal(data []byte, v interface{}) {
	if err := json.Unmarshal(data, v); err != nil {
		log.Errorln("JsonUnmarshal error: %v", err)
	}
}

// IgnoreErrorBytes 忽略错误[]byte
func IgnoreErrorBytes(data []byte, err error) []byte {
	if err != nil {
		log.Errorln("IgnoreError: %v", err)
	}
	return data
}

// IgnoreErrorString 忽略错误string
func IgnoreErrorString(data string, err error) string {
	if err != nil {
		log.Errorln("IgnoreError: %v", err)
	}
	return data
}

// ToLowerCamelCase 转小驼峰camelCase
func ToLowerCamelCase(s string) string {
	return toCamelCase(s, false)
}

// ToUpperCamelCase 转大驼峰CamelCase
func ToUpperCamelCase(s string) string {
	return toCamelCase(s, true)
}

func toCamelCase(s string, toUpper bool) string {
	if len(s) == 0 {
		return s
	}
	var camelCaseStr string
	if toUpper {
		camelCaseStr = strings.ToUpper(s[:1])
	} else {
		camelCaseStr = strings.ToLower(s[:1])
	}
	if len(s) == 1 {
		return camelCaseStr
	}
	return camelCaseStr + s[1:]
}
