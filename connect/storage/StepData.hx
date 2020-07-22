/*
    This file is part of the Ingram Micro CloudBlue Connect SDK.
    Copyright (c) 2019 Ingram Micro. All Rights Reserved.
*/
package connect.storage;

import connect.models.Model;
import connect.util.Dictionary;
import haxe.Json;


@:dox(hide)
enum StorageType {
    ConnectStorage;
    LocalStorage;
    FailedStorage;
}


@:dox(hide)
class StepData {
    public final firstIndex: Int;
    public final data: Dictionary;
    public final storage: StorageType;
    public final attempt: Int;

    public function new(firstIndex: Int, data: Dynamic, storage: StorageType, attempt:Int) {
        this.firstIndex = firstIndex;
        this.data = new Dictionary();
        this.storage = storage;
        this.attempt = attempt;
        if (Std.is(data, Dictionary)) {
            // Create data from Dictionary. Store model class names with key
            for (key in cast(data, Dictionary).keys()) {
                final value = data.get(key);
                final className =
                    Std.is(value, Model) ? Type.getClassName(Type.getClass(value)) :
                    Std.is(value, Dictionary) ? 'Dictionary' :
                    '';
                this.data.set('$key::$className', value);
            }
        } else {
            // Create data from anonymous structure. For keys that have an attached class name, parse class
            for (field in Reflect.fields(data)) {
                final fieldSplit = field.split('::');
                final fieldName = fieldSplit.slice(0, -1).join('::');
                final fieldClassName = fieldSplit.slice(-1)[0];
                final fieldClass =
                    (fieldClassName == 'Dictionary') ? Dictionary :
                    (fieldClassName != '') ? Type.resolveClass(fieldClassName) :
                    null;
                final value = Reflect.field(data, field);
                final parsedValue: Dynamic =
                    (fieldClass == Dictionary) ? Dictionary.fromObject(value) :
                    (fieldClass != null) ? Model.parse(fieldClass, Json.stringify(value)) :
                    value;
                this.data.set(fieldName, parsedValue);
            }
        }
    }
}
