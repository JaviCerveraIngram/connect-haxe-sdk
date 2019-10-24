import connect.Collection;
import connect.Env;

class E2ETests {
    public static function main() {
        // Setup config
        Env.initConfig(
            'https://api.conn.rocks/public/v1/',
            'SU-615-925-491:75b49c434177186b80990a822cb7f5e070d36b95',
            new Collection<String>().push(tests.e2e.SampleProductTest.PRODUCT_ID));
        
        var runner = new haxe.unit.TestRunner();
        runner.add(new tests.e2e.SampleProductTest());
        runner.run();
    }
}
