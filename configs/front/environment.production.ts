export const environment = {
  production: true,
  resourceApiUrl: 'http://localhost:5000/api/v1',
  authServiceUrl: 'http://localhost:8000/auth',
  wsUrl: 'ws://localhost:8888/ws',
  wsUseAuthHeader: false,
  wsQueueMessages: false,
  wsMaxRetryAttempts: 5,
  wsRetryDelay: 1000,
  wsMaxRetryDelay: 10000,
  wsEnabled: true,
};
