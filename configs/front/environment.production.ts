export const environment = {
  production: true,
  resourceApiUrl: 'https://REPLACE_ME_DOMAIN/api/nest',
  authServiceUrl: 'https://REPLACE_ME_DOMAIN/api/auth',
  wsUrl: 'wss://REPLACE_ME_DOMAIN/api/go/ws',
  wsUseAuthHeader: false,
  wsQueueMessages: false,
  wsMaxRetryAttempts: 5,
  wsRetryDelay: 1000,
  wsMaxRetryDelay: 10000,
  wsEnabled: true,
};
