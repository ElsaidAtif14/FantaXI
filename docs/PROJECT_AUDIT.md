# FantaXI Project Audit

**Audit date:** 2026-10-19  
**Scope:** Read-only inspection of the current working tree. No source code, dependencies, tests, or configuration were changed.

## A. Executive Summary

FantaXI has a recognizable feature-first structure with repository interfaces, repository implementations, typed response models, Cubits, and route-scoped providers. API calls are centralized through a shared `DioClient`; repositories are shared by GetIt, while each page normally creates its own Cubits. The separation is useful, but the page-local ownership means shared FPL resources are fetched again when a feature route is entered, and there is no shared cache or in-flight request deduplication.

The highest-impact confirmed functional issue is the standalone Live route: it creates Picks, Live, and Bootstrap Cubits, but does not load picks or live data. Its listener and refresh action both depend on picks reaching `PicksLoaded`, which this route never causes. The route therefore has no normal path to its loaded UI. Other concrete issues include error screens whose retry controls do nothing and production-wide HTTP body/header logging.

The main performance concern is repeated network traffic from route-scoped Cubits—most notably Bootstrap requests across Home, Picks, Market, and Live, plus manager/picks/live requests when navigating between Home and Picks. These are code-supported repeated paths, but their real-world request count depends on navigation and refresh behavior; runtime instrumentation is required to measure them. A separate current-working-tree change removes the Market header while leaving the manager fetch in place, making the manager request unused on that screen.

Architecture is generally layered, but current screens own some persistence orchestration, the Picks model imports a History feature data model, and Cubits do not protect most awaited loads against completion after provider disposal or against out-of-order responses. There is no evidence of an embedded API credential. Release signing and application identifiers remain development defaults.

Verification was limited to static analysis and the existing test suite. `flutter analyze` completed with five issues (two infos, three warnings); `flutter test` failed both existing tests. No app launch, live API trace, device build, or DevTools request-count measurement was performed. Static analysis alone cannot establish actual duplicate HTTP request counts.

**Finding counts:** 0 Critical, 1 High, 9 Medium, 4 Low. No P0 finding.

## B. Project Architecture Map

### Application and infrastructure

- `lib/main.dart` initializes Flutter bindings, installs `CustomBlocObserver`, awaits GetIt initialization, then runs `MyApp` with `MaterialApp.router`.
- `lib/core/di/injection.dart` registers one lazy `DioClient` and lazy-singleton repository implementations. All six API Cubit types—Manager, League, History, Picks, Bootstrap, and Live—are GetIt factories, so each `BlocProvider(create: ...)` receives a new instance.
- `lib/core/network/dio_client.dart` configures the FPL API base URL, 15-second connect and receive timeouts, JSON headers, and a `LogInterceptor`. It exposes a dynamically typed GET method. It has no cache, retry, deduplication, or cancellation-token policy.
- `lib/core/constants/app_constants.dart` centralizes the base URL, six endpoint builders, local preference keys, and image URL bases.
- `lib/core/error/` defines the error model, exception mapping, and `Failure`. Each repository converts server exceptions and other thrown errors to `Either<Failure, Model>`.
- `lib/core/router/app_router.dart` constructs the routes for Splash, Onboarding, Home, League, History, Picks, Live, and Market. League ID is parsed with `int.parse`; Picks accepts optional `entryId` and `gw` query parameters with `int.tryParse`.

### Features and data responsibilities

| Feature | Responsibility and data path |
|---|---|
| Bootstrap | Fetches `/bootstrap-static/`; models players and teams and builds ID-indexed maps used by Home, Picks, Live, and Market. |
| Manager | Fetches `/entry/{id}/`; maps manager totals, current event, leagues, and cup matches. Used by Home, Picks, and (in the current working tree) Market. |
| Picks | Fetches `/entry/{id}/event/{gw}/picks/`; models team picks, automatic substitutions, active chip, and entry event history. |
| Live | Fetches `/event/{gw}/live/`; maps per-player live statistics. Home and Picks request it alongside picks. |
| League | Fetches `/leagues-classic/{leagueId}/standings/?page_standings={page}`; Cubit merges later pages and retains loaded data on a pagination failure. |
| History | Fetches `/entry/{id}/history/`; models current-season event history and chip usage. |
| Home | Composes manager, bootstrap, picks, and live state into dashboard cards and manager league summaries. It has no independent repository. |
| Market | Uses Bootstrap player/team data for in-memory search, filtering, sorting, and player comparisons. It has no independent repository; current code also loads Manager data. |
| Onboarding / Splash | Onboarding validates and persists a numeric entry ID; Splash reads the preference and routes to Home or Onboarding. |

### Cross-feature dependencies and screen composition

- `GameWeekPicksModel` imports `EventHistory` through the History feature's data-model export for the picks response's `entry_history` field (`lib/features/picks/data/models/gameweek_picks_model.dart:1`).
- Home and Picks each create their own Manager, Bootstrap, Picks, and Live Cubits. Market creates Bootstrap and Manager Cubits. Live creates Bootstrap, Picks, and Live Cubits. History and League create their respective Cubits.
- The route providers use `BlocProvider(create: ...)`; no `BlocProvider.value` use was found in the route flows. Provider-owned Cubits are closed when their route subtree is disposed. Repositories and the Dio client remain shared singletons.
- `AppNavigationDock` uses `context.go` for navigation. The Live destination is commented out of the dock even though `/live` remains registered.

## C. API Request Inventory

| Endpoint or operation | Triggering screen | Cubit | Repository/data source | Parameters | Potential duplicate path | Evidence |
|---|---|---|---|---|---|---|
| `GET /bootstrap-static/` | Home | Bootstrap | `BootstrapRepositoryImpl` → `DioClient` | None | Also requested on Picks, Market, and Live route creation; no shared cache or in-flight deduplication. | `home_screen.dart:36`; `picks_screen.dart:32`; `market_screen.dart:16`; `live_screen.dart:27`; repository `bootstrap_repository_impl.dart:15` |
| `GET /entry/{id}/` | Home | Manager | `ManagerRepositoryImpl` → `DioClient` | Persisted entry ID | Picks independently loads the same entry. Market also loads it in the current working tree. Home manager refresh triggers another Manager load and then its listener requests picks/live again. | `home_screen.dart:57`; `picks_screen.dart:48`; `market_screen.dart:39`; repository `manager_repository_impl.dart:16` |
| `GET /entry/{id}/history/` | History | History | `HistoryRepositoryImpl` → `DioClient` | Persisted entry ID | May repeat if `HistoryScreen` rebuilds with a new inline Future; the screen calls `loadHistory` from the FutureBuilder builder whenever the future completes with data. Requires runtime confirmation for actual frequency. | `history_screen.dart:16-22`; repository `history_repository_impl.dart:16` |
| `GET /entry/{id}/event/{gw}/picks/` | Home, Picks | Picks | `PicksRepositoryImpl` → `DioClient` | Manager/entry ID and gameweek | Home requests on each successful Manager load; Picks requests after Manager and Bootstrap are loaded, on gameweek changes, and on retry. The same entry/gameweek can therefore be fetched again across page navigation or a Home manager refresh. | `home_screen.dart:40-48`; `picks_view.dart:187-212`; repository `picks_repository_impl.dart:19` |
| `GET /leagues-classic/{leagueId}/standings/` | League | League | `LeagueRepositoryImpl` → `DioClient` | Path league ID; query `page_standings`, default `1`, incremented by Cubit | Re-entering a League route creates a new Cubit and fetches page 1 again. Each next-page action uses a different page parameter and is a legitimate distinct request. | `league_screen.dart:12-15`; `league_repository_impl.dart:17-22`; `league_cubit.dart:14-21,24-36` |
| `GET /event/{gw}/live/` | Home, Picks; conditionally Live | Live | `LiveRepositoryImpl` → `DioClient` | Gameweek | Home issues this on every successful Manager load; Picks issues it with each Picks load/gameweek change. Live has a listener/refresh path but cannot normally reach it because its own Picks Cubit is never loaded. | `home_screen.dart:40-48`; `picks_view.dart:187-212`; `live_screen.dart:57,67-70`; repository `live_repository_impl.dart:16` |

No POST or other mutation endpoint was found in the inspected application code. The client currently makes only GET calls.

## D. Cubit and Provider Lifecycle Map

| Cubit | Creation location and owner | Consumers / initialization | Disposal and duplication notes |
|---|---|---|---|
| `BootstrapCubit` | Factory from GetIt; created by Home, Picks, Market, and Live page providers. | Loads immediately in each of those four pages. Read by Home, Picks, Live, and Market UI. | Each page owns a separate instance; exiting the page disposes it. No shared result cache or request coalescing. |
| `ManagerCubit` | Factory; created by Home, Picks, and Market. | Home starts after reading SharedPreferences; Picks starts from query/persisted ID; Market starts in `_MarketManagerLoader.initState`. Home listens for `ManagerLoaded` to load Picks and Live. | The same ID can be loaded independently in multiple screens. Market's data is currently not used to render its removed header (see API-003). |
| `PicksCubit` | Factory; created by Home, Picks, and Live. | Home loads on each `ManagerLoaded`. Picks waits for loaded Bootstrap and Manager, then loads the selected gameweek. Live only listens for Picks state and never initiates its own Picks load. | Route-scoped instances mean data is not shared across pages. No sequence token prevents an older gameweek response from replacing a newer one. |
| `LiveCubit` | Factory; created by Home, Picks, and Live. | Home and Picks request live data with the selected/current gameweek. Live route's listener and refresh control depend on `PicksLoaded`. | No cache/cancellation. Route-local Live in `/live` remains initial unless a Picks load is added. |
| `HistoryCubit` | Factory; created by `HistoryScreen`'s `BlocProvider`. | `HistoryScreen` calls `loadHistory` inside its FutureBuilder builder after SharedPreferences resolves. `HistoryViewBody` consumes the state. | Provider closes it on route disposal. The load trigger is tied to builder execution rather than a one-time lifecycle event. |
| `LeagueCubit` | Factory; created by `LeagueScreen` and immediately calls `loadLeague(leagueId)`. | `LeagueViewBody` renders and requests next pages through the load-more control. | Provider closes it on route disposal. `loadNextPage` guards duplicate pagination while loading and checks that the original response/page is still current; initial loads do not have equivalent stale-result protection. |

**Provider lifecycle observations:** no use of `BlocProvider.value` was identified in these route surfaces; `create` ownership is appropriate for the page-local instances. The main concern is not accidental reuse/closure but independent route-scoped ownership, absent cancellation for ongoing requests, and absent stale-response protection in the initial-load Cubits.

## E. Findings and Issues

### STATE-001 — Standalone Live route never initializes its required data

1. **Severity:** High  
2. **Confidence:** Confirmed  
3. **Category:** Functional / state lifecycle  
4. **Affected files and symbols:** `lib/features/live/presentation/pages/live_screen.dart`, `LiveScreen`, `_LiveView`; `lib/shared/widgets/app_navigation_dock.dart`, `AppNavigationDock`.  
5. **Evidence:** Live creates Picks, Live, and Bootstrap providers at lines 23-27, but its FutureBuilder ignores the preference snapshot and returns `_LiveView` at lines 29-35. `LiveCubit.loadLive` is called only from a refresh button shown when state is `PicksLoaded` (lines 51-62) or a listener receiving `PicksLoaded` (lines 67-70). No call to `PicksCubit.loadPicks` exists in this screen. The Live destination is commented out in the dock at `app_navigation_dock.dart:33`.  
6. **Current behavior:** Opening `/live` loads Bootstrap only. Picks stays `PicksInitial`, so the normal loaded UI condition at lines 107-108 cannot be satisfied and live data is not fetched.  
7. **Problem:** The route has no working initialization path for the gameweek picks or live points it requires. It is also not reachable from the navigation dock.  
8. **Reproduction conditions:** Navigate directly to `/live` with a saved manager ID; wait for Bootstrap.  
9. **Impact:** The Live screen remains blank/nonfunctional; its refresh action is unavailable because it depends on Picks being loaded.  
10. **Recommended direction:** Pass a resolved manager ID into an explicit initialization flow, load manager/picks/live as required, and decide whether Live belongs in the dock. Keep gameweek selection consistent with the data loaded.  
11. **Verification method:** Add a widget/Cubit test with fake repositories asserting a saved manager ID results in picks and live requests and that loaded/error states render. Confirm direct-route and dock navigation behavior.

### API-001 — Bootstrap data is refetched independently by multiple routes

1. **Severity:** Medium  
2. **Confidence:** Strongly suspected (page-level calls confirmed; counts depend on navigation)  
3. **Category:** API traffic / caching  
4. **Affected files and symbols:** `HomeScreen`, `PicksScreen`, `MarketScreen`, `LiveScreen`, `BootstrapCubit`, `BootstrapRepositoryImpl`.  
5. **Evidence:** Each page creates a factory Cubit and starts `loadBootstrap`: `home_screen.dart:36`, `picks_screen.dart:32`, `market_screen.dart:16`, `live_screen.dart:27`. The repository always performs `_dioClient.get(AppConstants.bootstrapStatic)` at `bootstrap_repository_impl.dart:15`. Repositories are singleton registrations, but no result cache exists in them (`core/di/injection.dart:29-48`).  
6. **Current behavior:** Each route entry performs its own Bootstrap request. `context.go` and page-owned providers do not share the previous route's Cubit state.  
7. **Problem:** The relatively large common player/team dataset can be transferred and parsed repeatedly even when its contents have not changed. No in-flight deduplication exists if consumers overlap.  
8. **Reproduction conditions:** Open Home, then Picks, Market, or Live; navigate away and reopen a feature.  
9. **Impact:** Additional network traffic, latency, response parsing, and loading intervals. The exact number of HTTP requests per session is not established by static inspection.  
10. **Recommended direction:** Evaluate a repository-level freshness-aware cache or shared Bootstrap owner with explicit invalidation/refresh behavior. Avoid making the Cubit globally permanent without defining lifecycle and freshness.  
11. **Verification method:** Instrument endpoint counts with a test adapter or network log across the route sequence; verify the cached path avoids redundant loads while explicit refresh still fetches current data.

### API-002 — Home refresh and Picks navigation repeat manager, picks, and live requests

1. **Severity:** Medium  
2. **Confidence:** Strongly suspected  
3. **Category:** API traffic / refresh behavior  
4. **Affected files and symbols:** `HomeScreen` listener, `HomeBody` manager refresh, `PicksScreen`, `PicksView`.  
5. **Evidence:** Home's listener starts Picks and Live whenever it observes `ManagerLoaded` (`home_screen.dart:40-48`). The Home refresh action calls `ManagerCubit.loadManager` (`home_body.dart:92`; error retry at `132`). Picks creates a separate Manager/Picks/Live set and starts a manager load from its own saved/route ID (`picks_screen.dart:31-48`); after both Manager and Bootstrap load, `_checkAndLoadPicks` starts Picks and Live (`picks_view.dart:184-195`).  
6. **Current behavior:** A Home manager refresh reissues the current Picks and Live calls after the manager request succeeds. Entering Picks independently loads the manager and the same current gameweek resources already loaded for Home.  
7. **Problem:** These code paths can request identical endpoint/parameter pairs without an explicit user refresh of Picks/Live or a shared in-flight result. This is a confirmed duplicate-capable path, not proof that every session sees simultaneous duplicates.  
8. **Reproduction conditions:** From Home, refresh the manager or navigate to Picks for the same manager and gameweek; capture request URLs and parameters.  
9. **Impact:** Unnecessary API traffic and reload/flicker; repeated Live requests are especially likely during manager refresh.  
10. **Recommended direction:** Make refresh semantics explicit: manager refresh need not automatically refetch Picks/Live unless the manager's active gameweek or identity changed. Consider carrying fresh state across navigation or using a scoped shared data owner/cache.  
11. **Verification method:** Count `/entry/{id}/`, `/entry/{id}/event/{gw}/picks/`, and `/event/{gw}/live/` before/after manager refresh and Home→Picks navigation; assert refresh and gameweek-change cases still fetch when intended.

### API-003 — Market still fetches manager data that the current view no longer uses

1. **Severity:** Low  
2. **Confidence:** Confirmed for the current working tree  
3. **Category:** Unnecessary request / working-tree change  
4. **Affected files and symbols:** `lib/features/market/presentation/pages/market_screen.dart`, `_MarketManagerLoader`; `lib/features/market/presentation/widgets/market_view_body.dart`, `MarketViewBody`.  
5. **Evidence:** Market creates a ManagerCubit and loads the saved ID in `market_screen.dart:17-39`. `market_view_body.dart:99-103` still watches the Manager state and computes `bank` and `gameweek`, but neither value is used. The current uncommitted diff removes the `MarketViewHeader` that previously consumed them.  
6. **Current behavior:** Entering Market with a saved positive ID fetches `/entry/{id}/`; the current view does not display or otherwise use the resulting manager fields.  
7. **Problem:** The manager request and provider are unnecessary for the current Market UI. Analyzer warnings for the unused import and local variables also occur in this modified file.  
8. **Reproduction conditions:** Enter Market with a stored manager ID and inspect the request log.  
9. **Impact:** One avoidable manager endpoint request per Market entry, plus unused state dependency.  
10. **Recommended direction:** Reassess the Manager provider/loader based on the intended post-diff Market design; retain it only if the data is used elsewhere in that screen.  
11. **Verification method:** With the intended Market UI, assert whether `/entry/{id}/` is required; confirm analyzer warnings disappear if the unnecessary dependency is removed.  
**Working-tree note:** `android/app/src/main/AndroidManifest.xml` and this Market widget are already modified by the user. The report does not alter either file.

### API-004 — History load is coupled to a rebuildable FutureBuilder builder

1. **Severity:** Medium  
2. **Confidence:** Needs verification for actual duplicate frequency  
3. **Category:** API traffic / lifecycle  
4. **Affected files and symbols:** `HistoryScreen.build`.  
5. **Evidence:** `history_screen.dart:16-22` constructs the SharedPreferences Future inline and calls `context.read<HistoryCubit>().loadHistory(...)` from the FutureBuilder builder whenever `snap.hasData`.  
6. **Current behavior:** The screen requests history from the builder rather than a one-time initialization callback. A parent rebuild creates a new Future; its successful completion runs the builder and calls `loadHistory` again.  
7. **Problem:** Request frequency is coupled to widget rebuild behavior and is easy to increase accidentally. The intended history request is normally keyed to the persisted entry ID, not each build.  
8. **Reproduction conditions:** Cause the `HistoryScreen` subtree/ancestor to rebuild after the preference Future completes and compare history endpoint counts.  
9. **Impact:** Potential duplicate `/entry/{id}/history/` traffic and re-entered loading state.  
10. **Recommended direction:** Resolve the preference once and trigger loading from a stable lifecycle/action boundary; keep an explicit retry path separate.  
11. **Verification method:** Add a widget test that pumps/rebuilds the screen multiple times and asserts one initial repository call; separately assert retry produces one additional call.

### STATE-002 — Async loads can emit after route-owned Cubits are closed

1. **Severity:** Medium  
2. **Confidence:** Strongly suspected (missing guards confirmed; timing requires runtime)  
3. **Category:** State lifecycle / reliability  
4. **Affected files and symbols:** Bootstrap, Manager, History, Picks, Live, and initial League Cubits.  
5. **Evidence:** For example, `picks_cubit.dart:13-18`, `live_cubit.dart:13-17`, `manager_cubit.dart:13-17`, and `history_cubit.dart:13-17` await repositories and then emit with no `isClosed` check or cancellation. League initial load similarly awaits and emits at `league_cubit.dart:16-20`; pagination alone has a closed/current-state guard at lines 48-69. Providers are route-owned and close their `create` Cubits when disposed.  
6. **Current behavior:** A request continues through the shared Dio client after a route is left. If it completes after the Cubit has been closed, the continuation attempts to emit on the closed Cubit.  
7. **Problem:** This can raise an uncaught `StateError` during normal navigation under slow network conditions. In-flight work is also wasted.  
8. **Reproduction conditions:** Start a delayed API request, navigate away before it completes, then allow the response to resolve.  
9. **Impact:** Runtime errors, unnecessary work, and possible noisy logs/crash reporting.  
10. **Recommended direction:** Add request cancellation or stale/closed guards using the existing Cubit lifecycle and Dio cancellation support; apply consistently to initial loads as well as pagination.  
11. **Verification method:** Use a delayed fake repository and close the Cubit before completion; assert no post-close emission and that cancellation/stale responses are handled.

### STATE-003 — Out-of-order gameweek responses can replace newer Picks/Live state

1. **Severity:** Medium  
2. **Confidence:** Strongly suspected  
3. **Category:** Data correctness / race condition  
4. **Affected files and symbols:** `PicksView._changeGameweek`, `PicksCubit.loadPicks`, `LiveCubit.loadLive`.  
5. **Evidence:** `_changeGameweek` starts both loads without awaiting (`picks_view.dart:199-205`); each Cubit emits whichever repository result completes (`picks_cubit.dart:12-18`, `live_cubit.dart:12-17`). Neither state records/validates the requested gameweek before accepting a result.  
6. **Current behavior:** Rapid gameweek changes can leave multiple requests in flight. The later response can belong to an earlier selected gameweek. The UI continues to display `_currentGw` independently of the loaded result.  
7. **Problem:** Picks and live points may be shown under the wrong gameweek label if requests complete out of order.  
8. **Reproduction conditions:** Add response delays so the first gameweek request completes after the second request.  
9. **Impact:** Misleading gameweek points, squad, or live stats.  
10. **Recommended direction:** Associate each result with its requested parameters and discard stale responses, or cancel superseded requests. Keep Picks and Live synchronized to the selected gameweek.  
11. **Verification method:** Deterministic Cubit tests with reversed completion order; assert only the latest selected gameweek is rendered.

### UX-001 — History and Market error retry buttons do not retry

1. **Severity:** Medium  
2. **Confidence:** Confirmed  
3. **Category:** Error recovery / user experience  
4. **Affected files and symbols:** `HistoryViewBody`; `MarketViewBody`.  
5. **Evidence:** History error state displays “Try again” with `onAction: () {}` at `history_view_body.dart:46-52`. Market Bootstrap error state displays “Try again+” with `onAction: () {}` at `market_view_body.dart:87-93`.  
6. **Current behavior:** Tapping either visible retry control performs no action.  
7. **Problem:** Users cannot recover from transient network errors from these screens without leaving/re-entering or restarting the flow.  
8. **Reproduction conditions:** Cause the corresponding request to fail, then tap the displayed action.  
9. **Impact:** Stuck error UI and avoidable navigation/workarounds.  
10. **Recommended direction:** Wire the controls to the relevant Cubit's load method with the retained entry ID, or remove/disable the action if retry is intentionally unavailable.  
11. **Verification method:** Widget tests tap each control and assert exactly one new repository call and correct loaded/error transition.

### SEC-001 — HTTP headers and response bodies are logged without a release guard

1. **Severity:** Medium  
2. **Confidence:** Confirmed  
3. **Category:** Security / privacy  
4. **Affected files and symbols:** `lib/core/network/dio_client.dart`, `DioClient`.  
5. **Evidence:** A `LogInterceptor` is always registered at lines 23-29 with `requestHeader: true`, `requestBody: true`, `responseBody: true`, and error logging enabled; no build-mode guard is present. Manager and history endpoints can return public manager/team profile details.  
6. **Current behavior:** Requests and responses are logged in debug and release configurations using the interceptor's default logging callback.  
7. **Problem:** Profile/response data and request metadata may be exposed through device logs or diagnostic collection. No API credential was observed in the inspected configuration, but broad body logging is still unnecessary data exposure.  
8. **Reproduction conditions:** Run a build with logging enabled and inspect platform logs after manager/history requests.  
9. **Impact:** Privacy exposure and larger/noisier production logs.  
10. **Recommended direction:** Restrict detailed logging to development builds and redact sensitive fields; use structured, minimal request diagnostics in production.  
11. **Verification method:** Inspect release logs and assert response bodies and headers are not logged; verify development diagnostics remain useful without including private response fields.

### CONFIG-001 — Android release signing and package ID remain development defaults

1. **Severity:** Medium  
2. **Confidence:** Confirmed  
3. **Category:** Release configuration  
4. **Affected files and symbols:** `android/app/build.gradle.kts`, Android `defaultConfig` and `release` build type.  
5. **Evidence:** `applicationId` is `com.example.fantasy` at line 24; release `signingConfig` uses the debug signing configuration at line 37.  
6. **Current behavior:** The release variant is configured with a placeholder application ID and debug key.  
7. **Problem:** This is not suitable for a production identity or normal app-store release/update signing. It is a release-readiness issue, not evidence of an exposed signing secret.  
8. **Reproduction conditions:** Build and inspect the Android release APK/AAB metadata and signing certificate.  
9. **Impact:** Distribution/update blockers and unsuitable signing posture if treated as a production artifact.  
10. **Recommended direction:** Before distribution, set a unique production application ID and configure protected release signing outside source control.  
11. **Verification method:** Build a release artifact with the intended package ID; verify its certificate and confirm repeat builds can update the same application.

### BUG-001 — Picks accepts unbounded gameweek query parameters

1. **Severity:** Low  
2. **Confidence:** Confirmed for request construction; API response behavior needs verification  
3. **Category:** Input validation / data correctness  
4. **Affected files and symbols:** `AppRouter` Picks route; `PicksScreen`; `PicksView`.  
5. **Evidence:** `app_router.dart:44-48` parses `gw` but does not validate a range. `PicksView` initializes `_currentGw` directly from `widget.initialGw` at lines 37-39 and sends it to Picks/Live at lines 187-195. Previous/next button checks in `squad_content_view.dart:51-54` only constrain button presses, not a deep-link value.  
6. **Current behavior:** A parsed `gw=0`, negative value, or future value can be passed to the Picks and Live repositories for a valid entry ID.  
7. **Problem:** Invalid links can cause avoidable API failures or misleading gameweek labels. Whether a particular value is accepted by the remote API is not inferred here.  
8. **Reproduction conditions:** Open `/picks?entryId=<valid-id>&gw=0` or use another out-of-range integer.  
9. **Impact:** Unnecessary failed requests and confusing UI.  
10. **Recommended direction:** Validate the supplied gameweek against known season events/manager history and choose a documented fallback or show an invalid-link state.  
11. **Verification method:** Route/widget tests for null, valid, zero, negative, and future values; record the resulting endpoint parameters.

### ARCH-001 — Picks response model depends on another feature's data model

1. **Severity:** Low  
2. **Confidence:** Confirmed  
3. **Category:** Architecture / feature coupling  
4. **Affected files and symbols:** `lib/features/picks/data/models/gameweek_picks_model.dart`; `lib/features/history/data/models/manager_history_model.dart`; `EventHistory`.  
5. **Evidence:** Picks imports the History model export at `gameweek_picks_model.dart:1` and uses `EventHistory` for the picks response's `entry_history`.  
6. **Current behavior:** The Picks data model relies on a concrete model owned and exported by the History feature.  
7. **Problem:** The model's ownership implies History-specific semantics even though the type is used to parse a Picks response; this creates unnecessary feature coupling and makes either feature harder to evolve independently.  
8. **Reproduction conditions:** A change to History's `EventHistory` schema affects parsing/compilation for Picks.  
9. **Impact:** Maintainability and test isolation; no current runtime defect established.  
10. **Recommended direction:** If the model is truly shared, move it to a neutral shared/domain location; otherwise define the response-owned type in the feature that owns the payload. Do not duplicate it without confirming semantic differences.  
11. **Verification method:** Confirm both API payloads and usage; add model parsing tests before any ownership change.

### TEST-001 — Existing test suite is failing and does not validate app behavior

1. **Severity:** Medium  
2. **Confidence:** Confirmed by `flutter test`  
3. **Category:** Testing / reliability  
4. **Affected files and symbols:** `test/widget_test.dart`; `test/core/error/expentions_test.dart`; `handleDioException`.  
5. **Evidence:** The widget test is still named “Counter increments smoke test” and expects text `0`/`1` (`widget_test.dart:14-28`), but `MyApp` is the FPL app, not a counter. The exception test expects an Arabic message (`expentions_test.dart:13-25`) while the actual connection exception message is English (`lib/core/error/expentions.dart:82-87`).  
6. **Current behavior:** Both tests fail: the exception assertion reports the language mismatch, and the widget test cannot find `0`.  
7. **Problem:** The suite provides no passing smoke-test baseline and does not exercise the main feature flows.  
8. **Reproduction conditions:** Run `flutter test` in the current working tree.  
9. **Impact:** Regressions in network, Cubit, routing, and UI behavior are not effectively guarded.  
10. **Recommended direction:** Replace the starter counter test with an app-appropriate test using controlled dependencies; align the expected exception message with the intended product language; add focused tests for request triggers, retries, races, and pagination.  
11. **Verification method:** Run the targeted tests and then the complete `flutter test`; require a passing suite before relying on it for changes.

### TEST-002 — High-risk data flows have no focused automated coverage

1. **Severity:** Low  
2. **Confidence:** Confirmed from the test tree  
3. **Category:** Test coverage  
4. **Affected files and symbols:** `test/` (currently only the two tests above); API repositories and feature Cubits/screens.  
5. **Evidence:** The tracked test tree contains only `widget_test.dart` and `core/error/expentions_test.dart`; no repository, Cubit, navigation/provider lifecycle, pagination, or request-count tests were found.  
6. **Current behavior:** Data-flow behavior is primarily validated only by implementation inspection and manual runtime use.  
7. **Problem:** Duplicate requests, request races, route disposal, and refresh behavior can regress unnoticed.  
8. **Reproduction conditions:** Change endpoint triggers or route provider ownership without corresponding tests.  
9. **Impact:** Reliability and maintainability risk.  
10. **Recommended direction:** Add tests incrementally around the highest-risk flows rather than attempting broad UI snapshots.  
11. **Verification method:** Use fake repositories and a Dio adapter to assert endpoint/parameter counts and state behavior without requiring the public API.

## F. Duplicate Request Analysis

### Bootstrap: four independent page-scoped paths

```text
Home → Bootstrap provider → BootstrapCubit.loadBootstrap
     → BootstrapRepositoryImpl → GET /bootstrap-static/
Picks → Bootstrap provider → BootstrapCubit.loadBootstrap
      → same repository → GET /bootstrap-static/
Market → Bootstrap provider → BootstrapCubit.loadBootstrap
       → same repository → GET /bootstrap-static/
Live → Bootstrap provider → BootstrapCubit.loadBootstrap
     → same repository → GET /bootstrap-static/
```

These are distinct Cubit instances and distinct repository invocations. The GetIt singleton repository shares only the client; it has no response or in-flight cache. Requests normally happen when the relevant route is created, so repeated navigation is confirmed as a repeated-request path. Simultaneous requests require overlapping routes or another lifecycle trigger and were not measured.

### Home to Picks: manager, picks, and live

```text
Home → ManagerCubit.loadManager(savedId)
     → GET /entry/{id}/
     → ManagerLoaded listener
     → GET /entry/{id}/event/{currentGw}/picks/
     → GET /event/{currentGw}/live/

Picks → new ManagerCubit.loadManager(savedId or route ID)
      → GET /entry/{id}/
      → when Manager + Bootstrap loaded:
      → GET /entry/{id}/event/{currentGw}/picks/
      → GET /event/{currentGw}/live/
```

Home and Picks own different Cubits. For the same entry/gameweek these can repeat the same paths after route navigation. Home's manager refresh also runs the Picks/Live listener again. These calls could be intentional refreshes, but the code currently ties them to every `ManagerLoaded`, not only a changed manager identity/gameweek.

### Market: manager request with no current consumer

```text
Market → Manager provider → SharedPreferences entry ID
       → ManagerCubit.loadManager(id)
       → GET /entry/{id}/
```

In the current working tree, the values formerly passed to `MarketViewHeader` are computed but unused. This is a confirmed unnecessary call for the present view, subject to the user’s in-progress UI change.

### History: builder-triggered load

```text
History → FutureBuilder(SharedPreferences Future)
        → builder when snap.hasData
        → HistoryCubit.loadHistory(id)
        → GET /entry/{id}/history/
```

The Future and load call are in `build`; this is a potential repeated request path on rebuild, not a measured runtime count. No cache/in-flight sharing exists.

### Live: route path is incomplete, not a proven duplicate

```text
Live → BootstrapCubit.loadBootstrap → GET /bootstrap-static/
     → PicksCubit remains PicksInitial
     → no normal Picks or Live request
```

The Live listener and refresh button are downstream of a `PicksLoaded` event that this route does not create. Therefore do not count `/event/{gw}/live/` as a request from normal Live route entry; the request exists from Home and Picks paths instead.

### Legitimate distinct requests and limitations

- League pagination uses a different `page_standings` value per page; these are legitimate page requests. `loadNextPage` prevents a second concurrent call while the page is loading.
- Picks and Live calls for a deliberately selected different gameweek are not duplicates solely because the endpoint pattern is the same.
- Home refresh and explicit retry are legitimate user actions, but repeated side effects tied to a broader state transition should be measured and reviewed.
- No automatic polling loop was found. No retries or Dio request cancellation policy were found.
- Static analysis cannot reveal server request counts, response caching outside the app, or network-layer retries. Use a request adapter, proxy, or DevTools/log trace to establish counts.

## G. Prioritized Remediation Roadmap

### P0 — Critical

No P0 findings.

### P1 — High

| Finding | Dependencies | Expected benefit | Regression risk |
|---|---|---|---|
| STATE-001 | Decide intended Live manager/gameweek source; test fake repository flow. | Restore the route's core functionality and make loading/error states reachable. | Incorrect manager/gameweek initialization or duplicate Live requests if existing Home/Picks behavior is copied without coordination. |

### P2 — Medium

| Finding | Dependencies | Expected benefit | Regression risk |
|---|---|---|---|
| API-001, API-002 | First define freshness, refresh, and route ownership; then add request-count tests. | Reduce repeated Bootstrap/manager/picks/live traffic while preserving explicit refresh. | Stale team/player or live data if cache TTL/invalidation is too broad; accidentally suppressing user-requested refresh. |
| API-004 | Stabilize preference Future and make load/retry explicit. | Prevent rebuild-driven History requests. | Failing to load after an entry ID changes unless the key is updated. |
| STATE-002, STATE-003 | Define Cubit cancellation/stale-result policy; add delayed fake repository tests. | Avoid post-dispose exceptions and mismatched gameweek state. | Dropping a valid latest result or canceling data needed by another consumer. |
| UX-001 | Retain entry/gameweek inputs for retries. | Let users recover from temporary failures. | Repeated rapid taps can trigger concurrent retries unless guarded. |
| SEC-001 | Choose development vs production logging policy and redact fields. | Limit exposure of response data through platform logs. | Less diagnostic detail if redaction/filtering is overly aggressive. |
| CONFIG-001 | Requires production bundle identity and protected signing credentials. | Enable valid store distribution and updates. | Existing install identity changes if package ID is changed after distribution. |
| TEST-001 | Decide intended user-facing language for exception messages. | Restore a meaningful passing test baseline. | Tests may encode the wrong language/product contract if expectations are changed without a product decision. |

**Suggested implementation order:** (1) repair Live initialization and replace the stale widget smoke test; (2) wire error retries and stabilize History loading; (3) guard async Cubit loads and out-of-order gameweek results; (4) add request-count tests, then implement a freshness-aware shared data strategy and remove the Market-only unused Manager path if the current design stands; (5) disable/redact release logging and prepare production Android identity/signing before distribution.

### P3 — Low

| Finding | Dependencies | Expected benefit | Regression risk |
|---|---|---|---|
| API-003 | Confirm intended Market header/design in the current working diff. | Remove one unnecessary manager request and unused state dependency. | Removing Manager data needed by a later Market design. |
| BUG-001 | Establish valid gameweek range and fallback UX. | Avoid requests built from invalid deep links. | Rejecting a historical gameweek that is valid for a manager but outside the current event. |
| ARCH-001 | Confirm whether Picks and History share identical event-history semantics. | Reduce feature ownership coupling. | Duplicate/contradictory model parsers if types are split without contract tests. |
| TEST-002 | Add fakes/adapters as tests are introduced. | Make critical behavior measurable and regression-resistant. | Excessive brittle UI tests; prefer focused Cubit/repository tests. |

## H. Verification Plan

1. **Request inventory and traffic:** Use a test `Dio` adapter or controlled repository fakes to record method, endpoint, query parameters, invocation time, and completion order. Exercise cold Home, Home→Picks, Home manager refresh, Picks gameweek change, Market, History rebuild/retry, and League pagination. Compare request counts before/after any cache or provider-scope change.
2. **Freshness and refresh:** Verify that ordinary route navigation reuses data only within the documented freshness window, while explicit refresh and manager/gameweek changes make the intended calls. Confirm a failed cached refresh does not permanently hide a prior usable result if stale-while-revalidate behavior is chosen.
3. **Cubit lifecycle:** Delay repository futures; close route providers before completion; confirm there are no emissions on closed Cubits and no uncaught `StateError`. Test cancellation and stale-result guards.
4. **Gameweek race:** Resolve requests in reverse order after selecting two gameweeks quickly. Assert the displayed label and Picks/Live payloads all correspond to the latest selection.
5. **UI recovery:** For History and Market, simulate failure, tap retry, and assert one additional repository invocation and a visible success/error transition. For Live, verify the route reaches loading, loaded, empty, and error states from a valid persisted entry.
6. **League paging:** Assert one initial page request, page increment only after success, no concurrent next-page request, retained rows on pagination error, and correct termination when no next page exists.
7. **Security/config:** Inspect a release run's platform logs for body/header leakage. Before distribution, verify Android application ID and release certificate on the generated artifact.
8. **Automated suite:** Replace the obsolete counter smoke test, resolve the language mismatch by an explicit product decision, then run `flutter analyze` and `flutter test`. For visual behavior, manually exercise device navigation after widget/Cubit tests pass.

No API request reduction should be claimed from code inspection alone. Record endpoint counts in the same navigation/retry scenarios before and after implementation and separately verify that explicit refresh and data freshness still work.

## I. Items Requiring Further Investigation

- Runtime request counts, overlapping route behavior, device/network caching, and remote response timing require instrumentation; they cannot be concluded from this static audit.
- The app was not launched, and no FPL API responses were captured. Current API field optionality, unusual season/off-season responses, and whether queried historical/future gameweeks are accepted remain unverified.
- The desired Live route entry behavior and whether Live should appear in the dock need product confirmation.
- The intended Market screen after the existing uncommitted header removal should be confirmed before treating the now-unused manager request as permanent design debt.
- The intended error-message language should be confirmed; implementation is English while one test expects Arabic.
- Production distribution target, Android package ID, release signing process, and any CI/environment-specific configuration were not provided. The audit found no API credential in the inspected source/configuration, but did not inspect external CI secrets or user-local environment state.
- Leaf presentation widgets were reviewed selectively at the data-flow and route boundaries; not every decorative widget was individually evaluated for visual polish or runtime performance.
- Current user changes were present in `android/app/src/main/AndroidManifest.xml` and `lib/features/market/presentation/widgets/market_view_body.dart`. They were preserved. The added Android `INTERNET` permission is present in the current manifest.

## Verification Results

| Command | Result |
|---|---|
| `flutter analyze` | Completed with exit code 1: **5 issues** — two infos (`unnecessary_underscores` in `history_chart.dart:240`) and three warnings (`unused_import` at `market_view_body.dart:12`; unused locals `bank` at line 100 and `gameweek` at line 102). No analyzer errors were reported. Market warnings are in a file with existing user changes. |
| `flutter test` | Completed with exit code 1: **both tests failed**. `expentions_test.dart` expected an Arabic connection message but implementation returned English. `widget_test.dart` is a counter-template test and failed to find text `0` in the actual app. |

The test results above are observations from the current working tree and were not repaired as part of this read-only audit.
