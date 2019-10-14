package connect;


/**
    This class provides static methods for string transformation. For example,
    to change casing (snake_case, camelCase, UpperCamelCase), or to singularize a word.
**/
class Inflection {
    /**
        Returns a string with the given text converted from snake_case to camelCase.

        If `capitalizeFirst` is true, then the string is returned as UpperCamelCase.
    **/
    public static function toCamelCase(text: String, capitalizeFirst: Bool = false): String {
        var buffer = new StringBuf();
        var lastWasUnderscore = capitalizeFirst;
        for (i in 0...text.length) {
            var char = lastWasUnderscore ? text.charAt(i).toUpperCase() : text.charAt(i);
            if (char != '_') {
                buffer.add(char);
                lastWasUnderscore = false;
            } else {
                lastWasUnderscore = true;
            }
        }
        return buffer.toString();
    }


    /**
        Returns a string the trailing "s" removed from the given text, if it has one.
    **/
    public static function toSingular(text: String): String {
        if (text.charAt(text.length - 1) == 's') {
            return text.substr(0, text.length - 1);
        } else {
            return text;
        }
    }


    /**
        Returns a string with the given text converted from camelCase or UpperCamelCase to
        snake_case.
    **/
    public static function toSnakeCase(text: String): String {
        var r1 = ~/(.)([A-Z][a-z]+)/g;
        var r2 = ~/([a-z0-9])([A-Z])/g;
        var s1 = r1.replace(text, '$1_$2');
        return r2.replace(s1, '$1_$2').toLowerCase();
    }


    /*
        If the text contains a JSON string representation, it returns it beautified using two space
        indentation. Otherwise, returns the string as-is. If `onlyId` is `true` and the text
        contains a JSON string representation, only the id is returned.
    */
    public static function beautify(text: String, onlyId: Bool): String {
        try {
            var parsed: Dynamic = haxe.Json.parse(text);
            if (onlyId) {
                if (Type.typeof(parsed) == TObject && Reflect.hasField(parsed, 'id')) {
                    return parsed.id;
                } else {
                    return haxe.Json.stringify(
                        cast(parsed, Array<Dynamic>).map(function(obj) {
                            return Reflect.hasField(obj, 'id') ? obj.id : Std.string(obj);
                        }),
                        null,
                        '  '
                    );
                }
            } else {
                return haxe.Json.stringify(parsed, null, '  ');
            }
        } catch (ex: Dynamic) {
            return text;
        }
    }


    /**
        @returns Whether the text seems to contain a JSON object or array.
        NOTE: If the JSON string is malformed, this still returns `true`.
    **/
    public static function isJson(text: String): Bool {
        return isJsonObject(text) || isJsonArray(text);
    }


    /**
        @returns Whether the text seems to contain a JSON object.
        NOTE: If the JSON string is malformed, this still returns `true`.
    **/
    public static function isJsonObject(text: String): Bool {
        return StringTools.trim(text).charAt(0) == '{';
    }


    /**
        @returns Whether the text seems to contain a JSON array.
        NOTE: If the JSON string is malformed, this still returns `true`.
    **/
    public static function isJsonArray(text: String): Bool {
        return StringTools.trim(text).charAt(0) == '[';
    }
}
