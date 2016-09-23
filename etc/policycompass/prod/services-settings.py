__author__ = 'fki'

from .settings_basic import *

DEBUG = False
TEMPLATE_DEBUG = False

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'pcompass_services',
        'USER': 'pcompass',
        'PASSWORD': 'pcompass',
        'HOST': 'localhost',
        'PORT': '5433',
    }
}

ELASTICSEARCH_URL = 'http://localhost:9200/policycompass_search/'

PC_SERVICES = {
    'references': {
        'frontend_base_url': 'http://alpha.policycompass.eu',
        'base_url': 'http://localhost:8000',
        'MEDIA_URL': 'media/',
        'units': '/api/v1/references/units',
        'external_resources': '/api/v1/references/externalresources',
        'languages': '/api/v1/references/languages',
        'domains': '/api/v1/references/policydomains',
        'dateformats': '/api/v1/references/dateformats',
        'eventsInVisualizations': '/api/v1/visualizationsmanager/eventsInVisualizations',
        'datasetsInvisualizations': '/api/v1/visualizationsmanager/datasetsInVisualizations',
        'updateindexitem' : '/api/v1/searchmanager/updateindexitem',
        'deleteindexitem' : '/api/v1/searchmanager/deleteindexitem',
        'fcm_base_url': 'http://localhost:10080',
        'adhocracy_api_base_url': 'https://adhocracy-prod.policycompass.eu/api'
    },
    'external_resources': {
        'physical_path_phantomCapture': '/home/policycompass/policycompass/policycompass-services/apps/visualizationsmanager/phantomCapture/main.js',
    }
}

ALLOWED_HOSTS = ['localhost', '.policycompass.eu']

with open('/home/policycompass/policycompass/secret_key') as f:
    SECRET_KEY = f.read().strip()


STATIC_ROOT = "/home/policycompass/policycompass/policycompass-services/static"
