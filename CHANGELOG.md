## [Unreleased]

## [2.2.0]

- Expose merge counterparty Q-ids on the diff. When a revision's edit comment is `wbmergeitems-to:…||Q…` or `wbmergeitems-from:…||Q…`, the per-revision diff now includes a `:merge_target` or `:merge_source` field with the parsed Q-id. Only present on the actual merge revision; existing counter fields are unchanged. Lets consumers reason about which item was merged into which without re-fetching the comment — needed to count merges when the source item is no longer in the consumer's tracked-articles list (e.g. PetScan-driven dashboards excluding redirects).

## [2.1.0]

- Add configurable `User-Agent` for wikidata.org requests via `WikidataDiffAnalyzer.user_agent=`. Default identifies the gem; applications should override with their own so wikidata sysadmins can route any traffic concerns to the right party. Resolves anonymous-client 429s when running the spec suite or other unauthenticated callers.
- Refactor `WikidataDiffAnalyzer.analyze` to stream batch-by-batch: fetch one batch's revisions, compute their diffs, then drop the fetched content before moving to the next batch. Peak memory becomes a function of batch size rather than total input size — observed RSS peak drops from ~240 MB to ~25 MB on a 2000-rev input, and is now roughly constant regardless of input size at a given batch size.
- Within-batch parent-fetch dedupe: when a revision's parent ID is also among the current batch's input revisions, reuse the already-fetched content instead of re-fetching it as a parent. On bot-tier inputs this captures ~94% of the cross-batch parent-overlap the prior implementation paid for, translating to ~30% less data transferred per call without changing API call count.
- `analyze` no longer mutates its `revision_ids` argument (previously called `delete(0)` on the caller's array).

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