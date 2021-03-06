/*
    This file is part of the Ingram Micro CloudBlue Connect SDK.
    Copyright (c) 2019 Ingram Micro. All Rights Reserved.
*/
package connect.native;


#if javalib
class JavaIterator<T> implements java.util.Iterator<T> {
    public function new(array: Array<T>) {
        this.array = array;
        this.index = 0;
    }


    public function forEachRemaining(param1: java.util.function.Consumer<Dynamic>): Void {
        throw new java.lang.RuntimeException("JavaIterator.forEachRemaining not implemented.");
    }


    public function hasNext(): Bool {
        return index < this.array.length;
    }


    public function next(): T {
        return this.array[this.index++];
    }


    public function remove(): Void {
        throw new java.lang.RuntimeException("JavaIterator.remove not implemented.");
    }


    private final array: Array<T>;
    private var index: Int;
}
#end
