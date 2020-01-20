/*
    This file is part of the Ingram Micro CloudBlue Connect SDK.
    Copyright (c) 2019 Ingram Micro. All Rights Reserved.
*/
package tests.unit;

import connect.Env;
import connect.models.Asset;
import connect.models.Param;
import connect.util.Dictionary;


class ItemTest extends haxe.unit.TestCase {
    override public function setup() {
        Env._reset(new Dictionary()
            .setString('IFulfillmentApi', 'tests.mocks.FulfillmentApiMock'));
    }


    public function testGetParamByIdOk() {
        final item = Asset.get('AS-392-283-000-0').items.get(0);
        final param = item.getParamById('item_parameter');
        assertTrue(Std.is(param, Param));
        assertEquals('item_parameter', param.id);
        assertEquals('Value 1', param.value);
    }


    public function testGetParamByIdKo() {
        final item = Asset.get('AS-392-283-000-0').items.get(0);
        final param = item.getParamById('invalid-id');
        assertTrue(param == null);
    }
}
