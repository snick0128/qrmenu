# URL Routing Flow Diagram

## Complete Flow Visualization

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Scans QR Code or Enters URL             │
│                  Format: /<restaurant_id>/<table_code>          │
└─────────────────────────────────────┬───────────────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────┐
                    │  Parse URL Parameters           │
                    │  - restaurantId                 │
                    │  - tableCode (optional)         │
                    └─────────────┬───────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────────────┐
                    │  Query Firebase:                │
                    │  restaurants.doc(restaurantId)  │
                    └─────────────┬───────────────────┘
                                  │
                    ┌─────────────┴──────────────┐
                    │                            │
            ┌───────▼────────┐          ┌───────▼─────────┐
            │   NOT FOUND    │          │     FOUND       │
            │   OR ERROR     │          │   Restaurant    │
            └───────┬────────┘          └───────┬─────────┘
                    │                            │
                    ▼                            ▼
        ┌───────────────────────┐   ┌──────────────────────────┐
        │   ERROR SCREEN        │   │  Extract Restaurant Data │
        │                       │   │  - name                  │
        │ ❌ Invalid Restaurant │   │  - id                    │
        │    ID                 │   │  - other details         │
        │                       │   └──────────┬───────────────┘
        │ [Go to Home Button]   │              │
        └───────────────────────┘              │
                                               ▼
                                  ┌────────────────────────┐
                                  │  Has Table Code in URL?│
                                  └────────┬───────────────┘
                                           │
                          ┌────────────────┴────────────────┐
                          │                                 │
                    ┌─────▼─────┐                    ┌─────▼──────┐
                    │    NO     │                    │    YES     │
                    └─────┬─────┘                    └─────┬──────┘
                          │                                │
                          ▼                                ▼
        ┌─────────────────────────────┐    ┌──────────────────────────────┐
        │  MANUAL TABLE ENTRY SCREEN  │    │  Query Firebase:             │
        │                             │    │  accessCodes.doc(tableCode)  │
        │  Pre-filled:                │    └──────────┬───────────────────┘
        │  ✓ Restaurant ID            │               │
        │  ✓ Restaurant Name          │               │
        │                             │    ┌──────────┴──────────┐
        │  User Enters:               │    │                     │
        │  - Table Code               │    │                     │
        └─────────────────────────────┘    ▼                     ▼
                                   ┌────────────────┐   ┌────────────────┐
                                   │  NOT FOUND OR  │   │     FOUND      │
                                   │   !isActive    │   │  & isActive    │
                                   └────────┬───────┘   └────────┬───────┘
                                            │                    │
                                            ▼                    ▼
                          ┌─────────────────────────────┐   ┌──────────────────┐
                          │  MANUAL TABLE ENTRY SCREEN  │   │  Extract Data:   │
                          │                             │   │  - type          │
                          │  Shows:                     │   │  - tableNumber   │
                          │  🏪 Restaurant Name         │   └────────┬─────────┘
                          │  📍 "Please enter table     │            │
                          │      code"                  │            ▼
                          │                             │   ┌──────────────────┐
                          │  User can manually enter    │   │   MENU SCREEN    │
                          │  correct table code         │   │                  │
                          └─────────────────────────────┘   │  Displays:       │
                                                            │  ✓ Restaurant    │
                                                            │    Name          │
                                                            │  ✓ Table Code    │
                                                            │  ✓ Menu Items    │
                                                            │                  │
                                                            │  Session Type:   │
                                                            │  - dine_in       │
                                                            │  - parcel        │
                                                            └──────────────────┘
```

## URL Patterns and Outcomes

### Pattern 1: `/:restaurantId/:tableCode`
```
Example: /demo_restaurant/TBL_1

Flow:
1. Validate restaurant → ✅
2. Validate table code → ✅
3. Outcome: Menu Screen
```

### Pattern 2: `/:restaurantId/:tableCode` (Invalid Table)
```
Example: /demo_restaurant/INVALID

Flow:
1. Validate restaurant → ✅
2. Validate table code → ❌
3. Outcome: Manual Entry Screen (with restaurant info)
```

### Pattern 3: `/:restaurantId/:tableCode` (Invalid Restaurant)
```
Example: /fake_restaurant/TBL_1

Flow:
1. Validate restaurant → ❌
2. Outcome: Error Screen
```

### Pattern 4: `/:restaurantId`
```
Example: /demo_restaurant

Flow:
1. Validate restaurant → ✅
2. Outcome: Manual Entry Screen (with restaurant info)
```

### Pattern 5: `/`
```
Example: / (root)

Flow:
1. Outcome: Manual Entry Screen (no pre-fill)
```

## State Transitions

```
┌─────────────────┐
│  Initial Load   │
│  (Loading...)   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Firebase Query State                   │
│                                         │
│  ConnectionState.waiting                │
│  → Show Loading Indicator               │
│                                         │
│  ConnectionState.done                   │
│  → Evaluate result                      │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Result Evaluation                      │
│                                         │
│  1. Document exists? → Proceed          │
│  2. Document missing? → Error/Manual    │
│  3. isActive=false? → Manual Entry      │
└─────────────────────────────────────────┘
```

## Component Responsibilities

### main.dart (Router)
- Parse URL parameters
- Orchestrate validation flow
- Handle navigation logic
- Show loading states

### FirebaseService
- Query restaurant collection
- Query accessCodes collection
- Validate data integrity
- Return formatted results

### ErrorScreen
- Display error messages
- Provide navigation options
- User-friendly error UI

### ManualTableEntryScreen
- Accept restaurant context
- Display restaurant info
- Manual code entry
- Validate and navigate

### MenuScreen
- Display menu items
- Manage cart
- Handle orders
- Session management
