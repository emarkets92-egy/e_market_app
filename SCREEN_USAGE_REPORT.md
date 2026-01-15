# Screen Usage Analysis Report
## Detailed Navigation Flow Analysis

### ✅ SCREENS IN ACTIVE FLOW (Actually Navigated To)

#### 1. **LoginScreen** (`/login`)
- **Called from:**
  - Initial route (app starts here)
  - `app_router.dart` redirect logic (when not authenticated)
  - `auth_init_wrapper.dart` (when auth check fails)
  - `home_screen.dart` line 197 (on logout)
- **Navigates to:** `HomeScreen` (on successful login)
- **Status:** ✅ ACTIVE

#### 2. **RegisterScreen** (`/register`)
- **Called from:**
  - `login_form.dart` line 141 (link to register)
- **Navigates to:** `HomeScreen` (on successful registration)
- **Status:** ✅ ACTIVE

#### 3. **CompleteProfileScreen** (`/complete-profile`)
- **Called from:**
  - Auth flow (after registration if profile incomplete)
- **Navigates to:** `HomeScreen` (on completion)
- **Status:** ✅ ACTIVE

#### 4. **HomeScreen** (`/home`)
- **Called from:**
  - `app_router.dart` redirect (when authenticated)
  - `login_screen.dart` line 23 (after login)
  - `register_screen.dart` line 30 (after registration)
  - `complete_profile_screen.dart` line 35 (after profile completion)
  - `profile_detail_screen.dart` lines 141, 174, 179 (breadcrumb navigation)
- **Navigates to:** `SubscriptionSelectionScreen` (line 79)
- **Status:** ✅ ACTIVE

#### 5. **ConversationsListScreen** (`/inbox`)
- **Called from:**
  - `sidebar_navigation.dart` line 60 (inbox navigation)
- **Navigates to:**
  - `SearchUnlockedProfilesScreen` (line 71)
  - `ChatScreen` (line 124)
- **Status:** ✅ ACTIVE

#### 6. **SearchUnlockedProfilesScreen** (`/chat/search-profiles`)
- **Called from:**
  - `conversations_list_screen.dart` line 71
- **Navigates to:** `ChatScreen` (lines 96, 103)
- **Status:** ✅ ACTIVE

#### 7. **ChatScreen** (`/chat`)
- **Called from:**
  - `conversations_list_screen.dart` line 124
  - `search_unlocked_profiles_screen.dart` lines 96, 103
  - `profile_detail_screen.dart` line 266
- **Status:** ✅ ACTIVE

#### 8. **SubscriptionSelectionScreen** (`/subscription-selection`)
- **Called from:**
  - `home_screen.dart` line 79
- **Navigates to:**
  - `AnalysisScreen` (line 215)
  - `ProfileDetailScreen` (line 550)
- **Status:** ✅ ACTIVE

#### 9. **ProductListScreen** (`/products`)
- **Called from:**
  - `search_bar.dart` line 14 (home screen search)
- **Navigates to:** `ProductDetailScreen` (via product cards)
- **Status:** ✅ ACTIVE

#### 10. **ProductDetailScreen** (`/products/:id`)
- **Called from:**
  - `product_card.dart` line 21
- **Navigates to:** `MarketSelectionScreen` (line 119)
- **Status:** ✅ ACTIVE

#### 11. **MarketSelectionScreen** (`/market-selection`)
- **Called from:**
  - `product_detail_screen.dart` line 119
- **Navigates to:**
  - `ProfileListScreen` (lines 97, 105)
  - `AnalysisScreen` (line 114)
- **Status:** ✅ ACTIVE

#### 12. **ProfileListScreen** (`/profiles`)
- **Called from:**
  - `market_selection_screen.dart` lines 97, 105
- **Navigates to:** `ProfileDetailScreen` (via profile cards)
- **Status:** ✅ ACTIVE

#### 13. **ProfileDetailScreen** (`/profiles/:id`)
- **Called from:**
  - `subscription_selection_screen.dart` line 550
  - `market_selection_screen.dart` (via profile cards)
  - `profile_card.dart` line 27
  - `subscription_profile_card.dart` lines 132, 140, 227, 236
  - `subscription_profile_table_row.dart` line 134
- **Navigates to:**
  - `HomeScreen` (lines 141, 174, 179)
  - `ChatScreen` (line 266)
- **Status:** ✅ ACTIVE

#### 14. **AnalysisScreen** (`/analysis`)
- **Called from:**
  - `market_selection_screen.dart` line 114
  - `subscription_selection_screen.dart` line 215
- **Note:** This screen shows all analysis types (competitive, pestle, swot, market plan) as TABS within one screen
- **Status:** ✅ ACTIVE

---

### ❌ SCREENS NOT IN FLOW (Orphaned/Unused)

#### 15. **OpportunitiesScreen** (`/opportunities`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found anywhere
- **Status:** ❌ ORPHANED - Can be removed from router

#### 16. **NotificationsScreen** (`/notifications`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found anywhere
- **Status:** ❌ ORPHANED - Can be removed from router

#### 17. **ProfileScreen** (`/profile`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found anywhere
- **Status:** ❌ ORPHANED - Can be removed from router

#### 18. **CompetitiveAnalysisScreen** (`/analysis/competitive`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found
- **Note:** Analysis is shown as a TAB within `AnalysisScreen`, not as a separate screen
- **Status:** ❌ ORPHANED - Can be removed from router

#### 19. **PESTLEAnalysisScreen** (`/analysis/pestle`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found
- **Note:** Analysis is shown as a TAB within `AnalysisScreen`, not as a separate screen
- **Status:** ❌ ORPHANED - Can be removed from router

#### 20. **SWOTAnalysisScreen** (`/analysis/swot`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found
- **Note:** Analysis is shown as a TAB within `AnalysisScreen`, not as a separate screen
- **Status:** ❌ ORPHANED - Can be removed from router

#### 21. **MarketPlanScreen** (`/analysis/market-plan`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found
- **Note:** Analysis is shown as a TAB within `AnalysisScreen`, not as a separate screen
- **Status:** ❌ ORPHANED - Can be removed from router

#### 22. **ShipmentRecordsListScreen** (`/profiles/:profileId/shipment-records`)
- **In router:** ✅ YES
- **Navigated to:** ❌ NO - No navigation calls found
- **Note:** Shipment records are shown directly in `ProfileDetailScreen` (expandable section), not as a separate screen
- **Status:** ❌ ORPHANED - Can be removed from router

#### 23. **InboxScreen** (`lib/features/home/presentation/screens/inbox_screen.dart`)
- **In router:** ❌ NO
- **Status:** ❌ UNUSED - File exists but is replaced by `ConversationsListScreen`
- **Recommendation:** DELETE this file

---

### 🔧 SPECIAL PURPOSE SCREENS

#### 24. **UpdateRequiredScreen**
- **In router:** ❌ NO (intentionally)
- **Called from:** `version_check_wrapper.dart` line 37 (shown directly, not via routing)
- **Status:** ✅ ACTIVE (special purpose - shown when update is required)

---

## Summary

### Total Screens Found: 24
- **Active in Flow:** 14 screens
- **Orphaned (in router but never navigated to):** 7 screens
- **Unused (not in router, file exists):** 1 screen (`InboxScreen`)
- **Special Purpose:** 1 screen (`UpdateRequiredScreen`)

### Screens to Remove from Router:
1. `OpportunitiesScreen` - `/opportunities`
2. `NotificationsScreen` - `/notifications`
3. `ProfileScreen` - `/profile`
4. `CompetitiveAnalysisScreen` - `/analysis/competitive`
5. `PESTLEAnalysisScreen` - `/analysis/pestle`
6. `SWOTAnalysisScreen` - `/analysis/swot`
7. `MarketPlanScreen` - `/analysis/market-plan`
8. `ShipmentRecordsListScreen` - `/profiles/:profileId/shipment-records`

### Files to Delete:
1. `lib/features/home/presentation/screens/inbox_screen.dart`

### Note:
The individual analysis screens (competitive, pestle, swot, market plan) are redundant because `AnalysisScreen` shows all these analyses as tabs within a single screen. The separate screens are never navigated to.
