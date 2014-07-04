"""Example dummy rest server."""
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.view import view_config


@view_config(request_method='GET', route_name='get_test', renderer='json')
def get_test(request):
    """Return dummy test data."""
    value = request.matchdict['value']
    return {'key': value}


if __name__ == '__main__':
    config = Configurator()

    config.add_route('get_test', '/test/{value}')

    config.scan()
    app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 9900, app)
    server.serve_forever()
