/*
    This file is part of the Ingram Micro CloudBlue Connect SDK.
    Copyright (c) 2019 Ingram Micro. All Rights Reserved.
 */

package connect.logger;

import connect.util.Collection;

/**
    This class is used to log events to a file and the output console.
**/
class Logger extends Base {
    /** Only writes compact error level messages. **/
    public static final LEVEL_ERROR = 0;

    /** Only writes compact error & warning level messages. **/
    public static final LEVEL_WARNING = 1;

    /** Only writes compact error & info level messages. **/
    public static final LEVEL_INFO = 2;

    /** Writes detailed messages of all levels. **/
    public static final LEVEL_DEBUG = 3;

    private final path:String;
    private final level:Int;
    private final handlers:Collection<LoggerHandler>;
    private final sections:Array<LoggerSection>;
    private final maskedFields:Collection<String>;
    private final regexMaskingList:Collection<EReg>;
    private final compact:Bool;
    private var defaultFilename:String;

    /**
        Creates a new Logger object. You don't normally create objects of this class,
        since the SDK uses the default instance provided by `Env.getLogger()`.
    **/
    public function new(config:LoggerConfig) {
        config = (config != null) ? config : new LoggerConfig();
        this.path = (config.path_.charAt(config.path_.length - 1) == '/') ? config.path_ : (config.path_ + '/');
        this.level = Std.int(Math.min(Math.max(config.level_, LEVEL_ERROR), LEVEL_DEBUG));
        this.handlers = config.handlers_.copy();
        this.sections = [];
        this.maskedFields = config.maskedFields_.copy();
        this.regexMaskingList = config.regexMaskingList_.copy();
        if (this.maskedFields.indexOf('Authorization') == -1) this.maskedFields.push('Authorization');
        this.compact = (this.level != LEVEL_DEBUG) ? config.compact_ : false;
        this.defaultFilename = null;
    }

    /** @returns The path where logs are stored. **/
    public function getPath():String {
        return this.path;
    }

    /**
     * @return Int The level of the log. One of: `LEVEL_ERROR`, `LEVEL_WARNING`,
     * `LEVEL_INFO`, `LEVEL_DEBUG`.
     */
    public function getLevel():Int {
        return this.level;
    }

    /**
     * @return Bool Whether the logs are written in compact format (this is,
     * for JSON objects only print key names or, if it has an 'id' field,
     * only the id)..
     */
    public function isCompact(): Bool {
        return this.compact;
    }

    /**
        Sets the filename of the log. All future log messages will get printed to this file.
        Initially, the logger only writes to the standard output. The first time you call
        this method with an argument other than `null`, the provided name will be considered
        the default filename. Whenever this method is called afterwards with a `null` argument,
        output will be sent to the default file.

        Filename extension must be omitted, since it is provided by the formatters
        used in each handler.
    **/
    public function setFilename(filename:String):Void {
        if (this.defaultFilename == null && filename != null) {
            this.defaultFilename = filename;
        }
        final fullname =
            (this.path != null && filename != null) ? this.path + filename :
            (this.path != null) ? this.path + this.defaultFilename :
            null;
        final setFilenameResult = Lambda.fold(this.handlers, function(handler, last) {
            final fullnameWithExt = (fullname != null)
                ? '$fullname.${handler.formatter.getFileExtension()}'
                : null;
            return last && handler.writer.setFilename(fullnameWithExt);
        }, true);
        if (setFilenameResult && fullname != null) {
            for (section in this.sections) {
                section.written = false;
            }
        }
    }

    /** @returns The last filename that was set. **/
    public function getFilename():String {
        final firstWriter = (this.handlers.length() > 0) ? this.handlers.get(0).writer : null;
        if (firstWriter != null) {
            final filename = firstWriter.getFilename();
            final fixedFilename = (filename != null && filename.indexOf(this.path) == 0)
                ? filename.substr(this.path.length)
                : filename;
            return fixedFilename;
        } else {
            return null;
        }
    }
    
    /** @returns The defined handlers for this logger. Do not modify this collection. **/
    public function getHandlers():Collection<LoggerHandler> {
        return this.handlers;
    }

    /**
        Opens a new section in the log. This will be output as a Markdown header when using
        this formatting, depending on the number of opened sections. For example, at the beginning
        of a function, a section can be opened, and closed when the function finishes.
    **/
    public function openSection(name:String):Void {
        this.sections.push(new LoggerSection(name));
    }

    /**
        Closes the last opened section.
    **/
    public function closeSection():Void {
        this.sections.pop();
    }

    /**
     * Writes a block to the log in the specified level.
     * It adds a new line to the log after writing the block.
     * @param level Message level. One of: `LEVEL_ERROR`, `LEVEL_WARNING`, `LEVEL_INFO`, `LEVEL_DEBUG`.
     * @param block Block of text to log. Lines in the text are formatted to appear as a block.
     */
    public function writeBlock(level:Int, block:String):Void {
        for (output in this.handlers) {
            this._writeToHandler(level, output.formatter.formatBlock(level, block), output);
        }
    }

    /**
     * Writes a code block to the log in the specified level.
     * It adds a new line to the log after writing the block.
     * @param level Message level. One of: `LEVEL_ERROR`, `LEVEL_WARNING`, `LEVEL_INFO`, `LEVEL_DEBUG`.
     * @param code Code to log. Text is formatted to appear as a code block.
     * @param language Language used in the block. For example, "json". Can be an empty string.
     */
    public function writeCodeBlock(level:Int, code:String, language:String):Void {
        for (output in this.handlers) {
            this._writeToHandler(level, output.formatter.formatCodeBlock(level, Std.string(code), language), output);
        }
    }

    /**
     * Writes a list to the log in the specified level.
     * It adds a new line to the log after writing the list.
     * @param level Message level. One of: `LEVEL_ERROR`, `LEVEL_WARNING`, `LEVEL_INFO`, `LEVEL_DEBUG`.
     * @param list List to log. Lines are formatted to appear as a list.
     */
    public function writeList(level:Int, list:Collection<String>):Void {
        for (output in this.handlers) {
            this._writeToHandler(level, output.formatter.formatList(level, list), output);
        }
    }

    /**
     * Writes a table to the log in the specified level. The first row should contain the
     * table header.
     * It adds a new line to the log after writing the list.
     * @param level Message level. One of: `LEVEL_ERROR`, `LEVEL_WARNING`, `LEVEL_INFO`, `LEVEL_DEBUG`.
     * @param table Table to log. Rows are formatted to appear as a table.
     */
    public function writeTable(level:Int, table:Collection<Collection<String>>):Void {
        for (output in this.handlers) {
            this._writeToHandler(level, output.formatter.formatTable(level, table), output);
        }
    }

    /**
     * Writes a message to the log in the specified level.
     * It adds a new line to the log after writing the message.
     * @param level Message level. One of: `LEVEL_ERROR`, `LEVEL_WARNING`, `LEVEL_INFO`, `LEVEL_DEBUG`.
     * @param message Message to log. The message is not formatted.
     */
    public function write(level:Int, message:String):Void {
        for (output in this.handlers) {
            this._writeToHandler(level, message, output);
        }
    }

    /**
     *  Returns a list of fields which should be masked in http requests or responses
    **/
    public function getMaskedFields():Collection<String> {
        return this.maskedFields;
    }

     /**
     *  Returns a list of regular expression for string data masking purposes
    **/
    public function getRegExMaskingList():Collection<EReg> {
        return this.regexMaskingList;
    }

    @:dox(hide)
    public function log(message:String):Void {
        this.error(message);
    }

    @:dox(hide)
    public function debug(message:String):Void {
        this.write(LEVEL_DEBUG, message);
    }

    @:dox(hide)
    public function info(message:String):Void {
        this.write(LEVEL_INFO, message);
    }

    @:dox(hide)
    public function notice(message:String):Void {
        this.info(message);
    }

    @:dox(hide)
    public function warning(message:String):Void {
        this.write(LEVEL_WARNING, message);
    }

    @:dox(hide)
    public function error(message:String):Void {
        this.write(LEVEL_ERROR, message);
    }

    @:dox(hide)
    public function critical(message:String):Void {
        this.error(message);
    }

    @:dox(hide)
    public function alert(message:String):Void {
        this.error(message);
    }

    @:dox(hide)
    public function emergency(message:String):Void {
        this.error(message);
    }

    @:dox(hide)
    public function _writeToHandler(level:Int, message:String, handler:LoggerHandler):Void {
        if (this.level >= level) {
            this.writeSections(level);
            handler.writer.writeLine(handler.formatter.formatLine(level, message));
        }
    }
    
    private function writeSections(level:Int):Void {
        for (i in 0...this.sections.length) {
            if (!this.sections[i].written) {
                for (output in this.handlers) {
                    final section = output.formatter.formatSection(level, i+1, this.sections[i].name);
                    output.writer.writeLine(section);
                }
                this.sections[i].written = true;
            }
        }
    }
}

private class LoggerSection {
    public final name:String;
    public var written:Bool;

    public function new(name:String) {
        this.name = name;
        this.written = false;
    }
}
