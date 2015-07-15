/**
 * @description
 * This module sets all configuration
 *
 * policyCompassConfig is exposed as a global variable in order to use it in
 * the main app.js file. If there's a way to do the same with dependency
 * injection, this should be fixed.
 */

// Configuration for remote services
var remotePolicyCompassConfig = {
    'URL': '/api/v1',
    'METRICS_MANAGER_URL': 'https://services-dev.policycompass.eu/api/v1/metricsmanager',
    'VISUALIZATIONS_MANAGER_URL': 'https://services-dev.policycompass.eu/api/v1/visualizationsmanager',
    'EVENTS_MANAGER_URL': 'https://services-dev.policycompass.eu/api/v1/eventsmanager',
    'REFERENCE_POOL_URL': 'https://services-dev.policycompass.eu/api/v1/references',
    'FCM_URL': 'https://alpha.policycompass.eu/api/v1/fcmmanager',
    'ELASTIC_URL' : 'https://search-dev.policycompass.eu/',
    'ELASTIC_INDEX_NAME' : 'policycompass_search',
    'ENABLE_ADHOCRACY': true,
    'ADHOCRACY_BACKEND_URL': 'https://adhocracy-backend-dev.policycompass.eu',
    'ADHOCRACY_FRONTEND_URL': 'https://adhocracy-frontend-dev.policycompass.eu'
};

angular.module('pcApp.config', []).constant('API_CONF', remotePolicyCompassConfig);
