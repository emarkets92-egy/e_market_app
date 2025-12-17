# Flutter Admin Panel Development Prompt

## Project Overview

Create a comprehensive Flutter web application for the E-Market backend admin panel. This admin panel should provide full CRUD operations for managing products, profiles, users, sales requests, market analysis, shipments, and system configurations. The application must implement a robust permission-based access control system.

## Backend API Information

**Base URL**: `http://localhost:3000` (configurable via environment)
**API Documentation**: Available at `http://localhost:3000/api` (Swagger)
**Authentication**: JWT Bearer Token (stored in Authorization header as `Bearer <token>`)

## Authentication & Authorization

### Admin Login
- **Endpoint**: `POST /admin/login`
- **Body**: 
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "accessToken": "string",
    "refreshToken": "string",
    "admin": {
      "id": "uuid",
      "publicId": "uuid",
      "email": "string",
      "name": "string",
      "fcmToken": "string",
      "permissions": ["create_products", "manage_users", ...]
    }
  }
  ```

### Permission System
The system has 10 predefined permissions:
1. `create_products` - Can create new products
2. `edit_products` - Can edit existing products
3. `delete_products` - Can delete products
4. `manage_users` - Can create, edit, and manage user accounts
5. `manage_profiles` - Can create, edit, and manage user profiles
6. `manage_subscriptions` - Can manage product subscriptions for users
7. `view_reports` - Can view system reports and analytics
8. `manage_sales_requests` - Can view and manage sales requests
9. `manage_admins` - Can create and manage admin accounts
10. `manage_permissions` - Can manage admin permissions

**Important**: 
- All admin endpoints require authentication via `AdminGuard`
- The app should check user permissions before showing/hiding UI elements
- API calls should include the JWT token in the Authorization header: `Bearer <accessToken>`
- Store tokens securely (use secure storage) and implement token refresh logic

## Core Features & API Endpoints

### 1. Dashboard
Create a dashboard page showing:
- Total profiles count
- Total products count
- Total sales requests count
- Recent activity/updates
- Quick statistics

**Note**: Some endpoints may need to be aggregated or created for dashboard data.

### 2. Profile Management

#### List All Profiles
- **Endpoint**: `GET /admin/profiles?page=1&limit=20`
- **Response**: Paginated list with metadata
- **Features**: 
  - Pagination controls
  - Search/filter by email, name, company
  - Filter by userTypeId (1=Importer, 2=Exporter)
  - Filter by countryId
  - Filter by isActive status
  - Display: email, name, companyName, phone, country, userType, points, subscriptions count, isActive

#### Get Single Profile
- **Endpoint**: `GET /admin/profiles/:id` (UUID)
- **Response**: Full profile details including subscriptions and shipment records

#### Create Profile
- **Endpoint**: `POST /admin/profiles`
- **Body**:
  ```json
  {
    "email": "string",
    "name": "string",
    "companyName": "string",
    "phone": "string",
    "whatsapp": "string",
    "website": "string",
    "address": "string",
    "statusId": "number",
    "userTypeId": "number (1 or 2)",
    "countryId": "number (required)",
    "subscriptions": [
      {
        "productId": "uuid",
        "subscriptionType": "string"
      }
    ]
  }
  ```

#### Update Profile
- **Endpoint**: `PATCH /admin/profiles/:id`
- **Body**: Same as create (all fields optional)

#### Add Subscription to Profile
- **Endpoint**: `POST /admin/profiles/:id/subscriptions`
- **Body**:
  ```json
  {
    "productId": "uuid",
    "subscriptionType": "string"
  }
  ```

#### Credit Points to Profile
- **Endpoint**: `POST /admin/profiles/:id/points`
- **Body**:
  ```json
  {
    "amount": "number",
    "reason": "string"
  }
  ```

### 3. Product Management

#### List All Products
- **Endpoint**: `GET /products?locale=en&page=1&limit=20&hscode=string`
- **Features**:
  - Pagination
  - Search by HS code
  - Language selection for product names
  - Display: name, hscode, categoryId, targetMarkets, createdAt

#### Get Single Product
- **Endpoint**: `GET /products/:id?locale=en`

#### Create Product
- **Endpoint**: `POST /products?locale=en`
- **Body**:
  ```json
  {
    "name": "string",
    "hscode": "string",
    "categoryId": "number",
    "sourceLanguageId": "number (default: 1)",
    "targetMarkets": [1, 2, 3],
    "otherMarkets": [4, 5],
    "importerMarkets": [6, 7]
  }
  ```

#### Update Product
- **Endpoint**: `PATCH /products/:id`
- **Body**: Same as create (all fields optional)

#### Delete Product
- **Endpoint**: `DELETE /products/:id`

#### Update Product Translation
- **Endpoint**: `PATCH /products/:id/translations/:languageCode`
- **Body**:
  ```json
  {
    "name": "string"
  }
  ```

### 4. Sales Request Management

#### List All Sales Requests (Admin)
- **Endpoint**: `GET /sales-requests/admin/all`
- **Response**: Array of sales requests
- **Features**:
  - Display: user info, productIds, status, notes, assignedTo, createdAt
  - Filter by status (pending, contacted, converted, rejected)
  - Filter by assigned admin

#### Update Sales Request
- **Endpoint**: `PATCH /sales-requests/admin/:id`
- **Body**:
  ```json
  {
    "status": "string",
    "notes": "string",
    "assignedTo": "number (adminId)"
  }
  ```

### 5. Market Analysis Management

All endpoints under `/admin/market-analysis` require admin authentication.

#### Competitive Analysis
- **Create**: `POST /admin/market-analysis/competitive`
- **List**: `GET /admin/market-analysis/competitive/:productId/:targetCountryId?locale=en`
- **Get One**: `GET /admin/market-analysis/competitive/:id?locale=en`
- **Update**: `PATCH /admin/market-analysis/competitive/:id`
- **Delete**: `DELETE /admin/market-analysis/competitive/:id`

**Body for Create/Update**:
```json
{
  "productId": "uuid",
  "targetCountryId": "number",
  "marketName": "string",
  "totalImports": "string",
  "totalExportsFromSelectedCountry": "string",
  "rank": "number"
}
```

#### PESTLE Analysis
- **Create/Update (Upsert)**: `POST /admin/market-analysis/pestle`
- **Get**: `GET /admin/market-analysis/pestle/:productId/:targetCountryId?locale=en`
- **Update**: `PATCH /admin/market-analysis/pestle/:productId/:targetCountryId`

**Body**:
```json
{
  "productId": "uuid",
  "targetCountryId": "number",
  "political": "string",
  "economic": "string",
  "social": "string",
  "technological": "string",
  "legal": "string",
  "environmental": "string"
}
```

#### SWOT Analysis
- **Create/Update (Upsert)**: `POST /admin/market-analysis/swot`
- **Get**: `GET /admin/market-analysis/swot/:productId/:targetCountryId?locale=en`
- **Update**: `PATCH /admin/market-analysis/swot/:productId/:targetCountryId`

**Body**:
```json
{
  "productId": "uuid",
  "targetCountryId": "number",
  "strengths": "string",
  "weaknesses": "string",
  "opportunities": "string",
  "threats": "string"
}
```

#### Marketing Plan
- **Create/Update (Upsert)**: `POST /admin/market-analysis/marketing-plan`
- **Get**: `GET /admin/market-analysis/marketing-plan/:productId/:targetCountryId?locale=en`
- **Update**: `PATCH /admin/market-analysis/marketing-plan/:productId/:targetCountryId`

**Body**:
```json
{
  "productId": "uuid",
  "countryId": "number",
  "productText": "string",
  "priceText": "string",
  "placeText": "string",
  "promotionText": "string"
}
```

### 6. Shipment Records Management

#### List Shipment Records for Profile
- **Endpoint**: `GET /admin/profiles/:profileId/shipment-records`

#### Get Single Shipment Record
- **Endpoint**: `GET /admin/shipment-records/:id`

#### Create Shipment Record
- **Endpoint**: `POST /admin/profiles/:profileId/shipment-records`
- **Body**:
  ```json
  {
    "exporterName": "string",
    "countryOfOrigin": "string",
    "netWeight": "string",
    "netWeightUnit": "string",
    "portOfArrival": "string",
    "portOfDeparture": "string",
    "notifyParty": "string",
    "notifyAddress": "string",
    "year": "number",
    "month": "number",
    "hsCode": "string",
    "quantity": "number",
    "value": "number",
    "originCountryId": "number",
    "destinationCountryId": "number"
  }
  ```

#### Update Shipment Record
- **Endpoint**: `PATCH /admin/shipment-records/:id`
- **Body**: Same as create (all fields optional)

#### Delete Shipment Record
- **Endpoint**: `DELETE /admin/shipment-records/:id`

### 7. Points & Pricing Management

#### Get All Points Pricing
- **Endpoint**: `GET /admin/points-pricing`
- **Response**: Array of pricing configurations
- **Keys**: `PROFILE_CONTACT`, `MARKET_PLAN`, `COMPETITIVE_ANALYSIS`, `PESTLE_ANALYSIS`, `SWOT_ANALYSIS`

#### Update Points Pricing
- **Endpoint**: `PATCH /admin/points-pricing/:key`
- **Body**:
  ```json
  {
    "cost": "number",
    "isActive": "boolean"
  }
  ```

### 8. Admin User Management

#### Create Admin
- **Endpoint**: `POST /admin/users`
- **Body**:
  ```json
  {
    "email": "string",
    "password": "string",
    "name": "string",
    "fcmToken": "string",
    "permissions": ["create_products", "manage_users", ...]
  }
  ```
- **Note**: If permissions array is empty or not provided, all permissions are assigned

### 9. Import/Export Functionality

#### Download Templates
- **Products Template**: `GET /admin/import/template/products`
- **Profiles Template**: `GET /admin/import/template/profiles`
- **Shipment Records Template**: `GET /admin/import/template/shipment-records`
- **Unified Template**: `GET /admin/import/template/unified`

#### Import Data
- **Import Products**: `POST /admin/import/products` (multipart/form-data, file field)
- **Import Profiles**: `POST /admin/import/profiles` (multipart/form-data, file field)
- **Import Shipment Records**: `POST /admin/import/shipment-records` (multipart/form-data, file field)
- **Unified Import**: `POST /admin/import/unified` (multipart/form-data, file field)

**Response Format**:
```json
{
  "totalRows": "number",
  "successCount": "number",
  "failureCount": "number",
  "errors": ["string"],
  "errorSummary": {},
  "missingColumns": []
}
```

### 10. Localization Data

#### Get Languages
- **Endpoint**: `GET /localization/languages`
- **Use**: For language selection in product translations and market analysis

#### Get Countries
- **Endpoint**: `GET /localization/countries?locale=en`
- **Use**: For country selection in profiles, products, and market analysis

## UI/UX Requirements

### Design System
- Use Material Design 3 or Flutter's modern design principles
- Implement a responsive layout that works on desktop and tablet
- Use a consistent color scheme (primary, secondary, error, success colors)
- Implement dark mode support

### Navigation Structure
1. **Sidebar Navigation** with collapsible sections:
   - Dashboard
   - Profiles
   - Products
   - Sales Requests
   - Market Analysis
     - Competitive Analysis
     - PESTLE Analysis
     - SWOT Analysis
     - Marketing Plans
   - Shipment Records
   - Points & Pricing
   - Admin Users
   - Import/Export
   - Settings

2. **Top Bar**:
   - Admin name and avatar
   - Notifications (if applicable)
   - Logout button
   - Language selector (if multi-language UI)

### Key UI Components Needed

1. **Data Tables**:
   - Sortable columns
   - Pagination controls
   - Row actions (edit, delete, view)
   - Bulk actions (if applicable)
   - Export to CSV/Excel

2. **Forms**:
   - Validation with clear error messages
   - Required field indicators
   - Auto-save drafts (optional)
   - Multi-step forms for complex entities

3. **Modals/Dialogs**:
   - Confirmation dialogs for delete actions
   - Form dialogs for create/edit
   - View-only dialogs for details

4. **Filters & Search**:
   - Advanced filter panels
   - Search bars with debouncing
   - Filter chips showing active filters
   - Clear all filters button

5. **Status Indicators**:
   - Badges for status (pending, active, inactive, etc.)
   - Color-coded status indicators
   - Loading states
   - Empty states

6. **Charts & Analytics** (if dashboard requires):
   - Line charts
   - Bar charts
   - Pie charts
   - Statistics cards

### Permission-Based UI
- Hide/show menu items based on permissions
- Disable buttons/actions based on permissions
- Show permission warnings when needed
- Display user's current permissions in profile/settings

## Technical Requirements

### State Management
- Use a state management solution (Provider, Riverpod, Bloc, or GetX)
- Implement proper error handling and loading states
- Cache API responses where appropriate
- Implement optimistic updates for better UX

### API Client
- Create a centralized API service/client
- Implement interceptors for:
  - Adding Authorization header
  - Handling token refresh
  - Error handling and retry logic
  - Request/response logging (dev mode)

### Data Models
- Create Dart models for all API request/response DTOs
- Use code generation (json_serializable) if preferred
- Implement proper null safety

### Error Handling
- Global error handler
- User-friendly error messages
- Network error handling
- Validation error display
- Retry mechanisms for failed requests

### Local Storage
- Secure storage for tokens
- Cache frequently accessed data
- Store user preferences
- Offline data handling (optional)

### File Handling
- Excel file picker for imports
- File download for templates
- Progress indicators for file uploads
- Error handling for file operations

### Form Validation
- Client-side validation matching backend validation
- Real-time validation feedback
- Required field validation
- Format validation (email, phone, etc.)

## Additional Features to Consider

1. **Activity Log**: Track admin actions (if backend provides)
2. **Export Functionality**: Export filtered data to CSV/Excel
3. **Bulk Operations**: Bulk update/delete where applicable
4. **Advanced Search**: Full-text search across entities
5. **Notifications**: Real-time notifications for important events
6. **Audit Trail**: View history of changes to entities
7. **User Preferences**: Save table column preferences, filters, etc.

## Development Guidelines

1. **Code Organization**:
   - Feature-based folder structure
   - Separate models, services, views, and widgets
   - Reusable components library

2. **Testing**:
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for critical flows

3. **Performance**:
   - Lazy loading for large lists
   - Image optimization
   - Efficient state updates
   - Debouncing for search/filter inputs

4. **Accessibility**:
   - Semantic HTML labels
   - Keyboard navigation support
   - Screen reader support
   - ARIA attributes where applicable

5. **Documentation**:
   - Code comments for complex logic
   - README with setup instructions
   - API integration documentation

## Environment Configuration

Create environment configuration for:
- API base URL (development, staging, production)
- Feature flags
- App version
- Build configuration

## Deliverables

1. Complete Flutter web application
2. All admin endpoints integrated
3. Permission-based access control implemented
4. Responsive UI design
5. Error handling and validation
6. Documentation (README, API integration guide)
7. Basic testing suite

## Questions to Clarify

Before starting development, consider asking:
1. What is the production API base URL?
2. Are there any additional admin endpoints not listed?
3. Should there be real-time updates (WebSocket)?
4. What are the specific design/branding requirements?
5. Are there any specific browser compatibility requirements?
6. Should the app support multiple languages for the UI itself?
7. Are there any specific analytics or tracking requirements?

---

**Note**: This prompt is comprehensive and should be used as a guide. Adapt it based on specific requirements and priorities. Start with core features (authentication, profiles, products) and gradually add other features.
