# travel_permit_reader

A new Flutter project.

## Dependencies

- Flutter: 3.19.5
- Kotlin: 2.*

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuration

### Homologation

In `cnb_client.dart` uses
```
static final String _host = 'https://assinatura-hml.e-notariado.org.br'; // HOMOLOGATION
```
In `crypto_util.dart` uses
```
static ECPublicKey _publicKeyV1 = ECPublicKey(
	_ecDomain.curve.createPoint(
		BigIntExt.fromBase64('hebj9X2FaROdv/g8iFhdk5ecfg6+lyaSTU9Jw2JOp8Q='),
		BigIntExt.fromBase64('A+jzLgtvtjAUpbNgNmBe3RZDHt1Ip8D9fte+Of17tNQ=')),
	_ecDomain);
```

### Development
Use a proxy to redirect to https development server
```
$ npm install -g http-server
# Runs proxy server on port 8080
$ http-server --proxy https://localhost:44354/ --proxy-options.secure false
```
In `cnb_client.dart` uses `<LOCAL_NETWORK_HOST>` to redirect to proxy server (eg. 192.168.1.100:8080)
```
static final String _host = 'http://<LOCAL_NETWORK_HOST>/'; // HOMOLOGATION
```
In `crypto_util.dart` uses the Homologation keys
