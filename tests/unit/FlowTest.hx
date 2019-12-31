/*
    This file is part of the Ingram Micro CloudBlue Connect SDK.
    Copyright (c) 2019 Ingram Micro. All Rights Reserved.
*/
package tests.unit;

import connect.Dictionary;
import connect.Env;
import connect.Flow;


class FlowTest extends haxe.unit.TestCase {
    override public function setup() {
        Env._reset(new Dictionary()
            .setString('IFulfillmentApi', 'tests.mocks.FulfillmentApiMock')
            .setString('ITierApi', 'tests.mocks.TierApiMock'));
    }

    public function testDataEmpty() {
        final flow = new Flow(_ -> true);
        this.assertEquals(null, flow.getData('Number'));
    }

    public function testDataNumber() {
        final flow = new Flow(_ -> true);
        flow.setData('Number', 56);
        this.assertEquals(56, flow.getData('Number'));
    }
}
