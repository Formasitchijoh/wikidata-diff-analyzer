## [Unreleased]

## [0.1.0] - 2023-05-22

- Initial release

## [0.1.1] 

- Solving errors and removing unnecessary print statements

## [2.0.0] 

- Adding support for lexeme and property

## [2.0.1]

- Minor issue upgrade

## [2.0.2]

- Minor issue upgrade

## [2.0.3]

- Add handling for queries that hit the MediaWiki response limit

## [2.0.4]

- Relax mediawiki_api version requirement

## [2.0.5]

- Memoize `Api.api_client` so callers share a single `MediawikiApi::Client` (and its underlying Faraday connection / keep-alive pool) instead of opening a fresh TCP+TLS connection per request