enum Environment { development, staging, production }

String apiUrl(Environment environment) {
  switch (environment) {
    case Environment.development:
      return 'jsonplaceholder.typicode.com';
    case Environment.staging:
      return 'jsonplaceholder.typicode.com';
    case Environment.production:
      return 'jsonplaceholder.typicode.com';
  }
}
