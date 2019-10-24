package tests.e2e;

import connect.Collection;
import connect.Env;
import connect.api.QueryParams;
import connect.models.Request;


class SampleProductTest extends haxe.unit.TestCase {
    public static inline var PRODUCT_ID = 'PRD-165-786-478';


    override public function setup() {
        Env.getLogger().openSection('${currentTest.classname}::${currentTest.method}');
        if (request == null) {
            requests = Request.list(new QueryParams()
                .set('status', 'pending')
                .set('asset.product.id', PRODUCT_ID));
            if (requests.length() > 0) {
                request = requests.get(0);
            }
        }
    }


    override public function tearDown() {
        Env.getLogger().closeSection();
    }

    
    public function testList() {
        assertEquals(1, requests.length());
    }


    public function testGetOk() {
        var req = Request.get(request.id);
        assertEquals(request.id, req.id);
    }


    public function testGetKo() {
        assertEquals(null, Request.get('PR-0000-0000-0000-000'));
    }


    public function testGetKo2() {
        assertEquals(null, Request.get(null));
    }


    public function testCreate() {
        var req = Reflect.copy(request);
        
        //Reflect.setProperty(req.asset, 'externalUid', 'qwerty');
        req = Request.create(req);
        assertTrue(req != null);
        assertTrue(StringTools.startsWith(req.id, 'PR-'));
        assertTrue(request.id != req.id);
        trace(req.id);
    }


    private var requests: Collection<Request>;
    private var request: Request;
}
