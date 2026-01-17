# API Summary: Sales Requests & Products with Summary Statistics

## Table of Contents
1. [Sales Requests](#sales-requests)
2. [Products with Summary Statistics](#products-with-summary-statistics)

---

## Sales Requests

### Overview
Sales requests allow users to express interest in specific products. The system tracks these requests through a workflow where admins can manage and update the status of each request.

### How It Works

1. **User Creates Request**: A user creates a sales request by providing:
   - An array of product public IDs (`productIds`) they're interested in
   - Optional notes about their interest
   - The request is automatically assigned a `pending` status

2. **Status Workflow**: 
   - `pending` → Initial status when created
   - `contacted` → Admin has reached out to the user
   - `converted` → Request successfully converted to a sale
   - `rejected` → Request was declined

3. **Admin Management**:
   - Admins can view all sales requests across all users
   - Admins can update request status, notes, and assign requests to other admins
   - Assignment helps track which admin is handling each request

4. **Data Model**:
   - Each request stores: user ID, product IDs (array), status, notes, assigned admin ID (optional), and timestamps
   - Products are linked via their public IDs (UUIDs) but stored internally as BigInt IDs

### APIs

#### 1. **POST `/sales-requests`** (User)
Create a new sales request.

**Authentication**: Required (JWT)

**Request Body**:
```json
{
  "productIds": ["550e8400-e29b-41d4-a716-446655440000", "660e8400-e29b-41d4-a716-446655440001"],
  "notes": "Interested in bulk order"
}
```

**Response** (201 Created):
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "userId": "123",
  "productIds": ["550e8400-e29b-41d4-a716-446655440000", "660e8400-e29b-41d4-a716-446655440001"],
  "status": "pending",
  "notes": "Interested in bulk order",
  "assignedTo": null,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

---

#### 2. **GET `/sales-requests`** (User)
Get all sales requests for the authenticated user.

**Authentication**: Required (JWT)

**Response** (200 OK):
```json
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "userId": "123",
    "productIds": ["550e8400-e29b-41d4-a716-446655440000"],
    "status": "pending",
    "notes": "Interested in bulk order",
    "assignedTo": null,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
]
```

---

#### 3. **GET `/sales-requests/:id`** (User)
Get a single sales request by ID.

**Authentication**: Required (JWT)

**Parameters**:
- `id` (path): Sales request UUID

**Response** (200 OK):
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "userId": "123",
  "productIds": ["550e8400-e29b-41d4-a716-446655440000"],
  "status": "pending",
  "notes": "Interested in bulk order",
  "assignedTo": null,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Error Responses**:
- `404 Not Found`: Sales request not found or doesn't belong to user

---

#### 4. **GET `/sales-requests/admin/all`** (Admin Only)
Get all sales requests across all users.

**Authentication**: Required (JWT + Admin privileges)

**Response** (200 OK):
```json
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "userId": "123",
    "productIds": ["550e8400-e29b-41d4-a716-446655440000"],
    "status": "pending",
    "notes": "Interested in bulk order",
    "assignedTo": null,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
]
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: User is not an admin

---

#### 5. **PATCH `/sales-requests/admin/:id`** (Admin Only)
Update a sales request (status, notes, assignment).

**Authentication**: Required (JWT + Admin privileges)

**Parameters**:
- `id` (path): Sales request UUID

**Request Body** (all fields optional):
```json
{
  "status": "contacted",
  "notes": "Contacted user via email on 2024-01-16",
  "assignedTo": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Status Values**: `pending`, `contacted`, `converted`, `rejected`

**Response** (200 OK):
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "userId": "123",
  "productIds": ["550e8400-e29b-41d4-a716-446655440000"],
  "status": "contacted",
  "notes": "Contacted user via email on 2024-01-16",
  "assignedTo": "550e8400-e29b-41d4-a716-446655440000",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-16T14:20:00Z"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: User is not an admin
- `404 Not Found`: Sales request not found

---

## Products with Summary Statistics

### Overview
This API endpoint provides products along with aggregated statistics about importers, exporters, and shipment records. The statistics are calculated by matching product HS codes with shipment record HS codes.

### How It Works

1. **HS Code Matching**: Products are linked to shipment records through HS codes:
   - `Product.hscode` matches `ShipmentRecord.hsCode`
   - Only products with HS codes will have aggregated statistics

2. **Statistics Calculated**:
   - **Total Shipment Records**: Count of all shipment records with matching HS code
   - **Total Importers**: Count of unique importer profiles (from `importerId` field)
   - **Total Exporters**: Count of unique exporter profiles (from `exporterId` field)

3. **User-Based Filtering**:
   - **If user is Importer (userTypeId=1)**: Only shows exporters count (opponents), importers count is 0
   - **If user is Exporter (userTypeId=2)**: Only shows importers count (opponents), exporters count is 0
   - **If user is Service Provider (userTypeId=3) or has no type**: Shows both importers and exporters counts

4. **Data Aggregation**:
   - For each product, the system queries all shipment records with matching HS codes
   - Unique importers and exporters are counted (excluding null values)
   - Statistics are filtered based on the authenticated user's type
   - Products without HS codes will show 0 for all statistics

### API

#### **GET `/products/summary`** (Authenticated)
Get all products with summary statistics (importers, exporters, shipment records).

**Authentication**: Required (JWT)

**Query Parameters**:
- `locale` (optional): Language code for product names (default: `en`)
- `page` (optional): Page number (default: `1`)
- `limit` (optional): Items per page (default: `20`)
- `hscode` (optional): Filter by HS code (prefix match)
- `name` (optional): Filter by product name (case-insensitive partial match)

**Example Request**:
```
GET /products/summary?locale=en&page=1&limit=20&hscode=0901&name=coffee
Authorization: Bearer <JWT_TOKEN>
```

**Response Examples**:

*For an Importer user (userTypeId=1) - only exporters shown*:
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Organic Coffee Beans",
      "hscode": "0901.11.00",
      "categoryId": 1,
      "totalShipmentRecords": 150,
      "totalImporters": 0,
      "totalExporters": 32,
      "createdAt": "2024-01-10T08:00:00Z",
      "updatedAt": "2024-01-15T12:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

*For an Exporter user (userTypeId=2) - only importers shown*:
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Organic Coffee Beans",
      "hscode": "0901.11.00",
      "categoryId": 1,
      "totalShipmentRecords": 150,
      "totalImporters": 45,
      "totalExporters": 0,
      "createdAt": "2024-01-10T08:00:00Z",
      "updatedAt": "2024-01-15T12:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

*For a Service Provider user (userTypeId=3) or user with no type - both shown*:
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Organic Coffee Beans",
      "hscode": "0901.11.00",
      "categoryId": 1,
      "totalShipmentRecords": 150,
      "totalImporters": 45,
      "totalExporters": 32,
      "createdAt": "2024-01-10T08:00:00Z",
      "updatedAt": "2024-01-15T12:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

**Response Fields**:
- `id`: Product public ID (UUID)
- `name`: Product name (translated based on locale)
- `hscode`: HS Code (Harmonized System code) - can be null
- `categoryId`: Product category ID - can be null
- `totalShipmentRecords`: Total number of shipment records with matching HS code
- `totalImporters`: Total number of unique importers
- `totalExporters`: Total number of unique exporters
- `createdAt`: Product creation timestamp
- `updatedAt`: Product last update timestamp

**Notes**:
- Products without HS codes will have all statistics set to 0
- Statistics are calculated in real-time by querying shipment records
- Statistics are filtered based on the authenticated user's type (Importer/Exporter/Service Provider)
- If user is Importer: only `totalExporters` will have a value, `totalImporters` will be 0
- If user is Exporter: only `totalImporters` will have a value, `totalExporters` will be 0
- If user is Service Provider or has no type: both counts will be shown
- The endpoint supports pagination, filtering by HS code, and searching by product name
- Product names are returned in the requested locale (or English by default)
- Authentication is required to access this endpoint

---

## Summary

### Sales Requests
- **5 APIs** available for managing sales requests
- Users can create and view their own requests
- Admins can view all requests and update them
- Supports status tracking, notes, and assignment to admins

### Products with Summary Statistics
- **1 API** available for getting products with aggregated statistics
- Requires authentication (JWT)
- Provides real-time statistics on importers, exporters, and shipment records
- Statistics are filtered based on user type:
  - Importers see only exporters (opponents)
  - Exporters see only importers (opponents)
  - Service Providers see both
- Statistics are calculated by matching product HS codes with shipment record HS codes
- Supports pagination, filtering, and localization

---

## Technical Details

### Database Relationships

**Sales Requests**:
- `SalesRequest.userId` → `User.id` (many-to-one)
- `SalesRequest.productIds` → `Product.id[]` (array of BigInt IDs)
- `SalesRequest.assignedTo` → `Admin.id` (optional, many-to-one)

**Products & Shipment Records**:
- `Product.hscode` (string) matches `ShipmentRecord.hsCode` (string)
- No direct foreign key relationship - matching is done via HS code string comparison
- `ShipmentRecord.importerId` → `Profile.id` (many-to-one, nullable)
- `ShipmentRecord.exporterId` → `Profile.id` (many-to-one, nullable)

### Performance Considerations

- The products summary endpoint performs aggregation queries for each product
- For large datasets, consider adding database indexes on `ShipmentRecord.hsCode`, `ShipmentRecord.importerId`, and `ShipmentRecord.exporterId`
- Future optimization could include caching aggregated statistics or pre-computing them in a separate table
