import connect.Config;
import connect.api.ConnectApi;
import connect.api.QueryParams;
import connect.models.*;

class Example {
    public static function main() {
        // Get initial time
        var initialTime = Date.now().getTime();

        // Load test config
        Config.load('test_config.json');

        // List requests
        var requests = Fulfillment.list(new QueryParams()
            .param('asset.product.id__in', Config.getInstance().getProductsString())
            .param('status', 'pending')
        );

        // Trace requests
        for (request in requests) {
            trace(request.id
                + ' : ' + request.asset.id
                + ' : ' + request.asset.connection.id
                + ' : ' + request.asset.product.id
                + ' : ' + request.status);

            /*
            // Approve by tile
            api.fulfillment.changeRequestStatus(request.id, 'approve', {
                activation_tile: 'Markdown text'
            });

            // Approve by template
            api.fulfillment.changeRequestStatus(request.id, 'approve', {
                template_id: 'TL-000-000-000'
            });
            */
        }

        // Trace total time
        var finalTime = Date.now().getTime();
        trace('Total time: ' + ((finalTime - initialTime) / 1000) + ' secs.');
    }
}
