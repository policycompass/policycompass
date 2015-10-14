/**
 * @description
 * This module sets all configuration
 *
 * policyCompassConfig is exposed as a global variable in order to use it in
 * the main app.js file. If there's a way to do the same with dependency
 * injection, this should be fixed.
 */

// Configuration for remote services
var policyCompassConfig = {
    'URL': '/api/v1',
    'SEARCH_MANAGER_URL': 'https://services-prod.policycompass.eu/api/v1/searchmanager',
    'METRICS_MANAGER_URL': 'https://services-prod.policycompass.eu/api/v1/metricsmanager',
    'FORMULA_VALIDATION_URL' : 'https://services-prod.policycompass.eu/api/v1/metricsmanager/formulas/validate',
    'NORMALIZERS_URL': 'https://services-prod.policycompass.eu/api/v1/metricsmanager/normalizers',
    'DATASETS_MANAGER_URL': 'https://services-prod.policycompass.eu/api/v1/datasetmanager',
    'VISUALIZATIONS_MANAGER_URL': 'https://services-prod.policycompass.eu/api/v1/visualizationsmanager',
    'EVENTS_MANAGER_URL': 'https://services-prod.policycompass.eu/api/v1/eventsmanager',
    'REFERENCE_POOL_URL': 'https://services-prod.policycompass.eu/api/v1/references',
    'INDICATOR_SERVICE_URL': 'https://services-prod.policycompass.eu/api/v1/indicatorservice',
    'FCM_URL': 'https://fcm-prod.policycompass.eu/api/v1/fcmmanager',
    'ELASTIC_URL' : 'https://search-prod.policycompass.eu/',
    'ELASTIC_INDEX_NAME' : 'policycompass_search',
    'ENABLE_ADHOCRACY': true,
    'ADHOCRACY_BACKEND_URL': 'https://adhocracy-prod.policycompass.eu/api',
    'ADHOCRACY_FRONTEND_URL': 'https://adhocracy-prod.policycompass.eu'
};

angular.module('pcApp.config', []).constant('API_CONF', policyCompassConfig);