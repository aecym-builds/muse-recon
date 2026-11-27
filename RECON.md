# Muse (`com.facebook.aura`) — static recon

## Target

| field | value |
|---|---|
| package | `com.facebook.aura` |
| label | `Muse` |
| versionName | **18.0.0.8.161** |
| versionCode | 1062301896 |
| minSdk / targetSdk / compileSdk | 29 / 37 / 37 |
| APK SHA-256 | `f2f9acb0dc0d8cc60d2322e3de6f02a0fb9b74c8b07eecb7d34c92c6ae5a51d3` |

Version note: the build requested was 17.0.0.10.160, which is not on this machine. The only `com.facebook.aura` APK present is 18.0.0.8.161 (verified from the decoded manifest). You confirmed to use it, so every finding below applies to **18.0.0.8.161**. Do not assume identical class names/line numbers for 17.0.0.10.160.

## Tools

| tool | version |
|---|---|
| apktool | 3.0.3 (`3.0.3-dirty`) |
| jadx | 1.5.1 |
| Java | OpenJDK 21.0.13.1 (`openjdk-21-x`) |
| platform | Termux/aarch64 (Android), no root |

Decode commands used (APK not modified):

```
apktool d -f -o apktool_out <apk>          # -Xmx3g
sh jadx/bin/jadx -d jadx_out --no-res --threads-count 2 --show-bad-code <apk>
```

Result: `apktool_out/` with 76,243 `.smali` files (per-dex counts match the DEX `class_defs_size` exactly), `jadx_out/` with Java sources.

## smali_selected archives

Total 111 MB, so split into 7 parts, each < 35 MB. Entry paths keep the `smali*/...` prefix, so unzipping them all into the `apktool_out/` root restores the original tree.

| part | contents | size |
|---|---|---|
| `smali_selected_part1.zip` | `smali/` (classes.dex) + `com/facebook`, `X`, `com/meta`, `com/instagram` | 19 MB |
| `smali_selected_part2.zip` | `smali_classes2/` | 16 MB |
| `smali_selected_part3.zip` | `smali_classes3/` | 17 MB |
| `smali_selected_part4.zip` | `smali_classes4/` | 17 MB |
| `smali_selected_part5.zip` | `smali_classes5/` | 17 MB |
| `smali_selected_part6.zip` | `smali_classes6/` | 17 MB |
| `smali_selected_part7.zip` | `smali_classes7/` | 7.4 MB |

Only `com/facebook/**`, `X/**` (obfuscated top-level), `com/meta/**`, `com/instagram/**` are included. Deliberately excluded: `androidx/`, `kotlin/`, `kotlinx/`, `org/`, `libraries/`, `bolts/`, `okhttp3/`, `exoplayer2/`, `javax/`, `android/`, `redex/`, and `secondary/` (`secondary/dexNN/Canary` are Redex canary stubs, not app code). Compression: `zip -9`.

---

## a) Settings screen

### Which code renders it

The settings destination is registered by `com.facebook.aura.navigation.entries.SettingsEntryProvider` and its screen content is `com.facebook.aura.navigation.entries.SettingsEntryProviderKt.SettingsScreenContent`:

- `apktool_out/smali_classes3/com/facebook/aura/navigation/entries/SettingsEntryProvider.smali` — `provideEntry(LX/1Ge;)V`, modal-flow scene
- `apktool_out/smali_classes3/com/facebook/aura/navigation/entries/SettingsEntryProviderKt.smali` — `SettingsScreenContent(Ljava/lang/String;LX/2d4;II)V` (line 72), builds `HatchSettingsConfig` and calls `HatchSettingsScreen`

The actual UI is a Compose screen in:

- `apktool_out/smali/com/facebook/aura/settings/HatchSettingsScreenKt.smali` — `HatchSettingsScreen(...)` (line 2773)
- `apktool_out/smali/com/facebook/aura/settings/HatchSettingsScreenKt$HatchSettingsScreen$22.smali` — the content lambda that invokes the static sections

### Static vs data-driven: both

The section skeleton is **static** — one composable call per section, in fixed order, inside `HatchSettingsScreen$22` (`invoke-static` targets, with line numbers in that file):

```
2214: Lcom/facebook/aura/settings/HatchSettingsScreenKt;->ConfidentialityAwareSettingsSection(...)
2302: Lcom/facebook/aura/settings/HatchSettingsScreenKt;->RedeemInviteCodeSection(...)
2352: Lcom/facebook/aura/settings/HatchSettingsScreenKt;->SupportAndLegalSection(...)
2379: Lcom/facebook/aura/settings/HatchSettingsScreenKt;->AccountsCenterSection(...)
2765: Lcom/facebook/aura/settings/HatchSettingsScreenKt;->LogOutSection(...)
2875: Lcom/facebook/aura/settings/HatchSettingsScreenKt;->InternalSettingsSection(...)
```

The *general rows* are **data-driven** by a contributor list, iterated in `HatchSettingsScreen` itself:

```smali
# HatchSettingsScreenKt.smali, inside HatchSettingsScreen()
sget-object v9, Lcom/facebook/aura/settings/api/SettingsGeneralRows;->INSTANCE:Lcom/facebook/aura/settings/api/SettingsGeneralRows;
invoke-virtual {v9}, Lcom/facebook/aura/settings/api/SettingsGeneralRows;->contributors()Ljava/util/List;
move-result-object v9
invoke-static {}, LX/001;->A11()Ljava/util/ArrayList;
move-result-object v15
invoke-interface {v9}, Ljava/util/List;->iterator()Ljava/util/Iterator;
move-result-object v16
:cond_2a
:goto_10
invoke-interface/range {v16 .. v16}, Ljava/util/Iterator;->hasNext()Z
move-result v9
if-eqz v9, :cond_65
invoke-interface/range {v16 .. v16}, Ljava/util/Iterator;->next()Ljava/lang/Object;
move-result-object v11
move-object v9, v11
check-cast v9, Lcom/facebook/aura/settings/api/SettingsGeneralRowContributor;
move-object v10, v9
move/from16 v9, v33
invoke-interface {v10, v0, v9}, Lcom/facebook/aura/settings/api/SettingsGeneralRowContributor;->rememberIsVisible(LX/2d4;I)Z
move-result v9
if-eqz v9, :cond_2a
```

The registry currently returns exactly one contributor:

```smali
# smali/com/facebook/aura/settings/api/SettingsGeneralRows.smali  (contributors()Ljava/util/List;)
sget-object v0, Lcom/facebook/aura/partners/voice/impl/VoiceControlsSettingsRowProvider;->INSTANCE:Lcom/facebook/aura/partners/voice/impl/VoiceControlsSettingsRowProvider;
invoke-virtual {v0}, Lcom/facebook/aura/partners/voice/impl/VoiceControlsSettingsRowProvider;->contributor()Lcom/facebook/aura/settings/api/SettingsGeneralRowContributor;
move-result-object v0
invoke-virtual {v1, v0}, Ljava/util/AbstractCollection;->add(Ljava/lang/Object;)Z
return-object v1
```

`com.facebook.aura.settings.api.SettingsGeneralRowContributor` (interface, `smali/com/facebook/aura/settings/api/SettingsGeneralRowContributor.smali`):

```smali
.method public abstract Row(LX/3C1;LX/2d4;I)V
.method public abstract getDeeplinkSection()Ljava/lang/String;
.method public abstract open(Lcom/facebook/aura/navigation/AuraNavigator;)V
.method public abstract rememberIsVisible(LX/2d4;I)Z
```

Only implementation in the APK: `com.facebook.aura.partners.voice.impl.VoiceControlsSettingsRow` (`implements ...SettingsGeneralRowContributor`, field `deeplinkSection:Ljava/lang/String; = "voice"`, `open(Lcom/facebook/aura/navigation/AuraNavigator;)V` at line 468).

### How tap handlers are wired

Two mechanisms:

1. **General rows**: the row itself calls `open(AuraNavigator)`; visibility via `rememberIsVisible(Composer, int)`; deep-link key via `getDeeplinkSection()`.
2. **Static sections**: each section takes a `Function0`/`Function0<Unit>` callback. `SettingsScreenContent` passes lambdas such as `SettingsEntryProviderKt$SettingsScreenContent$9$1::<init>` (one per row) that call `AuraNavigator` navigation methods.

Account-related taps in the account menu go through `AuraAccounts`:

```smali
# smali_classes3/com/facebook/aura/auth/login/nativeflow/AuraAccountMenuKt$AccountDropdown$1$1.smali
iget p1, p1, Lcom/facebook/aura/vds/compose/contextmenu/AuraContextMenuItem;->id:I
const/4 v0, -0x2
if-ne p1, v0, :cond_1
sget-object v0, Lcom/facebook/aura/auth/api/AuraAccounts;->INSTANCE:Lcom/facebook/aura/auth/api/AuraAccounts;
invoke-virtual {v0}, Lcom/facebook/aura/auth/api/AuraAccounts;->addAccount()V
:cond_1
iget-object p0, p0, ...$AccountDropdown$1$1;->$accountsByItemId:Ljava/util/Map;
invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;
move-result-object p1
check-cast p1, Lcom/facebook/aura/auth/api/AuraSwitchableAccount;
if-eqz p1, :cond_0
iget-boolean v0, p1, Lcom/facebook/aura/auth/api/AuraSwitchableAccount;->isCurrent:Z
if-nez v0, :cond_0
sget-object p0, Lcom/facebook/aura/auth/api/AuraAccounts;->INSTANCE:Lcom/facebook/aura/auth/api/AuraAccounts;
iget-object v0, p1, Lcom/facebook/aura/auth/api/AuraSwitchableAccount;->userId:Ljava/lang/String;
invoke-virtual {p0, v0}, Lcom/facebook/aura/auth/api/AuraAccounts;->switchTo(Ljava/lang/String;)V
```

### Where a new row could be injected

- **Data-driven way (cleanest)**: make `SettingsGeneralRows.contributors()` return an extra `SettingsGeneralRowContributor` (patch the list-building in `smali/com/facebook/aura/settings/api/SettingsGeneralRows.smali`, `contributors()`), or patch `VoiceControlsSettingsRowProvider.contributor()`. The screen will render it automatically and call `rememberIsVisible`/`open`.
- **Static way**: add one more section call inside `HatchSettingsScreen$22.smali` (after the `AccountsCenterSection` call at line 2377 is the natural spot, before `LogOutSection`), or add an `item {}` in `HatchSettingsScreen`.
- The screen's section visibility booleans come from `com.facebook.aura.settings.HatchSettingsConfig`; `SettingsScreenContent` constructs it with `popOnInternalSettingsClick=0` and the other 13 flags `=1` (see `move/from16 v32, p1` where `p1` was set by `const/16 p1, 0x0`, and `const/16 p3, 0x1` feeding v33..v45).

---

## b) Session / login token

### Classes that hold the session

| role | class |
|---|---|
| facade (singleton) | `com.facebook.aura.auth.api.AuraSessions` (`INSTANCE`) |
| manager (singleton) | `com.facebook.aura.auth.api.AuraSessionManager` (`INSTANCE`, delegates to `AuraSessionManagerContract`) |
| persistence facade | `com.facebook.aura.auth.store.AuraUserSessionStore` (`INSTANCE`) |
| concrete session store | `LX/IAd` (`smali_classes6/X/IAd.smali`) |
| session object | `LX/AHE` (return type of `getCurrentUserSession()`) |

`AuraSessions.persistedSession()` is a straight delegation (and is marked deprecated):

```smali
# smali_classes4/com/facebook/aura/auth/api/AuraSessions.smali
.method public final persistedSession()LX/AHE;
    .annotation runtime Lkotlin/Deprecated;
        message = "DO NOT USE THIS directly. Instead get the user from your screen via LocalUserSession and pass it to the appropriate data layers."
    .end annotation
    sget-object p0, Lcom/facebook/aura/auth/store/AuraPersistedSessionBinding;->INSTANCE:Lcom/facebook/aura/auth/store/AuraPersistedSessionBinding;
    invoke-virtual {p0}, Lcom/facebook/aura/auth/store/AuraPersistedSessionBinding;->persistedSession()LX/AHE;
    move-result-object p0
    return-object p0
.end method
```

`AuraUserSessionStore.getCurrentUserSession()` checks `isCurrentUserAuthenticated()` and then reads the `LX/IAd` instance:

```smali
# smali_classes4/com/facebook/aura/auth/store/AuraUserSessionStore.smali
invoke-virtual {p0}, Lcom/facebook/aura/auth/store/AuraUserSessionStore;->isCurrentUserAuthenticated()Z
move-result p0
if-eqz p0, :cond_0
sget-object p0, Lcom/facebook/aura/auth/store/AuraUserSessionStore;->instance$delegate:Lkotlin/Lazy;
invoke-interface {p0}, Lkotlin/Lazy;->getValue()Ljava/lang/Object;
move-result-object p0
check-cast p0, LX/IAd
```

`LX/IAd` holds the live session and the prefs handle:

```smali
# smali_classes6/X/IAd.smali
.field public A00:LX/AHE;
.field public final A01:LX/BVu;
.field public final A02:LX/I7j;
```

### Where the active account/session is persisted

- Session object: `LX/IAd.A00` (an `LX/AHE`), written through `AuraUserSessionStore.saveCurrentUserSession(LX/AHE;)Z` and read via `getCurrentUserSession()`.
- Preference handle: `LX/BVu` (`AuraUserSessionStore.A01` / `authFrameworkPrefs$delegate`), obtained via `com.facebook.aura.common.prefs.AuraDevicePrefs`.
- Auth-framework marker: `AuraUserSessionStore.KEY_AUTH_FRAMEWORK = "auth_framework"`, value `CURRENT_AUTH_FRAMEWORK = "abra_native_to_web"`; session keys serialized as `AT`, `UID`, `UUN`, `SK`, `SCS`, `A2C`, `E2E_INJECTED`, `domain`, `path`, `expires`, `expires_timestamp`, `secure`, `value`.
- Singleton access: `AuraSessions.INSTANCE`, `AuraSessionManager.INSTANCE`, `AuraUserSessionStore.INSTANCE`, `AuraPersistedSessionBinding.INSTANCE`.

There is no separate "activeAccount" preference key in the APK. The Active account is whichever `LX/AHE` is in `LX/IAd.A00`; the store only holds one session.

### Multiple credentials

Credentials for other accounts are kept in a separate, Keystore-sealed store (see c):

```smali
# smali_classes4/com/facebook/aura/auth/login/credentials/AuraParkedAccountsStore.smali
.field public static final ACCESS_TOKENS:Ljava/lang/String; = "access_tokens"
.field public static final ACCESS_TOKENS_FORMAT:I = 0x1
.field public static final FORMAT:I = 0x2
.field public static final KEY_ALIAS:Ljava/lang/String; = "hatch_parked_accounts_store"
.field public static final lock:Ljava/lang/Object;
.field public static persistenceFailed:Z
```

---

## c) Multi-account

### What exists

| piece | class / member |
|---|---|
| account model for switching | `com.facebook.aura.auth.api.AuraSwitchableAccount` — fields `name`, `contact`, `userId`, `isCurrent` |
| account facade | `com.facebook.aura.auth.api.AuraAccounts` — `accounts(LX/2M4;)`, `addAccount()`, `continueWithLogin()`, `switchTo(Ljava/lang/String;)`, `getStatus()`, `restartForRecovery()`, `retry()`, `dismissFailure()` |
| switch orchestration | `com.facebook.aura.auth.logout.AuraAccountTransitionCoordinator` — implements `AuraAccountsController`; `switchTo(Ljava/lang/String;)`, `leaveCurrent`, `createAccountOperation`, `exchangeStoredFrlToken`, `continueWithLogin` |
| parked credential store | `com.facebook.aura.auth.login.credentials.AuraParkedAccountsStore` — `put/get/readAll/remove/reject/clear/onActivated`, `openOperation()`, `withOperation()`, Keystore alias `hatch_parked_accounts_store` |
| remembered accounts (UI metadata) | `com.facebook.aura.auth.login.credentials.AuraRememberedAccountsStore` (`RecordCipher`, sealed `record.` entries, `order` list) and `com.facebook.aura.auth.api.AuraRememberedAccounts.updateProfile(...)` |
| one-tap / saved creds | `AuraOneTapLoginStore`, `AuraSavedCredentialsStore` (`email`, `profile_name`, `profile_picture_url`, `id_for_aymh`, `dbl_data`) |
| account menu UI | `com.facebook.aura.auth.login.nativeflow.AuraAccountMenuKt` (`AuraAccountMenu`, `AccountDropdown`), `AuraAccountMenuProvider` |
| settings row for Accounts Center | `HatchSettingsScreenKt.AccountsCenterSection` → `com.facebook.aura.accountcenter.AuraAccountsCenterActivity` |

So yes: the code to **store multiple accounts** (`AuraParkedAccountsStore`, sealed access tokens) and to **swap** them (`AuraAccounts.switchTo` → `AuraAccountTransitionCoordinator.switchTo`) is present in the APK.

`AuraAccountTransitionCoordinator.switchTo`:

```smali
# smali_classes4/com/facebook/aura/auth/logout/AuraAccountTransitionCoordinator.smali
.method public switchTo(Ljava/lang/String;)V
    .locals 1
    const/4 v0, 0x0
    invoke-static {p1, v0}, LX/I1c;->A0f(Ljava/lang/Object;I)V
    invoke-direct {p0, p1, v0}, Lcom/facebook/aura/auth/logout/AuraAccountTransitionCoordinator;->switchTo(Ljava/lang/String;Z)V
    return-void
.end method
```

### Gates (booleans / experiments)

Gate class: `com.facebook.aura.auth.login.credentials.AuraRetainedAccountLoginGate` (fields `fastAccountSwitchingEnabled$delegate`, `isEnabled$delegate`, `isStoredTokenSwitchEnabled$delegate`, `hasRetainedAccount`).

```smali
# smali_classes4/com/facebook/aura/auth/login/credentials/AuraRetainedAccountLoginGate.smali
.method public final isAccountSwitcherEnabled(Lkotlin/jvm/functions/Function0;)Z
    .locals 2
    const/4 v1, 0x0
    invoke-static {p1, v1}, LX/I1c;->A0f(Ljava/lang/Object;I)V
    invoke-virtual {p0}, Lcom/facebook/aura/auth/login/credentials/AuraRetainedAccountLoginGate;->isEnabled()Z
    move-result v0
    if-eqz v0, :cond_2
    invoke-direct {p0}, Lcom/facebook/aura/auth/login/credentials/AuraRetainedAccountLoginGate;->getFastAccountSwitchingEnabled()Z
    move-result v0
    if-nez v0, :cond_1
    sget-object v0, Lcom/facebook/aura/auth/login/credentials/AuraRetainedAccountLoginGate;->hasRetainedAccount:Ljava/lang/Boolean;
    ...
```

The three flags are MobileConfig parameters declared in `MC$hatch_android_login` and `MC$hatch_android_login_sessioned` (both in `smali_classes4/com/facebook/aura/auth/login/credentials/`):

| smali field | MC id (decimal) | hex |
|---|---|---|
| `MC$hatch_android_login.enable_retained_account_login` | 18298291553894729 | `0x41023300110149` |
| `MC$hatch_android_login.enable_stored_token_switch` | 18298291554091339 | `0x4102330014014b` |
| `MC$hatch_android_login_sessioned.enable_fast_account_switching` | 36312943465333199 | `0x81026e000001cf` |

Where read:

- `AuraRetainedAccountLoginGate.isAccountSwitcherEnabled(...)` — the only reader of the two booleans. Call sites: `AuraAccountMenuKt.smali:1096` (menu visibility), `AuraAccountTransitionCoordinator$launchOperation$1.smali:626`, `AuraAccountTransitionCoordinator.smali:5074`. The account menu drops the account list when this returns false, which matches the observed UI.
- `AuraParkedAccountsStore.getCanRetainAccounts()` — read by `AuraAccountTransitionCoordinator$continueWithLogin$1` (line 267), i.e. whether an account may be parked after login:

```smali
.method public final getCanRetainAccounts()Z
    .locals 1
    sget-object p0, Lcom/facebook/aura/auth/login/credentials/AuraParkedAccountsStore;->lock:Ljava/lang/Object;
    monitor-enter p0
    :try_start_0
    sget-boolean v0, Lcom/facebook/aura/auth/login/credentials/AuraParkedAccountsStore;->persistenceFailed:Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0
    xor-int/lit8 v0, v0, 0x1
    monitor-exit p0
    return v0
```

Additional analytics/experiment identifiers that exist but are not gates: `ACCOUNT_SWITCH`, `ACCOUNT_SWITCHER`, `CANCEL_ACCOUNT_SWITCH`, `SAME_ACCOUNT_SWITCH`, `LEGACY_ACCOUNT_SWITCHER_SSO_SOURCES`, `FOA_SWITCHER_NOTIFICATION_COUNT_DISPLAY`, `IG4A_SWITCHER_LOGGING`, `isSwitcherAcquisitionEnabled` (log-field name only). `ACCOUNT_SWITCHER` is referenced by `smali_classes3/com/facebook/aura/analytics/hatch/HatchComponent.smali` as a logged component, not as a switcher implementation.

### Where the switcher UI lives

- `AuraAccountMenuKt.AuraAccountMenu(LX/JDQ;LX/3C1;LX/2d4;II)V` — account list + `AccountDropdown`; provided through `AuraAccountMenuProvider$contributor$1`.
- `HatchSettingsScreenKt.AccountsCenterSection` — the settings row that opens `AuraAccountsCenterActivity` (web Accounts Center), plus `AuraAccountCenterSessionValidator`, `AuraAccountsCenterCookieExchange`.

### NOT FOUND

- A class named `AccountSwitcher` — **NOT FOUND**.
- Identifier `storedAccounts` — **NOT FOUND** (equivalents: `AuraParkedAccountsStore.readAll()`, `AuraRememberedAccountsStore`).
- Identifier `activeAccount` — **NOT FOUND** (equivalents: `AuraSwitchableAccount.isCurrent:Z`, `LX/AHE` in `LX/IAd.A00`).
- Literal string `"switch account"` in code — **NOT FOUND** (row labels come from resources; the only near matches are the analytics enum values above).
- A settings row that switches accounts — **NOT FOUND**; the switcher UI is the login-side `AuraAccountMenu`, and settings only exposes Accounts Center.

---

## d) DEX map

| dex | smali dir | classes | obfuscated `X/` | dominant `com/facebook/aura` packages |
|---|---|---|---|---|
| classes.dex | `smali/` | 13,256 | 5,180 | settings 1027, vds 871, conversation 708, auth 433 |
| classes2.dex | `smali_classes2/` | 9,809 | 57 | agentpermission 1166, shopping 1045, skills 992, email 818 |
| classes3.dex | `smali_classes3/` | 10,708 | 260 | conversation 1882, navigation 795, spaces 692, settings 654 |
| classes4.dex | `smali_classes4/` | 11,247 | 639 | partners 2304, pairs 894, localbrowser 879, activation 725 |
| classes5.dex | `smali_classes5/` | 10,958 | 2,053 | auth 1262, partners 1252, subscription 732, confidentialvm 706 |
| classes6.dex | `smali_classes6/` | 14,117 | 10,470 | network 122, auth 120, partners 119, analytics 96 |
| classes7.dex | `smali_classes7/` | 6,148 | 2,291 | partners 369, conversation 222, gateway 191, pairs 174 |

`com.meta.*` present but small (clocksync, foa/cds, health, maps, compose helpers). `com.instagram.*` present (1 class in classes6).
