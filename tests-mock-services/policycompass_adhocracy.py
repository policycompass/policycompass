"""Example dummy rest server."""
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.view import view_config


@view_config(request_method='GET', route_name='login_email', renderer='json')
@view_config(request_method='GET', route_name='login_username', renderer='json')
def get_login(request):
    """Return dummy test data for get to /login_email and /login_username. """

    name = request.json_body['name']
    password = request.json_body['password']

    error = \
        {'errors': [{'description': "User doesn't exist or password is wrong",
                     'location': 'body',
                     'name': 'password'}],
         'status': 'error'}
    is_wrong_login = 'wrong' in name.lower() or 'wrong' in password.lower()
    if is_wrong_login:
        return error

    success = {'status': 'success',
               'user_path': '/principals/users/000001',
               'user_token': '0asdf89sfdio9823foi32frewpirew9i8fspofkjew9'}
    return success


@view_config(request_method='POST', route_name='principals_users', renderer='json')
def post_principals_users(request):
    """Return dummy test data for post to /principals_users."""
    data = request.json_body

    content_type = request.json_body['content_type']
    assert content_type == 'adhocracy.resources.principal.IUser'
    data = request.json_body['data']
    name = data['adhocracy.sheets.user.IUserBasic']['name']
    email = data['adhocracy.sheets.user.IUserBasic']['email']
    password = data['adhocracy.sheets.user.IPasswordAuthentication']['password']
    assert len(password) >= 6

    error = \
        {'errors': [{'description': 'The user login email is not unique',
                     'location': 'body',
                     'name': 'data.adhocracy.sheets.user.IUserBasic.email'}],
         'status': 'error'}
    is_wrong_user = 'wrong' in name.lower() or 'wrong' in email.lower()
    if is_wrong_user:
        return error

    success = {'content_type': 'adhocracy.resources.principal.IUser',
               'path': '/principals/users/000001'}
    return success

# example post:
#
# curl -X POST --data '$(<< EOF
# {"content_type": "adhocracy.resources.principal.IUser",
#  "data": {"adhocracy.sheets.user.IUserBasic": {"name": "name", "email": "email@email.de"},
#           "adhocracy.sheets.user.IPasswordAuthentication": {"password": "password"}
#          }
# }
# EOF
# )' http://localhost:9901/principals/users


if __name__ == '__main__':
    config = Configurator()

    config.add_route('login_username', '/login_username')
    config.add_route('login_email', '/login_email')
    config.add_route('principals_users', '/principals/users')
    config.scan()

    app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 9901, app)
    server.serve_forever()
